# CODING STANDARDS — LUMBA CORE

> **Versión:** v1.0
> **Tono:** Manual técnico operativo.
> **Propósito:** lograr que **todo el código del equipo salga igual**: limpio, seguro, sin líneas de más y claro para que cualquier dev pueda trabajar sobre él.
> **Última actualización:** 23 de mayo de 2026.

---

## 1. EL PRINCIPIO

> La uniformidad no se logra revisando. Se logra automatizando.

Una revisión por criterio (humano o agente) es **probabilística**: dos revisiones del mismo código marcan cosas distintas. Eso nunca produce código idéntico — produce código "más o menos parejo".

El formato, el estilo, las líneas de más, los imports muertos y el tipado son **ejecución determinística**. Eso es trabajo de **herramientas**, no de criterio. (Arquitectura WAT: separar lo probabilístico de lo determinístico.)

**Conclusión:** la igualdad la da la máquina. El criterio se reserva para lo que la máquina no puede juzgar.

---

## 2. LAS DOS CAPAS

```
┌──────────────────────────────────────────────────────────────┐
│ CAPA DETERMINÍSTICA (herramientas)  → igualdad automática      │
│ Prettier · ESLint · tsconfig strict · pre-commit hooks · CI    │
│ Resuelve: formato, líneas de más, código muerto, tipado.       │
│ Aplica las MISMAS reglas a todos, siempre, sin excepción.      │
├──────────────────────────────────────────────────────────────┤
│ CAPA PROBABILÍSTICA (agentes + humano) → criterio              │
│ /review-pr: code-reviewer + security-agent + code-quality-agent│
│ Resuelve: diseño, lógica, seguridad lógica, comprensión.       │
│ Solo se ocupa de lo que la máquina NO puede chequear.          │
└──────────────────────────────────────────────────────────────┘
```

Si saltás la capa determinística, el `/review-pr` se llena de "te falta un espacio" / "sobra esta variable" y se vuelve sello de goma. Con la capa determinística abajo, la revisión se concentra en lo que importa.

---

## 3. LA CAPA DETERMINÍSTICA (Stack A)

Config compartida y versionada en `shared/infra/stack-a-config/`. No es opinable por proyecto.

| Herramienta | Qué garantiza |
|---|---|
| **Prettier** | Formato idéntico para todos. No se discute, lo corre la máquina. |
| **ESLint** (flat config) | Caza variables/imports sin usar, `any`, `var`, `==`, `console.log`, `debugger`. |
| **tsconfig strict** | `strict` + `noUnusedLocals` + `noUnusedParameters` + `noUncheckedIndexedAccess`. Mata código muerto y fuerza claridad. |
| **Husky + lint-staged** | Corre format+lint+typecheck **antes del commit**. El código sucio nunca llega al PR. |
| **CI** | Mismos checks en cada PR. Bloquean el merge si fallan. Igual para todos. |

Detalle de cada archivo y cómo aplicarlo: `shared/infra/stack-a-config/README.md`.
Convenciones que el linter no enforza (carpetas, naming, patrones): `shared/infra/stack-a-config/CONVENTIONS.md`.

---

## 4. EL ORDEN CORRECTO

```
1. Dev escribe código
2. git commit  → pre-commit hook: Prettier + ESLint + typecheck
                 (si falla, NO commitea — se arregla solo o el dev corrige)
3. Push + PR   → CI corre format:check + lint + typecheck + tests
                 (si falla, NO se puede mergear)
4. /review-pr  → code-reviewer + security-agent + code-quality-agent + las
                 preguntas al dev (¿entendés lo que vas a mergear?)
5. Merge       → solo con CI verde + review APPROVED
```

Cuando el dev llega al paso 4, el formato y el código muerto **ya están resueltos**. El humano y los agentes discuten diseño, lógica y seguridad — no estilo.

---

## 5. REGLAS DURAS

- ❌ No se commitea código que no pasa el pre-commit hook.
- ❌ No se mergea con CI en rojo.
- ❌ No se edita la config base por proyecto sin justificación escrita en el README del proyecto.
- ❌ No hay `any` sin comentario, ni `console.log` en producción, ni `TODO` sin owner.
- ✅ Todo proyecto Stack A arranca con la config de `shared/infra/stack-a-config/` aplicada.

---

## 6. RELACIÓN CON LOS GATES

Esta capa es el **paso 0 del Software Gate** (ver `shared/metodologia/QUALITY-GATES.md`, sección 11): los checks determinísticos corren y pasan **antes** de que el `code-reviewer` mire una línea. Sin CI verde, el `/review-pr` ni arranca.

---

**FIN DE CODING STANDARDS**
