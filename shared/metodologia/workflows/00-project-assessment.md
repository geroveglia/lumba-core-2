# WORKFLOW 00 — PROJECT ASSESSMENT

> **Versión:** v1.0
> **Propósito:** Flujo operativo paso a paso que Jarvis ejecuta al crear un proyecto nuevo.
> **Última actualización:** 2 de junio de 2026.

---

## 1. PROPÓSITO

Este workflow define exactamente qué hace Jarvis cuando Gero dice:
- `nuevo proyecto {nombre}`
- O describe un proyecto nuevo sin usar el comando explícito.

Es el **primer workflow obligatorio** de todo proyecto. Sin completarlo, ninguna otra fase puede comenzar.

---

## 2. TRIGGER

- Gero dice `nuevo proyecto {nombre}` por Telegram.
- Gero describe un proyecto nuevo ("Hay un cliente que necesita...", "Arrancamos con...").
- Otro agente detecta que se necesita un proyecto nuevo.

---

## 3. FLUJO PASO A PASO

```
Paso 1: Identificación
         ↓
Paso 2: Vinculación con cliente
         ↓
Paso 3: Clasificación Tipo (A/B/C)
         ↓
Paso 4: Clasificación Complejidad (S/M/L/XL)
         ↓
Paso 5: Presentación y confirmación
         ↓
Paso 6: Asignación de squad
         ↓
Paso 7: Inicialización del proyecto
         ↓
Paso 8: Siguiente fase
```

---

## 4. DETALLE DE CADA PASO

### Paso 1 — Identificación del proyecto

Jarvis extrae del mensaje de Gero:

| Campo | Obligatorio | Ejemplo |
|---|---|---|
| **Nombre del proyecto** | ✅ | "TiendaX" |
| **Slug** (kebab-case) | ✅ (generado) | "tiendax" |
| **Descripción breve** | ✅ | "Ecommerce de ropa desde cero" |
| **Cliente asociado** | ✅ (puede ser null) | "RUS" |

**Si falta info**, Jarvis pregunta a Gero explícitamente. No infiere.

---

### Paso 2 — Vinculación con cliente

Jarvis verifica si el cliente existe en `/clientes/`:

| Caso | Acción |
|---|---|
| El slug del cliente existe en `/clientes/{slug}/` | Vincular. Cargar `MEMORIA-CLIENTE.md`. |
| El slug NO existe | Preguntar a Gero: "¿Es un cliente nuevo? ¿Creo la carpeta en `/clientes/{slug}/`?" |
| No hay cliente (proyecto interno) | Registrar `client: null` en state.json. |
| Cliente nuevo confirmado | Crear `/clientes/{slug}/` + `MEMORIA-CLIENTE.md` desde template en `/knowledge/templates/client-memory-template.md`. |

**Regla:** Un proyecto puede NO tener cliente (ej: proyecto interno de Lumba). En ese caso `client: null`.

---

### Paso 3 — Clasificación Tipo (A/B/C)

Jarvis evalúa el tipo de proyecto según estas señales:

| Tipo | Señales | Preguntas a Gero |
|---|---|---|
| **A — Greenfield** | No existe repo, no hay código, no hay stack previo | "¿Este proyecto es desde cero? ¿Hay algo existente?" |
| **B — Brownfield** | Hay repo con commits, hay stack definido, hay deuda técnica | "¿Hay código existente? ¿Hay un repo? ¿Cuántos commits?" |
| **C — Parcial** | Hay Figma pero no código, hay docs pero no implementación | "¿Hay diseños, specs, o algo a medio hacer?" |

**Casos híbridos** (resolver según MATRIZ-SQUADS.md §2):
- Repo con <10 commits sustanciales → **A** (Greenfield)
- Figma + docs sin código → **C** (Parcial)
- MVP funcionando pero se reescribe → **B** (Brownfield)
- Código legacy + specs nuevas → **B** (Brownfield)

**Si Jarvis no puede clasificar**, escala a Gero: "No estoy seguro si es A, B o C. ¿Podrías clarificar?"

---

### Paso 4 — Clasificación Complejidad (S/M/L/XL)

Jarvis hace las **6 preguntas del checklist** de MATRIZ-SQUADS.md §3, una por una:

```
"Voy a hacerte 6 preguntas rápidas para determinar la complejidad del proyecto."

1. "¿Cuántas entidades de negocio tiene? (ej: productos, usuarios, órdenes...)"
   → 1 = 0pts | 2-3 = 1pt | 4-8 = 2pts | 9+ = 3pts

2. "¿Cuántos roles de usuario? (ej: admin, user, editor...)"
   → 1 = 0pts | 2-3 = 1pt | 4-6 = 2pts | Multi-tenant = 3pts

3. "¿Qué tipo de autenticación necesita?"
   → Sin auth/simple = 0pts | OAuth/JWT = 1pt | 2FA/SSO/RBAC = 2pts | Multi-tenant+compliance = 3pts

4. "¿Cuántas integraciones externas? (ej: Mercado Pago, APIs de terceros...)"
   → 0 = 0pts | 1-2 = 1pt | 3-5 = 2pts | 6+ o ERPs = 3pts

5. "¿Cuántos usuarios concurrentes se esperan?"
   → <100 = 0pts | 100-1K = 1pt | 1K-100K = 2pts | 100K+ = 3pts

6. "¿Necesita IA o features no estándar?"
   → No = 0pts | Feature simple = 1pt | IA en flujo core = 2pts | Múltiples modelos = 3pts
```

**Tabla de puntuación:**

| Puntaje | Complejidad | Ejemplos |
|---|---|---|
| 0-2 | **S** (Small) | Landing, WordPress, ecommerce simple |
| 3-5 | **M** (Medium) | MVP, SaaS chico, portal de clientes |
| 6-9 | **L** (Large) | ERP, marketplace, fintech |
| 10-18 | **XL** (Extra Large) | Multiempresa, microservicios, compliance |

**Si Gero no sabe alguna respuesta**, Jarvis registra la duda como `assumption` y usa el valor más conservador (más bajo).

---

### Paso 5 — Presentación y confirmación

Jarvis presenta a Gero un resumen para confirmar:

```
📊 Clasificación del proyecto:

Proyecto: TiendaX
Cliente: RUS
Tipo: A (Greenfield)
Complejidad: M (5 puntos)

Detalle del puntaje:
  - Entidades: 2-3 (1pt)
  - Roles: 2-3 (1pt)
  - Auth: OAuth/JWT (1pt)
  - Integraciones: 1-2 (1pt)
  - Escala: 100-1K (1pt)
  - IA: No (0pts)

Squad asignado (MATRIZ A+M):
  PM, Research Agent, Analyst Functional, Backend Architect,
  QA Engineer, Product Owner, UX Designer, UI Designer,
  Frontend Architect (9 agentes)

¿Confirmás?
```

**Gero puede:**
- **Confirmar** → Paso 6
- **Ajustar clasificación** → Jarvis recalcula squad según la nueva clasificación
- **Pedir squad distinto** → Se registra como override. La matriz se mantiene pero Gero tiene última palabra.

---

### Paso 6 — Asignación de squad

Jarvis consulta `shared/metodologia/MATRIZ-SQUADS.md` §4 con el Tipo × Complejidad confirmados.

**Reglas:**
- El squad se toma textual de la matriz. No se inventan agentes.
- Si Gero pidió un override, se registra en `state.json` como nota.
- Si la matriz no cubre el caso → escalar a Gero.

---

### Paso 7 — Inicialización del proyecto

Jarvis crea la estructura del proyecto:

```
/proyectos/{slug}/
├── state.json                  ← Generado desde project-state-schema.json
├── MEMORIA-PROYECTO.md         ← Generado desde /knowledge/templates/project-memory-template.md
├── outputs/                    ← Vacío, aquí van los outputs de cada fase
├── approvals/                  ← Vacío, aquí van los registros de aprobación humana
├── handoffs/                   ← Vacío, aquí van los JSON de comunicación entre agentes
├── overrides/                  ← Vacío, aquí van los overrides del Devil's Advocate
└── drafts/                     ← Vacío, aquí van las propuestas de cambio a memoria
```

**El `state.json` inicial debe tener:**
- `schema_version`: "2.1"
- `project`: slug
- `project_name`: nombre legible
- `client`: slug del cliente o null
- `project_type`: tipo confirmado
- `complexity`: complejidad confirmada
- `complexity_score`: puntaje calculado
- `squad`: array de agentes asignados
- `current_phase`: "BRIEF" (la siguiente fase)
- Todas las fases en `pending` excepto `PROJECT_ASSESSMENT` en `completed`
- Budget con límite default de 50 USD

**El `MEMORIA-PROYECTO.md` inicial debe tener:**
- Nombre del proyecto
- Cliente vinculado
- Clasificación (tipo + complejidad)
- Squad asignado
- Fecha de creación
- Secciones vacías para decisiones, aprendizajes, restricciones

---

### Paso 8 — Siguiente fase

Jarvis notifica a Gero:

```
✅ Proyecto {nombre} creado.
📁 Estructura: /proyectos/{slug}/
🎯 Próxima fase: BRIEF
👥 Squad: {lista de agentes}

¿Arrancamos con el brief?
```

Si Gero confirma, Jarvis avanza a la fase BRIEF (Workflow 01 — Brief Obsesivo, definido en `shared/metodologia/WORKFLOW-BRIEF-OBSESIVO.md`).

---

## 5. ERRORES Y RECUPERACIÓN

| Error | Qué hace Jarvis |
|---|---|
| Gero cancela a mitad del assessment | Registrar como `PROJECT_ASSESSMENT: skipped`. No crear carpeta. |
| No se puede determinar tipo | Escalar a Gero con las opciones. |
| La matriz no tiene match | Escalar a Gero: "Este caso no está en la matriz." |
| El cliente no existe y Gero no quiere crearlo | Proyecto sin cliente (`client: null`). |
| Gero quiere un squad distinto al de la matriz | Registrar override. Usar squad de Gero. |

---

## 6. OUTPUT DE ESTE WORKFLOW

Al completar Workflow 00, debe existir:

| Output | Ubicación |
|---|---|
| Carpeta del proyecto | `/proyectos/{slug}/` |
| State.json inicializado | `/proyectos/{slug}/state.json` |
| Memoria del proyecto | `/proyectos/{slug}/MEMORIA-PROYECTO.md` |
| Carpeta del cliente (si no existía) | `/clientes/{slug}/` |
| Fase PROJECT_ASSESSMENT | `completed` en state.json |

---

## 7. ANTI-PATTERNS

- ❌ Crear el proyecto sin preguntar las 6 preguntas de complejidad.
- ❌ Inferir el tipo sin validar con Gero.
- ❌ Saltarse la confirmación ("¿Confirmás?").
- ❌ Crear la carpeta del proyecto antes de la confirmación.
- ❌ Asignar un squad que no está en la matriz sin registrar override.
- ❌ Empezar el brief sin haber completado este workflow.

---

**FIN DE WORKFLOW 00**
