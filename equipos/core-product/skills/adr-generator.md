---
name: adr-generator
version: 1.0
team: core-product
last_updated: 2026-05-23
used_by: [frontend-architect, backend-architect, data-architect]
---

# Skill: ADR Generator

## ADR — Architecture Decision Record

Cada decisión técnica importante se documenta como ADR.

## Template

```markdown
# ADR-{número}: {título de la decisión}

## Estado
[Propuesto / Aceptado / Rechazado / Deprecado]

## Contexto
¿Cuál es el problema o decisión que estamos tomando?
¿Por qué hay que decidir esto ahora?

## Decisión
¿Qué decidimos?

## Alternativas consideradas
- Alt 1: descripción + pros/contras.
- Alt 2: descripción + pros/contras.
- Alt 3: descripción + pros/contras.

## Justificación
¿Por qué esta decisión sobre las alternativas?

## Consecuencias
- Positivas.
- Negativas.
- Neutras.

## Compromisos
¿Qué nos comprometemos a hacer / no hacer después de esta decisión?
```

## Cuándo crear ADR

- Elección de stack o tecnología.
- Decisiones de arquitectura.
- Cambios en convenciones del proyecto.
- Decisiones que cuestan revertir.

## Ubicación
- En `proyectos/{proyecto}/docs/decisiones/`.
- Numerados secuencialmente.
