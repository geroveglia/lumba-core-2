---
name: code-review-checklist
version: 1.0
team: core-product
last_updated: 2026-05-23
used_by: [code-reviewer]
---

# Skill: Code Review Checklist

## Funcional
- [ ] Resuelve el problema descrito en el PR.
- [ ] Cumple criterios de aceptación.
- [ ] Tests asociados.
- [ ] Edge cases considerados.

## Seguridad
- [ ] No hay secrets en código.
- [ ] Variables de entorno usadas correctamente.
- [ ] Sin inyección SQL.
- [ ] Sanitización de inputs.
- [ ] RLS verificada en queries a Supabase.

## Performance
- [ ] Queries N+1 evitadas.
- [ ] Imágenes optimizadas.
- [ ] Lazy loading donde corresponde.
- [ ] Sin renders innecesarios en React.

## Mantenibilidad
- [ ] Naming claro.
- [ ] Funciones cortas (idealmente <50 líneas).
- [ ] Sin código duplicado.
- [ ] Sin TODOs sin owner.

## TypeScript
- [ ] Sin `any` injustificado.
- [ ] Tipos exportados donde aplica.
- [ ] Sin `@ts-ignore` sin explicación.

## Tests
- [ ] Tests passing en CI.
- [ ] Cobertura razonable para feature crítica.

## Documentación
- [ ] README actualizado si aplica.
- [ ] Comments en código complejo.
