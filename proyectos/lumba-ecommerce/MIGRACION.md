# Migración a repo propio — lumba-ecommerce

> **Estado:** ⏳ Pendiente — esperando creación del repo `github.com/lumba-io/lumba-ecommerce`

Cuando el repo esté creado, migrar:

| Carpeta actual | Destino |
|---|---|
| `outputs/` | Repo `lumba-ecommerce` → `docs/` o `outputs/` |
| `source/` | Repo `lumba-ecommerce` (código fuente) |
| `approvals/` | Repo `lumba-ecommerce` → `governance/approvals/` |
| `drafts/` | Repo `lumba-ecommerce` → `governance/drafts/` |
| `handoffs/` | Repo `lumba-ecommerce` → `governance/handoffs/` |
| `migrations/` | Repo `lumba-ecommerce` → `db/migrations/` |
| `overrides/` | Repo `lumba-ecommerce` → `governance/overrides/` |

**Acá se queda (registro liviano):**
- `repo.url` — slug del proyecto
- `state.json` — fase actual y metadatos
- `MEMORIA-PROYECTO.md` — contexto, decisiones, aprendizajes
