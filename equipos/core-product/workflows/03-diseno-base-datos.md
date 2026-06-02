# Workflow 03: Diseño de Base de Datos ⚡

> **Se ejecuta DESPUÉS del Tech Stack Decision (Workflow 02).**
> **SOLO cuando Business Strategist, Product Owner y Analyst Functional cerraron y validaron las reglas de negocio (Workflow 01).**
> **SOLO cuando el stack técnico está definido y aprobado (Workflow 02).**
> **Prohibido modelar sobre hipótesis. Se modela sobre certezas: reglas de negocio + motor de DB confirmado.**

---

## Principio fundacional

> **La base de datos se diseña sobre reglas de negocio validadas Y stack técnico definido.**
>
> Una decisión equivocada en el modelo de datos se paga en cada capa del stack. Una decisión correcta ahorra semanas de retrabajo.
> 
> **Por eso el Data Architect no interviene hasta que Discovery cerró Y el Tech Stack está aprobado. Modelar antes es adivinar — tanto las reglas de negocio como el motor sobre el que va a correr.**

---

## Cuándo se usa

- **Obligatorio** al iniciar CUALQUIER proyecto nuevo de producto digital.
- Después de que Workflow 01 (Discovery) Y Workflow 02 (Tech Stack) estén cerrados y aprobados.
- También aplica a proyectos de marketing y branding cuando involucren sistemas con persistencia de datos.

---

## Inputs del Data Architect

El Data Architect recibe como input:

| Fuente | Qué recibe |
|---|---|
| **Workflow 01 (Discovery)** | Reglas de negocio cerradas, entidades detectadas, user stories, permisos y roles |
| **Workflow 02 (Tech Stack)** | Motor de DB confirmado (PostgreSQL/Supabase, MySQL, MongoDB, etc.), ADR de arquitectura, restricciones de infra |

---

## Tipo de base de datos

La decisión de **relacional vs no relacional** está informada por el ADR del Tech Stack:

| Tipo | Cuándo usarla | Ejemplos |
|---|---|---|
| **Relacional (SQL)** | Datos estructurados, relaciones complejas, integridad transaccional, reporting | Minuta, CRMs, ecommerce, sistemas de gestión |
| **No relacional (NoSQL)** | Datos semi-estructurados, alta escalabilidad horizontal, schemas flexibles, documentos | Analytics, logs, catálogos con atributos variables, real-time feeds |

**Regla:** si el stack eligió Supabase → relacional (PostgreSQL). Si eligió otro motor, el Data Architect adapta su diseño al motor confirmado.

---

## Pasos

```
1. research-agent (universal) → contexto de negocio + entidades detectadas en discovery
2. data-architect ⚡ (OPUS) → DISEÑO DEL MODELO DE DATOS COMPLETO
   ├── Lee ADR del Tech Stack (Workflow 02) para conocer el motor de DB
   ├── Decisión: relacional vs no relacional (con justificación)
   ├── Entidades principales y sus atributos
   ├── Relaciones entre entidades
   ├── Índices, constraints, integridad referencial
   ├── Estrategia multi-tenant (si aplica)
   ├── Features específicas del motor elegido (RLS en Supabase, etc.)
   └── ADR de decisiones de modelado
3. devils-advocate → challenge al modelo:
   ├── ¿Escala al volumen esperado en 12 meses?
   ├── ¿Las relaciones cubren todos los casos de uso?
   ├── ¿Hay sobre-normalización o sub-normalización?
   ├── ¿Los índices cubren las consultas más frecuentes?
   ├── ¿El modelo aprovecha las capacidades del motor elegido?
   └── ¿Es coherente con el ADR del Tech Stack?
4. backend-architect → validación del modelo contra APIs necesarias
5. product-auditor → audit del modelo de datos (Software Gate)
6. PM o socio → aprobación del modelo
```

---

## Skills involucradas

- `data-modeling`
- `adr-generator`
- `discovery-framework`

---

## Output

- **Modelo de datos completo** (diagrama ER o documento equivalente).
- **Decisión fundamentada: relacional vs no relacional.**
- **ADR de decisiones de modelado** (por qué se eligió cada estructura).
- **Migraciones iniciales** listas para aplicar (en el formato del motor elegido).
- **Estrategia multi-tenant** definida (si aplica).

---

## Quality Gate

- **Software Gate** — el modelo de datos debe pasar auditoría antes de que cualquier otro agente técnico (frontend, backend, UX) comience a trabajar.
- Si el modelo no pasa → vuelve a `data-architect` para iteración.
- Máximo 2 iteraciones antes de escalar al Founder.

---

## Duración estimada

3-5 días (dependiendo de la complejidad del dominio).

---

## Validación humana

- El Founder o Tech Lead valida el modelo de datos antes de avanzar.
- Si el proyecto es para un cliente, se comparte el modelo en lenguaje no-técnico para validación de entidades principales.

---

## Reglas inviolables

1. **Este workflow va DESPUÉS de Discovery (W01) y Tech Stack (W02).** Ningún agente modela datos sin saber las reglas de negocio Y el motor de DB.
2. **Opus o nada.** El `data-architect` corre con Opus. No se negocia.
3. **Sin modelo aprobado, no hay desarrollo.** Si el modelo no pasó el gate, no se escribe una línea de código.
4. **La decisión relacional vs no relacional se documenta.** No se elige "por costumbre".
5. **El modelo se versiona.** Migraciones en el directorio del motor elegido desde el día 1.
6. **El modelo debe ser coherente con el ADR del Tech Stack.** Si el stack dice Supabase, el modelo usa PostgreSQL con RLS.

---

## Anti-patterns

- ❌ "Arranquemos con el frontend y después vemos la base."
- ❌ "Usemos NoSQL porque está de moda."
- ❌ "Modelemos sobre la marcha."
- ❌ "El ORM resuelve solo."
- ❌ "No necesitamos índices hasta que haya tráfico."
- ❌ "Deleguemos el modelo de datos al backend-architect sin revisión dedicada."
- ❌ "Diseñemos la DB sin saber en qué motor va a correr."

---

**Workflow 03** · Fundacional · ⚡
