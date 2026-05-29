# COSTOS Y PRESUPUESTO DE AGENTES — LUMBA CORE

> **Versión:** v1.0 (Lumba Core)
> **Tono:** Manual operativo.
> **Propósito:** controlar el costo real de operar Lumba Core.
> **Última actualización:** 23 de mayo de 2026.

---

## 1. POR QUÉ MEDIR COSTOS

Los agentes AI cuestan tokens. Los tokens cuestan plata.

Sin control de costos, una operación normal puede pasar de USD 50/mes a USD 500/mes sin que nadie se entere. Y eso pasa hasta que llega la factura.

Lumba Core mide costos desde día 1.

---

## 2. ASIGNACIÓN DE MODELOS POR AGENTE

| Agente | Modelo | Costo input | Costo output | Justificación |
|---|---|---|---|---|
| Devil's Advocate | **Opus 4.7** | $$$ | $$$$$ | Razonamiento profundo no negociable |
| Product Owner, UX, Backend, Data, QA | Sonnet 4.6 | $$ | $$$ | Equilibrio costo/calidad |
| Marketing Strategist, Content Strategist, Brand Strategist | Sonnet 4.6 | $$ | $$$ | Razonamiento estratégico |
| Copywriter, Brand Voice Writer, Scriptwriter | Sonnet 4.6 | $$ | $$$ | Calidad creativa |
| Orchestrator | Sonnet 4.6 | $$ | $$$ | Decisiones de enrutamiento |
| Project Manager, DevOps, Campaign Orchestrator | **Haiku 4.5** | $ | $$ | Alta frecuencia, predecible |
| Brandbook Builder | **Haiku 4.5** | $ | $$ | Generación estructurada |

`[INFERENCIA — Asignación basada en complejidad cognitiva. Validar tras 30 días de operación real.]`

---

## 3. REGLAS DE ASIGNACIÓN

### Regla 1 — Haiku para alta frecuencia

Si un agente se invoca >20 veces/día y la tarea es repetitiva/estructurada, usar Haiku.

### Regla 2 — Sonnet como default

La mayoría de agentes usan Sonnet. Es el sweet spot.

### Regla 3 — Opus solo cuando es indispensable

Devil's Advocate sí. Decisiones críticas que requieren razonamiento de élite.

**Nunca usar Opus para CRUD, generación estructurada, o tareas que Sonnet hace bien.**

### Regla 4 — Auditores en Opus

Los agentes auditores (brand-auditor, marketing-auditor, product-auditor) corren en Opus porque su trabajo es detectar problemas sutiles.

Total auditores en Opus: 4 (3 redes + Devil's Advocate).

---

## 4. COSTO ESTIMADO MENSUAL

Asumiendo 1 proyecto activo (Minuta) en operación normal:

### Agentes universales

| Agente | Modelo | Invocaciones/mes | Tokens promedio | USD/mes |
|---|---|---|---|---|
| Orchestrator | Sonnet | 300 | 5K in + 1K out | 15 |
| Project Manager | Haiku | 200 | 3K in + 1K out | 5 |
| Devil's Advocate | Opus | 20 | 10K in + 5K out | 25 |
| Research Agent | Sonnet | 30 | 5K in + 2K out | 6 |
| **Subtotal universales** | | | | **~USD 51** |

### Core-Product (operando Minuta)

| Agente | Modelo | Invocaciones/mes | USD/mes |
|---|---|---|---|
| Product Owner | Sonnet | 60 | 14 |
| Analyst Functional | Sonnet | 40 | 10 |
| UX Designer | Sonnet | 80 | 18 |
| UI Designer | Sonnet | 60 | 14 |
| Frontend Architect | Sonnet | 100 | 22 |
| Backend Architect | Sonnet | 100 | 22 |
| Data Architect | Sonnet | 40 | 11 |
| DevOps Engineer | Haiku | 150 | 4 |
| QA Engineer | Sonnet | 80 | 15 |
| Code Reviewer | Sonnet | 60 | 12 |
| Product Auditor | Opus | 15 | 18 |
| **Subtotal Core-Product** | | | **~USD 160** |

### Total Lumba Core (operando solo Minuta)

```
Universales:        USD 51
Core-Product:       USD 160
─────────────────
TOTAL ESTIMADO:     USD ~210/mes
```

Para operar las 3 redes simultáneamente con varios proyectos:
- **Estimado:** USD 400-600/mes.

`[INFERENCIA — Estimaciones basadas en pricing 2026 y patrones típicos. Refinar tras piloto Minuta.]`

---

## 5. PILOTO DE MEDICIÓN REAL — MINUTA COMO BASELINE

Como no tenemos data histórica, **usamos Minuta como piloto de medición**.

### Plan piloto (30 días)

1. **Día 1-7:** Instrumentar tracking. Cada invocación de agente registra:
   - Agente
   - Modelo
   - Tokens input
   - Tokens output
   - Costo USD
   - Tarea
   - Timestamp

2. **Día 8-30:** Operación normal de Minuta con tracking activo.

3. **Día 30:** Generar reporte:
   - Costo total real.
   - Costo por agente.
   - Top 5 agentes más caros.
   - Invocaciones que más consumieron.
   - Comparación contra estimación.

4. **Día 31:** Decidir budget mensual definitivo para Lumba Core.

---

## 6. BUDGET RECOMENDADO

Hasta tener datos reales del piloto:

| Fase | Budget mensual |
|---|---|
| Mes 1 (piloto Minuta) | USD 300 (con margen) |
| Mes 2-3 (Minuta + ajustes) | USD 250 |
| Mes 4-6 (Minuta + Core-Marketing) | USD 400 |
| Mes 7-12 (3 redes activas) | USD 500-700 |

`[INFERENCIA — Budget hipotético. Ajustar tras piloto.]`

---

## 7. ALERTAS Y CORTES AUTOMÁTICOS

### Por sesión

| Umbral | Acción |
|---|---|
| USD 5 | Alerta al usuario |
| USD 10 | Corte automático + requiere aprobación para continuar |

### Por día

| Umbral | Acción |
|---|---|
| USD 25 | Alerta al Founder |
| USD 50 | Alerta crítica + revisión obligatoria |

### Por mes

| Umbral | Acción |
|---|---|
| 80% del budget | Alerta a Founder |
| 95% | Alerta crítica |
| 100% | Corte automático. Requiere acción explícita del Founder para reabrir |

---

## 8. ANTI-PATTERNS DE COSTO

Cosas que aumentan costos sin agregar valor:

- ❌ Usar Opus para tareas que Sonnet hace bien.
- ❌ Invocar agente para preguntas que un comando Bash resuelve.
- ❌ Pasar todo MEMORIA.md como contexto a cada invocación (cuando solo se necesita una sección).
- ❌ Loops entre agentes sin límite (3 máximo).
- ❌ Dejar agentes idle en sesiones abiertas.
- ❌ Re-procesar la misma data en múltiples invocaciones (cachear).
- ❌ Generar outputs largos cuando alcanza con resumen.

---

## 9. TÉCNICAS DE OPTIMIZACIÓN

### Caching de resultados

Si un agente acaba de procesar X, no procesarlo de nuevo en 5 minutos. Guardar resultado.

### Context window mínimo

Cada agente recibe solo el contexto necesario para su tarea, no toda la memoria.

### Prompts compactos

System prompts directos. Sin redundancia. Sin instrucciones que ya están en el skill.

### Outputs estructurados

JSON > prosa. Menos tokens.

### Modelos adecuados

Haiku para tareas que Haiku hace bien. No Opus por defecto.

### Plan Mode antes de ejecutar

Para tareas largas, primero plan, después ejecución. Si el plan es malo, se aborta antes de gastar.

---

## 10. DASHBOARD DE COSTOS

El dashboard semanal de Lumba Core debe mostrar:

```
┌─────────────────────────────────────────────┐
│  COSTOS LUMBA CORE — SEMANA {N}             │
├─────────────────────────────────────────────┤
│                                             │
│  💰 GASTADO ESTA SEMANA: USD __             │
│  📊 VS BUDGET SEMANAL:    __%               │
│                                             │
│  🔝 TOP 3 AGENTES MÁS CAROS                 │
│  1. {agente}: USD __                        │
│  2. {agente}: USD __                        │
│  3. {agente}: USD __                        │
│                                             │
│  ⚠️  ALERTAS                                │
│  - [Si algún agente disparó alerta]         │
│                                             │
│  📉 OPORTUNIDADES                           │
│  - [Sugerencias para reducir costo]         │
│                                             │
└─────────────────────────────────────────────┘
```

---

## 11. CHECKLIST DE VALIDACIÓN PARA ESTEBAN

- [ ] La asignación de modelos por agente es razonable.
- [ ] El budget inicial (USD 300/mes para piloto Minuta) es aceptable.
- [ ] Las alertas y cortes automáticos son operables.
- [ ] El plan piloto de 30 días con Minuta es viable.
- [ ] El dashboard semanal de costos es útil.
- [ ] Las inferencias marcadas están resueltas.

---

**FIN COSTOS Y PRESUPUESTO**
