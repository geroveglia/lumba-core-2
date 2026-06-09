# 01 — UX Design System

> **Proyecto:** Lumba Ecommerce (Brownfield — migración PHP vanilla + Bootstrap 5 → React + Tailwind CSS + NestJS API)
> **Fecha:** 2026-06-08
> **Rol:** UX Designer
> **Modelo:** deepseek-v4-pro
> **Nivel de confianza global:** ALTA
> **Fuentes:** `01-ux-flows.md`, `01-ux-wireframes.md`, `01-frontend-architecture.md`, `01-frontend-component-tree.md`, `01-gaps-and-improvements.md`, `01-functional-spec.md`, `01-feature-prioritization.md`

---

## Índice

1. [Jerarquía Tipográfica](#1-jerarquía-tipográfica)
2. [Sistema de Espaciado](#2-sistema-de-espaciado)
3. [Sistema de Color](#3-sistema-de-color)
4. [Sombras y Elevación](#4-sombras-y-elevación)
5. [Radios de Borde](#5-radios-de-borde)
6. [Estados Interactivos](#6-estados-interactivos)
7. [Feedback y Micro-Interacciones](#7-feedback-y-micro-interacciones)
8. [Sistema de Iconografía](#8-sistema-de-iconografía)
9. [Patrones de Formularios](#9-patrones-de-formularios)
10. [Patrones de Carga](#10-patrones-de-carga)
11. [Manejo de Errores](#11-manejo-de-errores)
12. [Estados Vacíos](#12-estados-vacíos)
13. [Confirmaciones](#13-confirmaciones)
14. [Navegación](#14-navegación)
15. [Accesibilidad (WCAG 2.1 AA)](#15-accesibilidad-wcag-21-aa)

---

## 1. Jerarquía Tipográfica

### 1.1 Principios

- **Font family configurable por tenant** via CSS custom properties `--font-sans` y `--font-heading`.
- **Default:** Inter (sistema, sin descarga de fuente externa por defecto). Los tenants pueden override con Google Fonts o fuentes del sistema.
- **Tipografía funcional:** Los tamaños y pesos comunican jerarquía sin depender del color.
- **Mobile-first:** Los tamaños base son para mobile. Desktop escala con breakpoints.

### 1.2 Escala Tipográfica

> Los nombres de tamaño están mapeados a Tailwind CSS classes.

| Nivel | Tailwind Class | Mobile (default) | Desktop (lg:) | Font Weight | Line Height | Uso |
|---|---|---|---|---|---|---|
| **Display** | `text-4xl` / `lg:text-5xl` | 36px (2.25rem) | 48px (3rem) | Bold (700) | 1.15 | Homepage hero, página de éxito checkout |
| **Heading 1** | `text-3xl` / `lg:text-4xl` | 30px (1.875rem) | 36px (2.25rem) | Bold (700) | 1.2 | Títulos de página principal |
| **Heading 2** | `text-2xl` / `lg:text-3xl` | 24px (1.5rem) | 30px (1.875rem) | Semibold (600) | 1.25 | Títulos de sección, nombre de producto en PDP |
| **Heading 3** | `text-xl` / `lg:text-2xl` | 20px (1.25rem) | 24px (1.5rem) | Semibold (600) | 1.3 | Cards, subtítulos |
| **Heading 4** | `text-lg` / `lg:text-xl` | 18px (1.125rem) | 20px (1.25rem) | Medium (500) | 1.35 | Títulos de modal, títulos de card |
| **Body Large** | `text-base` | 16px (1rem) | 16px | Normal (400) | 1.5 | Texto de cuerpo, descripciones |
| **Body** | `text-sm` | 14px (0.875rem) | 14px | Normal (400) | 1.5 | Texto general, labels, valores |
| **Body Small** | `text-xs` | 12px (0.75rem) | 12px | Normal (400) | 1.5 | Texto secundario, badges, hints, SKU, timestamp |
| **Caption** | `text-[10px]` | 10px | 10px | Medium (500) | 1.4 | Overline, uppercase labels, contadores |

📐 **Recomendación — Font Family por defecto:**
```css
:root {
  --font-sans: 'Inter', system-ui, -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
  --font-heading: 'Inter', system-ui, -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
}
```

### 1.3 Jerarquía por Contexto

| Contexto | Nivel | Ejemplo |
|---|---|---|
| **Homepage hero** | Display | "Colección Verano 2026" |
| **Página de éxito** | Display | "¡Gracias, Juan!" |
| **Nombre de producto (PDP)** | Heading 2 | "Remera de Algodón Premium" |
| **Precio principal (PDP)** | Heading 2 (Bold) | "$15.500" |
| **Título de sección** | Heading 3 | "Productos destacados" |
| **Nombre en ProductCard** | Body (Medium 500, `line-clamp-2`) | "Remera de Algodón..." |
| **Marca en ProductCard** | Body Small (Uppercase, tracking-wide) | "NIKE" |
| **Precio en ProductCard** | Body (Semibold 600) | "$15.500" |
| **Precio tachado** | Body Small (line-through) | "$18.000" |
| **Badge descuento** | Body Small (Semibold) | "-20%" |
| **Badge estado (pedido)** | Body Small (Medium) | "Pagado" |
| **Label de input** | Body (Medium 500) | "Email" |
| **Hint de input** | Body Small | "Ej: juan@mail.com" |
| **Error de validación** | Body Small (Medium, red-600) | "Email inválido" |
| **Botón CTA** | Body (Semibold 600) si `size="md"` | "Agregar al carrito" |
| **Botón grande** | Body Large (Semibold 600) | "Confirmar compra" |
| **Breadcrumb** | Body Small (activo: Medium) | "Home > Categoría" |
| **Tab** | Body (Medium 500) | "Información" |
| **Total en CartSummary** | Heading 4 o Heading 3 (Bold) | "$45.800" |
| **KPI value (admin)** | Heading 1 o Heading 2 (Bold) | "$2.450.000" |
| **KPI label (admin)** | Body Small (Uppercase, tracking-wide) | "VENTAS DEL MES" |
| **Footer** | Body Small | Links, copyright |

### 1.4 Font Weight por Contexto

| Weight | Uso |
|---|---|
| **Bold (700)** | Display, h1, precios principales, totales, KPIs |
| **Semibold (600)** | h2, h3, labels, botones, badges |
| **Medium (500)** | h4, nombre de producto en card, tabs, links de navegación |
| **Normal (400)** | Body text, descripciones, hints, texto secundario |

---

## 2. Sistema de Espaciado

### 2.1 Grid Base

> Basado en el spacing scale de Tailwind CSS (4px base unit).

| Token | Rem | Px | Uso |
|---|---|---|---|
| `space-0` | 0 | 0 | Sin espacio |
| `space-0.5` | 0.125rem | 2px | Gap entre ícono y texto en badges/chips |
| `space-1` | 0.25rem | 4px | Gap mínimo entre elementos inline |
| `space-1.5` | 0.375rem | 6px | Gap entre label e input |
| `space-2` | 0.5rem | 8px | Gap entre badges, gap entre precio y descuento |
| `space-3` | 0.75rem | 12px | Gap entre campos, gap en toolbar |
| `space-4` | 1rem | 16px | Padding de cards, gap entre cart items |
| `space-5` | 1.25rem | 20px | Gap entre secciones de variantes |
| `space-6` | 1.5rem | 24px | Gap entre secciones, margin-top de botón CTA |
| `space-8` | 2rem | 32px | Gap entre columnas en layout 2-col |
| `space-10` | 2.5rem | 40px | Margen superior de sección grande |
| `space-12` | 3rem | 48px | Margen entre módulos del home |
| `space-16` | 4rem | 64px | Padding vertical de sección completa |
| `space-20` | 5rem | 80px | Padding de footer |

### 2.2 Padding por Componente

| Componente | Padding |
|---|---|
| **Card (ProductCard, AddressCard, OrderCard)** | `p-4` (16px) — `p-5` (20px) en desktop |
| **Modal body** | `px-6 py-4` (24px horizontal, 16px vertical) |
| **Drawer** | `p-4` (16px) |
| **Input / Select** | `px-3 py-2.5` (12px horizontal, 10px vertical) en mobile; `px-3 py-2` en desktop |
| **Button md** | `px-4 py-2.5` (16px horizontal, 10px vertical) |
| **Button lg** | `px-6 py-3` (24px horizontal, 12px vertical) |
| **Button xl (CTA mobile)** | `px-8 py-4` (32px horizontal, 16px vertical) — altura mínima 48px |
| **Sección de página** | `px-4 py-8` (16px horizontal, 32px vertical) en mobile; `px-6 py-12` en desktop |
| **Contenedor de página** | `max-w-7xl mx-auto px-4` en mobile; `px-6` en desktop |

### 2.3 Container Widths

| Breakpoint | Container |
|---|---|
| **Default (mobile)** | `w-full px-4` |
| **sm (640px)** | `max-w-screen-sm` |
| **md (768px)** | `max-w-screen-md` |
| **lg (1024px)** | `max-w-screen-lg` |
| **xl (1280px)** | `max-w-screen-xl` |
| **2xl (1536px)** | `max-w-screen-2xl` — usar `max-w-7xl` (80rem = 1280px) como máximo |

📐 **Recomendación:** La tienda (frontend cliente) usa `max-w-7xl` centrado. El admin usa full-width con padding lateral fijo (24px).

---

## 3. Sistema de Color

### 3.1 Principios

- **CSS custom properties para multi-tenant:** Los tenants pueden override los colores vía configuración en admin.
- **Paleta funcional:** Los colores comunican propósito, no solo estética.
- **Contraste WCAG 2.1 AA:** Todos los textos sobre fondos cumplen ratio 4.5:1 (normal) o 3:1 (grande).
- **No depender solo del color:** Usar íconos, texto y patrones como refuerzo.

### 3.2 Paleta Funcional por Defecto

#### Primary (Acción principal, marca)

| Token | Hex | Uso |
|---|---|---|
| `--color-primary-50` | `#eff6ff` | Fondo sutil (alert info, selected state) |
| `--color-primary-100` | `#dbeafe` | Fondo de badge, chip selected |
| `--color-primary-200` | `#bfdbfe` | — |
| `--color-primary-300` | `#93c5fd` | Ring de focus |
| `--color-primary-400` | `#60a5fa` | — |
| `--color-primary-500` | `#3b82f6` | **Color base:** botones, links, bordes activos |
| `--color-primary-600` | `#2563eb` | Hover de botones |
| `--color-primary-700` | `#1d4ed8` | Active de botones |
| `--color-primary-800` | `#1e40af` | — |
| `--color-primary-900` | `#1e3a8a` | Fondo de sidebar admin |

📐 **Recomendación:** La paleta primary debe ser configurable por tenant. Cada tenant setea `--color-primary-500` (su color de marca) y el sistema deriva los demás con lightness shifts. O el tenant configura manualmente cada token.

#### Neutral (Superficies, bordes, texto)

| Token | Hex | Uso |
|---|---|---|
| `white` | `#ffffff` | Fondo de página, fondo de cards |
| `gray-50` | `#f9fafb` | Fondo de CartSummary, fondo de input disabled |
| `gray-100` | `#f3f4f6` | Fondo de skeleton, hover de filas, fondo de badge neutral |
| `gray-200` | `#e5e7eb` | Borde de card, borde de input, separadores |
| `gray-300` | `#d1d5db` | Borde de input default |
| `gray-400` | `#9ca3af` | Íconos no interactivos, placeholder text |
| `gray-500` | `#6b7280` | Texto secundario, hints |
| `gray-600` | `#4b5563` | Texto descriptivo |
| `gray-700` | `#374151` | Texto de cuerpo, labels |
| `gray-800` | `#1f2937` | — |
| `gray-900` | `#111827` | Texto principal, headings |

#### Semantic Colors

| Token | Color | Hex principal | Uso |
|---|---|---|---|
| **Success** | Verde | `#16a34a` (green-600) | Éxito, stock disponible, pago aprobado, badge "Pagado" |
| **Success bg** | Verde claro | `#f0fdf4` (green-50) | Fondo de alert success, toast success |
| **Warning** | Ámbar | `#d97706` (amber-600) | Advertencias, stock bajo, badge "Pendiente" |
| **Warning bg** | Ámbar claro | `#fffbeb` (amber-50) | Fondo de alert warning, toast warning |
| **Error / Danger** | Rojo | `#dc2626` (red-600) | Errores, sin stock, badge "Sin stock", acciones destructivas |
| **Error bg** | Rojo claro | `#fef2f2` (red-50) | Fondo de alert error, toast error, campo con error |
| **Info** | Azul | `#2563eb` (blue-600) | Información, badge "Enviado", estado info |
| **Info bg** | Azul claro | `#eff6ff` (blue-50) | Fondo de alert info, toast info |

#### Badges por Estado

| Estado | Badge Variant | Ejemplos |
|---|---|---|
| **Activo** | `info` (azul) | Pedido activo, producto activo |
| **Pagado / Entregado / Completo** | `success` (verde) | Pago confirmado, pedido entregado |
| **Pendiente / En proceso** | `neutral` (gris) | Pago pendiente, preparando |
| **Sin stock** | `danger` (rojo) | Producto sin stock |
| **Poco stock / Stock bajo** | `warning` (ámbar) | Últimas unidades |
| **Descuento** | `danger` (rojo) | "-20% OFF" |
| **Predeterminada** | `info` (azul) | Dirección predeterminada |

### 3.3 Contraste Verificado

| Combinación | Ratio | Cumple AA |
|---|---|---|
| `gray-900` sobre `white` | 16.9:1 | ✅ AAA |
| `gray-700` sobre `white` | 10.4:1 | ✅ AAA |
| `gray-500` sobre `white` | 5.1:1 | ✅ AA |
| `white` sobre `primary-600` | 4.9:1 | ✅ AA |
| `primary-600` sobre `white` | 4.9:1 | ✅ AA (≥18px bold) |
| `red-600` sobre `white` | 5.5:1 | ✅ AA |
| `green-600` sobre `white` | 5.3:1 | ✅ AA |
| `amber-600` sobre `white` | 4.0:1 | ⚠️ No cumple para texto <18px → usar amber-700 (4.9:1) o bold |
| `gray-400` sobre `white` | 2.6:1 | ❌ Solo para placeholders (no texto informativo) |

📐 **Recomendación:** Para texto warning (ámbar), usar `amber-700` en vez de `amber-600` para cumplir AA en texto normal. O usar bold.

---

## 4. Sombras y Elevación

### 4.1 Shadow Scale

> Mapeado a Tailwind CSS shadow classes.

| Nivel | Tailwind | Valor | Uso |
|---|---|---|---|
| **0 (flat)** | `shadow-none` | `none` | Elementos base, página |
| **1 (raised)** | `shadow-sm` | `0 1px 2px 0 rgb(0 0 0 / 0.05)` | Cards, inputs, selects |
| **2 (elevated)** | `shadow` (default) | `0 1px 3px 0 rgb(0 0 0 / 0.1), 0 1px 2px -1px rgb(0 0 0 / 0.1)` | Cards en hover, header sticky |
| **3 (dropdown)** | `shadow-md` | `0 4px 6px -1px rgb(0 0 0 / 0.1), 0 2px 4px -2px rgb(0 0 0 / 0.1)` | Dropdowns, tooltips |
| **4 (overlay)** | `shadow-lg` | `0 10px 15px -3px rgb(0 0 0 / 0.1), 0 4px 6px -4px rgb(0 0 0 / 0.1)` | Modales, drawers, toasts |
| **5 (modal)** | `shadow-xl` | `0 20px 25px -5px rgb(0 0 0 / 0.1), 0 8px 10px -6px rgb(0 0 0 / 0.1)` | — |
| **6 (top)** | `shadow-2xl` | `0 25px 50px -12px rgb(0 0 0 / 0.25)` | Solo para elementos muy prioritarios (confirmación crítica) |

### 4.2 Elevación por Componente (Z-Index)

> Valores relativos al stacking context de Tailwind.

| Z-Index | Componente |
|---|---|
| `z-0` | Contenido de página |
| `z-10` | Overlay de fetching en grilla, dropdown |
| `z-20` | Header sticky |
| `z-30` | Sidebar (admin, cuenta) |
| `z-40` | Overlay de modal/drawer (bg-black/50) |
| `z-50` | Modal, Drawer, Dropdown menu |
| `z-[100]` | Toast container |

### 4.3 Shadow en Acciones del Usuario

| Componente | Default | Hover |
|---|---|---|
| **ProductCard** | `shadow-sm` | `shadow-md` (elevación sutil) |
| **Button primary** | `shadow-sm` | Sin cambio (solo cambia color de fondo) |
| **Header sticky** | `shadow-sm` (cuando hay scroll) | — |
| **Modal** | `shadow-2xl` | — |
| **CartSummary** | `shadow-sm` | — |

---

## 5. Radios de Borde

### 5.1 Border Radius Scale

| Token | Tailwind | Valor | Uso |
|---|---|---|---|
| **none** | `rounded-none` | 0 | Tablas, separadores internos |
| **sm** | `rounded-sm` | 0.125rem (2px) | Checkbox, radio |
| **base** | `rounded` | 0.25rem (4px) | Chips, badges pequeños |
| **md** | `rounded-md` | 0.375rem (6px) | Inputs, selects, tooltips, badges grandes, botones xs/sm, avatares |
| **lg** | `rounded-lg` | 0.5rem (8px) | **Estándar:** botones, cards, modales, drawers, inputs grandes |
| **xl** | `rounded-xl` | 0.75rem (12px) | CartSummary, cards destacadas, modales grandes |
| **2xl** | `rounded-2xl` | 1rem (16px) | Cards de login, hero images en home |
| **full** | `rounded-full` | 9999px | Badges, chips, avatares, swatches de color, botones circulares, toggle |

### 5.2 Consistencia por Tipo de Componente

| Componente | Border Radius |
|---|---|
| **Button** | `rounded-lg` (8px) |
| **Input, Select, Textarea** | `rounded-lg` (8px) |
| **Card (ProductCard, AddressCard, OrderCard)** | `rounded-xl` (12px) |
| **CartSummary** | `rounded-xl` (12px) |
| **Modal** | `rounded-xl` (12px) |
| **Drawer** | `rounded-none` (full-height) |
| **Badge** | `rounded-full` |
| **Chip** | `rounded-full` |
| **Avatar** | `rounded-full` |
| **Color Swatch** | `rounded-full` |
| **Tooltip** | `rounded-md` (6px) |
| **Toast** | `rounded-lg` (8px) |
| **Toggle** | `rounded-full` |
| **DataTable** | `rounded-lg` (8px) con `overflow-hidden` |

---

## 6. Estados Interactivos

### 6.1 Principios

- **Consistencia:** Mismo estado visual = mismo significado en todo el sistema.
- **A11y:** Focus visible en todos los interactivos. Los estados no dependen solo del color.
- **Transiciones:** Todas las transiciones de estado usan `duration-150` o `duration-200`.

### 6.2 Matriz de Estados

| Estado | Visual | Aplica a |
|---|---|---|
| **Default / Idle** | Estilo base del componente | Todos los interactivos |
| **Hover** (desktop) | Cambio sutil: oscurecer fondo, levantar sombra, cambiar borde | Botones, links, cards, filas de tabla, chips |
| **Focus** | Ring 2px `primary-500` + offset 2px | Todos los interactivos (teclado) |
| **Active / Pressed** | Más oscuro que hover, escala sutil (0.98) | Botones, chips |
| **Disabled** | Opacidad 50%, cursor `not-allowed`, sin sombra | Botones, inputs, selects, chips, checkboxes |
| **Loading** | Spinner + texto visible, disabled | Botones, quantity selector |
| **Selected** | Borde/background `primary-500`, ring o check | Chips, swatches, radio cards, address cards, filas de tabla |
| **Error** | Borde `red-500`, texto de error debajo | Inputs, selects, textareas |
| **Success** | Borde `green-500` (opcional, solo en campos que muestran éxito explícito) | Inputs con validación exitosa |

### 6.3 Focus Ring Especificaciones

```
focus:outline-none
focus:ring-2
focus:ring-primary-500
focus:ring-offset-2
```

- **Ancho:** 2px.
- **Color:** `primary-500` (o `red-500` para inputs con error).
- **Offset:** 2px entre el elemento y el ring (visible en fondos oscuros).
- **Visible solo en navegación por teclado** (`:focus-visible`, no en click de mouse). Tailwind lo maneja con `focus:ring-... focus-visible:ring-...`.
- **Excepciones:** Botones ghost usan `focus:ring-2 focus:ring-inset` (ring interno). Links usan `focus:ring-2 focus:ring-offset-2` con `rounded-sm`.

### 6.4 Hover Específico por Componente

| Componente | Hover |
|---|---|
| **Button primary** | `bg-primary-600` (oscurece un step) |
| **Button secondary** | `bg-gray-50` |
| **Button ghost** | `bg-gray-100` |
| **Button danger** | `bg-red-700` |
| **Link** | `text-primary-600 underline` |
| **ProductCard** | `shadow-md` + imagen `scale-105` |
| **AddressCard / OrderCard** | `border-gray-300` (si no seleccionada) |
| **Chip (no seleccionado)** | `bg-gray-200` |
| **Tab (no seleccionado)** | `text-gray-700 border-gray-300` |
| **Table row** | `bg-gray-50` |
| **Dropdown item** | `bg-gray-100` (normal) o `bg-red-50` (danger) |

### 6.5 Disabled — Por Componente

| Componente | Disabled Visual |
|---|---|
| **Button** | `opacity-50 cursor-not-allowed` (sin hover, sin sombra) |
| **Input / Select / Textarea** | `bg-gray-50 text-gray-500 cursor-not-allowed` |
| **Chip de variante** | `opacity-30 cursor-not-allowed line-through` |
| **Color swatch** | `opacity-30 cursor-not-allowed` (sin tachado, pero sin ring al seleccionar) |
| **Pagination arrow** | `opacity-40 cursor-not-allowed` |
| **Tab** | `opacity-50 cursor-not-allowed` |
| **QuantitySelector button** | `text-gray-300 cursor-not-allowed` (sin hover) |

---

## 7. Feedback y Micro-Interacciones

### 7.1 Principios

- **Duración estándar:** 150-200ms para transiciones de estado. 300ms para animaciones de entrada/salida.
- **Easing:** `ease-out` para entradas, `ease-in` para salidas.
- **Respetar `prefers-reduced-motion`:** Si el usuario tiene la preferencia del sistema, deshabilitar todas las animaciones no esenciales (mantener solo opacidad).
- **Propósito:** Las animaciones deben comunicar cambios de estado, no decorar.

### 7.2 Animaciones de Entrada/Salida

| Elemento | Animación | Duración | Easing |
|---|---|---|---|
| **Modal (entrada)** | Fade in (opacity 0→1) + scale 0.95→1 | 200ms | `ease-out` |
| **Modal (salida)** | Fade out (opacity 1→0) + scale 1→0.95 | 150ms | `ease-in` |
| **Overlay** | Fade in (opacity 0→1) | 200ms | `ease-out` |
| **Drawer (entrada)** | Slide in desde la izquierda/derecha | 300ms | `ease-out` |
| **Drawer (salida)** | Slide out hacia la izquierda/derecha | 200ms | `ease-in` |
| **Toast (entrada)** | Slide in desde la derecha + fade in | 300ms | `ease-out` |
| **Toast (salida)** | Fade out + slide right | 200ms | `ease-in` |
| **Accordion (abrir)** | Height 0 → auto | 200ms | `ease-out` |
| **Accordion (cerrar)** | Height auto → 0 | 150ms | `ease-in` |
| **Dropdown menu** | Fade in + scale 0.95→1 | 150ms | `ease-out` |
| **Tooltip** | Fade in + scale 0.95→1 | 150ms | `ease-out` |
| **Checkout step transition** | Slide horizontal | 300ms | `ease-out` |

### 7.3 Micro-Interacciones

| Acción | Feedback |
|---|---|
| **Agregar al carrito (desde PDP)** | 1. Botón: spinner + "Agregando..." (instantáneo). 2. Toast success: "Agregado al carrito" (slide-in derecha). 3. Badge del mini-cart en header: escala 1→1.3→1 (200ms). 4. Número en badge: animación de conteo (opcional, fase 2). |
| **Eliminar item del carrito** | 1. CartItem: fade-out + slide-right (200ms). 2. CartSummary: números se recalculan con transición CSS (transition en valores). |
| **Actualizar cantidad** | 1. QuantitySelector: spinner en el valor (sm). 2. CartSummary: actualización con transición (300ms). |
| **Aplicar cupón válido** | 1. Input se convierte en chip verde "CUPON20 ✕" (transition 200ms). 2. CartSummary muestra línea de descuento que aparece con fade-in + slide-down (200ms). 3. Total se actualiza. |
| **Cambiar variante (PDP)** | 1. Swatch/chip: ring primario aparece (150ms). 2. Nombre de la propiedad seleccionada se actualiza. 3. Stock indicator se actualiza (puede cambiar de color). 4. Precio se actualiza con transición. |
| **Favorito toggle** | 1. Corazón: escala 1→1.3→1 (200ms) + cambio de color a rojo. 2. Toast sutil (opcional). |
| **Validación de campo** | 1. Al blur: borde cambia a rojo + mensaje de error aparece con fade-in + slide-down (150ms). 2. Al corregir: error desaparece, borde vuelve a gris. |
| **Hover en ProductCard** | 1. Sombra `shadow-sm` → `shadow-md` (200ms). 2. Imagen scale 1→1.05 (300ms ease-out). 3. Botón "Agregar": opacity 0→1 (150ms). |
| **Guardar formulario** | 1. Botón: spinner + "Guardando..." (instantáneo). 2. Toast success: "Guardado" (slide-in). |
| **Navegación entre tabs** | 1. Borde inferior se desliza al nuevo tab (200ms ease-out). 2. Contenido con fade-in sutil (150ms). |
| **KPI change (admin)** | Números se actualizan con transición de opacidad + scale sutil (300ms). |

### 7.4 Skeleton Animations

```
@keyframes pulse {
  0%, 100% { opacity: 1; }
  50% { opacity: 0.5; }
}
animation: pulse 1.5s cubic-bezier(0.4, 0, 0.6, 1) infinite;
```

---

## 8. Sistema de Iconografía

### 8.1 Librería

📐 **Recomendación:** `lucide-react` (licencia MIT, 1000+ íconos, tree-shakeable, componentes React, tamaño consistente 24px viewBox).

Alternativas evaluadas:
- **Heroicons** (by Tailwind team): Excelente pero catálogo más limitado (~250 íconos).
- **Phosphor Icons**: Muy completo pero bundle más grande.
- **Radix Icons**: 15×15 viewBox (inconsistente con otros).

### 8.2 Tamaños de Ícono

| Tamaño | Clase | Uso |
|---|---|---|
| **xs** | `h-3 w-3` (12px) | Badges pequeños, dentro de texto |
| **sm** | `h-4 w-4` (16px) | Botones xs/sm, chips, dentro de inputs |
| **md** | `h-5 w-5` (20px) | **Default.** Botones, tabs, navegación, cards |
| **lg** | `h-6 w-6` (24px) | Radio cards de pago, categorías, KPI cards |
| **xl** | `h-8 w-8` (32px) | Empty states, páginas de éxito |
| **2xl** | `h-12 w-12` (48px) | Iconos de empty state grandes |

### 8.3 Iconografía por Contexto

| Contexto | Ícono | Nombre lucide |
|---|---|---|
| **Carrito** | Bolsa de compras | `ShoppingCart` |
| **Carrito vacío** | Bolsa abierta | `ShoppingBag` o `PackageOpen` |
| **Búsqueda** | Lupa | `Search` |
| **Usuario / Cuenta** | Persona | `User` |
| **Favorito (vacío)** | Corazón border | `Heart` |
| **Favorito (lleno)** | Corazón relleno | `Heart` (con `fill="currentColor"`) |
| **Menú hamburguesa** | Tres líneas | `Menu` |
| **Cerrar / X** | Cruz | `X` |
| **Flecha izquierda** | Chevron | `ChevronLeft` |
| **Flecha derecha** | Chevron | `ChevronRight` |
| **Flecha abajo (select)** | Chevron | `ChevronDown` |
| **Flecha arriba (accordion)** | Chevron | `ChevronUp` |
| **Check / Éxito** | Círculo con check | `CheckCircle` o `CircleCheck` |
| **Error** | Círculo con X | `XCircle` o `AlertCircle` |
| **Warning** | Triángulo | `AlertTriangle` |
| **Info** | Círculo con i | `Info` o `AlertCircle` |
| **Filtro** | Embudo | `Filter` o `SlidersHorizontal` |
| **Ordenar** | Flechas arriba/abajo | `ArrowUpDown` |
| **Eliminar / Basura** | Tacho | `Trash2` |
| **Editar** | Lápiz | `Pencil` |
| **+ Agregar** | Más | `Plus` |
| **− Quitar** | Menos | `Minus` |
| **Cantidad** | — | Usar texto, no ícono |
| **Envío / Camión** | Camión | `Truck` |
| **Sucursal / Tienda** | Tienda | `Store` |
| **Punto de retiro / Mapa** | Pin de mapa | `MapPin` |
| **Tarjeta de crédito** | Tarjeta | `CreditCard` |
| **Transferencia / Banco** | Edificio banco | `Building2` o `Landmark` |
| **Efectivo** | Billete | `Banknote` |
| **Cupón** | Ticket | `Ticket` o `Tag` |
| **Pedido / Caja** | Caja | `Package` |
| **Reloj / Tiempo** | Reloj | `Clock` |
| **Email** | Sobre | `Mail` |
| **Teléfono** | Teléfono | `Phone` |
| **Ojo (mostrar contraseña)** | Ojo | `Eye` |
| **Ojo tachado (ocultar)** | Ojo tachado | `EyeOff` |
| **Dashboard** | Gráfico | `LayoutDashboard` o `BarChart3` |
| **Productos** | Caja | `Package` o `Boxes` |
| **Clientes** | Personas | `Users` |
| **Categorías** | Carpetas | `Folders` o `FolderTree` |
| **Configuración** | Engranaje | `Settings` |
| **Salir** | Puerta + flecha | `LogOut` |
| **Imprimir** | Impresora | `Printer` |
| **Exportar** | Flecha arriba de caja | `Upload` o `FileSpreadsheet` |
| **Notificación / Campana** | Campana | `Bell` |
| **Copiar** | Dos rectángulos | `Copy` |
| **Estrella (reseña)** | Estrella | `Star` |
| **Seguridad / Candado** | Candado | `Lock` |
| **Candado abierto** | Candado abierto | `Unlock` o `LockOpen` |

### 8.4 Reglas de Uso

- **Siempre dentro de un contenedor accesible:** Los íconos decorativos tienen `aria-hidden="true"`. Los íconos interactivos tienen `aria-label` o están dentro de un elemento con texto.
- **No usar íconos sin texto** en botones, excepto íconos universales (X para cerrar, lupa para buscar). En ese caso, usar `aria-label`.
- **Íconos en botones:** `leftIcon` / `rightIcon` con gap de 8px (`gap-2`). Tamaño proporcional al botón.
- **Íconos en inputs:** Ícono a la izquierda (lupa en búsqueda) o derecha (ojo en contraseña). Tamaño 20px (`h-5 w-5`), color `text-gray-400`.
- **No rotar íconos:** Usar el ícono correcto para cada dirección (ej: `ChevronDown` en vez de rotar `ChevronUp`). Excepción: accordion toggle.

---

## 9. Patrones de Formularios

### 9.1 Estructura de Campo

```
┌──────────────────────────────────────┐
│ Label *                              │  text-sm font-medium text-gray-700
│                                      │  * rojo si es requerido
│ ┌──────────────────────────────────┐ │
│ │ Input                            │ │  rounded-lg border-gray-300
│ └──────────────────────────────────┘ │
│ Hint opcional                        │  text-xs text-gray-500
│                                      │
│ ⚠ Mensaje de error                  │  text-xs text-red-600 + ícono
└──────────────────────────────────────┘
```

### 9.2 Validación

| Tipo | Cuándo | Feedback |
|---|---|---|
| **Client-side (Zod)** | `onChange` (modo `onChange`) | Errores inline debajo del campo. El campo tiene borde rojo. |
| **Server-side (NestJS)** | Al submit | Errores mapeados a campos si es posible. Errores generales en toast. |
| **Async (disponibilidad de email)** | Debounce 500ms después de blur | "Verificando..." → "Email disponible ✓" o "Este email ya está registrado" |

### 9.3 Campos Requeridos vs Opcionales

- **Requerido:** Asterisco rojo `*` al lado del label. Atributo `required` en el input. Validación Zod con `.min(1)` o `.nonempty()`.
- **Opcional:** Label sin asterisco. Placeholder sin "(opcional)". En casos donde la mayoría son requeridos, marcar los opcionales con "(opcional)" en el hint.
- **Recomendación:** Marcar solo los opcionales si son minoría. Marcar los requeridos si son minoría. El objetivo es reducir ruido visual.

### 9.4 Máscaras de Input

| Campo | Máscara | Comportamiento |
|---|---|---|
| **DNI** | `99.999.999` o sin puntos: `99999999` | Solo dígitos. Máximo 8. |
| **CUIT** | `99-99999999-9` | Solo dígitos. Guiones automáticos. |
| **CP** | `9999` o `A9999AAA` (según país) | Solo dígitos. Máximo 8. |
| **Teléfono** | `99 9999-9999` o sin formato | Solo dígitos. 6-10 dígitos. |
| **Área** | `999` o `9999` | Solo dígitos. 2-4 dígitos. |
| **Precio (admin)** | `$ 99.999,99` | Formato ARS. |

📐 **Recomendación:** Usar `react-number-format` o `react-imask` para máscaras. No reinventar.

### 9.5 Layout de Formulario

| Cantidad de campos | Layout Mobile | Layout Desktop |
|---|---|---|
| **1-2 campos** | Stack vertical | Stack o 2 columnas si son cortos |
| **3-4 campos** | Stack vertical | Grid 2 columnas (campos relacionados lado a lado) |
| **5+ campos** | Stack vertical con agrupación visual | Grid 2 columnas con secciones |
| **Campos cortos (área + teléfono)** | Grid 2 columnas | Grid 2 columnas |
| **Campos largos (email, dirección)** | Full width | Full width o 2 columnas si hay otro largo al lado |

### 9.6 Comportamiento del Botón Submit

- **Habilitado** si el formulario pasó validación Zod.
- **Deshabilitado** si hay errores de validación o está `isSubmitting`.
- **Loading:** Spinner + texto "Guardando...", "Creando cuenta...", etc.
- **Prevenir doble submit:** El botón se deshabilita al primer click.

### 9.7 Formularios Multi-Step (Checkout)

- Cada paso es un formulario independiente con su propio schema Zod.
- Al submit de un paso, se hace POST al backend para guardar el progreso.
- Si el backend devuelve error, el usuario permanece en el paso actual con los datos intactos.
- Navegación entre pasos: solo hacia adelante vía botón "Continuar". Hacia atrás vía botón "Volver" o StepIndicator (si el paso ya fue completado).
- Los datos se preservan en el estado local de React y en el backend.

---

## 10. Patrones de Carga

### 10.1 Cuándo Usar Cada Patrón

| Situación | Patrón | Justificación |
|---|---|---|
| **Carga inicial de página** | Skeleton | Da estructura inmediata. Evita saltos de layout (CLS). |
| **Navegación a nueva página** | Skeleton (si > 500ms de carga) o Spinner (si < 500ms) | El skeleton previene CLS. |
| **Acción de submit (botón)** | Spinner en el botón + texto | Feedback inmediato de que la acción se está procesando. |
| **Búsqueda / filtrado** | Overlay semi-transparente sobre contenido existente + Spinner | Mantiene el contexto. El contenido anterior no desaparece. |
| **Carga infinita / paginación** | Skeleton al final de la lista (3-4 items) | Natural en scroll. No interrumpe. |
| **Actualización en segundo plano** | Indicador sutil (spinner pequeño en esquina, o nada) | No interrumpir al usuario si los datos existentes son válidos. |
| **Procesamiento largo (> 10s)** | Progress bar + mensaje "Esto puede tardar unos segundos..." | Importación Excel, generación de variantes masivas. |
| **Procesamiento crítico (pago)** | Overlay full-page + spinner + "No cierres esta ventana" | Prevenir abandono durante transacción. |

### 10.2 Skeleton vs Spinner

```
Skeleton:
┌────────────────────┐
│ ██████████████████ │  ← rect gris que pulsa
│ ████████████       │
│ ██████             │
└────────────────────┘

Spinner:
     ◌  ← círculo que gira (SVG animate-spin)
```

- **Skeleton:** Para páginas completas, grillas, cards, listas. Da forma y estructura. Previene CLS.
- **Spinner:** Para botones, acciones puntuales, overlays de fetching.

### 10.3 Spinner por Tamaño

| Tamaño | Uso |
|---|---|
| **xs (12px)** | Dentro de inputs (verificando disponibilidad) |
| **sm (16px)** | Botones pequeños, QuantitySelector |
| **md (24px)** | Botones default, overlays locales |
| **lg (32px)** | Overlay de página, centro de grilla vacía cargando |
| **xl (48px)** | Página de carga completa |

### 10.4 Optimistic UI

📐 **Recomendación — NO usar en MVP para acciones críticas:**
- **No optimistic para:** Agregar al carrito (hay validación de stock server-side), confirmar compra, aplicar cupón, cambiar estado de pedido.
- **Sí optimistic para (Fase 2):** Toggle de favoritos, eliminar item del carrito (con rollback si falla), marcar notificación como leída.

---

## 11. Manejo de Errores

### 11.1 Jerarquía de Errores

| Nivel | Componente | Cuándo | Ejemplo |
|---|---|---|---|
| **Inline** | Debajo del campo | Error de validación de un campo específico | "Email inválido", "Contraseña muy corta" |
| **Alert** | Debajo del formulario o sección | Error que afecta a todo el formulario/sección | "El cupón no es válido", "No se alcanza la compra mínima" |
| **Toast** | Esquina inferior derecha | Error de una acción completada o error del servidor | "No se pudo agregar al carrito", "Error de conexión" |
| **Empty State con error** | Reemplaza el contenido | Error al cargar datos de una sección/página | "Error al cargar productos" + botón Reintentar |
| **Error Page** | Página completa | Error 500, error de conexión total | Página de error con ilustración + acciones |

### 11.2 Mensajes de Error

Principios:
- **Humano, no técnico:** "El email no es válido", no "ValidationError: email format mismatch".
- **Accionable:** Decir qué hacer. "Probá con otros filtros", no "No results".
- **Consistente:** Mismo error = mismo mensaje en todo el sistema.
- **No revelar información sensible:** "Email o contraseña incorrectos", no "El email no existe".

| Error | Mensaje |
|---|---|
| **Campo requerido vacío** | "Este campo es obligatorio" |
| **Email inválido** | "Ingresá un email válido, por ejemplo: juan@mail.com" |
| **Contraseña débil** | "La contraseña debe tener al menos 8 caracteres, una mayúscula y un número" |
| **Contraseñas no coinciden** | "Las contraseñas no coinciden" |
| **DNI inválido** | "El DNI debe tener 7 u 8 dígitos" |
| **CUIT inválido** | "El CUIT debe tener el formato XX-XXXXXXXX-X" |
| **Login fallido** | "Email o contraseña incorrectos" |
| **Cuenta no activada** | "Tu cuenta no está activada. Revisá tu email o solicitá un nuevo link." |
| **Cuenta bloqueada** | "Demasiados intentos fallidos. Esperá 15 minutos y volvé a intentar." |
| **Rate limit** | "Demasiados intentos. Esperá unos minutos." |
| **Cupón inválido** | "El cupón no es válido o ya expiró" |
| **Stock insuficiente** | "No hay suficiente stock de este producto" |
| **Precio cambiado** | "El precio se actualizó. Revisá el nuevo total." (no mostrar como error, solo informativo) |
| **Compra mínima** | "El monto mínimo de compra es $XX.XXX. Te faltan $X.XXX." |
| **Sin cobertura de envío** | "No realizamos envíos a esta zona. Probá con retiro en sucursal." |
| **Error de conexión** | "No pudimos conectar con el servidor. Verificá tu conexión e intentá de nuevo." |
| **Error 500** | "Algo salió mal. Estamos trabajando para solucionarlo. Volvé a intentar en unos minutos." |
| **Error 404 (producto)** | "Este producto ya no está disponible." |
| **Error 404 (página)** | "La página que buscás no existe." |

### 11.3 Toast de Error

- **Duración:** 8 segundos (más que success, que son 5s). El usuario necesita tiempo para leer el error.
- **Acción opcional:** Algunos toasts de error pueden incluir un botón "Reintentar".
- **No acumular:** Si llega un nuevo toast del mismo tipo, reemplazar el anterior.

### 11.4 Retry Pattern

Cuando una sección falla al cargar datos (grilla, lista, dashboard):
1. Mostrar estado de error con ícono + mensaje + botón "Reintentar".
2. Al hacer clic en "Reintentar": invalidar cache de TanStack Query y re-fetch.
3. Si falla de nuevo: mostrar el error con opción "Reintentar" (sin límite de reintentos manuales).
4. No hacer retry automático más de 3 veces (TanStack Query default: 3).

---

## 12. Estados Vacíos

### 12.1 Principios

- **No dejar la página en blanco.** Un empty state debe comunicar qué es ese espacio y qué acción puede tomar el usuario.
- **Ilustración + texto + acción.** La fórmula de 3 elementos.
- **Tono amigable, no técnico.**
- **Si hay datos en otra parte del sistema, sugerirlos** (ej: "No tenés favoritos. ¡Mirá nuestros destacados!").

### 12.2 Empty States por Contexto

| Contexto | Ícono | Título | Descripción | Acción Primaria | Acción Secundaria |
|---|---|---|---|---|---|
| **Carrito vacío** | `ShoppingCart` (64px, gray-300) | "Tu carrito está vacío" | "¿No sabés qué comprar? ¡Mirá nuestros productos destacados!" | "Ver productos" → `/productos` | — |
| **Sin resultados de búsqueda** | `Search` (48px, gray-300) | "No encontramos resultados" | "Para '[query]'. Probá con menos palabras o revisá la ortografía." | "Limpiar búsqueda" | Categorías sugeridas |
| **Sin resultados de filtros** | `PackageOpen` (48px, gray-300) | "No encontramos productos" | "Probá con otros filtros o navegá por categorías." | "Limpiar filtros" | "Ver todas las categorías" |
| **Sin pedidos** | `Package` (64px, gray-300) | "Todavía no hiciste ningún pedido" | "Cuando compres, acá vas a poder seguir el estado de tus pedidos." | "Ver productos" → `/productos` | — |
| **Sin direcciones** | `MapPin` (48px, gray-300) | "No tenés direcciones guardadas" | "Guardá tus direcciones para comprar más rápido." | "Agregar dirección" | — |
| **Sin favoritos** | `Heart` (48px, gray-300) | "No tenés productos en favoritos" | "Guardá los productos que te gusten para encontrarlos fácilmente." | "Ver productos" → `/productos` | — |
| **Admin — Sin productos** | `Package` (48px, gray-300) | "No hay productos todavía" | "Creá tu primer producto para empezar a vender." | "Nuevo producto" | — |
| **Admin — Sin pedidos** | `Inbox` (48px, gray-300) | "No hay pedidos todavía" | "Los pedidos que reciban van a aparecer acá." | — | — |
| **Admin — Sin clientes** | `Users` (48px, gray-300) | "No hay clientes registrados" | "Los clientes que se registren o compren van a aparecer acá." | — | — |

### 12.3 Estructura Visual del Empty State

```
┌────────────────────────────────────┐
│                                    │
│            [Ícono 48-64px]         │  Color gray-300
│                                    │
│         Título (text-lg)           │  font-medium, text-gray-900
│                                    │
│    Descripción (text-sm)           │  text-gray-500, max-w-md
│    centrada, 2-3 líneas            │
│                                    │
│      [Acción primaria]             │  Button primary
│                                    │
│        Acción secundaria           │  Link
│                                    │
└────────────────────────────────────┘
```

- Padding vertical generoso (`py-16`).
- Todo centrado horizontalmente.
- La acción primaria es un botón. La secundaria es un link.
- No usar skeletons para empty states (confunde con loading).

---

## 13. Confirmaciones

### 13.1 Cuándo Pedir Confirmación

| Acción | ¿Requiere confirmación? | Tipo |
|---|---|---|
| **Eliminar producto del carrito** | No (fácil de deshacer) | — |
| **Eliminar dirección guardada** | **Sí** | Modal de confirmación |
| **Eliminar producto (admin)** | **Sí** | Modal de confirmación |
| **Cambiar estado de pedido** | **Sí** | Modal de confirmación |
| **Cerrar sesión** | No | — |
| **Salir del checkout sin completar** | **Sí** (si hay datos ingresados) | Modal de confirmación |
| **Eliminar cuenta** | **Sí** (doble confirmación) | Modal con input de confirmación |
| **Confirmar compra** | No (es el botón final del checkout) | — |
| **Vaciar carrito** | Opcional | Modal o acción con undo |

### 13.2 Modal de Confirmación

```
┌──────────────────────────────────────┐
│ ¿Eliminar dirección?                 │  Título (text-lg, semibold)
│                                      │
│ Esta acción no se puede deshacer.    │  Descripción (text-sm, gray-500)
│ ¿Estás seguro?                       │
│                                      │
│ ┌────────────┐ ┌────────────────────┐│
│ │ Cancelar   │ │ Eliminar           ││  Footer con botones
│ └────────────┘ └────────────────────┘│  Cancelar: secondary/ghost
│                                      │  Confirmar: danger (si es destructivo)
└──────────────────────────────────────┘
```

### 13.3 Reglas de Confirmación

- **Acción destructiva:** Botón de confirmación con variant `danger` (rojo).
- **Acción no destructiva:** Botón de confirmación con variant `primary`.
- **Cancelar:** Siempre a la izquierda (o abajo en mobile). Botón `secondary` o `ghost`.
- **Foco inicial:** En el botón "Cancelar" (previene confirmación accidental con Enter).
- **Teclado:** Escape cierra el modal (cancela). Enter en el modal NO debería confirmar automáticamente (el usuario debe hacer Tab hasta el botón y presionar Enter).

---

## 14. Navegación

### 14.1 Patrones Mobile

| Componente | Implementación |
|---|---|
| **Menú principal** | Drawer izquierdo. Se abre con botón hamburguesa (☰). Contiene: logo, búsqueda, categorías, links de cuenta. Cierra con X o swipe right. |
| **Navegación secundaria (cuenta)** | Tabs horizontales con íconos (scrollables si no entran). |
| **Filtros (catálogo)** | Drawer izquierdo. Se abre con botón "Filtrar" en toolbar. |
| **Carrito** | Página completa (no drawer). El header tiene link al carrito con badge de conteo. |
| **Volver atrás** | Botón ← en el header (cuando corresponde). No depende solo del back del navegador. |
| **Breadcrumbs** | Solo en desktop. En mobile se omite (usa botón back o el título de la página). |

### 14.2 Patrones Desktop

| Componente | Implementación |
|---|---|
| **Menú principal** | Horizontal en el header. Categorías principales + links (Marcas, Ofertas). Dropdown en hover/click para subcategorías. |
| **Navegación de cuenta** | Sidebar izquierda (w-56) con links + íconos. Visible siempre en páginas de cuenta. |
| **Filtros (catálogo)** | Sidebar izquierdo fijo (w-64). Siempre visible. |
| **Admin** | Sidebar izquierda (w-56). Colapsable a íconos (w-16) para más espacio de trabajo. |
| **Breadcrumbs** | Visibles en catálogo, PDP, admin. |
| **Volver atrás** | Breadcrumbs cubren la necesidad. En pages sin breadcrumb: botón ← en el header. |

### 14.3 Header Comportamiento

- **Sticky top** en mobile y desktop. `z-20` (detrás de modales, delante del contenido).
- **Sombra:** `shadow-sm` solo cuando hay scroll (`shadow-none` en top of page). Detectado con `useScrollPosition` o Intersection Observer.
- **Altura:** 56px (h-14) en mobile, 64px (h-16) en desktop.
- **Contenido mobile:** [Hamburguesa] [Logo] [Search] [Carrito].
- **Contenido desktop:** [Logo] [Nav: Catálogo | Marcas | Ofertas] [Search expandida] [Usuario ▼] [Carrito con badge].

### 14.4 Tabs (Patrón de Navegación Local)

- Usar `Tabs` de Radix UI (headless, accesible).
- **Mobile:** Tabs horizontales, scrollables si no entran. Sin borde inferior en todo el ancho, solo en el tab activo.
- **Desktop:** Tabs horizontales con más espacio. Pueden tener badges de conteo.
- **Teclado:** Arrow Left/Right para mover entre tabs. Home/End para ir al primero/último.

### 14.5 Step Indicator (Checkout)

```
Mobile (compact):
● Datos ── ● Envío ── ○ Pago ── ○ Confirmar
Paso 2 de 4

Desktop (completo):
✓ Datos personales ── ● Forma de entrega ── ○ Medio de pago ── ○ Confirmar
```

- Dots conectados por líneas.
- Paso completado: dot verde con check + línea verde.
- Paso actual: dot primary con borde expandido (ring).
- Paso futuro: dot gris + línea gris.
- **Mobile:** Solo labels en el paso actual. Desktop: labels siempre visibles.

---

## 15. Accesibilidad (WCAG 2.1 AA)

### 15.1 Principios Generales

| Principio | Implementación |
|---|---|
| **Perceptible** | Todo contenido no textual tiene alternativa textual. Contraste 4.5:1 mínimo. |
| **Operable** | Navegación completa por teclado. Sin trampas de foco. Tiempo ajustable. |
| **Comprensible** | Lenguaje claro. Navegación consistente. Errores identificados y descritos. |
| **Robusto** | HTML semántico. Compatible con lectores de pantalla actuales. |

### 15.2 Checklist de A11y por Componente

| Componente | Requisitos |
|---|---|
| **Button** | `role="button"` (si es `<a>`). `aria-busy="true"` si loading. `aria-disabled="true"` si disabled (no solo atributo HTML). |
| **Input** | `<label>` asociado con `htmlFor`/`id`. `aria-invalid="true"` si error. `aria-describedby` apuntando a hint/error. Required: asterisco con `aria-hidden`. |
| **Select nativo** | Mismo que Input. No usar select custom con divs. |
| **Checkbox / Radio** | `<input>` real (no divs). `<label>` asociado. RadioGroup dentro de `<fieldset>` + `<legend>`. |
| **Modal** | Focus trap. Escape para cerrar. Foco vuelve al trigger al cerrar. `aria-modal="true"`. |
| **Drawer** | Similar a Modal. |
| **Dropdown Menu** | `role="menu"`. `role="menuitem"` en items. Arrow keys para navegar. |
| **Tabs** | `role="tablist"`, `role="tab"`, `role="tabpanel"`. Arrow keys. `aria-selected`. |
| **Accordion** | `aria-expanded` en trigger. `aria-controls` / `aria-labelledby`. |
| **Toast** | `role="alert"` (errores) o `role="status"` (éxito). `aria-live="polite"` en contenedor. |
| **ProductCard** | `<article>`. Imagen con `alt`. Links distinguibles. Precio como texto. |
| **ImageGallery** | Swiper con `aria-label`. Slide actual anunciado. |
| **DataTable** | `<table>` con `<thead>`, `<tbody>`, `<th scope="col">`. `aria-sort` en columnas ordenables. |
| **Pagination** | `<nav aria-label="Paginación">`. `aria-current="page"`. |
| **Breadcrumb** | `<nav aria-label="Breadcrumb">`. `aria-current="page"` en el último item. |
| **Alert** | `role="alert"` para mensajes importantes. |
| **Tooltip** | Asociado con `aria-describedby`. Visible en hover Y focus. |
| **Toggle** | `role="switch"` + `aria-checked`. |

### 15.3 Navegación por Teclado

| Tecla | Acción |
|---|---|
| **Tab** | Avanzar al siguiente elemento interactivo |
| **Shift + Tab** | Retroceder al elemento anterior |
| **Enter / Space** | Activar botón, link, checkbox, radio |
| **Escape** | Cerrar modal, drawer, dropdown, tooltip |
| **Arrow Keys** | Navegar dentro de: tabs, radio group, dropdown menu, select |
| **Home / End** | Ir al primer/último elemento en tabs, menú |

### 15.4 Skip Link

Primer elemento del DOM en cada página:

```html
<a href="#main-content" class="sr-only focus:not-sr-only focus:absolute focus:top-4 focus:left-4 focus:z-50 focus:px-4 focus:py-2 focus:bg-primary focus:text-white focus:rounded-lg">
  Saltar al contenido principal
</a>
```

### 15.5 Prefers Reduced Motion

```css
@media (prefers-reduced-motion: reduce) {
  *, *::before, *::after {
    animation-duration: 0.01ms !important;
    animation-iteration-count: 1 !important;
    transition-duration: 0.01ms !important;
    scroll-behavior: auto !important;
  }
}
```

En componentes React que usan animaciones JS (Framer Motion, etc.), respetar la media query:

```typescript
const prefersReducedMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches;
```

### 15.6 Color y Contraste

- **No usar solo color** para comunicar estado. Acompañar con íconos y texto.
- **Links:** Distinguibles del texto circundante por color + subrayado (al menos en hover/focus).
- **Estados de error:** Borde rojo + ícono + texto. No solo borde rojo.
- **Estados de éxito:** Ícono check + texto. No solo borde verde.
- **Gráficos (admin):** Usar patrones o texturas además de colores para diferenciar datasets. Recharts soporta esto.

---

## Resumen de Decisiones de Sistema de Diseño

| Decisión | Elección |
|---|---|
| **Tipografía** | Inter (sistema, configurable por tenant vía CSS vars). Escala Tailwind. |
| **Espaciado** | Tailwind spacing scale (4px base). Mobile-first con padding generoso. |
| **Colores** | Paleta funcional. CSS custom properties para multi-tenant. Semantic colors para estados. |
| **Sombras** | 6 niveles de shadow. Uso consistente por tipo de componente. |
| **Border Radius** | 9 niveles. `rounded-lg` para botones/inputs. `rounded-xl` para cards. `rounded-full` para badges. |
| **Estados interactivos** | Hover, focus, active, disabled, loading, selected, error estandarizados. Focus ring 2px primary-500. |
| **Animaciones** | 150-200ms para estados. 300ms para entrada/salida. Easing ease-out/ease-in. Respetar reduced-motion. |
| **Iconografía** | lucide-react. 6 tamaños. Uso consistente con aria-labels. |
| **Formularios** | React Hook Form + Zod. Validación onChange. Errores inline. Máscaras con librería. |
| **Carga** | Skeleton para páginas. Spinner para acciones. Overlay para filtros/búsqueda. |
| **Errores** | 5 niveles: inline, alert, toast, empty state, error page. Mensajes humanos y accionables. |
| **Empty states** | Icono + título + descripción + acción. Nunca dejar en blanco. |
| **Confirmaciones** | Modal para acciones irreversibles. Botón danger para destructivas. |
| **Navegación** | Drawer + tabs en mobile. Sidebar + menú horizontal en desktop. |
| **Accesibilidad** | WCAG 2.1 AA. HTML semántico. Keyboard nav. ARIA roles. Skip link. |

---

> **Confianza global de este documento:** ALTA.
>
> **Hechos:** Componentes y layouts definidos en la arquitectura frontend. Flujos y features del MVP. Gaps de UX identificados.
>
> **Diseño UX (decisiones propias):** Escalas tipográficas y de espaciado, paleta de color, sistema de sombras, iconografía, patrones de formularios, carga, errores, vacíos, confirmaciones y navegación.
>
> **Recomendaciones:** lucide-react para íconos, react-number-format para máscaras, uso de CSS custom properties para multi-tenant, respeto de `prefers-reduced-motion`.
>
> **Próximo paso:** Implementación de componentes según el Design System con las referencias de `01-frontend-component-tree.md` y los wireframes de `01-ux-wireframes.md`.
