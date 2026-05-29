# CONVENCIONES DE CÓDIGO — Stack A

> Lo que el linter NO puede enforzar automáticamente. Estas reglas las sostienen el dev, el `code-quality-agent` y el `/review-pr`.
> El formato (comillas, indentación, comas) NO está acá: lo resuelve Prettier solo. Acá va lo estructural.

---

## 1. Estructura de carpetas

```
src/
├── components/        # componentes reutilizables (no atados a una página)
│   └── ui/            # primitivos shadcn/ui
├── features/          # features por dominio (cada una con sus componentes, hooks, tipos)
│   └── [feature]/
│       ├── components/
│       ├── hooks/
│       ├── api.ts     # llamadas a Supabase de esa feature
│       └── types.ts
├── lib/               # utilidades puras, clientes (supabase.ts), helpers
├── hooks/             # hooks globales compartidos
├── pages/             # vistas / rutas
└── types/             # tipos globales compartidos
```

Regla: si algo se usa en una sola feature, vive dentro de esa feature. Solo sube a `components/`, `hooks/` o `types/` cuando lo comparten 2+ features.

## 2. Nombrado

- **Componentes:** PascalCase, archivo igual al componente → `UserCard.tsx`.
- **Hooks:** camelCase con prefijo `use` → `useUserProfile.ts`.
- **Utilidades / no-componentes:** camelCase → `formatCurrency.ts`.
- **Tipos e interfaces:** PascalCase, descriptivos → `UserProfile`, no `Data` ni `Props2`.
- **Constantes globales:** UPPER_SNAKE_CASE.
- **Carpetas:** kebab-case.
- Nada de abreviaturas crípticas (`usr`, `btnHdlr`). El nombre se lee, no se descifra.

## 3. Componentes React

- Un componente por archivo. Si pasa de ~150 líneas, partilo.
- Props tipadas con `interface`, no `any`, no `object`.
- Componentes funcionales + hooks. Nada de clases.
- Lógica de datos en hooks (`useX`), no mezclada en el JSX.
- Estados de UI siempre cubiertos: loading / empty / error / éxito.

## 4. TypeScript

- `strict` activo. Prohibido `any` sin comentario que justifique por qué.
- Prohibido `@ts-ignore` sin explicación al lado.
- Tipá los datos de Supabase (generá tipos desde el schema, no `as`).
- Preferí `type`/`interface` explícitos a inferencia cuando es un contrato público.

## 5. Funciones

- Una función hace una sola cosa. Si el nombre lleva "y" (`validateAndSave`), probablemente son dos.
- Máximo razonable de parámetros: 3. Más que eso → objeto de opciones.
- Evitá nesting profundo: early return en vez de `if` anidados.

## 6. Imports

- Usá el alias `@/` para imports internos (`@/lib/supabase`), no rutas relativas largas (`../../../lib`).
- Orden: librerías externas → internos `@/` → relativos. (Prettier/ESLint ayudan, pero respetalo al escribir.)

## 7. Manejo de errores

- Nada de `catch` vacío. Si lo catcheás, lo manejás o lo propagás con contexto.
- Errores de Supabase: chequear `error` siempre antes de usar `data`.
- Nada de `console.log` en código que va a producción (el linter lo marca; `warn`/`error` permitidos).

## 8. Comentarios

- Comentá el **por qué**, no el **qué**. El qué se lee en el código.
- Un `TODO` sin owner ni issue asociado no pasa el review.

## 9. Tests

- Lógica de negocio y utilidades: con test.
- UI crítica (auth, pagos, flujos de conversión): con test.
- No exigimos 100% de coverage; exigimos que lo riesgoso esté cubierto.

## 10. Regla que ordena todo lo demás

> El código se escribe una vez y se lee cien veces. Optimizá para quien lo va a leer y mantener, no para terminar rápido.
