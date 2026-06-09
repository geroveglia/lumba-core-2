# 01 — Feature Prioritization (MVP, Fases y Features No Migradas)

> **Proyecto:** Lumba Ecommerce (Brownfield — migración PHP vanilla → NestJS + Tailwind)
> **Fecha:** 2026-06-08
> **Rol:** Product Owner
> **Modelo:** deepseek-v4-pro
> **Nivel de confianza global:** ALTA
> **Fuente:** Outputs del System Auditor + Functional Spec

---

## Criterios de Priorización

| Criterio | Peso | Descripción |
|---|---|---|
| ¿Bloquea la operación? | Alto | Sin esto, un cliente no puede vender |
| ¿Impacta la conversión? | Alto | Afecta directamente las ventas |
| ¿Es requisito legal/fiscal? | Alto | Facturación, datos fiscales obligatorios |
| ¿Lo usan todos los clientes? | Medio | Si todos los branches lo tienen activo |
| ¿Complejidad de migración? | Bajo | Features simples se priorizan si aportan mucho valor |
| ¿Existe workaround? | Medio | Si hay forma de operar sin esta feature temporalmente |

---

## MVP — Imprescindible para Operar

> **Definición de MVP:** Un cliente (ej: cancat, pantole) debe poder operar su tienda completa con este alcance: publicar productos, recibir pedidos, cobrar, enviar, gestionar desde admin y manejar sus clientes. Sin esto, no se puede reemplazar el sistema actual.

### Catálogo y Productos

| # | Feature | Justificación | Esfuerzo estimado |
|---|---|---|---|
| MVP-01 | Grilla de productos con filtros (categoría, marca, tag, precio, propiedades) | Es la vidriera de la tienda. Sin esto no hay navegación. | Alto |
| MVP-02 | Página de detalle de producto con variantes, precio según lista, stock | Página de conversión. Sin esto no se vende. | Alto |
| MVP-03 | Restricción de marcas por cliente | Los clientes mayoristas solo deben ver sus marcas asignadas. Si no, ven productos que no pueden comprar → fricción/soporte. | Medio |
| MVP-04 | Categorías con jerarquía (árbol) | Navegación principal del sitio. | Medio |
| MVP-05 | Marcas y Tags con filtro | Navegación secundaria. La mayoría de los clientes las usa. | Bajo |

### Carrito de Compras

| # | Feature | Justificación | Esfuerzo estimado |
|---|---|---|---|
| MVP-06 | Agregar al carrito con validación server-side de stock y precio | Anti-tampering. Seguridad básica de la transacción. | Medio |
| MVP-07 | Gestión de carrito (cantidades, eliminar, resumen con totales) | Core del flujo de compra. | Medio |
| MVP-08 | Aplicación de promociones automáticas (tipo 00, 0) en carrito | Si hay promos configuradas y no se aplican, los precios son incorrectos → pérdida de ventas o margen. | Alto |
| MVP-09 | Aplicación de cupones en carrito | Mecanismo de descuento usado por marketing. | Medio |

### Checkout (4 pasos)

| # | Feature | Justificación | Esfuerzo estimado |
|---|---|---|---|
| MVP-10 | Checkout paso 1: Datos personales con campos dinámicos según tipo de cliente | Sin esto no se completa una compra. Los tipos de cliente condicionan precios, IVA y facturación. | Alto |
| MVP-11 | Checkout paso 2: Forma de entrega (sucursal, envío propio, Zipnova) + direcciones | Sin esto no se sabe cómo entregar el pedido. | Alto |
| MVP-12 | Checkout paso 3: Medio de pago según perfil | Selección del método de pago. | Medio |
| MVP-13 | Checkout paso 4: Confirmación, creación de pedido, transacción MySQL, ruteo por pago | Cierre de la compra. Sin esto no hay pedido. | Alto |
| MVP-14 | Compra como invitado con registro automático | Muchos clientes no quieren crear cuenta. Bloquear esto = perder ventas. | Medio |
| MVP-15 | Validación de compra mínima por tipo de cliente | Regla de negocio que protege márgenes. | Bajo |
| MVP-16 | Datos de facturación separables de envío | Requisito fiscal/empresarial. | Medio |

### Cuenta del Cliente

| # | Feature | Justificación | Esfuerzo estimado |
|---|---|---|---|
| MVP-17 | Registro con activación por email | Necesario para clientes que quieren cuenta. | Medio |
| MVP-18 | Login con bcrypt (reemplazar md5) | Seguridad básica. No negociable. | Medio |
| MVP-19 | Recuperación de contraseña | Soporte mínimo esperado. | Bajo |
| MVP-20 | Historial de pedidos con detalle | Cliente necesita ver sus compras y estados. | Medio |
| MVP-21 | Direcciones guardadas | Re-compra sin re-ingresar datos → conversión. | Bajo |

### Pagos

| # | Feature | Justificación | Esfuerzo estimado |
|---|---|---|---|
| MVP-22 | MercadoPago (SDK oficial Node.js, con validación de webhooks) | Medio de pago más usado en Argentina. Sin esto no se cobra online. **Crítico: validar firma de webhooks.** | Alto |
| MVP-23 | Transferencia bancaria con subida de comprobante | Alternativa de pago. Usada por clientes que no quieren/pueden usar MP. | Medio |
| MVP-24 | Efectivo (contra entrega) | Opción simple. | Bajo |

### Envíos

| # | Feature | Justificación | Esfuerzo estimado |
|---|---|---|---|
| MVP-25 | Envíos propios con reglas de zona y envío gratis | Logística básica. Configurable por cliente. | Medio |
| MVP-26 | Retiro por sucursal | Opción gratuita que muchos clientes usan. | Bajo |
| MVP-27 | Zipnova: cotización, selección y confirmación de envío | Si algún cliente depende de Zipnova, es crítico. **Corregir bug del webhook de tracking.** | Alto |
| MVP-28 | Reglas de envío gratis (global, por método, cupón) | Expectativa del consumidor actual. | Bajo |

### Admin Panel

| # | Feature | Justificación | Esfuerzo estimado |
|---|---|---|---|
| MVP-29 | Login admin con bcrypt + sistema de permisos granular | **Urgente**: contraseñas en texto plano hoy. Permisos por sección es indispensable. | Alto |
| MVP-30 | Dashboard con KPIs básicos (ventas del mes, pedidos) | Monitoreo mínimo del negocio. | Medio |
| MVP-31 | CRUD de productos (nombre, descripción, marca, categorías, tags, propiedades, fotos) | Sin esto no se puede publicar ni mantener el catálogo. | Alto |
| MVP-32 | CRUD de variantes, precios por lista, stock por sucursal | Core de la gestión de inventario. | Alto |
| MVP-33 | CRUD de categorías (nestable) | Organización del catálogo. | Medio |
| MVP-34 | CRUD de marcas, tags, propiedades y valores | Datos maestros del catálogo. | Medio |
| MVP-35 | Gestión de pedidos (listado, detalle, cambio de estados) | Operación diaria del negocio. Sin esto no se gestionan ventas. | Alto |
| MVP-36 | Gestión de clientes con perfiles (tipos, comprobantes, situaciones fiscales) | Administración de la base de clientes y sus reglas de negocio. | Alto |
| MVP-37 | Configuración general (pestañas: connect, contenido, envíos, pagos, productos, reglas de negocio, web, estilos) | Motor de personalización por tenant. | Alto |
| MVP-38 | Gestión de envíos propios | Configuración de logística. | Bajo |

### Multi-Tenant e Infraestructura

| # | Feature | Justificación | Esfuerzo estimado |
|---|---|---|---|
| MVP-39 | Base de datos por tenant con tenant switching (dominio/env) | Aislamiento de datos. **Reemplaza branches Git.** | Alto |
| MVP-40 | Configuración tipada por tenant (credenciales en .env, settings en DB) | **Crítico de seguridad**: API keys no pueden estar en DB ni hardcodeadas. | Alto |
| MVP-41 | Sistema de emails transaccionales con plantillas (Nodemailer) | Emails de pedido, registro, recuperación. | Medio |
| MVP-42 | Theming por tenant (logos, colores, tipografías) | Cada cliente tiene su identidad visual. | Medio |

---

### Resumen MVP: 42 features | Esfuerzo estimado: ~30 días hábiles (a $50/día = $1,500 USD)

---

## Fase 2 — Alto Valor, No Bloqueante

> Features que agregan valor significativo pero sin las cuales se puede operar. Se construyen después del MVP, idealmente dentro de los 15-30 días siguientes.

### Mejoras de Conversión y UX

| # | Feature | Justificación | Dependencia |
|---|---|---|---|
| F2-01 | Búsqueda full-text con Elasticsearch | Mejora discovery de productos → más ventas. | MVP completo |
| F2-02 | Galería de imágenes con zoom en producto | Mejora experiencia de producto → conversión. | MVP completo |
| F2-03 | Selectores visuales de variantes (no solo dropdowns) | Reduce errores al seleccionar talle/color. | MVP completo |
| F2-04 | Carrito persistente en DB (cross-device, post-sesión) | Recuperación de carrito > ventas recuperadas. | MVP completo |
| F2-05 | Mini-carrito en header con vista previa | UX estándar de ecommerce moderno. | MVP completo |
| F2-06 | Checkout con progress indicator y resumen siempre visible | Reduce abandono en checkout. | MVP completo |
| F2-07 | Magic link en vez de contraseña para nuevos clientes (compra como invitado) | Mejor UX que email con contraseña random. | MVP completo |
| F2-08 | Google/redes sociales login | Baja fricción de registro. | MVP cuenta cliente |

### Mejoras de Admin

| # | Feature | Justificación | Dependencia |
|---|---|---|---|
| F2-09 | Editor WYSIWYG para descripciones de producto | Contenido rico sin saber HTML. | MVP admin |
| F2-10 | Importación/Exportación Excel de productos | Migración de datos masiva entre sistemas. | MVP admin |
| F2-11 | Sincronización PadPio (stock + precios) con job scheduling | Sincronización automática de inventario desde ERP. | MVP PadPio |
| F2-12 | Alertas de stock bajo | Prevención de quiebres de stock. | MVP stock |
| F2-13 | Timeline visual de estados del pedido en admin y cliente | Trazabilidad de cada pedido. | MVP pedidos |
| F2-14 | Bulk actions en admin (activar/desactivar, cambiar categoría) | Productividad del admin. | MVP admin |
| F2-15 | 2FA para administradores | Seguridad del panel de control. | MVP login admin |

### Mejoras de Pagos y Envíos

| # | Feature | Justificación | Dependencia |
|---|---|---|---|
| F2-16 | Modo (SDK oficial Node.js, con validación de webhooks) | Segundo medio de pago online. Crítico si algún cliente lo usa como único medio. **Corregir fecha de nacimiento hardcodeada.** | MVP pagos |
| F2-17 | Cuotas con detalle de costo en checkout | Transparencia → confianza → conversión. | MVP MercadoPago |
| F2-18 | Mapa de sucursales/puntos de retiro en checkout | Mejor UX para seleccionar punto de retiro. | MVP envíos |

### Mejoras de Features Existentes

| # | Feature | Justificación | Dependencia |
|---|---|---|---|
| F2-19 | Carritos abandonados: vista admin + cron de recuperación | Recuperación de ventas perdidas. | MVP pedidos |
| F2-20 | Favoritos (wish list) | Engagement y retargeting. | MVP cuenta cliente |
| F2-21 | Devoluciones con flujo de estados completo | Gestión profesional de post-venta. | MVP admin |
| F2-22 | Reseñas reales de clientes sobre productos | Social proof → conversión. | MVP pedidos |
| F2-23 | Productos relacionados automáticos (categoría/marca) | Cross-selling → ticket promedio. | MVP catálogo |
| F2-24 | Slider, banners y home order configurables | Home page atractiva y personalizable. | MVP admin |
| F2-25 | Secciones de contenido adicional (CMS básico) | Páginas legales, institucionales. | MVP admin |

---

### Resumen Fase 2: 25 features | Esfuerzo estimado: ~15-20 días hábiles

---

## Fase 3 — Nice to Have

> Features que agregan valor pero pueden esperar. El sistema es completamente funcional sin ellas.

| # | Feature | Justificación |
|---|---|---|
| F3-01 | Chatbot IA con OpenAI (API key por tenant, cache de knowledge, rate limiting) | Feature diferencial. Costo por request requiere evaluación por cliente. No bloquea operación. |
| F3-02 | Encuestas post-compra con cupón de regalo | Engagement y feedback. Valioso pero no urgente. |
| F3-03 | Predicciones y reportes avanzados en dashboard | Business intelligence. |
| F3-04 | Segmentación de clientes en admin | Marketing. |
| F3-05 | Exportación de facturas en PDF | Valor administrativo. |
| F3-06 | Integración Dicomere (ERP) | Requiere investigación adicional para determinar método de conexión. |
| F3-07 | Variantes con N propiedades (eliminar hardcodeo de 3) | Flexibilidad para catálogos complejos. |
| F3-08 | Promociones con stacking rules explícitas y simulador | Poder para marketing. |
| F3-09 | Filtros guardables en admin | Productividad. |
| F3-10 | Notificaciones push al cliente (cambio de estado de pedido) | UX post-compra. |
| F3-11 | Historial de actividad de administradores | Auditoría y seguridad. |
| F3-12 | Subida de imágenes con drag-and-drop y recorte | UX de admin. |

---

### Resumen Fase 3: 12 features

---

## Features que NO se Migran

> Ninguna feature del sistema actual se descarta por completo. Sin embargo, hay implementaciones específicas que NO se replican tal cual:

| Feature Actual | Qué NO se migra | Qué se hace en su lugar | Impacto en clientes |
|---|---|---|---|
| **Contraseñas en md5** | No se migra el hash md5. | bcrypt con re-hash en primer login post-migración. | Los clientes deberán resetear su password o se hará migración automática con re-hash. |
| **Contraseñas admin en texto plano** | No se migra comparación directa. | bcrypt desde día 1. | Nuevas contraseñas para admins. |
| **API Key OpenAI hardcodeada** | No se migra hardcodeo. | Variables de entorno por tenant. | Transparente para el cliente. |
| **Conexión MSSQL vía `sqlsrv` (PHP, Windows-only)** | No se migra driver PHP. | `node-mssql` (cross-platform). | Transparente si se configura correctamente. |
| **`llamadoCurl()` genérico para pagos** | No se migra proxy interno. | SDKs oficiales (MercadoPago, Modo). | Mejor trazabilidad y seguridad. |
| **Branches de Git como tenant switching** | No se migra modelo de branches. | Tenant por variable de entorno/dominio. | Setup inicial diferente pero más simple a largo plazo. |
| **Configuración key-value en tabla `configuracion`** | No se migra key-value genérico. | ConfigModule tipado de NestJS. | Los valores se migran, la UI del admin mejora. |
| **PHPMailer** | No se migra librería PHP. | Nodemailer + MJML. | Templates se reconstruyen en nuevo formato. |
| **Template Velzon (Bootstrap + jQuery)** | No se migra UI legacy del admin. | Tailwind CSS + componentes headless. | Admin completamente rediseñado. |
| **Validación con `===` en login admin** | No se migra. | bcrypt compare. | Más seguro. |

---

## Qué Pasa con los Clientes que Usan Features Post-MVP

| Feature post-MVP | Clientes afectados | Plan de contingencia |
|---|---|---|
| Chatbot IA | Todos (siempre activo en el frontend) | Se desactiva el widget durante MVP. Se comunica a clientes que vuelve en Fase 3. No bloquea ventas. |
| Encuestas | Clientes con encuestas activas | Se pausan. Las respuestas existentes se preservan en la DB migrada. Se reactivan en Fase 3. |
| Carritos abandonados (cron) | Clientes con `cron_carritos_abandonados > 0` | El cron no corre. Los pedidos incompletos quedan visibles en admin. Se reactiva en Fase 2. |
| Dicomere | Cliente específico (dicomere) | Se requiere research adicional. Si es crítico para ese cliente, se escala a Gero para evaluar incluir en MVP. |
| Modo | Clientes que usan Modo como medio de pago | **Atención**: si algún cliente solo tiene Modo habilitado (sin MP), debe moverse a MVP. Revisar con cada cliente. |

---

## Timeline Propuesto

```
MVP (Semanas 1-6):      ████████████████████████████████ 42 features
Fase 2 (Semanas 7-10):  ████████████████████ 25 features  
Fase 3 (Semanas 11+):   ██████████ 12 features (continuo)
```

**Costo total estimado MVP:** ~$1,500 USD (30 días hábiles × $50/día)
**Costo total Fase 2:** ~$750-$1,000 USD (15-20 días hábiles)
**Costo total Fase 3:** ~$500-$600 USD (10-12 días hábiles)

---

## Riesgos y Dependencias

| Riesgo | Mitigación |
|---|---|
| Zipnova API no documentada → complejidad subestimada | Hacer spike técnico en semana 1 para validar SDK/documentación |
| Modo es crítico para algún cliente | Validar con cada cliente qué medios de pago usa. Si Modo es único medio → subir a MVP |
| PadPio requiere Windows → `node-mssql` puede no funcionar igual | Probar conexión con `tedious` en semana 1 |
| Clientes reacios a cambiar UI del admin | Mostrar prototipo de Tailwind CSS temprano para feedback |
| Migración de contraseñas md5 → bcrypt | Implementar estrategia de re-hash: al hacer login con md5, verificar contra hash md5 legacy, re-hashear con bcrypt y guardar |

---

> **Confianza de este documento:** ALTA en priorización MVP y Fase 2. MEDIA en estimaciones de esfuerzo (dependen de definición técnica detallada). BAJA en Fase 3 (alcance puede cambiar según feedback post-MVP).
