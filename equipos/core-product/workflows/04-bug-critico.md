# Workflow 4: Bug Crítico en Producción

## Cuándo se usa
- Bug que afecta usuarios en producción.
- Severidad: critical o high.

## Pasos

```
1. PM o desarrollador detecta y reporta.
2. qa-engineer → confirma reproducibilidad y severidad.
3. Bypass autorizado por humano (socio o PM):
   - Severity Critical → fix urgente con proceso mínimo.
   - Severity High → fix priorizado en próximo deploy.
4. Desarrollador + frontend/backend-architect → diseño del fix.
5. Implementación.
6. qa-engineer → verifica fix + regresión.
7. code-reviewer → review (acelerado pero presente).
8. devops-engineer → deploy con plan de rollback.
9. qa-engineer → smoke tests post-deploy.
10. Comunicación a cliente si aplica.
11. Post-mortem obligatorio dentro de 48h.
```

## Skills involucradas
- `qa-test-plan`
- `deployment-checklist`

## Output
- Fix en producción.
- Documento de post-mortem.
- Update de tests para evitar regresión.

## Quality Gate
- Software Gate (incluso en bypass).

## Regla crítica
Bypass NO significa saltarse process. Significa correr el proceso comprimido y registrarlo.
