# ⚡ Lumba Core

**Sistema de Agentes AI interno de Lumba.**

Lumba Core es una red de agentes especializados que trabajan junto al equipo humano para auditar, investigar, diseñar, construir y lanzar — sin reemplazar el criterio, sino amplificándolo.

---

## 🎯 ¿Qué hace Lumba Core?

| No es | Es |
|---|---|
| ❌ Un chatbot | ✅ Infraestructura de criterio |
| ❌ Un reemplazo del equipo | ✅ Una capa de auditoría antes del cliente |
| ❌ Producción masiva barata | ✅ Calidad distribuida en cada agente |

**Objetivo:** Reducir la corrección posterior al mínimo. Que lo que llega al cliente ya pasó por auditoría, Devil's Advocate, QA y validación humana.

---

## 🧠 Arquitectura

```
PEDIDO → Orchestrator (Jarvis⚡) → Workflow → Squad de agentes → Auditoría
  → Validación Humana → Entrega → Aprendizaje → MEMORIA
```

### 3 Redes de Agentes

| Red | Color | Especialidad | Agentes |
|---|---|---|---|
| 🎨 **Core-Brand** | #E91E63 | Estrategia de marca, naming, identidad visual, brandbook | 8 agentes · 9 skills |
| 📣 **Core-Marketing** | #FF9800 | Estrategia de marketing, campañas, ads, email, copy | 12 agentes · 14 skills |
| 💻 **Core-Product** | #00B4D8 | Producto digital, UX/UI, frontend, backend, QA, DevOps | 18 agentes · 10 skills |
| 🌐 **Universales** | #9C27B0 | DA, PM, Research, Scope, Client Translator | 5 agentes |

### El Orchestrator

Jarvis ⚡ recibe prompts y enruta al agente correcto. No produce contenido final. No toma decisiones estratégicas. Solo coordina.

---

## 📦 Instalación

### Windows
```bat
git clone https://github.com/LUMBA-AGENCY/lumba-core.git
cd lumba-core
setup.bat
```

### macOS / Linux
```bash
git clone https://github.com/LUMBA-AGENCY/lumba-core.git
cd lumba-core
chmod +x setup.sh
./setup.sh
```

### Manual
```bash
npm install -g openclaw
openclaw config set agents.defaults.workspace "/ruta/a/lumba-core"
openclaw gateway start
```

---

## 📁 Estructura

```
lumba-core/
├── AGENTS.md              ← Reglas globales del sistema
├── SOUL.md                ← Personalidad del Orchestrator
├── MANIFIESTO.md          ← Identidad de Lumba
├── PRINCIPIOS.md          ← 15 principios operativos
├── METRICAS.md            ← Cómo medimos éxito
├── MODEL-STRATEGY.md      ← Estrategia Flash vs Pro vs Opus
├── setup.bat / setup.sh   ← Scripts de instalación
├── docs/
│   └── lumba-agentes-skills.html  ← Documentación visual interactiva
├── shared/
│   ├── metodologia/       ← Proceso 8 pasos, auditoría, brief, costos
│   ├── schemas/           ← JSON Schemas de handoff entre agentes
│   ├── agentes-universales/
│   └── infra/             ← Stacks, coding standards, configs
├── equipos/
│   ├── core-brand/        ← Agentes, skills y workflows de branding
│   ├── core-marketing/    ← Agentes, skills, playbooks y workflows de mkt
│   └── core-product/      ← Agentes, skills y workflows de producto
├── knowledge/
│   ├── templates/         ← Templates de briefs, ADRs, sprints
│   ├── checklists/        ← Checklists de auditoría
│   └── aprendizajes/      ← Lecciones aprendidas reutilizables
├── proyectos/             ← Proyectos activos
├── clientes/              ← Memoria por cliente
└── outputs/               ← Salidas generadas
```

---

## 📊 Documentación Visual

Abrí `docs/lumba-agentes-skills.html` en tu navegador para ver:

- 🔄 Pipeline de 8 pasos
- 📊 Selección de agentes por tipo de proyecto
- 💰 Calculadora de costos
- 📋 Workflows operativos
- 🧪 Simulador de proyectos (describí un proyecto y ve qué agentes se activan)

También disponible online en: _(pending deploy)_

---

## 🔐 Confidencial

Este repositorio es **uso interno exclusivo de Lumba**. Contiene la ventaja competitiva de la agencia. No compartir fuera de la organización.

---

## 📝 Principios Clave

1. **Auditoría antes de entrega** — Nada sale sin auditor
2. **Brief obsesivo** — Sin objetivo claro, no se arranca
3. **Humano decide, agente prepara** — Los agentes nunca aprueban entregables
4. **Devil's Advocate obligatorio** — Cuestiona TODO antes de cerrar
5. **Memoria persistente** — Cada cliente y proyecto tiene memoria
6. **Modelos correctos** — Flash 70% / Pro 25% / Opus 5%
7. **Corte automático** — USD 10/sesión → aprobación. USD 50/día → alerta

---

## 🚀 Roadmap

Ver `shared/metodologia/ROADMAP-IMPLEMENTACION.md`

---

**Lumba Core v1.0** · Sistema operativo interno · ⚡
