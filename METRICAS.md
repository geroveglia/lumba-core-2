# MÉTRICAS DE ÉXITO — LUMBA CORE

> **Versión:** v1.0 (Lumba Core)
> **Tono:** Operativo. Manual de medición.
> **Para quién:** Founder, socios, responsables de áreas, futuros analistas.
> **Última actualización:** 23 de mayo de 2026.

---

## 1. PROPÓSITO DE ESTE DOCUMENTO

Este documento define **cómo medimos si Lumba Core funciona**.

Sin métricas, Lumba Core es una hipótesis. Con métricas mal diseñadas, Lumba Core mide lo que no importa (cantidad de outputs, velocidad, tokens consumidos) y pierde de vista lo que sí importa (calidad de entrega, reducción de corrección, criterio compartido).

Las métricas de este documento están alineadas al **Principio 0** de Lumba Core:

> *Lumba Core es auditoría antes de entrega. No es velocidad de producción.*

---

## 2. MÉTRICA NORTE

**Métrica norte de Lumba Core:**

> **Porcentaje de entregas al cliente que pasan sin corrección posterior.**

Esta es **la única métrica que importa de verdad**. Todas las demás existen para sostenerla o explicarla.

### Definición operativa

Una "entrega" es cualquier output que va al cliente: pieza, documento, código deployado, propuesta, plan, presentación, etc.

Una entrega "pasa sin corrección" si:

- El cliente no pide modificaciones de fondo.
- Las modificaciones que pide son ajustes menores acordados previamente (ej. fechas, nombres, datos), no cambios de criterio.
- No requiere rehacer parte del trabajo.

### Línea base y objetivo

| Estado | % entregas sin corrección |
|---|---|
| Hoy (sin Lumba Core, estimado) | ~30-40%
| Objetivo a 3 meses | >55% |
| Objetivo a 6 meses | >70% |
| Objetivo a 12 meses | >80% |

---

## 3. MODELO DE MEDICIÓN EN 4 CAPAS

Adoptamos el modelo de 4 capas usado en meeting science y validado por CIPD + Microsoft Research. Aplica acá porque Lumba Core es un sistema operativo, y los sistemas se miden en capas.

```
┌─────────────────────────────────────┐
│  CAPA 1 — HIGIENE                   │
│  ¿El proceso se cumple?             │
├─────────────────────────────────────┤
│  CAPA 2 — OUTPUT                    │
│  ¿Lo que producimos cumple criterio?│
├─────────────────────────────────────┤
│  CAPA 3 — EFECTO                    │
│  ¿Genera resultado en el cliente?   │
├─────────────────────────────────────┤
│  CAPA 4 — EXPERIENCIA               │
│  ¿Cómo lo viven el equipo y cliente?│
└─────────────────────────────────────┘
```

---

## 4. CAPA 1 — HIGIENE (¿el proceso se cumple?)

Mide si Lumba Core se está usando como debería.

| Métrica | Cómo se mide | Umbral saludable |
|---|---|---|
| % de proyectos que pasan por brief obsesivo antes de producir | Checklist de brief completado en `/proyectos/{cliente}/` | >90% |
| % de entregables que pasan por auditoría AI antes del cliente | Log del agente auditor | >95% |
| % de proyectos que respetan los 8 pasos del proceso | PM lo registra al cerrar fase | >85% |
| % de decisiones importantes con ADR registrado | Conteo en `/decisiones/` | >80% |
| % de proyectos con memoria de cliente actualizada | Última actualización en `/clientes/{nombre}/memoria.md` | >90% (actualizada en últimos 30 días) |

---

## 5. CAPA 2 — OUTPUT (¿lo que producimos cumple criterio?)

Mide la calidad técnica y conceptual de los entregables.

| Métrica | Cómo se mide | Umbral saludable |
|---|---|---|
| **% de entregas sin corrección posterior** ⭐ | Tracking del PM por entrega | >55% (3 meses), >80% (12 meses) |
| % de entregables aprobados al primer intento | Log de aprobaciones | >70% |
| Cantidad de iteraciones promedio por entregable | Conteo de versiones antes de aprobación | <2.5 |
| % de hallazgos críticos detectados por auditoría AI antes de entregar | Reporte del agente auditor | >60% |
| % de entregables con brief obsesivo completo al inicio | Checklist | >90% |

⭐ Esta es la métrica norte.

---

## 6. CAPA 3 — EFECTO (¿genera resultado en el cliente?)

Mide si los entregables producen impacto real en el negocio del cliente. Más difícil de medir, pero más importante.

| Métrica | Cómo se mide | Umbral saludable |
|---|---|---|
| % de clientes que renuevan retainer/proyecto | CRM o seguimiento manual | >70% |
| Duración promedio del vínculo con cliente activo | Seguimiento | >3 meses (baseline actual) → >6 meses (objetivo) |
| Cantidad de servicios cruzados por cliente | Tracking de áreas activas por cliente | Crecimiento mes a mes |
| NPS de clientes activos | Encuesta semestral simple | >50 |
| Cantidad de referidos generados por cliente | Tracking comercial | Métrica de crecimiento |

`[INFERENCIA — Estos umbrales son estimaciones razonables. Validar con datos reales tras 90 días.]`

---

## 7. CAPA 4 — EXPERIENCIA (¿cómo lo viven equipo y cliente?)

Lo que no se pregunta no se sabe.

### Para el equipo interno

| Métrica | Cómo se mide | Umbral saludable |
|---|---|---|
| % del equipo que usa Lumba Core activamente | Logs de invocaciones por usuario | >80% |
| Satisfacción percibida del equipo con Lumba Core | Encuesta trimestral 1-5 | >4 |
| Sensación de "tengo más criterio disponible que antes" | Encuesta trimestral binaria | >75% sí |
| Frustración con repreguntas o ambigüedad | Encuesta trimestral 1-5 | <2.5 |
| % del equipo que recomendaría Lumba Core a otra agencia | Encuesta trimestral binaria | >70% sí |

### Para el cliente

| Métrica | Cómo se mide | Umbral saludable |
|---|---|---|
| Percepción de calidad de entregables | Encuesta trimestral 1-5 | >4 |
| Percepción de criterio estratégico de Lumba | Encuesta trimestral 1-5 | >4 |
| Sensación de "Lumba entiende mi negocio" | Encuesta trimestral binaria | >80% sí |
| Cantidad de quejas formales por trimestre | Tracking del PM | <1 cada 5 clientes |

---

## 8. MÉTRICAS DE COSTO Y SUSTENTABILIDAD

Lumba Core consume tokens. Hay que medirlo.

| Métrica | Cómo se mide | Umbral saludable |
|---|---|---|
| Costo mensual en tokens de AI (USD) | Dashboard de consumo por proveedor | <USD 500/mes inicialmente, escalar según ROI |
| Costo de tokens por proyecto activo | Costo total / cantidad de proyectos | <USD 50/proyecto/mes |
| Ratio costo de tokens / facturación | Costo AI / facturación del mes | <2% |
| Cantidad de invocaciones idle (agentes que no devuelven valor) | Análisis de logs | <5% del total |

`[INFERENCIA — Sin datos históricos, estos números son hipótesis. Refinar tras los primeros 30 días usando Minuta como caso piloto.]`

### Plan piloto Minuta

Usar el proyecto Minuta como caso piloto para medir consumo real de tokens, construir baseline y proyectar para el resto de Lumba.

**Acciones:**
1. Instrumentar tracking de tokens desde día 1 en Minuta.
2. Después de 30 días, generar reporte de consumo por agente.
3. Proyectar consumo total de Lumba Core (3 redes × N proyectos).
4. Definir budget mensual definitivo.

---

## 9. MÉTRICAS POR RED

Cada red de Lumba Core tiene sus métricas específicas además de las generales.

### Core-Brand

| Métrica | Umbral |
|---|---|
| % de proyectos de branding con workshop estratégico previo | >95% |
| Tiempo promedio de un proyecto de branding completo | <3 meses |
| % de identidades visuales aprobadas en <3 rondas | >70% |

### Core-Marketing

| Métrica | Umbral |
|---|---|
| % de campañas con KPIs claros antes de lanzar | 100% |
| % de reportes mensuales con insights accionables (no solo datos) | >80% |
| ROAS promedio en campañas de performance | Variable por cliente |
| % de calendarios de contenido con estrategia documentada | >90% |

### Core-Product

| Métrica | Umbral |
|---|---|
| % de proyectos de producto con definición funcional completa antes de codear | >95% |
| % de bugs críticos detectados en QA vs en producción | >80% en QA |
| Lead time promedio de feature: idea → producción | <30 días para features simples |
| % de PRs revisados por agente auditor antes de merge | >90% |

---

## 10. DASHBOARD MÍNIMO

El dashboard de Lumba Core tiene que mostrar al socio operativo (Esteban) **5 números cada lunes**:

```
┌─────────────────────────────────────────────────────┐
│  LUMBA CORE — REPORTE SEMANAL                       │
├─────────────────────────────────────────────────────┤
│                                                     │
│  📊 MÉTRICA NORTE                                   │
│  % entregas sin corrección: __%                     │
│  (vs semana anterior: ↑↓ __pts)                     │
│                                                     │
│  🚥 HIGIENE                                         │
│  % proyectos en proceso correcto: __%               │
│                                                     │
│  💰 COSTO                                           │
│  Tokens gastados esta semana: USD __                │
│                                                     │
│  😀 EQUIPO                                          │
│  Satisfacción promedio última encuesta: _/5         │
│                                                     │
│  ⚠️  ALERTAS                                        │
│  - [Lista de problemas detectados esta semana]      │
│                                                     │
└─────────────────────────────────────────────────────┘
```

Si los 5 números están en verde, Lumba Core está sano.
Si 2 o más están en rojo, Lumba Core requiere intervención.

---

## 11. CADENCIA DE MEDICIÓN

| Métrica | Cadencia |
|---|---|
| % entregas sin corrección | Por entrega (tracking continuo) |
| Higiene del proceso | Semanal |
| Costos de tokens | Semanal |
| Satisfacción del equipo | Trimestral |
| Satisfacción del cliente | Trimestral |
| NPS clientes | Semestral |
| Revisión completa del sistema | Anual |

---

## 12. QUIÉN MIDE QUÉ

| Responsable | Métricas |
|---|---|
| **Esteban (Operación)** | Métrica norte, higiene, costos, dashboard semanal |
| **Martín (Comercial)** | Renovación, NPS, satisfacción cliente |
| **Hernán (Visión)** | Revisión semestral del sistema completo |
| **PM por proyecto** | Tracking de iteraciones, entregas, brief, auditoría |
| **Agente Auditor** | Detección de hallazgos antes de entregar |
| **Agente Devil's Advocate** | Riesgos invisibles, supuestos no validados |

---

## 13. QUÉ HACEMOS SI NO MEJORAMOS

Si después de 90 días la métrica norte no mejora:

1. **Auditoría del sistema completo** por Devil's Advocate.
2. **Entrevista con cada miembro del equipo**: ¿qué no funciona?
3. **Análisis de procesos**: ¿hay un paso que se está saltando?
4. **Revisión de skills**: ¿están desactualizados?
5. **Revisión de briefs**: ¿son lo suficientemente obsesivos?

Si después de la auditoría no se detectan causas claras → **revisar la hipótesis fundacional**. Capaz Lumba Core necesita un giro.

---

## 14. ANTI-MÉTRICAS (lo que NO medimos)

Para no perder foco, dejamos claro qué NO mide Lumba Core:

- ❌ Cantidad de outputs producidos por día.
- ❌ Cantidad de prompts ejecutados.
- ❌ Velocidad pura (tokens/segundo).
- ❌ Cantidad de agentes activos simultáneamente.
- ❌ Líneas de código generadas.
- ❌ Cantidad de tareas "completadas" sin chequear calidad.

**Si alguna de estas métricas crece pero la métrica norte no mejora, la métrica que crece es ruido.**

---

## 15. CHECKLIST DE VALIDACIÓN PARA ESTEBAN

Antes de cerrar este documento:

- [ ] La métrica norte (% entregas sin corrección) es la correcta.
- [ ] Los umbrales son alcanzables (no aspiracionales sin base).
- [ ] El dashboard semanal de 5 números es operable.
- [ ] La línea base (~30-40%) refleja realidad o necesita ajuste.
- [ ] La cadencia de medición no es burocrática.
- [ ] Las anti-métricas son las correctas.
- [ ] Las marcas `[INFERENCIA — Validar]` están resueltas.

---

**FIN DE MÉTRICAS DE ÉXITO**
