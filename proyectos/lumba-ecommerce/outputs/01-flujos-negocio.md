# 01 — Flujos de Negocio Documentados

> **Proyecto:** Lumba Ecommerce (Brownfield — migración PHP vanilla → NestJS + Tailwind)
> **Fecha:** 2026-06-04
> **Agente:** System Auditor (subagent)
> **Modelo:** deepseek-v4-pro
> **Nivel de confianza global:** ALTA (flujos inferidos del código PHP)
> **Fuente:** Código fuente en `routes/`, `inc/`, `ajax/`, `admin/`, `cron/`, `connect/`

---

## 3.1 Flujo de Compra Completo

### Paso 0: Catálogo y Descubrimiento

**Archivos:** `routes/productos.php`, `routes/productos_grilla.php`, `inc/get_products.php`, `routes/producto.php`, `routes/home.php`

1. El cliente accede a `/productos`, `/categoria/{url}`, `/marca/{url}`, `/tag/{url}` o la home.
2. `inc/get_products.php` construye una query dinámica con múltiples joins:
   - Filtro base: `productos.eliminado='0' AND productos.activo='1'`
   - **Restricción de marcas** por cliente (si `$_SESSION['cliente']['marcas']` tiene IDs, se agrega `WHERE productos.marca_id IN (...)`)
   - Filtro por categoría (`productos_categorias JOIN`)
   - Filtro por propiedades (múltiples `INNER JOIN productos_propiedades_valores AS ppv{N}`)
   - Filtro por precio máximo (`INNER JOIN productos_variantes_precios AS pvp_filter`)
   - Filtro por tags (`INNER JOIN productos_tags + tags`)
   - Filtro por marca (`INNER JOIN marcas`)
3. Se calculan `MIN/MAX` de precios para los filtros de rango.
4. Se aplica paginación con `LIMIT/OFFSET`.
5. Si se usa AJAX (`productos_grilla.php`), se devuelve HTML parcial para carga infinita.
6. En la página de producto individual (`/producto/{url}`), se muestran:
   - Variantes (combinaciones de propiedades)
   - Precio según lista del cliente
   - Stock por sucursal
   - Productos relacionados
   - Selector de cantidad y botón "Agregar al carrito"

### Paso 1: Agregar al Carrito

**Archivos:** `ajax/agregarcarrito.php`, `routes/cart.php`

1. AJAX POST a `ajax/agregarcarrito.php` con `producto_id`, `variante_id`, `cantidad`, `precio`, `sku`, `url`, `foto`, `iva`.
2. **Validación de stock server-side:** consulta `productos_variantes_stock` para `sucursal_id`. Si `stock_infinito=0` y `stock < cantidad`, el script hace `exit` (no agrega).
3. **Validación de precio server-side:** consulta `productos_variantes_precios` con el `lista_id` del cliente. Si el precio no coincide, se usa el de DB (ignora el del POST — anti-tampering).
4. **Validación de promociones:** `buscarPromoPorProducto()` busca promociones activas aplicables al producto (tipo `00` = porcentaje, `0` = cantidad).
5. El item se guarda en `$_SESSION['carrito'][producto_id][variante_id]` con cantidad, precio, foto, sku, datos de promoción.

### Paso 2: Carrito

**Archivos:** `routes/cart.php`, `components/resumen_carrito.php`

1. Al cargar `/cart`, se itera `$_SESSION['carrito']`:
   - Se recalcula dinámicamente la promoción aplicable (`buscarPromoPorProducto`)
   - Se verifica si el cupón de sesión aplica al producto (por tipo: toda la tienda / categorías / productos)
   - Si la promoción es tipo `00` o `0`, se descuenta `precio * valor / 100`
   - Si aplica cupón de porcentaje y es acumulable, se descuenta adicionalmente
   - Si el cupón es de "Monto fijo", se resta del total final
2. Se actualiza `$_SESSION['carrito_resumen']` con totales, IVA, costo de entrega, descuentos.
3. Se actualiza `$_SESSION['carrito_productos']` con array plano de productos.
4. El cliente puede modificar cantidades (formulario POST) o eliminar items (POST con `cantidad=0`).

### Paso 3: Checkout Paso 1 — Datos Personales

**Archivos:** `routes/checkout_1.php`, `inc/collect_checkout_info.php`

1. Si `$_SESSION['configuracion']['tipos_cliente'] == '1'`, se muestra selector de tipo de cliente (perfil).
2. Al seleccionar tipo de cliente, JS muestra/oculta campos según configuración del tipo:
   - Personales: nombre, apellido, DNI, teléfono
   - Empresa: razón social, nombre fantasía, CUIT
   - Situación fiscal
   - Tipo de comprobante (filtrado por los permitidos para ese tipo de cliente)
3. Email (pre-llenado si está logueado, requerido si no).
4. Checkbox de marketing.
5. **Validación de compra mínima:** si `total < cliente.minimo_compra`, se bloquea el botón con mensaje.
6. Al submit, se guardan datos en `$_SESSION['checkout']`.

### Paso 4: Checkout Paso 2 — Forma de Entrega

**Archivos:** `routes/checkout_2.php`, `routes/checkout_2_envio.php`

1. Se muestran opciones según configuración del cliente:
   - **Retiro por sucursal** (gratis, info de `configuracion.retiro_por_sucursal_informacion`)
   - **Envío a domicilio** (Zipnova o logística propia)
   - **Retiro en punto Zipnova**
2. Si selecciona envío a domicilio, se muestran campos de dirección:
   - Selector de direcciones guardadas (si está logueado)
   - Calle, número, departamento, CP, localidad, provincia
   - AJAX para localidades por CP y provincias por localidad
3. Checkbox "Los datos de entrega son mis datos de facturación". Si se destilda, aparecen campos de facturación separados.
4. Al seleccionar envío a domicilio, el formulario redirige a `checkout_2_envio` que muestra:
   - **Logística propia:** métodos configurados en `envios_propios` filtrados por provincia y localidad
   - **Zipnova:** [NO DETECTADO: cotización en tiempo real vía API]
   - Aplicación de envío gratis si aplica (general, por método, o cupón)

### Paso 5: Checkout Paso 3 — Medio de Pago

**Archivos:** `routes/checkout_3.php`

1. Se muestran métodos de pago según perfil del cliente (`$_SESSION['cliente']`):
   - **MercadoPago** (si `cliente.mercadopago == '1'` y el servicio está en `servicios_connect`)
   - **Modo** (si `cliente.modo == '1'` y el servicio está en `servicios_connect`)
   - **Transferencia bancaria** (si `cliente.transferencia == '1'`)
   - **Efectivo** (si `cliente.efectivo == '1'`)
2. Se muestra banner de promociones bancarias.
3. Validación de compra mínima.

### Paso 6: Checkout Paso 4 — Confirmación y Pago

**Archivos:** `routes/checkout_4.php`, `inc/guardar_pedido_parcial.php`

1. **Creación/actualización del pedido** (`inc/guardar_pedido_parcial.php` se ejecuta desde pasos anteriores):
   - Si `$_SESSION['checkout']['pedido_id']` existe → UPDATE
   - Si no → INSERT con estado `'Incompleto'`
   - Sincroniza `pedidos_detalle` (DELETE + INSERT de todos los items del carrito)

2. **Confirmación final** en `checkout_4.php`:
   - Si el cliente no está logueado y el email no existe en `clientes` → **crea nuevo cliente** automáticamente:
     - Genera contraseña random (8 chars)
     - Hashea con md5
     - Genera hash de 32 chars
     - Asigna vendedor predeterminado y lista predeterminada
     - Envía email de bienvenida con credenciales
   - **Transacción MySQL** (`BEGIN TRANSACTION`):
     - Valida stock con `SELECT ... FOR UPDATE` (bloqueo de fila)
     - Si `stock_infinito=0` y `stock < cantidad` → ROLLBACK y error
     - UPDATE del pedido con estado `'Activo'` y todos los datos finales
     - INSERT de nueva dirección si se usó una nueva (primera dirección = predeterminada)
     - UPDATE de `clientes.area`, `clientes.telefono`
   - **COMMIT de la transacción**

3. **Ruteo por forma de pago:**

   **a) MercadoPago:**
   - Llama a `llamadoCurl()` con payload JSON: `{servicio: 'mercadopago', total, mp_credenciales, id_compra: pedido_id, hash, cuotas}`
   - `llamadoCurl` [NO DETECTADO: implementación en `funciones.php` — se comunica con API de MercadoPago]
   - Si obtiene `url_pago`, redirige automáticamente (JS `setTimeout 1000ms`) a la URL de pago de MP
   - Los emails NO se envían todavía — quedan en `pedidos_emails` con `enviado=0`
   - El IPN (`connect/mp_ipn.php`) recibe el webhook cuando el pago se complete

   **b) Modo:**
   - Similar a MP: payload a `llamadoCurl()` con `servicio: 'modo'`, credenciales, datos del comprador
   - Si obtiene `url_pago`, muestra QR y link de pago
   - Webhook en `connect/modo_webhook.php` recibe la confirmación

   **c) Transferencia:**
   - Muestra datos bancarios (de `configuracion.datos_bancarios`) y link para subir comprobante
   - Envía emails inmediatamente (cliente + admin)
   - Redirige a `/comprobantes/{hash}` para subir comprobante

   **d) Efectivo:**
   - Muestra mensaje de éxito con código de compra
   - Envía emails inmediatamente

4. **Después de la confirmación:** se limpia el carrito (`unset($_SESSION['carrito'], $_SESSION['carrito_productos'], $_SESSION['carrito_resumen'], $_SESSION['checkout'], $_SESSION['cupon'])`).

---

## 3.2 Flujo de Administración

### 3.2.1 Login Admin

**Archivos:** `admin/login.php`, `admin/index.php`

1. El admin accede a `/admin/`.
2. `admin/index.php` verifica `$_SESSION["login"] != 'si'` → redirige a `login.php`.
3. Login: email + contraseña. La contraseña se compara **en texto plano** (`$rArray['contrasenia'] === $contrasenia`).
4. Si coincide, carga en sesión:
   - `usuario_id`, `usuario_nombre`, `usuario_email`
   - `usuario_tipo`, `usuario_tipo_id`, `usuario_home` (ruta default)
   - `permisos[seccion] = 'si'` (desde `administradores_tipos_permisos JOIN secciones_admin`)
5. Redirige a la home del usuario o a la URL original si venía con `redir`.

### 3.2.2 Dashboard

**Archivos:** `admin/routes/dashboard.php`

1. Selector de mes para filtrar métricas.
2. KPIs: ventas del mes actual vs mes anterior, cantidad de pedidos, ticket promedio, productos más vendidos, clientes nuevos. [NO DETECTADO: métricas exactas — el archivo se truncó en la lectura]

### 3.2.3 Gestión de Pedidos

**Archivos:** `admin/routes/pedidos.php`, `pedidos_edit.php`, `pedidos_view.php`, `pedidos_new.php`, `admin/ajax/actualizar_estados.php`, `admin/ajax/pedidos_edit_guardar.php`, `admin/ajax/pedidos_new_*.php`

**Listado:**
- DataTable con filtros por fecha, estado, estado de pago, estado de entrega
- Columnas: ID, fecha, cliente, total, estado, pago, entrega, factura, acciones
- Acciones: ver, editar, imprimir, exportar a RoTSis

**Crear pedido manual (admin):**
- Buscar cliente (AJAX `pedidos_new_buscar_clientes.php`)
- Buscar productos (AJAX `pedidos_new_buscar_productos.php`)
- Datos del cliente (AJAX `pedidos_new_datos_cliente.php`)
- Guardar (AJAX `pedidos_new_guardar.php`)

**Editar pedido:**
- Cambiar estado general (select)
- Cambiar estado de pago (select)
- Cambiar estado de entrega (select)
- Cambiar estado de factura (select)
- Agregar/quitar productos
- Agregar tracking de envío
- Los cambios de estado se persisten vía AJAX `actualizar_estados.php`

**Ver pedido:**
- Vista detallada con todos los datos, imprimible (jsPDF/html2pdf)
- Muestra historial de estados [NO DETECTADO: posible]

### 3.2.4 Gestión de Productos

**Archivos:** `admin/routes/productos.php`, `productos_edit.php`, `productos_new.php`, `productos_variantes.php`, `productos_stock.php`, `productos_excel.php`, `importar_productos.php`

1. **Listado:** DataTable con filtros, búsqueda.
2. **Crear/Editar producto:** formulario con nombre, URL, descripción, marca, categorías, propiedades, tags, keywords, fotos, estado activo.
3. **Variantes:** CRUD de combinaciones con SKU, propiedades, foto propia.
4. **Precios por variante:** por lista de precios. Admin gestiona vía `admin/ajax/precios.php`.
5. **Stock por variante:** por sucursal, con toggle `stock_infinito`. Admin gestiona vía `admin/ajax/stock.php`.
6. **Importación masiva:** Excel (PhpSpreadsheet) vía `importar_productos.php` y plantilla de `components/productos_plantilla_import_xlsx.php`.
7. **Exportación a Excel:** vía `admin/ajax/productos_excel_exportar.php` y `components/productos_export_xlsx.php`.
8. **Productos relacionados:** selector de productos vinculados.
9. **Sincronización PadPio:** botón en admin que dispara `connect/padpio.php?tipo=stock` o `?tipo=precios`.

### 3.2.5 Estados de Pedido y Transiciones

**Estados detectados:**
- **Pedido:** 'Incompleto' → 'Activo' → 'Reintegrado' [NO DETECTADO: más estados posibles]
- **Pago:** 'Pendiente' → 'Pagado' → 'Reintegrado'
- **Entrega:** 'Pendiente' → [NO DETECTADO: 'Enviado', 'Entregado']
- **Factura:** 'Pendiente' → [NO DETECTADO: 'Facturado']

El cambio de estados se hace desde el admin individualmente o vía webhooks/IPN para pagos automáticos.

---

## 3.3 Flujo de Registro y Login de Cliente

### 3.3.1 Registro

**Archivos:** `routes/account_register.php`

1. Formulario con campos según tipo de cliente.
2. Al submit, se crea registro en `clientes`:
   - `contrasenia = md5(password)` (sin salt)
   - `hash = random_strings(32)` (para activación)
   - `activo = 0`
3. Se envía email con link de activación: `/account_activate/{hash}`.
4. [NO DETECTADO: validación de email único]

### 3.3.2 Activación

**Archivos:** `routes/home.php` (con `action=account_activate`), `inc/account_activate.php`

1. Cliente clickea link `/account_activate/{hash}`.
2. `inc/account_activate.php` busca cliente por hash.
3. Si existe: `UPDATE clientes SET activo='1' WHERE hash='{hash}'`.
4. Loguea automáticamente al cliente (carga toda la sesión).
5. Redirige a home.

### 3.3.3 Login

**Archivos:** `routes/account_signin.php`, `inc/account_signin.php`

1. Formulario: email + contraseña.
2. `inc/account_signin.php`:
   - `contrasenia = md5($_POST['contrasenia'])`
   - Busca en `clientes WHERE email='...' AND contrasenia='...'`
3. Si encuentra, carga en `$_SESSION['cliente']`:
   - Datos personales (nombre, apellido, email, teléfono, CUIT, DNI, etc.)
   - `lista_id`, `tipo_id`, `compro`, `hash`
   - **Carga perfil de cliente** (`clientes_tipos`): métodos de pago habilitados, envíos, mínimo compra
   - **Marcas permitidas:** primero busca en `clientes.marcas`, si vacío hereda de `clientes_tipos.marcas`
   - **Compra mínima:** si el tipo tiene `minimo_compra > 0`, usa ese; sino usa el global de `compra_minima`
4. Carga favoritos en `$_SESSION['favoritos']`.
5. Redirige a home.

### 3.3.4 Recuperación de Contraseña

**Archivos:** `routes/account_recover.php`, `routes/account_password_recover.php`

1. Cliente clickea "Olvidé mi contraseña" → formulario de email.
2. [NO DETECTADO: genera token y envía email con link `/account_password_recover/{hash}`]
3. Cliente clickea link → formulario de nueva contraseña.
4. `account_password_recover.php`: `UPDATE clientes SET contrasenia=md5(nueva) WHERE hash='{hash}'`.

---

## 3.4 Flujo de Recuperación de Carrito Abandonado

**Archivos:** `cron/carritos_abandonados.php`, `acciones/retomar_compra.php`

1. **Cron** (debe ejecutarse cada 1 hora vía cron del servidor):
   - Carga configuración: `configuracion.cron_carritos_abandonados` (horas de espera) y `configuracion.cron_carritos_abandonados_cupon` (ID de cupón)
   - Busca pedidos: `WHERE estado='Incompleto' AND cron_notificado='0' AND eliminado='0' AND email != ''`
   - Filtra por ventana de tiempo: `fecha >= NOW() - INTERVAL {horas} HOUR AND fecha < NOW() - INTERVAL ({horas} - 1) HOUR`
2. Para cada pedido encontrado:
   - Carga `pedidos_detalle` para armar resumen de productos
   - Si hay cupón configurado, agrega sección con código y descuento
   - Genera link: `acciones/retomar_compra.php?hash={pedido.hash}&cupon={codigo_cupon}`
   - Envía email vía `enviar_mail_plantilla('carrito_abandonado', ...)`
   - Marca `pedidos.cron_notificado = 1`
3. `acciones/retomar_compra.php`:
   - Recibe `hash` del pedido y opcionalmente `cupon`
   - Restaura el carrito desde `pedidos_detalle`
   - Aplica el cupón automáticamente
   - Redirige al checkout

---

## 3.5 Flujo de Devoluciones

**Archivos:** `routes/devoluciones.php`, `routes/devoluciones-gracias.php`, `admin/routes/devoluciones.php`

1. **Condición:** `configuracion.formulario_devoluciones == '1'`.
2. Formulario público en `/devoluciones`:
   - Nombre, apellido, email, teléfono (área + número, validación 10 dígitos)
   - Número de pedido (opcional)
   - Mensaje con motivo de devolución
   - reCAPTCHA (si está configurado con `recaptcha_site_key`)
3. Al enviar, guarda en tabla `devoluciones`.
4. Redirige a `/devoluciones/gracias`.
5. **Admin:** `admin/routes/devoluciones.php` lista las solicitudes. [NO DETECTADO: acciones CRUD]

---

## 3.6 Flujo de Encuestas Post-Compra

**Archivos:** `routes/encuesta.php`, `cron/encuestas.php`, `admin/routes/encuestas.php`

1. **Admin configura encuestas:**
   - Crear encuesta con nombre
   - Agregar preguntas: tipo texto, valoración (estrellas 1-5), checkbox, radio
   - Asociar cupón de regalo (`cupon_id`) opcional
2. **Envío:** [NO DETECTADO: mecanismo exacto — posiblemente `cron/encuestas.php` envía emails con hash único a clientes post-compra o a prospectos]
3. **Recepción:** link único `/encuesta?hash={hash}` o `?route=encuesta&hash={hash}`.
4. **Validación:**
   - Hash existe en `encuestas_envios`
   - No hay respuesta previa (`encuestas_respuestas WHERE envio_id=... LIMIT 1`)
   - Encuesta activa y no eliminada
5. **Formulario:** renderiza preguntas dinámicamente según tipo.
6. **Al enviar:**
   - Guarda cada respuesta en `encuestas_respuestas`
   - Si la encuesta tiene `cupon_id`, busca el cupón, obtiene email del destinatario (de `clientes` si es prospecto, de `pedidos` si es post-compra), envía email con código de cupón vía `enviar_mail_plantilla('encuesta_cupon_regalo', ...)`.
7. Muestra pantalla de agradecimiento.

---

## 3.7 Flujo de Perfil y Cuenta del Cliente

**Archivos:** `routes/account_profile.php`, `routes/account_company.php`, `routes/account_addresses.php`, `routes/account_orders.php`, `routes/account_order.php`, `routes/account_wish_list.php`, `routes/account_session.php`, `routes/account_code_register.php`

1. **Perfil:** edición de datos personales.
2. **Empresa:** edición de razón social, nombre fantasía, CUIT.
3. **Direcciones:** CRUD de direcciones guardadas (`clientes_direcciones`).
4. **Pedidos:** historial con estados. Al clickear uno, detalle completo (`account_order.php` con `hash`).
5. **Favoritos:** lista de productos marcados, con toggle desde cualquier página (vía `ajax/favoritos.php`).
6. **Código de registro:** [NO DETECTADO: posiblemente registro con código de invitación]
7. **Cerrar sesión:** `routes/logout.php` (destruye sesión de tienda).

---

## 3.8 Flujo de Contacto

**Archivos:** `routes/contacto.php`, `routes/contacto-gracias.php`, `admin/routes/contacto.php`

1. Formulario en `/contacto`:
   - Nombre, email, teléfono
   - Área de contacto (de `contacto_areas`)
   - Mensaje
   - reCAPTCHA opcional
2. Al enviar, guarda en tabla `contacto` y redirige a `/contacto/gracias`.
3. **Admin:** lista mensajes por área, marca como leído, puede responder [NO DETECTADO: respuesta desde admin].

---

## 3.9 Flujo de Chatbot (AI)

**Archivos:** `ajax/chat_handler.php`

1. El frontend (JS widget) envía `action: 'load'` → devuelve historial de sesión.
2. El frontend envía `action: 'message'` con `message: {texto}`.
3. **Sistema de conocimiento:**
   - La primera vez, carga todos los productos (con precios de la lista del cliente, stock), marcas, categorías, envíos, promociones y contacto en una variable `chat_knowledge` guardada en sesión.
   - Se inyecta como system prompt a OpenAI (gpt-4o-mini).
4. **Procesamiento de respuesta:**
   - Si la respuesta contiene `COMMAND_ADD_TO_CART:{id, variant_id, qty}`, parsea el JSON, valida producto, stock y variante, lo agrega al carrito (`$_SESSION['carrito']`).
   - Sino, muestra la respuesta como texto (conversión de Markdown a HTML para links).
5. Historial completo se mantiene en `$_SESSION['chat_history']`.

---

## Observaciones de Negocio

1. **Compra como invitado:** El sistema permite comprar sin registro. Si el email no existe, crea automáticamente un cliente y envía credenciales.
2. **Emails transaccionales diferidos:** Para MercadoPago y Modo, los emails NO se envían al finalizar checkout sino que quedan en `pedidos_emails` y se despachan cuando el IPN/webhook confirma el pago.
3. **Datos denormalizados en pedidos:** La tabla `pedidos` almacena copia de datos del cliente (nombre, dirección, etc.) y `pedidos_detalle` almacena copia del producto, precio y foto. Esto permite preservar la información histórica aunque el cliente/producto cambie después.
4. **Doble validación de precio:** El precio se valida en el servidor al agregar al carrito (`agregarcarrito.php`) y al renderizar el carrito (`cart.php` recalcula promociones).
5. **Stock no se descuenta al agregar al carrito:** Solo se descuenta al confirmar el pago (IPN/webhook) o en el caso de Transferencia/Efectivo en checkout_4. El código de decremento en checkout_4 está comentado — el descuento real ocurre en `actualizarStock()` llamado desde los webhooks.
