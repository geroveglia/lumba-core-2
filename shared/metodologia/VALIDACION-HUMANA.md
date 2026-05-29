# VALIDACIÓN HUMANA OBLIGATORIA — LUMBA CORE

> **Versión:** v1.0
> **Tono:** Manual operativo + reglas duras.
> **Propósito:** definir las acciones que SIEMPRE requieren validación humana antes de ejecutarse.
> **Última actualización:** 23 de mayo de 2026.

---

## 1. PROPÓSITO

Lumba Core opera con agentes AI poderosos. Estos agentes pueden producir, recomendar, ejecutar y comunicar.

**Pero hay un conjunto de acciones que ningún agente puede ejecutar sin un humano aprobando.**

Este documento lista esas acciones. Es ley.

---

## 2. PRINCIPIO BASE

> **AI sugiere. Humano decide.**

Los agentes son aceleradores. Las decisiones críticas son humanas.

Esto no es por desconfianza. Es por:

- **Responsabilidad legal** — el humano firma, el humano responde.
- **Contexto del cliente** — solo el humano conoce sutilezas no documentadas.
- **Reputación de Lumba** — un error de un agente lo paga la agencia.
- **Reversibilidad** — algunas acciones no se pueden deshacer.

---

## 3. LAS 12 REGLAS DE VALIDACIÓN HUMANA OBLIGATORIA

### Regla 1 — Antes de enviar al cliente

**Cualquier entregable** (pieza, documento, código, propuesta, presentación) que vaya al cliente requiere aprobación humana explícita.

Sin excepción. Sin atajos.

**Aprobador:** PM del proyecto o socio.

---

### Regla 2 — Antes de publicar contenido

Cualquier publicación en redes sociales, blog, sitio web, email a base, requiere validación.

**Aprobador:** PM o responsable del canal.

---

### Regla 3 — Antes de lanzar campañas

Activación de campañas de Meta Ads, Google Ads, email marketing masivo, requiere aprobación.

**Aprobador:** Performance specialist (humano) + cliente cuando aplica.

---

### Regla 4 — Antes de cambiar presupuesto

Cambios de presupuesto en campañas activas, contratos con proveedores, gastos de cliente, requieren validación.

**Aprobador:** Socio comercial (Martín) o responsable de cuenta.

---

### Regla 5 — Antes de cambiar alcance

Cualquier modificación del scope original de un proyecto requiere:

1. Detección por `scope-agent` o detección humana.
2. Análisis de impacto.
3. Comunicación al cliente.
4. Acuerdo escrito.
5. Validación interna.

**Aprobador:** Socio comercial + PM del proyecto.

---

### Regla 6 — Antes de aprobar naming, identidad o estrategia final

El cierre de cualquier proyecto estratégico (naming, identidad visual, estrategia de marca, estrategia de marketing) requiere:

1. Pasaje por Strategy/Brand Gate.
2. Aprobación humana del Vertical Lead.
3. Validación final del cliente.

**Aprobador:** Vertical Lead + cliente.

---

### Regla 7 — Antes de deployar a producción

Cualquier deploy a producción requiere:

1. Pasaje por Software Gate.
2. Tests passing en CI.
3. Plan de rollback definido.
4. Aprobación humana.

**Aprobador:** DevOps engineer humano + tech lead.

---

### Regla 8 — Antes de usar datos sensibles

Cualquier acceso a:
- Base de datos de clientes.
- Información financiera.
- Datos personales identificables.
- Documentos legales.

requiere autorización explícita por escrito.

**Aprobador:** Socio responsable + cliente cuando corresponde.

---

### Regla 9 — Antes de modificar MEMORIA principal

Cualquier cambio en:
- `MANIFIESTO.md`
- `PRINCIPIOS.md`
- `METRICAS.md`
- `MEMORIA-CLIENTE.md` (raíz del cliente)
- `MEMORIA-PROYECTO.md` (raíz del proyecto)

requiere aprobación del Founder o socio.

**Aprobador:** Esteban (operación) + socios para cambios mayores.

---

### Regla 10 — Antes de aceptar override del Devil's Advocate

Si Devil's Advocate dice `reject` con `blocking: true`, el entregable no avanza.

Para hacer override de esa decisión:

1. Registrar como **decisión consciente** en `/proyectos/{nombre}/overrides/`.
2. Documentar el motivo.
3. Aceptar las consecuencias.
4. Aprobador: Founder o socio.

**Esto NO se puede automatizar.**

---

### Regla 11 — Antes de modificar `.claude/agents/` o skills

Cualquier modificación a:
- Definiciones de agentes.
- Skills oficiales.
- System prompts.
- Quality gates.

requiere aprobación del Founder.

**Aprobador:** Esteban (operación) + Devil's Advocate audita antes.

---

### Regla 12 — Antes de gastar >USD 10 en una sola sesión

Si una sesión de Claude Code está consumiendo más de USD 10 en tokens, se detiene automáticamente.

Para continuar:

1. El humano revisa qué está pasando.
2. Decide si vale la pena seguir.
3. Aprueba la continuación o detiene.

**Aprobador:** El usuario de la sesión + Founder si supera USD 25.

---

## 4. CASOS QUE NO REQUIEREN VALIDACIÓN HUMANA

Para que no se trabe la operación, hay cosas que sí pueden hacerse sin gate humano:

- Investigación interna.
- Análisis de información existente.
- Borradores internos (no van al cliente).
- Estructuración de información.
- Resumen de reuniones internas.
- Búsqueda de referencias.
- Cálculos y análisis numéricos.
- Generación de drafts para revisión humana posterior.
- Lectura de documentación.
- Tests internos (no a producción).
- Lint, formateo, type-checking.
- Commits a feature branches (no a main).

**La regla es:** si es trabajo interno reversible y de bajo riesgo, agente actúa solo.
Si es externo, irreversible o de alto riesgo, humano valida.

---

## 5. CÓMO SE EJECUTA UNA VALIDACIÓN HUMANA

### Flujo estándar

```
1. Agente prepara entregable.
2. Agente declara: "Listo para validación humana."
3. Sistema notifica al aprobador.
4. Aprobador revisa.
5. Aprueba / pide cambios / rechaza.
6. Si aprueba → ejecutar.
7. Si pide cambios → ajustar y volver.
8. Si rechaza → archivar con motivo.
```

### Plan Mode de Claude Code

Para acciones críticas, los agentes operan en **Plan Mode**:

1. Agente presenta plan completo.
2. Humano revisa plan.
3. Humano aprueba ejecución.
4. Recién entonces se ejecuta.

Esto se aplica a:
- Deploys.
- Modificaciones de configuración del sistema.
- Acciones irreversibles.

---

## 6. QUÉ PASA SI UN AGENTE VIOLA UNA REGLA

Si un agente ejecuta una acción que requería validación humana sin haberla obtenido:

1. **Bloqueo inmediato del agente** involucrado.
2. **Análisis del incidente** por Founder + Devil's Advocate.
3. **Post-mortem** en `/lumba-core/incidents/`.
4. **Ajuste de configuración** del agente.
5. **Reapertura** solo después de fix verificado.

---

## 7. REGISTROS Y TRAZABILIDAD

Toda validación humana queda registrada:

```
/proyectos/{nombre}/approvals/
  {fecha}-{tipo}-{aprobador}.json
```

Contenido:

```json
{
  "approval_id": "string",
  "timestamp": "ISO-8601",
  "approver": "string (humano)",
  "type": "client_delivery|campaign_launch|deploy|...",
  "what_was_approved": "string",
  "context": "string",
  "agent_proposer": "string",
  "approved": true,
  "conditions": ["string (si aplica)"]
}
```

Esto permite:
- Auditoría posterior.
- Aprendizaje (qué tipo de cosas requieren más validación).
- Compliance.
- Defensa ante incidentes.

---

## 8. ESCALADA DE APROBACIONES

| Tipo de decisión | Aprobador primario | Si no disponible |
|---|---|---|
| Entrega rutinaria al cliente | PM del proyecto | Vertical Lead |
| Cambio de scope | Socio comercial (Martín) | Esteban |
| Deploy a producción | Tech lead | Esteban |
| Cambio en `.claude/` | Esteban | Devil's Advocate + Esteban remoto |
| Lanzamiento de campaña con presupuesto >USD 1000 | Cliente + Martín | Esteban + Martín |
| Decisión estratégica mayor | Los 3 socios | — |

---

## 9. INTEGRACIÓN CON LOS QUALITY GATES

Los Quality Gates de `QUALITY-GATES.md` son el primer filtro técnico.
La validación humana de este documento es el filtro humano final.

```
Producción → Quality Gate → Validación Humana → Ejecución
```

Ambos son necesarios.

---

## 10. ANTI-PATTERNS

Cosas que NO hacemos:

- ❌ "Aprobá rapidito" sin que el humano revise.
- ❌ Asumir validación implícita.
- ❌ Validar sin entender qué se está aprobando.
- ❌ Saltarse validación porque "es chiquito".
- ❌ Tener un solo aprobador para todo (cuello de botella).
- ❌ Validaciones sin registro.

---

## 11. CHECKLIST DE VALIDACIÓN

- [ ] Las 12 reglas son operables.
- [ ] Los aprobadores por tipo están claros.
- [ ] El flujo de validación no es burocrático.
- [ ] El registro de aprobaciones es viable.
- [ ] Hay backup de aprobadores cuando uno no está.

---

**FIN DE VALIDACIÓN HUMANA OBLIGATORIA**
