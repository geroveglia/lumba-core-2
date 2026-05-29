# STACKS TIPIFICADOS — LUMBA CORE v1.0

> **Versión:** v1.0
> **Tono:** Manual técnico.
> **Propósito:** definir los 3 stacks técnicos estándar de Lumba.
> **Última actualización:** 23 de mayo de 2026.

---

## 1. POR QUÉ STACKS TIPIFICADOS

Tener stacks definidos permite:

- Decisión rápida al iniciar proyecto.
- Reutilización de skills y agentes.
- Menos errores de configuración.
- Costos predecibles.
- Onboarding más rápido.

**Regla:** todo proyecto nuevo elige uno de estos 3 stacks, salvo justificación del Founder.

---

## 2. STACK A — SERVERLESS GESTIONADO

### Usar para
- SaaS web (Minuta, productos internos).
- MVPs.
- Ecommerce moderno.
- Productos para agencias.
- Proyectos con bajo a medio tráfico.

### Stack técnico

| Capa | Tecnología |
|---|---|
| Frontend | Vite + React + TypeScript |
| Styling | Tailwind CSS + shadcn/ui |
| Backend | Supabase (Postgres + Auth + Realtime + Edge Functions) |
| AI | Gemini API / Claude API según caso |
| Hosting | Vercel |
| CDN | Vercel Edge Network |
| Email transaccional | Resend |
| Storage | Supabase Storage |
| Monitoring | Vercel Analytics + Sentry |

### Costo estimado mensual

- USD 0–50 (MVP / desarrollo).
- USD 50–200 (producción con tráfico bajo-medio).
- USD 200–500 (producción con tráfico medio-alto).

### Cuándo NO usar

- Si el cliente exige on-premise.
- Si hay compliance estricto (sector regulado, datos sensibles bajo control físico).
- Si necesitás procesamiento batch pesado.

### % de proyectos esperados con este stack

**~80% de los proyectos nuevos.**

---

## 3. STACK B — CONTENEDORES GESTIONADOS

### Usar para
- Backend con lógica pesada.
- Jobs largos o procesamiento batch.
- Proyectos que requieren control fino del runtime.
- Migraciones desde sistemas legacy.
- Casos con dependencias específicas de OS.

### Stack técnico

| Capa | Tecnología |
|---|---|
| Frontend | Vite + React + TypeScript |
| Backend | Docker en Railway / Fly.io / Render |
| DB | Supabase o Postgres gestionado |
| Hosting frontend | Vercel |
| Container orchestration | Plataforma gestionada (no K8s) |
| Monitoring | Sentry + plataforma host |

### Costo estimado mensual

- USD 100–300 (proyecto medio).
- USD 300–500 (proyecto medio-alto).

### Cuándo usar específicamente

- Necesitás un worker que procesa cosas en background.
- Necesitás dependencias nativas (FFmpeg, librerías específicas de OS).
- Necesitás websockets persistentes a escala.
- Necesitás integración con sistemas legacy del cliente.

### % de proyectos esperados con este stack

**~15% de los proyectos nuevos.**

---

## 4. STACK C — KUBERNETES

### Usar para
- Cliente enterprise que lo exige.
- Escala enorme (>1M usuarios activos).
- Compliance estricto con control granular.
- Proyectos con presupuesto alto y operación dedicada.

### Stack técnico

| Capa | Tecnología |
|---|---|
| Cluster | GKE / EKS / DigitalOcean K8s |
| Frontend | Vite + React + TypeScript |
| Backend | Microservicios en Go / Node / Python |
| DB | PostgreSQL gestionado o self-hosted |
| Mensajería | RabbitMQ / Kafka según caso |
| CI/CD | ArgoCD + Helm charts |
| Monitoring | Prometheus + Grafana + Sentry |

### Costo estimado mensual

- USD 500+ (mínimo razonable).
- USD 1000–3000 (típico).

### Cuándo NO usar

- Si Stack A o B alcanzan.
- Si no hay equipo con experiencia en K8s.
- Si el cliente no entiende los costos asociados.

### % de proyectos esperados con este stack

**~5% de los proyectos nuevos.**

---

## 5. STACK LEGACY (heredado)

### Contexto

Lumba tiene proyectos en producción con stack PHP / MySQL tradicional.

`[INFERENCIA — basada en propuestas previas. Validar qué proyectos están activos en este stack.]`

### Stack técnico

| Capa | Tecnología |
|---|---|
| Frontend | HTML5 + CSS3 + JS + Bootstrap |
| Backend | PHP 7/8 o PHP 8.2 |
| DB | MySQL |
| Hosting | Servidores tradicionales (cPanel, VPS) |
| Integraciones | Mercado Pago, sistemas de gestión |

### Política con stack legacy

- **NO se inicia un proyecto nuevo en stack legacy.**
- **SÍ se mantienen** proyectos existentes en este stack.
- **SÍ se migran** proyectos viejos a Stack A cuando hay oportunidad comercial.
- Los agentes de Core-Product que trabajan en stack legacy tienen skills específicos.

---

## 6. MATRIZ DE DECISIÓN

Para elegir stack rápido:

```
¿Es proyecto interno o cliente típico?
  └─ Sí → STACK A (default)

¿Necesita procesamiento batch / workers pesados?
  └─ Sí → STACK B

¿Cliente enterprise + compliance + escala extrema?
  └─ Sí → STACK C

¿Es mantenimiento de proyecto existente?
  └─ Mantener stack actual
  └─ Considerar migración si hay oportunidad
```

---

## 7. PROHIBICIONES

- ❌ No usar Stack C "por si crecemos".
- ❌ No usar Stack legacy para proyectos nuevos.
- ❌ No mezclar stacks dentro de un mismo proyecto sin justificación.
- ❌ No agregar tecnologías "porque están de moda" si Stack A las cubre.

---

## 8. STACK PARA MINUTA (primer caso de uso real)

**Decisión:** Stack A.

| Componente | Implementación |
|---|---|
| Frontend | Vite + React + TypeScript |
| UI | Tailwind + shadcn/ui |
| Backend | Supabase (Postgres + Auth + Realtime + Edge Functions) |
| AI | Gemini API (con abstracción de provider) |
| Hosting | Vercel |
| Multi-tenant | Implementado desde MVP |

Razón: Es SaaS web típico. Stack A es la opción óptima.

---

## 9. ESTÁNDAR DE CÓDIGO (obligatorio en todo proyecto)

Elegir el stack no alcanza para que el código salga parejo. Todo proyecto Stack A
arranca además con la **capa determinística** de calidad: Prettier + ESLint +
tsconfig strict + pre-commit hooks + CI.

- **Config base lista para copiar:** `shared/infra/stack-a-config/`
- **El porqué y cómo encaja con `/review-pr`:** `shared/infra/CODING-STANDARDS.md`
- **Convenciones (carpetas, naming, patrones):** `shared/infra/stack-a-config/CONVENTIONS.md`

**Regla:** el formato y el código muerto los resuelve la máquina antes del PR.
El `/review-pr` se reserva para diseño, lógica, seguridad y comprensión.

---

## 10. EVOLUCIÓN DE STACKS

Esta lista se revisa cada 6 meses para verificar:

- Si las tecnologías siguen vigentes.
- Si aparecieron alternativas mejores.
- Si los costos cambiaron significativamente.
- Si Lumba tiene experiencia para adoptar algo nuevo.

**Cambios mayores en stacks requieren aprobación del Founder.**

---

## 11. CHECKLIST DE VALIDACIÓN

- [ ] Los 3 stacks cubren los casos típicos.
- [ ] El stack legacy está acotado.
- [ ] La matriz de decisión es operable.
- [ ] Stack A para Minuta está validado.

---

**FIN STACKS TIPIFICADOS**
