# Workflow 06: Post-Launch (Semana 1)

> **Se ejecuta inmediatamente después del deploy a producción.**
> **Duración: 7 días. Lo que diferencia una agencia buena de una que entrega y desaparece.**

---

## Principio

> **El deploy no es el final. La primera semana en producción es donde se valida todo.**
>
> Sin Post-Launch, entregás y desaparecés. Con Post-Launch, demostrás que te importa lo que construiste.

---

## Cuándo se usa

- **Obligatorio** después de todo deploy a producción de un proyecto nuevo.
- También aplica a releases mayores (v2.0, redesign completo).
- No aplica a hotfixes o deploys incrementales de features.

---

## Pasos

```
DÍA 1-2 — MONITORING ACTIVO

1. devops-engineer → verificar métricas de infraestructura
   ├── Uptime (>99.5% target)
   ├── Tiempos de respuesta (p95 < 500ms)
   ├── Errores 4xx/5xx (tasa < 0.1%)
   ├── Consumo de recursos (CPU, memoria, DB connections)
   └── Alertas configuradas y funcionando

2. qa-engineer → smoke test en producción
   ├── Happy path completo: registro → compra → pago
   ├── Mobile + desktop
   ├── Navegadores principales (Chrome, Safari, Firefox)
   └── Geolocalización si aplica

DÍA 3-5 — MÉTRICAS DE NEGOCIO

3. data-analyst → primeras métricas
   ├── Usuarios únicos
   ├── Tasa de conversión
   ├── Tasa de rebote
   ├── Páginas más visitadas
   ├── Dispositivos y navegadores
   └── Errores en checkout (si ecommerce)

4. business-strategist → validación de hipótesis iniciales
   ├── ¿Los usuarios están haciendo lo que esperábamos?
   ├── ¿Hay fricciones no detectadas en QA?
   └── ¿El funnel funciona como se diseñó?

DÍA 6-7 — HOTFIXES + AJUSTES

5. dev-team (frontend + backend) → hotfixes críticos
   ├── Bugs encontrados en producción (P0 y P1)
   ├── Ajustes de configuración (timeouts, rate limits)
   └── Optimizaciones de queries lentas

6. product-owner → backlog post-launch
   ├── Issues detectados → priorizados
   ├── Quick wins identificados
   └── Plan de siguientes 2 semanas

7. retrospective-agent → retrospectiva de lanzamiento
   ├── ¿Qué salió bien?
   ├── ¿Qué salió mal?
   ├── ¿Qué haríamos diferente?
   └── Lecciones aprendidas → /knowledge/aprendizajes/
```

---

## Outputs

- `outputs/06-post-launch-report.md` — reporte completo de la semana 1:
  - Estado de infraestructura.
  - Métricas clave de negocio.
  - Bugs encontrados y resueltos.
  - Validación de hipótesis.
  - Backlog priorizado para siguientes sprints.
- `outputs/06-retrospectiva.md` — lecciones aprendidas.
- `knowledge/aprendizajes/{proyecto}-post-launch.md` — conocimiento reutilizable.

---

## Quality Gate

- **Stability Gate** — el proyecto se considera "estable" cuando:
  - Uptime >99.5% durante 7 días consecutivos.
  - Zero errores P0 sin resolver.
  - Métricas de negocio dentro del rango esperado (±30%).
  - Cliente notificado y conforme.

---

## Duración estimada

7 días corridos (no horas hombre, sino ventana de observación).

---

## Validación humana

- Reporte diario a Gero por Telegram durante los primeros 3 días.
- Reporte final al cliente al cierre de la semana 1.
- Si hay errores P0 → notificación inmediata, no esperar al reporte.

---

## Anti-patterns

- ❌ "Deployamos un viernes y nos vamos el finde."
- ❌ "El cliente no pidió monitoreo, no lo hacemos."
- ❌ "Las métricas son solo para proyectos grandes."
- ❌ "Si hay bugs, los arreglamos en el próximo sprint (en 2 semanas)."
- ❌ "No necesitamos retrospectiva, ya sabemos lo que pasó."

---

**Workflow 06** · Post-Launch · ⚡
