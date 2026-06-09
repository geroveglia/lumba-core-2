# 01 — Database Schema Design (PostgreSQL + TypeORM)

> **Proyecto:** Lumba Ecommerce (Brownfield — migración PHP vanilla + MySQL → NestJS + TypeORM + PostgreSQL)
> **Fecha:** 2026-06-08
> **Rol:** Data Architect
> **Modelo:** deepseek-v4-pro
> **Nivel de confianza global:** ALTA (basado en 12 outputs previos: System Auditor, Product Owner, Security Agent, Backend Architect)
> **Fuentes:** `01-modelo-datos-actual.md`, `01-discovery-sistema-actual.md`, `01-backend-architecture.md`, `01-backend-api-spec.md`, `01-gaps-and-improvements.md`, `01-security-remediation-plan.md`, `01-feature-prioritization.md`, `01-features-por-cliente.md`, `01-functional-spec.md`

---

## Índice

1. [Decisiones de Diseño](#1-decisiones-de-diseño)
2. [Estrategia Multi-Tenant](#2-estrategia-multi-tenant)
3. [Identidad: Clientes y Administradores](#3-identidad-clientes-y-administradores)
4. [Catálogo: Productos, Variantes, Propiedades](#4-catálogo-productos-variantes-propiedades)
5. [Transaccional: Carrito, Checkout, Pedidos, Pagos](#5-transaccional-carrito-checkout-pedidos-pagos)
6. [Envíos y Logística](#6-envíos-y-logística)
7. [Marketing: Cupones, Promociones, Reseñas](#7-marketing-cupones-promociones-reseñas)
8. [Contenido y Configuración](#8-contenido-y-configuración)
9. [Encuestas](#9-encuestas)
10. [Geolocalización](#10-geolocalización)
11. [Seguridad y Auditoría](#11-seguridad-y-auditoría)
12. [Índices Recomendados](#12-índices-recomendados)
13. [Full-Text Search](#13-full-text-search)
14. [Resumen de Cambios vs Original](#14-resumen-de-cambios-vs-original)
15. [Equivalencias TypeORM](#15-equivalencias-typeorm)

---

## 1. Decisiones de Diseño

### 1.1 Principios del schema

| Decisión | Elección | Justificación |
|---|---|---|
| **PK strategy** | `SERIAL` (INTEGER auto-increment) para tablas existentes; `UUID` para tablas nuevas sin dependencias legacy | Mantiene compatibilidad con IDs existentes en la migración. Facilita ETL de MySQL. UUID para nuevas entidades (carts, webhook_logs) evita colisiones en entornos multi-tenant. |
| **Timestamps** | `TIMESTAMPTZ` (timestamp with time zone) en todas las tablas | El sistema opera en Argentina (GMT-3). PostgreSQL maneja timezone nativamente. Reemplaza `DATETIME` de MySQL que es timezone-naive. |
| **Soft deletes** | `deleted_at TIMESTAMPTZ` (nullable) en vez de `eliminado TINYINT(1)` | TypeORM `@DeleteDateColumn()` lo soporta nativamente. Auditoría de cuándo se eliminó. Sin necesidad de filtrar `WHERE eliminado = 0` en cada query — TypeORM lo hace automáticamente con `.find()` (no con `.findAndCount()` o queries raw). |
| **JSON** | `JSONB` para datos semiestructurados | Índices GIN, consultas performantes dentro del JSON. Reemplaza columnas TEXT con JSON en MySQL. |
| **Textos largos** | `TEXT` en PostgreSQL (sin límite práctico) en vez de `VARCHAR(255)` | PostgreSQL no penaliza TEXT vs VARCHAR. Usar TEXT para campos como descripcion, mensaje, cuerpo de email. |
| **IDs en strings** | `VARCHAR(36)` para UUID, `VARCHAR` con CHECK para hashes | Hashes de pedido y activación son VARCHAR(64) con índices. |
| **Moneda** | `NUMERIC(12,2)` para precios y totales | Precisión exacta para operaciones financieras. DECIMAL en MySQL, NUMERIC en PostgreSQL — equivalentes. |
| **Nombres de tabla** | `snake_case` pluralizado en inglés | Convención TypeORM. Facilita migración multi-dialecto. |
| **Nombres de columna** | `snake_case` en inglés | Consistencia con estándar PostgreSQL. TypeORM mapea camelCase (entity) ↔ snake_case (DB). |

### 1.2 Compatibilidad MySQL ↔ PostgreSQL

> **Nota del Data Architect:** El Backend Architect recomendó mantener MySQL en el MVP. Gero debe decidir. Este diseño usa PostgreSQL como target primario pero **todas las decisiones son compatibles con MySQL 8.0+** mediante TypeORM. Las diferencias se marcan explícitamente en cada caso.

| Feature usado | PostgreSQL | MySQL 8.0+ | Compatible? |
|---|---|---|---|
| `SERIAL` / `BIGSERIAL` | ✅ | ✅ `AUTO_INCREMENT` | ✅ TypeORM abstrae |
| `TIMESTAMPTZ` | ✅ | ⚠️ `TIMESTAMP` sin TZ | ⚠️ La app debe manejar UTC |
| `JSONB` | ✅ | ✅ `JSON` | ✅ TypeORM `type: 'jsonb'` → MySQL `json` |
| `TEXT` | ✅ | ✅ | ✅ |
| `NUMERIC(p,s)` | ✅ | ✅ `DECIMAL(p,s)` | ✅ |
| `UUID` (tipo nativo) | ✅ `UUID` | ❌ `CHAR(36)` | ⚠️ TypeORM maneja string |
| `tsvector` / GIN index | ✅ | ❌ `FULLTEXT` | ⚠️ Abstract en service |
| `CHECK` constraints | ✅ (enforced) | ⚠️ (parseado, no enforced < 8.0.16) | ⚠️ Validar en app también |
| `ILIKE` (case-insensitive) | ✅ | ❌ Usar `LOWER()` + `LIKE` | ⚠️ Abstract en repository |
| `RETURNING` clause | ✅ | ❌ | ⚠️ No usar en queries raw multi-dialecto |

**Recomendación final:** PostgreSQL es superior para este caso por JSONB (props dinámicas), tsvector (búsqueda), CHECK constraints enforce, y TIMESTAMPTZ (timezone). Si Gero decide mantener MySQL, el schema es compatible con mínimos ajustes (ver notas en cada entidad).

---

## 2. Estrategia Multi-Tenant

### 2.1 Modelo elegido: Database-per-tenant

```
┌─────────────────────────────────────────────────┐
│                  NestJS App                      │
│  (única instancia, mismo código para todos)      │
└────────────┬────────────┬────────────┬───────────┘
             │            │            │
    ┌────────▼───┐  ┌─────▼────┐  ┌───▼──────┐
    │ DB: tenant1 │  │DB:tenant2│  │DB:tenant3│
    │ (canccat)   │  │(kiarashop)│  │(cliente3) │
    └────────────┘  └──────────┘  └──────────┘
```

| Decisión | Valor |
|---|---|
| **Modelo** | Database per tenant (hereda el modelo actual de branches Git → DB separadas) |
| **Resolución** | Subdominio (`{tenant}.lumba.com`) → `X-Tenant-ID` header → `TENANT_ID` env var |
| **Migrations** | Se ejecutan contra TODAS las DBs de tenants mediante script |
| **Secrets** | `.env.{tenant}` o vault path `/tenants/{tenant}/` |
| **Conexión TypeORM** | DataSource dinámico: middleware resuelve tenant → crea/recupera DataSource del pool |

**Justificación:** El sistema actual ya tiene DB separadas por cliente. Mantener este modelo es el camino de menor fricción para la migración. Schema-per-tenant (schemas de PostgreSQL) sería una alternativa más económica en recursos pero rompe el aislamiento fuerte que los clientes ya tienen.

**No recomendado:** discriminador `tenant_id` en todas las tablas — requeriría modificar TODAS las queries y migrations, rompe el aislamiento, y complica backups/restores por cliente.

---

## 3. Identidad: Clientes y Administradores

### 3.1 `customers` ← `clientes`

> **Hecho:** Tabla principal de clientes. ~25 columnas en MySQL actual.
> **Cambios:** PK se mantiene SERIAL. Contraseña md5 → bcrypt con columnas de migración. `marcas` JSON → JSONB. `eliminado` TINYINT → `deleted_at TIMESTAMPTZ`.

```sql
CREATE TABLE customers (
    -- Primary Key
    id              SERIAL PRIMARY KEY,

    -- Identidad
    email           VARCHAR(255) NOT NULL,
    nombre          VARCHAR(100) NOT NULL,
    apellido        VARCHAR(100) NOT NULL,

    -- Empresa (opcional)
    razon_social    VARCHAR(255),
    nombre_fantasia VARCHAR(255),
    cuit            VARCHAR(20),
    dni             VARCHAR(20),
    iibb            VARCHAR(50),              -- Ingresos Brutos

    -- Contacto
    area            VARCHAR(10),              -- Código de área telefónico
    telefono        VARCHAR(30),

    -- Autenticación y Seguridad
    -- [MIGRACIÓN] columna contrasenia VARCHAR(32) → reemplazada por:
    password_hash           VARCHAR(60),      -- bcrypt hash (60 chars)
    password_needs_migration BOOLEAN NOT NULL DEFAULT FALSE, -- Flag migración md5→bcrypt
    legacy_md5_hash         VARCHAR(32),      -- [TEMPORAL] hash md5 original
    password_migrated_at    TIMESTAMPTZ,      -- [TEMPORAL] fecha de migración
    hash                    VARCHAR(64),      -- Hash único para activación/recuperación
    hash_expires_at         TIMESTAMPTZ,      -- [MEJORA] expiración del hash (1h recovery)

    -- Estado
    activo          BOOLEAN NOT NULL DEFAULT FALSE,  -- Activado vía email
    compro          BOOLEAN NOT NULL DEFAULT FALSE,  -- Ya realizó al menos 1 compra
    marketing       BOOLEAN NOT NULL DEFAULT FALSE,  -- Acepta marketing/newsletter

    -- Clasificación
    tipo_id         INTEGER REFERENCES customer_types(id),
    lista_id        INTEGER REFERENCES price_lists(id),
    tipo_comprobante_id INTEGER REFERENCES customer_invoice_types(id),
    situacion_fiscal_id INTEGER REFERENCES customer_fiscal_situations(id),
    vendedor_id     INTEGER REFERENCES admin_users(id),

    -- Pricing
    descuento       NUMERIC(5,2) DEFAULT 0,   -- Descuento personalizado (%)
    codigo          VARCHAR(100),             -- Código interno / legacy

    -- Restricciones
    marcas          JSONB,                    -- Array de IDs de marcas permitidas [1,3,5]

    -- Registro
    fecha_registro  TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    -- Soft delete + timestamps
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at      TIMESTAMPTZ               -- @DeleteDateColumn() TypeORM
);

-- Índices
CREATE UNIQUE INDEX idx_customers_email ON customers(email) WHERE deleted_at IS NULL;
CREATE INDEX idx_customers_tipo ON customers(tipo_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_customers_vendedor ON customers(vendedor_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_customers_hash ON customers(hash) WHERE deleted_at IS NULL;
CREATE INDEX idx_customers_lista ON customers(lista_id) WHERE deleted_at IS NULL;

-- [MEJORA] Índice para búsqueda unificada admin (nombre + apellido + email)
CREATE INDEX idx_customers_search ON customers
    USING gin (to_tsvector('spanish', coalesce(nombre,'') || ' ' || coalesce(apellido,'') || ' ' || coalesce(email,'')))
    WHERE deleted_at IS NULL;

-- Trigger para updated_at
CREATE TRIGGER trg_customers_updated_at
    BEFORE UPDATE ON customers
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
```

**Mapeo desde MySQL `clientes`:**
| Columna MySQL | Acción | Columna PostgreSQL |
|---|---|---|
| `Id` | Mantener | `id SERIAL` |
| `contrasenia` VARCHAR(32) | Reemplazar (md5→bcrypt) | `password_hash` + `legacy_md5_hash` + `password_needs_migration` |
| `eliminado` TINYINT(1) | Transformar | `deleted_at TIMESTAMPTZ` |
| `marcas` JSON | Mantener tipo | `marcas JSONB` |
| `nombre` VARCHAR(255) | Reducir | `nombre VARCHAR(100)` (nombre, no razón social) |
| `apellido` VARCHAR(255) | Reducir | `apellido VARCHAR(100)` |
| *(sin columna)* | Agregar | `created_at`, `updated_at` |
| *(sin columna)* | Agregar | `hash_expires_at` (mejora: expiración explícita) |
| `direccion` VARCHAR(255) | **No migrar** | Campo legacy ya no usado. Las direcciones están en `customer_addresses`. |

**Confianza:** ALTA. La tabla `clientes` está bien documentada en las queries PHP. Los cambios de seguridad (bcrypt) vienen del Security Agent.

---

### 3.2 `customer_types` ← `clientes_tipos`

> **Hecho:** Perfiles de cliente que definen métodos de pago/entrega, compra mínima, campos requeridos en checkout, y restricción de marcas.
> **Cambios:** Mismos que customers: `eliminado` → `deleted_at`, JSON → JSONB. Nombres de columnas en inglés.

```sql
CREATE TABLE customer_types (
    id                  SERIAL PRIMARY KEY,
    nombre              VARCHAR(100) NOT NULL,      -- "Minorista", "Mayorista", etc.

    -- Métodos de pago habilitados
    mercadopago         BOOLEAN NOT NULL DEFAULT TRUE,
    modo                BOOLEAN NOT NULL DEFAULT FALSE,
    transferencia       BOOLEAN NOT NULL DEFAULT TRUE,
    efectivo            BOOLEAN NOT NULL DEFAULT FALSE,

    -- Métodos de envío habilitados
    zipnova             BOOLEAN NOT NULL DEFAULT FALSE,
    zipnova_puntoentrega BOOLEAN NOT NULL DEFAULT FALSE,
    envios_propios      BOOLEAN NOT NULL DEFAULT TRUE,
    retiro_sucursal     BOOLEAN NOT NULL DEFAULT TRUE,

    -- Restricciones
    minimo_compra       NUMERIC(12,2) DEFAULT 0,
    lista_precios_id    INTEGER REFERENCES price_lists(id),
    marcas              JSONB,                     -- IDs de marcas permitidas

    -- Campos requeridos en checkout (Paso 1)
    datos_nombre        BOOLEAN NOT NULL DEFAULT TRUE,
    datos_apellido      BOOLEAN NOT NULL DEFAULT TRUE,
    datos_razon_social  BOOLEAN NOT NULL DEFAULT FALSE,
    datos_nombre_fantasia BOOLEAN NOT NULL DEFAULT FALSE,
    datos_dni           BOOLEAN NOT NULL DEFAULT FALSE,
    datos_cuit          BOOLEAN NOT NULL DEFAULT FALSE,
    datos_telefono      BOOLEAN NOT NULL DEFAULT FALSE,
    datos_marketing     BOOLEAN NOT NULL DEFAULT FALSE,
    datos_direccion     BOOLEAN NOT NULL DEFAULT FALSE,
    datos_situacion_fiscal BOOLEAN NOT NULL DEFAULT FALSE,

    -- Registro
    registro_habilitado BOOLEAN NOT NULL DEFAULT TRUE,
    predeterminado      BOOLEAN NOT NULL DEFAULT FALSE,

    -- Tipos de comprobante permitidos
    tipos_comprobante   JSONB,                     -- Array de IDs

    -- Timestamps
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at          TIMESTAMPTZ
);

CREATE INDEX idx_customer_types_predeterminado ON customer_types(predeterminado)
    WHERE deleted_at IS NULL AND predeterminado = TRUE;
```

**Confianza:** ALTA. Todos los campos `datos_*` están verificados en el código de checkout PHP.

---

### 3.3 `customer_invoice_types` ← `clientes_tipos_comprobante`

```sql
CREATE TABLE customer_invoice_types (
    id              SERIAL PRIMARY KEY,
    nombre          VARCHAR(100) NOT NULL,     -- "Factura A", "Factura B", "Ticket"
    predeterminado  BOOLEAN NOT NULL DEFAULT FALSE,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at      TIMESTAMPTZ
);
```

### 3.4 `customer_fiscal_situations` ← `clientes_situaciones`

```sql
CREATE TABLE customer_fiscal_situations (
    id          SERIAL PRIMARY KEY,
    nombre      VARCHAR(100) NOT NULL,         -- "Consumidor Final", "Responsable Inscripto", etc.
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at  TIMESTAMPTZ
);
```

### 3.5 `customer_addresses` ← `clientes_direcciones`

> **Hecho:** Direcciones de envío guardadas por el cliente. El campo `predeterminada` se usa para precargar en checkout.
> **Mejora:** Agregar `etiqueta` ("Casa", "Trabajo", "Oficina") para UX. Agregar `lat`/`lng` opcionales para futura integración con mapas.

```sql
CREATE TABLE customer_addresses (
    id              SERIAL PRIMARY KEY,
    customer_id     INTEGER NOT NULL REFERENCES customers(id) ON DELETE CASCADE,

    -- Dirección
    calle           VARCHAR(255) NOT NULL,
    numero          VARCHAR(20) NOT NULL,
    departamento    VARCHAR(50),
    entre_calles    VARCHAR(255),              -- [MEJORA] Referencia
    cp              VARCHAR(20) NOT NULL,

    -- Geo
    provincia_id    INTEGER NOT NULL REFERENCES provinces(id),
    localidad_id    INTEGER NOT NULL REFERENCES localities(id),
    lat             NUMERIC(10,7),             -- [MEJORA] Para mapas futuros
    lng             NUMERIC(10,7),

    -- Metadata
    etiqueta        VARCHAR(50),               -- [MEJORA] "Casa", "Trabajo"
    predeterminada  BOOLEAN NOT NULL DEFAULT FALSE,

    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at      TIMESTAMPTZ
);

-- Solo una dirección predeterminada por cliente
CREATE UNIQUE INDEX idx_addresses_predeterminada
    ON customer_addresses(customer_id, predeterminada)
    WHERE deleted_at IS NULL AND predeterminada = TRUE;

CREATE INDEX idx_addresses_customer ON customer_addresses(customer_id) WHERE deleted_at IS NULL;
```

**Confianza:** ALTA. CRUD completo visible en código PHP.

---

### 3.6 `admin_users` ← `administradores`

> **Hecho:** Usuarios del panel de administración. Contraseñas en **texto plano** en el sistema actual.
> **Cambio crítico:** bcrypt desde día 1. Columnas de migración temporal para el texto plano → bcrypt en primer login.

```sql
CREATE TABLE admin_users (
    id              SERIAL PRIMARY KEY,
    nombre          VARCHAR(100) NOT NULL,
    email           VARCHAR(255) NOT NULL,

    -- Seguridad: reemplaza contrasenia en texto plano
    password_hash           VARCHAR(60),       -- bcrypt hash
    password_needs_migration BOOLEAN NOT NULL DEFAULT FALSE,
    legacy_password         VARCHAR(255),      -- [TEMPORAL] contraseña en texto plano original

    -- Rol y permisos
    tipo_id         INTEGER NOT NULL REFERENCES admin_roles(id),
    predeterminado  BOOLEAN NOT NULL DEFAULT FALSE, -- Vendedor por defecto para clientes nuevos

    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at      TIMESTAMPTZ
);

CREATE UNIQUE INDEX idx_admin_email ON admin_users(email) WHERE deleted_at IS NULL;
CREATE INDEX idx_admin_tipo ON admin_users(tipo_id) WHERE deleted_at IS NULL;
```

### 3.7 `admin_roles` ← `administradores_tipos`

```sql
CREATE TABLE admin_roles (
    id              SERIAL PRIMARY KEY,
    nombre          VARCHAR(100) NOT NULL,     -- "Super Admin", "Vendedor", etc.
    home            VARCHAR(100) DEFAULT 'dashboard', -- Ruta default post-login
    clientes_propios BOOLEAN NOT NULL DEFAULT FALSE,  -- Solo ve sus clientes asignados
    pedidos_propios BOOLEAN NOT NULL DEFAULT FALSE,   -- Solo ve sus pedidos
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at      TIMESTAMPTZ
);
```

### 3.8 `admin_permissions` ← `secciones_admin` + `administradores_tipos_permisos`

> **Cambio:** Unificar las dos tablas en un modelo más flexible: permisos granulares asignables a roles (M:N).

```sql
CREATE TABLE admin_permissions (
    id              SERIAL PRIMARY KEY,
    recurso         VARCHAR(100) NOT NULL,     -- "productos", "pedidos", "clientes"
    accion          VARCHAR(50) NOT NULL,      -- "ver", "crear", "editar", "eliminar"
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    UNIQUE(recurso, accion)
);

CREATE TABLE admin_role_permissions (
    role_id         INTEGER NOT NULL REFERENCES admin_roles(id) ON DELETE CASCADE,
    permission_id   INTEGER NOT NULL REFERENCES admin_permissions(id) ON DELETE CASCADE,
    PRIMARY KEY (role_id, permission_id)
);
```

**Mapeo desde MySQL:**
| MySQL | PostgreSQL |
|---|---|
| `secciones_admin` (catálogo) + `administradores_tipos_permisos` (asignación) | `admin_permissions` (catálogo granular) + `admin_role_permissions` (M:N) |

**Confianza:** ALTA en estructura, MEDIA en migración de permisos existentes (se necesita mapear las secciones antiguas a recursos+acciones nuevos).

---

## 4. Catálogo: Productos, Variantes, Propiedades

### 4.1 `products` ← `productos`

> **Hecho:** Tabla principal de catálogo. ~15 columnas en MySQL.
> **Cambios:** Agregar `search_vector tsvector` para full-text search. `precio_desde` ahora es calculado (no almacenado, o actualizado por trigger). Quitar `categoria_id` directo (la relación real es M:N).

```sql
CREATE TABLE products (
    id              SERIAL PRIMARY KEY,
    nombre          VARCHAR(255) NOT NULL,
    url             VARCHAR(255) NOT NULL,     -- Slug único para URLs
    descripcion     TEXT,                      -- HTML sanitizado (el admin usa WYSIWYG)
    marca_id        INTEGER REFERENCES brands(id),
    iva             NUMERIC(5,2) DEFAULT 21,   -- IVA del producto

    -- Visual
    foto            VARCHAR(500),              -- Path/URL de la foto principal
    destacado       BOOLEAN NOT NULL DEFAULT FALSE,
    orden           INTEGER DEFAULT 0,

    -- Estado
    activo          BOOLEAN NOT NULL DEFAULT TRUE,
    codigo          VARCHAR(100),              -- Código interno / SKU principal

    -- Full-text search
    search_vector   TSVECTOR,                  -- [MEJORA] tsvector para búsqueda PostgreSQL

    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at      TIMESTAMPTZ
);

CREATE UNIQUE INDEX idx_products_url ON products(url) WHERE deleted_at IS NULL;
CREATE INDEX idx_products_marca ON products(marca_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_products_activo ON products(activo) WHERE deleted_at IS NULL AND activo = TRUE;
CREATE INDEX idx_products_destacado ON products(destacado) WHERE deleted_at IS NULL;
CREATE INDEX idx_products_search ON products USING gin(search_vector);

-- [MEJORA] Trigger para mantener search_vector actualizado
CREATE TRIGGER trg_products_search_vector
    BEFORE INSERT OR UPDATE ON products
    FOR EACH ROW EXECUTE FUNCTION update_product_search_vector();
```

**Mapeo desde MySQL `productos`:**
| Columna MySQL | Acción |
|---|---|
| `precio_desde` DECIMAL | **No incluir** en schema → calcular en query (MIN de variantes.precio) |
| `categoria_id` INT | **No incluir** → la relación real es M:N (`product_categories`) |
| `stock` INT | **No incluir** → campo legacy, el stock real está en `product_variant_stock` |
| *(sin columna)* | **Agregar** `search_vector tsvector` para full-text search |
| `eliminado` TINYINT | **Transformar** → `deleted_at` |

---

### 4.2 `brands` ← `marcas`

```sql
CREATE TABLE brands (
    id              SERIAL PRIMARY KEY,
    nombre          VARCHAR(100) NOT NULL,
    url             VARCHAR(255) NOT NULL,
    logo            VARCHAR(500),              -- [MEJORA] URL del logo de la marca
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at      TIMESTAMPTZ
);

CREATE UNIQUE INDEX idx_brands_url ON brands(url) WHERE deleted_at IS NULL;
```

### 4.3 `categories` ← `categorias`

> **Hecho:** Jerarquía de categorías nestable (árbol). `categoria_padre_id` self-referenciada.

```sql
CREATE TABLE categories (
    id                  SERIAL PRIMARY KEY,
    nombre              VARCHAR(100) NOT NULL,
    url                 VARCHAR(255) NOT NULL,
    descripcion         TEXT,                  -- [MEJORA] Descripción para SEO
    foto                VARCHAR(500),
    orden               INTEGER DEFAULT 0,
    parent_id           INTEGER REFERENCES categories(id), -- Self-referencia para jerarquía
    activo              BOOLEAN NOT NULL DEFAULT TRUE,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at          TIMESTAMPTZ
);

CREATE UNIQUE INDEX idx_categories_url ON categories(url) WHERE deleted_at IS NULL;
CREATE INDEX idx_categories_parent ON categories(parent_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_categories_orden ON categories(orden) WHERE deleted_at IS NULL;
```

### 4.4 `product_categories` ← `productos_categorias` (M:N)

```sql
CREATE TABLE product_categories (
    product_id      INTEGER NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    category_id     INTEGER NOT NULL REFERENCES categories(id) ON DELETE CASCADE,
    PRIMARY KEY (product_id, category_id)
);

CREATE INDEX idx_product_categories_category ON product_categories(category_id);
```

### 4.5 `tags` ← `tags`

```sql
CREATE TABLE tags (
    id                  SERIAL PRIMARY KEY,
    nombre              VARCHAR(100) NOT NULL,
    url                 VARCHAR(255) NOT NULL,
    visible_menu        BOOLEAN NOT NULL DEFAULT FALSE,
    orden               INTEGER DEFAULT 0,

    -- Estilos visuales del tag en el menú
    color_fondo_menu    VARCHAR(7),            -- Color CSS hexadecimal
    color_texto_menu    VARCHAR(7),
    bold_menu           BOOLEAN NOT NULL DEFAULT FALSE,

    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at          TIMESTAMPTZ
);

CREATE INDEX idx_tags_visible ON tags(visible_menu) WHERE deleted_at IS NULL;
CREATE INDEX idx_tags_orden ON tags(orden) WHERE deleted_at IS NULL;
```

### 4.6 `product_tags` ← `productos_tags` (M:N)

```sql
CREATE TABLE product_tags (
    product_id      INTEGER NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    tag_id          INTEGER NOT NULL REFERENCES tags(id) ON DELETE CASCADE,
    PRIMARY KEY (product_id, tag_id)
);
```

### 4.7 `product_images` ← `productos_imagenes` / `productos_variantes_fotos`

> **Cambio:** Unificar imágenes de producto y variante en una sola tabla con discriminador `entity_type`.

```sql
CREATE TABLE product_images (
    id              SERIAL PRIMARY KEY,
    product_id      INTEGER NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    variant_id      INTEGER REFERENCES product_variants(id) ON DELETE CASCADE, -- NULL si es imagen general
    archivo         VARCHAR(500) NOT NULL,     -- Path/URL de la imagen
    orden           INTEGER DEFAULT 0,
    alt_text        VARCHAR(255),              -- [MEJORA] Texto alternativo para accesibilidad
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at      TIMESTAMPTZ
);

CREATE INDEX idx_product_images_product ON product_images(product_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_product_images_variant ON product_images(variant_id) WHERE deleted_at IS NULL;
```

### 4.8 `properties` ← `propiedades`

> **Hecho:** Catálogo de propiedades de producto (ej: "Talle", "Color"). Usado para variantes y filtros.

```sql
CREATE TABLE properties (
    id              SERIAL PRIMARY KEY,
    nombre          VARCHAR(100) NOT NULL,     -- "Talle", "Color", "Material"
    orden           INTEGER DEFAULT 0,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at      TIMESTAMPTZ
);
```

### 4.9 `property_values` ← `propiedades_valores`

```sql
CREATE TABLE property_values (
    id              SERIAL PRIMARY KEY,
    property_id     INTEGER NOT NULL REFERENCES properties(id) ON DELETE CASCADE,
    valor           VARCHAR(255) NOT NULL,     -- "XL", "Rojo", "Algodón"
    valor2          NUMERIC(12,2) DEFAULT 0,  -- Multiplicador de precio (usado en PadPio)
    orden           INTEGER DEFAULT 0,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at      TIMESTAMPTZ
);

CREATE INDEX idx_property_values_prop ON property_values(property_id) WHERE deleted_at IS NULL;
CREATE UNIQUE INDEX idx_property_values_unique ON property_values(property_id, valor)
    WHERE deleted_at IS NULL;
```

### 4.10 `product_variants` ← `productos_variantes`

> **Cambio:** Reemplazar `propiedad1_id`, `propiedad2_id`, `propiedad3_id` (columnas fijas) por tabla M:N `variant_property_values` (flexible, N propiedades por variante).

```sql
CREATE TABLE product_variants (
    id                  SERIAL PRIMARY KEY,
    product_id          INTEGER NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    sku                 VARCHAR(100) NOT NULL,
    nombre_combinacion  VARCHAR(255),          -- Generado: "Talle XL / Color Rojo"
    foto                VARCHAR(500),           -- Foto específica de la variante
    activo              BOOLEAN NOT NULL DEFAULT TRUE,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at          TIMESTAMPTZ,

    UNIQUE(product_id, sku)                    -- SKU único dentro del producto
);

CREATE INDEX idx_variants_product ON product_variants(product_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_variants_sku ON product_variants(sku) WHERE deleted_at IS NULL;

-- Relación M:N entre variantes y valores de propiedad
CREATE TABLE variant_property_values (
    variant_id      INTEGER NOT NULL REFERENCES product_variants(id) ON DELETE CASCADE,
    property_value_id INTEGER NOT NULL REFERENCES property_values(id) ON DELETE CASCADE,
    PRIMARY KEY (variant_id, property_value_id)
);

CREATE INDEX idx_vpv_value ON variant_property_values(property_value_id);
```

**Mapeo desde MySQL:**
| MySQL `productos_variantes` | PostgreSQL |
|---|---|
| `propiedad1_id`, `propiedad2_id`, `propiedad3_id` (3 columnas fijas) | `variant_property_values` (M:N flexible, N propiedades) |

**Justificación:** El sistema actual limita a 3 propiedades por variante (talle, color, material). Con M:N se soportan N propiedades, más escalable para catálogos complejos. La migración es directa: cada `propiedadN_id` no nulo → INSERT en `variant_property_values`.

---

### 4.11 `product_variant_stock` ← `productos_variantes_stock`

```sql
CREATE TABLE product_variant_stock (
    id              SERIAL PRIMARY KEY,
    product_id      INTEGER NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    variant_id      INTEGER NOT NULL REFERENCES product_variants(id) ON DELETE CASCADE,
    branch_id       INTEGER NOT NULL REFERENCES branches(id) ON DELETE CASCADE,
    stock           INTEGER NOT NULL DEFAULT 0,
    stock_infinito  BOOLEAN NOT NULL DEFAULT FALSE, -- Stock ilimitado
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    UNIQUE(variant_id, branch_id)               -- Un registro de stock por variante+sucursal
);

CREATE INDEX idx_stock_product ON product_variant_stock(product_id);
CREATE INDEX idx_stock_branch ON product_variant_stock(branch_id);

-- CHECK: stock no puede ser negativo (salvo que sea infinito)
ALTER TABLE product_variant_stock ADD CONSTRAINT chk_stock_non_negative
    CHECK (stock_infinito = TRUE OR stock >= 0);
```

### 4.12 `product_variant_prices` ← `productos_variantes_precios`

```sql
CREATE TABLE product_variant_prices (
    id              SERIAL PRIMARY KEY,
    product_id      INTEGER NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    variant_id      INTEGER NOT NULL REFERENCES product_variants(id) ON DELETE CASCADE,
    price_list_id   INTEGER NOT NULL REFERENCES price_lists(id) ON DELETE CASCADE,
    precio          NUMERIC(12,2) NOT NULL,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    UNIQUE(variant_id, price_list_id)           -- Un precio por variante+lista
);

CREATE INDEX idx_prices_product ON product_variant_prices(product_id);
CREATE INDEX idx_prices_list ON product_variant_prices(price_list_id);
```

### 4.13 `price_lists` ← `listas`

```sql
CREATE TABLE price_lists (
    id              SERIAL PRIMARY KEY,
    nombre          VARCHAR(100) NOT NULL,     -- "Minorista", "Mayorista A", etc.
    predeterminada  BOOLEAN NOT NULL DEFAULT FALSE,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at      TIMESTAMPTZ
);
```

### 4.14 `product_property_values` ← `productos_propiedades_valores`

> **Hecho:** Relación directa producto → valores de propiedad para filtros en grilla.
> **Justificación:** Permite filtrar productos por propiedad sin pasar por la tabla de variantes.

```sql
CREATE TABLE product_property_values (
    product_id      INTEGER NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    property_value_id INTEGER NOT NULL REFERENCES property_values(id) ON DELETE CASCADE,
    PRIMARY KEY (product_id, property_value_id)
);

CREATE INDEX idx_ppv_value ON product_property_values(property_value_id);
```

### 4.15 `keywords` ← `keywords`

```sql
CREATE TABLE keywords (
    id          SERIAL PRIMARY KEY,
    keyword     VARCHAR(255) NOT NULL,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at  TIMESTAMPTZ,

    UNIQUE(keyword)
);
```

### 4.16 `product_keywords` ← `productos_keywords` (M:N)

```sql
CREATE TABLE product_keywords (
    product_id  INTEGER NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    keyword_id  INTEGER NOT NULL REFERENCES keywords(id) ON DELETE CASCADE,
    PRIMARY KEY (product_id, keyword_id)
);
```

### 4.17 `related_products` ← `productos_relacionados`

```sql
CREATE TABLE related_products (
    product_id              INTEGER NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    related_product_id      INTEGER NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    PRIMARY KEY (product_id, related_product_id),
    CHECK (product_id != related_product_id)  -- Un producto no puede relacionarse consigo mismo
);
```

---

## 5. Transaccional: Carrito, Checkout, Pedidos, Pagos

### 5.1 `carts` — NUEVA (carrito persistente)

> **Hecho:** Reemplaza el carrito en `$_SESSION` de PHP. Es una de las mejoras más críticas (ver `01-gaps-and-improvements.md` §1.2).
> **Diseño:** Asociado a `customer_id` (si está logueado) o a `session_token` (visitante anónimo).

```sql
CREATE TABLE carts (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(), -- UUID: no secuencial, seguro para URLs
    customer_id     INTEGER REFERENCES customers(id),     -- NULL si es anónimo
    session_token   VARCHAR(255),                         -- JWT anónimo o token de sesión

    -- Cupón aplicado (denormalizado para performance)
    coupon_code     VARCHAR(100),
    coupon_value    NUMERIC(12,2),
    coupon_type     VARCHAR(50),                         -- 'Porcentaje', 'Monto fijo', 'Envío gratis'

    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Un carrito por cliente logueado (el más reciente)
CREATE UNIQUE INDEX idx_carts_customer ON carts(customer_id) WHERE customer_id IS NOT NULL;
CREATE INDEX idx_carts_session ON carts(session_token);
CREATE INDEX idx_carts_stale ON carts(updated_at)
    WHERE updated_at < NOW() - INTERVAL '7 days';  -- Para limpieza de carritos viejos
```

### 5.2 `cart_items` — NUEVA

```sql
CREATE TABLE cart_items (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    cart_id         UUID NOT NULL REFERENCES carts(id) ON DELETE CASCADE,
    product_id      INTEGER NOT NULL REFERENCES products(id),
    variant_id      INTEGER NOT NULL REFERENCES product_variants(id),
    cantidad        INTEGER NOT NULL CHECK (cantidad > 0),

    -- Snapshot al momento de agregar (evita joins en cada render del carrito)
    nombre          VARCHAR(255) NOT NULL,       -- Nombre del producto
    sku             VARCHAR(100),
    foto            VARCHAR(500),
    precio          NUMERIC(12,2) NOT NULL,       -- Precio unitario validado server-side
    iva             NUMERIC(5,2) DEFAULT 21,
    url             VARCHAR(255),                -- Slug del producto

    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    UNIQUE(cart_id, variant_id)                 -- No duplicar items
);

CREATE INDEX idx_cart_items_cart ON cart_items(cart_id);
```

### 5.3 `checkouts` — NUEVA (estado de checkout persistente)

> **Hecho:** Reemplaza `$_SESSION['checkout']`. Persiste el estado de cada paso del checkout.

```sql
CREATE TABLE checkouts (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    cart_id         UUID NOT NULL REFERENCES carts(id),
    customer_id     INTEGER REFERENCES customers(id),
    order_id        INTEGER REFERENCES orders(id),  -- Se crea en paso 1 con estado 'Incompleto'

    -- Paso actual del checkout
    paso_actual     SMALLINT NOT NULL DEFAULT 1 CHECK (paso_actual BETWEEN 1 AND 4),

    -- Datos de cada paso (JSONB — schema validado en app)
    datos_personales JSONB,     -- Paso 1: nombre, email, tipo cliente, facturación
    datos_envio      JSONB,     -- Paso 2: dirección, sucursal, método envío
    datos_pago       JSONB,     -- Paso 3: método de pago

    completado      BOOLEAN NOT NULL DEFAULT FALSE,

    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_checkouts_cart ON checkouts(cart_id);
CREATE INDEX idx_checkouts_customer ON checkouts(customer_id);
```

### 5.4 `orders` ← `pedidos`

> **Hecho:** Tabla más grande y compleja del sistema (~50 columnas). Snapshot completo del pedido.
> **Cambios:** Separar dirección en JSONB. Agregar `tracking_number` y `tracking_url`. Mejorar estados con CHECK constraints.

```sql
CREATE TABLE orders (
    id                  SERIAL PRIMARY KEY,
    hash                VARCHAR(64) NOT NULL,   -- Identificador público único (no secuencial)
    customer_id         INTEGER REFERENCES customers(id),
    lista_id            INTEGER REFERENCES price_lists(id),
    branch_id           INTEGER REFERENCES branches(id),

    -- Fecha
    fecha               TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    -- Datos del cliente (snapshot — inmutable una vez confirmado)
    email               VARCHAR(255) NOT NULL,
    nombre              VARCHAR(100),
    apellido            VARCHAR(100),
    area                VARCHAR(10),
    telefono            VARCHAR(30),
    dni                 VARCHAR(20),
    newsletter          BOOLEAN NOT NULL DEFAULT FALSE,
    origen              VARCHAR(50) DEFAULT 'Web',

    -- Datos fiscales (snapshot)
    razon_social        VARCHAR(255),
    nombre_fantasia     VARCHAR(255),
    cuit                VARCHAR(20),
    tipo_cliente        VARCHAR(100),
    situacion_fiscal    VARCHAR(100),
    tipo_comprobante    VARCHAR(100),

    -- Dirección de entrega (JSONB — snapshot)
    shipping_address    JSONB,
    --  { calle, numero, departamento, provincia_id, provincia, localidad_id, localidad, cp }

    -- Dirección de facturación (JSONB — snapshot, opcional)
    billing_address     JSONB,

    -- Envío
    forma_entrega       VARCHAR(100) NOT NULL,  -- 'retiro_sucursal', 'envio_domicilio', 'zipnova_sucursal'
    sucursal_id         INTEGER REFERENCES branches(id),
    costo_envio         NUMERIC(12,2) DEFAULT 0,
    costo_envio_real    NUMERIC(12,2) DEFAULT 0,
    zipnova_opcion      VARCHAR(100),
    zipnova_point_id    VARCHAR(100),
    zipnova_json        JSONB,
    tracking_number     VARCHAR(255),           -- [MEJORA] Número de tracking
    tracking_url        VARCHAR(500),           -- [MEJORA] URL de tracking público

    -- Pago
    forma_pago          VARCHAR(100),           -- 'mercadopago', 'modo', 'transferencia', 'efectivo'
    payment_provider    VARCHAR(50),            -- [MEJORA] Normalizado: 'mercadopago', 'modo', etc.
    payment_external_id VARCHAR(255),           -- [MEJORA] ID de transacción externa (MP preference_id, Modo payment_id)

    -- Cupón aplicado (snapshot)
    cupon               VARCHAR(100),
    cupon_valor         NUMERIC(12,2),
    cupon_tipo          VARCHAR(50),            -- 'Porcentaje', 'Monto fijo', 'Envío gratis'

    -- Totales
    subtotal            NUMERIC(12,2) NOT NULL DEFAULT 0,
    descuentos          NUMERIC(12,2) NOT NULL DEFAULT 0,
    iva_total           NUMERIC(12,2) NOT NULL DEFAULT 0,
    total               NUMERIC(12,2) NOT NULL DEFAULT 0,

    -- Estados
    estado              VARCHAR(50) NOT NULL DEFAULT 'Incompleto',   -- 'Incompleto', 'Activo', 'Reintegrado'
    estado_pago         VARCHAR(50) NOT NULL DEFAULT 'Pendiente',    -- 'Pendiente', 'Pagado', 'Reintegrado'
    estado_entrega      VARCHAR(50) NOT NULL DEFAULT 'Pendiente',    -- 'Pendiente', 'Enviado', 'Entregado'
    estado_factura      VARCHAR(50) NOT NULL DEFAULT 'Pendiente',    -- 'Pendiente', 'Facturado'

    -- Carrito abandonado
    cron_notificado     BOOLEAN NOT NULL DEFAULT FALSE,
    cron_notificado_at  TIMESTAMPTZ,            -- [MEJORA] Cuándo se notificó

    -- Observaciones
    observaciones       TEXT,

    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at          TIMESTAMPTZ
);

-- Índices críticos (basados en queries PHP detectadas)
CREATE UNIQUE INDEX idx_orders_hash ON orders(hash);
CREATE INDEX idx_orders_customer ON orders(customer_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_orders_fecha ON orders(fecha DESC) WHERE deleted_at IS NULL;
CREATE INDEX idx_orders_estado ON orders(estado) WHERE deleted_at IS NULL;
CREATE INDEX idx_orders_estado_pago ON orders(estado_pago) WHERE deleted_at IS NULL;
CREATE INDEX idx_orders_estado_entrega ON orders(estado_entrega) WHERE deleted_at IS NULL;
CREATE INDEX idx_orders_branch ON orders(branch_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_orders_cron ON orders(cron_notificado, estado, fecha)
    WHERE deleted_at IS NULL AND estado = 'Incompleto' AND cron_notificado = FALSE;

-- CHECK constraints
ALTER TABLE orders ADD CONSTRAINT chk_orders_estado
    CHECK (estado IN ('Incompleto', 'Activo', 'Reintegrado'));
ALTER TABLE orders ADD CONSTRAINT chk_orders_estado_pago
    CHECK (estado_pago IN ('Pendiente', 'Pagado', 'Reintegrado'));
ALTER TABLE orders ADD CONSTRAINT chk_orders_estado_entrega
    CHECK (estado_entrega IN ('Pendiente', 'Enviado', 'Entregado'));
ALTER TABLE orders ADD CONSTRAINT chk_orders_total_non_negative
    CHECK (total >= 0);
```

**Mapeo desde MySQL `pedidos`:**
| Columna MySQL | Acción |
|---|---|
| `calle`, `numero`, `departamento`, `provincia_id`, `localidad_id`, `cp` (6 columnas) | **Agrupar** en `shipping_address JSONB` |
| `facturacion_calle`, `facturacion_numero`, `facturacion_departamento`, `facturacion_provincia_id`, `facturacion_localidad_id`, `facturacion_cp` (6 columnas) | **Agrupar** en `billing_address JSONB` |
| `formapago` | **Renombrar** a `forma_pago` |
| `formaentrega` | **Renombrar** a `forma_entrega` |
| *(sin columna)* | **Agregar** `payment_provider`, `payment_external_id` |
| *(sin columna)* | **Agregar** `tracking_number`, `tracking_url` |
| `eliminado` TINYINT | **Transformar** → `deleted_at` |

**Confianza:** ALTA. Esta es la tabla más auditada (checkout, admin, webhooks, cron).

---

### 5.5 `order_items` ← `pedidos_detalle`

```sql
CREATE TABLE order_items (
    id                  SERIAL PRIMARY KEY,
    order_id            INTEGER NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    product_id          INTEGER REFERENCES products(id),
    variant_id          INTEGER REFERENCES product_variants(id),

    -- Snapshot del producto al momento de la compra (inmutable)
    producto            VARCHAR(255) NOT NULL,  -- Nombre del producto
    producto_sku        VARCHAR(100),
    foto                VARCHAR(500),
    propiedades         VARCHAR(500),           -- "Talle XL / Color Rojo" (concatenado)
    cantidad            INTEGER NOT NULL CHECK (cantidad > 0),

    -- Precios
    precio_abonado      NUMERIC(12,2) NOT NULL,  -- Precio final cobrado
    precio_original     NUMERIC(12,2) NOT NULL,  -- Precio de lista sin descuentos
    iva                 NUMERIC(5,2) DEFAULT 21,

    -- Promoción aplicada (snapshot)
    promotion_id        INTEGER REFERENCES promotions(id),
    promotion_nombre    VARCHAR(255),
    promotion_tipo      VARCHAR(50),
    promotion_valor     NUMERIC(12,2),

    -- Cupón aplicado
    aplica_cupon        BOOLEAN NOT NULL DEFAULT FALSE,
    codigo_cupon        VARCHAR(100),

    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_order_items_order ON order_items(order_id);
CREATE INDEX idx_order_items_product ON order_items(product_id);
```

### 5.6 `order_status_history` — NUEVA (tracking de cambios de estado)

> **Hecho:** No existe en el sistema actual. Los estados se actualizan en webhooks sin registro histórico.
> **Mejora crítica:** Auditar cada cambio de estado con timestamp, usuario/sistema que lo hizo, y nota.

```sql
CREATE TABLE order_status_history (
    id              SERIAL PRIMARY KEY,
    order_id        INTEGER NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    status_type     VARCHAR(20) NOT NULL CHECK (status_type IN ('general', 'pago', 'entrega', 'factura')),
    old_status      VARCHAR(50),
    new_status      VARCHAR(50) NOT NULL,
    changed_by      VARCHAR(100),              -- 'system', 'admin:{id}', 'webhook:{provider}'
    nota            TEXT,                      -- Motivo del cambio (opcional)
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_order_status_order ON order_status_history(order_id);
CREATE INDEX idx_order_status_created ON order_status_history(created_at DESC);
```

### 5.7 `order_emails` ← `pedidos_emails`

```sql
CREATE TABLE order_emails (
    id              SERIAL PRIMARY KEY,
    order_id        INTEGER NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    asunto          VARCHAR(500) NOT NULL,
    cuerpo          TEXT NOT NULL,              -- HTML compilado
    destinatario    VARCHAR(255) NOT NULL,
    enviado         BOOLEAN NOT NULL DEFAULT FALSE,
    enviado_at      TIMESTAMPTZ,               -- [MEJORA] Cuándo se envió
    intentos        SMALLINT NOT NULL DEFAULT 0, -- [MEJORA] Reintentos
    error           TEXT,                      -- [MEJORA] Último error
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_order_emails_order ON order_emails(order_id);
CREATE INDEX idx_order_emails_pending ON order_emails(enviado, intentos)
    WHERE enviado = FALSE;
```

### 5.8 `payments` — NUEVA (registro de pagos)

> **Hecho:** El sistema actual no tiene tabla de pagos separada. Los estados se actualizan en `pedidos.estado_pago`.
> **Mejora crítica:** Tabla dedicada para tracking de transacciones con idempotencia.

```sql
CREATE TABLE payments (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id            INTEGER NOT NULL REFERENCES orders(id),
    provider            VARCHAR(50) NOT NULL,   -- 'mercadopago', 'modo', 'transferencia', 'efectivo'
    external_id         VARCHAR(255),           -- ID en el provider (MP payment_id, Modo transaction_id)
    status              VARCHAR(50) NOT NULL DEFAULT 'pending', -- 'pending', 'approved', 'rejected', 'refunded'
    amount              NUMERIC(12,2) NOT NULL,
    currency            VARCHAR(3) DEFAULT 'ARS',

    -- Metadata del provider (JSONB — varía por proveedor)
    provider_metadata   JSONB,                  -- MP: {preference_id, payment_method_id, ...}, Modo: {...}

    -- Comprobante (transferencia)
    comprobante_url     VARCHAR(500),           -- Path al archivo subido

    -- Fechas
    initiated_at        TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    completed_at        TIMESTAMPTZ,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    UNIQUE(order_id, provider)                  -- Un pago por pedido+provider
);

CREATE INDEX idx_payments_order ON payments(order_id);
CREATE INDEX idx_payments_external ON payments(provider, external_id);
CREATE INDEX idx_payments_status ON payments(status);
```

### 5.9 `payment_webhooks` — NUEVA (log de webhooks recibidos)

> **Hecho:** No existe log de webhooks. Sin él, es imposible auditar problemas de pago.
> **Mejora crítica de seguridad:** Idempotencia y auditoría de todos los webhooks recibidos.

```sql
CREATE TABLE payment_webhooks (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    payment_id      UUID REFERENCES payments(id),
    order_id        INTEGER NOT NULL REFERENCES orders(id),
    provider        VARCHAR(50) NOT NULL,       -- 'mercadopago', 'modo', 'zipnova'
    event_type      VARCHAR(100) NOT NULL,       -- 'payment.created', 'payment.updated', 'shipment.status_changed'
    raw_payload     JSONB NOT NULL,              -- Body completo del webhook (auditoría)
    signature_valid BOOLEAN NOT NULL DEFAULT FALSE,
    processed       BOOLEAN NOT NULL DEFAULT FALSE,
    processed_at    TIMESTAMPTZ,
    error           TEXT,                        -- Si falló el procesamiento
    ip_address      VARCHAR(45),                 -- IP del remitente
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_webhooks_order ON payment_webhooks(order_id);
CREATE INDEX idx_webhooks_provider ON payment_webhooks(provider, created_at DESC);
CREATE INDEX idx_webhooks_unprocessed ON payment_webhooks(processed)
    WHERE processed = FALSE;
```

### 5.10 `payment_status_history` — NUEVA

```sql
CREATE TABLE payment_status_history (
    id              SERIAL PRIMARY KEY,
    payment_id      UUID NOT NULL REFERENCES payments(id) ON DELETE CASCADE,
    old_status      VARCHAR(50),
    new_status      VARCHAR(50) NOT NULL,
    source          VARCHAR(50) NOT NULL,       -- 'webhook', 'admin', 'system'
    nota            TEXT,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_payment_status_payment ON payment_status_history(payment_id);
```

### 5.11 `wishlists` ← `clientes_favoritos`

```sql
CREATE TABLE wishlists (
    customer_id     INTEGER NOT NULL REFERENCES customers(id) ON DELETE CASCADE,
    product_id      INTEGER NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    PRIMARY KEY (customer_id, product_id)
);
```

---

## 6. Envíos y Logística

### 6.1 `branches` ← `sucursales`

```sql
CREATE TABLE branches (
    id              SERIAL PRIMARY KEY,
    nombre          VARCHAR(100) NOT NULL,
    direccion       VARCHAR(255),
    telefono        VARCHAR(50),
    email           VARCHAR(255),              -- [MEJORA]
    horarios        TEXT,                      -- [MEJORA] "Lun-Vie 9-18hs, Sáb 9-13hs"
    lat             NUMERIC(10,7),             -- [MEJORA] Mapa de sucursales
    lng             NUMERIC(10,7),
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at      TIMESTAMPTZ
);
```

### 6.2 `shipping_methods` ← `envios_propios`

```sql
CREATE TABLE shipping_methods (
    id                  SERIAL PRIMARY KEY,
    nombre              VARCHAR(100) NOT NULL,  -- "Envío CABA", "Envío GBA"
    precio              NUMERIC(12,2) NOT NULL DEFAULT 0,
    informacion         TEXT,                   -- Info mostrada al cliente
    provincia_id        INTEGER REFERENCES provinces(id),
    localidades         JSONB,                 -- Array de IDs de localidades ([0]=todas)
    envio_gratis        BOOLEAN NOT NULL DEFAULT FALSE,
    envio_gratis_minimo NUMERIC(12,2),         -- Monto mínimo para envío gratis
    activo              BOOLEAN NOT NULL DEFAULT TRUE,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at          TIMESTAMPTZ
);

CREATE INDEX idx_shipping_provincia ON shipping_methods(provincia_id) WHERE deleted_at IS NULL;
```

### 6.3 `shipping_config` — configuración global de envío (fila única)

> **Cambio:** Unificar `envio_gratis` y `compra_minima` (tablas de una fila) en config JSONB.

```sql
CREATE TABLE shipping_config (
    id              SMALLINT PRIMARY KEY DEFAULT 1 CHECK (id = 1), -- Fila única
    config          JSONB NOT NULL DEFAULT '{}',
    -- {
    --   "envio_gratis_activo": false,
    --   "envio_gratis_monto_desde": 50000,
    --   "compra_minima": 0,
    --   "compra_minima_sin_impuestos": true
    -- }
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
```

### 6.4 `shipping_zones` — NUEVA

> **Mejora:** Reemplaza el JSON `localidades` en `envios_propios` con una tabla normalizada.

```sql
CREATE TABLE shipping_zones (
    id                  SERIAL PRIMARY KEY,
    shipping_method_id  INTEGER NOT NULL REFERENCES shipping_methods(id) ON DELETE CASCADE,
    provincia_id        INTEGER REFERENCES provinces(id),
    localidad_id        INTEGER REFERENCES localities(id), -- NULL = toda la provincia
    cp_desde            VARCHAR(20),                       -- [MEJORA] Rango de CP
    cp_hasta            VARCHAR(20),
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_shipping_zones_method ON shipping_zones(shipping_method_id);
CREATE INDEX idx_shipping_zones_location ON shipping_zones(provincia_id, localidad_id);
```

**Justificación:** La tabla normalizada permite queries SQL directas para filtrar métodos de envío por ubicación, sin necesidad de parsear JSON en la app. El JSON actual (`[0]=todas`) se migra fácilmente. Si se prefiere mantener simplicidad, usar JSONB en `shipping_methods.localidades`.

---

## 7. Marketing: Cupones, Promociones, Reseñas

### 7.1 `coupons` ← `cupones`

```sql
CREATE TABLE coupons (
    id                  SERIAL PRIMARY KEY,
    codigo              VARCHAR(100) NOT NULL,
    tipo_descuento      VARCHAR(50) NOT NULL CHECK (tipo_descuento IN ('Porcentaje', 'Monto fijo', 'Envío gratis')),
    valor               NUMERIC(12,2) NOT NULL,
    uso_maximo          INTEGER DEFAULT 0,      -- 0 = ilimitado
    uso_actual          INTEGER NOT NULL DEFAULT 0,
    aplica_a_tipo       VARCHAR(50) NOT NULL DEFAULT 'toda_la_tienda'
                        CHECK (aplica_a_tipo IN ('toda_la_tienda', 'categorias', 'productos')),
    aplica_a_categorias JSONB,                  -- Array de IDs de categorías
    aplica_a_productos  JSONB,                  -- Array de IDs de productos
    acumulable          BOOLEAN NOT NULL DEFAULT FALSE,
    fecha_desde         DATE,
    fecha_hasta         DATE,
    activo              BOOLEAN NOT NULL DEFAULT TRUE,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at          TIMESTAMPTZ
);

CREATE UNIQUE INDEX idx_coupons_codigo ON coupons(codigo) WHERE deleted_at IS NULL;
CREATE INDEX idx_coupons_activo ON coupons(activo) WHERE deleted_at IS NULL AND activo = TRUE;
```

### 7.2 `coupon_usage` ← `cupones_utilizados`

```sql
CREATE TABLE coupon_usage (
    id              SERIAL PRIMARY KEY,
    coupon_id       INTEGER NOT NULL REFERENCES coupons(id),
    customer_id     INTEGER REFERENCES customers(id),
    order_id        INTEGER REFERENCES orders(id),
    used_at         TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(coupon_id, order_id)                -- Un cupón por pedido
);

CREATE INDEX idx_coupon_usage_coupon ON coupon_usage(coupon_id);
CREATE INDEX idx_coupon_usage_customer ON coupon_usage(customer_id);
```

### 7.3 `promotions` ← `promociones`

```sql
CREATE TABLE promotions (
    id                  SERIAL PRIMARY KEY,
    nombre              VARCHAR(255) NOT NULL,
    promocion_tipo      VARCHAR(50) NOT NULL,   -- '00'=PadPio %, '0'=descuento x cantidad, otros=tipos custom
    cantidad_minimo     INTEGER DEFAULT 1,      -- Cantidad mínima para aplicar
    cantidad_valor      NUMERIC(12,2),          -- Valor del descuento (%)
    limite_fecha        BOOLEAN NOT NULL DEFAULT FALSE,
    fecha_desde         DATE,
    fecha_hasta         DATE,
    aplica_a_tipo       VARCHAR(50) NOT NULL DEFAULT 'toda_la_tienda'
                        CHECK (aplica_a_tipo IN ('toda_la_tienda', 'categorias', 'productos')),
    aplica_a_categorias JSONB,
    aplica_a_productos  JSONB,
    excluir_categorias  JSONB,
    excluir_productos   JSONB,
    activo              BOOLEAN NOT NULL DEFAULT TRUE,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at          TIMESTAMPTZ
);

CREATE INDEX idx_promotions_activo ON promotions(activo) WHERE deleted_at IS NULL AND activo = TRUE;
```

### 7.4 `reviews` ← `resenias`

> **Mejora:** Agregar `product_id` y `customer_id` para reseñas verificadas de compra. El sistema actual solo tiene testimonios manuales cargados por admin.

```sql
CREATE TABLE reviews (
    id              SERIAL PRIMARY KEY,
    product_id      INTEGER REFERENCES products(id), -- [MEJORA] Reseña de producto específico
    customer_id     INTEGER REFERENCES customers(id), -- [MEJORA] Cliente que compró el producto
    order_id        INTEGER REFERENCES orders(id),   -- [MEJORA] Pedido verificado
    nombre          VARCHAR(100) NOT NULL,            -- Nombre público (puede ser el del cliente o "Anónimo")
    resenia         TEXT NOT NULL,
    puntaje         SMALLINT NOT NULL CHECK (puntaje BETWEEN 1 AND 5),
    verificado      BOOLEAN NOT NULL DEFAULT FALSE,   -- [MEJORA] Compra verificada
    aprobado        BOOLEAN NOT NULL DEFAULT FALSE,   -- [MEJORA] Moderación admin
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at      TIMESTAMPTZ
);

CREATE INDEX idx_reviews_product ON reviews(product_id) WHERE deleted_at IS NULL AND aprobado = TRUE;
CREATE INDEX idx_reviews_aprobado ON reviews(aprobado) WHERE deleted_at IS NULL;
```

### 7.5 `abandoned_carts` ← `carritos_abandonados`

> **Hecho:** El sistema actual tiene `pedidos` con `estado='Incompleto'` como carritos abandonados. Esta tabla es para tracking específico del cron de abandono.

```sql
CREATE TABLE abandoned_carts (
    id              SERIAL PRIMARY KEY,
    order_id        INTEGER NOT NULL REFERENCES orders(id),
    customer_id     INTEGER REFERENCES customers(id),
    email           VARCHAR(255) NOT NULL,
    notified_at     TIMESTAMPTZ,
    recovered_at    TIMESTAMPTZ,               -- Si el cliente retomó la compra
    coupon_sent_id  INTEGER REFERENCES coupons(id),
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_abandoned_orders ON abandoned_carts(order_id);
CREATE INDEX idx_abandoned_notified ON abandoned_carts(notified_at);
```

---

## 8. Contenido y Configuración

### 8.1 `sliders` ← `slider`

```sql
CREATE TABLE sliders (
    id              SERIAL PRIMARY KEY,
    titulo          VARCHAR(255),
    descripcion     TEXT,
    foto            VARCHAR(500) NOT NULL,
    foto_mobile     VARCHAR(500),              -- [MEJORA] Imagen específica para mobile
    link            VARCHAR(500),
    orden           INTEGER DEFAULT 0,
    activo          BOOLEAN NOT NULL DEFAULT TRUE,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at      TIMESTAMPTZ
);

CREATE INDEX idx_sliders_activo ON sliders(activo, orden) WHERE deleted_at IS NULL AND activo = TRUE;
```

### 8.2 `banners` ← `banners` + `banners_promociones_bancarias`

> **Cambio:** Unificar ambas tablas con discriminador `type`.

```sql
CREATE TABLE banners (
    id              SERIAL PRIMARY KEY,
    titulo          VARCHAR(255),
    foto            VARCHAR(500) NOT NULL,
    link            VARCHAR(500),
    ubicacion       VARCHAR(100),              -- 'home_top', 'home_middle', 'sidebar', etc.
    type            VARCHAR(50) NOT NULL DEFAULT 'promocional'
                    CHECK (type IN ('promocional', 'bancario', 'informativo')),
    banco           VARCHAR(100),              -- Solo para type='bancario'
    activo          BOOLEAN NOT NULL DEFAULT TRUE,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at      TIMESTAMPTZ
);

CREATE INDEX idx_banners_activo ON banners(activo) WHERE deleted_at IS NULL AND activo = TRUE;
```

### 8.3 `content_sections` ← `secciones_adicionales` + `secciones_adicionales_contenido`

```sql
CREATE TABLE content_sections (
    id              SERIAL PRIMARY KEY,
    titulo          VARCHAR(255) NOT NULL,     -- "Términos y Condiciones", "Política de Privacidad"
    url             VARCHAR(255) NOT NULL UNIQUE,
    contenido       TEXT,                      -- [MEJORA] Contenido principal (Markdown o HTML)
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at      TIMESTAMPTZ
);

CREATE UNIQUE INDEX idx_content_sections_url ON content_sections(url) WHERE deleted_at IS NULL;
```

**Mapeo:** La tabla `secciones_adicionales_contenido` del sistema actual (varios bloques de contenido por sección con orden) se puede modelar como JSONB en `content_sections.sub_secciones` o mantener como tabla separada. Para simplicidad MVP, el campo `contenido TEXT` contiene todo el HTML/Markdown.

### 8.4 `faqs` ← `preguntas_frecuentes`

```sql
CREATE TABLE faqs (
    id              SERIAL PRIMARY KEY,
    pregunta        VARCHAR(500) NOT NULL,
    respuesta       TEXT NOT NULL,
    orden           INTEGER DEFAULT 0,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at      TIMESTAMPTZ
);

CREATE INDEX idx_faqs_orden ON faqs(orden) WHERE deleted_at IS NULL;
```

### 8.5 `social_links` ← `redes`

```sql
CREATE TABLE social_links (
    id              SERIAL PRIMARY KEY,
    red             VARCHAR(50) NOT NULL,      -- 'facebook', 'instagram', 'whatsapp'
    link            VARCHAR(500) NOT NULL,
    icono           VARCHAR(255),              -- [MEJORA] Nombre del ícono o URL
    orden           INTEGER DEFAULT 0,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at      TIMESTAMPTZ
);
```

### 8.6 `contacts` ← `consultas` / `contacto`

```sql
CREATE TABLE contacts (
    id              SERIAL PRIMARY KEY,
    nombre          VARCHAR(100) NOT NULL,
    email           VARCHAR(255) NOT NULL,
    telefono        VARCHAR(30),
    area_id         INTEGER REFERENCES contact_areas(id),
    mensaje         TEXT NOT NULL,
    leido           BOOLEAN NOT NULL DEFAULT FALSE,
    leido_at        TIMESTAMPTZ,               -- [MEJORA]
    leido_por       INTEGER REFERENCES admin_users(id), -- [MEJORA]
    fecha           TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_contacts_leido ON contacts(leido, fecha DESC);
```

### 8.7 `contact_areas` ← `contacto_areas`

```sql
CREATE TABLE contact_areas (
    id              SERIAL PRIMARY KEY,
    nombre          VARCHAR(100) NOT NULL,     -- "Ventas", "Soporte", "Devoluciones"
    email           VARCHAR(255) NOT NULL,     -- Email destino de los mensajes
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at      TIMESTAMPTZ
);
```

### 8.8 `returns` ← `devoluciones`

```sql
CREATE TABLE returns (
    id              SERIAL PRIMARY KEY,
    nombre          VARCHAR(100) NOT NULL,
    apellido        VARCHAR(100) NOT NULL,
    email           VARCHAR(255) NOT NULL,
    area            VARCHAR(10),
    telefono        VARCHAR(30),
    compra_id       VARCHAR(100),              -- Número de pedido (referencia)
    mensaje         TEXT NOT NULL,
    estado          VARCHAR(50) NOT NULL DEFAULT 'pendiente'
                    CHECK (estado IN ('pendiente', 'en_proceso', 'resuelta', 'rechazada')),
    fecha           TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_returns_estado ON returns(estado);
```

### 8.9 `email_templates` ← `emails_plantillas` / `emails`

```sql
CREATE TABLE email_templates (
    id              SERIAL PRIMARY KEY,
    nombre          VARCHAR(100) NOT NULL UNIQUE, -- 'pedido_confirmacion_cliente', 'carrito_abandonado', etc.
    asunto          VARCHAR(500) NOT NULL,      -- Con placeholders {{VAR}}
    cuerpo          TEXT NOT NULL,               -- HTML con placeholders {{VAR}}
    descripcion     VARCHAR(255),                -- [MEJORA] Descripción para el admin
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at      TIMESTAMPTZ
);
```

### 8.10 `tenant_settings` ← `configuracion` (solo settings de negocio)

> **Hecho:** La tabla `configuracion` es key-value con ~40 variables.
> **Cambio crítico:** Separar secretos (→ `.env`) de configuración de negocio (→ esta tabla). Ver `01-security-remediation-plan.md` V05.

```sql
CREATE TABLE tenant_settings (
    id              SERIAL PRIMARY KEY,
    key             VARCHAR(100) NOT NULL,
    value           TEXT NOT NULL,
    type            VARCHAR(20) NOT NULL DEFAULT 'string'
                    CHECK (type IN ('string', 'number', 'boolean', 'json', 'html')),
    description     VARCHAR(255),              -- [MEJORA] Descripción para el panel admin
    category        VARCHAR(50) NOT NULL DEFAULT 'general'
                    CHECK (category IN ('general', 'payments', 'shipping', 'theme', 'contact', 'cron')),
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    UNIQUE(key)
);

CREATE INDEX idx_settings_category ON tenant_settings(category);
```

**Variables que migran a esta tabla (no secretos):**
```
cuotas_mercadopago, compra_minima_sin_impuestos, datos_bancarios,
metodos_pago, envio_habilitado, retiro_por_sucursal, retiro_por_sucursal_informacion,
nombre_fantasia, email_compras, marcas (toggle), tipos_cliente (toggle),
formulario_devoluciones (toggle), logo_menu, logo_header, logo_footer, favicon,
fondo_login, img_share, colores*, tipografias*,
telefono_whatsapp, whatsapp, carritos_abandonados_horas, carritos_abandonados_cupon_id
```

**Variables que NO migran a DB (van a `.env` o vault):**
```
mercadopago_access_token → MERCADOPAGO_ACCESS_TOKEN (env)
modo_username, modo_password → MODO_USERNAME, MODO_PASSWORD (env)
modo_processor_code, modo_cc_code → MODO_PROCESSOR_CODE, MODO_CC_CODE (env)
padpio_user, padpio_password, padpio_host → PADPIO_USER, PADPIO_PASSWORD, PADPIO_HOST (env)
recaptcha_site_key, recaptcha_secret_key → RECAPTCHA_SITE_KEY, RECAPTCHA_SECRET_KEY (env)
smtp_* → SMTP_HOST, SMTP_PORT, SMTP_USER, SMTP_PASSWORD (env)
```

### 8.11 `home_layout` ← `home_order`

```sql
CREATE TABLE home_layout (
    id              SERIAL PRIMARY KEY,
    module_type     VARCHAR(50) NOT NULL CHECK (module_type IN ('slider', 'categories', 'products', 'banners', 'carousel')),
    config          JSONB NOT NULL DEFAULT '{}',
    -- {
    --   "category_id": 5,     // Para module_type='categories'
    --   "product_ids": [1,2], // Para module_type='products'
    --   "title": "Destacados" // Título de la sección
    -- }
    orden           INTEGER DEFAULT 0,
    activo          BOOLEAN NOT NULL DEFAULT TRUE,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_home_layout_orden ON home_layout(orden) WHERE activo = TRUE;
```

---

## 9. Encuestas

### 9.1 `surveys` ← `encuestas`

```sql
CREATE TABLE surveys (
    id              SERIAL PRIMARY KEY,
    nombre          VARCHAR(255) NOT NULL,
    cupon_id        INTEGER REFERENCES coupons(id),
    fecha_desde     DATE,
    fecha_hasta     DATE,
    activo          BOOLEAN NOT NULL DEFAULT TRUE,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at      TIMESTAMPTZ
);
```

### 9.2 `survey_questions` ← `encuestas_preguntas`

```sql
CREATE TABLE survey_questions (
    id              SERIAL PRIMARY KEY,
    survey_id       INTEGER NOT NULL REFERENCES surveys(id) ON DELETE CASCADE,
    pregunta        VARCHAR(500) NOT NULL,
    tipo_pregunta   VARCHAR(50) NOT NULL
                    CHECK (tipo_pregunta IN ('texto', 'valoracion', 'checkbox', 'radio', 'si_no')),
    opciones        JSONB,                    -- Array de opciones para checkbox/radio
    orden           INTEGER DEFAULT 0,
    requerido       BOOLEAN NOT NULL DEFAULT TRUE, -- [MEJORA]
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_survey_questions_survey ON survey_questions(survey_id);
```

### 9.3 `survey_invitations` ← `encuestas_envios`

```sql
CREATE TABLE survey_invitations (
    id              SERIAL PRIMARY KEY,
    survey_id       INTEGER NOT NULL REFERENCES surveys(id),
    hash            VARCHAR(64) NOT NULL UNIQUE,
    tipo            VARCHAR(50) NOT NULL CHECK (tipo IN ('prospectos', 'pedidos')),
    origen_id       INTEGER,                  -- ID del prospecto o pedido
    customer_id     INTEGER REFERENCES customers(id),
    email           VARCHAR(255),
    enviado_at      TIMESTAMPTZ,
    respondido_at   TIMESTAMPTZ,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_survey_inv_survey ON survey_invitations(survey_id);
```

### 9.4 `survey_responses` ← `encuestas_respuestas`

```sql
CREATE TABLE survey_responses (
    id              SERIAL PRIMARY KEY,
    invitation_id   INTEGER NOT NULL REFERENCES survey_invitations(id) ON DELETE CASCADE,
    survey_id       INTEGER NOT NULL REFERENCES surveys(id),
    question_id     INTEGER NOT NULL REFERENCES survey_questions(id),
    pregunta        VARCHAR(500) NOT NULL,     -- Denormalizado para preservar texto original
    respuesta       TEXT NOT NULL,             -- Respuesta (string o JSON si es multi-opción)
    fecha           TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_survey_resp_inv ON survey_responses(invitation_id);
```

---

## 10. Geolocalización

### 10.1 `provinces` ← `provincias`

```sql
CREATE TABLE provinces (
    id              SERIAL PRIMARY KEY,
    nombre          VARCHAR(100) NOT NULL,
    code            VARCHAR(10),              -- [MEJORA] Código ISO 3166-2:AR (ej: "AR-B")
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
```

### 10.2 `localities` ← `localidades`

```sql
CREATE TABLE localities (
    id              SERIAL PRIMARY KEY,
    nombre          VARCHAR(255) NOT NULL,
    provincia_id    INTEGER NOT NULL REFERENCES provinces(id),
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_localities_provincia ON localities(provincia_id);
```

### 10.3 `postal_codes` ← `codigos_postales`

```sql
CREATE TABLE postal_codes (
    id              SERIAL PRIMARY KEY,
    codigo          VARCHAR(20) NOT NULL,
    localidad_id    INTEGER NOT NULL REFERENCES localities(id),
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_postal_codes_codigo ON postal_codes(codigo);
CREATE INDEX idx_postal_codes_localidad ON postal_codes(localidad_id);
```

---

## 11. Seguridad y Auditoría

### 11.1 `refresh_tokens` — NUEVA

```sql
CREATE TABLE refresh_tokens (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id         INTEGER NOT NULL,              -- customer.id o admin_user.id
    user_type       VARCHAR(20) NOT NULL CHECK (user_type IN ('customer', 'admin')),
    token_hash      VARCHAR(64) NOT NULL UNIQUE,   -- SHA-256 del refresh token
    revoked         BOOLEAN NOT NULL DEFAULT FALSE,
    revoked_at      TIMESTAMPTZ,
    expires_at      TIMESTAMPTZ NOT NULL,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_refresh_tokens_user ON refresh_tokens(user_id, user_type);
CREATE INDEX idx_refresh_tokens_expires ON refresh_tokens(expires_at)
    WHERE revoked = FALSE;
```

### 11.2 `audit_logs` — NUEVA (auditoría de acciones sensibles)

```sql
CREATE TABLE audit_logs (
    id              BIGSERIAL PRIMARY KEY,
    user_id         INTEGER,                       -- Admin o customer que realizó la acción
    user_type       VARCHAR(20) CHECK (user_type IN ('customer', 'admin', 'system', 'webhook')),
    action          VARCHAR(100) NOT NULL,          -- 'order.status_changed', 'product.deleted', etc.
    entity_type     VARCHAR(50) NOT NULL,           -- 'order', 'product', 'customer', etc.
    entity_id       VARCHAR(100) NOT NULL,          -- ID de la entidad afectada
    old_values      JSONB,                          -- Valores antes del cambio
    new_values      JSONB,                          -- Valores después del cambio
    ip_address      VARCHAR(45),
    user_agent      VARCHAR(500),
    tenant_id       VARCHAR(100),                   -- Para logs multi-tenant
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_audit_entity ON audit_logs(entity_type, entity_id);
CREATE INDEX idx_audit_user ON audit_logs(user_id, user_type);
CREATE INDEX idx_audit_action ON audit_logs(action, created_at DESC);
CREATE INDEX idx_audit_created ON audit_logs(created_at DESC);
```

---

## 12. Índices Recomendados

### 12.1 Índices basados en queries detectadas en código PHP

| Query detectada | Índice(s) recomendado(s) |
|---|---|
| `SELECT * FROM productos WHERE activo=1 AND eliminado=0 ORDER BY orden` | `idx_products_activo` (activo) WHERE deleted_at IS NULL |
| `SELECT * FROM productos WHERE marca_id=X AND activo=1 AND eliminado=0` | `idx_products_marca` (marca_id) WHERE deleted_at IS NULL |
| `SELECT * FROM productos WHERE url='slug'` | `idx_products_url` UNIQUE WHERE deleted_at IS NULL |
| `SELECT p.* FROM productos p JOIN productos_categorias pc ON p.Id=pc.producto_id WHERE pc.categoria_id=X` | PK de product_categories (product_id, category_id) + idx on category_id |
| `SELECT * FROM productos WHERE producto LIKE '%texto%' OR descripcion LIKE '%texto%'` | **Reemplazar por:** `idx_products_search` GIN index on `search_vector` |
| `SELECT * FROM pedidos WHERE cliente_id=X ORDER BY fecha DESC` | `idx_orders_customer` (customer_id) WHERE deleted_at IS NULL |
| `SELECT * FROM pedidos WHERE hash='abc'` | `idx_orders_hash` UNIQUE |
| `SELECT * FROM pedidos WHERE estado='Incompleto' AND cron_notificado=0` | `idx_orders_cron` partial index |
| `SELECT * FROM pedidos WHERE fecha BETWEEN X AND Y ORDER BY fecha` | `idx_orders_fecha` (fecha DESC) |
| `SELECT * FROM clientes WHERE email='x@y.com'` | `idx_customers_email` UNIQUE WHERE deleted_at IS NULL |
| `SELECT * FROM clientes WHERE hash='abc'` | `idx_customers_hash` |
| `SELECT * FROM productos_variantes WHERE producto_id=X AND eliminado=0` | `idx_variants_product` (product_id) WHERE deleted_at IS NULL |
| `SELECT * FROM productos_variantes_stock WHERE variante_id=X AND sucursal_id=Y` | UNIQUE(variant_id, branch_id) |
| `SELECT * FROM productos_variantes_precios WHERE variante_id=X AND lista_id=Y` | UNIQUE(variant_id, price_list_id) |
| `SELECT * FROM cupones WHERE codigo='XXX' AND activo=1` | `idx_coupons_codigo` UNIQUE WHERE deleted_at IS NULL |
| `SELECT * FROM carritos WHERE cliente_id=X` | `idx_carts_customer` UNIQUE WHERE customer_id IS NOT NULL |

### 12.2 Índices GIN para JSONB

```sql
-- Búsqueda en marcas de customer_types (productos visibles por cliente)
CREATE INDEX idx_customer_types_marcas ON customer_types USING gin(marcas);

-- Búsqueda en localidades de shipping_methods
CREATE INDEX idx_shipping_methods_localidades ON shipping_methods USING gin(localidades);

-- Búsqueda en aplica_a_productos de promotions
CREATE INDEX idx_promotions_productos ON promotions USING gin(aplica_a_productos);

-- Búsqueda en aplica_a_categorias de coupons
CREATE INDEX idx_coupons_categorias ON coupons USING gin(aplica_a_categorias);
```

---

## 13. Full-Text Search

### 13.1 Estrategia PostgreSQL

> **Decisión:** Usar `tsvector` nativo de PostgreSQL en vez de Elasticsearch para el MVP. Elasticsearch se evalúa post-MVP si el volumen de productos o la complejidad de búsqueda lo justifican.

```sql
-- Función para generar el tsvector combinando nombre, descripcion y keywords
CREATE OR REPLACE FUNCTION update_product_search_vector()
RETURNS trigger AS $$
BEGIN
    NEW.search_vector :=
        setweight(to_tsvector('spanish', coalesce(NEW.nombre, '')), 'A') ||
        setweight(to_tsvector('spanish', coalesce(NEW.descripcion, '')), 'B');
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger que actualiza search_vector en cada INSERT/UPDATE
-- (ya definido arriba: trg_products_search_vector)

-- Consulta de búsqueda (ejemplo)
-- SELECT *, ts_rank(search_vector, query) AS rank
-- FROM products
-- WHERE search_vector @@ plainto_tsquery('spanish', 'zapatilla running')
--   AND deleted_at IS NULL AND activo = TRUE
-- ORDER BY rank DESC;
```

**Compatibilidad MySQL:** MySQL usa `FULLTEXT INDEX` con `MATCH ... AGAINST`. TypeORM no abstrae esto. La solución es crear un `SearchService` con implementaciones separadas por dialecto (Strategy pattern), o usar LIKE/ILIKE para el MVP con MySQL y migrar a tsvector cuando se pase a PostgreSQL.

---

## 14. Resumen de Cambios vs Original

### 14.1 Tablas renombradas

| MySQL (PHP) | PostgreSQL (NestJS) | Razón |
|---|---|---|
| `clientes` | `customers` | Convención inglés, TypeORM |
| `clientes_tipos` | `customer_types` | Ídem |
| `clientes_direcciones` | `customer_addresses` | Ídem |
| `clientes_tipos_comprobante` | `customer_invoice_types` | Nombre descriptivo |
| `clientes_situaciones` | `customer_fiscal_situations` | Ídem |
| `clientes_favoritos` | `wishlists` | Concepto más claro |
| `administradores` | `admin_users` | Distinguir de customers |
| `administradores_tipos` | `admin_roles` | Ídem |
| `productos` | `products` | Inglés |
| `productos_variantes` | `product_variants` | Ídem |
| `productos_variantes_stock` | `product_variant_stock` | Ídem |
| `productos_variantes_precios` | `product_variant_prices` | Ídem |
| `marcas` | `brands` | Ídem |
| `categorias` | `categories` | Ídem |
| `propiedades` | `properties` | Ídem |
| `propiedades_valores` | `property_values` | Ídem |
| `listas` | `price_lists` | Nombre descriptivo |
| `pedidos` | `orders` | Inglés |
| `pedidos_detalle` | `order_items` | Ídem |
| `pedidos_emails` | `order_emails` | Ídem |
| `cupones` | `coupons` | Ídem |
| `promociones` | `promotions` | Ídem |
| `sucursales` | `branches` | Más estándar |
| `envios_propios` | `shipping_methods` | Ídem |
| `resenias` | `reviews` | Ídem |
| `encuestas` | `surveys` | Ídem |
| `banners` + `banners_promociones_bancarias` | `banners` | Unificar con discriminador |
| `slider` | `sliders` | Plural consistente |
| `secciones_adicionales` + `_contenido` | `content_sections` | Simplificar |
| `preguntas_frecuentes` | `faqs` | Nombre más corto |
| `consultas` / `contacto` | `contacts` | Ídem |
| `contacto_areas` | `contact_areas` | Ídem |
| `devoluciones` | `returns` | Ídem |
| `provincias` | `provinces` | Inglés |
| `localidades` | `localities` | Ídem |
| `codigos_postales` | `postal_codes` | Ídem |
| `emails_plantillas` / `emails` | `email_templates` | Unificar |
| `configuracion` | `tenant_settings` | Separar secretos → .env |
| `carritos_abandonados` | `abandoned_carts` | Mejor nombre |

### 14.2 Tablas NUEVAS (no existen en MySQL)

| Tabla | Propósito | Prioridad |
|---|---|---|
| `carts` + `cart_items` | Carrito persistente (reemplaza `$_SESSION`) | **P0** — MVP |
| `checkouts` | Estado de checkout persistente | **P0** — MVP |
| `order_status_history` | Tracking de cambios de estado | **P1** — Semana 1 |
| `payments` | Registro de transacciones de pago | **P0** — MVP |
| `payment_webhooks` | Log de webhooks con firma | **P0** — MVP |
| `payment_status_history` | Tracking de cambios de estado de pago | **P1** — Semana 1 |
| `shipping_zones` | Zonas de envío normalizadas | **P2** — Opcional (usar JSONB en MVP) |
| `refresh_tokens` | Blacklist de refresh tokens | **P0** — MVP |
| `audit_logs` | Auditoría de acciones sensibles | **P2** — Semana 2 |
| `shipping_config` | Config de envío unificada (reemplaza 2 tablas 1-fila) | **P1** — Semana 1 |
| `home_layout` | Orden de módulos del home | **P2** — Semana 2 |
| `admin_permissions` + `admin_role_permissions` | Permisos granulares (reemplaza 2 tablas) | **P0** — MVP |

### 14.3 Columnas agregadas (mejoras)

| Tabla | Columna | Mejora |
|---|---|---|
| `customers` | `hash_expires_at` | Expiración explícita de hash de recuperación |
| `customers` | `created_at`, `updated_at` | Timestamps |
| `products` | `search_vector` | Full-text search |
| `product_variants` | `activo` | Activar/desactivar variante individual |
| `order_items` | *(mantener `promotion_id`)* | Ya existía |
| `orders` | `tracking_number`, `tracking_url` | Tracking mejorado |
| `orders` | `payment_provider`, `payment_external_id` | Trazabilidad de pagos |
| `orders` | `subtotal`, `descuentos`, `iva_total` | Breakdown de totales |
| `order_emails` | `intentos`, `error`, `enviado_at` | Reintentos y auditoría |
| `reviews` | `product_id`, `customer_id`, `order_id`, `verificado`, `aprobado` | Reseñas verificadas |
| `contacts` | `leido_at`, `leido_por` | Tracking de atención |
| `addresses` | `etiqueta`, `lat`, `lng`, `entre_calles` | UX mejorada |
| `brands` | `logo` | Logo de marca |
| `categories` | `descripcion` | SEO |
| `product_images` | `alt_text` | Accesibilidad |
| **Casi todas** | `created_at`, `updated_at` | Auditoría temporal |

### 14.4 Cosas que se ELIMINAN del schema

| Elemento MySQL | Razón |
|---|---|
| Columna `eliminado` TINYINT(1) en TODAS las tablas | Reemplazada por `deleted_at TIMESTAMPTZ` (TypeORM @DeleteDateColumn) |
| `productos.categoria_id` | La relación real es M:N (`product_categories`) |
| `productos.precio_desde` | Calculado en query/trigger, no almacenado |
| `productos.stock` | Campo legacy. Stock real en `product_variant_stock` |
| `productos_variantes.propiedad1/2/3_id` (3 columnas fijas) | Reemplazado por M:N `variant_property_values` |
| `clientes.direccion` | Campo legacy. Direcciones en `customer_addresses` |
| `pedidos.calle, .numero, .departamento, .provincia_id, .localidad_id, .cp` (6 columnas) | Agrupadas en `shipping_address JSONB` |
| `pedidos.facturacion_*` (6 columnas) | Agrupadas en `billing_address JSONB` |
| `configuracion` como key-value con secretos | Secretos → .env. Settings → `tenant_settings` |
| `envio_gratis` + `compra_minima` (tablas de 1 fila) | Unificadas en `shipping_config` |
| `secciones_admin` + `administradores_tipos_permisos` | Reemplazadas por `admin_permissions` + `admin_role_permissions` |

---

## 15. Equivalencias TypeORM

### 15.1 Mapeo de tipos PostgreSQL → TypeORM

| PostgreSQL | TypeORM Decorator | Notas |
|---|---|---|
| `SERIAL` | `@PrimaryGeneratedColumn()` | |
| `BIGSERIAL` | `@PrimaryGeneratedColumn('increment', { type: 'bigint' })` | |
| `UUID` | `@PrimaryGeneratedColumn('uuid')` | |
| `VARCHAR(n)` | `@Column({ length: n })` | |
| `TEXT` | `@Column('text')` | |
| `BOOLEAN` | `@Column('boolean')` | |
| `SMALLINT` | `@Column('smallint')` | |
| `INTEGER` | `@Column('int')` | |
| `NUMERIC(p,s)` | `@Column('decimal', { precision: p, scale: s })` | |
| `TIMESTAMPTZ` | `@CreateDateColumn()` / `@UpdateDateColumn()` / `@Column('timestamptz')` | |
| `JSONB` | `@Column('jsonb')` | MySQL: `'json'` |
| `TSVECTOR` | `@Column('tsvector', { select: false })` | No se selecciona por defecto |
| `deleted_at` | `@DeleteDateColumn()` | TypeORM soft delete |

### 15.2 Ejemplo de entidad TypeORM

```typescript
// src/modules/customers/entities/customer.entity.ts
import {
  Entity, Column, PrimaryGeneratedColumn,
  CreateDateColumn, UpdateDateColumn, DeleteDateColumn,
  ManyToOne, JoinColumn, Index,
} from 'typeorm';
import { CustomerType } from './customer-type.entity';
import { PriceList } from '../../catalog/entities/price-list.entity';

@Entity('customers')
export class Customer {
  @PrimaryGeneratedColumn()
  id: number;

  @Index({ unique: true, where: 'deleted_at IS NULL' })
  @Column({ length: 255 })
  email: string;

  @Column({ length: 100 })
  nombre: string;

  @Column({ length: 100 })
  apellido: string;

  @Column({ length: 255, nullable: true })
  razonSocial: string;

  @Column({ length: 255, nullable: true })
  nombreFantasia: string;

  // Autenticación
  @Column({ name: 'password_hash', length: 60, nullable: true, select: false })
  passwordHash: string;

  @Column({ name: 'password_needs_migration', default: false })
  passwordNeedsMigration: boolean;

  @Column({ name: 'legacy_md5_hash', length: 32, nullable: true, select: false })
  legacyMd5Hash: string;

  @Column({ name: 'password_migrated_at', type: 'timestamptz', nullable: true })
  passwordMigratedAt: Date;

  @Index()
  @Column({ length: 64, nullable: true })
  hash: string;

  @Column({ name: 'hash_expires_at', type: 'timestamptz', nullable: true })
  hashExpiresAt: Date;

  @Column({ default: false })
  activo: boolean;

  @Column({ default: false })
  compro: boolean;

  @Column({ default: false })
  marketing: boolean;

  // Relaciones
  @ManyToOne(() => CustomerType, { nullable: true })
  @JoinColumn({ name: 'tipo_id' })
  tipo: CustomerType;

  @Column({ name: 'tipo_id', nullable: true })
  tipoId: number;

  @ManyToOne(() => PriceList, { nullable: true })
  @JoinColumn({ name: 'lista_id' })
  lista: PriceList;

  @Column({ name: 'lista_id', nullable: true })
  listaId: number;

  @Column('jsonb', { nullable: true })
  marcas: number[];

  @Column('decimal', { precision: 5, scale: 2, default: 0 })
  descuento: number;

  @Column({ length: 100, nullable: true })
  codigo: string;

  @Column({ name: 'fecha_registro', type: 'timestamptz', default: () => 'NOW()' })
  fechaRegistro: Date;

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;

  @UpdateDateColumn({ name: 'updated_at' })
  updatedAt: Date;

  @DeleteDateColumn({ name: 'deleted_at' })
  deletedAt: Date;
}
```

### 15.3 Relaciones TypeORM

```typescript
// Ejemplo: Product → Variants (OneToMany)
@Entity('product_variants')
export class ProductVariant {
  @PrimaryGeneratedColumn()
  id: number;

  @ManyToOne(() => Product, product => product.variants)
  @JoinColumn({ name: 'product_id' })
  product: Product;

  @Column({ name: 'product_id' })
  productId: number;
  // ...
}

// Ejemplo: Cart → CartItems (OneToMany con cascade)
@Entity('carts')
export class Cart {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @OneToMany(() => CartItem, item => item.cart, { cascade: true, eager: true })
  items: CartItem[];
  // ...
}

// Ejemplo: Product ↔ PropertyValue (ManyToMany)
@Entity('products')
export class Product {
  // ...

  @ManyToMany(() => PropertyValue)
  @JoinTable({
    name: 'product_property_values',
    joinColumn: { name: 'product_id', referencedColumnName: 'id' },
    inverseJoinColumn: { name: 'property_value_id', referencedColumnName: 'id' },
  })
  propertyValues: PropertyValue[];
}
```

---

## Anexo A: Funciones de utilidad PostgreSQL

```sql
-- Función reutilizable para triggers de updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS trigger AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Aplicar a todas las tablas con updated_at
-- (Ejecutar una vez por tabla)
-- CREATE TRIGGER trg_{table}_updated_at BEFORE UPDATE ON {table} FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
```

---

## Anexo B: Encriptación de datos sensibles en DB

> **Decisión:** NO se almacenan datos sensibles en la DB. Los secretos (API keys, passwords de servicios) van en `.env` o vault. Los únicos datos sensibles en DB son las contraseñas de usuarios, que se almacenan con bcrypt (ya incluye salt).

**No se requiere encriptación a nivel de columna en PostgreSQL** (`pgcrypto`) porque:
1. Contraseñas → bcrypt (hash unidireccional, no encriptación reversible)
2. API keys → `.env` / vault
3. Datos personales (DNI, CUIT, dirección) → no justifican encriptación reversible (se necesitan para facturación y envíos)

Si en el futuro se requiere encriptación reversible (ej: datos de tarjeta, aunque NO deberían almacenarse), usar `pgcrypto` con `pgp_sym_encrypt()`.

---

## Anexo C: Nivel de Confianza por Sección

| Sección | Confianza | Fundamento |
|---|---|---|
| Identidad (customers, admin_users) | **ALTA** | Esquema MySQL bien documentado en queries PHP. Cambios de seguridad validados por Security Agent. |
| Catálogo (products, variants, properties) | **ALTA** | Esquema inferido de queries de grilla, detalle y admin CRUD. Las relaciones M:N están confirmadas. |
| Transaccional (carts, orders, payments) | **ALTA** | Carts/checkouts/payments son NUEVOS (no existen en MySQL). Diseñados según gaps y arquitectura propuesta. Orders mapea directamente `pedidos`. |
| Envíos (shipping_methods, branches) | **ALTA** | Tablas simples con queries claras en PHP. |
| Marketing (coupons, promotions) | **ALTA** | Esquema MySQL claro. Lógica de aplicación en PHP validada. |
| Contenido (sliders, banners, faqs) | **MEDIA-ALTA** | Estructura simple. Algunas columnas son inferidas (hipótesis del Auditor). |
| Encuestas (surveys) | **MEDIA** | No se auditó el código de encuestas en profundidad. Schema inferido de nombres de tabla. |
| Configuración (tenant_settings) | **ALTA** | Mapeo directo de `configuracion` key-value. Separación secretos validada por Security Agent. |
| Seguridad (refresh_tokens, audit_logs, webhooks) | **ALTA** | Tablas NUEVAS diseñadas según gaps de seguridad. Sin dependencia del sistema legacy. |

---

*Documento preparado por el Data Architect basado en los 12 outputs previos del equipo (System Auditor, Product Owner, Security Agent, Backend Architect). Los hechos sobre el sistema MySQL actual provienen del System Auditor. El diseño del schema PostgreSQL y las mejoras son decisiones del Data Architect validadas contra los gaps y la arquitectura propuesta.*
