# WORKFLOW DE BRIEF OBSESIVO — LUMBA CORE

> **Versión:** v1.0 (Lumba Core)
> **Tono:** Manual operativo.
> **Propósito:** definir cómo se arma un brief antes de que un agente produzca cualquier cosa.
> **Última actualización:** 23 de mayo de 2026.

---

## 1. POR QUÉ EXISTE ESTE WORKFLOW

La **corrección posterior nace casi siempre de un brief flojo**.

Cuando alguien arranca a producir sin saber bien qué tiene que entregar, a quién, para qué y con qué restricciones, el resultado es **predeciblemente malo**.

Lumba Core opera con **brief obsesivo**:

> *Mejor invertir 30 minutos en un brief completo que 3 horas en correcciones después.*

Este workflow es el complemento natural del Workflow de Auditoría (Principio 0).

---

## 2. CUÁNDO SE ACTIVA

**Antes** de que cualquier agente produzca un entregable.

Aplica a:

- Cualquier pieza creativa.
- Cualquier documento estratégico.
- Cualquier desarrollo de software.
- Cualquier campaña.
- Cualquier reporte.
- Cualquier presentación.

Si no hay brief obsesivo completo, **el agente no arranca**.

---

## 3. COMPONENTES OBLIGATORIOS DEL BRIEF

Todo brief tiene estos 8 campos. Ninguno opcional.

```yaml
brief:
  # 1. Identificación
  id: brief-{cliente}-{proyecto}-{nnn}
  cliente: string
  proyecto: string
  entregable: string
  fecha: ISO-8601
  solicitante: string
  decisor_final: string
  
  # 2. Objetivo
  objetivo: |
    ¿Qué problema resuelve este entregable?
    ¿Qué cambio esperamos generar?
  
  # 3. Audiencia
  audiencia:
    quien_lo_lee: string
    contexto: string
    nivel_conocimiento: string
    expectativas: string
  
  # 4. Resultados esperados
  criterios_exito:
    - criterio_1
    - criterio_2
    - criterio_3
  
  # 5. Restricciones
  restricciones:
    plazo: ISO-8601
    presupuesto: string
    marca: ["restricciones de tono, visual, etc."]
    tecnicas: ["limitaciones técnicas"]
    legales: ["compliance, etc."]
  
  # 6. Ejemplos
  ejemplos_de_si:
    - referencia_1
    - referencia_2
  ejemplos_de_no:
    - antiejemplo_1
    - antiejemplo_2
  
  # 7. Información de soporte
  memoria_cliente_link: path
  proyectos_relacionados: [paths]
  documentos_referencia: [paths]
  decisiones_previas_aplicables: [paths]
  
  # 8. Aprobación
  brief_aprobado_por: string
  fecha_aprobacion: ISO-8601
```

---

## 4. EL WORKFLOW EN 5 PASOS

```
1. SOLICITUD INICIAL
   ↓
2. AGENTE PIDE BRIEF
   ↓
3. HUMANO COMPLETA (con ayuda del agente)
   ↓
4. VALIDACIÓN DEL BRIEF
   ↓
5. APROBACIÓN
```

---

## 5. PASO 1 — SOLICITUD INICIAL

### Qué pasa

Humano (PM, socio, o miembro del equipo) abre una solicitud de entregable.

Ejemplo:
> "Necesito un calendario de contenido para CanCat de junio 2026."

### Output

Solicitud sin estructura. El siguiente paso la estructura.

---

## 6. PASO 2 — AGENTE PIDE BRIEF

### Qué pasa

El agente correspondiente (ej. `content-strategist`) recibe la solicitud y **NO empieza a producir**.

Primero, identifica qué campos del brief están claros y qué campos faltan.

### Output del agente

```json
{
  "agent": "content-strategist",
  "request_received": "Calendario contenido CanCat junio 2026",
  "brief_status": "incomplete",
  "fields_provided": ["cliente", "tipo_entregable", "periodo"],
  "fields_missing": [
    "objetivo específico",
    "audiencia (¿es el mismo del mes pasado?)",
    "criterios de éxito",
    "campañas relevantes del mes",
    "presupuesto de producción si requiere ads"
  ],
  "questions_for_human": [
    "¿Hay algún lanzamiento o campaña especial en junio?",
    "¿Cambió la estrategia respecto del mes anterior?",
    "¿Hay restricciones de tono específicas para este período?"
  ]
}
```

---

## 7. PASO 3 — HUMANO COMPLETA (con ayuda del agente)

### Qué pasa

El humano responde las preguntas. El agente las estructura en el brief formal.

### Modo asistido

El agente puede:

- Sugerir respuestas basadas en `MEMORIA-CLIENTE.md`.
- Marcar campos como `[autogenerado_para_validar]` y pedir confirmación.
- Detectar contradicciones con briefs anteriores.

### Ejemplo

```yaml
brief:
  id: brief-cancat-marketing-042
  cliente: CanCat
  proyecto: Marketing mensual
  entregable: Calendario contenido junio 2026
  fecha: 2026-05-25
  solicitante: PM Lumba
  decisor_final: Marketing manager de CanCat
  
  objetivo: |
    [autogenerado_para_validar]
    Sostener engagement de comunidad B2B + impulsar
    consultas para línea nueva de productos lanzamiento de junio.
  
  audiencia:
    quien_lo_lee: [autogenerado_para_validar - basado en MEMORIA-CLIENTE]
    Compradores B2B + distribuidores existentes.
    
  ...
```

---

## 8. PASO 4 — VALIDACIÓN DEL BRIEF

### Qué pasa

Antes de aprobar, el agente revisa que el brief sea **completo y consistente**.

### Checks automáticos

- [ ] Todos los 8 componentes están completos.
- [ ] Hay decisor final identificado.
- [ ] Los criterios de éxito son medibles (no "que esté lindo").
- [ ] Los plazos son realistas.
- [ ] No contradice memoria del cliente.
- [ ] No contradice briefs anteriores aprobados.
- [ ] Hay ejemplos de "sí" Y de "no" (ambos requeridos).

### Si falla

Vuelve al humano con la lista específica de qué falta.

### Si pasa

Avanza a Paso 5.

---

## 9. PASO 5 — APROBACIÓN

### Quién aprueba

Depende del tipo:

| Tipo brief | Aprobador |
|---|---|
| Brief rutinario (pieza estándar del flujo mensual) | PM del proyecto |
| Brief de campaña nueva o entregable estratégico | Socio del área |
| Brief de proyecto nuevo o cambio mayor | Esteban + socio del área |

### Qué hace el aprobador

Lee el brief completo. Aprueba o devuelve con feedback.

### Tracking

Brief aprobado se guarda en:
```
/clientes/{nombre}/briefs/{fecha}-{tipo}.yaml
```

Con `version_hash` para que cualquier agente posterior pueda referenciarlo.

---

## 10. EJEMPLOS DE BRIEF OBSESIVO POR ÁREA

### Brief de pieza de branding

```yaml
brief:
  id: brief-profecia-branding-007
  cliente: Profecía
  proyecto: Rebranding 2026
  entregable: Sistema de identidad visual final
  fecha: 2026-04-15
  decisor_final: Founder de Profecía
  
  objetivo: |
    Cerrar identidad visual del rebranding, lista para
    aplicar a packaging + comunicación digital + retail.
  
  audiencia:
    quien_lo_lee: Founder de Profecía
    contexto: Lleva 3 meses esperando esta entrega
    nivel_conocimiento: Alto, ya pasó workshops estratégicos
    expectativas: Coherencia con posicionamiento + diferencial visual claro
  
  criterios_exito:
    - Aprobación al primer intento sin más rondas
    - Sistema escalable a 8+ aplicaciones
    - Diferencia clara vs los 3 competidores analizados
    - Coherencia con plataforma de marca aprobada
  
  restricciones:
    plazo: 2026-04-22
    marca:
      - Posicionamiento aprobado (ver MEMORIA-MARCA)
      - Territorio conceptual: "Patrimonio + Modernidad"
      - Excluir paleta competidor A (rojos y dorados)
    tecnicas:
      - Logotipo debe funcionar en B/N
      - Debe legible a 16px
  
  ejemplos_de_si:
    - "Estética similar a [referencia 1]"
    - "Limpieza tipográfica como [referencia 2]"
  ejemplos_de_no:
    - "Nada que evoque artesanía (lo descartamos en workshop 3)"
    - "Sin gradientes ni efectos brillantes"
```

### Brief de campaña de performance

```yaml
brief:
  id: brief-rusmotos-marketing-018
  cliente: RUS
  proyecto: RUS Motos
  entregable: Campaña Meta Ads junio 2026
  fecha: 2026-05-25
  decisor_final: Marketing manager RUS
  
  objetivo: |
    Captar 200 leads cualificados para cotización de motos
    en provincias de Entre Ríos, Santa Fe, Córdoba.
  
  audiencia:
    quien_lo_lee: Performance team interno + manager RUS
    contexto: Mes con presupuesto reducido vs mayo
    
  criterios_exito:
    - CPL <USD 5
    - CTR >1.5%
    - 200 leads en 30 días
    - ROAS proyectado >2.5
  
  restricciones:
    plazo: 2026-06-01 (inicio campaña)
    presupuesto: USD 3000 (vs 4500 de mayo)
    marca:
      - Solo creatividades aprobadas en abril
      - No usar tono alarmista (decisión histórica)
    tecnicas:
      - Pixel configurado en evento "lead generation"
      - Sin redirect a WhatsApp (probar landing nueva)
  
  ejemplos_de_si:
    - "Estructura ganadora marzo (ver MEMORIA-MARKETING)"
  ejemplos_de_no:
    - "Sin imágenes genéricas de motos stock"
```

### Brief de feature de producto

```yaml
brief:
  id: brief-minuta-product-012
  cliente: Minuta (interno)
  proyecto: MVP Minuta
  entregable: Feature - Backlog colaborativo
  fecha: 2026-06-10
  decisor_final: Esteban (founder Minuta)
  
  objetivo: |
    Permitir que cualquier miembro del equipo proponga
    temas a una reunión antes de que el Owner la curate.
  
  audiencia:
    quien_lo_lee: Equipo del cliente que va a usar Minuta
    nivel_conocimiento: Usuarios sin training, autoexplicativo
  
  criterios_exito:
    - User puede proponer tema en <30 segundos
    - Owner ve todos los temas en una sola vista
    - Curaduría toma <5 min para 10 temas
    - 0 bugs en producción primera semana
  
  restricciones:
    plazo: 2026-06-30
    tecnicas:
      - Stack: Vite + React + Supabase
      - Real-time obligatorio
      - Multi-tenant ready
      - Tests cobertura >70%
  
  ejemplos_de_si:
    - "UX similar a Linear (orden visual claro)"
    - "Velocidad como Cron"
  ejemplos_de_no:
    - "Sin formularios largos"
    - "Sin tutoriales internos"
```

---

## 11. ANTI-PATTERNS DEL BRIEF

Cosas que NO hacemos:

- ❌ "Que esté lindo" como criterio.
- ❌ "Para mañana" sin contexto del plazo real.
- ❌ "Como lo del mes pasado" sin referenciar específicamente.
- ❌ Brief verbal "yo te explico" sin documento.
- ❌ Brief con campos vacíos "lo completamos después".
- ❌ Aprobación implícita.
- ❌ Brief sin decisor final identificado.
- ❌ Briefs sin ejemplos de "no" (solo ejemplos de "sí").

---

## 12. INTEGRACIÓN CON WORKFLOW DE AUDITORÍA

Este workflow es **el primer paso** del Workflow de Auditoría.

```
BRIEF OBSESIVO → PRODUCCIÓN → AUDITORÍA → ENTREGA
```

Sin brief, no hay producción.
Sin producción, no hay auditoría.
Sin auditoría, no hay entrega.

**Es una cadena. Si el primer eslabón es flojo, todo se rompe.**

---

## 13. MÉTRICAS DEL BRIEF

| Métrica | Umbral saludable |
|---|---|
| % de entregables con brief obsesivo completo | >90% |
| Tiempo promedio para completar brief | <30 min |
| % de briefs aprobados al primer intento | >70% |
| % de briefs que tuvieron que reabrirse durante producción | <10% |
| Correlación brief incompleto ↔ corrección posterior | Tracking obligatorio |

---

## 14. CHECKLIST DE VALIDACIÓN PARA ESTEBAN

- [ ] Los 8 componentes obligatorios son razonables.
- [ ] El workflow de 5 pasos es operable.
- [ ] Los ejemplos por área son realistas.
- [ ] Los aprobadores por tipo son correctos.
- [ ] La integración con Workflow de Auditoría es clara.
- [ ] Las métricas son medibles.

---

**FIN WORKFLOW BRIEF OBSESIVO**
