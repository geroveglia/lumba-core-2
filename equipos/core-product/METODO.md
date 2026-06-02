# MÉTODO CORE-PRODUCT — LUMBA CORE v1.0

> **Versión:** v1.0
> **Tono:** Manual operativo.
> **Equipo:** Core-Product (una de las 3 unidades de negocio de Lumba).
> **Para quién:** equipo humano de producto + desarrollo (5 devs + diseñadores + estrategia) + agentes especializados.
> **Última actualización:** 23 de mayo de 2026.

---

## 1. PROPÓSITO DE LA RED

Core-Product es la red de agentes que sirve a los proyectos de **producto digital, software, UX/UI y estrategia de negocio asociada**.

Sirve dos tipos de proyectos:

1. **Productos de cliente** — sitios, plataformas, apps, ecommerces para clientes externos.
2. **Productos propios de Lumba** — empezando por **Minuta** (primer caso de uso real de Lumba Core).

Su función central: **reducir errores funcionales, retrabajos técnicos y mala definición que generan correcciones costosas en desarrollo** (Principio 0 aplicado a producto).

---

## 2. SERVICIOS QUE CUBRE

Basado en los servicios reales de Lumba:

### Estrategia de negocio
- Validación comercial.
- Modelos de monetización.
- Análisis de mercado.
- Estrategia de producto.
- Plan de viabilidad.
- Investigación cuali-cuantitativa.

### Producto digital
- Discovery.
- Definición funcional.
- Arquitectura de información.
- Wireframes y prototipos.
- Diseño UX/UI.
- Sistema de diseño.
- QA y testing.

### Desarrollo de software
- Sitios web.
- Plataformas SaaS.
- Apps móviles.
- Ecommerces (modernos y legacy).
- Integraciones (Mercado Pago, CRMs, APIs).
- Bots conversacionales (WhatsApp, web).
- Plataformas internas.

---

## 3. AGENTES ESPECIALIZADOS

Core-Product tiene **12 agentes especializados**:

| Agente | Función principal | Modelo |
|---|---|---|
| `business-strategist` | Estrategia de negocio + viabilidad | Sonnet 4.6 |
| `product-owner` | Define producto, priorización, roadmap | Sonnet 4.6 |
| `analyst-functional` | Definición funcional + criterios de aceptación | Sonnet 4.6 |
| `ux-designer` | Diseño UX, wireframes, prototipos | Sonnet 4.6 |
| `ui-designer` | Diseño UI, sistema de diseño, componentes | Sonnet 4.6 |
| `frontend-architect` | Arquitectura frontend | Sonnet 4.6 |
| `backend-architect` | Arquitectura backend | Sonnet 4.6 |
| `data-architect` | Diseño de base de datos ⚡ PRIMER AGENTE | **Opus 4.7** |
| `devops-engineer` | Deploy, CI/CD, monitoring | Haiku 4.5 |
| `qa-engineer` | Testing, casos de uso, edge cases | Sonnet 4.6 |
| `code-reviewer` | Review de código, deuda técnica | Sonnet 4.6 |
| `product-auditor` | Auditoría obligatoria | **Opus 4.7** |

> ⚡ **Regla fundacional:** `data-architect` (Opus) es el primer agente invocado en todo proyecto. El modelo de datos se diseña antes de cualquier definición funcional, UX o arquitectura. Ver Workflow 0.

Plus agentes universales (Orchestrator, PM, Devil's Advocate, Research, Scope, Client Translator).

---

## 4. STACKS TIPIFICADOS

Core-Product opera en 3 stacks (ver `shared/infra/STACKS.md`):

- **Stack A** — Serverless gestionado (default, 80% de proyectos).
- **Stack B** — Contenedores gestionados (15%).
- **Stack C** — Kubernetes (5%, solo enterprise).

Más **Stack legacy** (PHP/MySQL) para mantenimiento de proyectos existentes.

---

## 5. SKILLS REUSABLES

Core-Product tiene **10 skills**:

| Skill | Propósito |
|---|---|
| `discovery-framework` | Estructura de discovery de proyecto |
| `functional-specification` | Cómo escribir especificación funcional |
| `user-story-format` | Formato estándar de user stories |
| `ux-flow-design` | Diseño de flujos UX |
| `data-modeling` | Modelado de datos + esquemas |
| `adr-generator` | Generación de Architecture Decision Records |
| `code-review-checklist` | Checklist de code review |
| `qa-test-plan` | Plan de testing |
| `deployment-checklist` | Checklist pre-deploy |
| `product-audit-checklist` | Audit final de producto |

---

## 6. WORKFLOWS

Core-Product tiene **6 workflows operativos**:

0. ⚡ **Diseño de base de datos** — PRIMER workflow. Modelado de datos antes que todo.
1. **Discovery + definición funcional** — desde idea hasta especificación.
2. **Diseño UX/UI completo** — desde wireframes hasta sistema de diseño.
3. **Desarrollo de feature** — desde spec hasta deploy.
4. **Bug crítico en producción** — fix + rollback si hace falta.
5. **Soporte evolutivo** — mantenimiento + iteración mensual.

Ver detalles en `equipos/core-product/workflows/`.

---

## 7. PROCESO DE 8 PASOS APLICADO

En Core-Product, los 8 pasos del proceso Lumba se ven así:

```
1. INVESTIGAMOS    → discovery + relevamiento + research
2. PENSAMOS        → ⚡ PRIMERO: diseño de base de datos (data-architect · Opus)
                   → DESPUÉS: definición funcional + UX + arquitectura
3. PENSAMOS DE NUEVO → challenge de alcance + decisiones técnicas
4. VALIDAMOS       → prototipos + cliente
5. CONSTRUIMOS     → desarrollo
6. TESTEAMOS       → QA + tests automáticos
7. MEJORAMOS       → refactor + optimización
8. LANZAMOS        → deploy a producción
```

**Reglas:**
- Ningún proyecto salta del Paso 1 al Paso 5.
- ⚡ **El modelo de datos se diseña ANTES de cualquier otra decisión técnica.** Es el cimiento del sistema.

---

## 8. CHECKLIST DE AUDITORÍA — UX/PRODUCT GATE + SOFTWARE GATE

### UX/Product Gate (antes de desarrollar)

- [ ] Cada feature tiene criterio de aceptación.
- [ ] Casos de uso cubren happy path + edge cases.
- [ ] Permisos y roles definidos.
- [ ] Reglas de negocio claras.
- [ ] Integraciones identificadas.
- [ ] Estados de pantalla completos (loading/empty/error).
- [ ] Responsive funcional.
- [ ] Accesibilidad WCAG AA.

### Software Gate (antes de merge / deploy)

**Pre-merge:**
- [ ] PR pasó code review.
- [ ] Tests asociados.
- [ ] Variables de entorno fuera del repo.
- [ ] No hay TODOs sin owner.
- [ ] Documentación actualizada si corresponde.
- [ ] Tests passing en CI.

**Pre-deploy:**
- [ ] Plan de rollback definido.
- [ ] Variables de entorno configuradas en target.
- [ ] Monitoring activo.
- [ ] Cambio comunicado al cliente si corresponde.
- [ ] Backups recientes.

**Regla de hierro:**
- Sin tests passing → no hay merge.
- Sin plan de rollback → no hay deploy.

---

## 9. CONEXIÓN CON DOLORES DEL ÁREA

| Dolor | Cómo Core-Product lo resuelve |
|---|---|
| Definiciones funcionales débiles que generan retrabajo | `analyst-functional` + criterios de aceptación obligatorios |
| Errores de producto que detecta el cliente y no nosotros | `qa-engineer` + `product-auditor` antes de entrega |
| Deuda técnica acumulada | `code-reviewer` integrado al flujo + métricas de deuda |
| Decisiones técnicas no documentadas | `adr-generator` para Architecture Decision Records |
| Cambios de alcance sin control | `scope-agent` (universal) + workflow específico |

---

## 10. MEMORIA POR PROYECTO

Cada proyecto en Core-Product tiene `MEMORIA-PROYECTO.md` que incluye:

- Objetivo del producto.
- Stack elegido y justificación.
- Decisiones técnicas (con ADRs asociados).
- Modelo de datos.
- Permisos y roles.
- Reglas de negocio.
- Integraciones activas.
- Variables de entorno (referencias, no valores).
- Deuda técnica conocida.
- Riesgos abiertos.

---

## 11. CASO DE USO EJE: MINUTA

**Minuta es el primer caso de uso real de Lumba Core.**

- Es un SaaS de gestión de reuniones (humano-first, multi-cliente, español, AI auditor).
- Se construye CON Lumba Core (no después).
- Sirve como validación del sistema.

**Stack:** Stack A (Vite + React + TS + Supabase + Gemini + Vercel).
**Multi-tenant:** desde el MVP.

Su workspace está en `proyectos/minuta/`.

---

## 12. MÉTRICAS ESPECÍFICAS DE CORE-PRODUCT

| Métrica | Umbral saludable |
|---|---|
| % de proyectos con discovery completado | >95% |
| % de especificaciones funcionales auditadas pre-desarrollo | 100% |
| % de PRs con code review | 100% |
| % de deploys con plan de rollback | 100% |
| % de bugs detectados internamente (vs por cliente) | >80% |
| Tiempo promedio desde definición funcional hasta deploy de MVP | <8 semanas |
| % de deploys exitosos al primer intento | >90% |

---

## 13. CHECKLIST DE VALIDACIÓN

- [ ] Los 12 agentes cubren el flujo completo.
- [ ] Los 10 skills son los correctos.
- [ ] Los 5 workflows reflejan operación real.
- [ ] Los 3 stacks aplican.
- [ ] Minuta puede empezar a operar con esto.

---

**FIN MÉTODO CORE-PRODUCT**
