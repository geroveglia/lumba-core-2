# ORQUESTACIÓN EN OPENCLAW — LUMBA CORE v2.0

> **Versión:** v2.0
> **Propósito:** definir cómo Jarvis orquesta agentes en OpenClaw usando sessions, TaskFlow, cron y handoffs.
> **Última actualización:** 2 de junio de 2026.

---

## 1. PROPÓSITO

Este documento conecta el diseño conceptual de Lumba Core con la implementación real en OpenClaw. Define:

- Cómo Jarvis recibe, clasifica y enruta pedidos.
- Cómo se spawnear agentes como sub-agents.
- Cómo se maneja el estado del proyecto entre fases.
- Cómo funciona el human-in-the-loop en Telegram/Slack.

---

## 2. ARQUITECTURA DE ORQUESTACIÓN

```
                    ┌─────────────────────────────┐
                    │     Jarvis ⚡ (main agent)   │
                    │     Orchestrator central     │
                    └─────────────┬───────────────┘
                                  │
            ┌─────────────────────┼─────────────────────┐
            │                     │                     │
            ▼                     ▼                     ▼
    ┌───────────────┐   ┌───────────────┐   ┌───────────────┐
    │  TaskFlow Job │   │  Sub-Agent    │   │  Cron Job     │
    │  (workflows   │   │  (agentes     │   │  (heartbeats, │
    │   multi-paso) │   │   individual) │   │   recordatorios│
    └───────────────┘   └───────────────┘   └───────────────┘
            │                     │                     │
            └─────────────────────┼─────────────────────┘
                                  │
                                  ▼
                    ┌─────────────────────────────┐
                    │     Output Persistente       │
                    │  /proyectos/{nombre}/outputs │
                    └─────────────────────────────┘
```

---

## 3. JARVIS — EL ORCHESTRATOR

Jarvis es el agente `main` de OpenClaw. No produce contenido final. Su función:

### 3.1 Ciclo de operación

```
1. RECIBIR   → pedido del humano (Telegram) o de un agente (handoff)
2. CLASIFICAR → tipo de tarea: branding / marketing / product / universal
3. CARGAR    → memoria del proyecto + cliente
4. SELECCIONAR → workflow aplicable
5. SPAWNEAR  → sub-agents necesarios con sessions_spawn
6. VALIDAR   → output contra JSON Schema
7. ESCALAR   → al humano si corresponde (aprobación, bloqueo, duda)
```

### 3.2 Herramientas OpenClaw que usa Jarvis

| Herramienta | Uso |
|---|---|
| `sessions_spawn` | Crear sub-agents para cada tarea especializada |
| `sessions_send` | Enviar instrucciones a sub-agents activos |
| `sessions_history` | Leer output de sub-agents que terminaron |
| `memory_search` | Buscar en memoria de cliente/proyecto |
| `memory_get` | Cargar memoria antes de decidir |
| `cron add` | Crear recordatorios para follow-ups y aprobaciones |
| `exec` | Leer/escribir archivos de estado del proyecto |

### 3.3 Modelo

Jarvis usa `deepseek-v4-flash` para enrutamiento simple. Escala a `deepseek-v4-pro` cuando:
- La clasificación es ambigua
- Hay que decidir entre múltiples workflows
- Un handoff falló y hay que diagnosticar

---

## 4. SPAWN DE AGENTES

### 4.1 Cuándo spawnear vs hacer inline

| Tarea | Método | Razón |
|---|---|---|
| Clasificar pedido | Inline (Jarvis) | Simple, rápido |
| Research de mercado | **Sub-agent** | Usa web_search, web_fetch |
| Diseñar modelo de datos | **Sub-agent (Opus)** | Aislado, costoso, requiere modelo específico |
| Escribir spec funcional | **Sub-agent** | Documento largo, necesita foco |
| Auditoría pre-entrega | **Sub-agent (Pro + thinking)** | Crítico, requiere razonamiento profundo |
| Handoff entre agentes | `sessions_send` | Pasar output a siguiente agente |

### 4.2 Ejemplo de spawn

```javascript
// Jarvis spawn al Data Architect
sessions_spawn({
  task: "Diseñar modelo de datos para ecommerce 'TiendaX'. 
         Entidades: productos, categorías, clientes, órdenes, pagos.
         Stack: PostgreSQL (Supabase). Multi-tenant: no.
         Output esperado: modelo ER + migraciones SQL + ADR de decisiones.
         Escribir output en /proyectos/tiendax/outputs/00-modelo-datos.md",
  taskName: "tiendax_data_architect",
  model: "claude-opus-4",
  thinking: "high",
  mode: "run"
})
```

### 4.3 Cadena de handoffs

```
Jarvis spawn data-architect (Opus)
  → data-architect escribe /proyectos/tiendax/outputs/00-modelo-datos.md
  → data-architect termina → evento a Jarvis

Jarvis lee output, spawn devils-advocate (Pro + thinking)
  → devils-advocate lee /proyectos/tiendax/outputs/00-modelo-datos.md
  → devils-advocate escribe /proyectos/tiendax/outputs/00-audit-modelo.md
  → devils-advocate termina → evento a Jarvis

Jarvis evalúa: ¿pasa el gate?
  → SI: notifica al humano para aprobación
  → NO: re-spawn data-architect con feedback del DA
```

---

## 5. ESTADO DEL PROYECTO

### 5.1 State Machine

```
                            ┌─────────┐
                            │  BRIEF  │
                            └────┬────┘
                                 │
                                 ▼
                            ┌─────────┐
                            │PROPOSAL │ ◄── Cliente firma.
                            └────┬────┘
                                 │
                                 ▼
                     ┌──────────────────────┐
                     │  PROJECT ASSESSMENT  │ ◄── Workflow 00
                     │  Triaje: A / B / C   │     Templates instanciados
                     └──┬───────┬───────┬──┘
                        │       │       │
              TIPO A   │  TIPO B│       │ TIPO C
              (Nuevo)  │ (Exist)│       │ (Parcial)
                        │       │       │
                        ▼       ▼       ▼
                  ┌─────────┐ ┌───────────┐ ┌──────────────┐
                  │DISCOVERY │ │SYSTEM     │ │GAP ANALYSIS  │
                  │W01      │ │AUDITOR    │ │+ completar   │
                  └────┬────┘ └─────┬─────┘ │fases faltantes│
                       │            │       └──────┬───────┘
                       │            ▼              │
                       │      ┌───────────┐        │
                       │      │Gero decide│        │
                       │      │camino     │        │
                       │      └─────┬─────┘        │
                       │            │              │
                       ▼            ▼              ▼
                  ┌──────────┐
                  │TECH_STACK│ ◄── Gero elige.
                  │W02       │
                  └────┬─────┘
                       │
                       ▼
                  ┌─────────┐
                  │DB_DESIGN│ ◄── Opus
                  │W03      │     SOLO después de
                  └────┬────┘     Discovery cerrado
                       │            Y Tech Stack
                       │            definido.
                       ▼
                  ┌─────────┐
                  │BOOTSTRAP│ ◄── Solo Tipo A.
                  │W03.5    │     Scaffolding auto.
                  └────┬────┘
                       ▼
                  ┌─────────┐
                  │ BRANDING │ ◄── Nace del discovery.
                  └────┬────┘
                       ▼
                  ┌─────────┐
                  │ UX_UI   │
                  └────┬────┘
                       ▼
                  ┌─────────┐
                  │MARKETING│
                  └────┬────┘
                       ▼
                  ┌─────────┐
                  │  BUILD  │ ◄── Documentation Agent en paralelo.
                  └────┬────┘
                       ▼
                  ┌─────────┐
                  │   QA    │
                  └────┬────┘
                       ▼
                  ┌─────────┐
                  │ DEPLOY  │
                  └────┬────┘
                       ▼
                  ┌──────────┐
                  │POST_LAUNCH│ ◄── Semana 1.
                  └────┬─────┘
                       ▼
                  ┌─────────┐
                  │  DONE   │
                  └─────────┘
```

### 5.2 Archivo de estado

Cada proyecto tiene `/proyectos/{nombre}/state.json`:

```json
{
  "project": "tiendax",
  "current_phase": "TECH_STACK",
  "phases": {
    "BRIEF": {
      "status": "completed",
      "completed_at": "2026-06-01T15:00:00-03:00",
      "outputs": ["/proyectos/tiendax/outputs/brief.md"],
      "approved_by": "esteban",
      "rejection_count": 0,
      "max_iterations": 3
    },
    "PROPOSAL": {
      "status": "completed",
      "completed_at": "2026-06-01T17:00:00-03:00",
      "outputs": ["/proyectos/tiendax/outputs/propuesta-comercial.md"],
      "approved_by": "cliente",
      "rejection_count": 0,
      "max_iterations": 2
    },
    "DISCOVERY": {
      "status": "completed",
      "completed_at": "2026-06-05T12:00:00-03:00",
      "outputs": ["/proyectos/tiendax/outputs/01-discovery.md", "/proyectos/tiendax/outputs/01-spec-funcional.md"],
      "approved_by": "esteban",
      "rejection_count": 0,
      "max_iterations": 2
    },
    "TECH_STACK": {
      "status": "in_progress",
      "started_at": "2026-06-05T14:00:00-03:00",
      "rejection_count": 0,
      "max_iterations": 2
    },
    "DB_DESIGN": { "status": "pending", "rejection_count": 0, "max_iterations": 3 },
    "BRANDING": { "status": "pending", "rejection_count": 0, "max_iterations": 2 },
    "UX_UI": { "status": "pending", "rejection_count": 0, "max_iterations": 2 },
    "MARKETING": { "status": "pending", "rejection_count": 0, "max_iterations": 2 },
    "BUILD": { "status": "pending", "rejection_count": 0, "max_iterations": 3 },
    "QA": { "status": "pending", "rejection_count": 0, "max_iterations": 3 },
    "DEPLOY": { "status": "pending", "rejection_count": 0, "max_iterations": 1 },
    "POST_LAUNCH": { "status": "pending", "rejection_count": 0, "max_iterations": 1 }
  },
  "gates": {
    "DB_DESIGN": {
      "passed": false,
      "audited_by": null,
      "blocking_issues": []
    }
  },
  "approvals": [],
  "budget": {
    "limit_usd": 50,
    "spent_usd": 0,
    "last_check": null
  }
}
```

### 5.3 Cómo Jarvis usa el estado

1. **Al recibir un pedido** → lee `state.json` para saber en qué fase está el proyecto.
2. **Al spawnear un agente** → actualiza `state.json` con `status: "in_progress"` y `session_id`.
3. **Al recibir output** → actualiza `state.json`, evalúa gate, decide next action.
4. **En cada gate** → si `blocking_issues` no está vacío, no avanza.

---

## 6. HUMAN-IN-THE-LOOP EN OPENCLAW

### 6.1 Canales

| Canal | Para qué |
|---|---|
| **Telegram** (canal principal de Gero) | Aprobaciones, bloqueos, decisiones |
| **Discord/Slack** (si se configura) | Notificaciones al equipo |
| **Cron + Telegram** | Recordatorios de aprobación pendiente |

### 6.2 Flujo de aprobación

```
1. Agente termina output → escribe archivo
2. Jarvis evalúa gate → ¿requiere aprobación humana?
3. SI → Jarvis notifica por Telegram:
   "⚡ Fase DB_DESIGN completada para TiendaX.
    Output: /proyectos/tiendax/outputs/00-modelo-datos.md
    Audit: /proyectos/tiendax/outputs/00-audit-modelo.md
    ¿Apruebo para avanzar a DISCOVERY? (responde 'sí' o 'cambios')"
4. Jarvis crea cron job de recordatorio (24h timeout)
5. Humano responde:
   - "sí" → Jarvis avanza a siguiente fase
   - "cambios" → Jarvis pide detalles y re-spawnea agente
   - (sin respuesta en 48h) → Jarvis re-notifica, escala al Founder
```

### 6.3 Timeouts

| Gate | Timeout | Acción si no responde |
|---|---|---|
| Aprobación de fase | 48h | Re-notificar + escalar al Founder |
| Aprobación de deploy | 4h | Bloquear deploy, notificar tech lead |
| Cambio de scope | 24h | Pausar proyecto hasta respuesta |
| Override de Devil's Advocate | 72h | Mantener bloqueo, escalar a socios |

### 6.4 Registro de aprobaciones

```json
// /proyectos/tiendax/approvals/2026-06-02-db-design.json
{
  "approval_id": "appr_001",
  "timestamp": "2026-06-02T12:00:00-03:00",
  "approver": "esteban",
  "type": "phase_gate",
  "phase": "DB_DESIGN",
  "what_was_approved": "Modelo de datos para TiendaX",
  "approved": true,
  "conditions": ["Agregar índice en orders.user_id"]
}
```

---

## 7. TASKFLOW PARA WORKFLOWS MULTI-PASO

### 7.1 Cuándo usar TaskFlow

TaskFlow se usa para workflows que tienen **múltiples pasos con dependencias** y necesitan **durabilidad entre pasos**:

| Workflow | ¿TaskFlow? | Razón |
|---|---|---|
| 00 - Diseño de DB | **Sí** | 5 pasos (research → architect → DA → backend → auditor) |
| 01 - Discovery + Funcional | **Sí** | 9 pasos encadenados |
| 02 - Diseño UX/UI | **Sí** | Múltiples handoffs designer → reviewer |
| 04 - Bug crítico | No | Sub-agent único, respuesta inmediata |

### 7.2 Estructura de un TaskFlow Job

```yaml
taskflow:
  name: "tiendax-db-design"
  workflow: "00-diseno-base-datos"
  steps:
    - id: research
      agent: research-agent
      model: flash
      action: "Investigar entidades de negocio para ecommerce TiendaX"
      output: "/proyectos/tiendax/outputs/00-research-entidades.md"
      
    - id: data_model
      agent: data-architect
      model: opus
      action: "Diseñar modelo de datos completo"
      depends_on: [research]
      output: "/proyectos/tiendax/outputs/00-modelo-datos.md"
      
    - id: audit
      agent: devils-advocate
      model: pro
      thinking: high
      action: "Auditar modelo de datos"
      depends_on: [data_model]
      output: "/proyectos/tiendax/outputs/00-audit-modelo.md"
      
    - id: backend_validation
      agent: backend-architect
      model: pro
      action: "Validar modelo contra APIs necesarias"
      depends_on: [data_model]
      output: "/proyectos/tiendax/outputs/00-backend-validation.md"
      
    - id: final_audit
      agent: product-auditor
      model: opus
      action: "Auditoría final del modelo de datos"
      depends_on: [audit, backend_validation]
      output: "/proyectos/tiendax/outputs/00-final-audit.md"
      
  gates:
    - after: final_audit
      type: human_approval
      channel: telegram
      timeout_hours: 48
```

---

## 8. OUTPUT PERSISTENTE

### 8.1 Estructura de outputs por proyecto

```
proyectos/{nombre}/
├── state.json              ← Estado actual del proyecto (máquina de estados)
├── brief.md                ← Brief original
├── outputs/
│   ├── 00-modelo-datos.md           ← Workflow 0
│   ├── 00-audit-modelo.md
│   ├── 00-adr-stack.md              ← Architecture Decision Record
│   ├── 01-discovery.md              ← Workflow 1
│   ├── 01-spec-funcional.md
│   ├── 02-ux-flows.md               ← Workflow 2
│   ├── 02-ui-system.md
│   ├── 03-feature-xxx.md            ← Workflow 3
│   └── ...
├── approvals/              ← Registro de aprobaciones humanas
│   └── {fecha}-{fase}.json
├── handoffs/               ← JSON de comunicación entre agentes
│   └── {fecha}-{from}-{to}.json
├── migrations/             ← SQL migrations (Stack A)
│   └── {timestamp}_{desc}.sql
└── overrides/              ← Overrides de Devil's Advocate
    └── {fecha}-{motivo}.md
```

### 8.2 Convención de nombres

- Outputs: `{fase}-{descripcion}.md` donde fase es 00-05
- Approvals: `{YYYY-MM-DD}-{fase}.json`
- Handoffs: `{YYYY-MM-DD}-{from_agent}-{to_agent}.json`
- Migrations: timestamp de Supabase

---

## 9. TOOLS DE OPENCLAW MAPEADAS A AGENTES

Cada agente se define con las tools de OpenClaw que necesita:

| Agente | Tools OpenClaw |
|---|---|
| **research-agent** | `web_search`, `web_fetch`, `write`, `read` |
| **data-architect** | `write`, `read`, `exec` (para validar SQL) |
| **devils-advocate** | `read`, `write` |
| **product-owner** | `read`, `write`, `memory_search` |
| **analyst-functional** | `read`, `write` |
| **ux-designer** | `read`, `write`, `canvas` (para wireframes HTML) |
| **ui-designer** | `read`, `write`, `canvas` |
| **frontend-architect** | `read`, `write`, `exec` |
| **backend-architect** | `read`, `write`, `exec` |
| **qa-engineer** | `read`, `exec`, `write` |
| **code-reviewer** | `read`, `write` |
| **devops-engineer** | `exec`, `read`, `write` |
| **product-auditor** | `read`, `write`, `memory_search` |
| **security-agent** | `read`, `exec`, `web_search` |
| **business-strategist** | `read`, `write`, `web_search`, `memory_search` |

### 9.1 Restricciones

- `exec` solo en sandbox o con paths scoped al proyecto.
- `web_search` y `web_fetch` solo para research (no para datos sensibles).
- `canvas` solo para prototipado visual interno.
- Nunca `exec` en producción sin aprobación humana.

---

## 10. CRON JOBS PARA SEGUIMIENTO

### 10.1 Jobs automáticos

| Job | Schedule | Acción |
|---|---|---|
| Healthcheck de proyectos activos | Cada 6h | Revisar `state.json` de cada proyecto, alertar si hay fases estancadas >72h |
| Recordatorio de aprobaciones | Cada 12h | Si hay `approvals` pendientes con timeout cerca, re-notificar |
| Budget check | Cada 4h | Si `budget.spent_usd > budget.limit_usd * 0.8`, alertar |

### 10.2 Ejemplo de cron job

```javascript
cron add({
  name: "lumba-budget-check",
  schedule: { kind: "every", everyMs: 14400000 }, // cada 4h
  payload: {
    kind: "agentTurn",
    message: "Revisar budget de todos los proyectos activos en /proyectos/*/state.json. Si algún proyecto superó el 80% del budget, notificar a Gero por Telegram."
  }
})
```

---

## 11. EJEMPLO COMPLETO: ECOMMERCE DESDE CERO

### 11.1 Secuencia de orquestación

```
Gero (Telegram): "Nuevo proyecto: TiendaX, ecommerce de ropa. Sin marca, sin web, sin nada."

Jarvis ⚡:
  1. Crea /proyectos/tiendax/
  2. Escribe state.json (fase: BRIEF)
  3. Spawn PM Agent → brief.md
  4. Spawn Research Agent → investigación de mercado
  
  5. Fase DISCOVERY:
     → Spawn business-strategist, product-owner, analyst-functional
     → Reglas de negocio cerradas y validadas
  
  6. Actualiza state.json (fase: TECH_STACK)
     → Jarvis pregunta a Gero: "¿qué stack usamos?"
     → Gero: "Stack A (Supabase + Vercel)"
     → Spawn frontend-architect + backend-architect + devops → validación
     → Spawn devils-advocate → challenge al stack
     → Jarvis registra aprobación del ADR de stack
  
  7. Actualiza state.json (fase: DB_DESIGN)
     → Spawn data-architect (Opus) → modelo de datos CON stack confirmado
     → Spawn devils-advocate (Pro+thinking) → auditoría del modelo
     → Spawn backend-architect (Pro) → validación APIs
     → Spawn product-auditor (Opus) → auditoría final
  
  8. Gate: ¿modelo aprobado?
     → Notifica a Gero por Telegram
     → Gero: "sí, agregá índice en orders.user_id"
     → Jarvis registra aprobación, actualiza state.json
  
  9. Fase BRANDING (si aplica):
     → Spawn brand-strategist, identity-designer, etc.
  
  10. ... (continúa por las fases restantes)
```

### 11.2 Trazabilidad completa

Cada paso deja:
- **Output markdown** en `/proyectos/tiendax/outputs/`
- **Handoff JSON** en `/proyectos/tiendax/handoffs/`
- **Approval JSON** en `/proyectos/tiendax/approvals/`
- **Estado actualizado** en `/proyectos/tiendax/state.json`

---

## 12. DIFERENCIAS CON LA VERSIÓN ANTERIOR (v1.0)

| Aspecto | v1.0 (Claude Code) | v2.0 (OpenClaw) |
|---|---|---|
| Orquestación | Implícita en CLAUDE.md | Explícita: Jarvis + sessions_spawn |
| Estado | No definido | state.json por proyecto |
| Handoffs | JSON Schema (teórico) | sessions_send + JSON Schema |
| Human-in-the-loop | "El humano aprueba" | Canal definido + timeouts + cron reminders |
| Output | Genérico | Estructura por proyecto con naming convention |
| Tools | Glob, Grep, Read, Write | web_search, web_fetch, exec, canvas, memory_search |
| TaskFlow | No existía | Workflows multi-paso con dependencias |

---

**FIN ORQUESTACIÓN EN OPENCLAW**
