# MODEL STRATEGY — Lumba Core (OpenClaw)

> Estrategia de selección de modelos para el sistema de agentes.

---

## Modelos disponibles

| Modelo | Contexto | Costo relativo | Tier |
|---|---|---|---|
| `deepseek-v4-flash` | 977k | 💰 Económico | LOW |
| `deepseek-v4-pro` | 977k | 💰💰💰 Premium | MEDIUM (default) |
| `openai/gpt-5.5` | — | 💰💰💰💰 Premium+ | HIGH (vía ChatGPT Plus OAuth) |

> **Nota:** El tier HIGH usa `openai/gpt-5.5` a través de la suscripción ChatGPT Plus (Codex OAuth). No requiere API key de OpenAI Platform.

---

## Matriz de decisión

| Categoría de tarea | Modelo | Ejemplos |
|---|---|---|
| **Boilerplate / CRUD** | `deepseek-v4-flash` | Crear archivos, copiar, refactors simples, scaffolding |
| **Code review estándar** | `deepseek-v4-flash` | Revisar formato, convenciones, linting |
| **Documentación** | `deepseek-v4-flash` | READMEs, CHANGELOGs, comentarios |
| **Análisis funcional** | `deepseek-v4-pro` | Especificaciones, user stories, criterios de aceptación |
| **Arquitectura** | `deepseek-v4-pro` | Decisiones de diseño, ADRs |
| ⚡ **Modelado de datos** | `openai/gpt-5.5` | Diseño de base de datos, modelo ER, migraciones — SIEMPRE GPT-5.5 |
| **Debugging complejo** | `deepseek-v4-pro` | Bugs cross-layer, race conditions, memory leaks |
| **Code review crítica** | `deepseek-v4-pro` | Seguridad, performance, cambios en core |
| **Devil's Advocate** | `openai/gpt-5.5` | Auditoría pre-cierre de fase |
| **Orchestrator routing** | `deepseek-v4-pro` | Enrutamiento y coordinación (Jarvis) |
| **Research / Web Search** | `deepseek-v4-flash` | Búsquedas, síntesis de información |
| **Estrategia** | `deepseek-v4-pro` | Decisiones de negocio, propuestas al cliente |
| **Auditoría de entregables** | `deepseek-v4-pro` | Revisión contra brief y estándares |
| **Security / System Audit** | `openai/gpt-5.5` | Análisis de seguridad, auditoría de sistemas |
| **Product Ownership** | `openai/gpt-5.5` | Decisiones de producto, priorización |

---

## Reglas

1. **Default:** Toda tarea nueva arranca con `deepseek-v4-flash`. Si requiere más profundidad → se escala a `deepseek-v4-pro`.
2. **No negociable con GPT-5.5:** Devil's Advocate, Data Architect, Security Agent, System Auditor, Product Owner.
3. **Jarvis (Orchestrator):** Corre con `deepseek-v4-pro` — coordina y enruta, no usa flash.
4. **Costo acumulado:** Monitorear que el costo total por proyecto no exceda lo estimado. GPT-5.5 usa la suscripción ChatGPT Plus (sin costo de API adicional).
5. **Ajuste dinámico:** Si una tarea con `flash` requiere 2+ intentos, escalar a `pro`.
