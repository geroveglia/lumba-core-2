# Workflow 00: Project Assessment & Triaje Inicial

> **PRIMER workflow de TODO proyecto. Antes que cualquier otra cosa.**
> **Clasifica el proyecto en Tipo A (nuevo), B (existente) o C (parcial).**

---

## Principio

> **No todos los proyectos empiezan desde cero. El sistema debe adaptarse a lo que ya existe.**
>
> Antes de ejecutar un solo agente de Discovery, DB Design o Branding, necesitamos saber con qué estamos lidiando.

---

## Cuándo se usa

- **Obligatorio** como primer paso de CUALQUIER proyecto en Core-Product.
- Se ejecuta una sola vez al inicio del proyecto.
- Si el proyecto ya fue clasificado, no se re-ejecuta.

---

## Clasificación: Tipo A, B o C

| Tipo | Descripción | Pipeline |
|---|---|---|
| **A — Greenfield** | Proyecto nuevo desde cero. Sin código, sin repo, sin nada. | Flujo completo: Discovery → DB Design → Tech Stack → Branding → UX/UI → Build |
| **B — Brownfield** | Proyecto existente con código heredado. Hay repo, hay stack, hay decisiones previas. | System Auditor → Gap Analysis → Refactor/Extender |
| **C — Parcial** | Hay algo (diseños, specs, un MVP a medio hacer) pero no está completo. | Evaluar estado actual → Completar Discovery faltante → Reestructurar |

---

## Pasos

```
PASO 0 — JARVIS CLASIFICA

Jarvis pregunta a Gero por Telegram:
  "⚡ Proyecto [nombre]: ¿qué tenemos?
   
   A) Nada — proyecto nuevo desde cero (Greenfield)
   B) Código existente — hay repo, hay stack, hay que auditar (Brownfield)
   C) Algo hay — specs, diseños, MVP a medias (Parcial)
   
   Si es B o C → pasame el link al repo o los archivos."

Gero responde → Jarvis registra project_type en state.json


PASO 1 — INSTANCIAR MEMORIA DEL PROYECTO

Jarvis spawnea PM Agent:
  1. Crea /proyectos/{nombre}/MEMORIA-PROYECTO.md
     → Basado en knowledge/templates/project-memory-template.md
  2. Crea /proyectos/{nombre}/docs/decisions/ (para ADRs)
  3. Inicializa ADR-000: Project Assessment Decision
     → Tipo de proyecto, clasificación, justificación


PASO 2 — SEGÚN TIPO DE PROYECTO

┌──────────────────────────────────────────────────────────────┐
│ TIPO A — GREENFIELD                                          │
│                                                              │
│ → Avanza a Workflow 01 (Discovery + Definición Funcional)    │
│ → Pipeline completo desde cero                               │
│ → Se habilita Bootstrap Workflow post Tech Stack             │
└──────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────┐
│ TIPO B — BROWNFIELD                                          │
│                                                              │
│ → Jarvis spawnea SYSTEM AUDITOR                              │
│   (nuevo agente, Pro + thinking)                             │
│                                                              │
│ System Auditor ejecuta:                                      │
│   1. Codebase Audit                                          │
│      ├── Estructura del proyecto                             │
│      ├── Stack utilizado y versiones                         │
│      ├── Dependencias (actualizadas/obsoletas/vulnerables)   │
│      └── Deuda técnica visible (TODO, FIXME, commented code) │
│                                                              │
│   2. Architecture Audit                                      │
│      ├── Patrones usados vs anti-patrones                    │
│      ├── Acoplamiento y cohesión                             │
│      └── Escalabilidad y bottlenecks                         │
│                                                              │
│   3. Database Audit                                          │
│      ├── Schema actual (tablas, relaciones, índices)         │
│      ├── Migraciones pendientes                              │
│      └── Performance de queries (si hay logs)                │
│                                                              │
│   4. Security Scan                                           │
│      ├── Secrets expuestos                                   │
│      ├── Dependencias vulnerables (npm audit, etc.)          │
│      └── OWASP Top 10 superficial                            │
│                                                              │
│   5. Gap Analysis                                            │
│      ├── ¿Qué tiene vs qué necesita?                         │
│      ├── ¿Qué hay que refactorear sí o sí?                   │
│      ├── ¿Qué se puede aprovechar?                           │
│      └── Estimación de esfuerzo para cerrar gaps             │
│                                                              │
│ Output: /proyectos/{nombre}/outputs/00-audit-report.md       │
│                                                              │
│ Después de la auditoría:                                     │
│ → Si el código es salvable → Workflow de refactor/evolución  │
│ → Si es insalvable → Proponer rewrites por componentes       │
│ → Gero decide el camino                                      │
└──────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────┐
│ TIPO C — PARCIAL                                             │
│                                                              │
│ → Jarvis spawnea PM Agent + Research Agent:                  │
│   1. Inventario de lo que existe:                            │
│      ├── Specs, diseños, wireframes, prototipos              │
│      ├── Código (si hay)                                     │
│      └── Documentación y decisiones previas                  │
│                                                              │
│   2. Evaluación de completitud:                              │
│      ├── ¿Qué fases del pipeline ya se cumplieron?           │
│      ├── ¿Qué falta?                                         │
│      └── ¿La base existente es sólida o hay que rehacer?     │
│                                                              │
│   3. Gap fill:                                               │
│      └── Ejecutar SOLO las fases faltantes del pipeline      │
│                                                              │
│ Output: /proyectos/{nombre}/outputs/00-gap-analysis.md       │
│                                                              │
│ Gero aprueba el plan → se ejecutan fases faltantes           │
└──────────────────────────────────────────────────────────────┘
```

---

## Templates instanciados automáticamente

Al ejecutar este workflow, Jarvis DEBE crear:

1. **`/proyectos/{nombre}/MEMORIA-PROYECTO.md`**
   - Basado en `knowledge/templates/project-memory-template.md`
   - Memoria evolutiva obligatoria que TODOS los agentes consultan antes de actuar.
   - Se actualiza en cada fase. No se reemplaza.

2. **`/proyectos/{nombre}/docs/decisions/ADR-000.md`**
   - Basado en `knowledge/templates/adr-template.md`
   - Primera entrada del Decision Log: la decisión de clasificación del proyecto.
   - Los arquitectos agregan ADRs subsiguientes. ES el Decision Log único — no se crean archivos de registro redundantes.

---

## Outputs

- `state.json` actualizado con `project_type: "A" | "B" | "C"`
- `MEMORIA-PROYECTO.md` — instanciada del template
- `docs/decisions/ADR-000.md` — decisión de clasificación
- `outputs/00-project-assessment.md` — resumen del triaje

**Para Tipo B adicionalmente:**
- `outputs/00-audit-report.md` — reporte completo del System Auditor

**Para Tipo C adicionalmente:**
- `outputs/00-gap-analysis.md` — inventario y plan de gaps

---

## Quality Gate

- **Classification Gate** — el tipo de proyecto debe estar justificado y aprobado por Gero antes de avanzar.
- Para Tipo B: el audit report debe pasar Devil's Advocate antes de decidir el camino.

---

## Duración estimada

- Tipo A: 1 hora (solo clasificación + instanciar templates)
- Tipo B: 2-4 horas (incluye System Auditor)
- Tipo C: 1-2 horas (inventario y gap analysis)

---

## Anti-patterns

- ❌ "Asumamos que es Greenfield y arranquemos." → Siempre clasificar primero.
- ❌ "El código existente es una porquería, reescribamos todo." → Auditar antes de decidir.
- ❌ "No necesitamos MEMORIA-PROYECTO para un proyecto chico." → Siempre se instancia.
- ❌ "Los ADRs son solo para proyectos grandes." → Decision Log desde el día 1.

---

**Workflow 00** · Project Assessment · ⚡
