# Workflow 02: Tech Stack Decision (ADR de Arquitectura)

> **Se ejecuta DESPUÉS del Discovery (Workflow 01).**
> **ANTES del Diseño de Base de Datos (Workflow 03).**
> **Gero elige el stack. Los agentes validan, desafían y documentan.**

---

## Principio

> **El stack se elige antes de modelar datos.**
>
> El Data Architect necesita saber si modela para Supabase/PostgreSQL, para MongoDB, para Redis o para microservicios con event sourcing. Elegir el stack ANTES permite que el modelo de datos sea preciso desde el día 1 — no un modelo genérico que después hay que adaptar.

---

## Cuándo se usa

- **Obligatorio** después del Workflow 01 (Discovery + Definición Funcional) para todo proyecto de producto digital.
- Cuando un proyecto existente migra de stack.
- Cuando se evalúa una tecnología nueva para un cliente.

---

## Pasos

```
PASO 0 — GERO DECIDE EL STACK ⚡

Jarvis pregunta por Telegram:
  "⚡ TiendaX: ¿qué stack usamos?
   
   Opciones:
   A) Vite + React + TS + Tailwind + Supabase + Vercel (default, 80% proyectos)
   B) Next.js + TS + Tailwind + Supabase + Vercel (SSR/SEO)
   C) React + NestJS + PostgreSQL + AWS (enterprise)
   D) Otro — decime vos
   
   Con el discovery que tenemos, mi recomendación: Stack A."

Gero responde: "A" (o "B", "C", o describe stack custom)
  → Jarvis registra la decisión en state.json: stack.type = "A"

PASO 1 — AGENTES VALIDAN (no proponen, validan)

1. frontend-architect → revisa que el stack frontend sea adecuado
   ├── ¿El framework elegido cubre las necesidades del proyecto?
   ├── ¿Hay alguna restricción que obligue a cambiar?
   └── Output: validación o advertencia

2. backend-architect → revisa que el stack backend sea adecuado
   ├── ¿Las APIs necesarias son viables con este stack?
   ├── ¿Auth? ¿Real-time? ¿File upload?
   └── Output: validación o advertencia

3. devops-engineer → define infraestructura para el stack elegido
   ├── Hosting, CI/CD, entornos
   ├── Domains, SSL, secrets
   └── Costo mensual estimado

PASO 2 — DEVIL'S ADVOCATE CHALLENGEA

4. devils-advocate → challenge al stack ELEGIDO POR GERO
   ├── ¿Es el stack correcto para ESTE proyecto?
   ├── ¿Hay sobre o sub engineering?
   ├── ¿Riesgos específicos de este stack para este cliente?
   ├── ¿Costo real vs presupuesto del cliente?
   └── Si detecta problema grave → notifica a Gero con recomendación

PASO 3 — ADR Y CIERRE

5. frontend-architect + backend-architect → generan ADR completo
6. product-auditor → auditoría final
7. Gero → aprueba el ADR final

   ⬇ STACK DEFINIDO Y APROBADO
   ⬇ PASA A WORKFLOW 03: DATA ARCHITECT DISEÑA EL MODELO CON STACK CONFIRMADO
```

---

## Stacks pre-definidos

Lumba Core tiene stacks tipificados (ver `shared/infra/STACKS.md`):

| Stack | Frontend | Backend | DB | Hosting | Para qué |
|---|---|---|---|---|---|
| **A** (default) | Vite + React + TS + Tailwind | NestJS (si necesita) | Supabase (PostgreSQL) | Vercel + Supabase | 80% de proyectos |
| **B** | Next.js + TS + Tailwind | Next.js API routes | Supabase (PostgreSQL) | Vercel + Supabase | 15% — necesita SSR/SEO |
| **C** | React + TS + Tailwind | NestJS + microservicios | PostgreSQL + Redis | AWS ECS / K8s | 5% — enterprise |
| **Legacy** | jQuery / Vanilla | PHP / Laravel | MySQL | cPanel / VPS | Solo mantenimiento |

**Regla:** si el proyecto calza en Stack A → Stack A. No overengineerear.

---

## Skills involucradas

- `adr-generator`
- `deployment-checklist`

---

## Output

- **ADR de Stack Decision** (`/proyectos/{nombre}/outputs/02-adr-stack.md`):
  - Stack elegido y justificación.
  - Alternativas consideradas y descartadas.
  - Costo mensual estimado de infraestructura.
  - Plan de entornos (dev/staging/prod).
  - Estrategia de CI/CD.
  - Variables de entorno necesarias (nombres, no valores).
  - Motor de base de datos confirmado (input para Workflow 03).

---

## Quality Gate

- **Architecture Gate** — el ADR debe pasar auditoría del Devil's Advocate antes de avanzar.
- Si el stack no es el correcto → iterar.
- Máximo 2 iteraciones antes de escalar al Founder.

---

## Duración estimada

1-3 días.

---

## Validación humana

- Tech Lead o Founder aprueba el stack.
- Si el cliente tiene preferencias técnicas, se incorporan como restricción en el brief.

---

## Anti-patterns

- ❌ "Usemos Stack A siempre sin pensar."
- ❌ "Elijamos la tecnología más nueva porque está de moda."
- ❌ "No necesitamos entornos separados, deployemos directo a prod."
- ❌ "El stack lo decidimos sobre la marcha."
- ❌ "No documentemos las alternativas descartadas."
- ❌ "Diseñemos la DB antes de saber en qué motor va a correr."

---

**Workflow 02** · Architecture Decision · ⚡
