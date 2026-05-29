---
name: data-modeling
version: 1.0
team: core-product
last_updated: 2026-05-23
used_by: [data-architect]
---

# Skill: Data Modeling

## Principios

### 1. Multi-tenant by default
Si el producto sirve múltiples clientes, multi-tenant desde el día 1.

Patrón típico (Supabase):
```
- organizations (tenants)
- users
- organization_members (n-n)
- {entidad_negocio} (con organization_id)
```

### 2. RLS (Row Level Security)
Toda tabla con datos sensibles tiene RLS.

### 3. Naming conventions
- snake_case para tablas y columnas.
- Tablas en plural: `users`, `meetings`.
- IDs siempre `id` (uuid).
- Timestamps: `created_at`, `updated_at`.

### 4. Versionado de migrations
- Migrations en `supabase/migrations/`.
- Naming: `YYYYMMDDHHMMSS_descripcion.sql`.
- Idempotentes cuando es posible.

### 5. Soft delete vs hard delete
- Soft delete (`deleted_at`) para datos del usuario.
- Hard delete solo cuando hay obligación legal o no hay reversibilidad de valor.

## Anti-patterns

- ❌ Tablas sin RLS con datos sensibles.
- ❌ Migrations no versionadas.
- ❌ FK sin índices.
- ❌ Schemas sin documentación.
