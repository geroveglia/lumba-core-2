# MEMORIA COMPARTIDA — LUMBA CORE

> **Versión:** v1.0 (Lumba Core)
> **Tono:** Manual técnico.
> **Propósito:** definir cómo los agentes gestionan memoria compartida sin pisarse.
> **Última actualización:** 23 de mayo de 2026.

---

## 1. EL PROBLEMA QUE RESOLVEMOS

En un sistema multi-agente, si dos agentes acceden a la misma información en momentos distintos y la modifican sin coordinación, se producen **estados inconsistentes**.

Ejemplo:

- Agente A modifica especificación de feature X.
- Agente B trabaja con la versión anterior sin saberlo.
- Se generan dos versiones contradictorias del mismo entregable.

Este es el principal *failure mode* documentado en multi-agent systems (MAST taxonomy, NeurIPS 2025).

Lumba Core resuelve esto con un **sistema de memoria en 3 capas + protocolos estrictos de acceso**.

---

## 2. LAS 3 CAPAS DE MEMORIA

```
┌──────────────────────────────────────────────────┐
│  CAPA 1 — MEMORIA INMUTABLE                      │
│  Cambia solo en releases versionadas             │
├──────────────────────────────────────────────────┤
│  Manifiesto Lumba                                │
│  Principios Lumba Core                           │
│  Métricas de éxito                               │
│  Procesos universales (8 pasos)                  │
│  Agentes universales                             │
│  Definiciones de redes                           │
└──────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────┐
│  CAPA 2 — MEMORIA DE PROYECTO/CLIENTE            │
│  Cambia con aprobación del Founder               │
├──────────────────────────────────────────────────┤
│  MEMORIA-CLIENTE.md por cliente                  │
│  MEMORIA-PROYECTO.md por proyecto                │
│  ADRs (Architecture Decision Records)            │
│  Decisiones registradas                          │
│  Briefs aprobados                                │
│  Versiones aprobadas de entregables              │
└──────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────┐
│  CAPA 3 — MEMORIA EFÍMERA                        │
│  Existe solo durante la invocación               │
├──────────────────────────────────────────────────┤
│  Context window de cada subagent                 │
│  Variables temporales                            │
│  Logs de invocación (se archivan al cerrar)      │
│  Borradores intermedios                          │
└──────────────────────────────────────────────────┘
```

---

## 3. CAPA 1 — MEMORIA INMUTABLE

### Qué contiene

- `MANIFIESTO-LUMBA.md`
- `PRINCIPIOS-LUMBA-CORE.md`
- `METRICAS-DE-EXITO.md`
- `PROCESO-8-PASOS.md`
- `AGENTES-UNIVERSALES.md`
- `METODO-BRANDING.md`, `METODO-MARKETING.md`, `METODO-PRODUCT.md`
- Skills oficiales versionados.

### Reglas de acceso

- **Lectura:** todos los agentes pueden leer.
- **Escritura:** solo el Founder con aprobación explícita.
- Cualquier cambio queda registrado en git con commit firmado.
- Cambios mayores requieren versionado (v1.0 → v1.1).

### Frecuencia de cambio

Trimestral o ante cambios estratégicos. **No es memoria operativa**, es constitución.

---

## 4. CAPA 2 — MEMORIA DE PROYECTO/CLIENTE

### Estructura por cliente

```
/clientes/{nombre-cliente}/
  MEMORIA-CLIENTE.md          ← Info general del cliente
  /branding/
    MEMORIA-MARCA.md          ← Específico de branding
  /marketing/
    MEMORIA-MARKETING.md      ← Específico de marketing
  /producto/
    MEMORIA-PRODUCTO.md       ← Específico de producto
  /historico/
    decisiones/               ← ADRs históricos
    versiones/                ← Versiones aprobadas de entregables
```

### Estructura por proyecto

```
/proyectos/{nombre-proyecto}/
  MEMORIA-PROYECTO.md         ← Memoria del proyecto específico
  /decisiones/                ← ADRs del proyecto
    ADR-001.md
    ADR-002.md
  /sprints/                   ← Sprints del proyecto
  /handoffs/                  ← JSON entre agentes
  /audits/                    ← Reportes del Devil's Advocate
```

### MEMORIA-CLIENTE.md mínimo

```markdown
# Cliente: {nombre}

## Información general
- Razón social
- Industria
- Mercado objetivo
- Decisores
- Canales de comunicación

## Servicios activos
- Branding / Marketing / Producto (los que aplique)

## Criterios aprobados
- Posicionamiento
- Tono de voz
- Restricciones operativas

## Decisiones rechazadas
- Lista con motivo

## Aprendizajes históricos
- Lecciones de proyectos anteriores

## Última actualización
- Fecha
- Por quién (humano)
```

### Reglas de acceso

- **Lectura:** todos los agentes que trabajan en el cliente.
- **Escritura:** solo `project-manager` y `Founder`.
- **Drafts:** otros agentes pueden proponer cambios en `/drafts/{fecha}.md`.
- **Aprobación:** Founder consolida drafts a memoria principal en revisión semanal.

### Frecuencia de actualización

Semanal o ante decisiones importantes.

---

## 5. CAPA 3 — MEMORIA EFÍMERA

### Qué contiene

- Context window de cada agente durante una invocación.
- Variables temporales del Orchestrator.
- Borradores intermedios entre hand-offs.
- Logs de invocación.

### Reglas

- Vive solo durante la sesión del agente.
- Se archiva al cerrar invocación en `/logs/sesion-{fecha-hora}.json`.
- Se borra de context window una vez archivada.
- **Nada efímero puede convertirse en oficial sin pasar por aprobación.**

### Tamaño máximo recomendado

- Por agente: <50K tokens en context window.
- Si supera, se hace **context reset con structured handoff** a un agente fresco.

---

## 6. PROTOCOLO DE HAND-OFF ENTRE AGENTES

Cuando un agente termina su tarea y pasa información a otro agente.

### Reglas

1. El hand-off **siempre es JSON estructurado**, nunca texto libre.
2. El JSON incluye un `version_hash` de las fuentes consultadas.
3. El agente receptor verifica `version_hash` antes de operar.
4. Si las fuentes cambiaron desde el hand-off, el receptor pide refresh.

### Schema base de hand-off

```json
{
  "from_agent": "product-owner",
  "to_agent": "ux-designer",
  "project": "minuta",
  "phase": "C-funcional",
  "timestamp": "2026-05-23T14:32:00Z",
  "version_hash": "sha256:abc123...",
  "sources_consulted": [
    {"path": "/proyectos/minuta/MEMORIA-PROYECTO.md", "hash": "..."},
    {"path": "/proyectos/minuta/docs/funcional/spec-v3.md", "hash": "..."}
  ],
  "output_type": "feature_spec",
  "content": {
    "feature_name": "Backlog colaborativo",
    "decisions_made": [...],
    "assumptions": [...],
    "open_questions": [...]
  },
  "ready_for_review": true,
  "next_required_action": "Generar wireframes según especificación"
}
```

### Almacenamiento

Cada hand-off se guarda en `/proyectos/{nombre}/handoffs/{fecha}-{from}-{to}.json` para trazabilidad.

---

## 7. PROTOCOLO DE ACTUALIZACIÓN DE MEMORIA

### Para Capa 1 (Inmutable)

1. Founder identifica necesidad de cambio.
2. Founder crea propuesta en `/proposals/{fecha}-{tema}.md`.
3. Devil's Advocate audita la propuesta.
4. Founder aprueba o rechaza.
5. Si aprueba, actualiza archivo + commit en git con mensaje claro.
6. Versiona el documento (incrementa versión).

### Para Capa 2 (Proyecto/Cliente)

1. Agente detecta decisión nueva o cambio importante.
2. Agente NO modifica memoria directamente.
3. Agente escribe propuesta en `/proyectos/{nombre}/drafts/{fecha}.md`.
4. Founder o Project Manager revisa drafts (cadencia semanal).
5. Si aprueba, consolida a memoria principal.
6. Commit en git con mensaje claro.

### Para Capa 3 (Efímera)

No requiere protocolo formal — se archiva automáticamente al cerrar invocación.

---

## 8. CONFLICTOS DE MEMORIA — RESOLUCIÓN

Si dos agentes acceden a la misma memoria simultáneamente:

### Lectura simultánea
- Permitida sin restricciones.

### Escritura simultánea
- Solo el Founder o agentes con `write_paths` declarados pueden escribir.
- Locking optimista: si dos escrituras chocan, gana la primera y la segunda recibe error de "stale read".
- El agente con stale read debe releer y reintentar.

### Memoria desactualizada en context
- Si un agente operó con `version_hash` antiguo, su output queda marcado como `requires_review`.
- El Orchestrator no propaga ese output hasta que se revalide.

---

## 9. RETENCIÓN Y BACKUP

| Capa | Retención | Backup |
|---|---|---|
| Capa 1 | Para siempre | Git + backup semanal a S3/R2 |
| Capa 2 | Para siempre mientras cliente esté activo + 1 año post-baja | Git + backup semanal |
| Capa 3 | Logs archivados se mantienen 90 días, después se borran | Backup mensual de logs críticos |

### Sensibilidad de datos

- Datos de clientes en Capa 2 nunca se mandan a APIs externas sin permiso explícito.
- Capa 3 (logs) puede contener fragmentos de info sensible — backup encriptado.
- Cualquier acceso a la base de datos de clientes requiere doble confirmación.

`[INFERENCIA — basada en respuesta del Bloque 9 (base de clientes sensible sin NDAs hoy). Validar si requiere más estricto.]`

---

## 10. MEMORIA Y MULTI-TENANCY

Lumba Core opera con múltiples clientes simultáneamente. La memoria está aislada por cliente:

- Un agente trabajando para RUS no debería tener acceso a memoria de BeWell.
- El aislamiento se garantiza vía rutas de archivo (`/clientes/RUS/...` vs `/clientes/BeWell/...`).
- Los agentes declaran en su frontmatter qué cliente pueden acceder por invocación.

Cuando Lumba Core escale a 50 personas + múltiples proyectos, este aislamiento será crítico.

---

## 11. ANTI-PATTERNS DE MEMORIA

Cosas que NO hacemos:

- ❌ Dejar que cualquier agente escriba en cualquier memoria.
- ❌ Memoria global única (todos contra todos).
- ❌ Hand-offs en texto libre.
- ❌ Modificar memoria sin commit en git.
- ❌ Dejar context windows infinitos (truncar y archivar).
- ❌ Borrar logs sin backup.
- ❌ Confiar en memoria de Capa 3 más allá de la invocación.

---

## 12. CHECKLIST DE VALIDACIÓN PARA ESTEBAN

- [ ] Las 3 capas tienen sentido operativo.
- [ ] Las reglas de acceso son operables.
- [ ] El protocolo de hand-off con JSON Schema es viable.
- [ ] La retención y backup cubren lo crítico.
- [ ] Multi-tenancy de memoria es claro.
- [ ] Las marcas `[INFERENCIA — Validar]` están resueltas.

---

**FIN MEMORIA COMPARTIDA**
