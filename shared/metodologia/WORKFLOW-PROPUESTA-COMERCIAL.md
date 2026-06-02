# Workflow: Propuesta Comercial

> **Se ejecuta entre Brief y Discovery.**
> **El cliente tiene que firmar antes de que corra un solo agente más.**

---

## Principio

> **Sin contrato firmado, no se mueve un agente.**
>
> La propuesta comercial traduce el brief en un compromiso económico concreto: qué se va a hacer, en cuánto tiempo, por cuánto dinero.

---

## Cuándo se usa

- **Obligatorio** después del Brief para TODO proyecto de cliente.
- No aplica a proyectos internos de Lumba (como Minuta).

---

## Pasos

```
1. PM Agent → traduce brief a estructura de propuesta
   ├── Alcance del proyecto (qué incluye, qué NO incluye)
   ├── Fases y timeline estimado
   ├── Entregables por fase
   └── Supuestos y dependencias

2. business-strategist → pricing y modelo de negocio
   ├── Precio por fase o precio total
   ├── Forma de pago (anticipo + hitos)
   ├── Costos adicionales (infraestructura, licencias, dominios)
   └── Comparativa con proyectos similares

3. scope-agent → validación de alcance
   ├── ¿Está claro qué NO incluye?
   ├── ¿Los supuestos son razonables?
   └── ¿Hay dependencias del cliente identificadas?

4. devils-advocate → challenge a la propuesta
   ├── ¿El timeline es realista?
   ├── ¿El precio cubre el costo real (incluyendo tokens)?
   ├── ¿Hay riesgos no identificados?
   └── ¿El margen es saludable?

5. PM Agent → versión final de propuesta
   └── Documento listo para enviar al cliente

6. HUMANO → envía propuesta al cliente
7. CLIENTE → revisa, negocia, firma (o rechaza)
8. HUMANO → registra resultado en state.json
```

---

## Output

- `outputs/propuesta-comercial.md` — documento completo con:
  - Resumen ejecutivo.
  - Alcance detallado (qué incluye y qué NO).
  - Fases, timeline, y entregables por fase.
  - Precio, forma de pago, y condiciones.
  - Supuestos y dependencias del cliente.
  - Próximos pasos post-firma.

---

## Quality Gate

- **Commercial Gate** — la propuesta debe pasar Devil's Advocate antes de enviarse al cliente.
- Si el DA detecta margen negativo o timeline imposible → bloquear hasta ajustar.

---

## Duración estimada

1-2 días (preparación) + tiempo de respuesta del cliente (típicamente 3-7 días).

---

## Rejection Flow

| Escenario | Acción |
|---|---|
| Cliente pide ajustes menores | PM ajusta propuesta, re-envía (máx 2 iteraciones) |
| Cliente rechaza por precio | business-strategist revisa scope, propone alternativas |
| Cliente rechaza por timeline | PM ajusta fases o reduce MVP |
| Cliente rechaza definitivamente | Cerrar proyecto, archivar en `clientes/{nombre}/perdidos/` |
| Cliente no responde en 7 días | Cron job re-notifica. A los 14 días: escalar al Founder |

---

## Anti-patterns

- ❌ "Arranquemos igual, después firmamos."
- ❌ "El cliente es amigo, no hace falta propuesta formal."
- ❌ "No especifiquemos qué NO incluye para no asustar."
- ❌ "Pongamos un precio bajo para ganar el proyecto y después vemos."
- ❌ "No calculemos el costo de tokens en el precio."

---

**Workflow: Propuesta Comercial** · ⚡
