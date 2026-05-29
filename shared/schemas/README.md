# JSON SCHEMAS — Lumba Core (OpenClaw)

> Schemas de handoff entre agentes. Adaptados de Claude Code a OpenClaw.

---

## Schema Base — Envelope Universal

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

## Schemas específicos

### A — Feature Specification (Product Owner → UX Designer)
### B — UX Output (UX → UI Designer / Frontend)
### C — Architecture Decision Record (Backend Architect → Founder)
### D — Audit Report (Devil's Advocate → Orchestrator)
### E — Deliverable Ready for Client (Agent → Auditor → Founder)
### F — Research Output (Research Agent → Orchestrator)
### G — Growth Experiment (Growth → Orchestrator)
### H — Marketing Report (Data Analyst → Marketing Auditor)

Ver `shared/metodologia/COMUNICACION-AGENTES.md` para schemas completos.
