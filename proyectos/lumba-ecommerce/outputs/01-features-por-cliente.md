# 01 — Matriz Multi-Tenant (Features por Cliente)

> **Proyecto:** Lumba Ecommerce (Brownfield — migración PHP vanilla → NestJS + Tailwind)
> **Fecha:** 2026-06-04
> **Agente:** System Auditor (subagent)
> **Modelo:** deepseek-v4-pro
> **Nivel de confianza global:** BAJA-MEDIA (información limitada sobre branches específicos; inferido del código)
> **Fuente:** `inc/db.php`, estructura de branches Git, `inc/account_signin.php`, `admin/login.php`

---

## 5.1 Modelo Multi-Tenant

### Estrategia actual
**Base de datos por cliente.** Cada cliente (branch) tiene su propia base de datos MySQL independiente. La selección de DB se hace mediante credenciales diferentes en `inc/db.php`.

### Cómo funciona (inferido)

1. **Repositorio Git con branches:**
   - Rama `refactoring` (actual) — contiene el código base
   - Rama `main` (existía, fue descartada para el análisis)
   - Cada cliente tiene su propio branch: `cliente-nombre` [NO DETECTADO: nombres exactos de branches]
   - Cada branch tiene su propio archivo `inc/db.php` con credenciales de DB específicas

2. **`inc/db.php` por branch:**
   ```php
   // Estructura inferida (valores exactos no visibles por límite del archivo)
   $conexion = mysqli_connect($host, $usuario, $password, $dbname);
   // Cada branch tiene diferentes valores de conexión
   ```

3. **Aislamiento:** Cada cliente tiene datos completamente aislados (productos, pedidos, clientes, configuración — todo en su propia DB).

---

## 5.2 Features Condicionadas por Cliente

Las siguientes funcionalidades se activan/desactivan mediante configuración en la tabla `configuracion` (por DB de cada cliente) y en la tabla `clientes_tipos` (perfiles):

### 5.2.1 Métodos de Pago Habilitados

Cada perfil de cliente (`clientes_tipos`) define qué métodos de pago están disponibles:

| Feature | Variable en `clientes_tipos` | También en `configuracion` |
|---|---|---|
| MercadoPago | `mercadopago` (0/1) | `mercadopago_access_token`, `cuotas_mercadopago` |
| Modo | `modo` (0/1) | `modo_username`, `modo_password`, `modo_processor_code`, `modo_cc_code` |
| Transferencia | `transferencia` (0/1) | `datos_bancarios` (texto con CBU/alias) |
| Efectivo | `efectivo` (0/1) | — |

Además, en `checkout_3.php` se verifica `in_array('mercadopago', $_SESSION['servicios_connect'])` — lo que sugiere que hay un array global de servicios conectados que actúa como master switch.

### 5.2.2 Métodos de Envío

| Feature | Variable | Notas |
|---|---|---|
| Zipnova envío a domicilio | `clientes_tipos.zipnova` (0/1) | Requiere servicio Zipnova conectado |
| Zipnova punto de retiro | `clientes_tipos.zipnova_puntoentrega` (0/1) | |
| Envíos propios | `clientes_tipos.envios_propios` (0/1) | Configurados en `envios_propios` |
| Retiro por sucursal | `clientes_tipos.retiro_sucursal` (0/1) + `configuracion.retiro_por_sucursal` | |
| Envío habilitado (global) | `configuracion.envio_habilitado` (0/1) | | 
| Envío gratis global | `envio_gratis.activo` + `envio_gratis.monto_desde` | |

### 5.2.3 Catálogo y Visibilidad

| Feature | Mecanismo | Notas |
|---|---|---|
| **Restricción de marcas** | `clientes.marcas` (JSON array) o `clientes_tipos.marcas` (JSON array) | Limita qué productos ve el cliente en todo el catálogo. Se aplica en `inc/get_products.php` como `WHERE productos.marca_id IN (...)` |
| **Lista de precios** | `clientes.lista_id` y `clientes_tipos.lista_precios_id` | Cada cliente ve precios de una lista específica |
| **Compra mínima** | `clientes_tipos.minimo_compra` o `compra_minima.compra_minima` (global) | Si el tipo tiene `minimo_compra > 0`, lo usa; sino usa el global |
| **Tipo de comprobante** | `clientes.tipo_comprobante_id` + `clientes_tipos.tipos_comprobante` (JSON) | Filtra qué tipos de comprobante puede elegir el cliente |
| **Marcas toggle** | `configuracion.marcas` (0/1) | Activa/desactiva el módulo de marcas en el menú de navegación |

### 5.2.4 Registro y Perfiles

| Feature | Variable | Notas |
|---|---|---|
| Tipos de cliente habilitados | `configuracion.tipos_cliente` (0/1) | Si 1, muestra el selector de tipo en checkout paso 1 |
| Registro habilitado por tipo | `clientes_tipos.registro_habilitado` (0/1) | Controla si un tipo puede registrarse |
| Campos requeridos por tipo | `clientes_tipos.datos_nombre`, `datos_apellido`, `datos_dni`, `datos_cuit`, etc. | Define qué campos se piden y validan en checkout |

### 5.2.5 Funcionalidades Web

| Feature | Variable | Notas |
|---|---|---|
| Formulario de devoluciones | `configuracion.formulario_devoluciones` (0/1) | |
| Devoluciones en admin | `configuracion.formulario_devoluciones` (0/1) | El menú "Devoluciones" en admin se oculta si es 0 |
| Formulario de contacto | Siempre habilitado | Pero las áreas son configurables por cliente |
| Encuestas | Disponible en admin | Configurables por cliente |
| Carritos abandonados | `configuracion.cron_carritos_abandonados` (horas) | Si 0, el cron no hace nada |
| Chatbot AI | Hardcodeado (siempre activo si el JS está presente) | [NO DETECTADO: toggle por configuración] |

### 5.2.6 Configuración Visual y de Marca

| Feature | Fuente |
|---|---|
| Logo del menú | `configuracion.logo_menu` (extensión) |
| Logo del header | `configuracion.logo_header` |
| Logo del footer | `configuracion.logo_footer` |
| Favicon | `configuracion.favicon` |
| Fondo de login | `fondo_login` (tabla separada) |
| Imagen para compartir | `configuracion` → `admin/routes/img_share.php` |
| Estilos CSS | `configuracion_grafica` (colores, tipografías, etc.) |
| Nombre de fantasía | `configuracion.nombre_fantasia` (usado en emails) |

---

## 5.3 Estructura de Branches (Inferida)

### Clientes detectados (por análisis de `connect/padpio.php`)

El archivo `padpio.php` contiene lógica de diferenciación por marca (`marca_id=1` vs `marca_id!=1`) que sugiere que hay al menos 2 configuraciones de negocio diferentes:

| Cliente Inferido | Marcas | Fuente de Datos | Notas |
|---|---|---|---|
| **Cliente A** (Resistencia) | `marca_id = 1` | `PadPioResist` (puerto 9143) | Base SQL Server específica |
| **Cliente B** (MaxPaz u otros) | `marca_id != 1` | `PadPioMaxPaz` (puerto 9144) | Segunda base SQL Server |

### Otros clientes posibles

[NO DETECTADO] Los branches de Git en el repositorio `LumbaDev/lumba-ecommerce` podrían contener más clientes. Para determinar la lista exacta se debe:
1. Clonar el repo y listar todas las ramas: `git branch -r`
2. Para cada branch, examinar `inc/db.php` para ver el nombre de la BD
3. Mapear cada branch a un cliente

---

## 5.4 Tabla de Configuraciones por Cliente

### Configuraciones que VARÍAN entre clientes (muy probable)

| Configuración | Varía | Evidencia |
|---|---|---|
| Credenciales DB | ✅ Sí | Diferente `inc/db.php` por branch |
| Credenciales MercadoPago | ✅ Sí | Por tabla `configuracion` (cada cliente su propio access token) |
| Credenciales Modo | ✅ Sí | Por tabla `configuracion` |
| Credenciales PadPio | ✅ Sí | Host, user, password en `configuracion` |
| Credenciales Zipnova | ✅ Sí | [NO DETECTADO: hipótesis] |
| Datos bancarios (transferencia) | ✅ Sí | `configuracion.datos_bancarios` |
| Email de compras | ✅ Sí | `configuracion.email_compras` |
| Logo, colores, identidad visual | ✅ Sí | `configuracion.logo_*`, `configuracion_grafica` |
| Perfiles de cliente (tipos) | ✅ Sí | `clientes_tipos` varía por DB |
| Envíos propios (zonas, precios) | ✅ Sí | `envios_propios` varía por DB |
| Sucursales | ✅ Sí | `sucursales` varía por DB |
| Textos legales, FAQ, contenido | ✅ Sí | `preguntas_frecuentes`, `secciones_adicionales` |
| Productos, categorías, marcas | ✅ Sí | Varían completamente por DB |
| Pedidos y clientes | ✅ Sí | Aislados por DB |

### Configuraciones que PODRÍAN compartirse

| Configuración | Compartida | Evidencia |
|---|---|---|
| Código base PHP | ✅ Sí | Mismo repo en todos los branches |
| Assets (CSS, JS, imágenes del template) | ✅ Sí | La carpeta `assets/` es común |
| Lógica de negocio | ✅ Sí | Mismos archivos `routes/`, `inc/`, etc. |
| OpenAI API Key (chatbot) | ❌ Hardcodeada | [⚠️] Está hardcodeada en el código — todos los clientes usan la misma key |
| Estructura de tablas | ✅ Sí | Mismo código PHP asume mismas tablas |
| Google reCAPTCHA | [NO DETECTADO] | Puede variar por `configuracion.recaptcha_*` |

---

## 5.5 Implicaciones para la Migración a NestJS

### Estrategia Multi-Tenant Recomendada (para discusión en fase TECH_STACK)

| Opción | Descripción | Pros | Contras |
|---|---|---|---|
| **Base de datos por tenant** (actual) | Misma app, diferente DB por cliente | Aislamiento total, compatible con esquema actual | Más operaciones (migraciones por DB), más conexiones |
| **Schema por tenant** | PostgreSQL schemas por cliente | Menos conexiones, mismo servidor | Cambio de MySQL → PostgreSQL, requiere migración |
| **Single DB + tenant_id** | Una sola DB con `tenant_id` en todas las tablas | Simplifica deploys, migraciones | Requiere refactor completo, riesgo de leaks entre tenants |
| **Híbrido** | DB separadas en NestJS vía `TypeORM` multi-connection | Flexibilidad, misma app | Complejidad de configuración |

### Lo que SÍ se debe mantener
- Aislamiento de datos entre clientes (no pueden verse pedidos/productos de otro cliente)
- Capacidad de cada cliente de tener sus propias configuraciones de pago, envío y visuales
- El modelo de perfiles de cliente (`clientes_tipos`) que condiciona precios, métodos de pago, envíos y visibilidad de marcas

### Lo que se DEBE mejorar
- Las API keys y credenciales NUNCA deben estar hardcodeadas en el código — siempre en variables de entorno o vault
- El sistema de branches de Git para gestionar tenants es frágil — se debe implementar un mecanismo de tenant switching basado en dominio o configuración de deploy
- La configuración actual en tabla `configuracion` es un key-value genérico. Evaluar si migrar a un módulo de configuración tipado en NestJS.

---

## 5.6 Riesgos Detectados en el Modelo Actual

| Riesgo | Severidad | Descripción |
|---|---|---|
| API Key OpenAI compartida | 🔴 Alto | Hardcodeada en `ajax/chat_handler.php`. Si un cliente abusa, afecta a todos. |
| Branches como tenants | 🟡 Medio | Sincronizar features entre branches es manual y propenso a divergencia |
| Sin herramienta de migraciones | 🟡 Medio | Cada DB puede divergir en schema si las actualizaciones no se aplican uniformemente |
| Credenciales en tabla `configuracion` | 🟡 Medio | Sin encriptación — cualquiera con acceso admin ve las credenciales de pago |
| Conexiones MSSQL Windows-only | 🟡 Medio | `sqlsrv` solo funciona en Windows — limita opciones de hosting |
