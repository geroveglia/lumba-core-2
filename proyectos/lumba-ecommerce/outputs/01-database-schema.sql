-- Archivo SQL auto-generado a partir de 01-database-schema.md
-- Las tablas han sido reordenadas topológicamente para evitar errores de llaves foráneas (Foreign Keys) durante la importación.

-- ==========================================
-- 1. FUNCIONES DE UTILIDAD
-- ==========================================

CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS trigger AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION update_product_search_vector()
RETURNS trigger AS $$
BEGIN
    NEW.search_vector :=
        setweight(to_tsvector('spanish'::regconfig, coalesce(NEW.nombre, '')), 'A') ||
        setweight(to_tsvector('spanish'::regconfig, coalesce(NEW.descripcion, '')), 'B');
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ==========================================
-- 2. TABLAS BASE (SIN DEPENDENCIAS EXTERNAS)
-- ==========================================

CREATE TABLE provinces (
    id              SERIAL PRIMARY KEY,
    nombre          VARCHAR(100) NOT NULL,
    code            VARCHAR(10),              -- [MEJORA] Código ISO 3166-2:AR (ej: "AR-B")
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE localities (
    id              SERIAL PRIMARY KEY,
    nombre          VARCHAR(255) NOT NULL,
    provincia_id    INTEGER NOT NULL REFERENCES provinces(id),
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX idx_localities_provincia ON localities(provincia_id);

CREATE TABLE postal_codes (
    id              SERIAL PRIMARY KEY,
    codigo          VARCHAR(20) NOT NULL,
    localidad_id    INTEGER NOT NULL REFERENCES localities(id),
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX idx_postal_codes_codigo ON postal_codes(codigo);
CREATE INDEX idx_postal_codes_localidad ON postal_codes(localidad_id);

CREATE TABLE contact_areas (
    id              SERIAL PRIMARY KEY,
    nombre          VARCHAR(100) NOT NULL,     -- "Ventas", "Soporte", "Devoluciones"
    email           VARCHAR(255) NOT NULL,     -- Email destino de los mensajes
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at      TIMESTAMPTZ
);

CREATE TABLE price_lists (
    id              SERIAL PRIMARY KEY,
    nombre          VARCHAR(100) NOT NULL,     -- "Minorista", "Mayorista A", etc.
    predeterminada  BOOLEAN NOT NULL DEFAULT FALSE,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at      TIMESTAMPTZ
);

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

CREATE TABLE tags (
    id                  SERIAL PRIMARY KEY,
    nombre              VARCHAR(100) NOT NULL,
    url                 VARCHAR(255) NOT NULL,
    visible_menu        BOOLEAN NOT NULL DEFAULT FALSE,
    orden               INTEGER DEFAULT 0,
    color_fondo_menu    VARCHAR(7),            -- Color CSS hexadecimal
    color_texto_menu    VARCHAR(7),
    bold_menu           BOOLEAN NOT NULL DEFAULT FALSE,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at          TIMESTAMPTZ
);
CREATE INDEX idx_tags_visible ON tags(visible_menu) WHERE deleted_at IS NULL;
CREATE INDEX idx_tags_orden ON tags(orden) WHERE deleted_at IS NULL;

CREATE TABLE properties (
    id              SERIAL PRIMARY KEY,
    nombre          VARCHAR(100) NOT NULL,     -- "Talle", "Color", "Material"
    orden           INTEGER DEFAULT 0,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at      TIMESTAMPTZ
);

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

CREATE TABLE keywords (
    id          SERIAL PRIMARY KEY,
    keyword     VARCHAR(255) NOT NULL,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at  TIMESTAMPTZ,
    UNIQUE(keyword)
);

CREATE TABLE customer_invoice_types (
    id              SERIAL PRIMARY KEY,
    nombre          VARCHAR(100) NOT NULL,     -- "Factura A", "Factura B", "Ticket"
    predeterminada  BOOLEAN NOT NULL DEFAULT FALSE,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at      TIMESTAMPTZ
);

CREATE TABLE customer_fiscal_situations (
    id          SERIAL PRIMARY KEY,
    nombre      VARCHAR(100) NOT NULL,         -- "Consumidor Final", "Responsable Inscripto", etc.
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at  TIMESTAMPTZ
);

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

CREATE TABLE admin_users (
    id              SERIAL PRIMARY KEY,
    nombre          VARCHAR(100) NOT NULL,
    email           VARCHAR(255) NOT NULL,
    password_hash           VARCHAR(60),       -- bcrypt hash
    password_needs_migration BOOLEAN NOT NULL DEFAULT FALSE,
    legacy_password         VARCHAR(255),      -- [TEMPORAL] contraseña en texto plano original
    tipo_id         INTEGER NOT NULL REFERENCES admin_roles(id),
    predeterminado  BOOLEAN NOT NULL DEFAULT FALSE, -- Vendedor por defecto para clientes nuevos
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at      TIMESTAMPTZ
);
CREATE UNIQUE INDEX idx_admin_email ON admin_users(email) WHERE deleted_at IS NULL;
CREATE INDEX idx_admin_tipo ON admin_users(tipo_id) WHERE deleted_at IS NULL;

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
CREATE INDEX idx_coupons_categorias ON coupons USING gin(aplica_a_categorias);

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
CREATE INDEX idx_promotions_productos ON promotions USING gin(aplica_a_productos);

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
CREATE INDEX idx_shipping_methods_localidades ON shipping_methods USING gin(localidades);

CREATE TABLE shipping_config (
    id              SMALLINT PRIMARY KEY DEFAULT 1 CHECK (id = 1), -- Fila única
    config          JSONB NOT NULL DEFAULT '{}',
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

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

CREATE TABLE home_layout (
    id              SERIAL PRIMARY KEY,
    module_type     VARCHAR(50) NOT NULL CHECK (module_type IN ('slider', 'categories', 'products', 'banners', 'carousel')),
    config          JSONB NOT NULL DEFAULT '{}',
    orden           INTEGER DEFAULT 0,
    activo          BOOLEAN NOT NULL DEFAULT TRUE,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX idx_home_layout_orden ON home_layout(orden) WHERE activo = TRUE;

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

-- ==========================================
-- 3. TABLAS DEPENDIENTES
-- ==========================================

CREATE TABLE customer_types (
    id                  SERIAL PRIMARY KEY,
    nombre              VARCHAR(100) NOT NULL,      -- "Minorista", "Mayorista", etc.
    mercadopago         BOOLEAN NOT NULL DEFAULT TRUE,
    modo                BOOLEAN NOT NULL DEFAULT FALSE,
    transferencia       BOOLEAN NOT NULL DEFAULT TRUE,
    efectivo            BOOLEAN NOT NULL DEFAULT FALSE,
    zipnova             BOOLEAN NOT NULL DEFAULT FALSE,
    zipnova_puntoentrega BOOLEAN NOT NULL DEFAULT FALSE,
    envios_propios      BOOLEAN NOT NULL DEFAULT TRUE,
    retiro_sucursal     BOOLEAN NOT NULL DEFAULT TRUE,
    minimo_compra       NUMERIC(12,2) DEFAULT 0,
    lista_precios_id    INTEGER REFERENCES price_lists(id),
    marcas              JSONB,                     -- IDs de marcas permitidas
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
    registro_habilitado BOOLEAN NOT NULL DEFAULT TRUE,
    predeterminado      BOOLEAN NOT NULL DEFAULT FALSE,
    tipos_comprobante   JSONB,                     -- Array de IDs
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at          TIMESTAMPTZ
);
CREATE INDEX idx_customer_types_predeterminado ON customer_types(predeterminado)
    WHERE deleted_at IS NULL AND predeterminado = TRUE;
CREATE INDEX idx_customer_types_marcas ON customer_types USING gin(marcas);

CREATE TABLE customers (
    id              SERIAL PRIMARY KEY,
    email           VARCHAR(255) NOT NULL,
    nombre          VARCHAR(100) NOT NULL,
    apellido        VARCHAR(100) NOT NULL,
    razon_social    VARCHAR(255),
    nombre_fantasia VARCHAR(255),
    cuit            VARCHAR(20),
    dni             VARCHAR(20),
    iibb            VARCHAR(50),              -- Ingresos Brutos
    area            VARCHAR(10),              -- Código de área telefónico
    telefono        VARCHAR(30),
    password_hash           VARCHAR(60),      -- bcrypt hash (60 chars)
    password_needs_migration BOOLEAN NOT NULL DEFAULT FALSE, -- Flag migración md5→bcrypt
    legacy_md5_hash         VARCHAR(32),      -- [TEMPORAL] hash md5 original
    password_migrated_at    TIMESTAMPTZ,      -- [TEMPORAL] fecha de migración
    hash                    VARCHAR(64),      -- Hash único para activación/recuperación
    hash_expires_at         TIMESTAMPTZ,      -- [MEJORA] expiración del hash (1h recovery)
    activo          BOOLEAN NOT NULL DEFAULT FALSE,  -- Activado vía email
    compro          BOOLEAN NOT NULL DEFAULT FALSE,  -- Ya realizó al menos 1 compra
    marketing       BOOLEAN NOT NULL DEFAULT FALSE,  -- Acepta marketing/newsletter
    tipo_id         INTEGER REFERENCES customer_types(id),
    lista_id        INTEGER REFERENCES price_lists(id),
    tipo_comprobante_id INTEGER REFERENCES customer_invoice_types(id),
    situacion_fiscal_id INTEGER REFERENCES customer_fiscal_situations(id),
    vendedor_id     INTEGER REFERENCES admin_users(id),
    descuento       NUMERIC(5,2) DEFAULT 0,   -- Descuento personalizado (%)
    codigo          VARCHAR(100),             -- Código interno / legacy
    marcas          JSONB,                    -- Array de IDs de marcas permitidas [1,3,5]
    fecha_registro  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at      TIMESTAMPTZ               -- @DeleteDateColumn() TypeORM
);
CREATE UNIQUE INDEX idx_customers_email ON customers(email) WHERE deleted_at IS NULL;
CREATE INDEX idx_customers_tipo ON customers(tipo_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_customers_vendedor ON customers(vendedor_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_customers_hash ON customers(hash) WHERE deleted_at IS NULL;
CREATE INDEX idx_customers_lista ON customers(lista_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_customers_search ON customers
    USING gin (to_tsvector('spanish'::regconfig, coalesce(nombre,'') || ' ' || coalesce(apellido,'') || ' ' || coalesce(email,'')))
    WHERE deleted_at IS NULL;
CREATE TRIGGER trg_customers_updated_at
    BEFORE UPDATE ON customers
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TABLE customer_addresses (
    id              SERIAL PRIMARY KEY,
    customer_id     INTEGER NOT NULL REFERENCES customers(id) ON DELETE CASCADE,
    calle           VARCHAR(255) NOT NULL,
    numero          VARCHAR(20) NOT NULL,
    departamento    VARCHAR(50),
    entre_calles    VARCHAR(255),              -- [MEJORA] Referencia
    cp              VARCHAR(20) NOT NULL,
    provincia_id    INTEGER NOT NULL REFERENCES provinces(id),
    localidad_id    INTEGER NOT NULL REFERENCES localities(id),
    lat             NUMERIC(10,7),             -- [MEJORA] Para mapas futuros
    lng             NUMERIC(10,7),
    etiqueta        VARCHAR(50),               -- [MEJORA] "Casa", "Trabajo"
    predeterminada  BOOLEAN NOT NULL DEFAULT FALSE,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at      TIMESTAMPTZ
);
CREATE UNIQUE INDEX idx_addresses_predeterminada
    ON customer_addresses(customer_id, predeterminada)
    WHERE deleted_at IS NULL AND predeterminada = TRUE;
CREATE INDEX idx_addresses_customer ON customer_addresses(customer_id) WHERE deleted_at IS NULL;

CREATE TABLE products (
    id              SERIAL PRIMARY KEY,
    nombre          VARCHAR(255) NOT NULL,
    url             VARCHAR(255) NOT NULL,     -- Slug único para URLs
    descripcion     TEXT,                      -- HTML sanitizado (el admin usa WYSIWYG)
    marca_id        INTEGER REFERENCES brands(id),
    iva             NUMERIC(5,2) DEFAULT 21,   -- IVA del producto
    foto            VARCHAR(500),              -- Path/URL de la foto principal
    destacado       BOOLEAN NOT NULL DEFAULT FALSE,
    orden           INTEGER DEFAULT 0,
    activo          BOOLEAN NOT NULL DEFAULT TRUE,
    codigo          VARCHAR(100),              -- Código interno / SKU principal
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
CREATE TRIGGER trg_products_search_vector
    BEFORE INSERT OR UPDATE ON products
    FOR EACH ROW EXECUTE FUNCTION update_product_search_vector();

CREATE TABLE product_categories (
    product_id      INTEGER NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    category_id     INTEGER NOT NULL REFERENCES categories(id) ON DELETE CASCADE,
    PRIMARY KEY (product_id, category_id)
);
CREATE INDEX idx_product_categories_category ON product_categories(category_id);

CREATE TABLE product_tags (
    product_id      INTEGER NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    tag_id          INTEGER NOT NULL REFERENCES tags(id) ON DELETE CASCADE,
    PRIMARY KEY (product_id, tag_id)
);

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

CREATE TABLE variant_property_values (
    variant_id      INTEGER NOT NULL REFERENCES product_variants(id) ON DELETE CASCADE,
    property_value_id INTEGER NOT NULL REFERENCES property_values(id) ON DELETE CASCADE,
    PRIMARY KEY (variant_id, property_value_id)
);
CREATE INDEX idx_vpv_value ON variant_property_values(property_value_id);

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
ALTER TABLE product_variant_stock ADD CONSTRAINT chk_stock_non_negative
    CHECK (stock_infinito = TRUE OR stock >= 0);

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

CREATE TABLE product_property_values (
    product_id      INTEGER NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    property_value_id INTEGER NOT NULL REFERENCES property_values(id) ON DELETE CASCADE,
    PRIMARY KEY (product_id, property_value_id)
);
CREATE INDEX idx_ppv_value ON product_property_values(property_value_id);

CREATE TABLE product_keywords (
    product_id  INTEGER NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    keyword_id  INTEGER NOT NULL REFERENCES keywords(id) ON DELETE CASCADE,
    PRIMARY KEY (product_id, keyword_id)
);

CREATE TABLE related_products (
    product_id              INTEGER NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    related_product_id      INTEGER NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    PRIMARY KEY (product_id, related_product_id),
    CHECK (product_id != related_product_id)  -- Un producto no puede relacionarse consigo mismo
);

CREATE TABLE carts (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(), -- UUID: no secuencial, seguro para URLs
    customer_id     INTEGER REFERENCES customers(id),     -- NULL si es anónimo
    session_token   VARCHAR(255),                         -- JWT anónimo o token de sesión
    coupon_code     VARCHAR(100),
    coupon_value    NUMERIC(12,2),
    coupon_type     VARCHAR(50),                         -- 'Porcentaje', 'Monto fijo', 'Envío gratis'
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE UNIQUE INDEX idx_carts_customer ON carts(customer_id) WHERE customer_id IS NOT NULL;
CREATE INDEX idx_carts_session ON carts(session_token);
CREATE INDEX idx_carts_stale ON carts(updated_at);  -- Para limpieza de carritos viejos

CREATE TABLE cart_items (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    cart_id         UUID NOT NULL REFERENCES carts(id) ON DELETE CASCADE,
    product_id      INTEGER NOT NULL REFERENCES products(id),
    variant_id      INTEGER NOT NULL REFERENCES product_variants(id),
    cantidad        INTEGER NOT NULL CHECK (cantidad > 0),
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

CREATE TABLE orders (
    id                  SERIAL PRIMARY KEY,
    hash                VARCHAR(64) NOT NULL,   -- Identificador público único (no secuencial)
    customer_id         INTEGER REFERENCES customers(id),
    lista_id            INTEGER REFERENCES price_lists(id),
    branch_id           INTEGER REFERENCES branches(id),
    fecha               TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    email               VARCHAR(255) NOT NULL,
    nombre              VARCHAR(100),
    apellido            VARCHAR(100),
    area                VARCHAR(10),
    telefono            VARCHAR(30),
    dni                 VARCHAR(20),
    newsletter          BOOLEAN NOT NULL DEFAULT FALSE,
    origen              VARCHAR(50) DEFAULT 'Web',
    razon_social        VARCHAR(255),
    nombre_fantasia     VARCHAR(255),
    cuit                VARCHAR(20),
    tipo_cliente        VARCHAR(100),
    situacion_fiscal    VARCHAR(100),
    tipo_comprobante    VARCHAR(100),
    shipping_address    JSONB,
    billing_address     JSONB,
    forma_entrega       VARCHAR(100) NOT NULL,  -- 'retiro_sucursal', 'envio_domicilio', 'zipnova_sucursal'
    sucursal_id         INTEGER REFERENCES branches(id),
    costo_envio         NUMERIC(12,2) DEFAULT 0,
    costo_envio_real    NUMERIC(12,2) DEFAULT 0,
    zipnova_opcion      VARCHAR(100),
    zipnova_point_id    VARCHAR(100),
    zipnova_json        JSONB,
    tracking_number     VARCHAR(255),           -- [MEJORA] Número de tracking
    tracking_url        VARCHAR(500),           -- [MEJORA] URL de tracking público
    forma_pago          VARCHAR(100),           -- 'mercadopago', 'modo', 'transferencia', 'efectivo'
    payment_provider    VARCHAR(50),            -- [MEJORA] Normalizado: 'mercadopago', 'modo', etc.
    payment_external_id VARCHAR(255),           -- [MEJORA] ID de transacción externa (MP preference_id, Modo payment_id)
    cupon               VARCHAR(100),
    cupon_valor         NUMERIC(12,2),
    cupon_tipo          VARCHAR(50),            -- 'Porcentaje', 'Monto fijo', 'Envío gratis'
    subtotal            NUMERIC(12,2) NOT NULL DEFAULT 0,
    descuentos          NUMERIC(12,2) NOT NULL DEFAULT 0,
    iva_total           NUMERIC(12,2) NOT NULL DEFAULT 0,
    total               NUMERIC(12,2) NOT NULL DEFAULT 0,
    estado              VARCHAR(50) NOT NULL DEFAULT 'Incompleto',   -- 'Incompleto', 'Activo', 'Reintegrado'
    estado_pago         VARCHAR(50) NOT NULL DEFAULT 'Pendiente',    -- 'Pendiente', 'Pagado', 'Reintegrado'
    estado_entrega      VARCHAR(50) NOT NULL DEFAULT 'Pendiente',    -- 'Pendiente', 'Enviado', 'Entregado'
    estado_factura      VARCHAR(50) NOT NULL DEFAULT 'Pendiente',    -- 'Pendiente', 'Facturado'
    cron_notificado     BOOLEAN NOT NULL DEFAULT FALSE,
    cron_notificado_at  TIMESTAMPTZ,            -- [MEJORA] Cuándo se notificó
    observaciones       TEXT,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at          TIMESTAMPTZ
);
CREATE UNIQUE INDEX idx_orders_hash ON orders(hash);
CREATE INDEX idx_orders_customer ON orders(customer_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_orders_fecha ON orders(fecha DESC) WHERE deleted_at IS NULL;
CREATE INDEX idx_orders_estado ON orders(estado) WHERE deleted_at IS NULL;
CREATE INDEX idx_orders_estado_pago ON orders(estado_pago) WHERE deleted_at IS NULL;
CREATE INDEX idx_orders_estado_entrega ON orders(estado_entrega) WHERE deleted_at IS NULL;
CREATE INDEX idx_orders_branch ON orders(branch_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_orders_cron ON orders(cron_notificado, estado, fecha)
    WHERE deleted_at IS NULL AND estado = 'Incompleto' AND cron_notificado = FALSE;
ALTER TABLE orders ADD CONSTRAINT chk_orders_estado
    CHECK (estado IN ('Incompleto', 'Activo', 'Reintegrado'));
ALTER TABLE orders ADD CONSTRAINT chk_orders_estado_pago
    CHECK (estado_pago IN ('Pendiente', 'Pagado', 'Reintegrado'));
ALTER TABLE orders ADD CONSTRAINT chk_orders_estado_entrega
    CHECK (estado_entrega IN ('Pendiente', 'Enviado', 'Entregado'));
ALTER TABLE orders ADD CONSTRAINT chk_orders_total_non_negative
    CHECK (total >= 0);

CREATE TABLE checkouts (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    cart_id         UUID NOT NULL REFERENCES carts(id),
    customer_id     INTEGER REFERENCES customers(id),
    order_id        INTEGER REFERENCES orders(id),  -- Se crea en paso 1 con estado 'Incompleto'
    paso_actual     SMALLINT NOT NULL DEFAULT 1 CHECK (paso_actual BETWEEN 1 AND 4),
    datos_personales JSONB,     -- Paso 1: nombre, email, tipo cliente, facturación
    datos_envio      JSONB,     -- Paso 2: dirección, sucursal, método envío
    datos_pago       JSONB,     -- Paso 3: método de pago
    completado      BOOLEAN NOT NULL DEFAULT FALSE,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX idx_checkouts_cart ON checkouts(cart_id);
CREATE INDEX idx_checkouts_customer ON checkouts(customer_id);

CREATE TABLE order_items (
    id                  SERIAL PRIMARY KEY,
    order_id            INTEGER NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    product_id          INTEGER REFERENCES products(id),
    variant_id          INTEGER REFERENCES product_variants(id),
    producto            VARCHAR(255) NOT NULL,  -- Nombre del producto
    producto_sku        VARCHAR(100),
    foto                VARCHAR(500),
    propiedades         VARCHAR(500),           -- "Talle XL / Color Rojo" (concatenado)
    cantidad            INTEGER NOT NULL CHECK (cantidad > 0),
    precio_abonado      NUMERIC(12,2) NOT NULL,  -- Precio final cobrado
    precio_original     NUMERIC(12,2) NOT NULL,  -- Precio de lista sin descuentos
    iva                 NUMERIC(5,2) DEFAULT 21,
    promotion_id        INTEGER REFERENCES promotions(id),
    promotion_nombre    VARCHAR(255),
    promotion_tipo      VARCHAR(50),
    promotion_valor     NUMERIC(12,2),
    aplica_cupon        BOOLEAN NOT NULL DEFAULT FALSE,
    codigo_cupon        VARCHAR(100),
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX idx_order_items_order ON order_items(order_id);
CREATE INDEX idx_order_items_product ON order_items(product_id);

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

CREATE TABLE payments (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id            INTEGER NOT NULL REFERENCES orders(id),
    provider            VARCHAR(50) NOT NULL,   -- 'mercadopago', 'modo', 'transferencia', 'efectivo'
    external_id         VARCHAR(255),           -- ID en el provider (MP payment_id, Modo transaction_id)
    status              VARCHAR(50) NOT NULL DEFAULT 'pending', -- 'pending', 'approved', 'rejected', 'refunded'
    amount              NUMERIC(12,2) NOT NULL,
    currency            VARCHAR(3) DEFAULT 'ARS',
    provider_metadata   JSONB,                  -- MP: {preference_id, payment_method_id, ...}, Modo: {...}
    comprobante_url     VARCHAR(500),           -- Path al archivo subido
    initiated_at        TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    completed_at        TIMESTAMPTZ,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(order_id, provider)                  -- Un pago por pedido+provider
);
CREATE INDEX idx_payments_order ON payments(order_id);
CREATE INDEX idx_payments_external ON payments(provider, external_id);
CREATE INDEX idx_payments_status ON payments(status);

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

CREATE TABLE wishlists (
    customer_id     INTEGER NOT NULL REFERENCES customers(id) ON DELETE CASCADE,
    product_id      INTEGER NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    PRIMARY KEY (customer_id, product_id)
);

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
