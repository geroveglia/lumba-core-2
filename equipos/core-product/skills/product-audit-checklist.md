---
name: product-audit-checklist
version: 1.0
team: core-product
last_updated: 2026-05-23
used_by: [product-auditor]
---

# Skill: Product Audit Checklist

## Pre-development (UX/Product Gate)

### Especificación funcional
- [ ] Objetivo claro.
- [ ] User stories con criterios de aceptación.
- [ ] Casos de uso (happy + edge + error).
- [ ] Permisos y roles definidos.
- [ ] Reglas de negocio explícitas.
- [ ] Integraciones identificadas.
- [ ] Out of scope marcado.

### UX/UI
- [ ] Flows lógicos.
- [ ] Estados de pantalla completos (loading/empty/error/success).
- [ ] Responsive (mobile/tablet/desktop).
- [ ] Accesibilidad WCAG AA.
- [ ] Consistencia con sistema de diseño.

## Pre-deploy (Software Gate)

### Código
- [ ] Tests passing en CI.
- [ ] Code review aprobado.
- [ ] Sin secrets en repo.
- [ ] Variables de entorno fuera del código.
- [ ] Sin TODOs sin owner.

### Performance
- [ ] Lighthouse score aceptable.
- [ ] Queries optimizadas.

### Seguridad
- [ ] RLS configurada.
- [ ] Inputs sanitizados.
- [ ] Sin endpoints expuestos sin auth.

### Deploy
- [ ] Plan de rollback definido.
- [ ] Monitoring activo.
- [ ] Backups recientes.

## Pre-entrega al cliente (Client Gate)

- [ ] Documentación actualizada.
- [ ] README claro.
- [ ] Acceso entregado correctamente.
- [ ] Capacitación al cliente si aplica.

**Si falta cualquier checkbox crítico, el entregable no avanza.**
