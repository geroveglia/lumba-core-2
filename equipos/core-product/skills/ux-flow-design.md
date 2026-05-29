---
name: ux-flow-design
version: 1.0
team: core-product
last_updated: 2026-05-23
used_by: [ux-designer]
---

# Skill: UX Flow Design

## Estructura de un flow

### 1. Punto de entrada
- ¿Cómo llega el usuario?
- ¿Qué sabe / espera?

### 2. Pasos del flow
- Cada paso con propósito claro.
- Mínimos pasos posibles (no por menos sea mejor, pero sí por no agregar fricción innecesaria).

### 3. Estados intermedios
- Loading entre acciones.
- Validaciones inline.
- Feedback visual.

### 4. Punto de salida
- Confirmación clara.
- Next action sugerida.
- Cómo retomar si abandonó.

### 5. Edge cases
- ¿Qué pasa si no tiene datos?
- ¿Qué pasa si la conexión falla?
- ¿Qué pasa si vuelve más tarde?

## Principios

- **Reducir fricción** — menos clicks, menos campos, menos pensamiento.
- **Feedback constante** — el usuario sabe qué pasó.
- **Reversibilidad** — puede volver atrás.
- **Forgiveness** — perdona errores del usuario.

## Anti-patterns

- ❌ Formularios infinitos sin razón.
- ❌ Modals que rompen el flow.
- ❌ Sin feedback en acciones críticas.
- ❌ Sin estado de error legible.
