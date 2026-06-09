# 01 — Modelo de Datos Inferido

> **Proyecto:** Lumba Ecommerce (Brownfield — migración PHP vanilla → NestJS + Tailwind)
> **Fecha:** 2026-06-04
> **Agente:** System Auditor (subagent)
> **Modelo:** deepseek-v4-pro
> **Nivel de confianza global:** MEDIA-ALTA (inferido de queries; no hay schema SQL documentado)
> **Fuente:** INSERT, UPDATE, SELECT, DELETE statements en ~350 archivos PHP

---

## Metodología

El modelo de datos fue inferido 100% del código fuente PHP ya que NO existen archivos de migración ni schema SQL. Se analizaron todas las queries encontradas en `routes/`, `inc/`, `connect/`, `admin/routes/`, `ajax/`, `cron/` y `acciones/`. Las foreign keys son implícitas (convención de nomenclatura: `{tabla_relacionada}_id`). Los tipos de datos son estimados.

---

## 2.1 Dominio: Productos y Catálogo

### `productos`
| Columna | Tipo Estimado | Notas |
|---|---|---|
| `Id` | INT AUTO_INCREMENT PK | |
| `producto` | VARCHAR(255) | Nombre del producto |
| `url` | VARCHAR(255) | Slug para URL |
| `marca_id` | INT FK → `marcas.Id` | |
| `activo` | TINYINT(1) | 0=inactivo, 1=activo |
| `eliminado` | TINYINT(1) | Soft delete (0=visible, 1=eliminado) |
| `precio_desde` | DECIMAL(12,2) | Precio mínimo entre variantes |
| `descripcion` | TEXT | [NO DETECTADO: hipótesis] |
| `foto` | VARCHAR(255) | Extensión de la foto principal |
| `destacado` | TINYINT(1) | [NO DETECTADO: hipótesis] |
| `orden` | INT | [NO DETECTADO: hipótesis para home_order] |
| `stock` | INT | [NO DETECTADO: posible campo legacy] |
| `categoria_id` | INT | [NO DETECTADO: posible campo legacy; la relación real es M:N] |
| `iva` | DECIMAL(5,2) | [NO DETECTADO: posible campo] |
| `codigo` | VARCHAR(100) | [NO DETECTADO: posible código interno] |

### `productos_categorias` (M:N)
| Columna | Tipo Estimado |
|---|---|
| `producto_id` | INT FK → `productos.Id` |
| `categoria_id` | INT FK → `categorias.Id` |

### `categorias`
| Columna | Tipo Estimado |
|---|---|
| `Id` | INT AUTO_INCREMENT PK |
| `categoria` | VARCHAR(255) |
| `url` | VARCHAR(255) |
| `eliminado` | TINYINT(1) |
| `orden` | INT |
| `foto` | VARCHAR(255) |
| `categoria_padre_id` | INT FK → `categorias.Id` [NO DETECTADO: hipótesis por nestable] |

### `marcas`
| Columna | Tipo Estimado |
|---|---|
| `Id` | INT AUTO_INCREMENT PK |
| `marca` | VARCHAR(255) |
| `url` | VARCHAR(255) |
| `eliminado` | TINYINT(1) |

### `productos_variantes`
| Columna | Tipo Estimado |
|---|---|
| `Id` | INT AUTO_INCREMENT PK |
| `producto_id` | INT FK → `productos.Id` |
| `sku` | VARCHAR(100) | Código SKU único |
| `propiedad1_id` | INT FK → `propiedades_valores.Id` |
| `propiedad2_id` | INT FK → `propiedades_valores.Id` |
| `propiedad3_id` | INT FK → `propiedades_valores.Id` |
| `nombre_combinacion` | VARCHAR(255) | Nombre generado de la combinación |
| `foto` | VARCHAR(255) | Foto específica de la variante |
| `eliminado` | TINYINT(1) | |

### `productos_variantes_stock`
| Columna | Tipo Estimado |
|---|---|
| `producto_id` | INT FK → `productos.Id` |
| `variante_id` | INT FK → `productos_variantes.Id` |
| `sucursal_id` | INT FK → `sucursales.Id` |
| `stock` | INT | Cantidad disponible |
| `stock_infinito` | TINYINT(1) | 1=stock ilimitado |

### `productos_variantes_precios`
| Columna | Tipo Estimado |
|---|---|
| `producto_id` | INT FK → `productos.Id` |
| `variante_id` | INT FK → `productos_variantes.Id` |
| `lista_id` | INT FK → `listas.Id` | Lista de precios |
| `precio` | DECIMAL(12,2) | Precio de venta |

### `productos_variantes_fotos` [NO DETECTADO: inferido]
| Columna | Tipo Estimado |
|---|---|
| `Id` | INT PK |
| `variante_id` / `producto_id` | INT FK |
| `archivo` | VARCHAR(255) |
| `orden` | INT |

### `propiedades`
| Columna | Tipo Estimado |
|---|---|
| `Id` | INT AUTO_INCREMENT PK |
| `propiedad` | VARCHAR(255) | Ej: "Talle", "Color" |
| `eliminado` | TINYINT(1) |
| `orden` | INT |

### `propiedades_valores`
| Columna | Tipo Estimado |
|---|---|
| `Id` | INT AUTO_INCREMENT PK |
| `propiedad_id` | INT FK → `propiedades.Id` |
| `valor` | VARCHAR(255) | Ej: "XL", "Rojo" |
| `valor2` | DECIMAL(12,2) | Multiplicador de precio (usado en PadPio) |
| `eliminado` | TINYINT(1) |

### `productos_propiedades_valores` (relación directa para filtros)
| Columna | Tipo Estimado |
|---|---|
| `producto_id` | INT FK → `productos.Id` |
| `valor_id` | INT FK → `propiedades_valores.Id` |

### `keywords`
| Columna | Tipo Estimado |
|---|---|
| `Id` | INT AUTO_INCREMENT PK |
| `keyword` | VARCHAR(255) |
| `eliminado` | TINYINT(1) |

### `productos_keywords` [NO DETECTADO: hipótesis]
| Columna | Tipo Estimado |
|---|---|
| `producto_id` | INT FK |
| `keyword_id` | INT FK |

### `tags`
| Columna | Tipo Estimado |
|---|---|
| `Id` | INT AUTO_INCREMENT PK |
| `tag` | VARCHAR(255) |
| `url` | VARCHAR(255) |
| `eliminado` | TINYINT(1) |
| `visible_menu` | TINYINT(1) | Mostrar en menú de navegación |
| `orden` | INT |
| `color_fondo_menu` | VARCHAR(7) | Color CSS |
| `color_texto_menu` | VARCHAR(7) | Color CSS |
| `bold_menu` | TINYINT(1) | Negrita en menú |

### `productos_tags` (M:N)
| Columna | Tipo Estimado |
|---|---|
| `producto_id` | INT FK → `productos.Id` |
| `tag_id` | INT FK → `tags.Id` |

### `listas`
| Columna | Tipo Estimado |
|---|---|
| `Id` | INT AUTO_INCREMENT PK |
| `lista` | VARCHAR(255) | Nombre de lista de precios |
| `predeterminada` | TINYINT(1) | |
| `eliminado` | TINYINT(1) | |

### `productos_relacionados` [NO DETECTADO: hipótesis]
| Columna | Tipo Estimado |
|---|---|
| `producto_id` | INT FK |
| `producto_relacionado_id` | INT FK |

---

## 2.2 Dominio: Pedidos y Transacciones

### `pedidos`
| Columna | Tipo Estimado | Notas |
|---|---|---|
| `Id` | INT AUTO_INCREMENT PK | |
| `fecha` | DATETIME | |
| `observaciones` | TEXT | Notas del cliente |
| `total` | DECIMAL(12,2) | Total final |
| `cliente_id` | INT FK → `clientes.Id` | |
| `cupon` | VARCHAR(100) | Código de cupón aplicado |
| `cupon_valor` | DECIMAL(12,2) | Valor del descuento |
| `cupon_tipo` | VARCHAR(50) | 'Porcentaje', 'Monto fijo', 'Envío gratis' |
| `lista_id` | INT FK → `listas.Id` | |
| `sucursal_id` | INT FK → `sucursales.Id` | |
| `origen` | VARCHAR(50) | 'Web', 'Admin', etc. |
| `email` | VARCHAR(255) | Email del comprador |
| `newsletter` | TINYINT(1) | Aceptó marketing |
| `nombre` | VARCHAR(255) | |
| `apellido` | VARCHAR(255) | |
| `area` | VARCHAR(10) | Código de área telefónico |
| `telefono` | VARCHAR(20) | |
| `tipo_cliente` | VARCHAR(100) | |
| `dni` | VARCHAR(20) | |
| `cuit` | VARCHAR(20) | |
| `razon_social` | VARCHAR(255) | |
| `nombre_fantasia` | VARCHAR(255) | [NO DETECTADO directamente] |
| `situacion_fiscal` | VARCHAR(100) | |
| `tipo_comprobante` | VARCHAR(100) | Tipo de factura |
| `calle` | VARCHAR(255) | Dirección de entrega |
| `numero` | VARCHAR(20) | |
| `departamento` | VARCHAR(50) | |
| `provincia_id` | INT FK → `provincias.Id` | |
| `localidad_id` | INT FK → `localidades.Id` | |
| `cp` | VARCHAR(20) | |
| `facturacion_calle` | VARCHAR(255) | Dirección de facturación |
| `facturacion_numero` | VARCHAR(20) | |
| `facturacion_departamento` | VARCHAR(50) | |
| `facturacion_provincia_id` | INT FK → `provincias.Id` | |
| `facturacion_localidad_id` | INT FK → `localidades.Id` | |
| `facturacion_cp` | VARCHAR(20) | |
| `formapago` | VARCHAR(100) | 'Mercadopago', 'Modo', 'Transferencia', 'Efectivo' |
| `hash` | VARCHAR(32) | Identificador público único |
| `formaentrega` | VARCHAR(100) | 'Zipnova entrega a domicilio', 'Zipnova retiro por sucursal', 'Retiro por sucursal', nombre de envío propio |
| `zipnova_opcion` | VARCHAR(100) | ID de la opción de envío |
| `zipnova_point_id` | VARCHAR(100) | ID del punto de retiro |
| `zipnova_json` | TEXT | JSON con resultados de cotización |
| `costo_envio` | DECIMAL(12,2) | Costo cobrado |
| `costo_envio_real` | DECIMAL(12,2) | Costo real |
| `estado` | VARCHAR(50) | 'Activo', 'Incompleto', 'Reintegrado', etc. |
| `estado_pago` | VARCHAR(50) | 'Pendiente', 'Pagado', 'Reintegrado' |
| `estado_entrega` | VARCHAR(50) | 'Pendiente', 'Enviado', 'Entregado' |
| `estado_factura` | VARCHAR(50) | 'Pendiente', 'Facturado' |
| `eliminado` | TINYINT(1) | |
| `cron_notificado` | TINYINT(1) | Ya fue notificado por cron de carrito abandonado |
| `tracking` | VARCHAR(255) | [NO DETECTADO: hipótesis por tracking de envío] |

**Valores mágicos documentados:**
- `estado`: 'Incompleto' (checkout no finalizado), 'Activo' (compra confirmada), 'Reintegrado' (devolución)
- `estado_pago`: 'Pendiente', 'Pagado', 'Reintegrado'
- `estado_entrega`: 'Pendiente', 'Enviado', 'Entregado' [NO DETECTADO: inferido]
- `formapago`: 'Mercadopago', 'Modo', 'Transferencia', 'Efectivo'
- `formaentrega`: 'Zipnova entrega a domicilio', 'Zipnova retiro por sucursal', 'Retiro por sucursal', o nombre de envío propio
- `cupon_tipo`: 'Porcentaje', 'Monto fijo', 'Envío gratis'

### `pedidos_detalle`
| Columna | Tipo Estimado |
|---|---|
| `Id` | INT AUTO_INCREMENT PK |
| `pedido_id` | INT FK → `pedidos.Id` |
| `producto` | VARCHAR(255) | Nombre del producto (denormalizado) |
| `producto_id` | INT FK → `productos.Id` |
| `variante_id` | INT FK → `productos_variantes.Id` |
| `producto_sku` | VARCHAR(100) | SKU de la variante |
| `cantidad` | INT | |
| `precio_abonado` | DECIMAL(12,2) | Precio final pagado |
| `precio_original` | DECIMAL(12,2) | Precio de lista |
| `iva` | DECIMAL(5,2) | |
| `promocion` | VARCHAR(255) | Nombre de la promoción aplicada |
| `promocion_id` | INT FK → `promociones.Id` | |
| `promocion_tipo` | VARCHAR(50) | '00', '0', etc. |
| `promocion_valor` | DECIMAL(12,2) | Valor del descuento |
| `foto` | VARCHAR(255) | Foto del producto al momento de la compra |
| `propiedades` | VARCHAR(500) | Talle, color, etc. concatenados |
| `aplica_cupon` | TINYINT(1) / DECIMAL | Si aplicó cupón (boolean o porcentaje) |
| `codigo_cupon` | VARCHAR(100) | Código del cupón aplicado |

### `pedidos_emails`
| Columna | Tipo Estimado |
|---|---|
| `Id` | INT AUTO_INCREMENT PK |
| `pedido_id` | INT FK → `pedidos.Id` |
| `asunto` | VARCHAR(500) |
| `cuerpo` | TEXT | Cuerpo completo del email (HTML compilado) |
| `destinatario` | VARCHAR(255) |
| `enviado` | TINYINT(1) | 0=pendiente, 1=enviado |

### `pedidos_estados` [NO DETECTADO: hipótesis por AJAX `actualizar_estados.php`]
| Columna | Tipo Estimado |
|---|---|
| `Id` | INT PK |
| `estado` | VARCHAR(100) |
| `tipo` | VARCHAR(50) | 'pago', 'entrega', 'factura', 'general' |

---

## 2.3 Dominio: Clientes

### `clientes`
| Columna | Tipo Estimado | Notas |
|---|---|---|
| `Id` | INT AUTO_INCREMENT PK | |
| `nombre` | VARCHAR(255) | |
| `apellido` | VARCHAR(255) | |
| `razon_social` | VARCHAR(255) | |
| `nombre_fantasia` | VARCHAR(255) | |
| `email` | VARCHAR(255) | |
| `contrasenia` | VARCHAR(32) | **MD5 (sin salt)** |
| `activo` | TINYINT(1) | Activado vía email |
| `hash` | VARCHAR(32) | Hash único para activación y recuperación |
| `area` | VARCHAR(10) | |
| `telefono` | VARCHAR(20) | |
| `cuit` | VARCHAR(20) | |
| `dni` | VARCHAR(20) | |
| `direccion` | VARCHAR(255) | [NO DETECTADO: posible campo legacy] |
| `tipo_id` | INT FK → `clientes_tipos.Id` | Perfil del cliente |
| `lista_id` | INT FK → `listas.Id` | Lista de precios asignada |
| `tipo_comprobante_id` | INT FK → `clientes_tipos_comprobante.Id` | |
| `situacion_fiscal_id` | INT FK → `clientes_situaciones.Id` | |
| `vendedor_id` | INT FK → `administradores.Id` | Vendedor asignado |
| `fecha_registro` | DATETIME | |
| `descuento` | DECIMAL(5,2) | Descuento personalizado |
| `codigo` | VARCHAR(100) | Código interno |
| `compro` | TINYINT(1) | Ya realizó compras |
| `marketing` | TINYINT(1) | Acepta marketing |
| `iibb` | VARCHAR(50) | Ingresos Brutos |
| `marcas` | JSON | Marcas permitidas (array de IDs) |
| `eliminado` | TINYINT(1) | |

### `clientes_tipos` (perfiles de cliente)
| Columna | Tipo Estimado |
|---|---|
| `Id` | INT AUTO_INCREMENT PK |
| `cliente_tipo` | VARCHAR(255) | Nombre: "Minorista", "Mayorista", etc. |
| `registro_habilitado` | TINYINT(1) | Puede registrarse/activarse |
| `mercadopago` | TINYINT(1) | |
| `modo` | TINYINT(1) | |
| `transferencia` | TINYINT(1) | |
| `efectivo` | TINYINT(1) | |
| `zipnova` | TINYINT(1) | |
| `zipnova_puntoentrega` | TINYINT(1) | |
| `envios_propios` | TINYINT(1) | |
| `retiro_sucursal` | TINYINT(1) | |
| `envios` | TINYINT(1) | [NO DETECTADO: posible campo general] |
| `minimo_compra` | DECIMAL(12,2) | Compra mínima |
| `lista_precios_id` | INT FK → `listas.Id` | |
| `clientes_tipos_comprobante_id` | INT | [NO DETECTADO] |
| `tipo_comprobante_id` | INT FK → `clientes_tipos_comprobante.Id` | |
| `marcas` | JSON | Marcas permitidas |
| `datos_nombre` | TINYINT(1) | Campo requerido en checkout |
| `datos_apellido` | TINYINT(1) | |
| `datos_razon_social` | TINYINT(1) | |
| `datos_nombre_fantasia` | TINYINT(1) | |
| `datos_dni` | TINYINT(1) | |
| `datos_cuit` | TINYINT(1) | |
| `datos_telefono` | TINYINT(1) | |
| `datos_marketing` | TINYINT(1) | |
| `datos_direccion` | TINYINT(1) | |
| `datos_situacion_fiscal` | TINYINT(1) | |
| `tipos_comprobante` | JSON | Array de IDs de comprobantes permitidos |
| `predeterminado` | TINYINT(1) | |
| `eliminado` | TINYINT(1) | |

### `clientes_tipos2` (nomenclatura alternativa en admin)
| Columna | Tipo Estimado | Notas |
|---|---|---|
| `Id` | INT PK | |
| [similares a clientes_tipos] | | [NO DETECTADO: posible segunda categorización o legacy] |

### `clientes_tipos_comprobante`
| Columna | Tipo Estimado |
|---|---|
| `Id` | INT AUTO_INCREMENT PK |
| `tipo_comprobante` | VARCHAR(255) | 'Factura A', 'Factura B', 'Ticket', etc. |
| `predeterminado` | TINYINT(1) | |
| `eliminado` | TINYINT(1) | |

### `clientes_situaciones`
| Columna | Tipo Estimado |
|---|---|
| `Id` | INT AUTO_INCREMENT PK |
| `situacion` | VARCHAR(255) | 'Consumidor Final', 'Responsable Inscripto', etc. |
| `eliminado` | TINYINT(1) | |

### `clientes_direcciones`
| Columna | Tipo Estimado |
|---|---|
| `Id` | INT AUTO_INCREMENT PK |
| `cliente_id` | INT FK → `clientes.Id` |
| `calle` | VARCHAR(255) |
| `numero` | VARCHAR(20) |
| `departamento` | VARCHAR(50) |
| `localidad_id` | INT FK → `localidades.Id` |
| `provincia_id` | INT FK → `provincias.Id` |
| `cp` | VARCHAR(20) |
| `eliminado` | TINYINT(1) |
| `predeterminada` | TINYINT(1) | Dirección por defecto |

### `clientes_favoritos`
| Columna | Tipo Estimado |
|---|---|
| `producto_id` | INT FK → `productos.Id` |
| `cliente_id` | INT FK → `clientes.Id` |

---

## 2.4 Dominio: Pagos

### `pagos` [NO DETECTADO: tabla NO encontrada en queries]
No se detectó una tabla de pagos separada. Los estados de pago se registran directamente en `pedidos.estado_pago`. Las referencias externas (MercadoPago payment_id, Modo transaction_id) [NO DETECTADO: posiblemente no se persisten].

### `comprobantes` [NO DETECTADO: hipótesis para subida de comprobantes]
| Posible Columna | Notas |
|---|---|
| `Id` | PK |
| `pedido_id` | FK |
| `archivo` | Path al comprobante |
| `fecha` | DATETIME |

---

## 2.5 Dominio: Envíos y Logística

### `envios_propios`
| Columna | Tipo Estimado |
|---|---|
| `Id` | INT AUTO_INCREMENT PK |
| `envio` | VARCHAR(255) | Nombre del método |
| `precio` | DECIMAL(12,2) | |
| `informacion` | TEXT | Info adicional mostrada al cliente |
| `provincia_id` | INT FK → `provincias.Id` | |
| `localidades` | JSON | Array de IDs de localidades cubiertas ([0]=todas) |
| `envio_gratis` | TINYINT(1) | Tiene envío gratis |
| `envio_gratis_minimo` | DECIMAL(12,2) | Monto mínimo para envío gratis |
| `activo` | TINYINT(1) | |
| `eliminado` | TINYINT(1) | |

### `envio_gratis`
| Columna | Tipo Estimado |
|---|---|
| `Id` | INT PK (fila única, Id=1) |
| `activo` | TINYINT(1) | |
| `monto_desde` | DECIMAL(12,2) | Monto mínimo para envío gratis global |

### `compra_minima`
| Columna | Tipo Estimado |
|---|---|
| `Id` | INT PK (fila única, Id=1) |
| `compra_minima` | DECIMAL(12,2) | |

### `sucursales`
| Columna | Tipo Estimado |
|---|---|
| `Id` | INT AUTO_INCREMENT PK |
| `sucursal` | VARCHAR(255) | Nombre |
| `direccion` | VARCHAR(255) | |
| `telefono` | VARCHAR(50) | |
| `eliminado` | TINYINT(1) | |

### `provincias`
| Columna | Tipo Estimado |
|---|---|
| `Id` | INT AUTO_INCREMENT PK |
| `provincia` | VARCHAR(255) | |

### `localidades`
| Columna | Tipo Estimado |
|---|---|
| `Id` | INT AUTO_INCREMENT PK |
| `localidad` | VARCHAR(255) | |
| `provincia_id` | INT FK → `provincias.Id` | |

### `codigos_postales`
| Columna | Tipo Estimado |
|---|---|
| `Id` | INT AUTO_INCREMENT PK |
| `codigo_postal` | VARCHAR(20) | |
| `localidad_id` | INT FK → `localidades.Id` | |

---

## 2.6 Dominio: Promociones y Cupones

### `promociones`
| Columna | Tipo Estimado | Notas |
|---|---|---|
| `Id` | INT AUTO_INCREMENT PK | |
| `promocion` | VARCHAR(255) | Nombre descriptivo |
| `promocion_tipo` | VARCHAR(50) | '00'=porcentaje auto (PadPio), '0'=descuento por cantidad, otros IDs → `promociones_tipos.Id` |
| `cantidad_valor` | DECIMAL(12,2) | Valor del descuento (%) |
| `cantidad_minimo` | INT | Cantidad mínima de productos |
| `limite_fecha` | VARCHAR(50) | 'Ilimitado' o con fecha |
| `fecha_desde` | DATE | |
| `fecha_hasta` | DATE | |
| `aplica_a_tipo` | VARCHAR(50) | 'Toda la tienda', 'Categorías', 'Productos' |
| `aplica_a_categorias` | JSON | Array de IDs |
| `aplica_a_productos` | JSON | Array de IDs |
| `excluir_categorias` | JSON | |
| `excluir_productos` | JSON | |
| `activo` | TINYINT(1) | |
| `eliminado` | TINYINT(1) | |

### `promociones_tipos` [NO DETECTADO: inferido]
| Columna | Tipo Estimado |
|---|---|
| `Id` | INT PK |
| `promocion_tipo` | VARCHAR(255) | Nombre del tipo: "2x1", "Descuento por cantidad", etc. |

### `cupones`
| Columna | Tipo Estimado |
|---|---|
| `Id` | INT AUTO_INCREMENT PK |
| `codigo` | VARCHAR(100) | |
| `tipo_descuento` | VARCHAR(50) | 'Porcentaje', 'Monto fijo', 'Envío gratis' |
| `valor` | DECIMAL(12,2) | |
| `aplica_a_tipo` | VARCHAR(50) | 'Toda la tienda', 'Categorías', 'Productos' |
| `aplica_a_categorias` | JSON | |
| `aplica_a_productos` | JSON | |
| `acumulable` | TINYINT(1) | Si es acumulable con promociones |
| `activo` | TINYINT(1) | |
| `eliminado` | TINYINT(1) | |
| `limite_fecha` / `fecha_desde` / `fecha_hasta` | DATE | [NO DETECTADO: posible] |

---

## 2.7 Dominio: Encuestas

### `encuestas`
| Columna | Tipo Estimado |
|---|---|
| `Id` | INT AUTO_INCREMENT PK |
| `encuesta` | VARCHAR(255) | Nombre |
| `activo` | TINYINT(1) | |
| `eliminado` | TINYINT(1) | |
| `cupon_id` | INT FK → `cupones.Id` | Cupón de regalo al completar |
| `fecha_desde` / `fecha_hasta` | DATE/DATETIME | [NO DETECTADO: posible] |

### `encuestas_preguntas`
| Columna | Tipo Estimado |
|---|---|
| `Id` | INT AUTO_INCREMENT PK |
| `encuesta_id` | INT FK → `encuestas.Id` |
| `pregunta` | VARCHAR(500) | |
| `tipo_pregunta` | VARCHAR(50) | 'texto', 'valoracion', 'checkbox', 'radio' |
| `opciones` | JSON | Array de opciones para checkbox/radio |

### `encuestas_envios`
| Columna | Tipo Estimado |
|---|---|
| `Id` | INT AUTO_INCREMENT PK |
| `encuesta_id` | INT FK |
| `hash` | VARCHAR(32) | Hash único del enlace |
| `tipo` | VARCHAR(50) | 'prospectos' o 'pedidos' |
| `origen_id` | INT | ID del prospecto o pedido |

### `encuestas_respuestas`
| Columna | Tipo Estimado |
|---|---|
| `Id` | INT AUTO_INCREMENT PK |
| `fecha` | DATETIME | |
| `pregunta` | VARCHAR(500) | Texto de la pregunta (denormalizado) |
| `respuesta` | TEXT | Respuesta (string o JSON) |
| `pregunta_id` | INT FK → `encuestas_preguntas.Id` |
| `encuesta_id` | INT FK → `encuestas.Id` |
| `envio_id` | INT FK → `encuestas_envios.Id` |

---

## 2.8 Dominio: Administración

### `administradores`
| Columna | Tipo Estimado |
|---|---|
| `Id` | INT AUTO_INCREMENT PK |
| `nombre` | VARCHAR(255) |
| `email` | VARCHAR(255) |
| `contrasenia` | VARCHAR(255) | **Sin hash detectado** (comparación directa en `login.php`) |
| `tipo_id` | INT FK → `administradores_tipos.Id` |
| `eliminado` | TINYINT(1) |
| `predeterminado` | TINYINT(1) | Vendedor por defecto para nuevos clientes |

### `administradores_tipos`
| Columna | Tipo Estimado |
|---|---|
| `Id` | INT AUTO_INCREMENT PK |
| `tipo` | VARCHAR(255) | Nombre del rol |
| `home` | VARCHAR(100) | Ruta default post-login |
| `clientes_propios` | TINYINT(1) | Solo ve sus clientes |
| `pedidos_propios` | TINYINT(1) | Solo ve sus pedidos |

### `secciones_admin`
| Columna | Tipo Estimado |
|---|---|
| `Id` | INT AUTO_INCREMENT PK |
| `seccion` | VARCHAR(255) | Nombre de la sección para permisos |

### `administradores_tipos_permisos`
| Columna | Tipo Estimado |
|---|---|
| `tipo_id` | INT FK → `administradores_tipos.Id` |
| `seccion_id` | INT FK → `secciones_admin.Id` |

---

## 2.9 Dominio: Contenido y Configuración

### `configuracion` (key-value)
| Columna | Tipo Estimado |
|---|---|
| `variable` | VARCHAR(255) PK |
| `valor` | TEXT | |

**Variables detectadas:**
- Conexiones: `mercadopago_access_token`, `modo_username`, `modo_password`, `modo_processor_code`, `modo_cc_code`, `padpio_user`, `padpio_password`, `padpio_host`
- Pagos: `datos_bancarios`, `cuotas_mercadopago`, `compra_minima_sin_impuestos`, `metodos_pago`
- Envíos: `envio_habilitado`, `retiro_por_sucursal`, `retiro_por_sucursal_informacion`, `nombre_fantasia`
- Web: `recaptcha_site_key`, `recaptcha_secret_key`, `marcas` (toggle), `tipos_cliente` (toggle), `formulario_devoluciones` (toggle), `email_compras`
- Gráfica: `logo_menu`, `logo_header`, `logo_footer`, `favicon`
- Contacto: `telefono_whatsapp`, `whatsapp`

### `slider`
| Columna | Tipo Estimado |
|---|---|
| `Id` | INT AUTO_INCREMENT PK |
| `titulo` | VARCHAR(255) | |
| `descripcion` | TEXT | |
| `foto` | VARCHAR(255) | |
| `link` | VARCHAR(500) | |
| `orden` | INT | |
| `activo` | TINYINT(1) | |
| `eliminado` | TINYINT(1) | |

### `banners`
| Columna | Tipo Estimado |
|---|---|
| `Id` | INT AUTO_INCREMENT PK |
| `titulo` | VARCHAR(255) | |
| `foto` | VARCHAR(255) | |
| `link` | VARCHAR(500) | |
| `ubicacion` | VARCHAR(100) | Dónde se muestra |
| `eliminado` | TINYINT(1) | |

### `banners_promociones_bancarias`
| Columna | Tipo Estimado |
|---|---|
| `Id` | INT PK |
| `banco` | VARCHAR(255) | |
| `foto` | VARCHAR(255) | |
| `activo` | TINYINT(1) | |
| `eliminado` | TINYINT(1) | |

### `preguntas_frecuentes`
| Columna | Tipo Estimado |
|---|---|
| `Id` | INT PK |
| `pregunta` | VARCHAR(500) |
| `respuesta` | TEXT |
| `orden` | INT |
| `eliminado` | TINYINT(1) |

### `secciones_adicionales`
| Columna | Tipo Estimado |
|---|---|
| `Id` | INT PK |
| `seccion` | VARCHAR(255) |
| `url` | VARCHAR(255) |
| `eliminado` | TINYINT(1) |

### `secciones_adicionales_contenido`
| Columna | Tipo Estimado |
|---|---|
| `Id` | INT PK |
| `seccion_id` | INT FK |
| `contenido` | TEXT / VARCHAR |
| `orden` | INT |

### `redes`
| Columna | Tipo Estimado |
|---|---|
| `Id` | INT PK |
| `red` | VARCHAR(255) | Nombre de la red |
| `link` | VARCHAR(500) | URL |
| `eliminado` | TINYINT(1) |

### `resenias`
| Columna | Tipo Estimado |
|---|---|
| `Id` | INT PK |
| `nombre` | VARCHAR(255) |
| `resenia` | TEXT |
| `puntaje` | TINYINT | 1-5 estrellas |
| `eliminado` | TINYINT(1) |

### `contacto` (mensajes del formulario)
| Columna | Tipo Estimado |
|---|---|
| `Id` | INT PK |
| `nombre` | VARCHAR(255) |
| `email` | VARCHAR(255) |
| `telefono` | VARCHAR(50) |
| `mensaje` | TEXT |
| `area_id` | INT FK → `contacto_areas.Id` |
| `fecha` | DATETIME |
| `leido` | TINYINT(1) |

### `contacto_areas`
| Columna | Tipo Estimado |
|---|---|
| `Id` | INT PK |
| `area` | VARCHAR(255) |
| `email` | VARCHAR(255) | Email destino |
| `eliminado` | TINYINT(1) |

### `devoluciones` (solicitudes)
| Columna | Tipo Estimado |
|---|---|
| `Id` | INT PK |
| `nombre` | VARCHAR(255) |
| `apellido` | VARCHAR(255) |
| `email` | VARCHAR(255) |
| `area` | VARCHAR(10) |
| `telefono` | VARCHAR(20) |
| `compra_id` | INT / VARCHAR | Número de pedido |
| `mensaje` | TEXT | Motivo de devolución |
| `fecha` | DATETIME |
| `estado` | VARCHAR(50) | [NO DETECTADO: posible] |

### `emails_plantillas`
| Columna | Tipo Estimado |
|---|---|
| `Id` | INT PK |
| `nombre` | VARCHAR(255) | Identificador: 'pedido_confirmacion_cliente', 'carrito_abandonado', etc. |
| `asunto` | VARCHAR(500) | |
| `cuerpo` | TEXT | HTML con placeholders `{{VAR}}` |
| `eliminado` | TINYINT(1) | |

### Otros archivos
| Tabla inferida | Uso |
|---|---|
| `header_secundario` | Configuración del header secundario |
| `fondo_login` | `Id`, `extension` (imagen de fondo) |
| `carouseles` | Configuración de carouseles del home |
| `logos` | Configuración de logos [NO DETECTADO: posible en configuracion] |
| `home_order` | Orden de módulos del home |

---

## 2.10 Relaciones Clave (Foreign Keys Implícitas)

```
productos.marca_id → marcas.Id
productos_categorias.producto_id → productos.Id
productos_categorias.categoria_id → categorias.Id
productos_variantes.producto_id → productos.Id
productos_variantes.propiedad1_id → propiedades_valores.Id
productos_variantes.propiedad2_id → propiedades_valores.Id
productos_variantes.propiedad3_id → propiedades_valores.Id
productos_variantes_stock.(producto_id, variante_id, sucursal_id) → productos, productos_variantes, sucursales
productos_variantes_precios.(producto_id, variante_id, lista_id) → productos, productos_variantes, listas
productos_propiedades_valores.producto_id → productos.Id
productos_propiedades_valores.valor_id → propiedades_valores.Id
propiedades_valores.propiedad_id → propiedades.Id
productos_tags.producto_id → productos.Id
productos_tags.tag_id → tags.Id

pedidos.cliente_id → clientes.Id
pedidos.lista_id → listas.Id
pedidos.sucursal_id → sucursales.Id
pedidos.provincia_id → provincias.Id
pedidos.localidad_id → localidades.Id
pedidos_detalle.pedido_id → pedidos.Id
pedidos_detalle.promocion_id → promociones.Id
pedidos_emails.pedido_id → pedidos.Id

clientes.tipo_id → clientes_tipos.Id
clientes.vendedor_id → administradores.Id
clientes.lista_id → listas.Id
clientes.tipo_comprobante_id → clientes_tipos_comprobante.Id
clientes.situacion_fiscal_id → clientes_situaciones.Id
clientes_direcciones.cliente_id → clientes.Id
clientes_direcciones.localidad_id → localidades.Id
clientes_direcciones.provincia_id → provincias.Id
clientes_favoritos.cliente_id → clientes.Id
clientes_favoritos.producto_id → productos.Id

promociones.aplica_a_productos → productos[].Id (JSON array)

administradores.tipo_id → administradores_tipos.Id
administradores_tipos_permisos.tipo_id → administradores_tipos.Id
administradores_tipos_permisos.seccion_id → secciones_admin.Id

envios_propios.provincia_id → provincias.Id
localidades.provincia_id → provincias.Id
codigos_postales.localidad_id → localidades.Id

encuestas_preguntas.encuesta_id → encuestas.Id
encuestas_envios.encuesta_id → encuestas.Id
encuestas_respuestas.encuesta_id → encuestas.Id
encuestas_respuestas.pregunta_id → encuestas_preguntas.Id
encuestas_respuestas.envio_id → encuestas_envios.Id
```

---

## Observaciones Críticas para la Migración

1. **Contraseñas en MD5:** `clientes.contrasenia` usa md5. Migrar a bcrypt en NestJS; implementar re-hash en primer login post-migración.
2. **Contraseñas admin en texto plano:** `administradores.contrasenia` se compara directamente (`===`) sin hash.
3. **JSON en columnas:** `clientes_tipos.marcas`, `promociones.aplica_a_productos`, `envios_propios.localidades`, `pedidos.zipnova_json` almacenan JSON. En MySQL 5.7+ son columnas JSON o TEXT.
4. **Soft deletes ubicuos:** Prácticamente todas las tablas usan `eliminado` (0/1). Los SELECTs siempre filtran `WHERE eliminado='0'`.
5. **Multi-sucursal:** `sucursal_id` en pedidos, stock, y cliente separa el inventario y ventas por sucursal.
6. **Multi-lista de precios:** `lista_id` en cliente, pedidos, y `productos_variantes_precios` permite precios diferenciados por perfil de cliente.
7. **Restricción de marcas por cliente:** `clientes.marcas` y `clientes_tipos.marcas` limitan qué productos ve un cliente en el catálogo.
