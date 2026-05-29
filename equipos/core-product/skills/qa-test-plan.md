---
name: qa-test-plan
version: 1.0
team: core-product
last_updated: 2026-05-23
used_by: [qa-engineer]
---

# Skill: QA Test Plan

## Estructura

### 1. Scope
- Qué se testea.
- Qué NO se testea.

### 2. Tipos de testing
- Functional.
- Visual / UI.
- Cross-browser.
- Responsive (mobile / tablet / desktop).
- Accesibilidad.
- Performance.

### 3. Casos de prueba
Por cada user story:
- Happy path test.
- Edge case tests.
- Error case tests.

### 4. Datos de prueba
- Usuarios de prueba.
- Datos de prueba.
- Estados de prueba.

### 5. Criterios de salida
- 0 bugs críticos.
- <X bugs de severidad media.
- Coverage mínimo de tests automáticos.

## Bug report template

```
## Bug: [título corto]

### Severidad
[Critical / High / Medium / Low]

### Steps to reproduce
1.
2.
3.

### Expected
[qué debería pasar]

### Actual
[qué pasa]

### Environment
- Browser:
- Device:
- OS:
- URL:

### Screenshots / Video
[adjuntar]
```
