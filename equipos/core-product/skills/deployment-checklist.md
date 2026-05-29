---
name: deployment-checklist
version: 1.0
team: core-product
last_updated: 2026-05-23
used_by: [devops-engineer]
---

# Skill: Deployment Checklist

## Pre-deploy

- [ ] Tests passing en CI.
- [ ] Code review aprobado.
- [ ] Variables de entorno configuradas en target.
- [ ] Migrations preparadas.
- [ ] Backup reciente de DB.
- [ ] Plan de rollback documentado.
- [ ] Monitoring activo.
- [ ] Cambio comunicado al equipo.
- [ ] Cliente informado si aplica.

## Durante el deploy

- [ ] Ejecutar migrations primero (si aplica).
- [ ] Verificar variables de entorno cargadas.
- [ ] Smoke tests post-deploy.
- [ ] Verificar logs sin errores nuevos.

## Post-deploy

- [ ] Verificar metrics normales (Sentry, Vercel Analytics).
- [ ] Probar flow crítico manualmente.
- [ ] Confirmar a equipo.
- [ ] Update de MEMORIA-PROYECTO.

## Si algo falla

```
1. NO entrar en pánico.
2. Ejecutar plan de rollback.
3. Verificar que rollback funcionó.
4. Comunicar al equipo.
5. Análisis post-mortem.
```

## Regla de hierro
**Sin plan de rollback, no hay deploy.**
