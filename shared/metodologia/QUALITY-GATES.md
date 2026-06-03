# QUALITY GATES — LUMBA CORE

> **Versión:** v1.0
> **Tono:** Manual operativo.
> **Propósito:** definir los gates de calidad que protegen el sistema de entregas con errores.
> **Última actualización:** 23 de mayo de 2026.

---

## 1. QUÉ ES UN QUALITY GATE

Un Quality Gate es un **punto de control obligatorio** entre fases de trabajo.

Sin pasar el gate, el trabajo **no avanza**.

Cada gate tiene:
- **Trigger** — cuándo se activa.
- **Owner** — qué agente lo ejecuta.
- **Checklist** — qué se valida.
- **Output** — resultado del gate.
- **Escalada** — qué pasa si falla.

---

## 2. LOS 11 GATES DE LUMBA CORE

```
1. Strategy Gate     → estrategia de proyecto
2. Brand Gate        → entregables de branding
3. Design Gate       → diseño UI/visual
4. Marketing Gate    → planes y campañas
5. Growth Gate       → experimentos de growth
6. Paid Media Gate   → Meta Ads y Google Ads
7. Reporting Gate    → reportes mensuales
8. UX/Product Gate   → diseño UX y product specs
9. Software Gate     → código y deploys
10. Client Gate      → entregables al cliente
11. Scope/Risk Gate  → cambios de alcance
```

---

## 3. STRATEGY GATE

### Trigger
- Cierre de Paso 3 (Pensamos de nuevo).
- Antes de avanzar a validación.

### Owner
- Devil's Advocate (universal) + Vertical Lead del equipo.

### Checklist
- [ ] Estrategia conectada al problema de negocio del cliente.
- [ ] KPIs claros y medibles.
- [ ] Audiencia / usuario / mercado identificado.
- [ ] Supuestos declarados explícitamente.
- [ ] Alternativas consideradas (al menos 2).
- [ ] Coherente con MEMORIA del cliente.
- [ ] Coherente con principios de Lumba Core.

### Output
- ✅ Approved → avanza.
- ⚠️ Needs revision → vuelve con feedback específico.
- ❌ Rejected → reformular estrategia.

### Escalada si falla
- Vuelve al Vertical Lead.
- Máximo 3 iteraciones antes de escalar al Founder.

---

## 4. BRAND GATE

### Trigger
- Antes de entregar pieza de branding al cliente.

### Owner
- `brand-auditor` (Opus).

### Checklist
- [ ] Pieza responde al posicionamiento definido.
- [ ] Tono de voz coherente.
- [ ] Conecta con territorios conceptuales aprobados.
- [ ] Diferencia de competencia analizada.
- [ ] Respeta sistema visual del cliente.
- [ ] Aplicación correcta del logotipo.
- [ ] Coherencia con entregables anteriores del mismo cliente.
- [ ] Memoria del cliente está al día.

### Output
- ✅ Approved → avanza a Client Gate.
- ⚠️ Needs revision → vuelve al brand-strategist o identity-designer.

### Escalada si falla
- 3 iteraciones máximo.
- Después escala al Vertical Lead de Core-Brand.

---

## 5. DESIGN GATE

### Trigger
- Antes de pasar diseño visual a producción / desarrollo.

### Owner
- `ui-designer` o `visual-director` según contexto.

### Checklist
- [ ] Sistema visual consistente.
- [ ] Tipografías correctas del sistema.
- [ ] Paleta cromática oficial.
- [ ] Jerarquía visual clara.
- [ ] Estados de pantalla (loading/empty/error) definidos.
- [ ] Responsive funcional.
- [ ] Accesibilidad WCAG AA.

### Output
- ✅ Approved → producción.
- ⚠️ Needs revision → ajuste de diseño.

---

## 6. MARKETING GATE

### Trigger
- Antes de presentar plan de marketing al cliente.
- Antes de lanzar campaña.

### Owner
- `marketing-auditor` (Opus).

### Checklist
- [ ] Objetivos de negocio claros.
- [ ] KPIs definidos y medibles.
- [ ] Audiencia bien segmentada.
- [ ] Pilares de contenido alineados a estrategia.
- [ ] Calendario coherente con campañas.
- [ ] Presupuesto cuadra con objetivos.
- [ ] Tracking configurado.
- [ ] Hipótesis explícita (no "vamos a hacer porque sí").

### Output
- ✅ Approved → avanza.
- ⚠️ Needs revision → vuelve al marketing-strategist.

---

## 7. GROWTH GATE

### Trigger
- Antes de lanzar un experimento de growth.

### Owner
- `growth-marketing-specialist`.

### Checklist
- [ ] Hipótesis estructurada (Si cambiamos X, entonces Y mejorará porque Z).
- [ ] KPI primario definido.
- [ ] Guardrail metrics definidos.
- [ ] Duración del test calculada.
- [ ] Decision rules explícitas (scale/iterate/stop/investigate).
- [ ] Audiencia y control definidos.
- [ ] Assets necesarios listos.
- [ ] Owner del experimento asignado.

### Output
- ✅ Approved → ejecutar experimento.
- ⚠️ Needs revision → refinar hipótesis o setup.

---

## 8. PAID MEDIA GATE

### Trigger
- Antes de activar campaña en Meta Ads o Google Ads.

### Owner
- `meta-ads-analyst` o `google-ads-analyst` según plataforma.

### Checklist común
- [ ] Objetivo de campaña alineado a outcome de negocio.
- [ ] KPIs explícitos antes de lanzar.
- [ ] Pixel / conversion tracking configurado.
- [ ] Audiencias correctamente segmentadas.
- [ ] Copys alineados a marca.
- [ ] Creatividades aprobadas.
- [ ] UTMs presentes.
- [ ] Budget definido y aprobado por humano.

### Checklist específico Meta Ads
- [ ] Estructura de cuenta correcta.
- [ ] Exclusiones configuradas (evitar pisado entre campañas).
- [ ] Creatividad de control para testing.
- [ ] Frecuencia monitoreada.

### Checklist específico Google Ads
- [ ] Match types correctos.
- [ ] Keywords negativas configuradas.
- [ ] Search terms revisados.
- [ ] Landing page coherente con queries.
- [ ] Conversion events configurados.

### Output
- ✅ Approved → lanzamiento.
- ⚠️ Needs revision → ajustar antes de lanzar.

---

## 9. REPORTING GATE

### Trigger
- Antes de presentar reporte mensual o de campaña al cliente.

### Owner
- `marketing-auditor` (Opus) + `data-analyst`.

### Checklist
- [ ] Cada métrica tiene interpretación (no solo número).
- [ ] Se identificaron causas detrás de los números.
- [ ] Hay al menos 3 recomendaciones accionables.
- [ ] Estructura: qué pasó / qué significa / qué lo causa / qué hacer.
- [ ] Comparación contra periodo anterior.
- [ ] Limitaciones de data declaradas.
- [ ] Tendencias visualizadas claramente.

### Output
- ✅ Approved → presentación al cliente.
- ⚠️ Needs revision → vuelve al data-analyst para enriquecer.

### Regla de hierro
- Un reporte con métricas sin interpretación NO pasa este gate.

---

## 10. UX/PRODUCT GATE

### Trigger
- Antes de pasar diseño UX/UI a desarrollo.
- Antes de aprobar especificación funcional.

### Owner
- `product-auditor` (Opus).

### Checklist
- [ ] Cada feature tiene criterio de aceptación.
- [ ] Casos de uso cubren happy path + edge cases.
- [ ] Permisos y roles definidos.
- [ ] Reglas de negocio claras.
- [ ] Integraciones identificadas.
- [ ] Estados de pantalla completos.
- [ ] Responsive funcional.
- [ ] Accesibilidad WCAG AA.

### Output
- ✅ Approved → desarrollo.
- ⚠️ Needs revision → ajustar UX o spec.

---

## 11. SOFTWARE GATE

### Trigger
- Antes de hacer merge a main.
- Antes de deploy a producción.

### Owner
- `code-reviewer` + `qa-engineer`. Apoyo: `security-agent` + `code-quality-agent`.

### Paso 0 — Checks determinísticos (automáticos, bloqueantes)
Corren solos antes de cualquier revisión humana o de agente. Si fallan, el PR ni se revisa.
- [ ] Prettier — formato OK (`format:check`).
- [ ] ESLint — sin errores (`lint`).
- [ ] TypeScript strict — sin errores (`typecheck`).
- [ ] Estándar aplicado según `shared/infra/CODING-STANDARDS.md`.

> El formato y el código muerto se resuelven acá, no en el review. Ver `shared/infra/stack-a-config/`.

### Checklist pre-merge
- [ ] Paso 0 en verde (lint + format + typecheck).
- [ ] PR pasó code review (`/review-pr`).
- [ ] Tests asociados.
- [ ] Variables de entorno fuera del repo.
- [ ] No hay TODOs sin owner.
- [ ] Documentación actualizada si corresponde.
- [ ] Tests passing en CI.

### Checklist pre-deploy
- [ ] Plan de rollback definido.
- [ ] Variables de entorno configuradas en target.
- [ ] Monitoring activo.
- [ ] Cambio comunicado al cliente si corresponde.
- [ ] Backups recientes.

### Output
- ✅ Approved → merge/deploy.
- ⚠️ Needs revision → fix antes de deploy.

### Regla de hierro
- Sin tests passing, no hay merge.
- Sin plan de rollback, no hay deploy.

---

## 12. CLIENT GATE

### Trigger
- Antes de que CUALQUIER entregable salga al cliente externo.

### Owner
- Humano (PM, socio, o Vertical Lead).

### Checklist
- [ ] Pasó todos los gates previos del equipo correspondiente.
- [ ] Coherente con brief aprobado.
- [ ] Tono adecuado al cliente.
- [ ] Versión final, no draft.
- [ ] Archivos en formato correcto.
- [ ] Mensaje de acompañamiento preparado.
- [ ] Lecciones del proyecto registradas.

### Output
- ✅ Approved → entrega al cliente.
- ⚠️ Needs revision → última corrección.

### Regla de hierro
- **Sin Client Gate, nada sale al cliente.**

---

## 13. SCOPE/RISK GATE

### Trigger
- Cuando hay cambio de alcance solicitado por cliente.
- Cuando se detecta trabajo no cotizado.
- Cuando hay riesgo de rentabilidad.

### Owner
- `scope-agent` (universal) + humano (socio o PM).

### Checklist
- [ ] El cambio está dentro de alcance original.
- [ ] Si no, ¿cuánto trabajo adicional implica?
- [ ] ¿Afecta plazo del proyecto?
- [ ] ¿Afecta rentabilidad?
- [ ] ¿Hay acuerdo escrito del cambio?
- [ ] ¿El cliente acepta el costo / plazo adicional?

### Output
- ✅ Within scope → continuar.
- ⚠️ Scope creep detected → negociar con cliente.
- ❌ Out of scope → rechazar o cotizar adicional.

### Regla de hierro
- Trabajo no cotizado no se ejecuta sin acuerdo escrito.

---

## 14. MATRIZ DE GATES POR EQUIPO

| Equipo | Gates obligatorios |
|---|---|
| Core-Brand | Strategy, Brand, Design, Client, Scope/Risk |
| Core-Marketing | Strategy, Marketing, Growth (si aplica), Paid Media (si aplica), Reporting, Client, Scope/Risk |
| Core-Product | Strategy, UX/Product, Software, Client, Scope/Risk |

---

## 15. MAPPING GATES → FASES DEL PROYECTO (state.json)

> **Propósito:** Conectar los 11 gates con las fases de `project-state-schema.json`.
> Jarvis consulta esta tabla para saber qué gates evaluar al cerrar cada fase.

| Fase (state.json) | Gates obligatorios | Gates opcionales | Notas |
|---|---|---|---|
| `PROJECT_ASSESSMENT` | — | — | Sin gate. Es clasificación. |
| `BRIEF` | Strategy Gate | — | Validar que brief conecte con problema de negocio. |
| `PROPOSAL` | Client Gate, Scope/Risk Gate | — | Cliente debe firmar propuesta. |
| `DISCOVERY` | Strategy Gate | — | Validar supuestos, alternativas, KPIs. |
| `TECH_STACK` | Strategy Gate | — | Validar que stack sea coherente con requerimientos. |
| `DB_DESIGN` | Software Gate, UX/Product Gate | — | Modelo de datos + validación APIs. |
| `BOOTSTRAP` | — | — | Sin gate. Es scaffolding automático (solo Tipo A). |
| `BRANDING` | Brand Gate, Strategy Gate | — | Posicionamiento + sistema visual. |
| `UX_UI` | Design Gate, UX/Product Gate | — | UI consistency + specs funcionales. |
| `MARKETING` | Marketing Gate | Growth Gate, Paid Media Gate | Opcionales según si hay growth/ads. |
| `BUILD` | Software Gate | — | Code review + tests. |
| `QA` | Software Gate | — | Tests passing, coverage. |
| `DEPLOY` | Software Gate, Client Gate | — | Rollback plan + aprobación. |
| `POST_LAUNCH` | Reporting Gate | — | Métricas semana 1. |

> ⚡ **Regla:** Si una fase tiene gate obligatorio, no se puede avanzar a la siguiente sin que pase.
> Los gates opcionales se evalúan solo si aplican al proyecto (ej: Growth Gate solo si hay experimentos de growth).

---

## 16. ESCALADA — QUÉ PASA SI UN GATE FALLA

```
1. Entregable rechazado en gate.
2. Vuelve al agente productor con feedback específico.
3. Producción ajusta.
4. Re-evaluación en gate.
5. Si pasa, avanza.
6. Si no pasa, ITERACIÓN #2.
7. Máximo 3 iteraciones.
8. Si después de 3 iteraciones no pasa → escalada al Founder.
9. Founder decide: aceptar conscientemente, rechazar definitivamente o reasignar.
```

**Esto evita el failure mode "circuitous conversations" (MAST).**

---

## 16. BYPASS POR EMERGENCIA

Hay casos donde no se puede ejecutar el gate completo:

- Bug crítico en producción que requiere fix inmediato.
- Cliente con problema urgente real.

En esos casos:

- Bypass autorizado por humano (PM o socio).
- Se ejecuta lo mínimo posible.
- Se registra el bypass.
- Post-mortem obligatorio después.

**Máximo de bypasses:** 5% del total.

---

## 17. MÉTRICAS DE LOS GATES

| Métrica | Umbral |
|---|---|
| % de entregables que pasan gates al primer intento | >70% |
| Promedio de iteraciones por gate | <2 |
| % de bypasses sobre total | <5% |
| % de Client Gates aprobados | >95% |
| % de Strategy Gates rechazados (sano: indica criterio) | 15-30% |

---

## 18. CHECKLIST DE VALIDACIÓN

- [ ] Los 11 gates son operables.
- [ ] Owners y checklists son claros.
- [ ] El proceso de escalada es viable.
- [ ] Los bypasses tienen control.
- [ ] La matriz por equipo es correcta.

---

**FIN DE QUALITY GATES**
