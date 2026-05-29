---
name: functional-specification
version: 1.0
team: core-product
last_updated: 2026-05-23
used_by: [analyst-functional]
---

# Skill: Functional Specification

## Estructura por feature

### 1. Objetivo
- Qué problema resuelve.
- A quién sirve.
- Valor de negocio.

### 2. User stories
Formato: "Como [rol], quiero [acción], para [beneficio]."

### 3. Criterios de aceptación
Lista de condiciones que deben cumplirse.

```
DADO [contexto inicial]
CUANDO [acción]
ENTONCES [resultado esperado]
```

### 4. Casos de uso
- Happy path (camino feliz).
- Edge cases (casos límite).
- Error cases (cuando algo falla).

### 5. Permisos y roles
- Quién puede ver.
- Quién puede editar.
- Quién puede eliminar.
- Restricciones especiales.

### 6. Reglas de negocio
Lógica explícita (no asumida).

### 7. Integraciones
- APIs externas necesarias.
- Datos que entran / salen.
- Manejo de errores de integración.

### 8. Estados de pantalla
- Loading.
- Empty (sin datos).
- Error.
- Success.
- Filled (con datos).

### 9. Out of scope
Lo que NO incluye esta feature.

## Reglas
- NO entregar spec sin criterios de aceptación.
- NO asumir reglas de negocio (preguntar).
- SÍ documentar edge cases.
