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

## Clasificación: Tipo A, B o C + Complejidad S, M, L, XL

| Tipo | Descripción | Pipeline |
|---|---|---|
| **A — Greenfield** | Proyecto nuevo desde cero. Sin código, sin repo, sin nada. | Flujo completo: Discovery → DB Design → Tech Stack → Branding → UX/UI → Build |
| **B — Brownfield** | Proyecto existente con código heredado. Hay repo, hay stack, hay decisiones previas. | System Auditor → Gap Analysis → Refactor/Extender |
| **C — Parcial** | Hay algo (diseños, specs, un MVP a medio hacer) pero no está completo. | Evaluar estado actual → Completar Discovery faltante → Reestructurar |

> ⚡ **La complejidad (S/M/L/XL) se determina con el checklist de 6 preguntas en `shared/metodologia/MATRIZ-SQUADS.md`.**
> **El squad de agentes NO se elige subjetivamente. Jarvis consulta la matriz: Tipo × Complejidad → Squad fijo.**

---

## Pasos

```
PASO 0 — JARVIS CLASIFICA (Tipo + Complejidad)

Jarvis pregunta a Gero por Telegram:
  "⚡ Proyecto [nombre]: ¿qué tenemos?
   
   A) Nada — proyecto nuevo desde cero (Greenfield)
   B) Código existente — hay repo, hay stack, hay que auditar (Brownfield)
   C) Algo hay — specs, diseños, MVP a medias (Parcial)
   
   Si es B o C → pasame el link al repo o los archivos."

Gero responde → Jarvis determina Tipo.

Luego Jarvis ejecuta el checklist de complejidad (6 preguntas, ver MATRIZ-SQUADS.md):
  1. ¿Cuántas entidades de negocio?
  2. ¿Cuántos roles de usuario?
  3. ¿Qué nivel de autenticación?
  4. ¿Cuántas integraciones externas?
  5. ¿Escala esperada de usuarios?
  6. ¿Requiere IA o features no estándar?

→ Resultado: S (0-2 pts) / M (3-5 pts) / L (6-9 pts) / XL (10-18 pts)

Jarvis consulta MATRIZ-SQUADS.md y presenta a Gero:
  "📊 Clasificación: Tipo X, Complejidad Y (Z pts)
   Squad asignado: [lista de agentes]
   ¿Confirmás?"

Gero confirma o ajusta → Jarvis registra en state.json:
  - project_type: "A" | "B" | "C"
  - complexity: "S" | "M" | "L" | "XL"
  - squad: [lista de agentes]


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
   - Primera entrada del Decision Log: clasificación de Tipo + Complejidad + Squad asignado.
   - Incluye puntaje del checklist de complejidad (6 preguntas).
   - Los arquitectos agregan ADRs subsiguientes. ES el Decision Log único — no se crean archivos de registro redundantes.

---

## Outputs

- `state.json` actualizado con `project_type: "A" | "B" | "C"` y `complexity: "S" | "M" | "L" | "XL"`
- `MEMORIA-PROYECTO.md` — instanciada del template
- `docs/decisions/ADR-000.md` — decisión de clasificación (Tipo + Complejidad + Squad)
- `outputs/00-project-assessment.md` — resumen del triaje + puntaje de complejidad

**Para Tipo B adicionalmente:**
- `outputs/00-audit-report.md` — reporte completo del System Auditor

**Para Tipo C adicionalmente:**
- `outputs/00-gap-analysis.md` — inventario y plan de gaps

---

## Quality Gate

- **Classification Gate** — Tipo + Complejidad deben estar justificados (checklist de 6 preguntas) y aprobados por Gero antes de avanzar.
- **Squad Gate** — El squad asignado debe coincidir con MATRIZ-SQUADS.md. Si Gero ajusta el squad manualmente, se registra en ADR-000 como excepción.
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
