# MATRIZ DE SQUADS — LUMBA CORE

> **Versión:** v1.0
> **Propósito:** Eliminar ambigüedad en la selección de agentes. Jarvis no "piensa" qué agentes usar — consulta una tabla.
> **Última actualización:** 2 de junio de 2026.

---

## 1. POR QUÉ EXISTE ESTE DOCUMENTO

El flujo anterior era:

```
Jarvis interpreta → clasifica A/B/C → elige agentes subjetivamente
```

**Problema:** Dos sesiones distintas pueden armar squads distintos para el mismo proyecto. Proyectos híbridos no encajan claramente en una categoría. Ambigüedad = riesgo.

**Solución:** Dos ejes × Matriz determinista.

```
Gero describe proyecto
        ↓
Jarvis: Tipo (A/B/C) + Complejidad (S/M/L/XL)
        ↓
Jarvis consulta MATRIZ DE SQUADS
        ↓
Squad asignado automáticamente
        ↓
Si no matchea → escala a Gero
```

---

## 2. EJE 1 — TIPO DE PROYECTO (A / B / C)

> Definido en Workflow 00 — Project Assessment. Se reproduce acá como referencia.

| Tipo | Descripción | Señales |
|---|---|---|
| **A — Greenfield** | Proyecto nuevo desde cero. Sin código, sin repo, sin stack previo. | No existe repo. No hay decisiones técnicas previas. |
| **B — Brownfield** | Proyecto existente con código heredado. | Hay repo con commits. Hay stack definido. Hay deuda técnica. |
| **C — Parcial** | Hay algo (diseños, specs, MVP a medio hacer) pero no está completo. | Hay Figma pero no código. Hay documentación pero no implementación. Hay MVP que no se usó. |

### Casos híbridos — cómo decidir

| Caso | Clasificación | Regla |
|---|---|---|
| "Hay repo pero tiene 3 commits y nunca se usó" | **A** (Greenfield) | Si el código es trivial o descartable → tratar como nuevo. Umbral: <10 commits sustanciales. |
| "Hay Figma + documentación pero no hay código" | **C** (Parcial) | Hay assets de diseño. Falta implementación. Se evalúa lo existente y se completa. |
| "Hay MVP funcionando pero hay que tirarlo entero" | **B** (Brownfield) | Hay código en producción. Aunque se reescriba, el System Auditor revisa lo existente para no repetir errores. |
| "Hay código legacy + specs nuevas para refactor" | **B** (Brownfield) | El System Auditor audita. Las specs nuevas se tratan como gap analysis. |

---

## 3. EJE 2 — COMPLEJIDAD (S / M / L / XL)

### Checklist de clasificación

Responder estas 6 preguntas. Sumar puntos.

| Pregunta | S (0 pts) | M (1 pt) | L (2 pts) | XL (3 pts) |
|---|---|---|---|---|
| **Entidades de negocio** | 1 entidad | 2-3 entidades | 4-8 entidades | 9+ entidades |
| **Roles de usuario** | 1 rol | 2-3 roles (admin + user) | 4-6 roles (RBAC) | Multi-tenant + roles por tenant |
| **Autenticación / Auth** | Sin auth o auth simple (email) | Auth estándar (OAuth, JWT) | Auth compleja (2FA, SSO, RBAC) | Multi-tenant auth + compliance |
| **Integraciones externas** | 0 integraciones | 1-2 integraciones (API simple) | 3-5 integraciones | 6+ integraciones o ERPs |
| **Escala / Concurrencia** | <100 usuarios | 100-1K usuarios | 1K-100K usuarios | 100K+ usuarios |
| **IA / Features no estándar** | Sin IA | Feature simple (chatbot, search) | IA integrada en flujo core | Múltiples modelos, pipelines |

### Tabla de puntuación

| Puntaje total | Complejidad | Ejemplos típicos |
|---|---|---|
| 0-2 | **S** (Small) | Landing page, WordPress, ecommerce simple, sitio institucional |
| 3-5 | **M** (Medium) | MVP, SaaS chico, portal de clientes, app mobile simple |
| 6-9 | **L** (Large) | ERP, marketplace, sistema interno complejo, fintech |
| 10-18 | **XL** (Extra Large) | Multiempresa, microservicios, IA pipelines, compliance (SOC2/HIPAA) |

---

## 4. MATRIZ DE SQUADS

### 4.1 — Tipo A (Greenfield)

| Complejidad | Squad | Cantidad |
|---|---|---|
| **A + S** | PM, Research Agent, Analyst Functional, Backend Architect, QA Engineer | 5 |
| **A + M** | + Product Owner, UX Designer, UI Designer, Frontend Architect | 9 |
| **A + L** | + Data Architect, Security Agent, DevOps Engineer, Devil's Advocate (pre-cierre) | 13 |
| **A + XL** | + Business Strategist, System Auditor, Documentation Agent | 16 |

### 4.2 — Tipo B (Brownfield)

| Complejidad | Squad | Cantidad |
|---|---|---|
| **B + S** | PM, System Auditor, Backend Architect, QA Engineer | 4 |
| **B + M** | + Product Owner, Frontend Architect, Security Agent | 7 |
| **B + L** | + Data Architect, UX Designer, UI Designer, DevOps Engineer, Devil's Advocate | 12 |
| **B + XL** | + Business Strategist, Analyst Functional, Documentation Agent | 15 |

### 4.3 — Tipo C (Parcial)

| Complejidad | Squad | Cantidad |
|---|---|---|
| **C + S** | PM, Research Agent, Analyst Functional, Backend Architect, QA Engineer | 5 |
| **C + M** | + Product Owner, UX Designer, UI Designer, Frontend Architect | 9 |
| **C + L** | + System Auditor, Data Architect, Security Agent, DevOps Engineer, Devil's Advocate | 14 |
| **C + XL** | + Business Strategist, Documentation Agent | 16 |

---

## 5. AGENTES POR TIER Y SU ROL EN LA MATRIZ

### Siempre presentes (base, todo proyecto)

| Agente | Tier | Se suma en |
|---|---|---|
| PM | LOW (`deepseek-v4-flash`) | **S+** (todos los proyectos) |
| QA Engineer | MEDIUM (`deepseek-v4-pro`) | **S+** (todos los proyectos) |
| Backend Architect | MEDIUM (`deepseek-v4-pro`) | **S+** (todos los proyectos) |

### Se suman con complejidad creciente

| Agente | Tier | Se suma en | Motivo |
|---|---|---|---|
| Research Agent | LOW | A+S, C+S | Investigación inicial obligatoria en Greenfield y Parcial |
| Analyst Functional | MEDIUM | A+S, C+S | Specs funcionales desde el inicio |
| Product Owner | HIGH (`gpt-5.5`) | M+ | Proyectos con múltiples stakeholders o decisión de producto compleja |
| Frontend Architect | MEDIUM | M+ | Cuando hay UI más allá de un template |
| UX Designer | HIGH (`gpt-5.5`) | M+ | Proyectos con usuarios reales y flujos complejos |
| UI Designer | HIGH (`gpt-5.5`) | M+ | Sistema de diseño, componentes, responsive |
| Data Architect | HIGH (`gpt-5.5`) | L+ | Modelado de datos complejo no trivial |
| Security Agent | HIGH (`gpt-5.5`) | L+ | Datos sensibles, auth compleja, compliance |
| DevOps Engineer | LOW | L+ | CI/CD, infraestructura, deploy |
| Devil's Advocate | HIGH (`gpt-5.5`) | L+ | Auditoría pre-cierre obligatoria en proyectos complejos |
| Business Strategist | MEDIUM | XL | Alineación estratégica en proyectos de gran escala |
| Documentation Agent | LOW (`deepseek-v4-flash`) | XL | Documentación técnica para equipos grandes |
| System Auditor | HIGH (`gpt-5.5`) | B (siempre), C (L+) | Auditar código existente |

### Exclusiones explícitas

| Agente | NO se incluye en | Motivo |
|---|---|---|
| System Auditor | A (Greenfield) S/M | No hay código que auditar. Para A+XL se incluye como validador de arquitectura. |
| Data Architect | S/M | Modelado simple, lo resuelve Backend Architect |
| DevOps Engineer | S/M | Deploy simple (Vercel/Netlify), no requiere especialista |
| Product Owner | S | Proyecto chico, el PM cubre la priorización |

---

## 6. FLURO DE EJECUCIÓN

```
1. Gero describe el proyecto
2. Jarvis ejecuta checklist de complejidad (6 preguntas)
3. Jarvis determina Tipo (A/B/C) + Complejidad (S/M/L/XL)
4. Jarvis presenta a Gero:
   "📊 Clasificación: Tipo B, Complejidad M (5 pts)
    Squad asignado: PM, System Auditor, Product Owner, Backend, Frontend, Security, QA
    ¿Confirmás?"
5. Gero confirma o ajusta
6. Jarvis instancia el squad según la matriz
7. Si la matriz no cubre el caso → Jarvis escala a Gero
```

---

## 7. ESCAPE HATCH — CUÁNDO LA MATRIZ NO APLICA

**Jarvis debe escalar a Gero cuando:**

- El proyecto no encaja claramente en ninguna celda
- Gero pide explícitamente un squad distinto al de la matriz
- El proyecto involucra 2+ tipos (ej: Greenfield + Brownfield en paralelo)
- Aparece un tipo de proyecto nuevo no contemplado (ej: "solo consultoría estratégica, sin build")

**Gero siempre tiene la última palabra.** La matriz es una guía, no una cárcel.

---

## 8. MANTENIMIENTO DE LA MATRIZ

| Responsable | Acción | Cadencia |
|---|---|---|
| **Scope Agent** | Revisa si la matriz sigue siendo adecuada contra proyectos reales | Trimestral |
| **PM de cada proyecto** | Reporta si el squad asignado fue el correcto o sobraron/faltaron agentes | Al cierre de proyecto |
| **Gero** | Aprueba cambios a la matriz | Cuando se propone un cambio |

### Reglas de evolución

1. Si 2+ proyectos del mismo tipo requirieron un agente que no estaba en la matriz → **se agrega**.
2. Si un agente se convocó en 3+ proyectos y nunca aportó valor → **se evalúa remover**.
3. Si aparece un tipo de proyecto nuevo → **se crea una nueva fila/columna** con aprobación de Gero.
4. La matriz **no se modifica en caliente** durante un proyecto. Los cambios se proponen al cierre.

---

## 9. ANTI-PATTERNS

- ❌ "Este proyecto es chico, no necesitamos QA." → QA está en S+. Siempre.
- ❌ "Convocamos a todos los agentes por las dudas." → La matriz existe para evitarlo. Squad mínimo viable.
- ❌ "Cambiemos la matriz ahora mismo porque este proyecto no encaja." → Escape hatch: escalar a Gero. La matriz se actualiza después.
- ❌ "El PM puede hacer de Product Owner en un proyecto M." → No. Son roles distintos. Si la matriz dice PO, va PO.

---

**FIN DE MATRIZ DE SQUADS**
