# 01 — Catálogo de Integraciones Externas

> **Proyecto:** Lumba Ecommerce (Brownfield — migración PHP vanilla → NestJS + Tailwind)
> **Fecha:** 2026-06-04
> **Agente:** System Auditor (subagent)
> **Modelo:** deepseek-v4-pro
> **Nivel de confianza global:** MEDIA (las implementaciones de `llamadoCurl` y APIs de envío no son completamente visibles)
> **Fuente:** `connect/`, `inc/funciones.php`, `routes/checkout_4.php`, `admin/routes/configuracion.php`

---

## 4.1 MercadoPago

### Tipo de integración
API directa con IPN (webhook de retorno). **No usa SDK oficial** — comunicación vía `llamadoCurl()`.

### Configuración
| Parámetro | Fuente | Notas |
|---|---|---|
| Access Token | `configuracion.mercadopago_access_token` | Almacenado en tabla `configuracion` (variable/valor) |
| Cuotas máximas | `configuracion.cuotas_mercadopago` | Opcional — si existe y es numérico, se limita la cantidad de cuotas |
| ID de compra | `pedidos.Id` | Se usa como referencia externa |
| Hash | `pedidos.hash` | Identificador público de 8 caracteres |

### Flujo de pago

1. **Inicio (checkout_4.php):**
   ```php
   $datos = [
     'servicio' => 'mercadopago',
     'total' => floatval($total + $costo_envio),
     'mp_credenciales' => $_SESSION['configuracion']['mercadopago_access_token'],
     'id_compra' => $pedido_id,
     'hash' => $hash,
     'cuotas' => intval($_SESSION['configuracion']['cuotas_mercadopago']) // opcional
   ];
   $respuesta = llamadoCurl(json_encode($datos));
   ```
   `llamadoCurl()` [NO DETECTADO: implementación — está en `inc/funciones.php` pero el archivo se truncó. Hipótesis: envía POST a un endpoint interno/proxy que a su vez crea la preferencia de pago en MercadoPago y devuelve `{url_pago}`].

2. **Redirección:** el frontend muestra link y redirige automáticamente vía JS a `respuesta.url_pago` (Checkout de MercadoPago).

3. **Emails:** NO se envían en este punto. Se guardan en `pedidos_emails` con `enviado=0`.

4. **Callback de retorno:** `/mercadopago/{estado}/{hash}` → carga `routes/mercadopago.php` que muestra pantalla de éxito/proceso/error según `estado`.

### IPN / Webhook

**Archivo:** `connect/mp_ipn.php`
**Método:** POST (JSON)
**Payload esperado:**
```json
{
  "pedido_id": 123,
  "order_status": "paid" | "reverted"
}
```

**Acciones según estado:**
- `paid`:
  1. `UPDATE pedidos SET estado='Pagado', estado_pago='Pagado' WHERE Id='$pedido_id'`
  2. Itera `pedidos_emails` pendientes (`enviado=0`) y los envía con `enviarmail()`
  3. `actualizarStock($pedido_id, 'restar')` — descuenta inventario
  4. `confirmarEnvioZipnova($pedido_id)` — [NO DETECTADO: dispara envío vía API Zipnova]
- `reverted`:
  1. `UPDATE pedidos SET estado='Reintegrado', estado_pago='Reintegrado'`
  2. `actualizarStock($pedido_id, 'sumar')` — repone inventario

**Seguridad:** [⚠️ CRÍTICO] No se detecta validación de firma o autenticidad del webhook. El IPN confía ciegamente en el cuerpo JSON. Esto debe ser prioridad en la migración.

---

## 4.2 Modo

### Tipo de integración
API directa con webhook de retorno. Comunicación vía `llamadoCurl()`.

### Configuración
| Parámetro | Fuente |
|---|---|
| Username | `configuracion.modo_username` |
| Password | `configuracion.modo_password` |
| Processor Code | `configuracion.modo_processor_code` |
| CC Code | `configuracion.modo_cc_code` |

### Flujo de pago

1. **Inicio (checkout_4.php):**
   ```php
   $datos = [
     'servicio' => 'modo',
     'currency' => 'ARS',
     'total' => floatval($total + $costo_envio),
     'processor_code' => $processor_code,
     'username' => $username,
     'password' => $password,
     'cc_code' => $cc_code,
     'id_compra' => $pedido_id,
     'hash' => $hash,
     'email' => $email,
     'nombre_completo' => $nombre_completo,
     'tipo_documento' => 'DNI' | 'CUIT',
     'nacimiento' => '1980-06-20',
     'telefono' => $area.$telefono,
     'cliente_id' => $cliente_id ?? $pedido_id,
     'calle', 'numero', 'provincia', 'localidad', 'cp',
     'logo' => $base.'img/logos/logo.{ext}',
     'categoria' => 'CATEGORIA',
     'sku' => 'PRODUCTOS'
   ];
   $respuesta = llamadoCurl(json_encode($datos));
   ```

2. **Respuesta esperada:** `{url_pago, qr}`. Si se recibe, muestra QR (desktop) y link de pago (mobile).

3. **Nota:** `nacimiento` está hardcodeado a `'1980-06-20'`. [⚠️ Esto es incorrecto — debe usar el dato real del cliente si está disponible.]

### Webhook

**Archivo:** `connect/modo_webhook.php`
**Método:** POST (JSON)
**Payload esperado:**
```json
{
  "pedido_id": "ABC12345",
  "order_status": "ACCEPTED"
}
```

**Acciones:**
- `ACCEPTED`:
  1. Busca pedido por `hash` (no por Id numérico): `SELECT * FROM pedidos WHERE hash='$pedido_id'`
  2. Obtiene el Id numérico real
  3. `UPDATE pedidos SET estado_pago='Pagado' WHERE Id='$pedido_id_real'`
  4. Envía emails pendientes
  5. `actualizarStock($pedido_id, 'restar')`
  6. `confirmarEnvioZipnova($pedido_id)`

**Seguridad:** [⚠️ CRÍTICO] Misma situación que MP — no hay validación de autenticidad del webhook.

---

## 4.3 PadPio (Gestión de Inventario y Precios)

### Tipo de integración
Conexión directa a 2 bases de datos SQL Server (MSSQL) vía extensión PHP `sqlsrv`.

### Configuración
| Parámetro | Fuente |
|---|---|
| Host | `configuracion.padpio_host` |
| Usuario | `configuracion.padpio_user` |
| Password | `configuracion.padpio_password` |

### Bases de datos conectadas
| Base | Puerto | Propósito (inferido por marca) |
|---|---|---|
| `PadPioResist` | `padpio_host:9143` | Marca ID 1 (Resistencia) |
| `PadPioMaxPaz` | `padpio_host:9144` | Otras marcas (MaxPaz) |

### Operaciones

**Archivo:** `connect/padpio.php?tipo=stock|precios`

**Stock (`tipo=stock`):**
1. Conecta a cada base SQL Server.
2. `SELECT * FROM Stock` → obtiene `{Codigo, Stock}`.
3. Cruza por SKU (`productos_variantes.sku`) contra los productos locales.
4. Verifica coincidencia de marca con la base correspondiente (`marca_id=1` para Resistencia).
5. `UPDATE productos_variantes_stock SET stock='$stock', stock_infinito='0' WHERE producto_id=... AND variante_id=... AND sucursal_id='$sucursal_id_default'`.

**Precios (`tipo=precios`):**
1. `SELECT * FROM Precios` → obtiene `{Producto (SKU), Precio, PrecioOfertaE, Lista}`.
2. Filtra por `Lista == '000'` y `Precio > 0`.
3. Cruza por SKU, aplica multiplicador de propiedad si `propiedades_valores.valor2 > 1`.
4. `UPDATE productos_variantes_precios SET precio='$precio' WHERE ... AND lista_id='$lista_id_default'`.
5. Detecta ofertas (`PrecioOfertaE > 0 && < Precio`), calcula porcentajes de descuento.
6. **Elimina promociones automáticas previas** (`DELETE/UPDATE promociones SET eliminado=1 WHERE promocion_tipo='00'`).
7. **Crea nuevas promociones** tipo `00` con `INSERT INTO promociones` para cada porcentaje detectado.
8. Actualiza `productos.precio_desde` con el mínimo de todas las variantes.

**Dependencias:**
- Requiere extensión PHP `sqlsrv` (Windows-only drivers para SQL Server).
- En la migración a Node.js, se debe usar `mssql` package (tedious) o `node-mssql`.

---

## 4.4 ZN (Zipnova) — Envíos

### Tipo de integración
API para cotización y gestión de envíos, más webhook para tracking.

### Configuración
[NO DETECTADO: credenciales — posiblemente en `configuracion` con prefijo `zipnova_*` o en `funciones.php` dentro de `llamadoCurl()`]

### Flujo de cotización
[NO DETECTADO: La cotización en `checkout_2_envio.php` probablemente llama a una API de Zipnova vía AJAX. El resultado se guarda en `$_SESSION['checkout']['zipnova_resultados']` como JSON con estructura `{results: {opcion_id: {amounts: {price_incl_tax: ...}}}, all_results: {...}}`.]

### En checkout_4
- Si la forma de entrega es Zipnova, se extrae `costo_envio` del JSON de resultados.
- Se persiste `zipnova_json` con los datos completos de la cotización.
- Se guarda `zipnova_opcion` y `zipnova_point_id`.

### Webhook de tracking

**Archivo:** `connect/zn_webhook.php`
**Método:** POST (JSON)
**Payload esperado:**
```json
{
  "pedido_id": 123,
  "estado": "Enviado" // o código de estado
}
```

**Acción:** `UPDATE pedidos SET estado_envio='estado' WHERE Id='$pedido_id'`

[⚠️ **BUG CRÍTICO:**] El valor se asigna literalmente como string `'estado'` en lugar de usar la variable `$estado`:
```php
$sql = "UPDATE pedidos SET estado_envio='estado' WHERE Id='$pedido_id'";
// Debería ser:
// $sql = "UPDATE pedidos SET estado_envio='$estado' WHERE Id='$pedido_id'";
```
Esto significa que **el tracking de Zipnova nunca funciona correctamente** en producción.

### Confirmación de envío
`confirmarEnvioZipnova($pedido_id)` se llama desde los IPN/webhooks de pago. [NO DETECTADO: implementación — probablemente hace una llamada a la API de Zipnova para confirmar/despachar el envío]

---

## 4.5 APIs de Envío — Logística Propia

### Tipo
No es una integración externa de API. Son reglas de negocio locales configuradas en `envios_propios`.

**Funcionamiento:**
- Admin configura métodos de envío con: nombre, precio, provincia, localidades cubiertas (JSON), información adicional, reglas de envío gratis.
- En checkout, se filtran por provincia y localidad del cliente.
- Se aplica envío gratis si: (a) `envio_gratis.activo=1` y total >= monto, o (b) el método tiene `envio_gratis=1` y total >= mínimo, o (c) hay cupón de tipo "Envío gratis".

---

## 4.6 OpenAI (Chatbot)

### Tipo de integración
API directa a OpenAI Chat Completions.

### Configuración
| Parámetro | Valor | Notas |
|---|---|---|
| API Key | Hardcodeada en `ajax/chat_handler.php` | [⚠️ CRÍTICO] Debe moverse a variable de entorno |
| Modelo | `gpt-4o-mini` | |
| Max tokens | 1000 | |
| Endpoint | `https://api.openai.com/v1/chat/completions` | |

### Funcionamiento
Ver sección 3.9 de `01-flujos-negocio.md`.

---

## 4.7 Dicomere (ERP)

### Tipo de integración
Archivos PHP en `importar_web/` que importan datos desde Dicomere.

**Archivos:**
- `importar_dicomere.php` — importa productos
- `importar_clientes_dicomere.php` — importa clientes
- `importar_pedidos_dicomere.php` — importa pedidos

[NO DETECTADO: método de conexión — podría ser API, CSV, o acceso directo a DB]

---

## 4.8 PHPMailer (Emails)

### Tipo
Librería PHP (vendor) usada para envío de emails transaccionales. No es una API externa per se, pero requiere configuración SMTP.

### Uso
- `enviarmail($destinatario, $asunto, $cuerpo, $path)` en `inc/funciones.php`
- `enviar_mail_plantilla($plantilla_nombre, $variables, $destinatario, $path, $config)` — compila plantillas desde `emails_plantillas`
- Plantillas detectadas:
  - `pedido_confirmacion_cliente`
  - `pedido_confirmacion_admin`
  - `registro_bienvenida_compra`
  - `carrito_abandonado`
  - `encuesta_cupon_regalo`
  - [NO DETECTADO: más plantillas]

### Configuración SMTP
[NO DETECTADO: credenciales SMTP — probablemente en `configuracion` o hardcodeadas en `funciones.php`]

---

## 4.9 reCAPTCHA

### Tipo
Google reCAPTCHA v3.

### Configuración
| Parámetro | Fuente |
|---|---|
| Site Key | `configuracion.recaptcha_site_key` |
| Secret Key | `configuracion.recaptcha_secret_key` |

### Uso
En formularios de contacto y devoluciones. Se activa solo si ambas keys están configuradas.

---

## 4.10 Otras APIs y Servicios Detectados

### APIs de envío (cotización con CP)
**Archivo:** `ajax/cotizar_envio_con_cp.php` [NO DETECTADO: implementación]
Probablemente consulta a API de Zipnova o servicio de cálculo de envíos por código postal.

### Exportación Excel
**Archivos:** `admin/components/productos_export_xlsx.php`, `admin/ajax/productos_excel_exportar.php`
Usa PhpSpreadsheet (vendor library). No es API externa pero es funcionalidad a migrar (usar `exceljs` en Node).

### Importación Excel
**Archivos:** `admin/components/productos_plantilla_import_xlsx.php`, `admin/routes/importar_productos.php`
Usa PhpSpreadsheet para leer XLSX.

---

## 4.11 Resumen de Integraciones para Migración

| Integración | Prioridad | Complejidad | Notas |
|---|---|---|---|
| MercadoPago | **Crítica** | Alta | Migrar a SDK oficial de Node.js (mercadopago). Implementar validación de webhooks con `x-signature`. |
| Modo | **Crítica** | Alta | Evaluar SDK oficial Node.js. Validar webhooks. Corregir `nacimiento` hardcodeado. |
| PadPio | **Crítica** | Alta | Migrar conexión MSSQL a `node-mssql`. Las 2 BBDD con puertos 9143/9144. |
| Zipnova (ZN) | **Crítica** | Alta | Implementar API correctamente. **Corregir bug del webhook** (estado hardcodeado). |
| OpenAI Chat | Alta | Baja | Mover API key a `.env`. Mantener lógica de knowledge injection. |
| Envíos propios | Alta | Baja | Es lógica de negocio local — migrar a servicio NestJS. |
| PHPMailer → Nodemailer | Alta | Media | Configurar SMTP, migrar sistema de plantillas. |
| Dicomere | Media | Alta | Determinar método de conexión. Si es DB directa, migrar a consultas SQL directas vía NestJS. |
| Google reCAPTCHA | Media | Baja | Usar package NestJS o middleware manual. |
| PhpSpreadsheet | Media | Media | Migrar a `exceljs` o `xlsx` package de Node.js. |
