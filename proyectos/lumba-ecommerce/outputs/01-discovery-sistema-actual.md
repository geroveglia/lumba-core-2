# 01 — Catálogo Completo del Sistema Actual

> **Proyecto:** Lumba Ecommerce (Brownfield — migración PHP vanilla → NestJS + Tailwind)
> **Fecha:** 2026-06-04
> **Agente:** System Auditor (subagent)
> **Modelo:** deepseek-v4-pro
> **Nivel de confianza global:** ALTA
> **Fuente:** Código fuente en `proyectos/lumba-ecommerce/source` (rama `refactoring`, ~350 archivos PHP)

---

## 1.1 Catálogo de Endpoints y Rutas

### 1.1.1 Routing Frontend (URL Rewriting — `.htaccess`)

El routing se implementa vía Apache `mod_rewrite`. Todas las URLs se reescriben a `index.php?route=NOMBRE_RUTA` con parámetros adicionales. Reglas agrupadas:

| URL Pública | Route Interno | Parámetros | Propósito |
|---|---|---|---|
| `/productos` | `productos` | — | Catálogo/grilla de productos |
| `/producto/{url}` | `producto` | `url` | Página de detalle de producto |
| `/categoria/{url}` | `productos` | `categoria_url`, `parametrounico=1` | Productos filtrados por categoría |
| `/marca/{url}` | `productos` | `marca_url`, `parametrounico=1` | Productos filtrados por marca |
| `/tag/{url}` | `productos` | `tag_url`, `parametrounico=1` | Productos filtrados por etiqueta |
| `/cart` | `cart` | — | Carrito de compras |
| `/checkout/1` | `checkout_1` | — | Checkout paso 1: Datos personales |
| `/checkout/2` | `checkout_2` | — | Checkout paso 2: Forma de entrega |
| `/checkout/2_envio` | `checkout_2_envio` | — | Checkout paso 2 alternativo: Envíos |
| `/checkout/3` | `checkout_3` | — | Checkout paso 3: Medio de pago |
| `/checkout/4` | `checkout_4` | — | Checkout paso 4: Confirmación y pago |
| `/contacto` | `contacto` | — | Formulario de contacto |
| `/contacto/gracias` | `contacto-gracias` | — | Gracias post-contacto |
| `/devoluciones` | `devoluciones` | — | Formulario de devolución |
| `/devoluciones/gracias` | `devoluciones-gracias` | — | Gracias post-devolución |
| `/comprobantes/{hash}` | `comprobantes` | `hash` | Subir comprobante de transferencia |
| `/login` | `login` | — | Login de cliente (alias a account_signin) [NO DETECTADO: puede redirigir] |
| `/account_signin` | `account_signin` | — | Iniciar sesión cliente |
| `/account_register` | `account_register` | — | Registro de cliente |
| `/account_recover` | `account_recover` | — | Recuperación de contraseña |
| `/account_activate/{hash}` | `home` | `action=account_activate`, `hash` | Activación de cuenta |
| `/account_password_recover/{hash}` | `account_password_recover` | `hash` | Seteo de nueva contraseña |
| `/account_session` | `account_session` | — | [NO DETECTADO: hipótesis — info de sesión] |
| `/account_profile` | `account_profile` | — | Perfil del cliente |
| `/account_company` | `account_company` | — | Datos de empresa del cliente |
| `/account_addresses` | `account_addresses` | — | Direcciones guardadas |
| `/account_orders` | `account_orders` | — | Historial de pedidos |
| `/account_order/{hash}` | `account_order` | `hash` | Detalle de un pedido |
| `/account_wish_list` | `account_wish_list` | — | Lista de favoritos |
| `/preguntas-frecuentes` | `preguntas-frecuentes` | — | FAQ |
| `/alerts` | `alerts` | — | [NO DETECTADO: sistema de alertas] |
| `/swal` | `swal` | — | [NO DETECTADO: SweetAlert helpers] |
| `/privacy_policy` | `privacy_policy` | — | [NO DETECTADO: políticas de privacidad] |
| `/terms_and_conditions` | `terms_and_conditions` | — | [NO DETECTADO: términos y condiciones] |
| `/level_table/{url}` | `level_table` | `url` | [NO DETECTADO] |
| `/level_transactional/{url}` | `level_transactional` | `url` | [NO DETECTADO] |
| `/secciones/{url}` | `secciones` | `url` | Secciones de contenido adicionales |
| `/mercadopago/{estado}/{hash}` | `mercadopago` | `estado`, `hash` | Callback post-pago MercadoPago |
| `/mercadopago/cancelado/` | `cart` | `mensaje=cancelado` | Pago cancelado en MercadoPago |

**Nota:** La .htaccess también fuerza HTTPS y www en producción.

### 1.1.2 AJAX Endpoints (Frontend)

Archivos en `ajax/`:

| Archivo | Método | Parámetros | Respuesta | Propósito |
|---|---|---|---|---|
| `agregarcarrito.php` | POST | `producto_id`, `variante_id`, `variante`(sku), `producto`, `cantidad`, `iva`, `foto`, `url` | N/A (modifica sesión) | Validar stock y precio en servidor, agregar al carrito |
| `chat_handler.php` | POST (JSON) | `action` (load/message), `message` | JSON `{status, reply}` o `{status, history}` | Chatbot AI (OpenAI gpt-4o-mini) con conocimiento de productos, precios, marcas, categorías, envíos, promociones; soporta `COMMAND_ADD_TO_CART` |
| `favoritos.php` | GET | `accion` (agregar), `favorito_id` | N/A (modifica sesión y DB) | Toggle de producto favorito |
| `buscarpropiedades.php` | GET | [NO DETECTADO: query params] | [NO DETECTADO] | Búsqueda de propiedades de producto |
| `buscarsku.php` | GET | [NO DETECTADO: sku] | [NO DETECTADO] | Búsqueda de producto por SKU |
| `buscarstock_y_precios.php` | GET | [NO DETECTADO] | [NO DETECTADO] | Consulta de stock y precios |
| `calcular_cantidad_carrito.php` | GET | [NO DETECTADO] | [NO DETECTADO] | Calcular cantidad items en carrito |
| `cotizar_envio_con_cp.php` | GET | [NO DETECTADO] | [NO DETECTADO] | Cotizar envío con código postal |
| `cp.php` | GET | [NO DETECTADO] | [NO DETECTADO] | Consulta de códigos postales |
| `localidades.php` | GET | [NO DETECTADO] | [NO DETECTADO] | Lista de localidades |
| `localidades_con_cp.php` | GET | [NO DETECTADO] | [NO DETECTADO] | Localidades con código postal |
| `provincias_con_localidad.php` | GET | [NO DETECTADO] | [NO DETECTADO] | Provincias con sus localidades |

### 1.1.3 AJAX Endpoints (Admin)

Archivos en `admin/ajax/`:

| Archivo | Método | Parámetros | Respuesta | Propósito |
|---|---|---|---|---|
| `actualizar_estados.php` | POST | `pedido_id`, `estado`, `estado_pago`, `estado_entrega`, `estado_factura` | N/A | Actualizar estados de un pedido |
| `categorias.php` | GET | [NO DETECTADO] | [NO DETECTADO] | CRUD de categorías |
| `crear_categoria.php` | POST | [NO DETECTADO] | [NO DETECTADO] | Crear nueva categoría |
| `dimensiones.php` | POST | [NO DETECTADO] | [NO DETECTADO] | [NO DETECTADO: dimensiones de producto?] |
| `direcciones.php` | GET | [NO DETECTADO] | [NO DETECTADO] | Listar direcciones |
| `direccion_edit.php` | POST | [NO DETECTADO] | [NO DETECTADO] | Editar dirección |
| `direccion_new.php` | POST | [NO DETECTADO] | [NO DETECTADO] | Nueva dirección |
| `eliminar.php` | POST | `tabla`, `id` | N/A | Eliminar registro (soft delete: `SET eliminado=1`) |
| `eliminar_categoria.php` | POST | [NO DETECTADO] | N/A | Eliminar categoría |
| `encuestas_preguntas.php` | GET | [NO DETECTADO] | [NO DETECTADO] | Preguntas de encuestas |
| `global_search.php` | GET | `q` | JSON | Búsqueda global en admin |
| `localidades.php` | GET | [NO DETECTADO] | [NO DETECTADO] | Localidades |
| `pedidos_edit_guardar.php` | POST | [NO DETECTADO] | N/A | Guardar edición de pedido |
| `pedidos_new_buscar_clientes.php` | GET | `q` | JSON | Buscar clientes para nuevo pedido |
| `pedidos_new_buscar_productos.php` | GET | `q` | JSON | Buscar productos para nuevo pedido |
| `pedidos_new_datos_cliente.php` | GET | `cliente_id` | JSON | Obtener datos de cliente para nuevo pedido |
| `pedidos_new_guardar.php` | POST | [NO DETECTADO] | N/A | Guardar nuevo pedido desde admin |
| `precios.php` | POST | [NO DETECTADO] | [NO DETECTADO] | Gestión de precios |
| `productos_excel_exportar.php` | GET | [NO DETECTADO] | Excel (XLSX) | Exportar productos a Excel |
| `stock.php` | POST | [NO DETECTADO] | [NO DETECTADO] | Gestión de stock |
| `test_search.php` | GET | [NO DETECTADO] | JSON | [NO DETECTADO: test de búsqueda] |
| `ver_pedidos_devolucion.php` | GET | [NO DETECTADO] | [NO DETECTADO] | Ver pedidos de devolución |

---

## 1.2 Estructura del Admin Panel

### 1.2.1 Arquitectura General

El admin panel reside en `admin/` con su propio `index.php`. La sesión es independiente de la tienda (`session_name("ecommerce-admin")`).

- **Login:** `admin/login.php` — autenticación contra tabla `administradores`
- **Routing:** parámetro `route` vía GET (`?route=NOMBRE`), que carga `admin/routes/{route}.php`
- **Control de acceso:** basado en `administradores_tipos_permisos` asignados al tipo de usuario
- **Seguridad:** sanitización de ruta con `preg_replace('/[^a-zA-Z0-9_-]/', '', $route)`
- **UI:** basada en template Velzon (Bootstrap 5, jQuery, DataTables, SweetAlert2, CKEditor, Leaflet, ApexCharts, FullCalendar)

### 1.2.2 Mapa de Secciones por Categoría (119 archivos en `admin/routes/`)

#### 🛒 **PRODUCTOS** — 12 archivos

| Ruta | Archivo | Operaciones CRUD |
|---|---|---|
| `productos` | `productos.php` | Listar (DataTable con filtros, paginación) |
| `productos_new` | `productos_new.php` | Crear nuevo producto |
| `productos_edit` | `productos_edit.php` | Editar producto |
| `productos_variantes` | `productos_variantes.php` | CRUD de variantes del producto |
| `productos_variantes_fotos` | `productos_variantes_fotos.php` | Gestión de fotos de variantes |
| `productos_variantes_fotos_` | `productos_variantes_fotos_.php` | [NO DETECTADO: posible backup/tmp] |
| `productos_relacionados` | `productos_relacionados.php` | Gestionar productos relacionados |
| `productos_stock` | `productos_stock.php` | Vista de stock por producto |
| `productos_excel` | `productos_excel.php` | Importación masiva vía Excel |
| `productos_actualizar_padpio` | `productos_actualizar_padpio.php` | Actualización desde PadPio (stock y precios) |
| `inventario_excel` | `inventario_excel.php` | Inventario exportable a Excel |
| `inventario_rotsis` | `inventario_rotsis.php` | Inventario formato RoTSis |

#### 📂 **CATEGORÍAS** — 3 archivos

| Ruta | Archivo | Operaciones |
|---|---|---|
| `categorias` | `categorias.php` | Listar, reordenar (nestable) |
| `categorias_edit` | `categorias_edit.php` | Editar |
| `categorias_foto` | `categorias_foto.php` | Foto de categoría |

#### 🏷️ **MARCAS** — 3 archivos

| Ruta | Archivo | Operaciones |
|---|---|---|
| `marcas` | `marcas.php` | Listar |
| `marcas_new` | `marcas_new.php` | Crear |
| `marcas_edit` | `marcas_edit.php` | Editar |

#### 🔑 **KEYWORDS** — 3 archivos

| Ruta | Archivo | Operaciones |
|---|---|---|
| `keywords` | `keywords.php` | Listar |
| `keywords_new` | `keywords_new.php` | Crear |
| `keywords_edit` | `keywords_edit.php` | Editar |

#### 🏷️ **ETIQUETAS (TAGS)** — 4 archivos

| Ruta | Archivo | Operaciones |
|---|---|---|
| `tags` | `tags.php` | Listar |
| `tags_new` | `tags_new.php` | Crear |
| `tags_edit` | `tags_edit.php` | Editar |
| `tags_order` | `tags_order.php` | Reordenar |

#### 📐 **PROPIEDADES** — 7 archivos

| Ruta | Archivo | Operaciones |
|---|---|---|
| `propiedades` | `propiedades.php` | Listar |
| `propiedades_new` | `propiedades_new.php` | Crear |
| `propiedades_edit` | `propiedades_edit.php` | Editar |
| `propiedades_order` | `propiedades_order.php` | Reordenar |
| `propiedades_valores` | `propiedades_valores.php` | Listar valores |
| `propiedades_valores_new` | `propiedades_valores_new.php` | Crear valor |
| `propiedades_valores_edit` | `propiedades_valores_edit.php` | Editar valor |

#### 📦 **STOCK** — 1 archivo

| Ruta | Archivo | Operaciones |
|---|---|---|
| `stock` | `stock.php` | Vista de stock global con filtros por sucursal |

#### 📋 **PEDIDOS** — 5 archivos

| Ruta | Archivo | Operaciones |
|---|---|---|
| `pedidos` | `pedidos.php` | Listar (DataTable avanzado con filtros por fecha, estado, pago, entrega) |
| `pedidos_new` | `pedidos_new.php` | Crear pedido manual desde admin |
| `pedidos_edit` | `pedidos_edit.php` | Editar pedido (cambiar estados, tracking, items) |
| `pedidos_view` | `pedidos_view.php` | Ver detalle de pedido (vista solo lectura/impresión) |
| `pedidos_rotsis` | `pedidos_rotsis.php` | Vista/exportación formato RoTSis |

#### 🛒 **CARRITOS ABANDONADOS** — 1 archivo

| Ruta | Archivo | Operaciones |
|---|---|---|
| `carritos_abandonados` | `carritos_abandonados.php` | Listar pedidos en estado "Incompleto" |

#### 🔄 **DEVOLUCIONES** — 1 archivo

| Ruta | Archivo | Operaciones |
|---|---|---|
| `devoluciones` | `devoluciones.php` | Listar y gestionar solicitudes de devolución |

#### 👥 **CLIENTES** — 8 archivos

| Ruta | Archivo | Operaciones |
|---|---|---|
| `clientes` | `clientes.php` | Listar (filtro tipo: clientes/prospectos) |
| `clientes_new` | `clientes_new.php` | Crear |
| `clientes_edit` | `clientes_edit.php` | Editar |
| `clientes_tipos` | `clientes_tipos.php` | Perfiles de clientes (lista) |
| `clientes_tipos_new` | `clientes_tipos_new.php` | Crear perfil |
| `clientes_tipos_edit` | `clientes_tipos_edit.php` | Editar perfil |
| `clientes_tipos2` | `clientes_tipos2.php` | Tipos de clientes (lista) |
| `clientes_tipos2_new` / `clientes_tipos2_edit` | (2 archivos) | CRUD de tipos de cliente |

#### 📊 **ENCUESTAS** — 3 archivos

| Ruta | Archivo | Operaciones |
|---|---|---|
| `encuestas` | `encuestas.php` | Listar |
| `encuestas_new` | `encuestas_new.php` | Crear |
| `encuestas_edit` | `encuestas_edit.php` | Editar |

#### 🚚 **LOGÍSTICA** — 6 archivos

| Ruta | Archivo | Operaciones |
|---|---|---|
| `envios_propios` | `envios_propios.php` | Listar métodos de envío propio |
| `envios_propios_new` | `envios_propios_new.php` | Crear |
| `envios_propios_edit` | `envios_propios_edit.php` | Editar |
| `envio_gratis` | `envio_gratis.php` | Configurar envío gratis (monto mínimo) |
| `compra_minima` | `compra_minima.php` | Configurar compra mínima global |
| `sucursales` | `sucursales.php` + `_new` + `_edit` | CRUD de sucursales |

#### 🎨 **CONTENIDO WEB** — 11 archivos

| Ruta | Archivo | Operaciones |
|---|---|---|
| `slider` | `slider.php` + `_new` + `_edit` + `_order` | CRUD + reordenar slides del homepage |
| `banners` | `banners.php` | Listar banners |
| `banners_promociones_bancarias` | `banners_promociones_bancarias.php` + `_new` + `_edit` | CRUD banners de promos bancarias |
| `header_secundario` | `header_secundario.php` | Configurar header secundario |
| `preguntas_frecuentes` | `preguntas_frecuentes.php` + `_new` + `_edit` + `_order` | CRUD FAQ |
| `secciones_adicionales` | `secciones_adicionales.php` + `_new` + `_edit` + `_contenido_order` | CRUD secciones de contenido |
| `redes` | `redes.php` + `_new` + `_edit` | CRUD redes sociales y contacto |
| `resenias` | `resenias.php` + `_new` + `_edit` | CRUD reseñas/testimonios |
| `carouseles` | `carouseles.php` | Configurar carouseles del home |

#### 🎨 **PROMOCIONES Y CUPONES** — 5 archivos

| Ruta | Archivo | Operaciones |
|---|---|---|
| `promociones` | `promociones.php` | Listar |
| `promociones_new` | `promociones_new.php` | Crear |
| `promociones_edit` | `promociones_edit.php` | Editar |
| `cupones` | `cupones.php` | Listar |
| `cupones_new` / `cupones_edit` | (2 archivos) | CRUD cupones |

#### ⚙️ **CONFIGURACIÓN** — 13 archivos

| Ruta | Archivo | Operaciones |
|---|---|---|
| `configuracion` | `configuracion.php` | Panel de configuración unificado pestañeado por tipo: `connect`, `contenido`, `envios`, `pagos`, `productos`, `reglas_de_negocio`, `web`, `estilos` |
| `configuracion_grafica` | `configuracion_grafica.php` | Estilos visuales (colores, tipografías) |
| `configuracion_cron_pedidos` | `configuracion_cron_pedidos.php` | Configurar comportamiento de pedidos |
| `logos` | `logos.php` | Subir/editar logos |
| `fondo_login` | `fondo_login.php` | Imagen de fondo del login |
| `img_share` | `img_share.php` | Imagen para compartir en redes |
| `home_order` | `home_order.php` | Orden de módulos en la home |
| `listas` | `listas.php` + `_new` + `_edit` | CRUD listas de precios |
| `tipos_comprobante` | `tipos_comprobante.php` | Configurar tipo de comprobante predeterminado |
| `reset` | `reset.php` | Resetear ecommerce (limpiar datos) |
| `emails_plantillas` | `emails_plantillas.php` + `_edit` | Editar plantillas de email |
| `importar_productos` | `importar_productos.php` | Panel de importación masiva |

#### 👤 **USUARIOS** — 6 archivos

| Ruta | Archivo | Operaciones |
|---|---|---|
| `usuarios` | `usuarios.php` | Listar administradores |
| `usuarios_new` / `usuarios_edit` | (2 archivos) | CRUD administradores |
| `usuarios_tipos` | `usuarios_tipos.php` | Tipos de usuario admin |
| `usuarios_tipos_new` / `usuarios_tipos_edit` | (2 archivos) | CRUD tipos |
| `usuarios_tipos_permisos` | `usuarios_tipos_permisos.php` | Asignar permisos a tipos |

#### 📊 **DASHBOARD** — 2 archivos

| Ruta | Archivo | Operaciones |
|---|---|---|
| `dashboard` | `dashboard.php` | KPIs: ventas del mes, comparativa mes anterior, métricas |
| `dashboard_connect` | `dashboard_connect.php` | [NO DETECTADO: dashboard de integraciones] |

#### 🔌 **CONEXIONES** — 2 archivos (en `connect/` y admin)

| Ruta | Archivo | Operaciones |
|---|---|---|
| `logout` | `logout.php` | Cerrar sesión admin |
| `contacto` | `contacto.php` + `_areas` + `_areas_new` + `_areas_edit` | Gestionar consultas de contacto y áreas |

---

## 1.3 Archivos Core

### 1.3.1 `inc/` — Núcleo del sistema

| Archivo | Líneas aprox. | Función |
|---|---|---|
| `db.php` | ~15 | Conexión a MySQL vía `mysqli_connect`. Lee host, user, password, dbname de constantes/variables hardcodeadas. [NO DETECTADO: valores exactos — están en el archivo pero no visibles en la lectura por límite] La DB se selecciona por cliente/branch. |
| `base.php` | ~25 | Define `$base` (URL base del sitio) detectando si es localhost o producción. Útil para rutas absolutas en emails y links. |
| `funciones.php` | ~700+ | Funciones globales: `formatearPrecio()`, `enviarmail()` (PHPMailer), `llamadoCurl()` (proxy para APIs de pago), `buscarPromoPorProducto()`, `actualizarStock()`, `confirmarEnvioZipnova()`, `enviar_mail_plantilla()`, `random_strings()`, y muchas más. |
| `config.php` | ~200 | Carga configuración desde tabla `configuracion` a `$_SESSION['configuracion']`. Incluye: credenciales de pago, datos de envío, textos legales, configuraciones de negocio. |
| `varios.php` | ~40 | Extrae `$_GET` y `$_POST` a variables locales, define whitelist de localhost, arrays de días y meses en español. |
| `cupon.php` | ~100 | Lógica de validación y aplicación de cupones de descuento. Soporta: porcentaje, monto fijo, envío gratis. Maneja acumulabilidad con promociones. |
| `seguridad.php` | ~10 | [NO DETECTADO: probablemente saneamiento de inputs] |
| `seo.php` | ~60 | Metadatos SEO (title, description, keywords, canonical, open graph) basados en ruta y parámetros. |
| `collect_checkout_info.php` | ~180 | Recolecta datos del checkout desde `$_SESSION['checkout']` y `$_POST`. Valida tipo de cliente, datos personales, dirección, facturación. |
| `get_products.php` | ~500+ | Builder de queries para productos. Construye joins y condiciones dinámicamente: filtro por categoría, propiedades, precio, tags, marca, lista de precios, restricción de marcas por cliente. Calcula min/max de precios y paginación. |
| `guardar_pedido_parcial.php` | ~180 | Guarda/actualiza el pedido y sus detalles (`pedidos` + `pedidos_detalle`) en cada paso del checkout. UPSERT: si existe pedido_id en sesión actualiza, sino inserta. Sincroniza `pedidos_detalle` (DELETE + INSERT de todos los items). |
| `account_signin.php` | ~120 | Procesa login de cliente: valida email+md5(contrasenia), carga perfil completo en `$_SESSION['cliente']`, hereda configuración de `clientes_tipos` (métodos de pago, envíos, mínimo compra, marcas permitidas), determina `lista_id`. |
| `account_activate.php` | ~80 | Activa cuenta de cliente vía hash: `UPDATE clientes SET activo='1'`, loguea automáticamente. |

### 1.3.2 `connect/` — Conexiones a APIs externas

| Archivo | Función |
|---|---|
| `mp_ipn.php` | **IPN de MercadoPago.** Recibe webhook JSON: `{pedido_id, order_status}`. Si `paid` → actualiza pedido a "Pagado", envía emails pendientes, descuenta stock, confirma envío Zipnova. Si `reverted` → revierte stock. |
| `modo_webhook.php` | **Webhook de Modo.** Recibe JSON: `{pedido_id (hash), order_status}`. Si `ACCEPTED` → busca pedido por hash, actualiza `estado_pago='Pagado'`, envía emails, descuenta stock, confirma Zipnova. |
| `padpio.php` | **Sincronización PadPio.** Se conecta a 2 bases SQL Server (`PadPioResist` y `PadPioMaxPaz` en puertos 9143 y 9144). Sincroniza stock (tabla `Stock`) y precios (tabla `Precios`, lista `000`). Aplica multiplicadores de propiedades (`valor2` en `propiedades_valores`). Genera promociones automáticas (tipo `00`) con los porcentajes detectados. Actualiza `precio_desde` en productos. Credenciales desde `$_SESSION['configuracion']['padpio_*']`. |
| `zn_webhook.php` | **Webhook de ZN (Zipnova).** Recibe JSON: `{pedido_id, estado}`. Actualiza `estado_envio` en pedidos. [NOTA: hay un bug — `SET estado_envio='estado'` hardcodeado en lugar de usar la variable] |

### 1.3.3 `acciones/` — Acciones especiales

| Archivo | Función |
|---|---|
| `repetir_compra.php` | [NO DETECTADO: repite una compra anterior] |
| `retomar_compra.php` | Recibe `hash` y opcionalmente `cupon` por GET. Restaura el carrito desde un pedido incompleto, aplica cupón si se envió. Usado por el cron de carritos abandonados. |

### 1.3.4 `cron/` — Tareas programadas

| Archivo | Función |
|---|---|
| `carritos_abandonados.php` | Ejecutable por cron. Busca pedidos en estado "Incompleto" cuya antigüedad coincida con las horas configuradas (`cron_carritos_abandonados`). Envía email con resumen de productos + cupón (si está configurado) + link para retomar compra. Marca `cron_notificado=1`. |
| `encuestas.php` | [NO DETECTADO: envío programado de encuestas] |

### 1.3.5 `importar_web/` — Importaciones

| Archivo | Función |
|---|---|
| `importar_dicomere.php` | Importa datos desde Dicomere (ERP) |
| `importar_clientes_dicomere.php` | Importa clientes desde Dicomere |
| `importar_pedidos_dicomere.php` | Importa pedidos desde Dicomere |

---

## 1.4 Estructura de Sesiones

### Sesión Tienda (Frontend)
- **Nombre:** `lumba-ecommerce`
- Variables clave:
  - `$_SESSION['cliente']` — datos del cliente logueado (Id, nombre, email, lista_id, tipo_id, marcas[], etc.)
  - `$_SESSION['carrito']` — `[producto_id][variante_id]` con cantidad, precio, foto, etc.
  - `$_SESSION['carrito_productos']` — array plano de items para iteración
  - `$_SESSION['carrito_resumen']` — totales, descuentos, iva, costo_entrega
  - `$_SESSION['checkout']` — datos progresivos del proceso de compra
  - `$_SESSION['cupon']` — cupón aplicado (codigo, tipo_descuento, valor, acumulable)
  - `$_SESSION['configuracion']` — configuración cargada de DB
  - `$_SESSION['favoritos']` — array de producto_id favoritos
  - `$_SESSION['chat_history']` — historial del chatbot
  - `$_SESSION['chat_knowledge']` — conocimiento inyectado al chatbot

### Sesión Admin
- **Nombre:** `ecommerce-admin`
- Variables clave:
  - `$_SESSION['login']` — 'si'/'no'
  - `$_SESSION['usuario_id']`, `usuario_nombre`, `usuario_email`, `usuario_tipo`, `usuario_tipo_id`
  - `$_SESSION['usuario_home']` — ruta default del usuario
  - `$_SESSION['permisos']` — array asociativo `[seccion => 'si']`
  - `$_SESSION['usuario_clientes_propios']`, `usuario_pedidos_propios` — filtros de visibilidad

---

## Hallazgos Notables

1. **Bug en `zn_webhook.php`:** `SET estado_envio='estado'` usa el string literal 'estado' en lugar de la variable `$estado`. El tracking de Zipnova nunca se actualiza correctamente.
2. **Contraseñas en md5:** Las contraseñas de clientes se hashean con md5 (sin salt). En la migración a NestJS se debe migrar a bcrypt/scrypt.
3. **API Key de OpenAI hardcodeada** en `ajax/chat_handler.php`. Debe moverse a variables de entorno.
4. **Conexiones a SQL Server** en `connect/padpio.php` requieren la extensión `sqlsrv` de PHP (Windows-only). Se deberá evaluar si migrar a un driver Node.js para MSSQL.
5. **Sin migraciones:** El esquema de DB no está documentado. Se infiere de los queries (ver `01-modelo-datos-actual.md`).
6. **Sistema multi-cliente vía branches:** La selección de DB se hace en `inc/db.php` con credenciales diferentes por branch de Git. Cada cliente tiene su propia base de datos.
