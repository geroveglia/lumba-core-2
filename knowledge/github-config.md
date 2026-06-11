# GitHub Configuration — Lumba

> **Estado:** ⏳ PENDIENTE — No implementado. Esperando cuenta/org de Lumba en GitHub.
> **Última actualización:** 10 de junio de 2026

---

## Modelo elegido (Opción A ✅)

**Una cuenta/org de GitHub de Lumba es dueña de todos los repos.**

- `lumba-core-2` en `github.com/lumba-io/lumba-core-2`
- Cada proyecto: `github.com/lumba-io/{slug}`
- Desarrolladores colaboran como contributors con sus cuentas personales
- OpenClaw usa un token de la cuenta de Lumba para crear repos automáticamente
- En `lumba-core-2/proyectos/{slug}/` se guarda solo el registro liviano (repo.url + state)

---

## Lo que falta para activarlo

- [ ] Crear cuenta/org de Lumba en GitHub (ej: `lumba-io` o `lumba-studio`)
- [ ] Generar un token de GitHub con permisos de `repo` y `admin:org`
- [ ] Configurar el token en OpenClaw como secret/provider
- [ ] Activar el paso de creación de repo en el Workflow 00

---

## Cómo va a funcionar cuando esté activo

Cuando Gero diga `nuevo proyecto {nombre}`:

1. Workflow 00 se ejecuta normalmente (assessment, clasificación, squad)
2. Al confirmar, se pregunta: "¿Creo el repo en GitHub también?"
3. Si sí → OpenClaw crea el repo en `github.com/lumba-io/{slug}`, lo deja listo
4. Se registra en `proyectos/{slug}/repo.url`
5. Se notifica a Gero: "Repo creado en github.com/lumba-io/{slug}. Clonalo donde quieras"

---

## Estructura de `proyectos/{slug}/` (liviana)

```
proyectos/{slug}/
├── repo.url              ← github.com/lumba-io/{slug}
├── state.json            ← fase actual, última actividad
└── MEMORIA-PROYECTO.md   ← contexto, decisiones, aprendizajes
```

Sin outputs, drafts, overrides, approvals, handoffs — eso vive en cada repo individual.

---

## Variables de entorno necesarias

| Variable | Valor esperado |
|---|---|
| `GITHUB_TOKEN` | Token con scope `repo` y `admin:org` |
| `GITHUB_ORG` | `lumba-io` (o el nombre de la org) |
| `GITHUB_ACCOUNT_TYPE` | `org` |
