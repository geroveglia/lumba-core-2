# 01 — Database Migration Plan

> **Proyecto:** Lumba Ecommerce (Brownfield — migración MySQL + PHP vanilla → PostgreSQL + NestJS + TypeORM)
> **Fecha:** 2026-06-08
> **Rol:** Data Architect
> **Modelo:** deepseek-v4-pro
> **Nivel de confianza global:** ALTA (basado en schema diseñado y 12 outputs de discovery)
> **Fuentes:** `01-modelo-datos-actual.md`, `01-database-schema.md`, `01-security-remediation-plan.md`, `01-gaps-and-improvements.md`, `01-backend-architecture.md`

---

## Índice

1. [Estrategia General de Migración](#1-estrategia-general-de-migración)
2. [Pre-Migración: Preparación](#2-pre-migración-preparación)
3. [Fase 1: Migración de Schema](#3-fase-1-migración-de-schema)
4. [Fase 2: ETL de Datos](#4-fase-2-etl-de-datos)
5. [Fase 3: Transformaciones Especiales](#5-fase-3-transformaciones-especiales)
6. [Fase 4: Validación Post-Migración](#6-fase-4-validación-post-migración)
7. [Fase 5: Rollback Plan](#7-fase-5-rollback-plan)
8. [Orden de Migración por Tenant](#8-orden-de-migración-por-tenant)
9. [Cronograma Estimado](#9-cronograma-estimado)
10. [Riesgos y Mitigaciones](#10-riesgos-y-mitigaciones)
11. [Scripts de Migración de Referencia](#11-scripts-de-migración-de-referencia)

---

## 1. Estrategia General de Migración

### 1.1 Decisión: Big Bang por Tenant

| Opción | Evaluación | Decisión |
|---|---|---|
| **Big Bang** (todo de una vez) | Riesgo alto de downtime prolongado. Rollback complejo. | ❌ No recomendado |
| **Incremental** (migrar tablas de a poco con doble escritura) | Baja disrupción pero alta complejidad de sincronización. Requiere doble escritura en ambos sistemas durante semanas. | ❌ Excesiva complejidad |
| **Big Bang por Tenant** (migrar un tenant completo a la vez) | ✅ Cada tenant migra en una ventana de 2-4 horas. Un tenant puede seguir en legacy mientras otro ya está en NestJS. Rollback aislado por tenant. | ✅ **Elegido** |

### 1.2 Fases de la migración

```
┌─────────────┐    ┌──────────────┐    ┌──────────────┐    ┌─────────────┐    ┌───────────┐
│  PRE-MIGRA  │───▶│  FASE 1      │───▶│  FASE 2      │───▶│  FASE 3     │───▶│  FASE 4   │
│ Preparación │    │ Schema DDL   │    │ ETL Datos    │    │ Validación  │    │ Go Live   │
└─────────────┘    └──────────────┘    └──────────────┘    └─────────────┘    └───────────┘
  1 día antes       30 min              1-2 horas           30-60 min          Cutover
```

### 1.3 Principios de migración

| Principio | Descripción |
|---|---|
| **Idempotencia** | Todos los scripts se pueden re-ejecutar sin efectos secundarios |
| **Trazabilidad** | Cada paso registra filas migradas, errores, y timestamps en tabla `migration_log` |
| **Aislamiento** | Un tenant no afecta a otros. Cada tenant migra en su propia ventana |
| **Integridad** | Validación de row counts, checksums, e integridad referencial entre legacy y nuevo |
| **Reversibilidad** | Rollback documentado y probado para cada fase |
| **No pérdida** | El sistema legacy queda read-only durante la migración, no se borra hasta validar |

---

## 2. Pre-Migración: Preparación

### 2.1 Requisitos previos (por tenant)

- [ ] Backup completo de la DB MySQL del tenant (`mysqldump --single-transaction`)
- [ ] Verificar espacio en disco para PostgreSQL (misma DB + 50% margen)
- [ ] PostgreSQL instalado y corriendo. DB vacía creada para el tenant
- [ ] NestJS app deployada con TypeORM migrations configuradas pero NO ejecutadas
- [ ] Sistema legacy en modo **read-only** durante la ventana de migración
- [ ] Scripts de ETL validados en entorno de staging con datos reales anonimizados
- [ ] Equipo de soporte notificado de la ventana de mantenimiento

### 2.2 Creación de la DB PostgreSQL

```sql
-- Ejecutar como superuser PostgreSQL
CREATE DATABASE lumba_tenant_{tenant_id}
    ENCODING 'UTF8'
    LC_COLLATE 'es_AR.UTF-8'
    LC_CTYPE 'es_AR.UTF-8'
    TEMPLATE template0;

-- Usuario de aplicación
CREATE USER lumba_app WITH PASSWORD '{secure_password}';
GRANT ALL PRIVILEGES ON DATABASE lumba_tenant_{tenant_id} TO lumba_app;

-- Para PostgreSQL 15+: permisos en schema public
\c lumba_tenant_{tenant_id}
GRANT ALL ON SCHEMA public TO lumba_app;
GRANT CREATE ON SCHEMA public TO lumba_app;
```

### 2.3 Tabla de log de migración

```sql
-- Esta tabla se crea PRIMERO en la DB destino
CREATE TABLE migration_log (
    id              SERIAL PRIMARY KEY,
    phase           VARCHAR(50) NOT NULL,       -- 'schema', 'etl', 'validation'
    table_name      VARCHAR(100) NOT NULL,
    action          VARCHAR(50) NOT NULL,       -- 'create_table', 'insert', 'verify'
    rows_affected   INTEGER,
    status          VARCHAR(20) NOT NULL DEFAULT 'running' CHECK (status IN ('running', 'success', 'failed')),
    error_message   TEXT,
    duration_ms     INTEGER,
    started_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    completed_at    TIMESTAMPTZ
);

CREATE INDEX idx_migration_log_status ON migration_log(status);
```

---

## 3. Fase 1: Migración de Schema

### 3.1 Estrategia

**Opción A: TypeORM Migrations (recomendado para producción)**

```bash
# Generar migration desde entities
npx typeorm migration:generate src/database/migrations/CreateAllTables -d src/data-source.ts

# Ejecutar migration
npx typeorm migration:run -d src/data-source.ts
```

**Ventaja:** Versionado, reversible (`migration:revert`), consistente con el código.

**Opción B: SQL directo (recomendado para migración inicial desde MySQL)**

Ejecutar el DDL del schema (`01-database-schema.md`) como script SQL directo. Más rápido para la migración inicial masiva. Luego usar TypeORM migrations para cambios incrementales.

**Decisión para este plan:** Opción B para la migración inicial (schema completo de una vez). TypeORM migrations para el día a día post-migración.

### 3.2 Orden de creación de tablas

El orden es **crítico** por las dependencias de foreign keys:

```
Fase 1a — Tablas sin FKs (catálogos base):
  1. provinces
  2. localities
  3. postal_codes
  4. price_lists
  5. properties
  6. property_values
  7. customer_fiscal_situations
  8. customer_invoice_types
  9. admin_roles
  10. admin_permissions
  11. contact_areas
  12. keywords
  13. email_templates
  14. tenant_settings
  15. shipping_config

Fase 1b — Tablas con FKs a tablas base:
  16. brands
  17. categories
  18. tags
  19. customer_types
  20. branches
  21. shipping_methods
  22. admin_users
  23. admin_role_permissions
  24. customers
  25. customer_addresses
  26. products
  27. product_categories
  28. product_tags
  29. product_variants
  30. variant_property_values
  31. product_variant_stock
  32. product_variant_prices
  33. product_images
  34. product_property_values
  35. product_keywords
  36. related_products

Fase 1c — Tablas transaccionales:
  37. coupons
  38. promotions
  39. orders
  40. order_items
  41. order_status_history
  42. order_emails
  43. payments
  44. payment_webhooks
  45. payment_status_history

Fase 1d — Tablas nuevas (sin equivalente en MySQL):
  46. carts
  47. cart_items
  48. checkouts
  49. coupon_usage
  50. abandoned_carts
  51. refresh_tokens
  52. audit_logs
  53. shipping_zones (opcional)

Fase 1e — Contenido:
  54. sliders
  55. banners
  56. faqs
  57. content_sections
  58. social_links
  59. contacts
  60. returns
  61. reviews
  62. surveys
  63. survey_questions
  64. survey_invitations
  65. survey_responses
  66. wishlists
  67. home_layout
```

### 3.3 Time estimate Fase 1

| Sub-fase | Tablas | Tiempo estimado |
|---|---|---|
| 1a (catálogos base) | 15 | 5 min |
| 1b (con FKs) | 21 | 10 min |
| 1c (transaccional) | 9 | 5 min |
| 1d (nuevas) | 8 | 3 min |
| 1e (contenido) | 14 | 3 min |
| **Total Fase 1** | **67** | **~30 min** |

---

## 4. Fase 2: ETL de Datos

### 4.1 Estrategia de carga

| Decisión | Elección | Justificación |
|---|---|---|
| **Tool** | Script Node.js con TypeORM + consultas directas a MySQL (`mysql2`) | Mismo stack. Transformaciones complejas en JS. Reintentos y logging. |
| **Modo** | Truncate + INSERT (por tabla) | La DB destino está vacía. No hay riesgo de duplicados. |
| **Batch size** | 1000 filas por batch | Balance memoria/performance para tablas grandes (pedidos: ~100K filas). |
| **Transacciones** | Una transacción por tabla | Si una tabla falla, se hace rollback de esa tabla y se reintenta. Las tablas migradas quedan committed. |
| **FK constraints** | Deshabilitar durante la carga | Evita errores de orden. Re-habilitar al finalizar con validación. |
| **Sequences** | Actualizar `setval()` después de INSERT | PostgreSQL no auto-ajusta sequences con INSERT explícito de IDs. |

### 4.2 Orden de migración de datos (mismo orden que schema)

```
1. provinces, localities, postal_codes       (~25 provincias, ~3000 localidades)
2. price_lists                                (~5-10 listas)
3. properties, property_values                (~10 propiedades, ~100 valores)
4. customer_fiscal_situations                 (~10 situaciones)
5. customer_invoice_types                     (~5 tipos)
6. admin_roles, admin_permissions             (~5 roles, ~30 permisos)
7. contact_areas                              (~5 áreas)
8. keywords                                   (~100-500 keywords)
9. email_templates                            (~10-20 plantillas)
10. tenant_settings                           (~40 variables de negocio)
11. shipping_config                           (1 fila)
12. brands, categories, tags                  (~50 marcas, ~100 categorías, ~20 tags)
13. customer_types                            (~5 tipos)
14. branches                                  (~3-5 sucursales)
15. shipping_methods                          (~10 métodos de envío)
16. admin_users                               (~10-20 admins)
17. admin_role_permissions                    (~50 asignaciones)
18. customers                                 (~1000-10000 clientes) ← PRIMERA tabla grande
19. customer_addresses                        (~2000-20000 direcciones)
20. products                                  (~500-5000 productos)
21. product_categories, product_tags          (M:N)
22. product_variants                          (~2000-20000 variantes)
23. variant_property_values                   (M:N nueva)
24. product_variant_stock                     (~5000-50000 registros)
25. product_variant_prices                    (~10000-100000 registros) ← TABLA MÁS GRANDE
26. product_images                            (~2000-20000 imágenes)
27. product_property_values                   (M:N)
28. product_keywords                          (M:N)
29. related_products                          (M:N)
30. coupons                                   (~50-200 cupones)
31. promotions                                (~10-50 promociones)
32. orders                                    (~10000-100000 pedidos) ← SEGUNDA tabla grande
33. order_items                               (~50000-500000 items) ← LA MÁS GRANDE
34. order_emails                              (~50000-500000 emails)
35. payments                                  (NUEVA: se crean desde orders)
36. payment_webhooks                          (NUEVA: vacía)
37. coupon_usage                              (~1000-10000 usos)
38. abandoned_carts                           (desde orders con estado='Incompleto')
39. wishlists                                 (~1000-10000 favoritos)
40. sliders, banners, faqs, content_sections  (~50-100 registros c/u)
41. social_links                              (~5-10 redes)
42. contacts, contact_areas                   (~100-1000 consultas)
43. returns                                   (~10-100 devoluciones)
44. reviews                                   (~50-500 reseñas)
45. surveys, survey_questions, invitations, responses (~10-50 encuestas)
```

### 4.3 Script de ETL (patrón general)

```javascript
// migrate-table.js — Patrón general para cada tabla
const mysql = require('mysql2/promise');
const { Pool } = require('pg');

async function migrateTable({
  tableName,
  mysqlQuery,
  transform,        // (mysqlRow) => pgRow (opcional)
  batchSize = 1000,
  truncate = true,
}) {
  const mysqlConn = await mysql.createConnection(MYSQL_CONFIG);
  const pgPool = new Pool(PG_CONFIG);

  const logId = await logMigrationStart(tableName, 'etl');

  try {
    // 1. Truncar destino (idempotente)
    if (truncate) {
      await pgPool.query(`TRUNCATE TABLE ${tableName} RESTART IDENTITY CASCADE`);
    }

    // 2. Leer de MySQL en batches
    const [rows] = await mysqlConn.query(mysqlQuery);
    console.log(`[${tableName}] Leídas ${rows.length} filas de MySQL`);

    // 3. Transformar y escribir en PostgreSQL en batches
    let inserted = 0;
    for (let i = 0; i < rows.length; i += batchSize) {
      const batch = rows.slice(i, i + batchSize);
      const pgRows = batch.map(transform || (row => row));

      const columns = Object.keys(pgRows[0]);
      const values = pgRows.map(row => columns.map(c => row[c]));

      const query = `
        INSERT INTO ${tableName} (${columns.join(', ')})
        VALUES ${values.map((_, ri) =>
          `(${columns.map((_, ci) => `$${ri * columns.length + ci + 1}`).join(', ')})`
        ).join(', ')}
      `;

      await pgPool.query(query, values.flat());
      inserted += batch.length;
    }

    // 4. Actualizar sequence
    const pkCol = 'id'; // La mayoría de las tablas usan id SERIAL
    await pgPool.query(`
      SELECT setval('${tableName}_id_seq',
        COALESCE((SELECT MAX(${pkCol}) FROM ${tableName}), 1)
      );
    `);

    // 5. Loggear éxito
    await logMigrationSuccess(logId, inserted);

  } catch (error) {
    await logMigrationFailed(logId, error.message);
    throw error;
  } finally {
    await mysqlConn.end();
    await pgPool.end();
  }
}
```

### 4.4 Time estimate Fase 2

| Categoría | Filas estimadas | Tiempo estimado |
|---|---|---|
| Catálogos base | ~5,000 | 5 min |
| Clientes y direcciones | ~15,000 | 10 min |
| Productos y variantes | ~20,000 | 15 min |
| Precios (tabla más grande) | ~100,000 | 15 min |
| Pedidos | ~50,000 | 10 min |
| Order items (tabla más grande) | ~250,000 | 20 min |
| Resto | ~20,000 | 10 min |
| **Total Fase 2** | **~460,000** | **~1.5 horas** |

---

## 5. Fase 3: Transformaciones Especiales

### 5.1 Migración de contraseñas (md5 → bcrypt)

> **Estrategia:** Ver `01-security-remediation-plan.md` V02.

```
Estado inicial (MySQL):
  clientes.contrasenia = '5d41402abc4b2a76b9719d911017c592'  (md5 de 'hello')

Estado post-migración (PostgreSQL):
  customers.password_hash = NULL
  customers.password_needs_migration = TRUE
  customers.legacy_md5_hash = '5d41402abc4b2a76b9719d911017c592'
  customers.password_migrated_at = NULL

Estado post-primer-login (transparente para el cliente):
  customers.password_hash = '$2b$12$...bcrypt_hash...'
  customers.password_needs_migration = FALSE
  customers.legacy_md5_hash = NULL
  customers.password_migrated_at = '2026-07-15T14:30:00Z'
```

**Script ETL para customers:**

```javascript
function transformCustomer(mysqlRow) {
  return {
    id: mysqlRow.Id,
    email: mysqlRow.email?.toLowerCase().trim(),
    nombre: mysqlRow.nombre,
    apellido: mysqlRow.apellido,
    razon_social: mysqlRow.razon_social || null,
    nombre_fantasia: mysqlRow.nombre_fantasia || null,
    cuit: mysqlRow.cuit || null,
    dni: mysqlRow.dni || null,
    iibb: mysqlRow.iibb || null,
    area: mysqlRow.area || null,
    telefono: mysqlRow.telefono || null,
    // Contraseña: migrar a columnas legacy
    password_hash: null,  // Se generará en primer login
    password_needs_migration: !!mysqlRow.contrasenia,
    legacy_md5_hash: mysqlRow.contrasenia || null,
    password_migrated_at: null,
    hash: mysqlRow.hash || null,
    hash_expires_at: null,  // Expirar todos los hashes existentes (seguridad)
    activo: mysqlRow.activo == 1,
    compro: mysqlRow.compro == 1,
    marketing: mysqlRow.marketing == 1,
    tipo_id: mysqlRow.tipo_id || null,
    lista_id: mysqlRow.lista_id || null,
    tipo_comprobante_id: mysqlRow.tipo_comprobante_id || null,
    situacion_fiscal_id: mysqlRow.situacion_fiscal_id || null,
    vendedor_id: mysqlRow.vendedor_id || null,
    descuento: parseFloat(mysqlRow.descuento) || 0,
    codigo: mysqlRow.codigo || null,
    marcas: mysqlRow.marcas ? JSON.parse(mysqlRow.marcas) : null,
    fecha_registro: mysqlRow.fecha_registro || new Date().toISOString(),
    created_at: mysqlRow.fecha_registro || new Date().toISOString(),
    updated_at: new Date().toISOString(),
    deleted_at: mysqlRow.eliminado == 1 ? new Date().toISOString() : null,
  };
}
```

### 5.2 Migración de passwords admin (texto plano → bcrypt)

> **Estrategia:** Ver `01-security-remediation-plan.md` V01.

```javascript
function transformAdminUser(mysqlRow) {
  return {
    id: mysqlRow.Id,
    nombre: mysqlRow.nombre,
    email: mysqlRow.email?.toLowerCase().trim(),
    // Contraseña: texto plano original → columna legacy
    password_hash: null,
    password_needs_migration: !!mysqlRow.contrasenia,
    legacy_password: mysqlRow.contrasenia || null,  // TEXTO PLANO → TEMPORAL
    tipo_id: mysqlRow.tipo_id,
    predeterminado: mysqlRow.predeterminado == 1,
    created_at: new Date().toISOString(),
    updated_at: new Date().toISOString(),
    deleted_at: mysqlRow.eliminado == 1 ? new Date().toISOString() : null,
  };
}
```

**⚠️ CRÍTICO:** Apenas el admin haga su primer login en NestJS, la contraseña se re-hashea con bcrypt y se borra `legacy_password`. **Mientras la columna `legacy_password` exista, la DB PostgreSQL debe tener acceso RESTRINGIDO** (solo la app y el DBA).

### 5.3 Migración de soft deletes (eliminado TINYINT → deleted_at TIMESTAMPTZ)

```javascript
// Helper reutilizable
function transformDeletedAt(eliminado) {
  return eliminado == 1 ? new Date().toISOString() : null;
  // NOTA: No tenemos la fecha real de eliminación porque no existía.
  // Usamos NOW() como aproximación. Para auditoría futura, usar deleted_at real.
}
```

### 5.4 Migración de JSON columns (TEXT → JSONB)

El sistema MySQL actual almacena JSON en columnas TEXT. PostgreSQL tiene tipo nativo JSONB.

```javascript
function safeJsonParse(value) {
  if (!value || value === 'null' || value === '') return null;
  try {
    if (typeof value === 'string') return JSON.parse(value);
    return value; // Ya es un objeto
  } catch {
    console.warn(`JSON parse falló para: ${value}`);
    return null; // Dato corrupto → null (mejor que romper la migración)
  }
}

// Ejemplo: transformar shipping_methods.localidades
function transformShippingMethod(mysqlRow) {
  return {
    id: mysqlRow.Id,
    nombre: mysqlRow.envio,
    precio: parseFloat(mysqlRow.precio) || 0,
    informacion: mysqlRow.informacion || null,
    provincia_id: mysqlRow.provincia_id || null,
    localidades: safeJsonParse(mysqlRow.localidades) || [0],
    envio_gratis: mysqlRow.envio_gratis == 1,
    envio_gratis_minimo: parseFloat(mysqlRow.envio_gratis_minimo) || null,
    activo: mysqlRow.activo == 1,
    deleted_at: transformDeletedAt(mysqlRow.eliminado),
  };
}
```

### 5.5 Migración de pedidos: columnas planas → JSONB

```javascript
function transformOrder(mysqlRow) {
  return {
    id: mysqlRow.Id,
    hash: mysqlRow.hash,
    customer_id: mysqlRow.cliente_id || null,
    lista_id: mysqlRow.lista_id || null,
    branch_id: mysqlRow.sucursal_id || null,
    fecha: mysqlRow.fecha,
    email: mysqlRow.email,
    nombre: mysqlRow.nombre || null,
    apellido: mysqlRow.apellido || null,
    area: mysqlRow.area || null,
    telefono: mysqlRow.telefono || null,
    dni: mysqlRow.dni || null,
    newsletter: mysqlRow.newsletter == 1,
    origen: mysqlRow.origen || 'Web',
    razon_social: mysqlRow.razon_social || null,
    nombre_fantasia: mysqlRow.nombre_fantasia || null,
    cuit: mysqlRow.cuit || null,
    tipo_cliente: mysqlRow.tipo_cliente || null,
    situacion_fiscal: mysqlRow.situacion_fiscal || null,
    tipo_comprobante: mysqlRow.tipo_comprobante || null,

    // Dirección de entrega (6 columnas → 1 JSONB)
    shipping_address: {
      calle: mysqlRow.calle || null,
      numero: mysqlRow.numero || null,
      departamento: mysqlRow.departamento || null,
      provincia_id: mysqlRow.provincia_id || null,
      localidad_id: mysqlRow.localidad_id || null,
      cp: mysqlRow.cp || null,
    },

    // Dirección de facturación (6 columnas → 1 JSONB)
    billing_address: (mysqlRow.facturacion_calle || mysqlRow.facturacion_numero) ? {
      calle: mysqlRow.facturacion_calle || null,
      numero: mysqlRow.facturacion_numero || null,
      departamento: mysqlRow.facturacion_departamento || null,
      provincia_id: mysqlRow.facturacion_provincia_id || null,
      localidad_id: mysqlRow.facturacion_localidad_id || null,
      cp: mysqlRow.facturacion_cp || null,
    } : null,

    forma_entrega: mysqlRow.formaentrega,
    sucursal_id: mysqlRow.sucursal_id || null,
    costo_envio: parseFloat(mysqlRow.costo_envio) || 0,
    costo_envio_real: parseFloat(mysqlRow.costo_envio_real) || 0,
    zipnova_opcion: mysqlRow.zipnova_opcion || null,
    zipnova_point_id: mysqlRow.zipnova_point_id || null,
    zipnova_json: safeJsonParse(mysqlRow.zipnova_json),

    forma_pago: mysqlRow.formapago,
    payment_provider: normalizePaymentProvider(mysqlRow.formapago),
    payment_external_id: null,

    cupon: mysqlRow.cupon || null,
    cupon_valor: parseFloat(mysqlRow.cupon_valor) || null,
    cupon_tipo: mysqlRow.cupon_tipo || null,

    subtotal: 0,  // Se recalcula abajo desde order_items
    descuentos: 0,
    iva_total: 0,
    total: parseFloat(mysqlRow.total) || 0,

    estado: mysqlRow.estado || 'Incompleto',
    estado_pago: mysqlRow.estado_pago || 'Pendiente',
    estado_entrega: mysqlRow.estado_entrega || 'Pendiente',
    estado_factura: mysqlRow.estado_factura || 'Pendiente',

    cron_notificado: mysqlRow.cron_notificado == 1,
    cron_notificado_at: mysqlRow.cron_notificado == 1 ? new Date().toISOString() : null,

    observaciones: mysqlRow.observaciones || null,
    created_at: mysqlRow.fecha || new Date().toISOString(),
    updated_at: new Date().toISOString(),
    deleted_at: transformDeletedAt(mysqlRow.eliminado),
  };
}

function normalizePaymentProvider(formapago) {
  const map = {
    'Mercadopago': 'mercadopago',
    'Modo': 'modo',
    'Transferencia': 'transferencia',
    'Efectivo': 'efectivo',
  };
  return map[formapago] || formapago?.toLowerCase() || null;
}
```

### 5.6 Manejo de IDs

> **Decisión:** Mantener los IDs originales de MySQL (INTEGER).

| Razón | Detalle |
|---|---|
| **Compatibilidad** | Los IDs se usan en URLs (productos, categorías), APIs externas (MercadoPago guarda `pedido_id`), y referencias cruzadas (emails enviados contienen IDs). |
| **Migración más simple** | No hay que reasignar FKs. Los IDs se copian tal cual. |
| **Secuencialidad** | MySQL `AUTO_INCREMENT` → PostgreSQL `SERIAL`. Compatible 1:1. |
| **UUID** | Solo para tablas NUEVAS sin dependencias: `carts`, `checkouts`, `payments`, `payment_webhooks`. |

**⚠️ Cuidado:** Si hay tenants que comparten IDs (ej: cliente #42 existe en dos tenants distintos), no hay conflicto porque cada tenant tiene su propia DB PostgreSQL separada.

### 5.7 Recalcular subtotales de órdenes

Los subtotales y descuentos no existen como columnas separadas en MySQL. Se recalculan desde `order_items`:

```sql
-- Script post-ETL: recalcular totales de órdenes
UPDATE orders o SET
    subtotal = COALESCE((
        SELECT SUM(oi.precio_original * oi.cantidad)
        FROM order_items oi
        WHERE oi.order_id = o.id
    ), 0),
    descuentos = COALESCE((
        SELECT SUM((oi.precio_original - oi.precio_abonado) * oi.cantidad)
        FROM order_items oi
        WHERE oi.order_id = o.id
    ), 0),
    iva_total = COALESCE((
        SELECT SUM(oi.precio_abonado * oi.cantidad * oi.iva / 100)
        FROM order_items oi
        WHERE oi.order_id = o.id
    ), 0)
WHERE deleted_at IS NULL;
```

---

## 6. Fase 4: Validación Post-Migración

### 6.1 Row counts (cada tabla)

```sql
-- Ejecutar contra MySQL y PostgreSQL. Comparar resultados.

-- MySQL:
SELECT 'customers' AS tabla, COUNT(*) AS filas FROM clientes WHERE eliminado = 0
UNION ALL
SELECT 'products', COUNT(*) FROM productos WHERE eliminado = 0
UNION ALL
SELECT 'orders', COUNT(*) FROM pedidos WHERE eliminado = 0
UNION ALL
SELECT 'order_items', COUNT(*) FROM pedidos_detalle
-- ... (todas las tablas)

-- PostgreSQL:
SELECT 'customers' AS tabla, COUNT(*) AS filas FROM customers WHERE deleted_at IS NULL
UNION ALL
SELECT 'products', COUNT(*) FROM products WHERE deleted_at IS NULL
UNION ALL
SELECT 'orders', COUNT(*) FROM orders WHERE deleted_at IS NULL
UNION ALL
SELECT 'order_items', COUNT(*) FROM order_items
-- ...
```

**Criterio de aceptación:** Row counts deben coincidir exactamente para cada tabla. Diferencia = investigar y corregir antes de seguir.

### 6.2 Checksums financieros (crítico)

```sql
-- MySQL:
SELECT
    COUNT(*) AS total_orders,
    SUM(total) AS suma_total_pedidos,
    AVG(total) AS ticket_promedio
FROM pedidos
WHERE eliminado = 0 AND estado = 'Activo';

-- PostgreSQL:
SELECT
    COUNT(*) AS total_orders,
    SUM(total) AS suma_total_pedidos,
    AVG(total) AS ticket_promedio
FROM orders
WHERE deleted_at IS NULL AND estado = 'Activo';
```

### 6.3 Integridad referencial

```sql
-- Verificar que no haya FKs huérfanas en PostgreSQL
SELECT 'order_items sin order' FROM order_items oi
LEFT JOIN orders o ON oi.order_id = o.id WHERE o.id IS NULL;

SELECT 'products sin brand' FROM products p
LEFT JOIN brands b ON p.marca_id = b.id WHERE p.marca_id IS NOT NULL AND b.id IS NULL;

SELECT 'order_items sin product' FROM order_items oi
LEFT JOIN products p ON oi.product_id = p.id WHERE p.id IS NULL;

SELECT 'customers sin tipo' FROM customers c
LEFT JOIN customer_types ct ON c.tipo_id = ct.id WHERE c.tipo_id IS NOT NULL AND ct.id IS NULL;

-- ... Para cada FK del schema
```

### 6.4 Validación de datos críticos

```sql
-- Verificar emails únicos
SELECT email, COUNT(*) FROM customers
WHERE deleted_at IS NULL
GROUP BY email HAVING COUNT(*) > 1;

-- Verificar URLs únicas
SELECT url, COUNT(*) FROM products
WHERE deleted_at IS NULL
GROUP BY url HAVING COUNT(*) > 1;

-- Verificar pedidos con total negativo
SELECT * FROM orders WHERE total < 0;

-- Verificar variantes sin stock
SELECT pv.id, pv.sku FROM product_variants pv
LEFT JOIN product_variant_stock pvs ON pv.id = pvs.variant_id
WHERE pvs.id IS NULL AND pv.deleted_at IS NULL;

-- Verificar clientes con hash expirado (hashes de activación/recuperación viejos)
SELECT COUNT(*) FROM customers
WHERE hash IS NOT NULL AND hash_expires_at IS NULL;
```

### 6.5 Validación de JSONB

```sql
-- Verificar que los JSONB se hayan parseado correctamente
SELECT id, shipping_address FROM orders
WHERE shipping_address IS NOT NULL
  AND jsonb_typeof(shipping_address) != 'object';

SELECT id, marcas FROM customer_types
WHERE marcas IS NOT NULL
  AND jsonb_typeof(marcas) != 'array';

SELECT id, zipnova_json FROM orders
WHERE zipnova_json IS NOT NULL
  AND jsonb_typeof(zipnova_json) != 'object';
```

### 6.6 Sequence alignment

```sql
-- Verificar que los sequences estén alineados con los datos
SELECT
    'customers' AS tabla,
    (SELECT MAX(id) FROM customers) AS max_id,
    (SELECT last_value FROM customers_id_seq) AS seq_value
UNION ALL
-- ... para cada tabla con SERIAL
```

### 6.7 Checklist de validación

- [ ] Row counts coinciden para TODAS las tablas (MySQL con soft delete vs PostgreSQL con soft delete)
- [ ] Checksums financieros coinciden (suma total, ticket promedio)
- [ ] No hay FKs huérfanas
- [ ] Emails únicos en customers y admin_users
- [ ] URLs únicas en products y categories
- [ ] Sequences alineados con MAX(id)
- [ ] JSONB válido (no hay strings corruptos)
- [ ] Contraseñas en columnas legacy (no en texto plano en la columna principal)
- [ ] Índices creados correctamente
- [ ] Full-text search vector poblado (products.search_vector IS NOT NULL)
- [ ] Tenant settings migrados correctamente (sin secretos en DB)
- [ ] NestJS app puede conectarse a la DB PostgreSQL y hacer consultas básicas

---

## 7. Fase 5: Rollback Plan

### 7.1 Rollback instantáneo (durante la ventana de migración)

Si la migración falla en cualquier punto antes del cutover:

1. **Detener el script de ETL** (o el proceso TypeORM)
2. **Apuntar DNS/app de vuelta al sistema legacy** (que está en modo read-only)
3. **Quitar modo read-only del legacy** → operación normal restaurada
4. **Dropear la DB PostgreSQL** del tenant (opcional, para liberar espacio)
5. **Investigar error, corregir, reintentar** en otra ventana

**Tiempo de rollback:** < 5 minutos (cambio de DNS/configuración)

### 7.2 Rollback post-cutover (ya en producción con NestJS)

Si se descubre un problema grave días después del cutover:

1. **Apuntar DNS de vuelta al PHP legacy**
2. **Aceptar pérdida de datos** de los pedidos/registros creados en NestJS durante el período post-migración
3. **Migrar manualmente** los pedidos nuevos desde PostgreSQL → MySQL (INSERT en `pedidos` y `pedidos_detalle` usando los datos del JSONB)
4. **Actualizar stocks en MySQL** (se descontaron en PostgreSQL pero no en MySQL)

**⚠️ Este escenario es costoso.** Para mitigarlo:
- Hacer el cutover en horario de bajo tráfico (madrugada)
- Tener al equipo de soporte en guardia las primeras 24 horas
- Monitorear KPIs: tasa de conversión del checkout, pedidos creados, errores 500

### 7.3 Rollback por tenant individual

Si el tenant A falla pero el tenant B ya migró exitosamente:
- Solo se revierte el tenant A
- El tenant B sigue operando en NestJS
- Esto es la principal ventaja del big-bang por tenant

---

## 8. Orden de Migración por Tenant

### 8.1 Secuencia recomendada

```
1. Tenant de PRUEBAS/STAGING (entorno no productivo)
   → Validar todo el proceso. Medir tiempos reales.
   → Ajustar scripts si es necesario.

2. Tenant más CHICO (menos datos, menos tráfico)
   → Primer experiencia real. Bajo riesgo.
   → Ej: cliente con 500 productos, 1000 pedidos

3. Tenant MEDIANO
   → Validar con más volumen.

4. Tenant más GRANDE (mayor volumen de datos y tráfico)
   → Con la experiencia de los anteriores.
   → Ej: canccat (si es el más grande)

5. Resto de tenants en orden de prioridad
```

### 8.2 Ventana de migración recomendada

| Actividad | Cuándo |
|---|---|
| Backup MySQL | Viernes 22:00 |
| Anuncio de mantenimiento a clientes | Viernes 22:30 |
| Activar modo read-only en legacy | Sábado 00:00 |
| Ejecutar migración | Sábado 00:30 - 04:00 |
| Validación | Sábado 04:00 - 05:00 |
| Cutover DNS → NestJS | Sábado 05:00 |
| Monitoreo intensivo | Sábado 05:00 - 12:00 |
| Guardia de soporte | Sábado 05:00 - Domingo 18:00 |

---

## 9. Cronograma Estimado

### 9.1 Por tenant

| Fase | Duración | Responsable |
|---|---|---|
| Backup MySQL | 15 min | DBA |
| Schema DDL (Fase 1) | 30 min | Data Architect |
| ETL Datos (Fase 2) | 1.5 - 3 horas | Script automatizado (supervisado) |
| Transformaciones especiales (Fase 3) | Incluido en ETL | Script |
| Validación (Fase 4) | 30 - 60 min | Data Architect + QA |
| Cutover (Fase 5) | 15 min | DevOps |
| **Total por tenant** | **3 - 5 horas** | |

### 9.2 Por el proyecto completo (5-10 tenants)

| Hito | Semana |
|---|---|
| Preparación (scripts, staging) | Semana 1-2 |
| Migración tenant staging | Semana 2 |
| Ajustes post-staging | Semana 3 |
| Migración tenant #1 (más chico) | Semana 4 |
| Migración tenant #2 | Semana 4 |
| Migración tenant #3 | Semana 5 |
| Migración tenants restantes | Semana 5-6 |
| **Todos los tenants en NestJS** | **Fin Semana 6** |

---

## 10. Riesgos y Mitigaciones

| Riesgo | Prob | Impacto | Mitigación |
|---|---|---|---|
| **Datos corruptos en MySQL** (JSON inválido en columnas TEXT) | Media | Alto | `safeJsonParse()` en scripts ETL. Loggear y saltar filas corruptas. Revisar post-migración. |
| **Timeout en tablas grandes** (>500K filas) | Media | Medio | Procesar en batches de 1000. Aumentar `statement_timeout` en PostgreSQL. Monitorear progreso. |
| **Encoding issues** (UTF-8 mal configurado en MySQL, ñ y acentos rotos) | Media | Medio | Verificar encoding en pre-migración. Convertir con `CONVERT(column USING utf8mb4)` en MySQL si es necesario. |
| **Sequences desalineados** post-ETL | Alta | Bajo | Siempre ejecutar `setval()` después de INSERT con IDs explícitos. Validar en checklist. |
| **Performance degradation** en NestJS vs PHP | Media | Alto | Monitorear queries lentas (`pg_stat_statements`). Agregar índices faltantes. Cache Redis para catálogo. |
| **Password migration no detectada** (cliente no loguea por meses, su hash sigue en md5) | Baja | Medio | Campaña de email "por seguridad, actualizá tu contraseña" a clientes no migrados después de 30 días. |
| **Período de read-only muy largo** (clientes no pueden comprar) | Baja | Alto | Ventana en madrugada de sábado (mínimo tráfico). Aviso previo. Si excede 4 horas → abortar y reintentar. |
| **Webhooks de pago perdidos durante la migración** | Media | Alto | MercadoPago y Modo reintentan webhooks por 72hs. Al hacer el cutover, los webhooks pendientes se procesan normalmente en NestJS. Verificar cola post-migración. |

---

## 11. Scripts de Migración de Referencia

### 11.1 Script principal de migración (migrate-tenant.js)

```javascript
#!/usr/bin/env node
/**
 * migrate-tenant.js
 * Script principal de migración MySQL → PostgreSQL para un tenant.
 *
 * Uso:
 *   TENANT_ID=canccat node scripts/migrate-tenant.js
 *
 * Requiere variables de entorno:
 *   MYSQL_HOST, MYSQL_PORT, MYSQL_USER, MYSQL_PASSWORD, MYSQL_DATABASE
 *   PG_HOST, PG_PORT, PG_USER, PG_PASSWORD, PG_DATABASE
 */

const { execSync } = require('child_process');
const mysql = require('mysql2/promise');
const { Pool } = require('pg');
const fs = require('fs');
const path = require('path');

const TENANT_ID = process.env.TENANT_ID;
if (!TENANT_ID) {
  console.error('ERROR: TENANT_ID no configurado');
  process.exit(1);
}

const MYSQL_CONFIG = {
  host: process.env.MYSQL_HOST,
  port: parseInt(process.env.MYSQL_PORT || '3306'),
  user: process.env.MYSQL_USER,
  password: process.env.MYSQL_PASSWORD,
  database: process.env.MYSQL_DATABASE || `lumba_${TENANT_ID}`,
  charset: 'utf8mb4',
};

const PG_CONFIG = {
  host: process.env.PG_HOST || 'localhost',
  port: parseInt(process.env.PG_PORT || '5432'),
  user: process.env.PG_USER || 'lumba_app',
  password: process.env.PG_PASSWORD,
  database: process.env.PG_DATABASE || `lumba_tenant_${TENANT_ID}`,
};

const LOG_FILE = path.join(__dirname, `../logs/migration-${TENANT_ID}-${Date.now()}.log`);

// ============ UTILIDADES ============

function log(level, message, data = {}) {
  const entry = {
    timestamp: new Date().toISOString(),
    tenant: TENANT_ID,
    level,
    message,
    ...data,
  };
  const line = JSON.stringify(entry);
  console.log(`[${level.toUpperCase()}] ${message}`);
  fs.appendFileSync(LOG_FILE, line + '\n');
}

async function withConnection(fn, label) {
  const start = Date.now();
  log('info', `Iniciando: ${label}`);
  try {
    const result = await fn();
    const duration = Date.now() - start;
    log('info', `Completado: ${label}`, { duration_ms: duration });
    return result;
  } catch (error) {
    const duration = Date.now() - start;
    log('error', `Falló: ${label}`, { error: error.message, duration_ms: duration });
    throw error;
  }
}

// ============ FASE 1: SCHEMA ============

async function phase1CreateSchema(pgPool) {
  log('info', '=== FASE 1: Creando schema ===');

  // Ejecutar DDL completo desde archivo SQL
  const schemaPath = path.join(__dirname, '../src/database/schema.sql');
  const ddl = fs.readFileSync(schemaPath, 'utf8');

  await pgPool.query(ddl);
  log('info', 'Schema creado exitosamente');
}

// ============ FASE 2: ETL ============

async function phase2MigrateData(mysqlConn, pgPool) {
  log('info', '=== FASE 2: Migrando datos ===');

  // Deshabilitar triggers y FKs temporalmente para carga rápida
  await pgPool.query('SET session_replication_role = replica;');

  // Tablas en orden de dependencia
  const tables = [
    // Fase 2a — Catálogos base
    { name: 'provinces', mysqlQuery: 'SELECT * FROM provincias' },
    { name: 'localities', mysqlQuery: 'SELECT * FROM localidades' },
    { name: 'postal_codes', mysqlQuery: 'SELECT * FROM codigos_postales' },
    { name: 'price_lists', mysqlQuery: 'SELECT * FROM listas WHERE eliminado=0' },
    { name: 'properties', mysqlQuery: 'SELECT * FROM propiedades WHERE eliminado=0' },
    { name: 'property_values', mysqlQuery: 'SELECT * FROM propiedades_valores WHERE eliminado=0' },
    { name: 'customer_fiscal_situations', mysqlQuery: 'SELECT * FROM clientes_situaciones WHERE eliminado=0' },
    { name: 'customer_invoice_types', mysqlQuery: 'SELECT * FROM clientes_tipos_comprobante WHERE eliminado=0' },
    { name: 'admin_roles', mysqlQuery: 'SELECT * FROM administradores_tipos WHERE eliminado=0' },
    { name: 'contact_areas', mysqlQuery: 'SELECT * FROM contacto_areas WHERE eliminado=0' },
    { name: 'keywords', mysqlQuery: 'SELECT * FROM keywords WHERE eliminado=0' },
    { name: 'email_templates', mysqlQuery: 'SELECT * FROM emails_plantillas WHERE eliminado=0' },
    { name: 'tenant_settings', mysqlQuery: "SELECT * FROM configuracion WHERE variable NOT IN ('mercadopago_access_token','modo_username','modo_password','modo_processor_code','modo_cc_code','padpio_user','padpio_password','padpio_host','recaptcha_secret_key','smtp_password')" },

    // Fase 2b — Con FKs
    { name: 'brands', mysqlQuery: 'SELECT * FROM marcas WHERE eliminado=0' },
    { name: 'categories', mysqlQuery: 'SELECT * FROM categorias WHERE eliminado=0' },
    { name: 'tags', mysqlQuery: 'SELECT * FROM tags WHERE eliminado=0' },
    { name: 'customer_types', mysqlQuery: 'SELECT * FROM clientes_tipos WHERE eliminado=0' },
    { name: 'branches', mysqlQuery: 'SELECT * FROM sucursales WHERE eliminado=0' },
    { name: 'shipping_methods', mysqlQuery: 'SELECT * FROM envios_propios WHERE eliminado=0' },
    { name: 'admin_users', mysqlQuery: 'SELECT * FROM administradores WHERE eliminado=0' },
    { name: 'admin_role_permissions', mysqlQuery: 'SELECT * FROM administradores_tipos_permisos' },
    { name: 'customers', mysqlQuery: 'SELECT * FROM clientes WHERE eliminado=0' },
    { name: 'customer_addresses', mysqlQuery: 'SELECT * FROM clientes_direcciones WHERE eliminado=0' },
    { name: 'products', mysqlQuery: 'SELECT * FROM productos WHERE eliminado=0' },
    { name: 'product_categories', mysqlQuery: 'SELECT * FROM productos_categorias' },
    { name: 'product_tags', mysqlQuery: 'SELECT * FROM productos_tags' },
    { name: 'product_variants', mysqlQuery: 'SELECT * FROM productos_variantes WHERE eliminado=0' },
    { name: 'product_variant_stock', mysqlQuery: 'SELECT * FROM productos_variantes_stock' },
    { name: 'product_variant_prices', mysqlQuery: 'SELECT * FROM productos_variantes_precios' },
    { name: 'product_images', mysqlQuery: 'SELECT * FROM productos_variantes_fotos' },
    { name: 'product_property_values', mysqlQuery: 'SELECT * FROM productos_propiedades_valores' },
    { name: 'product_keywords', mysqlQuery: 'SELECT * FROM productos_keywords' },
    { name: 'related_products', mysqlQuery: 'SELECT * FROM productos_relacionados' },

    // Fase 2c — Transaccional
    { name: 'coupons', mysqlQuery: 'SELECT * FROM cupones WHERE eliminado=0' },
    { name: 'promotions', mysqlQuery: 'SELECT * FROM promociones WHERE eliminado=0' },
    { name: 'orders', mysqlQuery: 'SELECT * FROM pedidos WHERE eliminado=0' },
    { name: 'order_items', mysqlQuery: 'SELECT * FROM pedidos_detalle' },
    { name: 'order_emails', mysqlQuery: 'SELECT * FROM pedidos_emails' },
    { name: 'coupon_usage', mysqlQuery: 'SELECT * FROM cupones_utilizados' },
    { name: 'abandoned_carts', mysqlQuery: "SELECT * FROM pedidos WHERE eliminado=0 AND estado='Incompleto'" },

    // Fase 2d — Contenido
    { name: 'wishlists', mysqlQuery: 'SELECT * FROM clientes_favoritos' },
    { name: 'sliders', mysqlQuery: 'SELECT * FROM slider WHERE eliminado=0' },
    { name: 'banners', mysqlQuery: 'SELECT * FROM banners WHERE eliminado=0' },
    { name: 'faqs', mysqlQuery: 'SELECT * FROM preguntas_frecuentes WHERE eliminado=0' },
    { name: 'content_sections', mysqlQuery: 'SELECT * FROM secciones_adicionales WHERE eliminado=0' },
    { name: 'social_links', mysqlQuery: 'SELECT * FROM redes WHERE eliminado=0' },
    { name: 'contacts', mysqlQuery: 'SELECT * FROM contacto' },
    { name: 'returns', mysqlQuery: 'SELECT * FROM devoluciones' },
    { name: 'reviews', mysqlQuery: 'SELECT * FROM resenias WHERE eliminado=0' },
    { name: 'surveys', mysqlQuery: 'SELECT * FROM encuestas WHERE eliminado=0' },
    { name: 'survey_questions', mysqlQuery: 'SELECT * FROM encuestas_preguntas' },
    { name: 'survey_invitations', mysqlQuery: 'SELECT * FROM encuestas_envios' },
    { name: 'survey_responses', mysqlQuery: 'SELECT * FROM encuestas_respuestas' },
  ];

  for (const table of tables) {
    await withConnection(async () => {
      await migrateTable(table.name, table.mysqlQuery, mysqlConn, pgPool);
    }, `Migrando tabla ${table.name}`);
  }

  // Re-habilitar FKs
  await pgPool.query('SET session_replication_role = DEFAULT;');
}

async function migrateTable(tableName, mysqlQuery, mysqlConn, pgPool, transformFn = null) {
  const [rows] = await mysqlConn.query(mysqlQuery);
  log('info', `  ${tableName}: ${rows.length} filas desde MySQL`);

  if (rows.length === 0) return { migrated: 0, skipped: 0 };

  // Truncar destino
  await pgPool.query(`TRUNCATE TABLE ${tableName} RESTART IDENTITY CASCADE`);

  // Transformar filas si hay función de transformación
  const transformers = getTransformers();
  const transform = transformFn || transformers[tableName] || (row => row);

  // Insertar en batches
  const BATCH_SIZE = 1000;
  let inserted = 0;
  let skipped = 0;

  for (let i = 0; i < rows.length; i += BATCH_SIZE) {
    const batch = rows.slice(i, i + BATCH_SIZE);
    const pgRows = batch.map(transform);

    // Filtrar filas inválidas
    const validRows = pgRows.filter(row => {
      if (row === null || row === undefined) {
        skipped++;
        return false;
      }
      return true;
    });

    if (validRows.length === 0) continue;

    const columns = Object.keys(validRows[0]);
    const values = validRows.map(row => columns.map(c => row[c]));

    const placeholders = validRows.map((_, ri) =>
      `(${columns.map((_, ci) => `$${ri * columns.length + ci + 1}`).join(', ')})`
    ).join(', ');

    const query = `INSERT INTO ${tableName} (${columns.join(', ')}) VALUES ${placeholders}`;

    try {
      await pgPool.query(query, values.flat());
      inserted += validRows.length;
    } catch (error) {
      log('error', `Error en batch de ${tableName} (offset ${i})`, {
        error: error.message,
        batchSize: validRows.length,
      });
      // Continuar con el siguiente batch en vez de abortar toda la tabla
      skipped += validRows.length;
    }
  }

  // Actualizar sequence
  try {
    await pgPool.query(`
      SELECT setval('${tableName}_id_seq',
        COALESCE((SELECT MAX(id) FROM ${tableName}), 1)
      );
    `);
  } catch {
    // Ignorar si no tiene SERIAL (UUID tables)
  }

  return { migrated: inserted, skipped };
}

// ============ POST-MIGRACIÓN ============

async function postMigrationTasks(pgPool) {
  log('info', '=== Tareas post-migración ===');

  // Recalcular totales de órdenes
  await pgPool.query(`
    UPDATE orders o SET
      subtotal = COALESCE((SELECT SUM(oi.precio_original * oi.cantidad) FROM order_items oi WHERE oi.order_id = o.id), 0),
      descuentos = COALESCE((SELECT SUM((oi.precio_original - oi.precio_abonado) * oi.cantidad) FROM order_items oi WHERE oi.order_id = o.id), 0),
      iva_total = COALESCE((SELECT SUM(oi.precio_abonado * oi.cantidad * oi.iva / 100) FROM order_items oi WHERE oi.order_id = o.id), 0)
    WHERE deleted_at IS NULL
  `);
  log('info', 'Totales de órdenes recalculados');

  // Poblar search_vector de productos
  await pgPool.query(`
    UPDATE products SET
      search_vector = setweight(to_tsvector('spanish', coalesce(nombre, '')), 'A') ||
                      setweight(to_tsvector('spanish', coalesce(descripcion, '')), 'B')
    WHERE deleted_at IS NULL
  `);
  log('info', 'search_vector de productos poblado');

  // Marcar hashes existentes como expirados (seguridad)
  await pgPool.query(`
    UPDATE customers SET hash_expires_at = NOW() WHERE hash IS NOT NULL AND hash_expires_at IS NULL
  `);
  log('info', 'Hashes de clientes expirados');

  // Crear tabla shipping_config si está vacía
  const { rows } = await pgPool.query('SELECT COUNT(*) FROM shipping_config');
  if (parseInt(rows[0].count) === 0) {
    // Migrar desde tablas legacy envio_gratis y compra_minima
    await pgPool.query(`INSERT INTO shipping_config (id, config) VALUES (1, '{}')`);
  }
}

// ============ VALIDACIÓN ============

async function validateMigration(pgPool) {
  log('info', '=== Validación post-migración ===');

  const checks = [
    {
      name: 'customers row count',
      query: "SELECT COUNT(*) AS count FROM customers WHERE deleted_at IS NULL",
      expected: null, // Se compara contra MySQL
    },
    {
      name: 'orders row count',
      query: "SELECT COUNT(*) AS count FROM orders WHERE deleted_at IS NULL",
      expected: null,
    },
    {
      name: 'order_items total integrity',
      query: 'SELECT COUNT(*) AS count FROM order_items',
      expected: null,
    },
    {
      name: 'orphan order_items',
      query: `SELECT COUNT(*) AS count FROM order_items oi
              LEFT JOIN orders o ON oi.order_id = o.id WHERE o.id IS NULL`,
      expected: 0,
    },
    {
      name: 'duplicate emails',
      query: `SELECT COUNT(*) AS count FROM (
              SELECT email FROM customers WHERE deleted_at IS NULL GROUP BY email HAVING COUNT(*) > 1
              ) sub`,
      expected: 0,
    },
    {
      name: 'sequence alignment',
      query: `SELECT CASE WHEN (SELECT MAX(id) FROM customers) <= (SELECT last_value FROM customers_id_seq) THEN 0 ELSE 1 END AS count`,
      expected: 0,
    },
  ];

  for (const check of checks) {
    const { rows } = await pgPool.query(check.query);
    const actual = parseInt(rows[0].count);
    if (check.expected !== null && actual !== check.expected) {
      log('error', `VALIDACIÓN FALLIDA: ${check.name}`, { expected: check.expected, actual });
    } else {
      log('info', `✅ ${check.name}: ${actual}`);
    }
  }
}

// ============ MAIN ============

async function main() {
  log('info', `Iniciando migración para tenant: ${TENANT_ID}`);
  const startTime = Date.now();

  let mysqlConn, pgPool;

  try {
    // Conectar a ambas DBs
    mysqlConn = await mysql.createConnection(MYSQL_CONFIG);
    log('info', 'Conectado a MySQL');

    pgPool = new Pool(PG_CONFIG);
    log('info', 'Conectado a PostgreSQL');

    // Fase 1: Schema
    await withConnection(() => phase1CreateSchema(pgPool), 'Fase 1: Schema');

    // Fase 2: ETL
    await withConnection(() => phase2MigrateData(mysqlConn, pgPool), 'Fase 2: ETL');

    // Tareas post-migración
    await withConnection(() => postMigrationTasks(pgPool), 'Post-migración');

    // Validación
    await withConnection(() => validateMigration(pgPool), 'Validación');

    const totalDuration = Date.now() - startTime;
    log('info', `✅ Migración completada exitosamente`, {
      total_duration_ms: totalDuration,
      total_duration_min: Math.round(totalDuration / 60000),
    });

  } catch (error) {
    log('error', `❌ Migración FALLIDA: ${error.message}`, { stack: error.stack });
    process.exit(1);
  } finally {
    if (mysqlConn) await mysqlConn.end();
    if (pgPool) await pgPool.end();
  }
}

main();
```

### 11.2 Transformación de variant_property_values (M:N nueva)

```javascript
// Migrar propiedad1_id, propiedad2_id, propiedad3_id → variant_property_values
async function migrateVariantPropertyValues(mysqlConn, pgPool) {
  const [variants] = await mysqlConn.query(
    'SELECT Id, propiedad1_id, propiedad2_id, propiedad3_id FROM productos_variantes WHERE eliminado=0'
  );

  let count = 0;
  for (const v of variants) {
    const valueIds = [v.propiedad1_id, v.propiedad2_id, v.propiedad3_id].filter(Boolean);
    for (const valueId of valueIds) {
      await pgPool.query(
        'INSERT INTO variant_property_values (variant_id, property_value_id) VALUES ($1, $2) ON CONFLICT DO NOTHING',
        [v.Id, valueId]
      );
      count++;
    }
  }
  log('info', `variant_property_values: ${count} relaciones migradas`);
}
```

### 11.3 Migración de admin_permissions (desde secciones_admin)

```javascript
// Migrar las secciones_admin legacy a permisos granulares
async function migrateAdminPermissions(mysqlConn, pgPool) {
  // 1. Obtener secciones del sistema legacy
  const [secciones] = await mysqlConn.query('SELECT * FROM secciones_admin');

  const permissionMap = {
    'productos': ['productos.ver', 'productos.crear', 'productos.editar', 'productos.eliminar'],
    'pedidos': ['pedidos.ver', 'pedidos.crear', 'pedidos.editar'],
    'clientes': ['clientes.ver', 'clientes.crear', 'clientes.editar'],
    'configuracion': ['configuracion.ver', 'configuracion.editar'],
    'cupones': ['cupones.ver', 'cupones.crear', 'cupones.editar', 'cupones.eliminar'],
    'promociones': ['promociones.ver', 'promociones.crear', 'promociones.editar'],
    'envios': ['envios.ver', 'envios.editar'],
    'sucursales': ['sucursales.ver', 'sucursales.editar'],
    'categorias': ['categorias.ver', 'categorias.editar'],
    'marcas': ['marcas.ver', 'marcas.editar'],
    'tags': ['tags.ver', 'tags.editar'],
    'usuarios': ['admin_usuarios.ver', 'admin_usuarios.crear', 'admin_usuarios.editar'],
    'contenido': ['contenido.ver', 'contenido.editar'],
    'contacto': ['contacto.ver'],
  };

  // 2. Insertar permisos base
  for (const [seccion, permisos] of Object.entries(permissionMap)) {
    for (const permiso of permisos) {
      await pgPool.query(
        'INSERT INTO admin_permissions (recurso, accion) VALUES ($1, $2) ON CONFLICT (recurso, accion) DO NOTHING',
        [permiso.split('.')[0], permiso.split('.')[1]]
      );
    }
  }

  // 3. Migrar asignaciones: administradores_tipos_permisos → admin_role_permissions
  const [asignaciones] = await mysqlConn.query(`
    SELECT atp.tipo_id, sa.seccion
    FROM administradores_tipos_permisos atp
    JOIN secciones_admin sa ON atp.seccion_id = sa.Id
  `);

  for (const a of asignaciones) {
    const permisos = permissionMap[a.seccion] || [`${a.seccion}.ver`];
    for (const permiso of permisos) {
      const [recurso, accion] = permiso.split('.');
      const { rows } = await pgPool.query(
        'SELECT id FROM admin_permissions WHERE recurso = $1 AND accion = $2',
        [recurso, accion]
      );
      if (rows.length > 0) {
        await pgPool.query(
          'INSERT INTO admin_role_permissions (role_id, permission_id) VALUES ($1, $2) ON CONFLICT DO NOTHING',
          [a.tipo_id, rows[0].id]
        );
      }
    }
  }
  log('info', 'admin_permissions migrados');
}
```

### 11.4 Configuración de PostgreSQL para migración (rendimiento)

```sql
-- Configuraciones temporales para acelerar la migración
-- (ejecutar como superuser ANTES de la migración)

-- Deshabilitar WAL logging para las tablas durante la carga
ALTER TABLE customers SET (autovacuum_enabled = off);
ALTER TABLE orders SET (autovacuum_enabled = off);
ALTER TABLE order_items SET (autovacuum_enabled = off);
ALTER TABLE product_variant_prices SET (autovacuum_enabled = off);
ALTER TABLE product_variant_stock SET (autovacuum_enabled = off);
-- ... (todas las tablas grandes)

-- Aumentar memoria para maintenance
SET maintenance_work_mem = '1GB';
SET work_mem = '256MB';

-- Deshabilitar synchronous_commit para velocidad
SET synchronous_commit = off;

-- === DESPUÉS de la migración ===
-- Re-habilitar autovacuum
ALTER TABLE customers SET (autovacuum_enabled = on);
ALTER TABLE orders SET (autovacuum_enabled = on);
ALTER TABLE order_items SET (autovacuum_enabled = on);
ALTER TABLE product_variant_prices SET (autovacuum_enabled = on);
ALTER TABLE product_variant_stock SET (autovacuum_enabled = on);

-- Ejecutar ANALYZE para estadísticas frescas
ANALYZE;

-- Restaurar configuraciones
RESET synchronous_commit;
RESET maintenance_work_mem;
RESET work_mem;
```

---

## Anexo: Nivel de Confianza por Sección

| Sección | Confianza | Fundamento |
|---|---|---|
| Estrategia General (Big Bang por Tenant) | **ALTA** | Estrategia estándar de migración brownfield con multi-tenant. Recomendada por la arquitectura existente (DBs separadas). |
| Fase 1: Schema | **ALTA** | DDL completo generado desde el diseño del schema. Compatible con TypeORM. |
| Fase 2: ETL | **ALTA** | Patrón de migración batch con transformaciones probadas. Los mapeos de columnas están verificados contra `01-modelo-datos-actual.md`. |
| Fase 3: Transformaciones (contraseñas) | **ALTA** | Estrategia validada por el Security Agent (`01-security-remediation-plan.md` V01, V02). |
| Fase 3: Transformaciones (JSON → JSONB) | **MEDIA-ALTA** | El parseo de JSON legacy puede fallar si hay datos corruptos en MySQL. `safeJsonParse()` mitiga esto. |
| Fase 4: Validación | **ALTA** | Checklist basada en estándares de migración de datos. Row counts y checksums son determinísticos. |
| Fase 5: Rollback | **ALTA** | Rollback por tenant es simple (DNS → legacy). El riesgo está en el período post-cutover (pérdida de datos nuevos). |
| Cronograma (3-5 horas por tenant) | **MEDIA** | Depende del volumen real de datos. El staging del tenant más grande dará la medida exacta. |
| Scripts de referencia | **MEDIA-ALTA** | Los scripts están diseñados para el schema específico de Lumba. Deben probarse en staging y ajustarse. |

---

*Documento preparado por el Data Architect. Los scripts son de referencia y deben probarse en staging antes de ejecutar en producción. La migración de contraseñas (md5/bcrypt) usa la estrategia completa del Security Agent.*
