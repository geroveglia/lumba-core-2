# package.json — snippet para Stack A

Agregá esto al `package.json` del proyecto (no reemplaces todo el archivo, solo sumá estas claves).

## Scripts

```json
{
  "scripts": {
    "dev": "vite",
    "build": "tsc -b && vite build",
    "preview": "vite preview",
    "lint": "eslint .",
    "lint:fix": "eslint . --fix",
    "format": "prettier --write .",
    "format:check": "prettier --check .",
    "typecheck": "tsc --noEmit",
    "prepare": "husky"
  }
}
```

## devDependencies

```bash
npm i -D prettier prettier-plugin-tailwindcss \
  eslint @eslint/js typescript-eslint globals \
  eslint-plugin-react-hooks eslint-plugin-react-refresh \
  husky lint-staged
```

## lint-staged (en package.json)

```json
{
  "lint-staged": {
    "*.{ts,tsx}": ["eslint --fix", "prettier --write"],
    "*.{json,css,md}": ["prettier --write"]
  }
}
```

## Activar el hook (una vez por proyecto)

```bash
npx husky init
# copiar .husky/pre-commit de este template sobre el generado
chmod +x .husky/pre-commit
```
