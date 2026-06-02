# Workflow 01: Discovery + Definición Funcional

## ⚠️ Pre-requisito obligatorio

**Antes de ejecutar este workflow, debe completarse el Workflow 00 (Project Assessment).**

El proyecto debe estar clasificado (Tipo A/B/C) y `MEMORIA-PROYECTO.md` instanciada.

---

## 🚫 Data Architect NO interviene en este workflow

**El diseño de base de datos ocurre en Workflow 03, DESPUÉS de este workflow y del Tech Stack Decision (W02).**
Queda estrictamente prohibido modelar datos antes de que las reglas de negocio estén cerradas y validadas, y el stack técnico esté definido.

---

## Cuándo se usa
- Después del Project Assessment (Workflow 00) para proyectos Tipo A.
- Para proyectos Tipo C, solo las partes de discovery que falten.

## Pasos

```
1. business-strategist → discovery comercial + viabilidad
   ├── Modelo de negocio
   ├── Propuesta de valor
   └── Validación comercial

2. research-agent (universal) → research de mercado + competencia
   ├── Competidores directos e indirectos
   ├── Tendencias del sector
   └── Benchmark de funcionalidades

3. product-owner → roadmap + MVP + PRIORIZACIÓN FORMAL
   ├── RICE / MoSCoW / WSJF (método formal obligatorio)
   ├── Roadmap con justificación cuantitativa
   └── Definición de MVP con criterios de corte

4. analyst-functional → especificación funcional detallada
   ├── User stories con criterios de aceptación
   ├── Reglas de negocio explícitas
   ├── Edge cases identificados
   └── Permisos y roles definidos

5. devils-advocate → challenge a la propuesta completa
   ├── ¿Las reglas de negocio son consistentes?
   ├── ¿El MVP es realmente mínimo?
   ├── ¿Hay funcionalidades sin justificación?
   └── ¿Faltan casos de uso críticos?

6. ux-designer → user flows iniciales (basados en reglas de negocio)
7. backend-architect → propuesta preliminar de APIs (sin modelo de datos aún)
8. product-auditor → audit completo (UX/Product Gate)
9. PM o socio + cliente → aprobación

   ⬇ SPEC FUNCIONAL + REGLAS DE NEGOCIO CERRADAS Y VALIDADAS
   ⬇ PASA A WORKFLOW 02: TECH STACK DECISION (Gero elige stack)
   ⬇ LUEGO A WORKFLOW 03: DATA ARCHITECT DISEÑA EL MODELO CON STACK CONFIRMADO
```

## Skills involucradas
- `discovery-framework`
- `functional-specification`
- `user-story-format`

## Output
- Documento de discovery.
- Especificación funcional del MVP.
- Reglas de negocio validadas.
- Roadmap con priorización formal (RICE/MoSCoW/WSJF).
- Estimación.

## Quality Gate
- Strategy Gate al cierre del discovery.
- UX/Product Gate al cierre de la spec.
- **Business Rules Gate** — reglas de negocio cerradas y validadas (pre-requisito para Workflow 02).

## Duración estimada
2-4 semanas.

## Validación humana
- Cliente valida discovery antes de pasar a desarrollo.
- Gero valida las reglas de negocio antes del Data Architect.
