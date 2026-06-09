# 01 — Functional Spec (Feature Map Completo)

> **Proyecto:** Lumba Ecommerce (Brownfield — migración PHP vanilla → NestJS + Tailwind)
> **Fecha:** 2026-06-08
> **Rol:** Product Owner
> **Modelo:** deepseek-v4-pro
> **Nivel de confianza global:** ALTA (basado en 5 outputs del System Auditor)
> **Fuentes:** `01-discovery-sistema-actual.md`, `01-modelo-datos-actual.md`, `01-flujos-negocio.md`, `01-integraciones.md`, `01-features-por-cliente.md`

---

## Leyenda de Decisiones

| Código | Significado |
|---|---|
| 🟢 **Migrar igual** | Funcionalidad que se migra tal cual existe hoy. Misma lógica, mismo alcance. |
| 🔵 **Migrar mejorado** | Se migra pero con mejoras de UX, seguridad, performance o arquitectura. |
| 🟡 **Post-MVP** | Se migra después del MVP. No bloquea la operación inicial. |
| 🔴 **No migrar** | No se migra. Se elimina o reemplaza por alternativa. |

---

## MÓDULO 1: CATÁLOGO (Listado de Productos)

### 1.1 Grilla de productos
| Aspecto | Detalle |
|---|---|
| **Qué hace hoy** | Listado paginado con carga infinita (AJAX). Filtros por categoría, marca, tag, rango de precio, propiedades. Ordenamiento (no detectado explícitamente pero inferido por UI). Restricción de marcas por cliente. Cálculo de MIN/MAX de precios para slider de filtro. |
| **Estado actual** | 🟢 Funciona |
| **Decisión** | 🔵 Migrar mejorado |
| **Justificación** | La funcionalidad base es sólida pero la construcción de queries dinámicos en `inc/get_products.php` (~500 líneas) es frágil. En NestJS se puede refactorizar con QueryBuilder/TypeORM, agregar ElasticSearch para búsqueda textual, y mejorar la performance de filtros de propiedades (hoy usa múltiples JOINs). |
| **Confianza** | ALTA |

**Historias de usuario:**
- Como visitante quiero navegar productos por categoría para encontrar lo que busco rápidamente
- Como cliente mayorista quiero ver solo las marcas que me corresponden para no distraerme con productos que no puedo comprar
- Como cliente quiero filtrar productos por rango de precio para ajustarme a mi presupuesto
- Como cliente quiero filtrar por propiedades (talle, color, material) para encontrar exactamente la variante que necesito

### 1.2 Filtro por categoría
| Aspecto | Detalle |
|---|---|
| **Qué hace hoy** | URL `/categoria/{url}`, filtro vía `productos_categorias` (M:N). Categorías anidadas (nestable en admin). |
| **Estado actual** | 🟢 Funciona |
| **Decisión** | 🔵 Migrar mejorado |
| **Justificación** | La relación M:N es correcta. Mejorar: tree de categorías con breadcrumbs automáticos, SEO-friendly, conteo de productos por categoría en tiempo real. |
| **Confianza** | ALTA |

### 1.3 Filtro por marca
| Aspecto | Detalle |
|---|---|
| **Qué hace hoy** | URL `/marca/{url}`, toggle de visibilidad en menú (`configuracion.marcas`). Restricción por cliente (`clientes.marcas` / `clientes_tipos.marcas`). |
| **Estado actual** | 🟢 Funciona |
| **Decisión** | 🟢 Migrar igual |
| **Justificación** | Lógica simple, bien implementada. No requiere cambios. |
| **Confianza** | ALTA |

### 1.4 Filtro por tag
| Aspecto | Detalle |
|---|---|
| **Qué hace hoy** | URL `/tag/{url}`, tags con colores personalizados en menú, visibilidad configurable. Relación M:N con productos. |
| **Estado actual** | 🟢 Funciona |
| **Decisión** | 🟢 Migrar igual |
| **Justificación** | Funcionalidad simple y efectiva. Los tags como navegación secundaria están bien resueltos. |
| **Confianza** | ALTA |

### 1.5 Búsqueda textual
| Aspecto | Detalle |
|---|---|
| **Qué hace hoy** | Búsqueda global en admin (`global_search.php`). En frontend: búsqueda integrada en la grilla (inferido: LIKE en queries de `get_products.php`). |
| **Estado actual** | 🟡 Parcial (búsqueda básica con LIKE, sin relevancia ni fuzzy) |
| **Decisión** | 🔵 Migrar mejorado |
| **Justificación** | La búsqueda con LIKE no escala y no maneja typos. Implementar búsqueda full-text con Elasticsearch o PostgreSQL `tsvector`. Esto impacta directamente en conversión. |
| **Confianza** | MEDIA (no se pudo verificar implementación exacta de la búsqueda frontend) |

---

## MÓDULO 2: PRODUCTO (Detalle Individual)

### 2.1 Página de detalle de producto
| Aspecto | Detalle |
|---|---|
| **Qué hace hoy** | URL `/producto/{url}`. Muestra: nombre, descripción, fotos, variantes (combinaciones de hasta 3 propiedades), precio según lista del cliente, stock por sucursal, selector de cantidad, botón agregar al carrito, productos relacionados. |
| **Estado actual** | 🟢 Funciona |
| **Decisión** | 🔵 Migrar mejorado |
| **Justificación** | Funcionalidad completa pero la UI es legacy. Mejorar: galería de imágenes con zoom, mostrar variantes como selectores visuales (no solo dropdowns), indicador de stock en tiempo real, breadcrumbs, schema.org structured data para SEO. |
| **Confianza** | ALTA |

**Historias de usuario:**
- Como cliente quiero ver todas las fotos del producto con zoom para evaluar detalles antes de comprar
- Como cliente quiero seleccionar talle y color visualmente para no equivocarme de variante
- Como cliente quiero ver si hay stock en mi sucursal antes de agregar al carrito

### 2.2 Variantes de producto
| Aspecto | Detalle |
|---|---|
| **Qué hace hoy** | Hasta 3 propiedades por variante (ej: Talle + Color + Material). Cada variante tiene SKU único, foto propia, stock por sucursal y precio por lista. |
| **Estado actual** | 🟢 Funciona |
| **Decisión** | 🔵 Migrar mejorado |
| **Justificación** | El modelo de datos es correcto (tablas `productos_variantes`, `productos_variantes_stock`, `productos_variantes_precios`). Mejorar: permitir N propiedades en lugar de hardcodear 3 (`propiedad1_id`, `propiedad2_id`, `propiedad3_id`), usar JSON array de propiedades para flexibilidad. |
| **Confianza** | ALTA |

### 2.3 Productos relacionados
| Aspecto | Detalle |
|---|---|
| **Qué hace hoy** | Admin selecciona productos vinculados manualmente. Se muestran en la página de producto. |
| **Estado actual** | 🟢 Funciona |
| **Decisión** | 🔵 Migrar mejorado |
| **Justificación** | Mantener selección manual. Agregar: relacionados automáticos por categoría/marca (como fallback cuando no hay manuales), "otros clientes también compraron". |
| **Confianza** | ALTA |

---

## MÓDULO 3: CARRITO DE COMPRAS

### 3.1 Gestión del carrito
| Aspecto | Detalle |
|---|---|
| **Qué hace hoy** | Almacenado en `$_SESSION['carrito']`. Agregar vía AJAX con validación server-side de stock y precio (anti-tampering). Modificar cantidades, eliminar items. Recalculo dinámico de promociones y cupones. Resumen con subtotales, descuentos, IVA, costo de envío. |
| **Estado actual** | 🟢 Funciona |
| **Decisión** | 🔵 Migrar mejorado |
| **Justificación** | La lógica de validación server-side es excelente (previene manipulación de precios). Mejorar: carrito persistente en DB para recuperación cross-dispositivo y post-sesión, mini-carrito en header con vista previa, animaciones de agregado. No depender de sesión PHP (usar JWT + Redis o DB). |
| **Confianza** | ALTA |

**Historias de usuario:**
- Como cliente quiero que mi carrito persista aunque cierre el navegador para no perder mis productos
- Como cliente quiero ver un resumen rápido del carrito desde cualquier página
- Como cliente quiero que el sistema valide el precio y stock al agregar al carrito para evitar sorpresas al final

### 3.2 Validación de stock en carrito
| Aspecto | Detalle |
|---|---|
| **Qué hace hoy** | `agregarcarrito.php` valida stock antes de agregar. Si `stock < cantidad`, rechaza con `exit`. |
| **Estado actual** | 🟢 Funciona |
| **Decisión** | 🟢 Migrar igual |
| **Justificación** | Buen mecanismo de defensa. Mantener igual. |
| **Confianza** | ALTA |

### 3.3 Validación de precio en carrito
| Aspecto | Detalle |
|---|---|
| **Qué hace hoy** | `agregarcarrito.php` consulta `productos_variantes_precios` con el `lista_id` del cliente. Si el precio del POST no coincide con DB, usa el de DB (ignora cliente). |
| **Estado actual** | 🟢 Funciona |
| **Decisión** | 🟢 Migrar igual |
| **Justificación** | Anti-tampering correcto. Mantener. |
| **Confianza** | ALTA |

### 3.4 Promociones automáticas en carrito
| Aspecto | Detalle |
|---|---|
| **Qué hace hoy** | `buscarPromoPorProducto()` busca promociones activas aplicables. Tipos: `00` (porcentaje automático de PadPio), `0` (descuento por cantidad). Se recalcula en cada renderizado. |
| **Estado actual** | 🟢 Funciona |
| **Decisión** | 🔵 Migrar mejorado |
| **Justificación** | Lógica correcta pero acoplada al renderizado. Migrar a servicio de pricing separado con cache. Agregar: mostrar "X% OFF" en el producto, mensaje "comprá N más para X% descuento". |
| **Confianza** | ALTA |

### 3.5 Cupones en carrito
| Aspecto | Detalle |
|---|---|
| **Qué hace hoy** | Aplicación de cupón desde el carrito. Soporta: porcentaje, monto fijo, envío gratis. Validación de acumulabilidad con promociones. Aplicación por tipo (toda la tienda, categorías, productos). |
| **Estado actual** | 🟢 Funciona |
| **Decisión** | 🔵 Migrar mejorado |
| **Justificación** | Buena lógica de aplicación selectiva. Mejorar: input de cupón más visible, feedback inmediato de validación (no postback), mostrar descuento aplicado por ítem. |
| **Confianza** | ALTA |

---

## MÓDULO 4: CHECKOUT (4 Pasos)

### 4.1 Checkout Paso 1 — Datos Personales
| Aspecto | Detalle |
|---|---|
| **Qué hace hoy** | Selector de tipo de cliente (si `tipos_cliente=1`). Campos dinámicos según tipo: nombre, apellido, DNI, razón social, CUIT, situación fiscal, tipo de comprobante. Email requerido si no logueado. Checkbox marketing. Validación de compra mínima. |
| **Estado actual** | 🟢 Funciona |
| **Decisión** | 🔵 Migrar mejorado |
| **Justificación** | La lógica de campos dinámicos por perfil está bien pensada. Mejorar: UX en un solo paso visual con sections expandibles, autocompletado de datos si está logueado, validación de CUIT/DNI en frontend, selector de tipo de cliente más visual. |
| **Confianza** | ALTA |

**Historias de usuario:**
- Como cliente no registrado quiero comprar sin crear cuenta para no perder tiempo
- Como empresa quiero elegir tipo de factura según mi situación fiscal
- Como cliente recurrente quiero que mis datos se autocompleten para no cargarlos cada vez

### 4.2 Checkout Paso 2 — Forma de Entrega
| Aspecto | Detalle |
|---|---|
| **Qué hace hoy** | Muestra opciones según cliente: retiro por sucursal (gratis), envío a domicilio (Zipnova o logística propia), retiro en punto Zipnova. Direcciones guardadas si logueado. Campos de dirección con AJAX para CP/localidad/provincia. Checkbox "misma dirección para facturación". |
| **Estado actual** | 🟢 Funciona |
| **Decisión** | 🔵 Migrar mejorado |
| **Justificación** | Buena flexibilidad. Mejorar: mapa de sucursales/puntos de retiro, cálculo de costo de envío en tiempo real sin recargar página, selector de sucursal/punto de retiro visual, validación de CP contra cobertura. |
| **Confianza** | ALTA |

**Historias de usuario:**
- Como cliente quiero ver un mapa con las sucursales disponibles para elegir la más cercana
- Como cliente quiero que el costo de envío se calcule automáticamente al ingresar mi CP
- Como cliente logueado quiero seleccionar una dirección guardada para no escribirla cada vez

### 4.3 Checkout Paso 3 — Medio de Pago
| Aspecto | Detalle |
|---|---|
| **Qué hace hoy** | Muestra métodos según perfil: MercadoPago, Modo, Transferencia, Efectivo. Banner de promos bancarias. Validación de compra mínima. |
| **Estado actual** | 🟢 Funciona |
| **Decisión** | 🔵 Migrar mejorado |
| **Justificación** | Selector simple pero poco informativo. Mejorar: mostrar cuotas y costo de cada una para MP, badges de seguridad, resumen del pedido visible en este paso, guardar medio preferido del cliente. |
| **Confianza** | ALTA |

### 4.4 Checkout Paso 4 — Confirmación y Pago
| Aspecto | Detalle |
|---|---|
| **Qué hace hoy** | Creación/actualización de pedido con UPSERT. Transacción MySQL con `SELECT ... FOR UPDATE` para validación final de stock. Registro automático de nuevo cliente si email no existe (genera contraseña random, envía email). Ruteo por forma de pago: MP (redirige a URL), Modo (QR + link), Transferencia (datos bancarios + link comprobante), Efectivo (mensaje confirmación). Limpia carrito. |
| **Estado actual** | 🟢 Funciona |
| **Decisión** | 🔵 Migrar mejorado |
| **Justificación** | El flujo transaccional con `FOR UPDATE` es correcto. Mejorar: pantalla de confirmación más clara (resumen completo antes de pagar), progress indicator de los 4 pasos, timer de expiración del pedido, registro automático con mejor UX (password via magic link en vez de email con contraseña). |
| **Confianza** | ALTA |

**Historias de usuario:**
- Como cliente quiero ver un resumen completo de mi pedido antes de pagar para confirmar que todo esté bien
- Como cliente nuevo quiero recibir un link mágico para acceder a mi cuenta en vez de una contraseña random
- Como cliente que pagó con transferencia quiero subir mi comprobante fácilmente

---

## MÓDULO 5: CUENTA DEL CLIENTE

### 5.1 Registro
| Aspecto | Detalle |
|---|---|
| **Qué hace hoy** | Formulario en `/account_register`. Crea cliente con `activo=0`, `contrasenia=md5(password)`, `hash=random_strings(32)`. Envía email con link de activación. |
| **Estado actual** | 🟢 Funciona |
| **Decisión** | 🔵 Migrar mejorado |
| **Justificación** | El flujo de activación por email es correcto. Mejorar crítico: bcrypt en vez de md5, validación de fortaleza de contraseña, rate limiting en registro, Google/redes sociales login (opcional), verificación de email único con feedback inmediato. |
| **Confianza** | ALTA |

### 5.2 Login
| Aspecto | Detalle |
|---|---|
| **Qué hace hoy** | Formulario email + contraseña. `md5(password)` comparado con DB. Carga perfil completo en sesión (métodos de pago, envíos, marcas, lista de precios, mínimo compra). Carga favoritos. |
| **Estado actual** | 🟢 Funciona |
| **Decisión** | 🔵 Migrar mejorado |
| **Justificación** | Funcionalidad correcta pero con md5. Migrar a JWT + bcrypt. Agregar: remember-me, bloqueo temporal tras N intentos fallidos, notificación de login desde nuevo dispositivo. |
| **Confianza** | ALTA |

### 5.3 Recuperación de contraseña
| Aspecto | Detalle |
|---|---|
| **Qué hace hoy** | Solicita email → envía link con hash → formulario de nueva contraseña → `UPDATE contrasenia=md5(nueva)`. |
| **Estado actual** | 🟢 Funciona |
| **Decisión** | 🔵 Migrar mejorado |
| **Justificación** | Flujo estándar. Mejorar: tokens con expiración, bcrypt, rate limiting (no permitir spam de recuperación). |
| **Confianza** | ALTA |

### 5.4 Activación de cuenta
| Aspecto | Detalle |
|---|---|
| **Qué hace hoy** | Link `/account_activate/{hash}` → `UPDATE clientes SET activo='1'` → login automático. |
| **Estado actual** | 🟢 Funciona |
| **Decisión** | 🟢 Migrar igual |
| **Justificación** | Simple y efectivo. |
| **Confianza** | ALTA |

### 5.5 Perfil del cliente
| Aspecto | Detalle |
|---|---|
| **Qué hace hoy** | Edición de datos personales en `/account_profile`. Datos de empresa en `/account_company`. |
| **Estado actual** | 🟢 Funciona |
| **Decisión** | 🟢 Migrar igual |
| **Justificación** | CRUD básico sin complejidad. |
| **Confianza** | ALTA |

### 5.6 Direcciones guardadas
| Aspecto | Detalle |
|---|---|
| **Qué hace hoy** | CRUD en `/account_addresses`. Tabla `clientes_direcciones`. Primera dirección guardada se marca como predeterminada. Usadas en checkout paso 2. |
| **Estado actual** | 🟢 Funciona |
| **Decisión** | 🔵 Migrar mejorado |
| **Justificación** | Mantener CRUD. Agregar: poder marcar/desmarcar predeterminada, etiquetas ("Casa", "Trabajo"), validación de CP en frontend. |
| **Confianza** | ALTA |

### 5.7 Historial de pedidos
| Aspecto | Detalle |
|---|---|
| **Qué hace hoy** | Listado en `/account_orders`. Detalle de pedido individual en `/account_order/{hash}` con estados. |
| **Estado actual** | 🟢 Funciona |
| **Decisión** | 🔵 Migrar mejorado |
| **Justificación** | Funcionalidad básica. Mejorar: tracking visual del envío, botón "Repetir compra" desde historial, filtros por estado, descarga de factura (PDF), timeline de estados del pedido. |
| **Confianza** | ALTA |

### 5.8 Cerrar sesión
| Aspecto | Detalle |
|---|---|
| **Qué hace hoy** | `logout.php` destruye sesión de tienda. |
| **Estado actual** | 🟢 Funciona |
| **Decisión** | 🟢 Migrar igual |
| **Justificación** | Trivial. |
| **Confianza** | ALTA |

---

## MÓDULO 6: ADMIN PANEL

### 6.1 Dashboard
| Aspecto | Detalle |
|---|---|
| **Qué hace hoy** | KPIs: ventas del mes, comparativa con mes anterior, métricas de pedidos. Selector de mes. |
| **Estado actual** | 🟢 Funciona (alcance exacto no totalmente visible) |
| **Decisión** | 🔵 Migrar mejorado |
| **Justificación** | Dashboard básico. Mejorar: KPIs en tiempo real, gráficos con filtros avanzados (por sucursal, por categoría, por cliente), predicciones simples, exportación de reportes. Tailwind CSS + chart.js o recharts. |
| **Confianza** | MEDIA (alcance exacto del dashboard actual no 100% visible) |

**Historias de usuario:**
- Como administrador quiero ver las ventas del día en tiempo real para monitorear el negocio
- Como administrador quiero comparar este mes con el anterior para detectar tendencias

### 6.2 Gestión de productos (CRUD)
| Aspecto | Detalle |
|---|---|
| **Qué hace hoy** | CRUD completo con DataTable. Crear/editar: nombre, URL, descripción, marca, categorías (M:N), propiedades, tags, keywords, fotos, estado. Importación masiva Excel. Exportación a Excel. Sincronización PadPio (stock y precios). |
| **Estado actual** | 🟢 Funciona |
| **Decisión** | 🔵 Migrar mejorado |
| **Justificación** | CRUD completo. Mejorar: editor WYSIWYG para descripción, drag-and-drop de imágenes con preview, edición inline en DataTable, bulk actions (activar/desactivar múltiples, cambiar categoría masiva), historial de cambios. |
| **Confianza** | ALTA |

### 6.3 Gestión de variantes y stock
| Aspecto | Detalle |
|---|---|
| **Qué hace hoy** | CRUD de variantes con hasta 3 propiedades. Stock por variante y sucursal con toggle `stock_infinito`. Precios por variante y lista de precios. Fotos por variante. |
| **Estado actual** | 🟢 Funciona |
| **Decisión** | 🔵 Migrar mejorado |
| **Justificación** | Base sólida. Mejorar: UI unificada de variantes (generador de combinaciones automático), stock con historial de movimientos, alertas de stock bajo, edición masiva de precios por lista. |
| **Confianza** | ALTA |

### 6.4 Gestión de categorías
| Aspecto | Detalle |
|---|---|
| **Qué hace hoy** | CRUD con ordenamiento nestable (drag-and-drop jerárquico). Foto por categoría. Soft delete. |
| **Estado actual** | 🟢 Funciona |
| **Decisión** | 🟢 Migrar igual |
| **Justificación** | Funcionalidad correcta. El nestable se reimplementa con librería equivalente en JS. |
| **Confianza** | ALTA |

### 6.5 Gestión de marcas
| Aspecto | Detalle |
|---|---|
| **Qué hace hoy** | CRUD simple. |
| **Estado actual** | 🟢 Funciona |
| **Decisión** | 🟢 Migrar igual |
| **Justificación** | CRUD básico. |
| **Confianza** | ALTA |

### 6.6 Gestión de tags
| Aspecto | Detalle |
|---|---|
| **Qué hace hoy** | CRUD con colores personalizados, visibilidad en menú, ordenamiento. |
| **Estado actual** | 🟢 Funciona |
| **Decisión** | 🟢 Migrar igual |
| **Justificación** | Funcionalidad simple y bien resuelta. |
| **Confianza** | ALTA |

### 6.7 Gestión de propiedades y valores
| Aspecto | Detalle |
|---|---|
| **Qué hace hoy** | CRUD de propiedades (Talle, Color, etc.) y sus valores (XL, Rojo, etc.). Multiplicador de precio (`valor2`). Ordenamiento. |
| **Estado actual** | 🟢 Funciona |
| **Decisión** | 🟢 Migrar igual |
| **Justificación** | Base para las variantes. Sin cambios necesarios. |
| **Confianza** | ALTA |

### 6.8 Gestión de pedidos
| Aspecto | Detalle |
|---|---|
| **Qué hace hoy** | DataTable avanzado con filtros por fecha, estado, pago, entrega. Vista detalle. Edición de estados, tracking, items. Creación manual de pedido desde admin. Vista imprimible. Exportación RoTSis. |
| **Estado actual** | 🟢 Funciona |
| **Decisión** | 🔵 Migrar mejorado |
| **Justificación** | La funcionalidad es muy completa. Mejorar: UI más moderna, timeline visual de estados, edición inline en DataTable, filtros guardables, notificaciones de cambios de estado al cliente. |
| **Confianza** | ALTA |

### 6.9 Gestión de clientes
| Aspecto | Detalle |
|---|---|
| **Qué hace hoy** | CRUD de clientes con filtros (tipo: clientes/prospectos). Perfiles de cliente (`clientes_tipos`) con configuración detallada de métodos de pago, envíos, mínimos, marcas. Tipos de comprobante (`clientes_tipos_comprobante`). Situaciones fiscales. |
| **Estado actual** | 🟢 Funciona |
| **Decisión** | 🔵 Migrar mejorado |
| **Justificación** | El modelo de perfiles es potente. Mejorar: vista unificada de cliente (pedidos + direcciones + datos en una sola pantalla), segmentación, exportación, historial de actividad. |
| **Confianza** | ALTA |

### 6.10 Gestión de envíos propios
| Aspecto | Detalle |
|---|---|
| **Qué hace hoy** | CRUD con filtro por provincia y localidades (JSON array). Reglas de envío gratis por método. |
| **Estado actual** | 🟢 Funciona |
| **Decisión** | 🟢 Migrar igual |
| **Justificación** | Lógica de negocio simple y correcta. |
| **Confianza** | ALTA |

### 6.11 Configuración general
| Aspecto | Detalle |
|---|---|
| **Qué hace hoy** | Panel pestañeado con 8 secciones: connect, contenido, envíos, pagos, productos, reglas de negocio, web, estilos. Key-value en tabla `configuracion`. |
| **Estado actual** | 🟢 Funciona |
| **Decisión** | 🔵 Migrar mejorado |
| **Justificación** | El key-value es flexible pero inseguro (credenciales en texto plano) y difícil de validar. Migrar a configuración tipada por módulo en NestJS. Separar settings visuales (que son por tenant) de credenciales (que deben ir a variables de entorno o vault). |
| **Confianza** | ALTA |

### 6.12 Gestión de usuarios admin
| Aspecto | Detalle |
|---|---|
| **Qué hace hoy** | CRUD de administradores. Tipos de usuario con permisos granulares por sección (119 secciones). Roles con restricción de clientes/pedidos propios. Login con contraseña en texto plano. |
| **Estado actual** | 🟡 Funciona pero con falla de seguridad crítica |
| **Decisión** | 🔵 Migrar mejorado |
| **Justificación** | El modelo de permisos granulares es bueno y debe mantenerse. Migrar urgentemente a bcrypt para contraseñas. Agregar: 2FA, registro de actividad de admin, roles más flexibles. |
| **Confianza** | ALTA |

### 6.13 Importación/Exportación Excel
| Aspecto | Detalle |
|---|---|
| **Qué hace hoy** | Importación masiva de productos vía plantilla XLSX (PhpSpreadsheet). Exportación de productos a Excel. |
| **Estado actual** | 🟢 Funciona |
| **Decisión** | 🔵 Migrar mejorado |
| **Justificación** | Migrar a `exceljs` en Node. Mejorar: validación en frontend antes de enviar, preview de filas antes de confirmar importación, reporte de errores detallado post-importación. |
| **Confianza** | ALTA |

### 6.14 Carritos abandonados (admin)
| Aspecto | Detalle |
|---|---|
| **Qué hace hoy** | Listado de pedidos en estado "Incompleto". |
| **Estado actual** | 🟢 Funciona |
| **Decisión** | 🟡 Post-MVP |
| **Justificación** | Es una vista de datos pasiva. En MVP, los pedidos incompletos se pueden ver desde la lista de pedidos. La vista dedicada y el cron de recuperación van en Post-MVP. |
| **Confianza** | ALTA |

### 6.15 Encuestas (admin)
| Aspecto | Detalle |
|---|---|
| **Qué hace hoy** | CRUD de encuestas con preguntas de tipos: texto, valoración, checkbox, radio. Cupón de regalo opcional al completar. Envío a prospectos/pedidos. Respuestas visualizables. |
| **Estado actual** | 🟢 Funciona |
| **Decisión** | 🟡 Post-MVP |
| **Justificación** | Funcionalidad valiosa pero no bloqueante. Se puede vivir sin encuestas en el MVP inicial. |
| **Confianza** | ALTA |

---

## MÓDULO 7: PAGOS

### 7.1 MercadoPago
| Aspecto | Detalle |
|---|---|
| **Qué hace hoy** | Integración vía `llamadoCurl()` (proxy interno). Creación de preferencia de pago, redirección a checkout MP. IPN recibe webhook, actualiza estado, envía emails, descuenta stock, confirma envío Zipnova. Soporte para cuotas configurables. Callback de retorno con pantallas éxito/proceso/error. |
| **Estado actual** | 🟡 Funciona pero sin validación de firma del webhook |
| **Decisión** | 🔵 Migrar mejorado |
| **Justificación** | Migrar a SDK oficial de MercadoPago para Node.js (`mercadopago`). Implementar validación de `x-signature` en webhooks. Agregar: guardar `payment_id` en pedidos para trazabilidad, reintentos ante fallos del webhook, logs de IPN. |
| **Confianza** | ALTA |

**Historias de usuario:**
- Como cliente quiero pagar con tarjeta en cuotas para financiar mi compra
- Como cliente quiero ver el estado de mi pago en tiempo real

### 7.2 Modo
| Aspecto | Detalle |
|---|---|
| **Qué hace hoy** | Similar a MP: proxy vía `llamadoCurl()`, QR y link de pago. Webhook recibe confirmación, actualiza pedido por hash. Bug detectado: `nacimiento` hardcodeado a `'1980-06-20'`. |
| **Estado actual** | 🟡 Funciona con bugs |
| **Decisión** | 🔵 Migrar mejorado |
| **Justificación** | Evaluar SDK oficial de Modo para Node.js. Corregir fecha de nacimiento (usar dato real del cliente o no enviar). Validar firma de webhooks. |
| **Confianza** | MEDIA (implementación de `llamadoCurl` no visible) |

### 7.3 Transferencia bancaria
| Aspecto | Detalle |
|---|---|
| **Qué hace hoy** | Muestra datos bancarios de `configuracion.datos_bancarios`. Link para subir comprobante vía `/comprobantes/{hash}`. Emails se envían inmediatamente. |
| **Estado actual** | 🟢 Funciona |
| **Decisión** | 🔵 Migrar mejorado |
| **Justificación** | Mejorar: subida de comprobante con drag-and-drop, validación de formato/tamaño, notificación al admin cuando se sube un comprobante nuevo, markup del pedido como "comprobante recibido". |
| **Confianza** | ALTA |

### 7.4 Efectivo
| Aspecto | Detalle |
|---|---|
| **Qué hace hoy** | Muestra mensaje de confirmación con código de compra. Emails inmediatos. |
| **Estado actual** | 🟢 Funciona |
| **Decisión** | 🟢 Migrar igual |
| **Justificación** | Simple y suficiente. |
| **Confianza** | ALTA |

---

## MÓDULO 8: ENVÍOS

### 8.1 Zipnova (ZN)
| Aspecto | Detalle |
|---|---|
| **Qué hace hoy** | Cotización en checkout paso 2. Guardado de `zipnova_json`, `zipnova_opcion`, `zipnova_point_id`. Webhook de tracking (con **bug**: `SET estado_envio='estado'` literal en vez de variable). Confirmación de envío post-pago. |
| **Estado actual** | 🔴 Tracking roto; cotización funciona |
| **Decisión** | 🔵 Migrar mejorado |
| **Justificación** | Corregir bug del webhook (prioridad #1). Implementar API de Zipnova correctamente con SDK o llamadas HTTP directas desde NestJS. Agregar: reintentos en webhook, logs de estados, notificación al cliente cuando cambia el estado del envío. |
| **Confianza** | MEDIA (API de Zipnova no totalmente visible) |

**Historias de usuario:**
- Como cliente quiero ver el tracking de mi envío en tiempo real
- Como cliente quiero recibir notificaciones cuando mi pedido esté en camino

### 8.2 Envíos propios
| Aspecto | Detalle |
|---|---|
| **Qué hace hoy** | Configurables por admin: nombre, precio, provincia, localidades (JSON), info adicional, envío gratis con mínimo. Filtrado en checkout por provincia/localidad del cliente. |
| **Estado actual** | 🟢 Funciona |
| **Decisión** | 🟢 Migrar igual |
| **Justificación** | Lógica de negocio simple y correcta. |
| **Confianza** | ALTA |

### 8.3 Retiro por sucursal
| Aspecto | Detalle |
|---|---|
| **Qué hace hoy** | Gratis. Información configurable. Habilitado por perfil (`clientes_tipos.retiro_sucursal`). |
| **Estado actual** | 🟢 Funciona |
| **Decisión** | 🔵 Migrar mejorado |
| **Justificación** | Agregar: mapa con ubicación de sucursales, selector de sucursal, horarios, notificación cuando el pedido esté listo para retirar. |
| **Confianza** | ALTA |

### 8.4 Envío gratis
| Aspecto | Detalle |
|---|---|
| **Qué hace hoy** | Tres niveles: global (`envio_gratis` con monto_desde), por método de envío propio (`envio_gratis_minimo`), por cupón tipo "Envío gratis". |
| **Estado actual** | 🟢 Funciona |
| **Decisión** | 🟢 Migrar igual |
| **Justificación** | Flexibilidad adecuada. |
| **Confianza** | ALTA |

---

## MÓDULO 9: CHATBOT IA

### 9.1 Chatbot con OpenAI
| Aspecto | Detalle |
|---|---|
| **Qué hace hoy** | Widget JS en frontend. AJAX a `chat_handler.php`. Knowledge injection: carga todos los productos (precios según lista, stock), marcas, categorías, envíos, promociones y contacto en el system prompt. Modelo: `gpt-4o-mini`. Comando `COMMAND_ADD_TO_CART` para agregar productos vía chat. Historial en sesión. API key hardcodeada. |
| **Estado actual** | 🟢 Funciona |
| **Decisión** | 🟡 Post-MVP |
| **Justificación** | Es una feature diferencial pero no bloqueante para operar. Además, usar `gpt-4o-mini` tiene costo por request que debe evaluarse por cliente. En MVP se puede prescindir. Cuando se migre: API key por tenant, cache de knowledge (no recargar en cada new session), rate limiting, toggle por cliente. |
| **Confianza** | ALTA |

**Historias de usuario:**
- Como cliente quiero preguntar al chatbot sobre productos y precios para encontrar rápido lo que necesito
- Como cliente quiero agregar productos al carrito desde el chat para comprar sin navegar

---

## MÓDULO 10: FAVORITOS (WISH LIST)

### 10.1 Lista de favoritos
| Aspecto | Detalle |
|---|---|
| **Qué hace hoy** | Toggle vía AJAX (`favoritos.php`). Guardado en sesión (`$_SESSION['favoritos']`) + DB (`clientes_favoritos`). Vista dedicada en `/account_wish_list`. |
| **Estado actual** | 🟢 Funciona |
| **Decisión** | 🟢 Migrar igual |
| **Justificación** | Simple y útil. |
| **Confianza** | ALTA |

**Historias de usuario:**
- Como cliente quiero guardar productos en favoritos para comprarlos después
- Como cliente quiero ver mi wishlist desde mi cuenta

---

## MÓDULO 11: CONTACTO

### 11.1 Formulario de contacto
| Aspecto | Detalle |
|---|---|
| **Qué hace hoy** | Formulario en `/contacto` con selector de área (`contacto_areas`). Guarda en tabla `contacto`. reCAPTCHA opcional. Admin puede ver mensajes, marcar como leídos, gestionar áreas. |
| **Estado actual** | 🟢 Funciona |
| **Decisión** | 🟢 Migrar igual |
| **Justificación** | Funcionalidad estándar sin complejidad. |
| **Confianza** | ALTA |

---

## MÓDULO 12: DEVOLUCIONES

### 12.1 Formulario de devolución
| Aspecto | Detalle |
|---|---|
| **Qué hace hoy** | Formulario en `/devoluciones`. Condicionado por `configuracion.formulario_devoluciones`. Admin puede gestionar solicitudes. reCAPTCHA opcional. |
| **Estado actual** | 🟢 Funciona |
| **Decisión** | 🔵 Migrar mejorado |
| **Justificación** | Funcionalidad básica. Mejorar: flujo de estados de devolución (pendiente → aprobada → recibida → reembolsada), notificaciones al cliente, política de devolución visible, gestión de reintegro desde admin. |
| **Confianza** | ALTA |

**Historias de usuario:**
- Como cliente quiero solicitar una devolución fácilmente indicando el motivo
- Como administrador quiero gestionar el flujo completo de una devolución hasta el reintegro

---

## MÓDULO 13: FAQ (PREGUNTAS FRECUENTES)

### 13.1 Página de FAQ
| Aspecto | Detalle |
|---|---|
| **Qué hace hoy** | Página pública `/preguntas-frecuentes`. Admin gestiona preguntas/respuestas con ordenamiento. |
| **Estado actual** | 🟢 Funciona |
| **Decisión** | 🟢 Migrar igual |
| **Justificación** | Simple. Posible mejora visual (accordion animado con Tailwind). |
| **Confianza** | ALTA |

---

## MÓDULO 14: BANNERS Y SLIDERS

### 14.1 Slider del homepage
| Aspecto | Detalle |
|---|---|
| **Qué hace hoy** | CRUD de slides con título, descripción, foto, link. Ordenamiento. Toggle activo/inactivo. |
| **Estado actual** | 🟢 Funciona |
| **Decisión** | 🟢 Migrar igual |
| **Justificación** | Funcionalidad estándar. Se reimplementa con carousel en Tailwind CSS. |
| **Confianza** | ALTA |

### 14.2 Banners
| Aspecto | Detalle |
|---|---|
| **Qué hace hoy** | CRUD de banners con ubicación configurable. Banners de promociones bancarias separados. |
| **Estado actual** | 🟢 Funciona |
| **Decisión** | 🟢 Migrar igual |
| **Justificación** | Simple. |
| **Confianza** | ALTA |

### 14.3 Carouseles y home order
| Aspecto | Detalle |
|---|---|
| **Qué hace hoy** | Configuración de carouseles del home y orden de módulos (`home_order`). |
| **Estado actual** | 🟢 Funciona |
| **Decisión** | 🔵 Migrar mejorado |
| **Justificación** | Migrar a sistema de "secciones" configurables: el admin puede arrastrar y ordenar módulos del home (slider, categorías destacadas, productos destacados, banners). Más flexible que el sistema actual. |
| **Confianza** | MEDIA (alcance exacto de home_order no visible) |

---

## MÓDULO 15: CUPONES

### 15.1 Gestión de cupones
| Aspecto | Detalle |
|---|---|
| **Qué hace hoy** | CRUD. Tipos: porcentaje, monto fijo, envío gratis. Aplicación selectiva: toda la tienda, categorías, productos. Acumulabilidad con promociones. Lógica en `inc/cupon.php`. |
| **Estado actual** | 🟢 Funciona |
| **Decisión** | 🟢 Migrar igual |
| **Justificación** | Buena flexibilidad. La lógica de validación es correcta. |
| **Confianza** | ALTA |

### 15.2 Aplicación de cupones en checkout
| Aspecto | Detalle |
|---|---|
| **Qué hace hoy** | Input en carrito. Validación server-side. Acumulabilidad: si la promoción es tipo `0` o `00`, el cupón se acumula si es `acumulable=1`. Monto fijo se descuenta del total. |
| **Estado actual** | 🟢 Funciona |
| **Decisión** | 🟢 Migrar igual |
| **Justificación** | Reglas de negocio claras y correctas. |
| **Confianza** | ALTA |

---

## MÓDULO 16: RESEÑAS (TESTIMONIOS)

### 16.1 Reseñas gestionadas por admin
| Aspecto | Detalle |
|---|---|
| **Qué hace hoy** | CRUD de reseñas en admin: nombre, texto, puntaje (1-5 estrellas). Se muestran en el frontend (ubicación inferida: homepage o sección dedicada). No son reseñas de clientes sobre productos específicos — son testimonios generales. |
| **Estado actual** | 🟢 Funciona |
| **Decisión** | 🔵 Migrar mejorado |
| **Justificación** | El sistema actual son testimonios manuales. Mejorar a reseñas reales de clientes sobre productos comprados: trigger post-compra, verificación de compra, moderación. Los testimonios generales pueden coexistir como "casos de éxito". |
| **Confianza** | MEDIA (alcance frontend de reseñas no visible) |

---

## MÓDULO 17: PROMOCIONES

### 17.1 Gestión de promociones
| Aspecto | Detalle |
|---|---|
| **Qué hace hoy** | CRUD con tipos: `00` (porcentaje automático de PadPio), `0` (descuento por cantidad desde N unidades), otros tipos vía `promociones_tipos`. Aplicación selectiva por producto/categoría con exclusiones. Fechas de vigencia. |
| **Estado actual** | 🟢 Funciona |
| **Decisión** | 🔵 Migrar mejorado |
| **Justificación** | El sistema es potente pero complejo. Mejorar: UI más clara para configurar reglas (tipo "si comprás 3 de categoría X, 20% off"), preview de promociones, stacking rules explícitas, simulación de descuentos. |
| **Confianza** | ALTA |

### 17.2 Promociones automáticas (PadPio)
| Aspecto | Detalle |
|---|---|
| **Qué hace hoy** | `padpio.php` detecta ofertas (`PrecioOfertaE`), calcula porcentajes, crea promociones tipo `00` automáticamente. Elimina promos automáticas previas en cada sincronización. |
| **Estado actual** | 🟢 Funciona |
| **Decisión** | 🔵 Migrar mejorado |
| **Justificación** | Migrar integración PadPio completa (ver abajo). La lógica de promos automáticas debe mantenerse pero con mejor manejo de conflictos con promos manuales. |
| **Confianza** | ALTA |

---

## MÓDULO 18: INTEGRACIONES (CROSS-CUTTING)

### 18.1 PadPio (sincronización stock/precios)
| Aspecto | Detalle |
|---|---|
| **Qué hace hoy** | Conexión directa a 2 BBDD SQL Server (puertos 9143, 9144). Sincroniza stock y precios. Aplica multiplicadores de propiedades. Genera promociones automáticas. Actualiza `precio_desde`. |
| **Estado actual** | 🟢 Funciona |
| **Decisión** | 🔵 Migrar mejorado |
| **Justificación** | Migrar de `sqlsrv` (PHP, Windows-only) a `node-mssql` (Node.js, cross-platform). Agregar: job scheduling (cron en NestJS), logs de sincronización, notificaciones de errores, sincronización incremental (no full cada vez). La dependencia Windows-only actual limita el deploy. |
| **Confianza** | ALTA |

### 18.2 Dicomere (ERP)
| Aspecto | Detalle |
|---|---|
| **Qué hace hoy** | Scripts PHP en `importar_web/` que importan productos, clientes y pedidos desde Dicomere. |
| **Estado actual** | 🟡 No detectado completamente |
| **Decisión** | 🟡 Post-MVP |
| **Justificación** | Sin visibilidad completa del mecanismo de integración. Se requiere investigación adicional con el cliente para determinar método (API, DB directa, CSV, etc.). Post-MVP porque no bloquea la operación de todos los clientes. |
| **Confianza** | BAJA (no visible en el código analizado) |

### 18.3 Envío de emails
| Aspecto | Detalle |
|---|---|
| **Qué hace hoy** | PHPMailer con sistema de plantillas (`emails_plantillas`) con placeholders `{{VAR}}`. Emails en cola (`pedidos_emails`) para pagos diferidos (MP, Modo). Plantillas: confirmación cliente, confirmación admin, bienvenida compra, carrito abandonado, encuesta cupón regalo. |
| **Estado actual** | 🟢 Funciona |
| **Decisión** | 🔵 Migrar mejorado |
| **Justificación** | Migrar a Nodemailer + sistema de plantillas (Handlebars/MJML). Mejorar: cola de emails con reintentos (BullMQ), templates responsive con MJML, logs de envío. |
| **Confianza** | ALTA |

### 18.4 reCAPTCHA
| Aspecto | Detalle |
|---|---|
| **Qué hace hoy** | Google reCAPTCHA v3 en formularios de contacto y devoluciones. Keys por `configuracion`. |
| **Estado actual** | 🟢 Funciona |
| **Decisión** | 🟢 Migrar igual |
| **Justificación** | Integración simple. |
| **Confianza** | ALTA |

---

## MÓDULO 19: CONTENIDO WEB

### 19.1 Secciones de contenido adicional
| Aspecto | Detalle |
|---|---|
| **Qué hace hoy** | Páginas con contenido editable vía admin (`secciones_adicionales`). URL: `/secciones/{url}`. |
| **Estado actual** | 🟢 Funciona |
| **Decisión** | 🟢 Migrar igual |
| **Justificación** | CMS básico para páginas estáticas (términos, privacidad, etc.). |
| **Confianza** | ALTA |

### 19.2 Redes sociales
| Aspecto | Detalle |
|---|---|
| **Qué hace hoy** | Links de redes configurables por admin. |
| **Estado actual** | 🟢 Funciona |
| **Decisión** | 🟢 Migrar igual |
| **Justificación** | Trivial. |
| **Confianza** | ALTA |

### 19.3 Identidad visual por tenant
| Aspecto | Detalle |
|---|---|
| **Qué hace hoy** | Logos (menú, header, footer), favicon, fondo de login, imagen para compartir, estilos CSS configurables (colores, tipografías) vía `configuracion_grafica`. |
| **Estado actual** | 🟢 Funciona |
| **Decisión** | 🔵 Migrar mejorado |
| **Justificación** | Migrar a un sistema de theming con variables CSS/Tailwind config. Cada tenant tiene su propio theme. Agregar: preview en admin antes de guardar, paletas predefinidas, subida de logos con guía de dimensiones. |
| **Confianza** | ALTA |

---

## MÓDULO 20: MULTI-TENANT

### 20.1 Aislamiento de datos
| Aspecto | Detalle |
|---|---|
| **Qué hace hoy** | Base de datos separada por cliente. Selección vía credenciales diferentes en `inc/db.php` por branch de Git. |
| **Estado actual** | 🟡 Funciona pero frágil |
| **Decisión** | 🔵 Migrar mejorado |
| **Justificación** | Mantener DB por tenant (aislamiento total). Migrar de branches Git a tenant switching por variable de entorno/dominio. Cada deploy puede apuntar a una DB diferente. Evaluar schema-per-tenant en PostgreSQL como evolución futura. |
| **Confianza** | ALTA |

### 20.2 Configuración por tenant
| Aspecto | Detalle |
|---|---|
| **Qué hace hoy** | Tabla `configuracion` por DB. Tablas de contenido (FAQ, banners, etc.) por DB. |
| **Estado actual** | 🟢 Funciona |
| **Decisión** | 🔵 Migrar mejorado |
| **Justificación** | Migrar a configuración tipada en NestJS (`@nestjs/config`). Separar settings de negocio (en DB) de credenciales (en `.env` o vault). |
| **Confianza** | ALTA |

---

## Resumen de Decisiones

| Módulo | Sub-feature | Decisión |
|---|---|---|
| Catálogo | Grilla con filtros | 🔵 Migrar mejorado |
| Catálogo | Búsqueda | 🔵 Migrar mejorado |
| Catálogo | Filtro por categoría/marca/tag | 🟢 Migrar igual |
| Producto | Detalle y variantes | 🔵 Migrar mejorado |
| Producto | Relacionados | 🔵 Migrar mejorado |
| Carrito | Gestión y validación | 🔵 Migrar mejorado |
| Carrito | Promos y cupones en carrito | 🔵 Migrar mejorado |
| Checkout | 4 pasos completos | 🔵 Migrar mejorado |
| Cuenta | Registro/login/recover | 🔵 Migrar mejorado |
| Cuenta | Perfil, direcciones, pedidos | 🔵 Migrar mejorado |
| Admin | Dashboard | 🔵 Migrar mejorado |
| Admin | CRUD productos/variantes/stock | 🔵 Migrar mejorado |
| Admin | CRUD categorías/marcas/tags/propiedades | 🟢 Migrar igual |
| Admin | Gestión de pedidos | 🔵 Migrar mejorado |
| Admin | Gestión de clientes y perfiles | 🔵 Migrar mejorado |
| Admin | Envíos propios | 🟢 Migrar igual |
| Admin | Configuración general | 🔵 Migrar mejorado |
| Admin | Usuarios y permisos | 🔵 Migrar mejorado |
| Admin | Import/Export Excel | 🔵 Migrar mejorado |
| Admin | Carritos abandonados | 🟡 Post-MVP |
| Admin | Encuestas | 🟡 Post-MVP |
| Pagos | MercadoPago | 🔵 Migrar mejorado |
| Pagos | Modo | 🔵 Migrar mejorado |
| Pagos | Transferencia | 🔵 Migrar mejorado |
| Pagos | Efectivo | 🟢 Migrar igual |
| Envíos | Zipnova | 🔵 Migrar mejorado |
| Envíos | Propios y sucursal | 🔵 Migrar mejorado |
| Chatbot | IA con OpenAI | 🟡 Post-MVP |
| Favoritos | Wish list | 🟢 Migrar igual |
| Contacto | Formulario | 🟢 Migrar igual |
| Devoluciones | Formulario y gestión | 🔵 Migrar mejorado |
| FAQ | Preguntas frecuentes | 🟢 Migrar igual |
| Banners | Slider, banners, carouseles | 🟢 Migrar igual (🔵 home order) |
| Cupones | CRUD y aplicación | 🟢 Migrar igual |
| Reseñas | Testimonios | 🔵 Migrar mejorado |
| Promociones | CRUD y reglas | 🔵 Migrar mejorado |
| Integraciones | PadPio | 🔵 Migrar mejorado |
| Integraciones | Dicomere | 🟡 Post-MVP |
| Integraciones | Emails | 🔵 Migrar mejorado |
| Integraciones | reCAPTCHA | 🟢 Migrar igual |
| Contenido | Secciones adicionales y redes | 🟢 Migrar igual |
| Identidad | Theming por tenant | 🔵 Migrar mejorado |
| Multi-tenant | Aislamiento y configuración | 🔵 Migrar mejorado |

**Conteo por decisión:**
- 🟢 Migrar igual: 15 features
- 🔵 Migrar mejorado: 28 features
- 🟡 Post-MVP: 4 features
- 🔴 No migrar: 0 features

---

> **Confianza global de este documento:** ALTA
> **Nota:** Todas las afirmaciones sobre el estado actual están basadas en los outputs del System Auditor. Las decisiones de migración son interpretaciones del Product Owner basadas en valor de negocio, complejidad técnica y restricciones del proyecto ($50 USD/día, NestJS + Tailwind).
