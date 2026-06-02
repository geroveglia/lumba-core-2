# Workflow 1: Discovery + Definición Funcional

## ⚠️ Pre-requisito obligatorio

**Antes de ejecutar este workflow, debe completarse el Workflow 0: `00-diseno-base-datos.md`.**

El modelo de datos debe estar diseñado, auditado y aprobado antes de avanzar a la definición funcional.

---

## Cuándo se usa
- Al iniciar un proyecto nuevo de producto digital (después del Workflow 0).

## Pasos

```
0. data-architect ⚡ (OPUS) → DISEÑO DEL MODELO DE DATOS (Workflow 0)
   ⬇ MODELO APROBADO
1. business-strategist → discovery comercial + viabilidad
2. research-agent (universal) → research de mercado + competencia
3. product-owner → propuesta de roadmap + MVP (basada en el modelo de datos existente)
4. devils-advocate → challenge a la propuesta
5. analyst-functional → especificación funcional detallada
6. ux-designer → user flows iniciales
7. backend-architect → propuesta de APIs (sobre el modelo de datos ya definido)
8. product-auditor → audit completo (UX/Product Gate)
9. PM o socio + cliente → aprobación
```

## Skills involucradas
- `data-modeling`
- `discovery-framework`
- `functional-specification`
- `user-story-format`

## Output
- Modelo de datos completo (del Workflow 0).
- Documento de discovery.
- Especificación funcional del MVP.
- Roadmap.
- Estimación.

## Quality Gate
- **Data Gate** — modelo de datos aprobado (pre-requisito).
- Strategy Gate al cierre del discovery.
- UX/Product Gate al cierre de la spec.

## Duración estimada
2-4 semanas (más 3-5 días del Workflow 0).

## Validación humana
- Modelo de datos validado por Founder/Tech Lead.
- Cliente valida discovery antes de pasar a desarrollo.
