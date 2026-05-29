# COMUNICACIÓN ENTRE AGENTES — LUMBA CORE

> **Versión:** v1.0
> **Tono:** Manual técnico.
> **Propósito:** definir cómo los agentes se comunican sin ambigüedades.
> **Última actualización:** 23 de mayo de 2026.

---

## 1. POR QUÉ IMPORTA

El **fallo #1** en sistemas multi-agente según MAST taxonomy (NeurIPS 2025) es **specification ambiguity** en hand-offs.

Cuando un agente le pasa output a otro en **texto libre**, el segundo agente lo interpreta. Esa interpretación puede ser distinta cada vez. Resultado: outputs inconsistentes.

**Solución de Lumba Core:** toda comunicación entre agentes pasa por **JSON Schema estricto**.

---

## 2. REGLAS GENERALES

1. Los agentes NO se hablan directamente entre sí. Todo pasa por el `Orchestrator`.
2. Toda comunicación es JSON Schema validado.
3. Cada JSON incluye metadata: `from_agent`, `to_agent`, `timestamp`, `version_hash`.
4. Si el JSON no valida, el `Orchestrator` rechaza la transferencia y pide regenerar.
5. Cada hand-off se archiva en `/proyectos/{nombre}/handoffs/`.

---

## 3. SCHEMA BASE — UNIVERSAL

Todo mensaje entre agentes lleva este envelope mínimo:

```json
{
  "envelope": {
    "from_agent": "string",
    "to_agent": "string",
    "via_orchestrator": true,
    "project": "string",
    "phase": "string",
    "timestamp": "ISO-8601",
    "version_hash": "sha256:string",
    "session_id": "string"
  },
  "content": {
    "type": "string",
    "payload": {}
  },
  "metadata": {
    "sources_consulted": [],
    "confidence": "alta|media|baja",
    "requires_review": true,
    "next_action": "string"
  }
}
```

---

## 4. SCHEMAS POR TIPO DE OUTPUT

### Schema A — Feature Specification (Product Owner → UX Designer)

```json
{
  "envelope": {
    "from_agent": "product-owner",
    "to_agent": "ux-designer",
    "type": "feature_specification"
  },
  "content": {
    "feature_name": "string",
    "user_problem": "string",
    "target_user": "string",
    "objective": "string",
    "success_criteria": ["string"],
    "user_stories": [
      {
        "id": "US-001",
        "as_a": "string",
        "i_want": "string",
        "so_that": "string",
        "acceptance_criteria": ["string"]
      }
    ],
    "edge_cases": ["string"],
    "constraints": ["string"],
    "out_of_scope": ["string"]
  }
}
```

### Schema B — UX Output (UX Designer → UI Designer / Frontend)

```json
{
  "envelope": {
    "from_agent": "ux-designer",
    "to_agent": "ui-designer",
    "type": "ux_specification"
  },
  "content": {
    "screens": [
      {
        "screen_id": "S001",
        "name": "string",
        "purpose": "string",
        "states": ["loading", "empty", "error", "success"],
        "components": ["string"],
        "user_flow_from": "string",
        "user_flow_to": "string"
      }
    ],
    "interactions": [],
    "responsive_breakpoints": ["mobile", "tablet", "desktop"],
    "accessibility_notes": []
  }
}
```

### Schema C — Architecture Decision (Backend Architect → Founder)

```json
{
  "envelope": {
    "from_agent": "backend-architect",
    "to_agent": "founder",
    "type": "architecture_decision_record"
  },
  "content": {
    "adr_id": "ADR-NNN",
    "title": "string",
    "status": "proposed|accepted|rejected",
    "context": "string",
    "decision": "string",
    "alternatives_considered": [
      {
        "option": "string",
        "pros": ["string"],
        "cons": ["string"]
      }
    ],
    "consequences": ["string"],
    "rollback_plan": "string"
  }
}
```

### Schema D — Audit Report (Devil's Advocate → Orchestrator)

```json
{
  "envelope": {
    "from_agent": "devils-advocate",
    "to_agent": "orchestrator",
    "type": "audit_report"
  },
  "content": {
    "audited_artifact": "string",
    "audit_date": "ISO-8601",
    "checklist_results": {
      "antiproducto_check": {"passed": true, "notes": "string"},
      "dolor_alignment": {"passed": true, "notes": "string"},
      "assumption_audit": {"passed": false, "notes": "string"},
      "failure_modes": {"passed": true, "notes": "string"},
      "scalability": {"passed": true, "notes": "string"},
      "cost": {"passed": true, "notes": "string"},
      "security": {"passed": true, "notes": "string"},
      "alternatives": {"passed": true, "notes": "string"},
      "memory_consistency": {"passed": true, "notes": "string"},
      "founder_alignment": {"passed": true, "notes": "string"}
    },
    "critical_risks": [
      {
        "risk": "string",
        "severity": "alta|media|baja",
        "blocking": true
      }
    ],
    "recommendation": "proceed|resolve_before_proceed|reject"
  }
}
```

### Schema E — Deliverable Ready for Client (any agent → Auditor → Founder)

```json
{
  "envelope": {
    "from_agent": "string",
    "to_agent": "auditor-{red}",
    "type": "deliverable_ready_for_audit"
  },
  "content": {
    "deliverable_type": "string",
    "client": "string",
    "project": "string",
    "brief_reference": "string",
    "file_paths": ["string"],
    "brief_compliance_check": {
      "objective_met": true,
      "audience_target_met": true,
      "restrictions_respected": true,
      "success_criteria_met": ["string"]
    },
    "ready_for_client": false
  }
}
```

### Schema F — Research Output (Research Agent → Orchestrator)

```json
{
  "envelope": {
    "from_agent": "research-agent",
    "to_agent": "orchestrator",
    "type": "research_output"
  },
  "content": {
    "research_question": "string",
    "findings": [
      {
        "finding": "string",
        "source": "URL",
        "source_type": "primary|secondary|tertiary",
        "confidence": "alta|media|baja"
      }
    ],
    "synthesis": "string",
    "recommendations": ["string"],
    "open_questions": ["string"]
  }
}
```

### Schema G — Growth Experiment Output (Growth Specialist → Orchestrator)

```json
{
  "envelope": {
    "from_agent": "growth-marketing-specialist",
    "to_agent": "orchestrator",
    "type": "growth_experiment"
  },
  "content": {
    "experiment_name": "string",
    "business_objective": "string",
    "funnel_stage": "acquisition|activation|conversion|retention|revenue",
    "bottleneck": "string",
    "hypothesis": "Si cambiamos X para Y, entonces Z debería mejorar porque W",
    "variable": "string",
    "control": "string",
    "variant": "string",
    "audience": "string",
    "primary_kpi": "string",
    "guardrail_metrics": ["string"],
    "duration_days": "number",
    "decision_rules": {
      "scale_if": "string",
      "iterate_if": "string",
      "stop_if": "string",
      "investigate_if": "string"
    },
    "required_assets": ["string"],
    "owner": "string",
    "ice_score": {
      "impact": "1-10",
      "confidence": "1-10",
      "effort": "1-10",
      "total": "number"
    }
  }
}
```

### Schema H — Marketing Report Output (Data Analyst → Marketing Auditor)

```json
{
  "envelope": {
    "from_agent": "data-analyst",
    "to_agent": "marketing-auditor",
    "type": "marketing_report"
  },
  "content": {
    "client": "string",
    "period": "string",
    "executive_summary": "string (3-5 líneas)",
    "objective_of_period": "string",
    "main_actions_performed": ["string"],
    "what_happened": "string",
    "what_it_means": "string",
    "channel_analysis": {
      "meta_ads": {
        "result": "string",
        "reading": "string",
        "possible_cause": "string",
        "recommendation": "string"
      },
      "google_ads": { "result": "string", "reading": "string", "possible_cause": "string", "recommendation": "string" },
      "social_content": { "result": "string", "reading": "string", "possible_cause": "string", "recommendation": "string" },
      "email_crm": { "result": "string", "reading": "string", "possible_cause": "string", "recommendation": "string" },
      "website_ecommerce": { "result": "string", "reading": "string", "possible_cause": "string", "recommendation": "string" }
    },
    "main_learnings": ["string"],
    "recommendations": {
      "scale": ["string"],
      "adjust": ["string"],
      "stop": ["string"],
      "test": ["string"]
    },
    "next_month_priorities": ["string"],
    "data_limitations": ["string"]
  }
}
```

---

## 5. ENFORCEMENT — CÓMO SE VALIDA

### Validación automática

El `Orchestrator` valida cada JSON antes de propagar:

```
Si JSON inválido:
  - Rechaza el hand-off.
  - Devuelve error al agente emisor.
  - Pide regenerar con schema correcto.
  - Si falla 3 veces consecutivas, escala al Founder.
```

### Validación de schema

Cada schema vive en `/lumba-core/shared/schemas/{tipo}.schema.json`.

Antes de propagar, el Orchestrator hace `JSON.parse + schema.validate(payload)`.

### Logging

Cada hand-off se loguea en:
```
/proyectos/{nombre}/handoffs/{fecha-hora}-{from}-{to}.json
```

---

## 6. CONFIANZA Y EVIDENCIA

Todo agente que produce output declara su `confidence`:

| Nivel | Cuándo usarlo |
|---|---|
| `alta` | Basado en evidencia primaria o instrucción explícita del humano |
| `media` | Basado en inferencia razonable o evidencia secundaria |
| `baja` | Basado en estimación o hipótesis débil |

**Cualquier output con `confidence: baja` requiere revisión humana antes de propagar.**

---

## 7. SOURCES CONSULTED

Todo output declara las fuentes que consultó:

```json
"sources_consulted": [
  {
    "path": "/proyectos/minuta/MEMORIA-PROYECTO.md",
    "version_hash": "sha256:...",
    "consulted_at": "ISO-8601"
  },
  {
    "url": "https://...",
    "consulted_at": "ISO-8601",
    "source_type": "web"
  }
]
```

Esto permite:
- Trazabilidad total ("¿de dónde salió esta decisión?").
- Detección de outputs basados en memoria desactualizada.
- Auditoría posterior.

---

## 8. LÍMITES DE COMUNICACIÓN

### Loops máximos

Si dos agentes iteran (ej. `product-owner ↔ devils-advocate`), máximo **3 iteraciones**. Después se escala al Founder.

Esto previene el failure mode "circuitous conversations" (MAST).

### Mensaje máximo

Cada JSON tiene tope de **20K tokens** de payload. Si supera, se divide en múltiples mensajes con referencias cruzadas.

### Timeout

Si un agente no responde en **120 segundos**, se considera timeout. El Orchestrator decide si reintentar o escalar.

---

## 9. ANTI-PATTERNS DE COMUNICACIÓN

Cosas que NO hacemos:

- ❌ Hand-off en texto libre / prosa.
- ❌ Agentes hablándose directamente sin Orchestrator.
- ❌ Hand-off sin `version_hash` de fuentes.
- ❌ Aceptar JSON malformado "porque casi está bien".
- ❌ Loops infinitos entre 2 agentes.
- ❌ Output sin declarar `confidence`.
- ❌ Mensajes sin trazabilidad de fuentes.

---

## 10. CHECKLIST DE VALIDACIÓN PARA ESTEBAN

- [ ] Los 6 schemas cubren los casos típicos.
- [ ] El envelope universal es suficiente.
- [ ] La validación automática vía Orchestrator es viable.
- [ ] El sistema de `confidence` es claro.
- [ ] Los límites (loops, timeout, tamaño) son razonables.

---

**FIN COMUNICACIÓN ENTRE AGENTES**
