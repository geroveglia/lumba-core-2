# ESTRUCTURA DE CARPETAS — LUMBA CORE v1.0

> **Versión:** v1.0
> **Propósito:** mapa completo del workspace.
> **Última actualización:** 23 de mayo de 2026.

---

## 1. ESTRUCTURA COMPLETA

```
lumba-core/
│
├── AGENTS.md                          ← Reglas globales (OpenClaw lee al iniciar)
├── README.md                          ← Entrada principal del workspace
├── SOUL.md                            ← Personalidad del Orchestrator
├── MODEL-STRATEGY.md                  ← Estrategia de modelos flash vs pro
├── MANIFIESTO.md                      ← Identidad de Lumba
├── PRINCIPIOS.md                      ← 15 principios + Principio 0
├── METRICAS.md                        ← Cómo medimos éxito
├── openclaw.template.json5             ← Template de configuración OpenClaw
├── .gitignore                         ← Configuración git
│
├── shared/                            ← Compartido entre equipos
│   ├── agentes-universales/
│   │   └── AGENTES-UNIVERSALES.md
│   ├── metodologia/
│   │   ├── PROCESO-8-PASOS.md
│   │   ├── MEMORIA-COMPARTIDA.md
│   │   ├── COMUNICACION-AGENTES.md
│   │   ├── SEGURIDAD.md
│   │   ├── COSTOS.md
│   │   ├── QUALITY-GATES.md
│   │   ├── VALIDACION-HUMANA.md
│   │   ├── WORKFLOW-AUDITORIA.md
│   │   ├── WORKFLOW-BRIEF-OBSESIVO.md
│   │   ├── WORKFLOW-PROPUESTA-COMERCIAL.md
│   │   ├── ORQUESTACION.md
│   │   ├── MATRIZ-SQUADS.md
│   │   ├── ROADMAP-IMPLEMENTACION.md
│   │   └── workflows/                 ← Workflows operativos paso a paso
│   │       └── 00-project-assessment.md
│   ├── schemas/
│   │   ├── project-state-schema.json
│   │   └── README.md
│   ├── infra/
│   │   ├── STACKS.md
│   │   └── DEVOPS-PROTOCOL.md
│   ├── ESTRUCTURA-CARPETAS.md         ← Este archivo
│   ├── RACI-OPERATIVO.md
│   └── FORBIDDEN-REQUIRED-BEHAVIOR.md
│
├── equipos/                           ← Las 3 unidades de negocio
│   │
│   ├── core-brand/
│   │   ├── METODO.md
│   │   ├── agentes/                   ← Definiciones de agentes especializados
│   │   ├── skills/                    ← Skills propias
│   │   └── workflows/                 ← Workflows del equipo
│   │
│   ├── core-marketing/
│   │   ├── METODO.md
│   │   ├── agentes/                   ← Definiciones de agentes especializados
│   │   ├── skills/                    ← Skills propias
│   │   ├── workflows/                 ← Workflows del equipo
│   │   └── playbooks/                 ← Playbooks operativos
│   │       ├── meta-ads-playbook.md
│   │       ├── google-ads-playbook.md
│   │       └── growth-marketing-playbook.md
│   │
│   └── core-product/
│       ├── METODO.md
│       ├── agentes/                   ← Definiciones de agentes especializados
│       ├── skills/                    ← Skills propias
│       └── workflows/                 ← Workflows del equipo
│
├── knowledge/                         ← Base de conocimiento operativo
│   ├── playbooks/                     ← Playbooks generales
│   ├── templates/                     ← Templates reutilizables
│   │   ├── brief-template.md
│   │   ├── brief-branding.md
│   │   ├── brief-marketing.md
│   │   ├── brief-producto.md
│   │   ├── marketing-report-template.md
│   │   ├── growth-experiment-template.md
│   │   ├── adr-template.md
│   │   ├── audit-report-template.md
│   │   ├── client-memory-template.md
│   │   ├── project-memory-template.md
│   │   └── sprint-template.md
│   ├── checklists/                    ← Checklists de auditoría
│   │   └── sistema-completo.md        ← Final audit checklist
│   └── taxonomias/                    ← Taxonomías
│       └── marketing-metrics.md
│
├── proyectos/                         ← Proyectos activos
│   └── {nombre}/                      ← Creado por Workflow 00 (Project Assessment)
│       ├── state.json                 ← Estado del proyecto (máquina de estados)
│       ├── MEMORIA-PROYECTO.md        ← Memoria del proyecto
│       ├── outputs/                   ← Outputs de cada fase
│       ├── approvals/                 ← Registros de aprobación humana
│       ├── handoffs/                  ← JSON entre agentes
│       ├── overrides/                 ← Overrides del Devil's Advocate
│       ├── drafts/                    ← Propuestas de cambio a memoria
│       └── migrations/                ← SQL migrations (si aplica)
│
├── clientes/                          ← Memoria por cliente
│   ├── rus/
│   │   ├── MEMORIA-CLIENTE.md
│   │   ├── branding/
│   │   ├── marketing/
│   │   └── producto/
│   ├── bewell/
│   ├── cancat/
│   ├── profecia/
│   ├── multidiagnostico/
│   ├── dicomere/
│   └── jom/
│
├── outputs/                           ← Salidas generadas por agentes (global)
│   ├── reports/
│   ├── briefs/
│   ├── audits/
│   └── ... (por tipo y fecha)
│
└── memory/                            ← Memoria del sistema
```

---

## 2. CONVENCIONES DE NOMBRES

### Archivos markdown

- **Mayúsculas con guiones para documentos institucionales:** `MANIFIESTO.md`, `PRINCIPIOS.md`.
- **kebab-case para documentos operativos:** `marketing-report-template.md`, `meta-ads-playbook.md`.
- **Snake_case para definiciones técnicas en YAML:** `frontmatter`.

### Carpetas

- **Minúscula:** `equipos/`, `clientes/`, `proyectos/`.
- **kebab-case si tiene múltiples palabras:** `core-brand/`, `core-marketing/`, `agentes-universales/`.

### Agentes

- **kebab-case:** `meta-ads-analyst`, `brand-strategist`, `code-reviewer`.

### Skills

- **kebab-case en subcarpeta con SKILL.md adentro:** `brand-diagnostic/SKILL.md`.

---

## 3. CARPETAS QUE SE CREAN AL VUELO

Las siguientes carpetas se crean cuando aparece su contenido, no antes:

- `proyectos/{nombre}/` — al iniciar un proyecto nuevo.
- `clientes/{nombre}/` — al onboardear un cliente nuevo.
- `outputs/{tipo}/{fecha}/` — al generar un output.

---

## 4. ARCHIVOS QUE SIEMPRE EXISTEN

Estos archivos NO se pueden eliminar:

- `AGENTS.md`
- `README.md`
- `MANIFIESTO.md`
- `PRINCIPIOS.md`
- `METRICAS.md`
- `SOUL.md`
- `MODEL-STRATEGY.md`
- `.gitignore`
- Cualquier archivo en `shared/metodologia/`.
- Cualquier archivo en `shared/agentes-universales/`.
- Cualquier archivo en `shared/schemas/`.

---

## 5. PERMISOS POR CARPETA

| Carpeta | Lectura | Escritura |
|---|---|---|
| Raíz (AGENTS.md, etc.) | Todos | Solo Founder |
| `shared/` | Todos | Solo Founder |
| `shared/metodologia/workflows/` | Todos | Founder + Vertical Leads |
| `equipos/*/METODO.md` | Todos | Vertical Lead + Founder |
| `equipos/*/agentes/` | Todos | Solo Founder |
| `equipos/*/skills/` | Todos | Vertical Lead + Founder |
| `equipos/*/workflows/` | Todos | Vertical Lead + Founder |
| `equipos/*/playbooks/` | Todos | Vertical Lead + Founder |
| `knowledge/` | Todos | Founder + delegados |
| `proyectos/{nombre}/` | Equipo del proyecto | Equipo del proyecto |
| `clientes/{nombre}/` | Equipo del cliente | PM + Vertical Leads |
| `outputs/` | Todos | Agentes (con scoped paths) |

---

## 6. .GITIGNORE RECOMENDADO

```
# Dependencies
node_modules/
.pnp
.pnp.js

# Testing
coverage/

# Production builds
build/
dist/
.next/
out/

# Environment
.env
.env*.local

# Logs
npm-debug.log*
yarn-debug.log*
*.log

# Editor
.vscode/
.idea/
*.swp
*.swo
.DS_Store

# Vercel
.vercel

# TypeScript
*.tsbuildinfo
next-env.d.ts

# Claude Code cache
.claude/cache/
.claude/logs/

# Supabase
.supabase/

# Secrets
*.pem
*.key
secrets.json

# Outputs efímeros (mantener carpeta pero no contenido transitorio)
outputs/ephemeral/

# Backups locales
*.backup
```

---

**FIN ESTRUCTURA DE CARPETAS**
