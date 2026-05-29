# MODEL STRATEGY — Lumba Core (OpenClaw)

> Estrategia de selección de modelos para el sistema de agentes.

---

## Modelos disponibles

| Modelo | Contexto | Costo relativo | Alias |
|---|---|---|---|
| `deepseek/deepseek-v4-flash` | 977k | 💰 Económico | `DeepSeek` |
| `deepseek/deepseek-v4-pro` | 977k | 💰💰💰 Premium | default |

---

## Matriz de decisión

| Categoría de tarea | Modelo | Ejemplos |
|---|---|---|
| **Boilerplate / CRUD** | `flash` | Crear archivos, copiar, refactors simples, scaffolding |
| **Code review estándar** | `flash` | Revisar formato, convenciones, linting |
| **Documentación** | `flash` | READMEs, CHANGELOGs, comentarios |
| **Análisis funcional** | `pro` | Especificaciones, user stories, criterios de aceptación |
| **Arquitectura** | `pro` | Decisiones de diseño, ADRs, modelado de datos |
| **Debugging complejo** | `pro` | Bugs cross-layer, race conditions, memory leaks |
| **Code review crítica** | `pro` | Seguridad, performance, cambios en core |
| **Devil's Advocate** | `pro` + thinking=high | Auditoría pre-cierre de fase |
| **Orchestrator routing** | `flash` | Enrutamiento simple y clasificación de tareas |
| **Research / Web Search** | `flash` | Búsquedas, síntesis de información |
| **Estrategia** | `pro` + thinking=high | Decisiones de negocio, propuestas al cliente |
| **Auditoría de entregables** | `pro` | Revisión contra brief y estándares |

---

## Reglas

1. **Default:** Toda tarea nueva arranca con `flash`. Si requiere más profundidad → se escala a `pro`.
2. **No negociable con pro:** Devil's Advocate, decisiones de arquitectura, estrategia final.
3. **Costo acumulado:** Monitorear que el costo total por proyecto no exceda lo estimado.
4. **Ajuste dinámico:** Si una tarea con `flash` requiere 2+ intentos, escalar a `pro`.
