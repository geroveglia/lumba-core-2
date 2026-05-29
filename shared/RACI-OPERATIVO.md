# RACI OPERATIVO — LUMBA CORE v1.0

> **Versión:** v1.0
> **Tono:** Manual operativo.
> **Propósito:** definir Responsibility / Accountability / Consulted / Informed por actividad.
> **Última actualización:** 23 de mayo de 2026.

---

## 1. QUÉ ES RACI

- **R — Responsible:** quien hace el trabajo.
- **A — Accountable:** quien responde por el resultado (uno solo).
- **C — Consulted:** quien aporta input antes de la decisión.
- **I — Informed:** quien recibe info después de la decisión.

---

## 2. ACTORES EN LUMBA CORE

### Humanos

| Actor | Rol |
|---|---|
| **Esteban** | Founder operativo (responsable de día a día) |
| **Hernán** | Founder visión (estratégico) |
| **Martín** | Founder comercial |
| **PM** | Project Manager del proyecto |
| **Vertical Lead** | Líder humano del equipo (Brand/Marketing/Product) |
| **Especialista** | Miembro del equipo (diseñador, copy, dev, etc.) |
| **Cliente** | Cliente externo |

### Agentes

| Actor | Rol |
|---|---|
| **Orchestrator** | Coordina y enruta tareas |
| **Vertical Lead Agent** | Estratega del equipo (brand-strategist, marketing-strategist, business-strategist) |
| **Especialistas Agent** | Agentes especializados del equipo |
| **Devil's Advocate** | Cuestiona decisiones críticas |
| **Auditor** | Audita entregables (brand-auditor, marketing-auditor, product-auditor) |
| **Scope Agent** | Vigila alcance |
| **Client Translator** | Traduce comunicación cliente↔equipo |
| **Research Agent** | Investiga mercado y evidencia |
| **PM Agent** | Project Manager agente |

---

## 3. MATRIZ RACI POR ACTIVIDAD

### Intake de proyecto nuevo

| Actividad | R | A | C | I |
|---|---|---|---|---|
| Recibir briefing inicial del cliente | PM + Client Translator | PM | Vertical Lead | Equipo del proyecto |
| Validar viabilidad técnica/comercial | Vertical Lead + Scope Agent | Martín (comercial) | Esteban | Hernán |
| Setup de workspace del proyecto | PM Agent | PM | — | Equipo |
| Crear MEMORIA-CLIENTE inicial | PM + Vertical Lead | PM | Esteban | Equipo |

---

### Definición estratégica

| Actividad | R | A | C | I |
|---|---|---|---|---|
| Investigación inicial | Research Agent | Vertical Lead | Especialistas | PM |
| Propuesta estratégica | Vertical Lead Agent | Vertical Lead (humano) | Especialistas + Devil's Advocate | PM, Cliente |
| Validación con cliente | PM + Vertical Lead | Vertical Lead | Cliente | Equipo |
| Cierre estratégico | Vertical Lead | Esteban | Devil's Advocate | Hernán + Martín si es mayor |

---

### Producción de entregables

| Actividad | R | A | C | I |
|---|---|---|---|---|
| Brief obsesivo | Especialistas + agentes | Vertical Lead | PM | Cliente cuando aplica |
| Producción del entregable | Especialistas + agentes | Vertical Lead | — | PM |
| Auto-check del agente | Agente productor | Agente productor | — | Auditor |
| Auditoría AI | Auditor (agente) | Vertical Lead | Devil's Advocate si crítico | PM |
| Revisión humana | PM o Vertical Lead | PM o Vertical Lead | Especialistas | Cliente |

---

### Entrega al cliente

| Actividad | R | A | C | I |
|---|---|---|---|---|
| Preparar comunicación al cliente | Client Translator + PM | PM | Vertical Lead | Equipo |
| Aprobación pre-entrega | PM | Vertical Lead | Devil's Advocate | Esteban si crítico |
| Envío al cliente | PM (humano) | PM | Client Translator | Equipo |
| Tracking de feedback | PM Agent | PM | Cliente | Equipo |

---

### Cambio de alcance

| Actividad | R | A | C | I |
|---|---|---|---|---|
| Detectar cambio de alcance | Scope Agent o equipo | PM | Vertical Lead | Esteban |
| Análisis de impacto | Scope Agent + Vertical Lead | PM | Especialistas | Martín |
| Comunicación al cliente | PM + Client Translator | PM | Martín | Cliente |
| Negociación comercial | Martín | Martín | Esteban | PM |
| Acuerdo escrito | Martín | Martín | Cliente | Equipo |
| Update de scope en workspace | PM Agent | PM | Esteban | Equipo |

---

### Deploy a producción (Core-Product)

| Actividad | R | A | C | I |
|---|---|---|---|---|
| Pre-deploy check | QA Agent + DevOps Agent | Tech Lead | Backend Architect | PM |
| Plan de rollback | DevOps Agent | Tech Lead | Backend Architect | Esteban |
| Aprobación de deploy | Tech Lead | Tech Lead | Esteban | Cliente |
| Ejecución de deploy | DevOps Agent + DevOps humano | DevOps humano | Tech Lead | Equipo |
| Monitoreo post-deploy | DevOps Agent | DevOps humano | QA | PM + Cliente |

---

### Campaña de marketing

| Actividad | R | A | C | I |
|---|---|---|---|---|
| Brief de campaña | Marketing Strategist Agent + PM | Marketing Strategist (humano) | Cliente | Equipo |
| Estructura de cuenta | Meta/Google Ads Analyst Agent | Marketing Strategist | — | PM |
| Creativos | Copywriter + UI Designer | Vertical Lead Marketing | Marketing Strategist | PM |
| Pre-launch check | Marketing Auditor Agent | Marketing Strategist | Devil's Advocate si presupuesto alto | PM |
| Aprobación de lanzamiento | Marketing Strategist (humano) | Martín si presupuesto >USD 1000 | Cliente | Equipo |
| Lanzamiento | Performance Specialist (humano) | Performance Specialist | — | PM |
| Optimización continua | Performance Specialist + Agent | Marketing Strategist | Data Analyst | PM |
| Reporte | Data Analyst Agent | Marketing Strategist | Marketing Auditor | Cliente |

---

### Reporte mensual

| Actividad | R | A | C | I |
|---|---|---|---|---|
| Recolección de data | Data Analyst Agent | Data Analyst | Performance Specialists | PM |
| Análisis e interpretación | Data Analyst Agent | Data Analyst | Marketing Strategist | PM |
| Auditoría de reporte | Marketing Auditor Agent | Marketing Strategist | — | PM |
| Validación humana | Marketing Strategist | Marketing Strategist | PM | Cliente |
| Presentación al cliente | PM | PM | Marketing Strategist | Equipo |

---

### Modificación de Lumba Core

| Actividad | R | A | C | I |
|---|---|---|---|---|
| Proponer cambio | Cualquiera | Esteban | Devil's Advocate + socios | Equipo |
| Auditoría del cambio | Devil's Advocate | Esteban | Vertical Leads | Hernán + Martín |
| Aprobación | Esteban | Esteban (+ Hernán/Martín si mayor) | Devil's Advocate | Equipo |
| Implementación | Esteban + agentes técnicos | Esteban | — | Equipo |
| Comunicación interna | Esteban | Esteban | PM | Equipo |

---

## 4. REGLAS GENERALES

### Solo un Accountable por actividad

Si hay dos personas "responsables finales" es porque nadie lo es.

### El Accountable puede delegar el Responsible

Pero la responsabilidad última no se delega.

### Consulted ≠ Aprobador

Consulted opina antes de la decisión. No la toma.

### Informed siempre incluye al PM y al equipo del proyecto

Aunque no esté listado explícitamente.

---

## 5. CASOS ESPECIALES

### El Founder (Esteban) puede sobrescribir cualquier RACI

Pero queda registrado como **decisión consciente** en `/lumba-core/overrides/`.

### Devil's Advocate tiene poder de bloqueo

No es Accountable, pero puede bloquear avance.

### Si el cliente toma decisión que el equipo no aprueba

- Se registra el desacuerdo.
- Se implementa la decisión del cliente.
- Se documenta para post-mortem.

---

## 6. CHECKLIST DE VALIDACIÓN

- [ ] Cada actividad tiene un único Accountable.
- [ ] La matriz cubre los procesos críticos.
- [ ] Los humanos saben dónde son R y dónde son A.
- [ ] Los agentes nunca son A por sí solos (siempre humano arriba).
- [ ] Las inferencias y excepciones están claras.

---

**FIN DEL RACI OPERATIVO**
