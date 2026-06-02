# Workflow 0: Diseño de Base de Datos ⚡ FUNDACIONAL

> **Este workflow es el punto de partida de TODO proyecto en Lumba Core.**
> **No se inicia ningún otro workflow técnico sin completar este primero.**

---

## Principio fundacional

> **La base de datos es el cimiento del sistema. Todo lo demás — frontend, backend, APIs, UX — se construye sobre ella.**
>
> Una decisión equivocada en el modelo de datos se paga en cada capa del stack. Una decisión correcta ahorra semanas de retrabajo.

---

## Cuándo se usa

- **Obligatorio** al iniciar CUALQUIER proyecto nuevo de producto digital.
- Antes de cualquier definición funcional, diseño UX/UI, o arquitectura de software.
- También aplica a proyectos de marketing y branding cuando involucren sistemas con persistencia de datos.

---

## Tipo de base de datos

La decisión de **relacional vs no relacional** es la primera decisión técnica del proyecto:

| Tipo | Cuándo usarla | Ejemplos |
|---|---|---|
| **Relacional (SQL)** | Datos estructurados, relaciones complejas, integridad transaccional, reporting | Minuta, CRMs, ecommerce, sistemas de gestión |
| **No relacional (NoSQL)** | Datos semi-estructurados, alta escalabilidad horizontal, schemas flexibles, documentos | Analytics, logs, catálogos con atributos variables, real-time feeds |

**Regla:** si el 80% del proyecto calza en relacional → relacional. No overengineerear con NoSQL "por si acaso".

---

## Pasos

```
1. research-agent (universal) → contexto de negocio + entidades detectadas en discovery
2. data-architect ⚡ (OPUS) → DISEÑO DEL MODELO DE DATOS COMPLETO
   ├── Decisión: relacional vs no relacional (con justificación)
   ├── Entidades principales y sus atributos
   ├── Relaciones entre entidades
   ├── Índices, constraints, integridad referencial
   ├── Estrategia multi-tenant (si aplica)
   └── ADR de decisiones de modelado
3. devils-advocate → challenge al modelo:
   ├── ¿Escala al volumen esperado en 12 meses?
   ├── ¿Las relaciones cubren todos los casos de uso?
   ├── ¿Hay sobre-normalización o sub-normalización?
   ├── ¿Los índices cubren las consultas más frecuentes?
   └── ¿Es la base de datos correcta para este proyecto?
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
- **Migraciones iniciales** listas para aplicar.
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

1. **Este workflow va PRIMERO.** Ningún agente de frontend, backend, o UX se activa antes.
2. **Opus o nada.** El `data-architect` corre con Opus. No se negocia.
3. **Sin modelo aprobado, no hay desarrollo.** Si el modelo no pasó el gate, no se escribe una línea de código.
4. **La decisión relacional vs no relacional se documenta.** No se elige "por costumbre".
5. **El modelo se versiona.** Migraciones en `supabase/migrations/` desde el día 1.

---

## Anti-patterns

- ❌ "Arranquemos con el frontend y después vemos la base."
- ❌ "Usemos NoSQL porque está de moda."
- ❌ "Modelemos sobre la marcha."
- ❌ "El ORM resuelve solo."
- ❌ "No necesitamos índices hasta que haya tráfico."
- ❌ "Deleguemos el modelo de datos al backend-architect sin revisión dedicada."

---

**Workflow 0** · Fundacional · ⚡
