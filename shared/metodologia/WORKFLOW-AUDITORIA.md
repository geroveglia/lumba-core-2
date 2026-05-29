# WORKFLOW DE AUDITORÍA — LUMBA CORE

> **Versión:** v1.0 (Lumba Core)
> **Tono:** Manual operativo.
> **Propósito:** definir el corazón del sistema — la auditoría antes de entregar al cliente.
> **Última actualización:** 23 de mayo de 2026.

---

## 1. POR QUÉ EXISTE ESTE WORKFLOW

Este workflow es la materialización del **Principio 0** de Lumba Core:

> *Lumba Core es auditoría antes de entrega. No es velocidad de producción.*

El **dolor #1** de Lumba es la corrección posterior. Este workflow ataca ese dolor directamente.

Si este workflow no funciona bien, Lumba Core no funciona. Punto.

---

## 2. CUÁNDO SE ACTIVA

Antes de que **CUALQUIER** entregable salga al cliente, se ejecuta este workflow.

Aplica a:

- Pieza de diseño (logo, banner, carrusel, etc.).
- Documento estratégico (plan, propuesta, brief).
- Copy o contenido escrito (post, email, anuncio).
- Reporte (mensual, de campaña, análisis).
- Definición funcional o documentación técnica.
- Diseño UX/UI.
- Código deployado a staging o producción.
- Cualquier presentación al cliente.

**Sin excepciones.**

---

## 3. EL WORKFLOW EN 6 PASOS

```
┌──────────────────────────────────────────┐
│  PASO 1: PRODUCCIÓN                      │
│  Agente especializado genera entregable  │
└──────────────────┬───────────────────────┘
                   │
                   ▼
┌──────────────────────────────────────────┐
│  PASO 2: AUTO-CHECK DEL AGENTE           │
│  El propio agente verifica brief         │
└──────────────────┬───────────────────────┘
                   │
                   ▼
┌──────────────────────────────────────────┐
│  PASO 3: AUDITORÍA POR AGENTE AUDITOR    │
│  Auditor de red revisa contra checklist  │
└──────────────────┬───────────────────────┘
                   │
                   ▼
┌──────────────────────────────────────────┐
│  PASO 4: DEVIL'S ADVOCATE (si crítico)   │
│  Solo si es entregable estratégico       │
└──────────────────┬───────────────────────┘
                   │
                   ▼
┌──────────────────────────────────────────┐
│  PASO 5: REVISIÓN HUMANA                 │
│  PM o socio aprueba                      │
└──────────────────┬───────────────────────┘
                   │
                   ▼
┌──────────────────────────────────────────┐
│  PASO 6: ENTREGA AL CLIENTE              │
│  Salida con tracking                     │
└──────────────────────────────────────────┘
```

---

## 4. PASO 1 — PRODUCCIÓN

### Qué pasa

El agente especializado (UX Designer, Copywriter, Backend Architect, etc.) produce el entregable.

### Requisito previo

Brief obsesivo completo (ver `WORKFLOW-BRIEF-OBSESIVO.md`). Sin brief completo, este paso NO arranca.

### Output

Entregable + JSON estructurado con:

```json
{
  "deliverable_type": "string",
  "agent": "string",
  "brief_id": "string",
  "client": "string",
  "project": "string",
  "version": "1.0",
  "files": ["paths"],
  "self_check": {
    "objective_met": true/false,
    "audience_aligned": true/false,
    "restrictions_respected": true/false,
    "brief_compliance": "completo|parcial"
  },
  "notes_for_auditor": "string"
}
```

---

## 5. PASO 2 — AUTO-CHECK DEL AGENTE

### Qué pasa

Antes de mandar el entregable a auditoría, el agente productor hace **autoverificación contra el brief**.

### Checklist mínimo (todos los entregables)

- [ ] ¿Cumple el objetivo del brief?
- [ ] ¿Habla a la audiencia correcta?
- [ ] ¿Respeta restricciones declaradas?
- [ ] ¿Cumple criterios de éxito?
- [ ] ¿Coherente con memoria del cliente?

### Resultado

- **Si todos ✅:** avanza a Paso 3.
- **Si algún ❌:** vuelve a producción con motivo registrado.

### Por qué importa este paso

Es el **primer filtro barato**. Detecta errores obvios sin gastar al auditor.

---

## 6. PASO 3 — AUDITORÍA POR AGENTE AUDITOR

### Quién audita

Según red:

- **Core-Brand:** `brand-auditor` (Opus 4.7).
- **Core-Marketing:** `marketing-auditor` (Opus 4.7).
- **Core-Product:** `product-auditor` (Opus 4.7).

### Qué hace

Ejecuta el **checklist de auditoría específico** de la red (definidos en cada `METODO-*.md`).

### Resultados posibles

```json
{
  "audit_result": "passed|failed|partial",
  "checklist_results": {...},
  "critical_findings": [...],
  "minor_findings": [...],
  "recommendation": "approve|fix_and_resubmit|reject"
}
```

### Si `failed` o `partial`

- Entregable vuelve a producción.
- Findings se anotan en `/proyectos/{nombre}/audits/`.
- Agente productor refina y reenvía.
- **Máximo 3 ciclos.** Si después de 3 ciclos no pasa, escalada al PM o Founder.

### Si `passed`

- Avanza a Paso 4 (si es crítico) o Paso 5 (si no).

---

## 7. PASO 4 — DEVIL'S ADVOCATE (solo entregables críticos)

### Cuándo aplica

Solo para entregables **estratégicos o de alto riesgo**:

- Propuestas comerciales nuevas.
- Cambios de estrategia de marca.
- Lanzamientos de campaña.
- Arquitectura técnica de proyecto nuevo.
- ADRs (Architecture Decision Records).
- Definiciones funcionales completas.

NO aplica para:

- Copys diarios para redes.
- Banners menores.
- Bugfixes simples.
- Reportes rutinarios.

### Qué hace

Devil's Advocate (Opus) ejecuta su checklist universal:

```yaml
- ¿Contradice antiproducto de Lumba?
- ¿Resuelve el dolor central del proyecto?
- ¿Hay supuestos no validados?
- ¿Qué pasa si X, Y, Z fallan?
- ¿Escala?
- ¿Costo real estimado?
- ¿Riesgo de seguridad aplica?
- ¿Alternativas obvias descartadas?
- ¿Coherente con MEMORIA del proyecto?
- ¿Coherente con principios de Lumba Core?
```

### Resultados posibles

- `proceed` — Avanza a Paso 5.
- `resolve_before_proceed` — Hay que resolver hallazgos antes de seguir.
- `reject` — Riesgo crítico. Vuelve a producción con cambios mayores.

### Poder de veto

Si Devil's Advocate dice `reject` con `blocking: true`, **el entregable no avanza** hasta que el Founder decida sobrescribir manualmente (registrado como decisión consciente).

---

## 8. PASO 5 — REVISIÓN HUMANA

### Quién revisa

Depende del tipo:

| Tipo | Aprobador |
|---|---|
| Entregable rutinario | PM del proyecto |
| Entregable estratégico | Socio del área (Esteban/Hernán/Martín) |
| Cambio mayor de proyecto | Esteban + uno de los otros socios |
| Decisión que afecta a múltiples clientes | Los 3 socios |

### Qué revisa

- Calidad final.
- Adecuación al cliente real (más allá de los checks automáticos).
- Tono, sensibilidad, contexto.
- Cualquier cosa que la AI no puede juzgar bien.

### Resultados posibles

- ✅ **Aprobado** — Avanza a Paso 6.
- ⚠️ **Aprobado con cambios menores** — Se aplican y avanza.
- ❌ **Rechazado** — Vuelve a producción con feedback específico.

### Si se rechaza después de pasar auditoría AI

Es una señal importante. Se registra en `/proyectos/{nombre}/audit-misses/` con análisis: ¿por qué el auditor lo pasó y el humano lo rechazó? Sirve para mejorar el checklist del auditor.

---

## 9. PASO 6 — ENTREGA AL CLIENTE

### Qué pasa

Entregable sale al cliente con:

- Documento principal.
- Resumen ejecutivo (opcional pero recomendado).
- Versión y fecha.
- Punto de contacto para feedback.

### Tracking

Se registra en `/proyectos/{nombre}/entregas/`:

```json
{
  "delivery_id": "string",
  "deliverable_type": "string",
  "client": "string",
  "delivered_at": "ISO-8601",
  "delivered_by": "string (humano)",
  "version": "string",
  "files": ["paths"],
  "audit_history": [...],
  "expected_feedback_by": "ISO-8601"
}
```

### Tracking post-entrega

Se registra si:

- Cliente aprobó sin cambios → ✅ Suma a la métrica norte.
- Cliente pidió cambios menores → ⚠️ Análisis: ¿por qué no se detectó antes?
- Cliente pidió cambios mayores → ❌ Falla del sistema. Post-mortem obligatorio.

---

## 10. CICLOS DE MEJORA

### Métrica clave

> **% de entregas que no requieren corrección post-entrega.**

### Revisión semanal

Cada lunes, el PM genera reporte:

- Cuántas entregas hubo.
- Cuántas pasaron sin corrección.
- Cuántas necesitaron cambios menores.
- Cuántas tuvieron rechazo mayor.

### Análisis de fallos

Si una entrega tuvo rechazo mayor del cliente:

1. Identificar en qué paso falló (auditor lo dejó pasar, humano no lo vio, etc.).
2. Documentar en `/lumba-core/lessons-learned/`.
3. Actualizar checklist del auditor si corresponde.
4. Actualizar memoria del cliente si corresponde.

---

## 11. EXCEPCIONES Y BYPASS

Hay situaciones donde el workflow completo no aplica:

### Urgencia justificada

Cliente pide algo crítico en <2 horas. En este caso:

- Producción + auto-check (Pasos 1-2) obligatorios.
- Auditoría (Paso 3) puede saltarse.
- Revisión humana (Paso 5) obligatoria.
- Registrar en `/proyectos/{nombre}/bypasses/` con motivo.

**Si los bypasses son >5% del total, hay un problema operativo.**

### Iteración interna

Si es un entregable intermedio que NO va al cliente, no aplica este workflow.

Aplica un workflow más liviano: agente produce → revisión cruzada con par humano → siguiente paso.

---

## 12. MÉTRICAS DEL WORKFLOW

| Métrica | Umbral saludable |
|---|---|
| % de entregas que pasaron por workflow completo | >95% |
| % de entregas que pasaron auditor al primer intento | >70% |
| Cantidad promedio de ciclos producción↔auditor | <2 |
| % de bypasses por urgencia | <5% |
| % de entregas aprobadas por humano al primer intento | >85% |
| % de entregas aceptadas por cliente sin corrección | **>55% (3 meses) → >80% (12 meses)** |

---

## 13. CHECKLIST DE VALIDACIÓN PARA ESTEBAN

- [ ] El workflow de 6 pasos es operable.
- [ ] La distinción "entregable crítico vs rutinario" es clara.
- [ ] El poder de veto del Devil's Advocate se acepta.
- [ ] La gestión de excepciones (bypass) es razonable.
- [ ] Las métricas del workflow son medibles.
- [ ] El Paso 5 (revisión humana) tiene aprobadores claros por tipo.

---

**FIN WORKFLOW DE AUDITORÍA**
