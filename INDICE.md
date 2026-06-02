# 📑 LUMBA CORE — Índice Completo de Contenidos

> Mapa de navegación de todo el repositorio. Cada archivo con su descripción.

---

## 📂 RAÍZ — Documentos Fundamentales

| Archivo | Contenido |
|---|---|
| `README.md` | 🚀 Puerta de entrada: qué es Lumba Core, instalación, arquitectura, estructura |
| `MANIFIESTO.md` | Identidad de Lumba: qué es, por qué existe, qué cree, cómo trabaja, visión a 3 años |
| `PRINCIPIOS.md` | 15 principios operativos del sistema + checklist de comportamiento (NUNCA/SIEMPRE) |
| `AGENTS.md` | Reglas globales de los agentes, validación humana obligatoria, flujo universal |
| `SOUL.md` | Personalidad del Orchestrator (Jarvis ⚡) — modelos, modo de operación, reglas |
| `MODEL-STRATEGY.md` | Estrategia Flash 70% / Pro 25% / Opus 5%. Opus para DB Design. Pro+thinking para System Auditor |
| `METRICAS.md` | Cómo medimos el éxito — KPI north: % entregas sin corrección posterior |
| `IDENTITY.md` | Identidad puntual: nombre, avatar, emoji, vibe |
| `USER.md` | Perfil del humano (Founder) |
| `TOOLS.md` | Notas locales de herramientas y configuración |
| `HEARTBEAT.md` | Configuración de chequeos periódicos del sistema |
| `.gitignore` | Protege secrets, outputs, datos de clientes |
| `setup.bat` | Instalador 1-click para Windows |
| `setup.sh` | Instalador 1-click para macOS/Linux |

---

## 📂 docs/ — Documentación Visual

| Archivo | Contenido |
|---|---|
| `lumba-agentes-skills.html` | 🌐 Doc interactiva con 5 pestañas:<br>🔄 **Cómo Funciona** — Pipeline 8 pasos, selección de agentes por complejidad, flujo de modelos, fórmula de costos<br>🤖 **Red de Agentes** — 3 equipos + universales con tooltips, skills, leyenda de modelos<br>💰 **Costos** — Tablas por tipo de proyecto + budget mensual<br>📋 **Workflows** — 6 workflows operativos detallados<br>⚙️ **Guía de Uso** — Cómo correr OpenClaw, decisiones, cuándo pregunta vs ejecuta, simulador interactivo de proyectos |

---

## 📂 shared/ — Compartido entre Equipos

### shared/metodologia/ — Procesos Transversales

| Archivo | Contenido |
|---|---|
| `PROCESO-8-PASOS.md` | Pipeline inviolable: Investigar → Pensar → Cuestionar → Validar → Construir → Testear → Mejorar → Lanzar |
| `ORQUESTACION.md` 🆕 | Cómo Jarvis orquesta agentes en OpenClaw: spawn, handoffs, TaskFlow, human-in-the-loop |
| `WORKFLOW-PROPUESTA-COMERCIAL.md` 🆕 | Propuesta económica: pricing, fases, timeline. Cliente firma antes de arrancar |
| `WORKFLOW-AUDITORIA.md` | Proceso de auditoría obligatoria pre-entrega |
| `WORKFLOW-BRIEF-OBSESIVO.md` | Metodología de brief completo antes de producir |
| `COMUNICACION-AGENTES.md` | Protocolo de handoff entre agentes (JSON Schema) |
| `COSTOS.md` | Modelo de costos, límites, presupuesto por proyecto |
| `MEMORIA-COMPARTIDA.md` | Sistema de memoria por cliente y proyecto |
| `QUALITY-GATES.md` | Puntos de control de calidad en el pipeline |
| `SEGURIDAD.md` | Políticas de seguridad, NDA, datos sensibles |
| `VALIDACION-HUMANA.md` | Checklist de cuándo se requiere aprobación humana |
| `ROADMAP-IMPLEMENTACION.md` | Plan de implementación futura del sistema |

### shared/agentes-universales/

| Archivo | Contenido |
|---|---|
| `AGENTES-UNIVERSALES.md` | Definición de los 5 agentes universales: Orchestrator, Devil's Advocate, Project Manager, Research Agent, Scope Agent, Client Translator |

### shared/infra/ — Infraestructura Técnica

| Archivo | Contenido |
|---|---|
| `STACKS.md` | Definición de stacks tecnológicos (Stack A, B, etc.) |
| `CODING-STANDARDS.md` | Estándares de código para toda la agencia |
| `stack-a-config/` | Config base para Stack A:<br>`.editorconfig` · `.prettierrc.json` · `eslint.config.js` · `tsconfig.json` · `CONVENTIONS.md` · `.husky/pre-commit` |

### shared/schemas/

| Archivo | Contenido |
|---|---|
| `README.md` | Documentación de JSON Schemas para handoff entre agentes |
| `project-state-schema.json` 🆕 | Schema del state.json del proyecto: fases, gates, approvals, budget |

### shared/ — Otros

| Archivo | Contenido |
|---|---|
| `ESTRUCTURA-CARPETAS.md` | Explicación de la estructura de directorios del workspace |
| `FORBIDDEN-REQUIRED-BEHAVIOR.md` | Reglas NUNCA/SIEMPRE para agentes |
| `RACI-OPERATIVO.md` | Matriz RACI: quién es Responsable, Aprueba, Consultado, Informado |

---

## 📂 equipos/core-brand/ — Red de Branding

### Agentes (8)

| Archivo | Agente | Rol |
|---|---|---|
| `brand-strategist.md` | 🧠 Brand Strategist | Estrategia de marca, posicionamiento, naming |
| `brand-auditor.md` | 🎯 Brand Auditor | Auditoría obligatoria de entregables de branding |
| `brandbook-builder.md` | 📋 Brandbook Builder | Construcción de brandbooks y guías |
| `brand-differentiator.md` | 🔍 Brand Differentiator | Diferenciación competitiva de marca |
| `brand-researcher.md` | 🔬 Brand Researcher | Investigación de mercado y competencia |
| `brand-voice-writer.md` | ✍️ Brand Voice Writer | Redacción de tono de voz |
| `identity-designer.md` | 🎨 Identity Designer | Diseño de identidad visual |
| `visual-director.md` | 👁️ Visual Director | Dirección de arte y sistema visual |

### Skills (9)

| Archivo | Skill |
|---|---|
| `benchmark-framework.md` | Framework de benchmarking competitivo |
| `brand-audit-checklist.md` | Checklist de auditoría de marca |
| `brand-diagnostic.md` | Diagnóstico de marca |
| `brandbook-template.md` | Template de brandbook |
| `naming-method.md` | Metodología de naming |
| `positioning-canvas.md` | Canvas de posicionamiento |
| `tone-of-voice-builder.md` | Constructor de tono de voz |
| `visual-system-design.md` | Diseño de sistema visual |
| `workshop-facilitator.md` | Facilitación de workshops |

### Workflows (6)

| Archivo | Workflow |
|---|---|
| `01-diagnostico-marca.md` | Diagnóstico inicial de marca |
| `02-workshop-estrategico.md` | Workshop estratégico de marca |
| `03-identidad-visual.md` | Creación de identidad visual |
| `04-manual-marca.md` | Manual de marca completo |
| `05-brand-differentiation-audit.md` | Auditoría de diferenciación |
| `06-visual-identity-review.md` | Revisión de identidad visual |

### Otros

| Archivo | Contenido |
|---|---|
| `METODO.md` | Método de trabajo del equipo Core-Brand |

---

## 📂 equipos/core-marketing/ — Red de Marketing

### Agentes (12)

| Archivo | Agente | Rol |
|---|---|---|
| `marketing-strategist.md` | 📊 Marketing Strategist | Estrategia de marketing, canales, funnel |
| `marketing-auditor.md` | 🎯 Marketing Auditor | Auditoría de campañas y copy |
| `campaign-orchestrator.md` | 📈 Campaign Orchestrator | Coordinación de campañas multi-canal |
| `content-strategist.md` | 📝 Content Strategist | Estrategia de contenido |
| `copywriter.md` | ✍️ Copywriter | Redacción publicitaria |
| `data-analyst.md` | 📊 Data Analyst | Análisis de datos de campaña |
| `ecommerce-manager.md` | 🛒 Ecommerce Manager | Gestión de ecommerce |
| `email-specialist.md` | 📧 Email Specialist | Email marketing |
| `google-ads-analyst.md` | 🔍 Google Ads Analyst | Análisis y optimización de Google Ads |
| `growth-marketing-specialist.md` | 📈 Growth Specialist | Growth marketing |
| `meta-ads-analyst.md` | 🔍 Meta Ads Analyst | Análisis y optimización de Meta Ads |
| `scriptwriter.md` | 🎬 Scriptwriter | Guiones para contenido/ads |

### Skills (14)

| Archivo | Skill |
|---|---|
| `attribution-model.md` | Modelo de atribución de conversiones |
| `audience-builder.md` | Constructor de audiencias |
| `content-pillars.md` | Definición de pilares de contenido |
| `creative-testing-framework.md` | Framework de testing creativo |
| `email-architecture.md` | Arquitectura de email marketing |
| `google-ads-audit.md` | Auditoría de Google Ads |
| `google-ads-structure.md` | Estructura de campañas Google Ads |
| `growth-marketing-analysis.md` | Análisis de growth marketing |
| `marketing-audit-checklist.md` | Checklist de auditoría de marketing |
| `marketing-diagnostic.md` | Diagnóstico de marketing |
| `marketing-reporting.md` | Reporting de marketing |
| `meta-ads-audit.md` | Auditoría de Meta Ads |
| `meta-ads-structure.md` | Estructura de campañas Meta Ads |
| `report-with-insights.md` | Reportes con insights accionables |

### Workflows (8)

| Archivo | Workflow |
|---|---|
| `01-plan-marketing-inicial.md` | Plan de marketing inicial |
| `02-campania-meta-ads.md` | Campaña de Meta Ads |
| `03-campania-google-ads.md` | Campaña de Google Ads |
| `04-email-marketing-comercial.md` | Email marketing comercial |
| `05-calendario-contenido-mensual.md` | Calendario de contenido mensual |
| `06-reporte-mensual-insights.md` | Reporte mensual con insights |
| `07-growth-reporting-sprint.md` | Sprint de growth reporting |
| `08-meta-google-ads-audit.md` | Auditoría combinada Meta + Google Ads |

### Playbooks (3)

| Archivo | Playbook |
|---|---|
| `google-ads-playbook.md` | Playbook operativo Google Ads |
| `growth-marketing-playbook.md` | Playbook de growth marketing |
| `meta-ads-playbook.md` | Playbook operativo Meta Ads |

### Otros

| Archivo | Contenido |
|---|---|
| `METODO.md` | Método de trabajo del equipo Core-Marketing |

---

## 📂 equipos/core-product/ — Red de Producto Digital

### Agentes (20)

| Archivo | Agente | Rol |
|---|---|---|
| `system-auditor.md` 🆕 | 🔍 System Auditor | Auditoría de repos heredados, deuda técnica, gap analysis (Tipo B) |
| `documentation-agent.md` | 📚 Documentation Agent | Documentación en paralelo durante BUILD |
| `product-owner.md` | 📋 Product Owner | Roadmap, backlog, priorización |
| `analyst-functional.md` | 📝 Analyst Functional | Especificación funcional, criterios de aceptación |
| `ux-designer.md` | 🎨 UX Designer | Flujos de usuario, wireframes, prototipos |
| `ui-designer.md` | 🖌️ UI Designer | Sistema de diseño, componentes, responsive |
| `frontend-architect.md` | 🏗️ Frontend Architect | Arquitectura frontend (Vite + React + TS + Tailwind) |
| `backend-architect.md` | ⚙️ Backend Architect | APIs REST, auth, integraciones |
| `data-architect.md` | ⚡🗄️ Data Architect (Opus) | PRIMER agente. Modelo de datos fundacional antes que todo |
| `code-reviewer.md` | 🔍 Code Reviewer | Guardián de calidad pre-merge |
| `code-quality-agent.md` | ✅ Code Quality Agent | Métricas de calidad de código |
| `qa-engineer.md` | 🧪 QA Engineer | Planes de testing, edge cases |
| `devops-engineer.md` | 🚀 DevOps Engineer | Deploy, CI/CD, monitoring |
| `security-agent.md` | 🔒 Security Agent | OWASP, vulnerabilidades, secretos |
| `product-auditor.md` | 🎯 Product Auditor | Auditoría pre-entrega de specs y UX/UI |
| `business-strategist.md` | 💼 Business Strategist | Viabilidad y estrategia de negocio |
| `client-onboarding-agent.md` | 🗣️ Client Onboarding | Onboarding de clientes nuevos |
| `prompt-engineer.md` | 🔧 Prompt Engineer | Optimización de prompts de agentes |
| `retrospective-agent.md` | 🔄 Retrospective Agent | Retrospectivas post-proyecto |

### Skills (10)

| Archivo | Skill |
|---|---|
| `adr-generator.md` | Architecture Decision Records |
| `code-review-checklist.md` | Checklist de code review |
| `data-modeling.md` | Modelado de datos |
| `deployment-checklist.md` | Checklist de deploy |
| `discovery-framework.md` | Framework de discovery |
| `functional-specification.md` | Especificación funcional |
| `product-audit-checklist.md` | Checklist de auditoría de producto |
| `qa-test-plan.md` | Plan de testing QA |
| `user-story-format.md` | Formato de user stories |
| `ux-flow-design.md` | Diseño de flujos UX |

### Workflows (10)

| Archivo | Workflow |
|---|---|
| 🔍 `00-project-assessment.md` 🆕 | **Project Assessment & Triaje** — clasifica A/B/C, instancia templates, System Auditor |
| `01-discovery-y-funcional.md` | Discovery + definición funcional — reglas de negocio cerradas antes de todo |
| 🏗️ `02-tech-stack-decision.md` | **Tech Stack Decision** — Gero elige, agentes validan. ANTES de DB Design |
| ⚡ `03-diseno-base-datos.md` | **Diseño de base de datos** — SOLO después de Discovery cerrado Y Tech Stack definido (Opus) |
| 🚀 `03.5-bootstrap-scaffolding.md` 🆕 | **Bootstrap Scaffolding** — Tipo A: estructura y config automática |
| `04-diseno-ux-ui.md` | Diseño UX/UI completo |
| `05-desarrollo-feature.md` | Desarrollo de feature |
| `06-bug-critico.md` | Bug crítico en producción |
| `07-soporte-evolutivo.md` | Soporte evolutivo |
| 🚀 `08-post-launch.md` | **Post-Launch (Semana 1)** — monitoreo, métricas, hotfixes |

### Otros

| Archivo | Contenido |
|---|---|
| `METODO.md` | Método de trabajo del equipo Core-Product |

---

## 📂 knowledge/ — Base de Conocimiento

### Templates (10)

| Archivo | Template |
|---|---|
| `brief-template.md` | Brief genérico |
| `brief-branding.md` | Brief de branding |
| `brief-marketing.md` | Brief de marketing |
| `brief-producto.md` | Brief de producto |
| `client-memory-template.md` | Memoria de cliente |
| `project-memory-template.md` | Memoria de proyecto |
| `adr-template.md` | Architecture Decision Record |
| `audit-report-template.md` | Reporte de auditoría |
| `sprint-template.md` | Sprint template |
| `growth-experiment-template.md` | Experimento de growth |
| `marketing-report-template.md` | Reporte de marketing |

### Checklists (2)

| Archivo | Checklist |
|---|---|
| `sistema-completo.md` | Checklist del sistema completo |
| `frontend-borrador.md` | Checklist de frontend en borrador |

---

## 📊 RESUMEN NUMÉRICO

| Categoría | Cantidad |
|---|---|
| Documentos raíz | 13 |
| Docs visuales | 1 (HTML con 5 pestañas) |
| Docs de metodología | 11 |
| Agentes definidos | 43 |
| Skills | 33 |
| Workflows | 24 |
| Playbooks | 3 |
| Templates | 11 |
| Checklists | 2 |
| Stack configs | 7 |
| Schemas | 1 (con guía) |
| **TOTAL archivos** | **161** |

---

## 🎯 TEMAS CLAVE POR ARCHIVO

### Si buscás...

| Tema | Archivos relevantes |
|---|---|
| **Filosofía Lumba** | `MANIFIESTO.md`, `PRINCIPIOS.md` |
| **Reglas de agentes** | `AGENTS.md`, `FORBIDDEN-REQUIRED-BEHAVIOR.md` |
| **Proceso de trabajo** | `PROCESO-8-PASOS.md`, `QUALITY-GATES.md` |
| **Auditoría** | `WORKFLOW-AUDITORIA.md`, `product-audit-checklist.md`, `brand-audit-checklist.md`, `marketing-audit-checklist.md` |
| **Costos** | `COSTOS.md`, `MODEL-STRATEGY.md` |
| **Briefing** | `WORKFLOW-BRIEF-OBSESIVO.md`, `brief-*.md` (4 templates) |
| **Validación humana** | `VALIDACION-HUMANA.md`, `AGENTS.md` (sección específica) |
| **Memoria** | `MEMORIA-COMPARTIDA.md`, `client-memory-template.md`, `project-memory-template.md` |
| ⚡ **Diseño de base de datos** | `03-diseno-base-datos.md`, `data-architect.md`, `data-modeling.md` |
| **Stack técnico** | `STACKS.md`, `CODING-STANDARDS.md`, `stack-a-config/` |
| **Comunicación agentes** | `COMUNICACION-AGENTES.md`, `schemas/README.md` |
| **Setup** | `README.md`, `setup.bat`, `setup.sh` |
| **Orquestación OpenClaw** | `ORQUESTACION.md`, `project-state-schema.json` |
| **Doc visual** | `docs/lumba-agentes-skills.html` |

---

**Lumba Core v1.0** · ⚡
