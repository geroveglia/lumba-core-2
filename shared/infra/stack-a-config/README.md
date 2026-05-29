# Config base — Stack A (Vite + React + TypeScript)

Configuración determinística compartida para que **todo proyecto Stack A salga igual**: mismo formato, mismas reglas, mismo tipado estricto. No es opinable por proyecto.

Ver el porqué y cómo encaja con `/review-pr` en `shared/infra/CODING-STANDARDS.md`.

## Qué hay acá

| Archivo | Para qué |
|---|---|
| `.prettierrc.json` | Formato idéntico para todos (Prettier). |
| `eslint.config.js` | Reglas de código + detección de código muerto (ESLint 9 flat config). |
| `tsconfig.json` | TypeScript strict + chequeos extra (`noUnusedLocals`, `noUncheckedIndexedAccess`, etc.). |
| `.editorconfig` | Consistencia entre editores. |
| `.husky/pre-commit` | Corre format+lint+typecheck antes de cada commit. |
| `package.snippet.md` | Scripts, devDependencies y config de lint-staged para sumar al `package.json`. |
| `CONVENTIONS.md` | Reglas estructurales que el linter no enforza (carpetas, naming, patrones). |

## Cómo aplicarlo a un proyecto nuevo

1. Copiá `.prettierrc.json`, `eslint.config.js`, `tsconfig.json`, `.editorconfig` y la carpeta `.husky/` a la raíz del proyecto.
2. Copiá `CONVENTIONS.md` a `docs/` del proyecto.
3. Seguí `package.snippet.md`: agregá los scripts, instalá las devDependencies, sumá la config de `lint-staged` y activá husky.
4. Verificá que corre:
   ```bash
   npm run format:check && npm run lint && npm run typecheck
   ```
5. Configurá el mismo trío en CI para que bloquee el PR si falla.

> `/new-project` (Stack A) deja esta config aplicada automáticamente. Esto es para aplicarla a mano o a proyectos existentes.
