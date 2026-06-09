# Plan General — Lumba Ecommerce (Refactorización)
>
> **Proyecto:** lumba-ecommerce | **Tipo:** B (Brownfield) | **Complejidad:** L (Large, 8 pts)
> **Squad:** 12 agentes | **Stack target:** NestJS + Tailwind CSS
> **Fuente:** PHP vanilla + MySQL → Rama `refactoring` en GitHub
> **Fecha:** 2026-06-03

---

## 🔭 Visión General

Migrar el ecommerce completo de PHP vanilla a **NestJS (backend) + Tailwind CSS (frontend)**, preservando toda la lógica de negocio, integraciones de pago y funcionalidad multi-cliente. La fuente de verdad es la rama `refactoring` del repo `LumbaDev/lumba-ecommerce`.

---

## 📐 Fases del Proyecto

```
PROJECT_ASSESSMENT ✅ → DISCOVERY → TECH_STACK → DB_DESIGN → UX_UI → BUILD → QA → DEPLOY → POST_LAUNCH
```

| Fase | Estado |
|---|---|
| PROJECT_ASSESSMENT | ✅ Completada (clasificación B+L, squad definido) |
| BRIEF | ⏭️ Skipped (proyecto interno) |
| PROPOSAL | ⏭️ Skipped (proyecto interno) |
| DISCOVERY | 🔜 Próxima fase |
| TECH_STACK | ⏳ Pendiente |
| DB_DESIGN | ⏳ Pendiente |
| BRANDING | ⏭️ Skipped (marca Lumba existe) |
| UX_UI | ⏳ Pendiente |
| MARKETING | ⏭️ Skipped (proyecto interno) |
| BUILD | ⏳ Pendiente |
| QA | ⏳ Pendiente |
| DEPLOY | ⏳ Pendiente |
| POST_LAUNCH | ⏳ Pendiente |

---

## 1. FASE DISCOVERY — Auditoría del Sistema Existente

### Objetivo
Documentar **todo** el funcionamiento del ecommerce actual para que Gero pueda revisarlo antes de empezar el nuevo.

### Agentes involucrados
- **System Auditor** (HIGH, `gpt-5.5`) — audita el código legacy
- **Product Owner** (HIGH, `gpt-5.5`) — extrae reglas de negocio y prioridades
- **Research Agent** (LOW, `flash`) — benchmark de ecommerce en NestJS
- **Security Agent** (HIGH, `gpt-5.5`) — audita vulnerabilidades del código actual

### Sub-fase 1.1 — System Auditor: Documentación del sistema existente

El System Auditor analiza la rama `refactoring` y produce:

**1.1.1 — Catálogo de endpoints y rutas**
- Mapeo de todas las rutas frontend (`/`, `/producto`, `/carrito`, `/checkout/1-4`, `/cuenta`, etc.)
- Mapeo de todos los AJAX endpoints (`admin/ajax/*.php`, `ajax/*.php`)
- Métodos HTTP, parámetros esperados, respuestas

**1.1.2 — Modelo de datos actual**
- Todas las tablas inferidas (no hay migraciones SQL — se infieren de los queries PHP)
- Relaciones entre entidades
- Campos, tipos de datos, constraints detectados

**1.1.3 — Flujos de negocio documentados**
- Flujo de compra completo (catálogo → carrito → checkout → pago → confirmación)
- Flujo de administración (productos, pedidos, clientes, cupones)
- Flujo de recuperación de carrito abandonado
- Flujo de devoluciones
- Flujo de encuestas post-compra

**1.1.4 — Integraciones externas documentadas**
- MercadoPago: endpoints IPN, flujo de pago, webhooks
- Modo: endpoints, flujo
- PadPio: implementación
- ZN: webhooks
- APIs de envío: cálculo, tracking

**1.1.5 — Catálogo de features por cliente (multi-tenant)**
- Qué features están activas por branch (cancat, pantole, pentole, profecia, etc.)
- Diferencias de configuración entre clientes

**Output:**
- `outputs/01-discovery-sistema-actual.md` (documento completo)
- `outputs/01-modelo-datos-actual.md` (esquema inferido)
- `outputs/01-flujos-negocio.md` (diagramas de flujo en texto)
- `outputs/01-integraciones.md` (catálogo de integraciones)
- `outputs/01-features-por-cliente.md` (matriz multi-tenant)

### Sub-fase 1.2 — Security Agent: Auditoría de seguridad

- Credenciales hardcodeadas (detectadas en `inc/db.php`)
- Vulnerabilidades de inyección SQL
- Manejo de sesiones y autenticación
- Exposición de datos sensibles
- CSRF, XSS

**Output:** `outputs/01-auditoria-seguridad.md`

### Sub-fase 1.3 — Product Owner: Priorización

Basado en el análisis del System Auditor, el PO define:
- Features core que DEBEN migrarse (MVP del nuevo sistema)
- Features que PUEDEN mejorarse/diferirse
- Features a ELIMINAR (funcionalidad muerta o no usada)
- Propuesta de scope para el nuevo ecommerce

**Output:** `outputs/01-product-backlog-inicial.md`

### Sub-fase 1.4 — Research Agent: Benchmark

- Cómo otros ecommerce modernos resuelven lo mismo
- Mejores prácticas NestJS para ecommerce
- Librerías y paquetes recomendados para pasarelas de pago, emails, Excel

**Output:** `outputs/01-benchmark-tecnico.md`

### Gate: Strategy Gate
- Devil's Advocate audita los outputs de Discovery
- ¿Está completo el entendimiento del sistema?
- ¿Hay supuestos no validados?

---

## 2. FASE TECH_STACK — Decisiones de Arquitectura

### Objetivo
Definir el stack técnico exacto para el nuevo ecommerce. Gero decide.

### Agentes involucrados
- **Backend Architect** (MEDIUM, `pro`) — arquitectura NestJS
- **Frontend Architect** (MEDIUM, `pro`) — arquitectura Tailwind + framework frontend
- **DevOps Engineer** (LOW, `flash`) — infraestructura y deploy
- **Data Architect** (HIGH, `gpt-5.5`) — estrategia de datos

### Decisiones a tomar

| Decisión | Opciones | Quién decide |
|---|---|---|
| Base de datos | PostgreSQL vs MySQL vs Supabase | Gero |
| ORM | TypeORM vs Prisma vs Drizzle | Gero |
| Frontend framework | Next.js vs React vs HTMX | Gero |
| Autenticación | JWT manual vs Auth0 vs Supabase Auth vs NextAuth | Gero |
| Hosting | Vercel + Railway vs Docker en VPS vs Supabase | Gero |
| File storage | S3 vs Supabase Storage vs local | Gero |
| Email | Resend vs SendGrid vs SMTP | Gero |
| Jobs/Queues | BullMQ vs temporal vs cron | Gero |
| Monorepo | Nx vs Turborepo vs monorepo simple | Gero |

### Sub-fase 2.1 — Backend Architect: Propuesta NestJS
- Estructura de módulos NestJS
- Patrones: CQRS, Event Sourcing, Repository
- Decisiones de arquitectura (ADR)
- Validación (class-validator, Zod)
- Testing strategy
- API design (REST vs GraphQL)

### Sub-fase 2.2 — Frontend Architect: Propuesta Frontend
- Estructura del proyecto
- Componentes reutilizables
- Estrategia de estado (React Query, Zustand, Context)
- Rutas y navegación
- Estrategia responsive
- Performance targets

### Sub-fase 2.3 — DevOps Engineer: Infraestructura
- Pipeline CI/CD
- Estrategia de branches (matching con multi-cliente)
- Ambientes (dev, staging, prod)
- Monitoreo y logging

### Sub-fase 2.4 — Data Architect: Estrategia de migración
- Plan de migración de datos (PHP/MySQL → nuevo sistema)
- Estrategia de corte (big bang vs gradual)
- Rollback plan

### Gate: Strategy Gate
- Devil's Advocate audita las decisiones de stack
- Gero aprueba el ADR de arquitectura

**Output principal:** `outputs/02-adr-stack.md` (Architecture Decision Records)

---

## 3. FASE DB_DESIGN — Modelo de Datos

### Objetivo
Diseñar el esquema de base de datos del nuevo sistema.

### Agentes
- **Data Architect** (HIGH, `gpt-5.5`) — diseño del modelo
- **Backend Architect** (MEDIUM, `pro`) — validación contra APIs
- **Devil's Advocate** (HIGH, `gpt-5.5`, thinking=high) — auditoría

### Entregables
1. Modelo entidad-relación completo
2. Migraciones SQL generadas
3. Seeds para datos de prueba
4. Documentación de decisiones (ADR)

### Sub-fases
1. Data Architect: diseño del modelo (basado en `01-modelo-datos-actual.md`)
2. Backend Architect: validación de queries contra los endpoints necesarios
3. Devil's Advocate: auditoría del modelo
4. Ajustes y validación final

### Gate: Software Gate + UX/Product Gate
- ¿El modelo soporta todos los casos de uso del discovery?
- ¿Está optimizado para los queries del frontend?

**Output:** `outputs/03-modelo-datos.md` + `migrations/*.sql`

---

## 4. FASE UX_UI — Diseño de Experiencia

### Objetivo
Diseñar la interfaz del nuevo ecommerce con Tailwind CSS.

### Agentes
- **UX Designer** (HIGH, `gpt-5.5`) — flujos de usuario, wireframes
- **UI Designer** (HIGH, `gpt-5.5`) — sistema de diseño, componentes

### Sub-fases
1. UX Designer: user flows basados en los flujos actuales + mejoras
2. UI Designer: design system con Tailwind (colores, tipografía, componentes)
3. Prototipado de pantallas clave
4. Validación responsive

### Gate: Design Gate + UX/Product Gate

**Outputs:**
- `outputs/04-ux-flows.md`
- `outputs/04-ui-system.md`
- `outputs/04-wireframes/` (HTML/CSS con Tailwind)

---

## 5. FASE BUILD — Construcción

### Objetivo
Construir el ecommerce completo en NestJS + Tailwind.

### Agentes
- **Backend Architect** — desarrollo de módulos NestJS
- **Frontend Architect** — desarrollo de componentes y páginas
- **QA Engineer** — tests automatizados
- **Security Agent** — revisión continua de seguridad

### Estrategia de desarrollo

El build se organiza en sprints de 2 semanas. El orden sugerido:

| Sprint | Módulo | Descripción |
|---|---|---|
| Sprint 1 | **Core + Auth** | Setup del proyecto, estructura de módulos, autenticación, roles |
| Sprint 2 | **Productos** | CRUD productos, variantes, SKU, stock, precios, imágenes, categorías, marcas, tags, propiedades |
| Sprint 3 | **Checkout + Carrito** | Carrito, wishlist, checkout 4 pasos, direcciones |
| Sprint 4 | **Pagos** | MercadoPago, Modo, PadPio, ZN — integraciones completas |
| Sprint 5 | **Pedidos + Clientes** | Gestión de pedidos, panel de clientes, cuenta, historial |
| Sprint 6 | **Admin Panel** | Dashboard, reportes, gestión de banner/sliders/secciones, import/export Excel |
| Sprint 7 | **Features avanzadas** | Cupones, envíos, encuestas, carritos abandonados, devoluciones |
| Sprint 8 | **Multi-cliente** | Sistema de tenants/branches, configuración por cliente |

### Gate: Software Gate (por sprint)
- Code review
- Tests passing
- Lint + format + typecheck

**Outputs:** Código en el repo nuevo + `outputs/05-sprint-N-retro.md` por sprint

---

## 6. FASE QA — Testing Integral

### Objetivo
Validar que el nuevo sistema funciona correctamente y es equivalente funcional al legacy.

### Agentes
- **QA Engineer** (MEDIUM, `pro`) — test suites
- **Security Agent** (HIGH, `gpt-5.5`) — penetration testing
- **Devil's Advocate** (HIGH, `gpt-5.5`) — auditoría final

### Tipos de testing
1. Tests unitarios (NestJS services)
2. Tests de integración (API endpoints)
3. Tests E2E (flujos completos de compra)
4. Tests de performance
5. Tests de seguridad (OWASP Top 10)
6. Smoke tests de integraciones de pago

### Gate: Software Gate

**Output:** `outputs/06-qa-report.md`

---

## 7. FASE DEPLOY — Lanzamiento

### Objetivo
Poner el nuevo ecommerce en producción sin romper los sites de clientes existentes.

### Agentes
- **DevOps Engineer** — CI/CD y deploy
- **QA Engineer** — smoke tests post-deploy

### Estrategia
1. Deploy en staging
2. Validación de Gero
3. Estrategia de migración por cliente (empezar por uno, validar, expandir)
4. Período de sombra (nuevo sistema en paralelo con el viejo)
5. Rollback plan documentado

### Gate: Software Gate + Client Gate

**Output:** `outputs/07-deploy-plan.md`

---

## 8. FASE POST_LAUNCH — Monitoreo y Estabilización

### Objetivo
Monitorear el sistema en producción y resolver issues.

### Agentes
- **DevOps Engineer** — monitoreo
- **QA Engineer** — reporte de bugs
- **PM** — cierre formal del proyecto

### Duración: 1-2 semanas
- Monitoreo de errores
- Feedback de Gero y usuarios
- Hotfixes
- Cierre de proyecto y aprendizaje global

### Gate: Reporting Gate

**Output:** `outputs/08-post-launch-report.md`

---

## 👥 Squad Completo y Roles

| # | Agente | Modelo | Fase principal | Rol específico |
|---|---|---|---|---|
| 1 | **PM** | `flash` | Todas | Organiza sprints, cadencia, bloqueos |
| 2 | **System Auditor** | `gpt-5.5` | DISCOVERY | Documenta TODO el sistema actual |
| 3 | **Product Owner** | `gpt-5.5` | DISCOVERY | Backlog, priorización, reglas de negocio |
| 4 | **Backend Architect** | `pro` | TECH_STACK, DB_DESIGN, BUILD | Arquitectura NestJS, módulos |
| 5 | **Frontend Architect** | `pro` | TECH_STACK, UX_UI, BUILD | Arquitectura Tailwind, componentes |
| 6 | **Security Agent** | `gpt-5.5` | DISCOVERY, QA | Auditoría de seguridad legacy + nuevo |
| 7 | **QA Engineer** | `pro` | BUILD, QA, DEPLOY | Tests, validación |
| 8 | **Data Architect** | `gpt-5.5` | TECH_STACK, DB_DESIGN | Modelo de datos y migración |
| 9 | **UX Designer** | `gpt-5.5` | UX_UI | Flujos de usuario |
| 10 | **UI Designer** | `gpt-5.5` | UX_UI | Sistema de diseño Tailwind |
| 11 | **DevOps Engineer** | `flash` | TECH_STACK, DEPLOY, POST_LAUNCH | Infraestructura, CI/CD |
| 12 | **Devil's Advocate** | `gpt-5.5` | Pre-cierre de cada fase | Auditoría crítica |

---

## 🔒 Quality Gates por Fase

| Fase | Gates | ¿Bloqueante? |
|---|---|---|
| DISCOVERY | Strategy Gate | ✅ |
| TECH_STACK | Strategy Gate | ✅ |
| DB_DESIGN | Software Gate + UX/Product Gate | ✅ |
| UX_UI | Design Gate + UX/Product Gate | ✅ |
| BUILD | Software Gate (por sprint) | ✅ |
| QA | Software Gate | ✅ |
| DEPLOY | Software Gate + Client Gate | ✅ |
| POST_LAUNCH | Reporting Gate | ✅ |

---

## 💰 Presupuesto Estimado

| Fase | Agentes activos | Modelos | Costo est. USD |
|---|---|---|---|
| DISCOVERY | 4 | flash + pro + gpt-5.5 | ~8-12 |
| TECH_STACK | 5 | flash + pro + gpt-5.5 | ~6-10 |
| DB_DESIGN | 3 | pro + gpt-5.5 | ~5-8 |
| UX_UI | 2 | gpt-5.5 | ~4-6 |
| BUILD (8 sprints) | 3-4 | pro + gpt-5.5 | ~30-40 |
| QA | 3 | pro + gpt-5.5 | ~5-8 |
| DEPLOY | 2 | flash + pro | ~2-3 |
| POST_LAUNCH | 2 | flash | ~2-3 |
| **TOTAL ESTIMADO** | | | **~62-90** |

> ⚠️ Límite diario: $50 USD. Si una sesión supera $10 → requiere aprobación.

---

## 📋 Timeline Estimado

| Fase | Duración est. | Depende de |
|---|---|---|
| DISCOVERY | 1-2 días | — |
| TECH_STACK | 1-2 días | DISCOVERY |
| DB_DESIGN | 1-2 días | TECH_STACK |
| UX_UI | 2-3 días | DISCOVERY |
| BUILD | 4-8 semanas | TECH_STACK + DB_DESIGN + UX_UI |
| QA | 1 semana | BUILD |
| DEPLOY | 2-3 días | QA |
| POST_LAUNCH | 1-2 semanas | DEPLOY |

**Total estimado: 8-14 semanas** (dependiendo de velocidad de iteración)

---

## ⚠️ Riesgos Identificados

| Riesgo | Impacto | Mitigación |
|---|---|---|
| No hay migraciones SQL — el modelo de datos se infiere | Alto | System Auditor dedica más tiempo a inferir relaciones desde queries PHP |
| Múltiples pasarelas de pago con implementaciones distintas | Alto | Documentar cada una por separado, testear exhaustivamente |
| Branches por cliente pueden divergir | Medio | El PO define un core común + configuración por tenant |
| Credenciales hardcodeadas en el repo | Alto | Security Agent audita y propone secret management |
| Budget de agentes ($50/día) | Medio | Usar `flash` para tareas operativas, reservar `gpt-5.5` solo para decisiones críticas |

---

**📌 Próximo paso:** Si validás este plan, arranco con la Fase DISCOVERY — el System Auditor clona la rama `refactoring` y empieza a documentar el sistema completo.

---

*Documento generado por Jarvis (Orchestrator). Sujeto a validación de Gero antes de ejecutar.*
