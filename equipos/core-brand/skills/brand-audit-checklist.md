---
name: brand-audit-checklist
version: 1.0
team: core-brand
last_updated: 2026-05-23
used_by: [brand-auditor]
---

# Skill: Brand Audit Checklist

## Propósito

Checklist exhaustivo que el `brand-auditor` ejecuta antes de aprobar cualquier entregable de branding.

## Aplicación

**Obligatorio antes de:**
- Presentar diagnóstico al cliente.
- Presentar propuesta estratégica.
- Presentar identidad visual.
- Presentar brandbook.
- Cualquier pieza visual que vaya al cliente.

## Checklist completo

### Sección 1 — Estratégico

- [ ] La pieza responde al posicionamiento aprobado.
- [ ] El mensaje está alineado con tono de voz definido.
- [ ] Conecta con territorios conceptuales aprobados.
- [ ] Diferencia de competencia analizada (no se parece a competidor).
- [ ] Resuelve el problema de marca identificado en el diagnóstico.
- [ ] La propuesta de valor está clara.

### Sección 2 — Visual

- [ ] Respeta sistema visual aprobado.
- [ ] Usa paleta cromática oficial (no colores nuevos).
- [ ] Usa tipografías del sistema (no fonts random).
- [ ] Jerarquía visual clara (qué se lee primero, segundo, tercero).
- [ ] Aplicación correcta del logotipo (zona de respeto, color, tamaño).
- [ ] Coherencia entre elementos visuales.

### Sección 3 — Mensaje

- [ ] Copy aplica reglas de tono de voz.
- [ ] No usa palabras del anti-tono.
- [ ] Mensaje principal claro al primer escaneo.
- [ ] CTAs explícitos cuando aplica.
- [ ] Sin clichés de la categoría.

### Sección 4 — Coherencia

- [ ] Conecta con entregables anteriores del mismo cliente.
- [ ] MEMORIA-MARCA del cliente está al día.
- [ ] No contradice criterios aprobados previamente.
- [ ] No introduce elementos sin aprobación.

### Sección 5 — Brief

- [ ] Cumple el objetivo del brief original.
- [ ] Respeta las restricciones declaradas.
- [ ] Decisor final identificado.
- [ ] Plazo de entrega coherente con calendario.

### Sección 6 — Calidad técnica

- [ ] Archivos en formatos correctos (vectorial, RGB/CMYK según corresponde).
- [ ] Resoluciones correctas.
- [ ] No hay errores tipográficos.
- [ ] No hay errores ortográficos.
- [ ] Capas / componentes organizados.

### Sección 7 — Anti-genérico

- [ ] No parece "cualquier marca de la categoría".
- [ ] No usa lugares comunes visuales.
- [ ] No usa imágenes stock genéricas (a menos que sea intencional).
- [ ] Tiene personalidad propia detectable.

## Resultado

### Si TODOS los checkboxes pasan
✅ `approve` — el entregable avanza al cliente.

### Si fallan 1-3 checkboxes
⚠️ `fix_and_resubmit` — vuelve al productor con feedback específico.

### Si fallan >3 checkboxes
❌ `reject` — replanteo mayor necesario.

### Si fallan checkboxes críticos (Sección 1)
❌ `reject` — el problema es estratégico, no de ejecución.

## Output del audit

JSON Schema D (Audit Report) con:
- Checklist completo marcado.
- Findings críticos vs menores.
- Recomendación.
- Justificación de cada falla.
