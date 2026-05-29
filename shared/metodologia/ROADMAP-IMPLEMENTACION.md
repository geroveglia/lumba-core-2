# ROADMAP DE IMPLEMENTACIÓN — LUMBA CORE

> **Versión:** v1.0 (Lumba Core)
> **Tono:** Manual operativo + estratégico.
> **Propósito:** definir el orden de implementación de Lumba Core en producción real.
> **Última actualización:** 23 de mayo de 2026.

---

## 1. OBJETIVO

Llevar Lumba Core de **documentación a operación real** sin romper procesos vigentes ni saturar al equipo.

**Lema operativo:** "introducir, validar, expandir". No big-bang.

---

## 2. PRINCIPIOS DEL ROADMAP

1. **Minuta primero.** Es el piloto donde se prueban todos los procesos sin riesgo de cliente externo.
2. **Una red por vez.** No activar las 3 redes simultáneamente.
3. **Read-only antes que write.** Primer agente de cada red es solo lectura.
4. **Métricas desde día 1.** No avanzamos sin data.
5. **Devil's Advocate obligatorio en cada gate de avance.**
6. **Validación humana en cada hito mayor.**

---

## 3. FASES — VISIÓN GENERAL

```
FASE 0  →  Setup técnico inicial
FASE 1  →  Construir Minuta con Core-Product (piloto)
FASE 2  →  Activar Core-Product en proyectos de cliente
FASE 3  →  Activar Core-Marketing
FASE 4  →  Activar Core-Brand
FASE 5  →  Operación completa + optimización continua
```

Cada fase tiene **criterios de salida** explícitos. No se avanza si no se cumplen.

---

## 4. FASE 0 — SETUP TÉCNICO INICIAL

**Duración estimada:** 1-2 semanas.

### Qué hacemos

- Crear workspace Lumba Core en GitHub privado.
- Configurar estructura de carpetas (ya hecha en el ZIP de setup).
- Conectar Vercel y Supabase.
- Configurar Claude Code con CLAUDE.md global.
- Crear primer subagent (Devil's Advocate, read-only).
- Validar funcionamiento con 5-10 tareas pequeñas.

### Criterios de salida

- [ ] Workspace en GitHub privado funcionando.
- [ ] Claude Code lee CLAUDE.md correctamente.
- [ ] Devil's Advocate read-only operativo.
- [ ] 5 tareas de validación pasaron.
- [ ] Tracking de costos activado.

### Responsable

Esteban + Claude Code.

---

## 5. FASE 1 — PILOTO MINUTA CON CORE-PRODUCT

**Duración estimada:** 3-4 meses.

### Por qué Minuta como piloto

- Es interno (sin riesgo de cliente externo si algo falla).
- Tiene scope claro (ya tenemos MEMORIA-MINUTA).
- Permite probar los 12 agentes de Core-Product en condiciones reales.
- Genera baseline real de costos.
- Valida workflows de auditoría y brief obsesivo en producción.
- Si funciona acá, sabemos que funciona para clientes.

### Qué hacemos

#### Mes 1
- Configurar los 12 agentes de Core-Product (uno por semana).
- Cada agente se introduce read-only primero, después gradualmente write.
- Discovery + definición funcional de Minuta con Core-Product.
- Devil's Advocate audita cada decisión clave.

#### Mes 2
- Diseño UX/UI con UX Designer + UI Designer.
- Arquitectura técnica con Backend Architect + Data Architect.
- Setup de infra (Stack A: Vite + Supabase + Vercel).
- Construcción de Sprint 1 + Sprint 2.

#### Mes 3
- Sprints 3-5: features principales.
- QA + Code Reviewer activos.
- Product Auditor en cada entrega.
- Deploy a staging.

#### Mes 4
- Sprint 6: pulido + bugs.
- Deploy a producción.
- Primer uso real con el equipo de Lumba.
- Recolección de feedback.

### Criterios de salida

- [ ] Minuta MVP en producción.
- [ ] 12 agentes de Core-Product probados.
- [ ] Workflow de auditoría operativo.
- [ ] Brief obsesivo aplicado en todos los entregables.
- [ ] Datos reales de costo de tokens (baseline para presupuesto futuro).
- [ ] >60% de entregables pasaron auditoría al primer intento.
- [ ] Devil's Advocate detectó al menos 3 riesgos críticos prevenidos.

### Métricas a recolectar durante la fase

- Costo total de tokens del piloto.
- Costo por agente.
- Tiempo promedio por sprint.
- Cantidad de bugs en QA vs producción.
- % de auditorías pasadas al primer intento.
- Satisfacción del equipo de Lumba usando Minuta.

### Responsables

- Esteban (founder Minuta + operativo Lumba).
- Equipo de desarrollo (5 personas) acompañando con Core-Product.

---

## 6. FASE 2 — ACTIVAR CORE-PRODUCT EN CLIENTES

**Duración estimada:** 2-3 meses.

### Pre-requisito

Fase 1 cerrada con métricas en verde.

### Qué hacemos

- Activar Core-Product en 1-2 proyectos de cliente.
- Empezar por proyectos con menor riesgo y mayor afinidad.

### Candidatos sugeridos

`[INFERENCIA — basada en clientes activos. Validar con socios.]`

- **RUS Market** (proyecto en evolución continua, equipo familiarizado).
- **Dicomere ecommerce** (mantenimiento + evolutivos).

### Adaptaciones

- Cada cliente tiene su `MEMORIA-CLIENTE.md`.
- Workflows se ajustan según procesos del cliente.
- Devil's Advocate es especialmente crítico en proyectos cliente.

### Criterios de salida

- [ ] 2 proyectos de cliente operando con Core-Product.
- [ ] >55% de entregables pasaron sin corrección post-cliente.
- [ ] Equipo del cliente no detectó disrupciones.
- [ ] Costos dentro del budget.
- [ ] No hubo incidentes de seguridad.

---

## 7. FASE 3 — ACTIVAR CORE-MARKETING

**Duración estimada:** 2-3 meses.

### Por qué Marketing antes que Brand

Según tu respuesta del Bloque 10: priorizás Core-Product y Core-Marketing primero.

Marketing tiene **mayor volumen de entregables** (calendarios, copys, campañas). El impacto en reducir correcciones es proporcionalmente mayor.

### Qué hacemos

#### Mes 1 — Setup
- Configurar los 10 agentes de Core-Marketing.
- Read-only primero.
- Memoria de marketing por cliente.

#### Mes 2 — Piloto con 1 cliente
- Elegir 1 cliente de marketing con volumen alto (Dicomere o CanCat).
- Operar 1 mes completo con Core-Marketing.
- Medir.

#### Mes 3 — Expansión
- Sumar 2-3 clientes más.
- Refinar workflows según aprendizajes.

### Criterios de salida

- [ ] 3-4 clientes operando con Core-Marketing.
- [ ] Reportes con insights (no solo datos) en >80% de los casos.
- [ ] Calendarios con estrategia documentada en >90% de los casos.
- [ ] >60% de campañas con KPIs claros antes de lanzar.

---

## 8. FASE 4 — ACTIVAR CORE-BRAND

**Duración estimada:** 2-3 meses.

### Por qué último

Branding tiene menor volumen que Marketing y menor riesgo técnico que Product. Es donde el equipo puede operar con menos soporte de agentes inicialmente.

### Qué hacemos

Similar a Fase 3 pero con los 7 agentes de Core-Brand.

### Piloto sugerido

- **Profecía** (ya está en proceso de branding).
- O un proyecto de branding nuevo cuando llegue.

### Criterios de salida

- [ ] Al menos 1 proyecto de branding completo con Core-Brand.
- [ ] Workshops estratégicos estructurados con `workshop-facilitator`.
- [ ] Manual de marca generado parcialmente por agentes.
- [ ] Auditoría visual aplicada en >80% de entregables visuales.

---

## 9. FASE 5 — OPERACIÓN COMPLETA + OPTIMIZACIÓN

**A partir del mes 12 (aproximadamente).**

### Qué hacemos

- 3 redes operando en paralelo.
- Múltiples clientes activos en cada red.
- Métricas de salud monitoreadas semanalmente.
- Skills se actualizan según aprendizajes.
- Agentes se ajustan según data real.

### Hitos esperados

- **Mes 12:** primera revisión completa del sistema.
- **Mes 18:** decisión sobre escalar a 50 personas (con Lumba Core operando).
- **Mes 24:** revisión estratégica de Lumba Core (¿algún cambio mayor?).

### Métricas de éxito de la fase

- % entregas sin corrección >70%.
- Costo de tokens <2% de facturación.
- Equipo reporta satisfacción >4/5.
- Onboarding de nuevos colaboradores <2 semanas.
- Lumba Core es percibido como ventaja competitiva interna.

---

## 10. GATES DE AVANCE

Cada fase tiene un **gate** antes de avanzar a la siguiente.

```
GATE = REVISIÓN OBLIGATORIA POR:
1. Devil's Advocate audita la fase completa.
2. PM Lumba revisa métricas.
3. Esteban valida criterios de salida.
4. (Si aplica) Hernán y Martín validan.
5. Decisión: avanzar / iterar / retroceder.
```

**No se avanza saltando gates.**

---

## 11. ANTI-PATTERNS DE IMPLEMENTACIÓN

Cosas que NO hacemos:

- ❌ Activar las 3 redes simultáneamente.
- ❌ Saltarse el piloto de Minuta y arrancar directo con clientes.
- ❌ Introducir agentes con write desde día 1.
- ❌ Avanzar a una fase nueva sin cerrar la anterior.
- ❌ Esconder problemas para "no parar el roadmap".
- ❌ Cambiar el orden por presión comercial.

---

## 12. RIESGOS Y MITIGACIONES

| Riesgo | Probabilidad | Mitigación |
|---|---|---|
| Minuta no se termina en 4 meses | Alta | Sprints cortos, revisión semanal, MVP-first |
| Costos de tokens más altos de lo esperado | Media | Tracking semanal, alertas, ajustes de modelo |
| Equipo resiste el cambio | Media | Onboarding gradual, training, demostrar valor con Minuta |
| Clientes no perciben mejora | Baja | Métrica norte mensual + comparación pre/post |
| Devil's Advocate genera fricción excesiva | Media | Ajustar checklist tras 30 días reales |
| Algún agente con permisos amplios genera error | Media | Permisos mínimos por default + auditoría |
| Falta de skills calificados para operar el sistema | Media | Documentación clara + academia interna (futuro) |

---

## 13. RESPONSABILIDADES POR FASE

| Fase | Responsable principal | Apoyo |
|---|---|---|
| Fase 0 | Esteban | Claude Code |
| Fase 1 | Esteban + equipo dev | Claude Code |
| Fase 2 | Esteban + PM del cliente | Equipo dev |
| Fase 3 | Esteban + equipo marketing | PM, Hernán/Martín |
| Fase 4 | Equipo branding + Hernán | Esteban |
| Fase 5 | Los 3 socios | Equipo completo |

---

## 14. CRONOGRAMA ESTIMADO

```
2026 Q2-Q3 → Fase 0 + Fase 1 (Minuta MVP)
2026 Q4    → Fase 2 (Core-Product en clientes)
2027 Q1    → Fase 3 (Core-Marketing)
2027 Q2    → Fase 4 (Core-Brand)
2027 Q3+   → Fase 5 (Operación completa)
```

`[INFERENCIA — Cronograma estimado. Ajustar según capacidad real del equipo.]`

---

## 15. CHECKLIST DE VALIDACIÓN PARA ESTEBAN

- [ ] El orden de fases tiene sentido (Minuta primero, después Product, Marketing, Brand).
- [ ] Los criterios de salida de cada fase son razonables.
- [ ] Los gates obligatorios no van a frenar excesivamente.
- [ ] Los responsables por fase son los correctos.
- [ ] El cronograma es factible.
- [ ] Los riesgos están identificados.
- [ ] Las inferencias marcadas están resueltas.

---

**FIN ROADMAP DE IMPLEMENTACIÓN**
