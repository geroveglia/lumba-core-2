# Workflow 3: Desarrollo de Feature

## Cuándo se usa
- Para cada feature del backlog.

## Pasos

```
1. product-owner → priorización en sprint
2. analyst-functional → spec final + criterios de aceptación
3. frontend-architect + backend-architect → diseño técnico
4. data-architect → modelo de datos si aplica
5. (ADRs si hay decisiones técnicas mayores)
6. devops-engineer → preparación de entorno si aplica
7. Desarrollo (humano + agentes coding cuando aplique)
8. qa-engineer → test plan
9. code-reviewer → review pre-merge
10. product-auditor → audit (Software Gate)
11. devops-engineer → deploy con plan de rollback
12. qa-engineer → smoke tests post-deploy
13. Validación humana + cliente si aplica
```

## Skills involucradas
- `functional-specification`
- `adr-generator`
- `code-review-checklist`
- `qa-test-plan`
- `deployment-checklist`

## Output
- Feature en producción.
- ADRs generados si aplica.
- Documentación actualizada.

## Quality Gate
- Software Gate (pre-merge + pre-deploy).
- Client Gate si entrega al cliente.

## Duración estimada
Variable según feature.

## Validaciones humanas obligatorias
- Code review humano.
- Aprobación de deploy.
