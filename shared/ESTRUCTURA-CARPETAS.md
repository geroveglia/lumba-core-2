# ESTRUCTURA DE CARPETAS — LUMBA CORE v1.0

> **Versión:** v1.0
> **Propósito:** mapa completo del workspace.
> **Última actualización:** 23 de mayo de 2026.

---

## 1. ESTRUCTURA COMPLETA

```
lumba-core/
│
├── CLAUDE.md                          ← Reglas globales (Claude Code lee al iniciar)
├── README.md                          ← Entrada principal del workspace
├── MANIFIESTO.md                      ← Identidad de Lumba
├── PRINCIPIOS.md                      ← 15 principios + Principio 0
├── METRICAS.md                        ← Cómo medimos éxito
├── .gitignore                         ← Configuración git
│
├── .claude/                           ← Configuración técnica de Claude Code
│   ├── agents/                        ← Definiciones YAML de agentes implementables
│   │   ├── orchestrator.md
│   │   ├── project-manager.md
│   │   ├── devils-advocate.md
│   │   ├── research-agent.md
│   │   ├── scope-agent.md
│   │   ├── client-translator.md
│   │   └── ... (agentes específicos por equipo)
│   ├── skills/                        ← Skills reusables
│   │   └── ... (subcarpetas por skill)
│   ├── workflows/                     ← Workflows operativos
│   ├── commands/                      ← Slash commands
│   │   ├── challenge.md
│   │   ├── brief.md
│   │   ├── research.md
│   │   ├── audit-meta-ads.md
│   │   ├── audit-google-ads.md
│   │   ├── audit-marketing-report.md
│   │   ├── audit-brand.md
│   │   ├── audit-product.md
│   │   ├── review-scope.md
│   │   └── new-project.md
│   ├── hooks/                         ← Hooks de seguridad
│   │   ├── pre-commit.json
│   │   ├── pre-deploy.json
│   │   ├── post-handoff.json
│   │   └── README.md
│   └── rules/                         ← Reglas adicionales
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
│   │   └── ROADMAP-IMPLEMENTACION.md
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
│   │   ├── agentes/                   ← 8 agentes especializados
│   │   ├── skills/                    ← Skills propias
│   │   └── workflows/                 ← 6 workflows
│   │
│   ├── core-marketing/
│   │   ├── METODO.md
│   │   ├── agentes/                   ← 12 agentes especializados
│   │   ├── skills/                    ← Skills propias
│   │   ├── workflows/                 ← 8 workflows
│   │   └── playbooks/                 ← Playbooks operativos
│   │       ├── meta-ads-playbook.md
│   │       ├── google-ads-playbook.md
│   │       └── growth-marketing-playbook.md
│   │
│   └── core-product/
│       ├── METODO.md
│       ├── agentes/                   ← 12 agentes especializados
│       ├── skills/                    ← Skills propias
│       └── workflows/                 ← 5 workflows
│
├── knowledge/                         ← Base de conocimiento operativo
│   ├── playbooks/                     ← Playbooks generales
│   ├── templates/                     ← 11 templates reutilizables
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
│   └── minuta/                        ← Primer caso de uso real
│       ├── CLAUDE.md
│       ├── README.md
│       ├── docs/
│       │   ├── MEMORIA-PROYECTO.md
│       │   ├── BUSINESS-VALIDATION.md
│       │   ├── biblia/
│       │   ├── funcional/
│       │   ├── sprints/
│       │   ├── decisiones/
│       │   ├── handoffs/
│       │   └── audits/
│       └── .claude/
│           ├── agents/
│           └── skills/
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
├── outputs/                           ← Salidas generadas por agentes
│   ├── reports/
│   ├── briefs/
│   ├── audits/
│   └── ... (por tipo y fecha)
│
└── academia/                          ← Centro educativo (se completa en Sesión 3)
    ├── README.md
    ├── onboarding/
    │   ├── 00-bienvenida.md
    │   ├── 01-que-es-lumba-core.md
    │   ├── 02-principios-basicos.md
    │   ├── 03-mi-primer-dia.md
    │   └── por-rol/
    ├── tutoriales/
    ├── workflows-paso-a-paso/
    ├── troubleshooting/
    ├── ejemplos/
    └── certificacion/
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

- `CLAUDE.md`
- `README.md`
- `MANIFIESTO.md`
- `PRINCIPIOS.md`
- `METRICAS.md`
- `.gitignore`
- Cualquier archivo en `shared/metodologia/`.
- Cualquier archivo en `shared/agentes-universales/`.

---

## 5. PERMISOS POR CARPETA

| Carpeta | Lectura | Escritura |
|---|---|---|
| Raíz (CLAUDE.md, etc.) | Todos | Solo Founder |
| `shared/` | Todos | Solo Founder |
| `.claude/agents/` | Todos | Solo Founder |
| `.claude/skills/` | Todos | Solo Founder |
| `.claude/commands/` | Todos | Solo Founder |
| `equipos/*/METODO.md` | Todos | Vertical Lead + Founder |
| `equipos/*/agentes/` | Todos | Solo Founder |
| `equipos/*/skills/` | Todos | Vertical Lead + Founder |
| `equipos/*/workflows/` | Todos | Vertical Lead + Founder |
| `equipos/*/playbooks/` | Todos | Vertical Lead + Founder |
| `knowledge/` | Todos | Founder + delegados |
| `proyectos/{nombre}/` | Equipo del proyecto | Equipo del proyecto |
| `clientes/{nombre}/` | Equipo del cliente | PM + Vertical Leads |
| `outputs/` | Todos | Agentes (con scoped paths) |
| `academia/` | Todos | Founder + delegados |

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
