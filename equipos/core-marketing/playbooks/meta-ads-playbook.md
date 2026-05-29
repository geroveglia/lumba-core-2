# META ADS PLAYBOOK — LUMBA CORE v1.0

> **Para quién:** `meta-ads-analyst`, `marketing-strategist`, especialistas humanos.
> **Cuándo usar:** al diagnosticar, estructurar o analizar cualquier cuenta de Meta Ads.
> **Última actualización:** 23 de mayo de 2026.

---

## 1. PARA QUÉ SIRVE META ADS (BIEN HECHO)

Meta Ads es bueno en:

- **Demand creation** — generar demanda donde no existía.
- **Creative testing** — probar mensajes y formatos rápido.
- **Remarketing** — recuperar usuarios que ya conocen la marca.
- **Lead generation** — captar leads con formularios nativos.
- **Visual offer testing** — probar variantes de oferta visualmente.
- **Audience signal discovery** — descubrir señales de audiencia que funcionan.

Meta Ads NO es bueno para:

- Capturar demanda existente con alta intención (eso es Google Ads).
- Reemplazar producto o oferta débil.
- Compensar landing pages con fricción.

---

## 2. QUÉ ANALIZAR EN UNA CUENTA

### 2.1 Campaign objective

¿El objetivo de la campaña está alineado con el outcome de negocio del cliente?

Errores comunes:
- Objetivo "Reach" cuando se necesita conversiones.
- Objetivo "Engagement" cuando se busca leads.
- Objetivo "Traffic" cuando hay tracking de conversiones disponible.

### 2.2 Creative

- **Hook** — ¿captura atención en 3 segundos?
- **Visual clarity** — ¿se entiende sin sonido?
- **Format** — ¿el formato es apto para placement?
- **Message** — ¿claro? ¿coherente con marca?
- **Offer** — ¿hay oferta explícita?
- **CTA** — ¿llamada a acción única y clara?
- **Fatigue** — ¿el creativo está saturado?
- **Comments** — ¿qué dice la gente en comentarios?

### 2.3 Audience

- **Broad vs segmented** — ¿la audiencia tiene sentido?
- **Interest quality** — ¿los intereses son relevantes?
- **Lookalikes** — ¿basadas en fuente de calidad?
- **Remarketing** — ¿está configurado y se usa?
- **Exclusions** — ¿se evita pisado entre campañas?
- **Saturation** — ¿la audiencia se está agotando?

### 2.4 Delivery

- **CPM** — ¿alto o bajo? ¿por qué?
- **Frequency** — ¿>3-4? ¿saturación?
- **Learning phase** — ¿salió de aprendizaje?
- **Budget distribution** — ¿se está distribuyendo bien?
- **Placement performance** — ¿qué placement performa?

### 2.5 Click quality

- **CTR** — ¿está dentro de benchmark de la categoría?
- **CPC** — ¿alto / bajo? ¿por qué?
- **Landing behavior** — ¿bounce rate? ¿time on page?
- **WhatsApp quality** — si lleva a WhatsApp, ¿calidad de conversación?
- **Lead quality** — si genera leads, ¿son cualificados?

### 2.6 Conversion

- **CPL / CPA** — ¿alineado con KPI?
- **Qualified leads** — ¿pasan a sales?
- **Sales** — si es ecommerce, ¿hay tracking?
- **ROAS** — ¿sustentable para el cliente?

---

## 3. LECTURAS COMUNES

### High CTR + Low conversion

**Posibles causas:**
- Creativo atrae atención pero intent incorrecto (clickbait).
- Landing / WhatsApp tiene fricción.
- Mismatch entre oferta del ad y oferta del landing.
- Audiencia muy broad, atrae curiosos sin intención.

**Qué hacer:**
- Auditar landing.
- Verificar que el ad refleje la oferta real.
- Probar segmentación más afinada.

---

### Low CTR + High CPM

**Posibles causas:**
- Creativo débil (no resuena).
- Audiencia muy chica o saturada.
- Mensaje no relevante para la audiencia.
- Competencia alta en auction.

**Qué hacer:**
- Probar variantes de creativo.
- Ampliar audiencia.
- Refinar mensaje (con `copywriter`).

---

### Low CPC + Bad leads

**Posibles causas:**
- Audiencia barata pero con baja calidad.
- Form muy fácil (cualquiera completa).
- Oferta muy broad (atrae todo el mundo).

**Qué hacer:**
- Filtrar formulario con preguntas cualificadoras.
- Refinar audiencia.
- Especificar oferta.

---

### High frequency + Falling CTR

**Posibles causas:**
- Fatiga creativa (mismo creativo demasiadas veces).
- Saturación de audiencia.

**Qué hacer:**
- Refrescar creativos.
- Ampliar audiencia.
- Pausar y rotar.

---

### Good leads + High CPL

**No siempre es problema.**

Antes de cortar:
- Calcular ROAS, CAC, ticket promedio, margen.
- ¿El CAC sigue siendo sustentable?
- ¿La calidad del lead compensa el costo?

Si todo cuadra → mantener.
Si no → optimizar audience / creative / oferta.

---

## 4. ESTRUCTURA RECOMENDADA DE CUENTA

### Nivel campaña

Separar por objetivo:
- Conversión (la principal).
- Tráfico (si es para descubrir).
- Awareness (si aplica).

### Nivel conjunto de anuncios (ad set)

- 1 ad set por tipo de audiencia.
- Audiencias bien diferenciadas (no overlap).
- Exclusiones configuradas.

### Nivel anuncios (ads)

- Mínimo 3 variantes de creativo por ad set.
- Máximo 5-6 ads por ad set (más diluye presupuesto).
- 1 creativo de "control" estable + 2-3 variantes testeando.

---

## 5. ERRORES TÍPICOS — QUÉ NO HACER

- ❌ **Subir presupuesto** antes de arreglar el waste.
- ❌ **Ignorar search terms** (en Performance Max).
- ❌ **Tratar todas las conversiones iguales** (lead ≠ venta).
- ❌ **Optimizar Meta Ads sin revisar landing**.
- ❌ **Confiar en CPL bajo** sin verificar calidad.
- ❌ **Lanzar sin pixel configurado**.
- ❌ **Lanzar sin UTMs** en URLs.
- ❌ **Cambiar 10 cosas a la vez** y no saber qué movió.
- ❌ **Optimizar solo por CPC** (CPC bajo + lead malo = perder plata).
- ❌ **Culpar al algoritmo** antes de revisar creative / offer / funnel.

---

## 6. CHECKLIST PRE-LAUNCH

Antes de activar una campaña:

- [ ] Objetivo de campaña alineado con outcome de negocio.
- [ ] KPIs explícitos definidos.
- [ ] Pixel configurado.
- [ ] Audiencias definidas con criterio (no genéricas).
- [ ] Exclusiones configuradas.
- [ ] Creatividades aprobadas por marca.
- [ ] Copys validados.
- [ ] CTAs claros.
- [ ] UTMs presentes en URLs.
- [ ] Landing pages testeadas.
- [ ] Budget aprobado por humano.
- [ ] Pasó **Paid Media Gate**.

---

## 7. CADENCIA DE OPTIMIZACIÓN

### Diario
- Verificar performance básica (no entrar en pánico).

### Semanal
- Revisar creativos (¿hay fatiga?).
- Revisar audiencias (¿saturación?).
- Ajustar pequeño.

### Mensual
- Reporte completo.
- Decisiones estructurales.

### Trimestral
- Audit profundo de cuenta.

---

## 8. INTEGRACIÓN CON GROWTH

Las campañas de Meta pueden ser **experimentos** en sí mismos.

Para usarlas como tests:
- Hipótesis explícita.
- Variable controlada (creative, audience, offer).
- Decisión rules pre-definidas.
- Análisis post-test estructurado.

Ver `growth-marketing-playbook.md` para framework.

---

**FIN META ADS PLAYBOOK**
