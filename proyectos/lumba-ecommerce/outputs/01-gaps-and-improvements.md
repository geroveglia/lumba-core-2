# 01 — Gaps, Improvements & Antipatterns

> **Proyecto:** Lumba Ecommerce (Brownfield — migración PHP vanilla → NestJS + Tailwind)
> **Fecha:** 2026-06-08
> **Rol:** Product Owner
> **Modelo:** deepseek-v4-pro
> **Nivel de confianza global:** ALTA (basado en hallazgos del System Auditor)
> **Fuentes:** Los 5 outputs del System Auditor + análisis propio del PO

---

## 1. Gaps: Lo Que Falta en el Sistema Actual

> Funcionalidades que el sistema debería tener y no tiene. No son bugs — son ausencias que el nuevo sistema debe cubrir.

### 1.1 Gaps de Seguridad (Críticos)

| Gap | Severidad | Evidencia del Auditor | Recomendación para NestJS |
|---|---|---|---|
| **Sin validación de firma en webhooks de pago** | 🔴 Crítico | `mp_ipn.php` y `modo_webhook.php` confían ciegamente en el body JSON. No verifican `x-signature`. | Implementar middleware de validación de firma para cada proveedor de pago. Rechazar requests sin firma válida. |
| **Contraseñas de clientes en MD5 sin salt** | 🔴 Crítico | `clientes.contrasenia` hasheada con `md5($password)`. Sin salt. | bcrypt con salt automático. Estrategia de migración: al primer login post-migración, verificar contra hash MD5 legacy y re-hashear con bcrypt. |
| **Contraseñas admin en TEXTO PLANO** | 🔴 Crítico | `admin/login.php`: `$rArray['contrasenia'] === $contrasenia`. | bcrypt desde día 1. Forzar cambio de contraseña en primer login post-migración. |
| **API Key de OpenAI hardcodeada en código** | 🔴 Crítico | `ajax/chat_handler.php` contiene la key en texto plano en el archivo. | Variables de entorno por tenant (`.env`). Nunca en código ni en DB. |
| **Credenciales de pago en tabla `configuracion` sin encriptar** | 🔴 Crítico | `mercadopago_access_token`, `modo_username`, `modo_password`, `padpio_user`, `padpio_password`, `recaptcha_secret_key` en tabla key-value. | Secretos en `.env` o vault (HashiCorp Vault, Infisical, etc.). Settings de negocio en DB. |
| **Sin rate limiting en login/registro/recuperación** | 🟠 Alto | No se detectó ningún mecanismo de rate limiting en `account_signin.php`, `account_register.php`, `account_recover.php`. | `@nestjs/throttler` en endpoints de autenticación. Rate limit por IP + email. |
| **Sin protección CSRF** | 🟠 Alto | No se detectaron tokens CSRF en formularios ni validación server-side. | CSRF protection nativo de NestJS + SameSite cookies. |
| **Sin Content Security Policy (CSP)** | 🟡 Medio | No se detectaron headers de seguridad HTTP. | Helmet middleware en NestJS con CSP configurable. |

### 1.2 Gaps Funcionales

| Gap | Valor de Negocio | Descripción | Recomendación |
|---|---|---|---|
| **Sin búsqueda real (solo LIKE)** | Alto | `get_products.php` usa `LIKE '%texto%'` que no escala, no maneja typos, no tiene ranking de relevancia. | Elasticsearch o PostgreSQL full-text search (`tsvector`). Mínimo: índice FULLTEXT en MySQL. |
| **Sin carrito persistente** | Alto | El carrito vive en `$_SESSION`. Si la sesión expira o el cliente cambia de dispositivo, pierde todo. | Carrito en DB (`carritos` + `carritos_items`). Asociado a cliente logueado o a token anónimo (JWT o cookie). |
| **Sin tracking de envío funcional** | Alto | Bug en `zn_webhook.php` rompe el tracking. Pero además no hay tracking visual para el cliente. | Reparar webhook. Agregar página de tracking pública con timeline. Notificaciones proactivas. |
| **Sin página de agradecimiento post-compra para MP/Modo** | Medio | Cuando el cliente es redirigido a MP/Modo, no hay una pantalla clara de "gracias, estamos procesando tu pago". | Página de confirmación intermedia con instrucciones claras y polling de estado. |
| **Sin multi-idíoma** | Medio | Sistema 100% en español. Sin estructura para i18n. | Preparar arquitectura con `nestjs-i18n` desde el inicio aunque solo se use español. Facilita expansión futura. |
| **Sin API REST** | Alto | Todo el frontend se renderiza server-side. No hay API que pueda ser consumida por mobile apps o headless frontends. | NestJS naturalmente expone API REST. Separar backend (API) de frontend (Next.js/Nuxt o SPA). |
| **Sin tests automatizados** | Alto | No se detectó ningún archivo de test en los ~350 archivos PHP. Cero cobertura. | Jest + Supertest para tests e2e. Unit tests para lógica de negocio crítica (pricing, cupones, stock). |
| **Sin logs estructurados** | Alto | No hay sistema de logging. Errores probablemente van a `error_log` de PHP. | Winston/Pino con niveles, correlación IDs, y almacenamiento centralizado. |
| **Sin health checks** | Medio | No hay endpoint de monitoreo. | `@nestjs/terminus` para health checks de DB, Redis, APIs externas. |
| **Sin documentación de API** | Medio | No hay Swagger/OpenAPI. | `@nestjs/swagger` con decoradores. Auto-generado del código. |

### 1.3 Gaps de UX

| Gap | Descripción | Recomendación |
|---|---|---|
| **Sin responsive design nativo** | El sistema actual depende del template Velzon. No se auditó la calidad responsive. | Tailwind CSS mobile-first. Garantizar que checkout fluya en mobile (60%+ tráfico ecommerce hoy). |
| **Sin feedback de carga** | No se detectaron loading states ni skeleton screens en el análisis. | Loading skeletons en grillas, spinners en botones de acción, optimistic UI donde sea seguro. |
| **Sin validación en tiempo real** | Las validaciones parecen ser server-side (postback). | Validación client-side con Zod/Yup + server-side como respaldo. |
| **Sin accesibilidad (a11y)** | No se detectaron atributos ARIA, roles, ni navegación por teclado. | WCAG 2.1 AA como estándar mínimo. Componentes headless accesibles (Radix UI, Headless UI). |
| **Sin PWA / offline** | Sin service worker ni capacidades offline. | Service worker para cache de assets. No es MVP pero la arquitectura debe permitirlo. |

---

## 2. Oportunidades de Mejora

> No son gaps (el sistema funciona sin esto), pero representan saltos de calidad significativos.

### 2.1 Mejoras de Arquitectura

| Oportunidad | Situación Actual | Propuesta | Beneficio |
|---|---|---|---|
| **Headless ecommerce** | Frontend y backend acoplados en PHP monolítico. | NestJS como API backend + frontend separado (Next.js o SPA con React/Vue). | Permite mobile apps nativas, kioskos, múltiples frontends consumiendo la misma API. Escalabilidad independiente. |
| **Event-driven para post-compra** | Acciones post-pago (emails, stock, envíos) ejecutadas sincrónicamente en el webhook. | Eventos: `payment.confirmed` → listeners independientes para emails, stock, envío, notificaciones. | Desacoplamiento, reintentos individuales, trazabilidad. Si falla el email no se pierde el descuento de stock. |
| **Cache de catálogo** | Cada request a la grilla ejecuta una query compleja con múltiples JOINs. | Redis cache para queries de catálogo. Invalidación por evento (producto actualizado). | Performance de navegación. Menos carga en DB. |
| **Job queue para tareas asíncronas** | `cron/carritos_abandonados.php` debe ejecutarse vía cron del servidor. Sincronización PadPio es manual (botón en admin). | BullMQ con Redis. Jobs programados para sincronización PadPio, carritos abandonados, envío de emails, limpieza de sesiones. | Confiabilidad, reintentos, monitoreo de jobs fallidos. |
| **API versioning** | Sin versionado. | `@nestjs/versioning` — URI versioning (`/api/v1/...`). | Permite evolucionar la API sin romper clientes existentes. |
| **Database migrations** | Sin sistema de migraciones. Schema inferido de queries. | TypeORM migrations o Knex. Migraciones versionadas y reversibles. | Trazabilidad del schema. Deploy automatizado. |

### 2.2 Mejoras de Negocio

| Oportunidad | Situación Actual | Propuesta | Beneficio |
|---|---|---|---|
| **Pricing engine independiente** | Lógica de precios (promos, cupones, listas) dispersa entre `get_products.php`, `cart.php`, `cupon.php`, `buscarPromoPorProducto()`. | Servicio de pricing dedicado: recibe (producto, cliente, cupón) → devuelve precio final con breakdown de descuentos. | Testeable, mantenible, reutilizable en carrito, checkout, API, admin preview. |
| **Checkout simplificado** | 4 pasos separados con recarga de página entre cada uno. | Single-page checkout con pasos como tabs/steps. Toda la información visible y editable en una página. | Reduce abandono. Estándar moderno (Shopify, Mercado Libre). |
| **Motor de promociones avanzado** | Solo 2 tipos reales: `00` (porcentaje PadPio) y `0` (descuento por cantidad). Sin reglas de stacking explícitas. | Reglas tipadas: "2x1", "3x2", "20% en 2da unidad", "si comprás A + B → descuento en C", "envío gratis + 10% off". Stacking configurable por prioridad. | Poder de marketing sin tocar código. |
| **Reseñas de productos reales** | Testimonios manuales cargados por admin. Sin verificación de compra. | Sistema de reseñas verificadas: email post-compra → formulario de reseña → moderación → publicación. Con fotos. | Social proof real → conversión. |
| **Dashboard con KPIs accionables** | KPIs básicos: ventas del mes vs mes anterior. | KPIs avanzados: tasa de conversión del checkout, productos más vistos vs más vendidos, clientes recurrentes, ticket promedio por categoría, tasa de abandono. | Decisiones data-driven. |
| **Catálogo con SEO avanzado** | Meta tags básicos vía `inc/seo.php`. Sin structured data. | Schema.org Product, BreadcrumbList, Organization. Sitemap.xml automático. Open Graph completo. Canonical URLs. | Tráfico orgánico. |

### 2.3 Mejoras de Operación

| Oportunidad | Situación Actual | Propuesta | Beneficio |
|---|---|---|---|
| **Deploy automatizado** | Sin CI/CD detectado. | GitHub Actions: test → build → deploy por tenant. | Deploy sin errores manuales. Rollback instantáneo. |
| **Monitoreo y alertas** | Sin monitoring. | Health checks + alertas: webhook de pago caído, stock negativo, error 500, latencia alta. | Detección proactiva de problemas. |
| **Backups automatizados** | No detectado. | Backups diarios de DB por tenant con retención configurable. | Disaster recovery. |
| **Feature flags** | No existen. | Feature flags por tenant: activar/desactivar features sin deploy (chatbot, encuestas, Modo). | Deploy más seguro. Rollout progresivo. |

---

## 3. Antipatrones Detectados (NO Replicar)

> Problemas del sistema actual que son errores de diseño o implementación. El nuevo sistema debe evitarlos explícitamente.

### 3.1 Antipatrones de Seguridad

| Antipatrón | Evidencia | Por Qué es Malo | Cómo se Evita en NestJS |
|---|---|---|---|
| **Secretos en código fuente** | API key OpenAI hardcodeada en `ajax/chat_handler.php`. | Cualquiera con acceso al repo tiene la key. Si el repo es público o se filtra, la key queda expuesta. | Variables de entorno (`process.env`). `.env` en `.gitignore`. Secrets manager para producción. |
| **Contraseñas con hash débil** | MD5 sin salt en clientes. | MD5 es computable en milisegundos con hardware moderno. Rainbow tables rompen hashes sin salt. | bcrypt con 12+ rounds de salt. Argon2 para máxima seguridad. Re-hash strategy. |
| **Contraseñas sin hash** | Texto plano en administradores. | Si la DB se filtra, todas las cuentas admin quedan expuestas inmediatamente. | bcrypt siempre. No hay excepción. |
| **Webhooks sin autenticación** | `mp_ipn.php` y `modo_webhook.php` no validan origen del request. | Cualquiera puede enviar un POST falso marcando un pedido como pagado sin haber pagado. | Validar `x-signature` (MP), `x-modo-signature` (Modo) con el secreto del provider. Middleware reutilizable. |
| **Credenciales de terceros en DB** | Access tokens de MP, credenciales Modo y PadPio en tabla `configuracion` sin encriptar. | Un admin con acceso a la DB o al panel de configuración ve todas las credenciales. | Secrets en `.env` o vault. El panel de configuración muestra "••••••••" con opción de cambiar. |
| **Sin HTTPS enforcement a nivel aplicación** | `.htaccess` fuerza HTTPS, pero es responsabilidad de Apache. | Si el deploy no incluye `.htaccess`, el sitio podría correr en HTTP. | NestJS middleware que redirige HTTP → HTTPS. HSTS header. |

### 3.2 Antipatrones de Arquitectura

| Antipatrón | Evidencia | Por Qué es Malo | Cómo se Evita en NestJS |
|---|---|---|---|
| **Monolito acoplado** | ~350 archivos PHP sin separación de capas. Lógica de negocio, queries SQL y HTML en el mismo archivo. | Imposible testear. Cambios en HTML pueden romper queries. Reutilización nula. | Arquitectura modular NestJS: controllers (HTTP), services (lógica), repositories (DB). Cada capa independiente. |
| **Lógica de negocio dispersa** | Pricing en `get_products.php`, `cart.php`, `cupon.php`, `funciones.php::buscarPromoPorProducto()`. | Si hay un bug en pricing, hay que buscar en 4+ archivos. Imposible garantizar consistencia. | Servicio dedicado `PricingService` con métodos claros: `calculatePrice()`, `applyPromotions()`, `applyCoupon()`. |
| **Estado en sesión PHP** | Todo el estado (carrito, checkout, cliente, cupón, chat) en `$_SESSION`. | No escala horizontal. Sesiones PHP se pierden al reiniciar servidor. Imposible compartir entre servicios. | JWT para autenticación. Carrito en DB. Estado de checkout en DB. Sesiones solo para datos volátiles no críticos. |
| **Transacciones manuales** | `BEGIN TRANSACTION`, `COMMIT`, `ROLLBACK` escritos a mano en `checkout_4.php`. | Propenso a errores (olvidar commit/rollback). Sin manejo de deadlocks. | TypeORM `@Transaction()` o Unit of Work pattern. Manejo automático de commit/rollback. |
| **Multi-tenant vía branches Git** | Cada cliente es un branch del repo con su propio `inc/db.php`. | Sincronizar features entre branches es una pesadilla. Divergencia de código inevitable. Deploy manual por branch. | Tenant switching por dominio o variable de entorno. Mismo código para todos. DB diferente por tenant. |
| **Sin separación frontend/backend** | PHP renderiza HTML + procesa lógica. AJAX endpoints mezclados con endpoints de página. | El frontend no puede evolucionar sin tocar backend. Imposible hacer SPA o mobile app. | API REST en NestJS. Frontend separado (Next.js recomendado). Contrato de API claro. |
| **Dependencia Windows (PadPio)** | `sqlsrv` solo funciona en Windows. Limita el deploy a servidores Windows. | Vendor lock-in. Mayor costo de hosting. Menos herramientas de DevOps. | `node-mssql` (tedious) funciona en Linux. La app puede deployarse en cualquier plataforma. |

### 3.3 Antipatrones de Datos

| Antipatrón | Evidencia | Por Qué es Malo | Cómo se Evita en NestJS |
|---|---|---|---|
| **Sin migraciones documentadas** | Schema inferido de queries SQL. Sin archivos de migración. | Imposible saber qué versión de schema tiene cada tenant. Actualizaciones manuales y riesgosas. | TypeORM migrations. Cada cambio de schema es un archivo versionado. `migration:run` por tenant. |
| **JSON en columnas sin validación** | `clientes_tipos.marcas` (JSON array), `envios_propios.localidades` (JSON), `pedidos.zipnova_json` (JSON). Sin schema validation. | Datos corruptos si el JSON está mal formado. Sin type safety. | Validar JSON con Zod/class-validator al escribir. Columnas JSON con TypeORM. Considerar si conviene normalizar (ej: tabla `envios_localidades`). |
| **Soft deletes sin timestamps** | `eliminado` (0/1) en casi todas las tablas pero sin `eliminado_fecha` o `eliminado_por`. | Sin auditoría de quién borró qué y cuándo. | TypeORM soft delete (`@DeleteDateColumn()`). Agregar `deleted_by` si se requiere auditoría. |
| **Datos denormalizados sin estrategia clara** | `pedidos` almacena copia de datos del cliente. `pedidos_detalle` almacena copia de producto, precio, foto. | Por un lado es snapshot histórico (bueno). Por otro, no hay estrategia explícita — a veces se usa el dato de `pedidos`, a veces se joinea con `clientes`. | Documentar estrategia: pedidos SON snapshot. Nunca joinear con tablas maestras para mostrar datos de un pedido. El pedido es inmutable una vez confirmado. |

### 3.4 Antipatrones de UX

| Antipatrón | Evidencia | Por Qué es Malo | Cómo se Evita |
|---|---|---|---|
| **4 pasos con recarga completa** | Cada paso del checkout es una página separada que hace POST y redirect. | Lento. Si el cliente refresca en paso 3, pierde contexto. Mala experiencia mobile. | Single-page checkout con estado preservado (React state + DB sync). |
| **Sin validación client-side** | Validaciones solo al hacer submit del formulario (postback). | Feedback lento. Mala UX. | Validación en tiempo real con Zod/Yup. Errores inline. |
| **Sin estados de carga** | No se detectaron spinners, skeleton screens ni loading indicators. | El usuario no sabe si el sistema está procesando o roto. Click repetido → doble submit. | Loading states en todos los componentes interactivos. Debounce/disable en botones de submit. |
| **Dropdowns para variantes** | Selectores de variantes (talle, color) son dropdowns. | Para colores, un dropdown no permite visualizar. Para talles, no muestra disponibilidad de un vistazo. | Botones de selección visual. Colores como swatches. Talles como chips con indicador de stock. |

---

## 4. Recomendaciones de Arquitectura para NestJS

> Basadas en los bugs, problemas y limitaciones encontrados por el auditor.

### 4.1 Estructura de Módulos Recomendada

```
src/
├── modules/
│   ├── auth/               # Login, registro, recuperación, JWT
│   ├── users/              # Clientes + Administradores
│   ├── catalog/            # Productos, categorías, marcas, tags, propiedades
│   ├── inventory/          # Variantes, stock, precios
│   ├── cart/               # Carrito de compras
│   ├── checkout/           # Flujo de compra (4 pasos → single page)
│   ├── orders/             # Pedidos y su ciclo de vida
│   ├── payments/           # MercadoPago, Modo, Transferencia, Efectivo
│   │   ├── strategies/     # Strategy pattern: cada medio de pago
│   │   └── webhooks/       # Endpoints de IPN/webhook con validación
│   ├── shipping/           # Envíos propios, Zipnova, sucursal
│   ├── promotions/         # Promociones y cupones
│   ├── content/            # Slider, banners, FAQ, secciones, reseñas
│   ├── surveys/            # Encuestas (Post-MVP)
│   ├── chatbot/            # Chatbot IA (Post-MVP)
│   ├── tenant/             # Multi-tenant: DB switching, configuración
│   ├── email/              # Plantillas y envío de emails
│   ├── excel/              # Import/Export Excel
│   └── integration/        # PadPio, Dicomere, Zipnova
├── common/
│   ├── decorators/         # @CurrentUser, @Tenant, @Permissions
│   ├── guards/             # AuthGuard, PermissionsGuard, TenantGuard
│   ├── interceptors/       # Logging, transform, cache
│   ├── filters/            # Exception filters
│   └── pipes/              # Validation pipes
├── config/                 # Configuración tipada por módulo
└── database/
    ├── migrations/         # TypeORM migrations
    └── seeds/              # Datos iniciales
```

### 4.2 Decisiones Técnicas Clave

| Decisión | Recomendación | Justificación (basada en hallazgos) |
|---|---|---|
| **ORM** | TypeORM | Más maduro en ecosistema NestJS. Soporta migrations, multiple connections (multi-tenant), soft deletes, transactions. |
| **Base de datos** | MySQL (mantener) | Los datos existen en MySQL. Migrar a PostgreSQL sería costo adicional sin beneficio inmediato. Se puede evaluar post-MVP. |
| **Autenticación** | JWT + Passport | Reemplaza sesiones PHP. Stateless. Compatible con API REST + frontend separado. |
| **Validación** | class-validator + class-transformer | Integración nativa con NestJS. ValidationPipe global. Tipado estricto. |
| **Cache** | Redis | Para queries de catálogo, sesiones de checkout, rate limiting. |
| **Job queue** | BullMQ (Redis) | Sincronización PadPio, carritos abandonados, emails asíncronos. |
| **Email** | Nodemailer + MJML + Handlebars | Templates responsive. Variables tipadas. Cola de envío con reintentos. |
| **Frontend** | Next.js 14 (React) + Tailwind CSS | SSR para SEO. API routes para proxy. Componentes cliente para interactividad. Separado del backend. |
| **Admin UI** | React + Tailwind CSS + Headless UI | Componentes accesibles. Tablas con TanStack Table. Sin dependencia de templates de terceros (Velzon). |
| **Excel** | exceljs | Lectura/escritura XLSX. Streaming para archivos grandes. |
| **MSSQL (PadPio)** | tedious → node-mssql | Conexión a SQL Server desde Linux. Cross-platform. |
| **Logging** | Winston o Pino | Structured JSON logs. Niveles. Correlación IDs. |
| **Testing** | Jest + Supertest | Unit tests para servicios. e2e para flujos críticos (checkout, pricing). |
| **API Docs** | Swagger (`@nestjs/swagger`) | Auto-generado. Cliente puede consumir API documentada. |

### 4.3 Patrones para Evitar Bugs Conocidos

| Bug del Sistema Actual | Patrón Defensivo en NestJS |
|---|---|
| **`SET estado_envio='estado'` literal** (Zipnova) | Nunca concatenar strings en queries. Usar siempre parámetros (`WHERE Id = :id`). TypeORM lo garantiza. |
| **`nacimiento` hardcodeado a `'1980-06-20'`** (Modo) | Nunca hardcodear datos de usuario. Si el dato no existe, no enviarlo o usar null. Validar payload contra schema antes de enviar a API externa. |
| **Stock validado en carrito pero no descontado** | Usar transacciones con `FOR UPDATE` (o TypeORM `@Transaction`). Reserva temporal de stock al iniciar checkout con TTL (ej: 30 min). Si expira, liberar stock. |
| **Emails en `pedidos_emails` con `enviado=0` — si el webhook nunca llega, nunca se envían** | Job queue: al confirmar pago, encolar job de envío de email. Si falla, reintentar con backoff. Si el webhook no llega en N horas, alertar. |
| **Sin validación de firma en webhooks** | Middleware `WebhookGuard`: verificar firma criptográfica antes de procesar. Responder 401 si no es válida. Loggear intentos fallidos. |

### 4.4 Estrategia Multi-Tenant

```
Recomendación: Base de datos por tenant (mantener modelo actual)

Implementación:
1. NestJS ConfigModule carga tenant desde:
   - Subdominio: {tenant}.lumba.com
   - Header: X-Tenant-ID
   - Variable de entorno: TENANT_ID=canccat

2. TypeORM con múltiples conexiones o conexión dinámica:
   - Opción A: Cada tenant es una conexión nombrada
   - Opción B: Connection pool por tenant (más escalable)
   - Opción C: Middleware que resuelve tenant y configura DataSource

3. Migrations se ejecutan para todos los tenants:
   - Script: `migration:run --tenant=all`

4. Secrets por tenant:
   - .env.{tenant} o vault path: /tenants/{tenant}/secrets
```

### 4.5 Estrategia de Migración de Datos

```
Fase 1: Schema nuevo en NestJS (TypeORM migrations)
  - Crear tablas equivalentes con mejoras de schema
  - Agregar columnas nuevas (timestamps, created_at, updated_at)

Fase 2: ETL de datos legacy → nuevo schema
  - Script por tenant que lee MySQL legacy y escribe en nuevo schema
  - Transformar md5 → bcrypt (con flag "password_needs_rehash")
  - Mapear configuracion key-value → configuración tipada

Fase 3: Convivencia (opcional)
  - Nuevo sistema como primario
  - Legacy como fallback read-only durante X días
  - Sincronización inversa si es necesario rollback

Fase 4: Apagar legacy
  - Una vez validado: descomisionar PHP
```

---

## 5. Riesgos de Migración

| Riesgo | Probabilidad | Impacto | Mitigación |
|---|---|---|---|
| Pérdida de datos en migración de DB | Media | Crítico | Backup completo antes de migrar. ETL con validación de integridad (checksums). |
| Clientes rechazan nueva UI admin | Media | Alto | Prototipo temprano. Demo a clientes clave. Período de feedback antes del switch. |
| APIs externas cambian (MP, Modo, Zipnova) | Baja | Alto | Usar SDKs oficiales que abstraen cambios de API. Tests e2e contra sandbox. |
| Complejidad subestimada de Zipnova/PadPio | Media | Alto | Spike técnico en semana 1. Si es más complejo de lo esperado, ajustar timeline. |
| Regresiones en lógica de pricing | Media | Crítico | Tests exhaustivos del PricingService. Comparar outputs con sistema legacy en dataset de prueba. |
| Tenant configuration incorrecta en deploy | Media | Alto | Validación de configuración al iniciar la app. Health check de conectividad a DB. |

---

> **Confianza de este documento:** ALTA en gaps de seguridad y antipatrones (basado en código auditado). MEDIA-ALTA en recomendaciones de arquitectura (basadas en experiencia con NestJS y patrones de ecommerce). MEDIA en estrategia multi-tenant (depende de decisión técnica final del equipo).

---

*Documento preparado por el Product Owner basado exclusivamente en los hallazgos del System Auditor (2026-06-04). Los hechos sobre el sistema actual son del auditor. Las recomendaciones y decisiones son del PO.*
