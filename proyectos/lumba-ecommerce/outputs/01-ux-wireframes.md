# 01 — UX Wireframes (Mobile-First)

> **Proyecto:** Lumba Ecommerce (Brownfield — migración PHP vanilla + Bootstrap 5 → NestJS API + React + Tailwind CSS)
> **Fecha:** 2026-06-08
> **Rol:** UX Designer
> **Modelo:** deepseek-v4-pro
> **Nivel de confianza global:** ALTA
> **Fuentes:** `01-ux-flows.md`, `01-frontend-architecture.md`, `01-frontend-component-tree.md`, `01-flujos-negocio.md`, `01-functional-spec.md`

---

## Instrucciones para el UI Designer

Estos wireframes son **descripciones textuales de alta precisión**. Cada sección describe:
- Layout y estructura (qué va arriba, medio, abajo)
- Jerarquía visual (qué es más importante)
- Componentes React que la componen
- Comportamiento responsive (mobile vs desktop)
- Estados: empty, loading, error
- Navegación (breadcrumbs, back, tabs)
- CTAs principales y su jerarquía

**Mobile-first:** La descripción principal es mobile (375px). Desktop se describe como variante. Tailwind breakpoints: sm=640, md=768, lg=1024, xl=1280.

---

## 1. Home (Mobile, 375px)

> **Ruta:** `/` | **Render:** ISR 300s | **Componentes:** `MainLayout` > `Header`, `Slider`, `CategoriesShowcase`, `ProductCarousel`, `BannerGrid`, `Footer`

### Layout y Estructura

```
┌────────────────────────────────┐
│ HEADER (sticky top, z-30)      │
│ [≡] [   LOGO    ] [🔍] [🛒 3] │  48px height, bg-white, shadow-sm
├────────────────────────────────┤
│ SLIDER                          │
│ ┌────────────────────────────┐  │
│ │  [Slide 1: imagen full-width]│  │  h-48 (192px), swiper/swiper
│ │  Título + subtítulo        │  │  dots abajo centrados
│ │            [Ver más]       │  │
│ └────────────────────────────┘  │
│         ● ○ ○ ○                │
├────────────────────────────────┤
│ CATEGORÍAS DESTACADAS          │
│ Categorías destacadas          │  px-4 py-6
│ ┌──────┐ ┌──────┐             │
│ │ icon │ │ icon │             │  Grid 2×2 o 3×2
│ │Ropas │ │Calzad│             │  Cards con ícono/foto circular
│ └──────┘ └──────┘             │  Nombre debajo
│ ┌──────┐ ┌──────┐             │
│ │Acce..│ │Depor.│             │
│ └──────┘ └──────┘             │
├────────────────────────────────┤
│ PRODUCTOS DESTACADOS           │
│ Destacados          [Ver todos]│  px-4 py-6
│ ← scroll horizontal →         │  Carousel horizontal
│ ┌──────┐ ┌──────┐ ┌──────┐   │  ProductCard 160px ancho
│ │foto  │ │foto  │ │foto  │   │  Nombre 2 líneas + precio
│ │nombre│ │nombre│ │nombre│   │
│ │$XXXX │ │$XXXX │ │$XXXX │   │
│ └──────┘ └──────┘ └──────┘   │
├────────────────────────────────┤
│ BANNER PROMOCIONAL             │
│ ┌────────────────────────────┐  │  px-4 py-4
│ │   [Banner full-width]      │  │  Imagen con link
│ └────────────────────────────┘  │
├────────────────────────────────┤
│ FOOTER                          │
│ Logo + descripción             │  bg-gray-900 text-white
│ Links: Categorías, Ayuda, etc  │  py-12 px-4
│ Redes sociales                 │  3 columnas en mobile
│ © 2026 Tienda                  │
└────────────────────────────────┘
```

### Jerarquía Visual

1. **Header + navegación** — siempre visible, acceso a búsqueda y carrito.
2. **Slider** — impacto visual inmediato, promociones principales.
3. **Categorías** — navegación de descubrimiento primaria.
4. **Productos destacados** — scroll horizontal, curatorial.
5. **Banner** — promoción puntual.
6. **Footer** — links institucionales.

### Componentes React

`MainLayout` > `Header[logo, SearchBar, MiniCart]`, `Slider[swiper, autoplay=5s]`, `CategoriesShowcase[grid, CategoryCard]`, `ProductCarousel[scroll-snap-x, ProductCard]`, `BannerGrid[BannerCard]`, `Footer[links, social]`

### Estados

| Estado | Visual |
|---|---|
| **Loading** | Skeleton slider (rect h-48), skeletons categorías (círculos + texto), skeleton cards (4× rect + texto). Animación pulse. |
| **Empty slider** | Omitir sección slider (no renderizar). |
| **Empty destacados** | Mostrar "Próximamente nuevos productos" con link a catálogo. |
| **Empty categorías** | Omitir sección. Mostrar solo slider + banner. |
| **Error parcial** | Si falla solo el slider: mostrar home con resto de secciones normales + toast warning sutil. |

### Navegación

- Header: hamburger → `Drawer` con menú de categorías + links de cuenta.
- Click en slide → URL del slide.
- Click en categoría → `/categoria/{slug}`.
- Click en producto → `/productos/{slug}`.
- Click en "Ver todos" → `/productos`.
- Click en carrito → `/carrito`.

### Desktop (≥1024px)

- Header: menú horizontal (Categorías, Marcas, Ofertas) + search expandida + mini-cart.
- Slider: h-80 (320px) o h-96 (384px). Más ancho.
- Categorías: grid 4-6 columnas.
- Destacados: grid 4 columnas con ProductCard completo.
- Layout general: max-w-7xl centrado, padding lateral más generoso.
- Footer: 4 columnas.

---

## 2. Catálogo / PLP (Mobile, 375px)

> **Ruta:** `/productos`, `/categoria/{slug}`, etc. | **Render:** Hybrid | **Componentes:** `MainLayout` > `Breadcrumb`, `FilterPanel` (Drawer), `SearchBar`, `SortSelect`, `ActiveFilters`, `ProductGrid`, `Pagination`

### Layout y Estructura

```
┌────────────────────────────────┐
│ HEADER (sticky)                │
│ [←] Catálogo     [🔍] [🛒 3] │  Botón back a home
├────────────────────────────────┤
│ TOOLBAR                        │
│ [🎛 Filtrar]  48 productos [↓]│  px-4 py-3, bg-white, border-b
├────────────────────────────────┤
│ ACTIVE FILTERS (si hay)        │
│ [✕ Rojo] [✕ XL] [Limpiar]    │  Chips horizontales scrollable
├────────────────────────────────┤
│ PRODUCT GRID                   │
│ ┌──────────┐ ┌──────────┐     │  Grid 2 columnas
│ │  [foto]  │ │  [foto]  │     │  gap-4, px-4 py-4
│ │          │ │          │     │
│ │ MARCA    │ │ MARCA    │     │
│ │ Nombre   │ │ Nombre   │     │
│ │ prod 2l  │ │ prod 2l  │     │  line-clamp-2
│ │ $XX.XXX  │ │ $XX.XXX  │     │  PriceDisplay
│ │  -20%    │ │          │     │  Badge descuento
│ └──────────┘ └──────────┘     │
│ ┌──────────┐ ┌──────────┐     │
│ │   ...    │ │   ...    │     │
│ └──────────┘ └──────────┘     │
├────────────────────────────────┤
│ PAGINATION                     │
│        [← 1 2 3 ... 8 →]      │  Centrado, py-6
└────────────────────────────────┘
```

### Jerarquía Visual

1. Toolbar (filtros + conteo + orden) — controles primarios.
2. Grilla de productos — contenido principal.
3. Paginación — navegación secundaria.

### Componentes React

`FilterPanel` (Drawer mobile / Sidebar desktop), `SearchBar` (en header), `SortSelect`, `ActiveFilters` (conjunto de Chips removibles), `ProductGrid` (con ProductCard × N), `Pagination`

### Drawer de Filtros (Mobile)

```
┌──────────────────────────┐
│ 🎛 Filtrar      [Limpiar]│  Header
├──────────────────────────┤
│ CATEGORÍA                │
│ ☑ Ropa (42)             │  Accordion expandible
│ ☐ Calzado (18)          │  Checkbox + conteo
│ ☐ Accesorios (7)        │
├──────────────────────────┤
│ MARCA                    │
│ ☑ Nike                   │
│ ☐ Adidas                 │
├──────────────────────────┤
│ PRECIO                   │
│ $0 ───────●────── $50K  │  Range slider
│ Desde [$0  ] Hasta [$30K]│  Inputs numéricos
├──────────────────────────┤
│ COLOR                    │
│ ● ● ● ● ●               │  Swatches de color
│ Rojo Azul Neg.           │
├──────────────────────────┤
│ TALLE                    │
│ [S] [M] [L] [XL]        │  Chips seleccionables
├──────────────────────────┤
│                          │
│ [Aplicar filtros (42)]   │  Botón sticky bottom
└──────────────────────────┘
```

Abre desde la izquierda (Drawer, side="left"), ocupa 85% del ancho (max-w-sm).

### Comportamiento Responsive

| Breakpoint | Comportamiento |
|---|---|
| **< 768px (mobile)** | Filtros en Drawer. Grilla 2 columnas. |
| **768-1023px (tablet)** | Filtros en Drawer. Grilla 3 columnas. |
| **≥ 1024px (desktop)** | Filtros en sidebar izquierdo fijo (w-64). Grilla 3-4 columnas al lado derecho. |

### Estados

| Estado | Visual |
|---|---|
| **Loading inicial** | 12 skeletons ProductCard en grid 2 cols. Toolbar visible con conteo "—". |
| **Fetching (filtros)** | Overlay semi-transparente sobre grilla actual + Spinner centrado. Grilla existente visible con opacity-60. |
| **Empty** | Centro: ícono caja vacía (PackageOpenIcon, 48px, text-gray-300). "No encontramos productos". "Probá con otros filtros o categorías." Botón "Limpiar filtros". |
| **Error** | Centro: ícono alerta (AlertCircleIcon, 48px, text-red-400). "Error al cargar productos". Botón "Reintentar". Los filtros se preservan (query params en URL). |
| **Sin resultados de búsqueda** | "No hay resultados para '[query]'". "Probá con menos palabras o revisá la ortografía." Categorías sugeridas debajo. |

### Navegación

- Breadcrumb: "Home > Categoría > Subcategoría" o "Home > Productos".
- Click en producto → `/productos/{slug}`.
- Paginación: recarga arriba con scroll to top (instantáneo).
- Ordenamiento: `SortSelect` con opciones "Más relevantes", "Menor precio", "Mayor precio", "Más nuevos".

### Desktop (≥1024px)

- Sidebar de filtros: izquierda, w-64, sticky top-20, siempre visible.
- Grilla: 3-4 columnas a la derecha del sidebar.
- Toolbar: solo "X productos" + SortSelect. Sin botón "Filtrar".
- ProductCard: más grande, hover effects (sombra, zoom, botón Agregar).
- Paginación completa con números y ellipsis.

---

## 3. Detalle Producto / PDP (Mobile, 375px)

> **Ruta:** `/productos/{slug}` | **Render:** ISR 60s | **Componentes:** `ImageGallery`, `VariantSelector`, `StockIndicator`, `PriceDisplay`, `QuantitySelector`, `Button`, `Accordion`, `ProductCarousel` (relacionados)

### Layout y Estructura

```
┌────────────────────────────────┐
│ HEADER                          │
│ [←]                    [🛒 3] │
├────────────────────────────────┤
│ IMAGE GALLERY                   │
│ ┌────────────────────────────┐  │
│ │                            │  │  Swiper horizontal
│ │    [Foto principal]        │  │  h-80 (320px) o aspect-[4/3]
│ │     ← swipe →              │  │  Contador "2/5" abajo derecha
│ │                            │  │  Pinch-to-zoom
│ │                    (2/5)   │  │
│ └────────────────────────────┘  │
│         ● ● ○ ○ ○              │  Dots de navegación
├────────────────────────────────┤
│ PRODUCT INFO                    │
│ MARCA                          │  text-xs, text-gray-500, uppercase
│                                │
│ Nombre del Producto            │  text-xl, font-bold, text-gray-900
│ Completo en 2-3 Líneas         │
│                                │
│ SKU: ABC-123                   │  text-xs, text-gray-400
│                                │
│ $XX.XXX  $YY.YYY  -20%        │  PriceDisplay: precio actual (xl, bold, gray-900)
│                                │  + original tachado + badge rojo % OFF
│                                │
│ [★★★★★] (0 reseñas)          │  (Fase 2: estrellas + conteo)
├────────────────────────────────┤
│ VARIANTES                       │
│ Color                          │  label + nombre del seleccionado
│ ● ● ● ●                       │  Swatches circulares 40px
│ Rojo Azul Neg. Blanc.          │  Seleccionado: ring-2 primary
│                                │  No disponible: opacity-30
│                                │
│ Talle                          │
│ [S] [M] [L] [XL] [XXL]       │  Chips: seleccionado bg-primary
│                                │  No disponible: opacity-30 tachado
├────────────────────────────────┤
│ STOCK + CANTIDAD + CTA         │
│ ● Stock disponible             │  StockIndicator: verde disponible
│                                │
│ [−]  1  [+]                   │  QuantitySelector: 48px altura
│                                │
│ ┌────────────────────────────┐ │
│ │  🛒  Agregar al carrito    │ │  Button primary, full-width
│ │      Por $XX.XXX           │ │  h-12 (48px), text-base, semibold
│ └────────────────────────────┘ │
│                                │
│ Compra mínima: $XX.XXX        │  Solo si no se alcanza
├────────────────────────────────┤
│ ACCORDION                       │
│ ▼ Descripción                  │  Abierto por defecto
│   [texto enriquecido...]       │  Prose max-w-none (Tailwind Typography)
│                                │
│ ▶ Envíos                       │  Colapsado
│ ▶ Cambios y devoluciones       │  Colapsado
├────────────────────────────────┤
│ PRODUCTOS RELACIONADOS          │
│ También te puede interesar     │  Scroll horizontal
│ ┌──────┐ ┌──────┐ ┌──────┐   │  ProductCard width 160px
│ │ ...  │ │ ...  │ │ ...  │   │
│ └──────┘ └──────┘ └──────┘   │
├────────────────────────────────┤
│ FOOTER                          │
└────────────────────────────────┘
```

### Jerarquía Visual

1. **Imagen** — lo primero que ve el usuario (emocional).
2. **Precio + descuento** — impacto inmediato post-imagen.
3. **Botón CTA** — la acción principal, siempre accesible.
4. **Variantes** — interactivas, afectan disponibilidad y precio.
5. **Nombre y marca** — identificación del producto.
6. **Descripción + Envíos** — información complementaria.
7. **Relacionados** — cross-selling.

### Componentes React

`Breadcrumb`, `ImageGallery` (swiper), `VariantSelector` (swatches + chips), `StockIndicator`, `PriceDisplay`, `QuantitySelector`, `Button` (CTA), `Accordion`, `ProductCarousel` (relacionados), `ProductSchemaOrg` (JSON-LD invisible)

### Estados

| Estado | Visual |
|---|---|
| **Loading** | Skeleton: rect grande (imagen) + 4 líneas texto (nombre/precio) + 2 rows chips (variantes) + rect botón. |
| **404** | "Producto no disponible". "Este producto ya no está a la venta." + botón "Ver productos". |
| **Sin stock total** | Galería normal. Variantes todas disabled. StockIndicator rojo "Sin stock". Botón CTA "Sin stock" disabled. Mensaje "Dejanos tu email y te avisamos" (Fase 2). |
| **Agregando al carrito** | Botón: `Spinner` + "Agregando...". Botón disabled para prevenir doble click. |
| **Agregado exitoso** | Toast success "Agregado al carrito". Badge del mini-cart en header se actualiza con animación (número que crece). |
| **Error al agregar** | Toast error: "No hay suficiente stock" o "El precio cambió, se actualizó en tu carrito". Producto permanece en PDP. |

### Navegación

- Swipe horizontal en galería para cambiar de foto.
- Pinch-to-zoom en foto (modal fullscreen o zoom in-place).
- Back button en header → volver a página anterior (categoría/búsqueda).
- "Ver productos" en 404 → `/productos`.
- Click en relacionado → `/productos/{slug}`.

### Desktop (≥1024px)

```
┌──────────────────────────────────────────────┐
│ Breadcrumb                                   │
├──────────────────┬───────────────────────────┤
│ GALERÍA          │ INFO                      │
│                  │                           │
│ [Thumb1] [Main]  │ Marca                     │
│ [Thumb2]         │ Nombre (text-2xl)         │
│ [Thumb3]         │ SKU                       │
│ [Thumb4]         │ ★★★★★ (reseñas)          │
│ [Thumb5]         │                           │
│                  │ $XX.XXX  $YY.YYY  -20%   │
│                  │                           │
│ Layout:          │ Variantes (swatches+chips) │
│ Thumbnails       │ Stock + Cantidad          │
│ vertical izq.    │ ┌──────────────────┐      │
│ 80×80px cada uno │ │ Agregar al carrito│      │
│ Imagen principal │ │  Por $XX.XXX      │      │
│ grande derecha   │ └──────────────────┘      │
│ (1:1, 500px+)    │                           │
│                  │ Accordion (Descripción,    │
│                  │ Envíos, Devoluciones)      │
├──────────────────┴───────────────────────────┤
│ RELACIONADOS (Carousel 4 items)              │
└──────────────────────────────────────────────┘
```

- Galería con hover-zoom (lupa) en la imagen principal.
- Cantidad y botón CTA en la misma línea (no stacked).
- Relacionados en grid de 4 columnas, no scroll.
- Sticky: el bloque de precio + CTA puede hacerse sticky al hacer scroll para mantenerlo visible (opcional).

---

## 4. Carrito (Mobile, 375px)

> **Ruta:** `/carrito` | **Render:** Client | **Componentes:** `CartItem` × N, `CouponInput`, `CartSummary`, `Alert`, `Button`

### Layout y Estructura

```
┌────────────────────────────────┐
│ HEADER                          │
│ [←] Carrito (3)      [🛒 3]  │
├────────────────────────────────┤
│ ITEMS                           │
│ ┌────────────────────────────┐  │
│ │ [foto80] Nombre Prod       │  │  CartItem: horizontal
│ │          SKU: ABC-123      │  │  flex gap-4, p-4
│ │          [− 2 +]  $XX.XXX │  │  Borde gris claro
│ │          Subt: $XX.XXX     │  │  rounded-lg
│ │          Ahorro: $X.XXX    │  │
│ │                       [🗑] │  │  Botón eliminar: esquina superior derecha
│ └────────────────────────────┘  │
│ ┌────────────────────────────┐  │
│ │ [foto80] Nombre Prod 2     │  │
│ │          SKU: DEF-456      │  │
│ │          [− 1 +]  $YY.YYY │  │
│ │                       [🗑] │  │
│ └────────────────────────────┘  │
├────────────────────────────────┤
│ CUPÓN                           │
│ ¿Tenés un cupón?               │  Input + botón "Aplicar"
│ [Código        ] [Aplicar]     │  O chip verde si ya aplicado
│                                │  con botón X para remover
├────────────────────────────────┤
│ RESUMEN                         │
│ ┌────────────────────────────┐  │
│ │ Resumen                    │  │  CartSummary: bg-gray-50, rounded-xl
│ │                            │  │
│ │ Subtotal          $XX.XXX │  │  Items de línea con justify-between
│ │ Descuento promo    -$X.XXX│  │  Descuentos en verde
│ │ Cupón SUMMER20     -$X.XXX│  │
│ │ IVA                $X.XXX │  │
│ │ Envío              GRATIS │  │  "GRATIS" en verde, o $XXX
│ │                            │  │
│ │ ───────────────────────── │  │  Separador (border-t)
│ │ Total             $XX.XXX │  │  text-lg, font-bold
│ └────────────────────────────┘  │
│                                │
│ ⚠ Monto mínimo: $XX.XXX       │  Alert warning (solo si aplica)
│ Te faltan $X.XXX               │
├────────────────────────────────┤
│ ┌────────────────────────────┐ │
│ │  Iniciar compra            │ │  Button primary, full-width, h-12
│ │  Por $XX.XXX               │ │  Disabled si no alcanza mínimo
│ └────────────────────────────┘ │
│                                │
│   Seguir comprando            │  Link ghost, text-center
├────────────────────────────────┤
│ FOOTER                          │
└────────────────────────────────┘
```

### Jerarquía Visual

1. **Lista de items** — revisión y control de cantidades.
2. **Resumen** — subtotales y totales, transparencia de costos.
3. **Botón CTA** — "Iniciar compra", la acción principal.
4. **Cupón** — acción secundaria (ahorro opcional).

### Componentes React

`CartItem` × N, `CouponInput`, `CartSummary`, `Alert`, `Button`

### Estados

| Estado | Visual |
|---|---|
| **Loading** | 3 skeletons CartItem (rect foto + 3 líneas). Skeleton CartSummary (rect). |
| **Vacío** | Ícono carrito vacío (ShoppingCartIcon, 64px, text-gray-300). "Tu carrito está vacío". "¿No sabés qué comprar? ¡Mirá nuestros destacados!" Botón "Ver productos" → `/productos`. |
| **Actualizando cantidad** | QuantitySelector en ese item muestra Spinner. Los otros items normales. |
| **Eliminando item** | El CartItem tiene animación fade-out (200ms) + slide a la derecha. El CartSummary se recalcula con animación de números (transition). |
| **Cupón válido** | Chip verde "SUMMER20 ✕". CartSummary muestra línea de descuento en verde. |
| **Cupón inválido** | Mensaje de error inline debajo del input: "Cupón no válido o expirado". El input mantiene el texto. |
| **Compra mínima no alcanzada** | Alert warning entre el resumen y el botón CTA. Botón disabled, opacidad 50%. |
| **Error de stock (al actualizar cantidad)** | Toast error "No hay suficiente stock". La cantidad vuelve al valor anterior. Badge rojo en el item afectado. |

### Navegación

- Click en nombre de producto o foto → `/productos/{slug}`.
- "Seguir comprando" → `/productos`.
- "Iniciar compra" → `/checkout`.
- Back → página anterior.

### Desktop (≥1024px)

```
┌──────────────────────────────────────────────┐
│ Carrito (3 productos)                        │
├────────────────────────┬─────────────────────┤
│ ITEMS (2/3 width)      │ RESUMEN (1/3 width) │
│                        │                     │
│ ┌────────────────────┐ │ ┌─────────────────┐ │
│ │ CartItem más grande│ │ │ Resumen         │ │
│ │ Foto 120×120px     │ │ │                 │ │
│ │ Nombre + variante  │ │ │ Subtotal $XXX   │ │
│ │ Precio + cantidad  │ │ │ Descuentos      │ │
│ └────────────────────┘ │ │ Cupón           │ │
│ ┌────────────────────┐ │ │ IVA             │ │
│ │ CartItem 2         │ │ │ Envío           │ │
│ └────────────────────┘ │ │ Total           │ │
│                        │ │                 │ │
│ [Cupón input]         │ │ [Iniciar compra] │ │
│                        │ └─────────────────┘ │
└────────────────────────┴─────────────────────┘
```

- 2 columnas: items (⅔) + resumen sticky (⅓).
- Items más grandes, foto 120×120px.
- Cupón input dentro de la columna de items, arriba del resumen (o integrado en el resumen).
- Botón CTA dentro del CartSummary.

---

## 5. Checkout Paso 1 — Datos Personales (Mobile, 375px)

> **Ruta:** `/checkout` (step 0) | **Layout:** `CheckoutLayout` | **Componentes:** `StepIndicator`, `CheckoutStep1` > `Select`, `Input` × N, `Checkbox`, `Button`

### Layout y Estructura

```
┌────────────────────────────────┐
│ HEADER MINIMAL                  │
│ [←] Checkout                   │  Solo logo + back. Sin menú.
├────────────────────────────────┤
│ STEP INDICATOR                  │
│ ● Datos ── ○ Envío ── ○ Pago ── ○ Confirmar
│ Paso 1 de 4                    │  4 dots conectados. El actual: primary.
├────────────────────────────────┤
│ RESUMEN (colapsable)            │
│ ▼ Ver resumen ($XX.XXX)        │  Accordion: expande CartSummary
├────────────────────────────────┤
│ TIPO DE CLIENTE                 │
│ ○ Persona   ● Empresa          │  RadioGroup horizontal si hay >1 tipo
├────────────────────────────────┤
│ DATOS PERSONALES                │  Campos dinámicos según tipo
│ ┌────────────────────────────┐  │
│ │ Nombre *                  │  │  Input label + required asterisco
│ └────────────────────────────┘  │
│ ┌────────────────────────────┐  │
│ │ Apellido *                │  │
│ └────────────────────────────┘  │
│ ┌────────────────────────────┐  │
│ │ DNI *                     │  │  inputMode="numeric", maxLength=8
│ │ Error: DNI inválido       │  │
│ └────────────────────────────┘  │
│ ┌────────────────────────────┐  │
│ │ Email *                   │  │  type="email"
│ └────────────────────────────┘  │
│ ┌──────────┐ ┌──────────────┐  │
│ │ Área *   │ │ Teléfono *   │  │  Grid 2 columnas
│ │ 11       │ │ 45678901     │  │  Área: maxLength=4, Tel: maxLength=10
│ └──────────┘ └──────────────┘  │
├────────────────────────────────┤
│ ☐ Deseo recibir novedades y   │  Checkbox marketing (opcional)
│   promociones por email        │
├────────────────────────────────┤
│ ⚠ El monto mínimo de compra   │  Alert warning (si no se alcanza)
│ es $XX.XXX. Te faltan $X.XXX  │
├────────────────────────────────┤
│ ┌────────────────────────────┐ │
│ │  Continuar al envío  →    │ │  Button primary, full-width, h-12
│ └────────────────────────────┘ │
└────────────────────────────────┘
```

### Jerarquía Visual

1. Campos obligatorios (marcados con asterisco rojo).
2. Botón "Continuar" — la acción principal, al final del form.
3. Step Indicator — contexto de progreso.
4. Resumen colapsable — información de referencia.

### Componentes React

`StepIndicator` (4 steps, current=0), `Select` (tipo de cliente), `Input` (nombre, apellido, DNI, email, área, teléfono / razón social, CUIT, nombre fantasía), `Checkbox` (marketing), `Alert` (compra mínima), `CartSummary` (en accordion), `Button`

### Validación en Tiempo Real

- Zod schema con `mode: 'onChange'`.
- Cada campo muestra error inline debajo apenas el usuario sale del campo (`onBlur`) o mientras tipea si ya hubo error.
- DNI: validar formato `^\d{7,8}$` con mensaje "El DNI debe tener 7 u 8 dígitos".
- CUIT: validar formato `^\d{2}-\d{8}-\d{1}$` con máscara automática (XX-XXXXXXXX-X).
- Email: validar formato email + debounce para verificar si ya existe (opcional, solo si queremos sugerir login).
- Teléfono: validar `^\d{6,10}$`.

### Estados

| Estado | Visual |
|---|---|
| **Loading** | Skeleton del formulario: 5-6 rectángulos de input + rect botón. StepIndicator visible. |
| **Campos pre-llenados (logueado)** | Si el cliente está logueado, los campos vienen pre-llenados del perfil. El usuario puede modificarlos. |
| **Campos dinámicos (cambio de tipo)** | Al cambiar de Persona a Empresa, los campos hacen fade out/in (200ms). Los datos de persona se guardan en el estado local por si vuelve a cambiar. |
| **Validación** | Errores inline en rojo debajo del campo. El botón se mantiene enabled (validación completa en submit). Al hacer submit, scroll al primer error. |
| **Guardando** | Botón: `Spinner` + "Guardando...". Deshabilitado. |
| **Error de API** | Toast error: "No se pudieron guardar los datos. Reintentá." El formulario mantiene los datos. |
| **Compra mínima no alcanzada** | Alert warning. Botón disabled. |

### Navegación

- Back button → volver al carrito (con confirmación si hay cambios).
- "Continuar al envío" → avanza a paso 2 (animación slide left).
- Step Indicator: solo muestra progreso (no clickeable en mobile hasta que los pasos estén completados).

### Desktop (≥1024px)

```
┌──────────────────────────────────────────────────────┐
│ Header minimal + StepIndicator (4 pasos completos)   │
├──────────────────────────────┬───────────────────────┤
│ FORMULARIO (2/3 width)       │ RESUMEN (1/3, sticky) │
│                              │                       │
│ Tipo de cliente              │ ┌───────────────────┐ │
│ ┌──────────┐ ┌────────────┐  │ │ Resumen           │ │
│ │ Nombre   │ │ Apellido   │  │ │ Subtotal  $XX.XXX │ │
│ └──────────┘ └────────────┘  │ │ Descuentos        │ │
│ ┌──────────┐ ┌────────────┐  │ │ Envío    (—)      │ │
│ │ DNI      │ │ Email      │  │ │ Total    $XX.XXX  │ │
│ └──────────┘ └────────────┘  │ └───────────────────┘ │
│ ┌──────────┐ ┌────────────┐  │                       │
│ │ Área     │ │ Teléfono   │  │                       │
│ └──────────┘ └────────────┘  │                       │
│ ☐ Marketing                  │                       │
│                              │                       │
│ [Continuar al envío]         │                       │
└──────────────────────────────┴───────────────────────┘
```

- Campos en grid de 2 columnas donde tenga sentido (nombre+apellido, área+teléfono).
- CartSummary sticky en sidebar derecho. Se actualiza con el envío en pasos siguientes.
- StepIndicator: se puede clickear en pasos ya completados para volver.

---

## 6. Checkout Paso 2 — Forma de Entrega (Mobile, 375px)

> **Ruta:** `/checkout` (step 1) | **Componentes:** `CheckoutStep2` > `RadioGroup`, `AddressCard` × N, `AddressForm`, `Select`, `Checkbox`

### Layout y Estructura

```
┌────────────────────────────────┐
│ STEP INDICATOR                  │
│ ✓ Datos ── ● Envío ── ○ Pago ── ○ Confirmar
├────────────────────────────────┤
│ ▼ Ver resumen ($XX.XXX)        │  Accordion colapsable
├────────────────────────────────┤
│ FORMA DE ENTREGA               │
│ ┌────────────────────────────┐  │
│ │ 🏪 Retiro por sucursal     │  │  RadioGroup con cards visuales
│ │   Gratis                   │  │  Ícono + título + costo
│ │   ○                        │  │  Borde primary si seleccionada
│ └────────────────────────────┘  │
│ ┌────────────────────────────┐  │
│ │ 🚚 Envío a domicilio      │  │
│ │   $X.XXX                  │  │
│ │   ●                        │  │  ← seleccionada
│ └────────────────────────────┘  │
│ ┌────────────────────────────┐  │
│ │ 📍 Punto Zipnova          │  │  Solo si el cliente tiene Zipnova
│ │   $X.XXX                  │  │
│ │   ○                        │  │
│ └────────────────────────────┘  │
├────────────────────────────────┤
│ [Si retiro por sucursal:]     │
│ SUCURSAL                       │
│ ▼ Sucursal Palermo (Gratis)  │  Select con sucursales disponibles
│   Dirección, horarios         │  Info extra debajo del select
│   [Ver en mapa]               │  Link a Google Maps
├────────────────────────────────┤
│ [Si envío a domicilio:]       │
│ DIRECCIÓN DE ENVÍO             │
│ ┌────────────────────────────┐  │
│ │ 🏠 Casa (Predeterminada)   │  │  AddressCard seleccionable
│ │   Av. Corrientes 1234...  │  │  Radio visual, border-primary
│ │   CABA, CP 1425            │  │  Badge "Predeterminada"
│ │                        [✎] │  │  Botón editar
│ └────────────────────────────┘  │
│ ┌────────────────────────────┐  │
│ │ 🏢 Oficina                │  │  AddressCard no seleccionada
│ │   Maipú 567, 3B...       │  │  Borde gris
│ │                        [✎] │  │
│ └────────────────────────────┘  │
│                                │
│ + Agregar nueva dirección      │  Link que expande AddressForm inline
│                                │  o abre Modal con AddressForm
├────────────────────────────────┤
│ [Si envío a domicilio sin     │
│  direcciones guardadas:]      │
│ NUEVA DIRECCIÓN                │
│ ┌────────────────────────────┐  │
│ │ Código postal *           │  │  inputMode="numeric"
│ │ [1425               ]     │  │  Al blur, autocompleta provincia+localidad
│ └────────────────────────────┘  │
│ ┌────────────────────────────┐  │
│ │ Provincia *               │  │  Select con provincias
│ │ [CABA              ▼]     │  │  Cargado por API o autocompletado por CP
│ └────────────────────────────┘  │
│ ┌────────────────────────────┐  │
│ │ Localidad *               │  │  Select, depende de provincia
│ │ [Palermo            ▼]    │  │
│ └────────────────────────────┘  │
│ ┌──────────┐ ┌──────────────┐  │
│ │ Calle *  │ │ Número *     │  │  Grid 2 cols
│ └──────────┘ └──────────────┘  │
│ ┌────────────────────────────┐  │
│ │ Depto/Piso (opcional)     │  │
│ └────────────────────────────┘  │
│ ┌────────────────────────────┐  │
│ │ Etiqueta (opcional)       │  │  Placeholder: "Ej: Casa, Trabajo"
│ └────────────────────────────┘  │
│ ☐ Usar como predeterminada     │
├────────────────────────────────┤
│ MÉTODO DE ENVÍO (si aplica)   │
│ ▼ Correo Argentino - $X.XXX  │  Select con métodos disponibles
│   Llega en 3-5 días hábiles  │  Según provincia y localidad
│   [Envío gratis desde $XXK]  │
├────────────────────────────────┤
│ FACTURACIÓN                    │
│ ☑ Usar misma dirección        │  Checkbox. Si destildado:
│   para facturación            │  → mostrar campos de dirección facturación
├────────────────────────────────┤
│ ┌────────────────────────────┐ │
│ │  Continuar al pago  →     │ │  Button primary
│ └────────────────────────────┘ │
└────────────────────────────────┘
```

### Jerarquía Visual

1. Forma de entrega — la decisión principal de este paso.
2. Dirección — campos obligatorios para completar la entrega.
3. Método de envío — opciones según zona.
4. Facturación — opcional.
5. Botón Continuar.

### Componentes React

`RadioGroup` (forma de entrega), `AddressCard` × N, `AddressForm`, `Select` (sucursal, provincia, localidad, método de envío), `Input` (CP, calle, número, depto, etiqueta), `Checkbox` (predeterminada, misma dirección facturación), `Button`

### Estados

| Estado | Visual |
|---|---|
| **Loading** | Skeleton: 3 cards de radio grandes + 4-5 rectángulos de input. |
| **Cliente sin direcciones** | No mostrar sección AddressCard. Directamente el AddressForm. |
| **Cliente con direcciones** | Mostrar AddressCards seleccionables + link "Agregar nueva". |
| **Agregando nueva dirección** | Animación expand (300ms) para mostrar AddressForm debajo del link. O Modal. |
| **Cargando provincias/localidades** | Select con estado loading (spinner en el chevron). |
| **Autocompletado por CP** | Al ingresar CP y blur (debounce 500ms), se hace `GET /api/geo/cp?codigo=`. Si encuentra, autocompleta provincia y localidad con highlight sutil. Si no encuentra, el usuario las selecciona manualmente. |
| **Costo de envío calculándose** | Spinner chico al lado del método de envío. Se actualiza el CartSummary. |
| **Sin cobertura** | Mensaje: "No realizamos envíos a esta zona. Probá con retiro en sucursal o punto Zipnova." La opción de envío se deshabilita. |
| **Guardando** | Botón `Spinner` + "Guardando...". |

### Navegación

- Back → paso 1.
- "Continuar al pago" → paso 3.
- "Ver en mapa" → abre Google Maps en nueva pestaña.

### Desktop (≥1024px)

- 2 columnas: formulario (⅔) + CartSummary sticky (⅓).
- AddressCards en grid de 2 columnas para aprovechar el ancho.
- Los campos de dirección en grid de 2-3 columnas.
- El CartSummary ahora muestra "Envío: $XXX" (antes mostraba "—" en paso 1).

---

## 7. Checkout Paso 3 — Medio de Pago (Mobile, 375px)

> **Ruta:** `/checkout` (step 2) | **Componentes:** `CheckoutStep3` > `PaymentMethodSelector`

### Layout y Estructura

```
┌────────────────────────────────┐
│ STEP INDICATOR                  │
│ ✓ Datos ── ✓ Envío ── ● Pago ── ○ Confirmar
├────────────────────────────────┤
│ ▼ Ver resumen ($XX.XXX)        │
├────────────────────────────────┤
│ ELEGÍ CÓMO PAGAR               │
│                                │
│ ┌────────────────────────────┐  │
│ │ 💳 MercadoPago             │  │  Card grande con ícono + descripción
│ │ Tarjetas de crédito/débito │  │  + costo
│ │ dinero en cuenta.           │  │  Borde primary si seleccionada
│ │ Hasta 12 cuotas.            │  │
│ │                          ●  │  │  Radio a la derecha
│ └────────────────────────────┘  │
│                                │
│ ┌────────────────────────────┐  │
│ │ 🏦 Transferencia bancaria  │  │
│ │ Transferí desde tu banco   │  │
│ │ y subí el comprobante.     │  │
│ │                          ○  │  │
│ └────────────────────────────┘  │
│                                │
│ ┌────────────────────────────┐  │
│ │ 💵 Efectivo                │  │
│ │ Pagá cuando retirás        │  │
│ │ tu pedido.                 │  │
│ │                          ○  │  │
│ └────────────────────────────┘  │
├────────────────────────────────┤
│ [Si MercadoPago:]              │
│ ℹ️ Podés pagar en hasta 12    │  Alert info
│ cuotas sin interés con         │
│ tarjetas seleccionadas.        │
│                                │
│ Cuotas disponibles:            │  Accordion "Ver cuotas"
│ ▼ Ver cuotas                  │
│   3 cuotas de $X.XXX          │
│   6 cuotas de $X.XXX          │
│   12 cuotas de $X.XXX         │
├────────────────────────────────┤
│ [Si Transferencia:]            │
│ ℹ️ Datos para la transferencia│  Alert info con datos bancarios
│ Banco: XXXX                   │
│ CBU: XXXXXXXXXXXXXX [Copiar]  │  Botón copiar
│ Alias: TIENDA.PAGOS           │
│ Titular: XXXXXXXX             │
│ CUIT: XX-XXXXXXXX-X           │
├────────────────────────────────┤
│ ┌────────────────────────────┐ │
│ │  Continuar →              │ │  Button primary
│ └────────────────────────────┘ │
└────────────────────────────────┘
```

### Jerarquía Visual

1. Opciones de pago — la decisión principal. Cards grandes y fáciles de comparar.
2. Información adicional — cuotas (MP) o datos bancarios (Transferencia).
3. Botón Continuar.

### Componentes React

`RadioGroup` (PaymentMethodSelector con cards), `Alert` (info cuotas, datos bancarios), `Accordion` (cuotas), `Button`

### Estados

| Estado | Visual |
|---|---|
| **Loading** | 3 skeletons de cards de pago (rectángulos con ícono circular). |
| **Un solo método disponible** | Si el cliente solo tiene 1 método habilitado (ej: solo MP), viene pre-seleccionado. La card igual se muestra. |
| **Sin métodos** | "No hay métodos de pago disponibles para tu perfil. Contactanos para más información." |
| **Guardando** | Botón `Spinner` + "Guardando...". |

### Navegación

- Back → paso 2.
- "Continuar" → paso 4 (Confirmación).
- "Copiar" (CBU) → copia al portapapeles + toast "CBU copiado".
- "Ver cuotas" → expande accordion inline.

### Desktop (≥1024px)

- 2 columnas: métodos de pago (⅔) + CartSummary sticky (⅓).
- Las cards de pago pueden estar en grid de 2 columnas (si son 3 o más métodos).
- El CartSummary ya muestra el total completo (con envío).

---

## 8. Checkout Paso 4 — Confirmar (Mobile, 375px)

> **Ruta:** `/checkout` (step 3) | **Componentes:** `CheckoutStep4`

### Layout y Estructura

```
┌────────────────────────────────┐
│ STEP INDICATOR                  │
│ ✓ Datos ── ✓ Envío ── ✓ Pago ── ● Confirmar
├────────────────────────────────┤
│ ▼ Ver resumen ($XX.XXX)        │
├────────────────────────────────┤
│ REVISÁ TU PEDIDO               │
│                                │
│ ┌────────────────────────────┐  │
│ │ Datos personales     [Editar]│ │  Sección colapsable
│ │ ▼                          │  │  Abierta por defecto
│ │ Nombre Apellido            │  │  Botón Editar → vuelve a paso 1
│ │ DNI XX.XXX.XXX             │  │
│ │ email@ejemplo.com          │  │
│ │ 11 45678901                │  │
│ └────────────────────────────┘  │
│ ┌────────────────────────────┐  │
│ │ Envío                [Editar]│ │
│ │ ▼                          │  │
│ │ Envío a domicilio         │  │
│ │ Av. Corrientes 1234      │  │
│ │ Palermo, CABA - CP 1425  │  │
│ │ Correo Argentino - $XXX  │  │
│ └────────────────────────────┘  │
│ ┌────────────────────────────┐  │
│ │ Pago                 [Editar]│ │
│ │ ▼                          │  │
│ │ MercadoPago               │  │
│ │ Tarjetas de crédito       │  │
│ └────────────────────────────┘  │
├────────────────────────────────┤
│ RESUMEN DE COMPRA              │
│ ┌────────────────────────────┐  │
│ │ Items (3)                  │  │  Lista compacta de items
│ │ ┌────────────────────────┐ │  │
│ │ │ [foto40] Prod 1  ×2   │ │  │  Foto 40px + nombre + cantidad
│ │ │          $XX.XXX      │ │  │  + subtotal
│ │ └────────────────────────┘ │  │
│ │ ┌────────────────────────┐ │  │
│ │ │ [foto40] Prod 2  ×1   │ │  │
│ │ │          $YY.YYY      │ │  │
│ │ └────────────────────────┘ │  │
│ │                            │  │
│ │ Subtotal          $XX.XXX │  │
│ │ Descuento          -$X.XXX│  │
│ │ Envío              $X.XXX │  │
│ │ ───────────────────────── │  │
│ │ TOTAL             $XX.XXX │  │  text-xl, font-bold
│ └────────────────────────────┘  │
├────────────────────────────────┤
│ ┌────────────────────────────┐ │
│ │  Confirmar compra         │ │  Button primary, full-width, h-14 (56px)
│ │  Pagar $XX.XXX            │ │  text-lg, font-semibold, shadow-lg
│ └────────────────────────────┘ │
│                                │
│ Al confirmar aceptás los      │  Texto legal chico
│ términos y condiciones        │
└────────────────────────────────┘
```

### Jerarquía Visual

1. **Total + Botón Confirmar** — lo más importante.
2. **Resumen de compra** — items y totales.
3. **Secciones de datos** — colapsables, verificables.

### Componentes React

`Accordion` (secciones de datos), `CartItem` (read-only, compacto), `CartSummary` (readOnly), `Button`

### Estados

| Estado | Visual |
|---|---|
| **Confirmando** | Botón: `Spinner` + "Procesando tu pedido...". Overlay semi-transparente sobre toda la página + mensaje "No cierres esta ventana". |
| **Error de stock** | Toast error: "El producto 'XYZ' ya no tiene stock suficiente. Volvé al carrito para ajustar." NO se redirige automáticamente. |
| **Error de precio** | Toast error: "Los precios de algunos productos cambiaron. Revisá el resumen actualizado." El resumen se actualiza. |
| **Error de pago (API)** | Toast error: "No se pudo procesar el pago. Reintentá." Botón de Confirmar sigue habilitado. |
| **Éxito (MP)** | Redirección a URL de MercadoPago (con mensaje breve "Redirigiendo al portal de pago..."). |
| **Éxito (Transferencia/Efectivo)** | Página de éxito (ver abajo). |

### Resultado Post-Confirmación

**Página de Éxito (Transferencia / Efectivo):**
```
┌────────────────────────────────┐
│                                │
│            ✓ (Verde)           │  Ícono check en círculo verde, 64px
│                                │
│     ¡Gracias, [Nombre]!        │  text-2xl, font-bold
│                                │
│     Tu pedido #ABC123          │  text-lg
│     fue registrado.            │
│                                │
│ ┌────────────────────────────┐  │
│ │ Resumen del pedido          │  │
│ │ 3 productos — $XX.XXX      │  │
│ │ Envío a domicilio          │  │
│ │ Correo Argentino           │  │
│ └────────────────────────────┘  │
│                                │
│ [Si Transferencia:]            │
│ ┌────────────────────────────┐  │
│ │ Transferí a:               │  │
│ │ CBU: XXXX  [Copiar]        │  │
│ │ Alias: TIENDA.PAGOS        │  │
│ └────────────────────────────┘  │
│ ┌────────────────────────────┐  │
│ │  Subir comprobante        │  │  Button primary
│ └────────────────────────────┘  │
│                                │
│ Te enviamos un email a         │  text-sm, text-gray-500
│ email@ejemplo.com              │
│                                │
│ ┌────────────────────────────┐  │
│ │  Ver mi pedido            │  │  Button secondary
│ └────────────────────────────┘  │
│                                │
│   Seguir comprando            │  Link
└────────────────────────────────┘
```

### Navegación

- "Editar" en cada sección → vuelve al paso correspondiente. Los datos ya están guardados en el backend.
- "Confirmar compra" → ejecuta `POST /api/checkout/confirm`.
- "Ver mi pedido" → `/cuenta/pedidos/{hash}`.
- "Seguir comprando" → `/`.

### Desktop (≥1024px)

- 2 columnas: secciones de datos + resumen (⅔) + CartSummary sticky (⅓).
- El CartSummary es el mismo de los pasos anteriores pero en modo readOnly.
- Las secciones de datos se muestran en grid de 2 columnas (Datos + Envío lado a lado, Pago abajo).
- Botón Confirmar tiene ancho natural, no full-width.
- Sin el accordion de resumen (ya está en el sidebar).

---

## 9. Login / Registro (Mobile, 375px)

> **Rutas:** `/login`, `/registro` | **Layout:** `AuthLayout` | **Componentes:** `Input`, `Button`, `Checkbox`, `Alert`

### Layout y Estructura

```
┌────────────────────────────────┐
│                                │
│         [LOGO]                 │  Logo de la tienda, 48-64px altura
│                                │
│      Nombre Tienda             │  text-xl, font-bold
│                                │
├────────────────────────────────┤
│ [TABS: Iniciar sesión | Crear cuenta]
│                                │
│ ─── INICIAR SESIÓN ───        │
│                                │
│ ┌────────────────────────────┐  │
│ │ Email                     │  │
│ └────────────────────────────┘  │
│ ┌────────────────────────────┐  │
│ │ Contraseña        [👁]    │  │  Botón mostrar/ocultar
│ └────────────────────────────┘  │
│                                │
│ ☐ Recordarme                  │  Checkbox
│                                │
│ ┌────────────────────────────┐  │
│ │    Iniciar sesión         │  │  Button primary, full-width, h-12
│ └────────────────────────────┘  │
│                                │
│      Olvidé mi contraseña     │  Link a `/recuperar`
│                                │
│ ─────────────────────────────  │
│                                │
│ ─── CREAR CUENTA ───          │
│                                │
│ ┌────────────────────────────┐  │
│ │ Nombre                    │  │
│ └────────────────────────────┘  │
│ ┌────────────────────────────┐  │
│ │ Apellido                  │  │
│ └────────────────────────────┘  │
│ ┌────────────────────────────┐  │
│ │ Email                     │  │  Validación de formato + disponibilidad
│ └────────────────────────────┘  │
│ ┌────────────────────────────┐  │
│ │ Contraseña        [👁]    │  │
│ │ ████████░░  Débil         │  │  Indicador de fortaleza
│ └────────────────────────────┘  │
│ ┌────────────────────────────┐  │
│ │ Repetir contraseña [👁]   │  │
│ └────────────────────────────┘  │
│                                │
│ ☐ Acepto los términos y       │
│    condiciones                 │
│                                │
│ ┌────────────────────────────┐  │
│ │    Crear cuenta           │  │  Button primary, full-width
│ └────────────────────────────┘  │
│                                │
│   ← Volver a la tienda        │
└────────────────────────────────┘
```

### Jerarquía Visual

1. Logo — identificación visual.
2. Formulario — la acción principal.
3. Links secundarios — recuperar, volver a la tienda.

### Componentes React

`Input` (email, contraseña), `Button`, `Checkbox` (recordarme, términos), `Tabs` (Login | Registro), `Alert` (error)

### Estados

| Estado | Visual |
|---|---|
| **Login — Loading** | Botón `Spinner` + "Ingresando...". |
| **Login — Error** | Alert error: "Email o contraseña incorrectos." (genérico). |
| **Login — Cuenta no activada** | "Tu cuenta no está activada. Revisá tu email." + botón "Reenviar". |
| **Login — Bloqueo temporal** | "Demasiados intentos. Esperá 15 minutos." |
| **Registro — Loading** | Botón `Spinner` + "Creando cuenta...". |
| **Registro — Email duplicado** | Error inline: "Este email ya está registrado." + link "Iniciar sesión". |
| **Registro — Éxito** | "¡Cuenta creada! Te enviamos un email para activarla." |
| **Registro — Fortaleza de contraseña** | Barra de progreso: rojo (< 8 chars), amarillo (8+ chars), verde (8+ chars + mayúscula + número). |
| **Registro — Contraseñas no coinciden** | Error inline en "Repetir contraseña". |

### Navegación

- "Olvidé mi contraseña" → `/recuperar`.
- "Crear cuenta" (desde login) → activa tab Registro.
- "Iniciar sesión" (desde registro) → activa tab Login.
- "← Volver a la tienda" → `/`.
- Post-login: redirigir a `?redirect=` o `/`.

### Desktop (≥1024px)

- Layout split: izquierda (50%) con logo grande, nombre de la tienda, ilustración/fondo. Derecha (50%) con formulario centrado.
- El formulario es más ancho (max-w-md).
- Sin tabs: se muestran ambas opciones en páginas separadas (o dos columnas lado a lado si se prefiere).
- El lado izquierdo puede tener el fondo de login configurado por tenant.

---

## 10. Mi Cuenta — Panel (Mobile, 375px)

> **Layout:** `AccountLayout` | **Componentes:** `Tabs`/`AccountSidebar`, `Button`

### Layout y Estructura

```
┌────────────────────────────────┐
│ HEADER                          │
│ [←] Hola, [Nombre]    [🛒 3] │
├────────────────────────────────┤
│ NAVEGACIÓN DE CUENTA (Tabs)    │
│ [👤 Perfil] [📦 Pedidos] [📍 Dir] [❤️ Fav]
│ Scroll horizontal si no entran │  4 tabs con íconos
├────────────────────────────────┤
│ CONTENIDO                       │  Varía según tab seleccionado
│ ...                             │
└────────────────────────────────┘
```

### Navegación Mobile

- **Opción A (Tabs):** 4-5 tabs horizontales con íconos, scrollables si no entran. Fáciles de tappear (min 44px altura). El tab activo tiene color primary y borde inferior.
- **Opción B (Menú dropdown):** Botón "Mi Cuenta ▼" que despliega las opciones en un `Dropdown` o mini-menú. Útil si hay más de 5 opciones.

### Desktop (≥1024px)

```
┌──────────────────────────────────────────────┐
│ Header                                       │
├──────────┬───────────────────────────────────┤
│ SIDEBAR  │ CONTENIDO                         │
│          │                                   │
│ 👤 Perfil│ [Perfil form / Pedidos / etc.]   │
│ 📦 Pedido│                                   │
│   - #123 │                                   │
│ 📍 Direc │                                   │
│ ❤️ Favor │                                   │
│ 🏢 Empres│ (solo si es tipo empresa)        │
│ ──────── │                                   │
│ 🚪 Salir │                                   │
│          │                                   │
│ w-56     │ flex-1, max-w-3xl                │
└──────────┴───────────────────────────────────┘
```

- Sidebar izquierda, w-56 (224px), con links + íconos.
- Ítem activo: bg-primary-50, text-primary, borde izquierdo primary.
- Separador antes de "Cerrar sesión".
- Contenido a la derecha, centrado, max-w-3xl.

---

## 11. Historial de Pedidos (Mobile, 375px)

> **Ruta:** `/cuenta/pedidos` | **Componentes:** `OrderCard` × N, `Pagination`, `Select` (filtro por estado)

### Layout y Estructura

```
┌────────────────────────────────┐
│ MIS PEDIDOS                     │
│ [Todos ▼]              3 pedido│  Select para filtrar por estado
├────────────────────────────────┤
│ ┌────────────────────────────┐  │
│ │ Pedido #ABC123    [Entregado]│ │  OrderCard: badge de estado
│ │ 15 de junio, 2026          │  │  Fecha formateada
│ │                            │  │
│ │ 3 productos  ● Pagado      │  │  Badges de pago y envío
│ │              ● Enviado     │  │
│ │                            │  │
│ │ ─────────────────────────  │  │
│ │ Total: $XX.XXX            │  │
│ │ Ver detalle →  [Repetir]  │  │  Link + botón
│ └────────────────────────────┘  │
│ ┌────────────────────────────┐  │
│ │ Pedido #DEF456    [Activo] │  │
│ │ 10 de junio, 2026          │  │
│ │ 1 producto   ● Pendiente   │  │
│ │              ○ Sin envío   │  │
│ │ Total: $XX.XXX            │  │
│ │ Ver detalle →  [Repetir]  │  │
│ └────────────────────────────┘  │
│                                │
│ [← Anteriores  Siguientes →]  │  Paginación
└────────────────────────────────┘
```

### Componentes React

`Select` (filtro por estado: Todos, Activo, Pagado, Enviado, Entregado), `OrderCard` × N, `Pagination`

### Estados

| Estado | Visual |
|---|---|
| **Loading** | 5 skeletons OrderCard (rectángulos con texto). |
| **Vacío** | Ícono caja + "Todavía no hiciste ningún pedido." + botón "Ver productos". |
| **Error** | Toast error + botón "Reintentar". |

### Detalle de Pedido (Mobile)

```
┌────────────────────────────────┐
│ [←] Pedido #ABC123             │
├────────────────────────────────┤
│ ESTADO: ENTREGADO              │  Badge grande, color success
├────────────────────────────────┤
│ TIMELINE                       │
│ ● Pedido creado                │  OrderTimeline vertical
│ │ 15 jun, 14:30               │
│ ● Pago confirmado              │
│ │ 15 jun, 14:32               │
│ ● Preparando                   │
│ │ 16 jun, 09:15               │
│ ● Enviado                      │
│ │ 16 jun, 16:00               │
│ ● Entregado                    │
│ │ 18 jun, 10:30               │
├────────────────────────────────┤
│ DETALLE DE ENVÍO               │
│ Correo Argentino               │
│ Tracking: ABC123456           │
│ [Seguir envío →]              │  Link a tracking de correo/Zipnova
├────────────────────────────────┤
│ PRODUCTOS                      │
│ ┌────────────────────────────┐  │
│ │ [foto60] Nombre Producto   │  │
│ │          SKU: ABC-123      │  │
│ │          ×2  $XX.XXX c/u  │  │
│ │          Subt: $XX.XXX     │  │
│ └────────────────────────────┘  │
├────────────────────────────────┤
│ RESUMEN                        │
│ Subtotal              $XX.XXX │
│ Descuento              -$X.XXX│
│ Envío                  $X.XXX │
│ TOTAL                 $XX.XXX │
├────────────────────────────────┤
│ DATOS DE ENTREGA               │
│ Av. Corrientes 1234           │
│ Palermo, CABA, CP 1425       │
├────────────────────────────────┤
│ DATOS DE FACTURACIÓN           │
│ Nombre Apellido               │
│ DNI XX.XXX.XXX                │
├────────────────────────────────┤
│ ┌────────────────────────────┐  │
│ │  Repetir compra           │  │  Button secondary
│ └────────────────────────────┘  │
│   ¿Necesitás ayuda?            │  Link a contacto
│   Contactanos                  │
└────────────────────────────────┘
```

### Desktop (≥1024px)

- Layout 2 columnas: izquierda (timeline + items, ⅔) + derecha (resumen, datos de entrega, facturación, ⅓).
- Las OrderCards en la lista usan más ancho, 1 columna full-width.
- El timeline puede ser horizontal en desktop (pasos conectados con flechas).

---

## 12. Admin Dashboard (Desktop, 1440px)

> **Ruta:** `/admin` | **Layout:** `AdminLayout` | **Componentes:** `KpiCard` × N, `Recharts`, `AdminDataTable`

### Layout y Estructura

```
┌──────┬─────────────────────────────────────────────────────────┐
│SIDEB.│ HEADER: [🔍 Buscar...]       [🔔] [👤 Admin] [Salir]  │
│      ├─────────────────────────────────────────────────────────┤
│ 📊   │ DASHBOARD                          [Junio 2026 ▼]      │
│ Dash │                                                         │
│      │ ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐   │
│ 📦   │ │Ventas mes│ │Pedidos   │ │Ticket    │ │Productos │   │
│ Prod │ │$XX.XXX   │ │42        │ │promedio  │ │activos   │   │
│      │ │▲ 12% vs  │ │▲ 8%      │ │$X.XXX    │ │156       │   │
│ 📋   │ │mes ant.  │ │          │ │▼ 3%      │ │          │   │
│ Pedi │ └──────────┘ └──────────┘ └──────────┘ └──────────┘   │
│      │                                                         │
│ 👥   │ ┌──────────┐ ┌──────────┐                              │
│ Clie │ │Clientes  │ │Tasa Conv.│                              │
│      │ │nuevos    │ │Checkout  │                              │
│ ⚙️   │ │8         │ │68%       │                              │
│ Conf │ └──────────┘ └──────────┘                              │
│      │                                                         │
│      │ VENTAS POR DÍA (Últimos 30 días)                       │
│      │ ┌──────────────────────────────────────────────────┐   │
│      │ │  │     │\                                     │   │
│      │ │  │   /\│ \  /\                                │   │
│      │ │  │  /  \│  \/  \      /\                      │   │
│      │ │  │ /    \│       \    /  \                     │   │
│      │ │  │/      \│        \/\/    \                   │   │
│      │ │  └──────────────────────────────────────────   │   │
│      │ │  1  5  10  15  20  25  30                      │   │
│      │ └──────────────────────────────────────────────────┘   │
│      │                                                         │
│      │ ┌─────────────────────┐ ┌─────────────────────────────┐│
│      │ │PRODUCTOS + VENDIDOS│ │ ÚLTIMOS PEDIDOS              ││
│      │ │ (gráfico barras)   │ │ ┌───────────────────────────┐││
│      │ │                    │ │ │#hash │Cliente│Total│Estado │││
│      │ │ Prod A ████████   │ │ │#123  │Juan   │$XXX │Pagado │││
│      │ │ Prod B ██████     │ │ │#124  │María  │$YYY │Activo │││
│      │ │ Prod C ████       │ │ │ ...                      │││
│      │ │ Prod D ███        │ │ └───────────────────────────┘││
│      │ └─────────────────────┘ │ [Ver todos los pedidos →]   ││
│      │                         └─────────────────────────────┘│
└──────┴─────────────────────────────────────────────────────────┘
```

### Sidebar (Admin)

```
┌──────────────┐
│ [LOGO]      │  Logo pequeño, 32px
├──────────────┤
│ 📊 Dashboard │  Link activo: bg-primary-50, text-primary
│ 📦 Productos │
│ 📋 Pedidos   │
│ 👥 Clientes  │
│ 🏷️ Categorías│
│ 🏭 Marcas    │
│ 🔖 Tags      │
│ 🎨 Propiedad.│
│ 🚚 Envíos    │
│ 🎟️ Cupones   │
│ 🏪 Sucursales│
│ 📄 Contenido │
│ ⚙️ Config.   │
│ 👤 Usuarios  │
│ ───────────  │
│ 🚪 Salir     │
└──────────────┘
w-56 (224px), bg-gray-900 text-white (o bg-white con borde derecho)
```

### Jerarquía Visual

1. **KPIs** — lo primero que ve el admin. Información accionable inmediata.
2. **Gráfico de ventas** — tendencia, rendimiento en el tiempo.
3. **Últimos pedidos** — acción inmediata (procesar pedidos nuevos).
4. **Productos más vendidos** — información complementaria.

### Componentes React

`KpiCard` × 6, `Recharts` (LineChart + BarChart), `AdminDataTable` (últimos pedidos, compacto), `MonthYearPicker`

### Estados

| Estado | Visual |
|---|---|
| **Loading** | 6 skeletons KpiCard (rectángulos), skeleton gráfico (rect grande), skeleton tabla (5 filas). |
| **Sin datos** | KPIs en 0 (no ocultar). Gráficos: "Sin datos para este período". Tabla: "No hay pedidos aún." |
| **Error** | Toast error por sección (KPIs, gráficos, tabla pueden fallar independientemente). Cada sección muestra error + botón "Reintentar". |
| **Cambio de mes** | Spinner overlay en KPIs y gráficos mientras se cargan los nuevos datos. Los datos anteriores se mantienen visibles hasta que lleguen los nuevos. |

### Interacciones

- `MonthYearPicker`: selector de mes/año. Cambia todos los KPIs y gráficos al período seleccionado.
- Hover en gráfico de ventas: tooltip con fecha + monto exacto.
- Click en pedido (tabla) → `/admin/pedidos/{id}`.
- "Ver todos los pedidos" → `/admin/pedidos`.

---

## 13. Admin — Lista de Productos (Desktop, 1440px)

> **Ruta:** `/admin/productos` | **Componentes:** `AdminDataTable`, `SearchBar`, `Button`, `Pagination`

### Layout y Estructura

```
┌──────────────────────────────────────────────────────────────────┐
│ PRODUCTOS                                          [+ Nuevo producto]
├──────────────────────────────────────────────────────────────────┤
│ TOOLBAR                                                          │
│ [🔍 Buscar productos...]  [Marca ▼] [Categoría ▼] [Estado ▼]   │
│                                                                  │
│ 3 seleccionados: [Activar] [Desactivar] [Cambiar cat.] [Eliminar]│
├──────────────────────────────────────────────────────────────────┤
│ DATA TABLE                                                        │
│ ┌──────────────────────────────────────────────────────────────┐ │
│ │☐│Foto│Nombre         │SKU   │Marca │Precio │Stock│Estado│···│ │
│ ├──────────────────────────────────────────────────────────────┤ │
│ │☐│[40]│Remera Algodón │REM001│Nike  │$XX.XXX│ 42  │🟢Act │ ⋮ │ │
│ │☑│[40]│Pantalón Jean  │PAN002│Levi's│$YY.YYY│  0  │🔴Inac│ ⋮ │ │
│ │☐│[40]│Zapatillas Run │ZAP003│Adidas│$ZZ.ZZZ│ 15  │🟢Act │ ⋮ │ │
│ │☑│[40]│Campera Invier.│CAM004│North │$WW.WWW│  3  │🟡Bajo│ ⋮ │ │
│ │ ...                                                          │ │
│ └──────────────────────────────────────────────────────────────┘ │
│                                                                  │
│ Mostrando 1-25 de 156 productos                                  │
│              [← 1 2 3 4 ... 7 →]                                 │
└──────────────────────────────────────────────────────────────────┘
```

### Funcionalidad de la Tabla

- **Server-side:** paginación, sorting, y filtros se envían al backend via `GET /api/admin/products?page=&limit=&sort=&order=&search=&marcaId=&categoriaId=&estado=`.
- **Sorting:** click en header de columna → ordena ascendente/descendente. Ícono de flecha en la columna activa.
- **Filtros:** search busca en nombre y SKU. Selects de marca, categoría y estado filtran server-side.
- **Selección:** checkbox en cada fila + checkbox "Seleccionar todos" en el header. Al seleccionar, aparece la toolbar de bulk actions.
- **Bulk actions:** Activar, Desactivar, Cambiar categoría (abre modal con selector), Eliminar (abre modal de confirmación).
- **Row actions:** dropdown (⋮) en cada fila: Editar, Duplicar, Activar/Desactivar, Eliminar.
- **Badge de stock:** Verde si > 10, Ámbar si 1-10, Rojo si 0.

### Componentes React

`AdminDataTable` (TanStack Table server-side), `SearchBar`, `Select` (filtros), `Button`, `Pagination`, `Modal` (confirmación de bulk actions), `Dropdown` (row actions)

### Estados

| Estado | Visual |
|---|---|
| **Loading** | Skeleton de tabla: header fijo + 10 filas de rectángulos. |
| **Fetching (paginación/filtros)** | Overlay sutil + Spinner en esquina superior derecha de la tabla. Las filas existentes permanecen visibles. |
| **Vacío** | "No se encontraron productos." Si hay filtros aplicados: "Probá con otros filtros." + botón "Limpiar filtros". Si no: "Creá el primer producto." + botón "Nuevo producto". |
| **Error** | Mensaje de error + botón "Reintentar". |
| **Bulk action en progreso** | Spinner en la toolbar de bulk actions. Filas seleccionadas con opacidad reducida. |

---

## 14. Admin — Edición de Producto (Desktop, 1440px)

> **Ruta:** `/admin/productos/{id}` | **Componentes:** `Tabs`, `AdminForm`, `ImageUploader`, `VariantSelector`, `Button`

### Layout y Estructura

```
┌──────────────────────────────────────────────────────────────────┐
│ [← Productos]  /  Editando: Remera Algodón          [Guardar]   │
├──────────────────────────────────────────────────────────────────┤
│ [Información] [Variantes y Stock] [Imágenes] [SEO]              │  Tabs
├──────────────────────────────────────────────────────────────────┤
│                                                                  │
│ INFORMACIÓN                                                      │
│ ┌────────────────────────────┐ ┌────────────────────────────┐   │
│ │ Nombre *                  │ │ URL (slug)                 │   │
│ │ Remera Algodón            │ │ remera-algodon             │   │
│ └────────────────────────────┘ └────────────────────────────┘   │
│                                                                  │
│ ┌────────────────────────────┐ ┌────────────────────────────┐   │
│ │ Marca *                   │ │ Estado                     │   │
│ │ [Nike ▼]                 │ │ [🟢 Activo ●——○]          │   │
│ └────────────────────────────┘ └────────────────────────────┘   │
│                                                                  │
│ Categorías *                                                     │
│ ┌──────────────────────────────────────────────────────────────┐ │
│ │ [✕ Ropa] [✕ Remeras] [+ Agregar categoría]                 │ │
│ └──────────────────────────────────────────────────────────────┘ │
│                                                                  │
│ Tags                                                             │
│ ┌──────────────────────────────────────────────────────────────┐ │
│ │ [✕ Nueva temporada] [✕ Algodón] [+ Agregar tag]            │ │
│ └──────────────────────────────────────────────────────────────┘ │
│                                                                  │
│ Descripción                                                      │
│ ┌──────────────────────────────────────────────────────────────┐ │
│ │ [Editor WYSIWYG — bold, italic, bullets, links, images]     │ │
│ │                                                              │ │
│ │ Remera de algodón 100% peinado...                           │ │
│ │                                                              │ │
│ └──────────────────────────────────────────────────────────────┘ │
│                                                                  │
├──────────────────────────────────────────────────────────────────┤
│ TAB: VARIANTES Y STOCK                                           │
│                                                                  │
│ PROPIEDADES DEL PRODUCTO                                         │
│ ┌─────────────────────┐ ┌─────────────────────┐                 │
│ │ 1. Talle           │ │ 2. Color            │                 │
│ │ [S] [M] [L] [✕ XL]│ │ [●Rojo][●Azul][●Neg]│                 │
│ │ [+ Agregar valor]  │ │ [+ Agregar valor]   │                 │
│ └─────────────────────┘ └─────────────────────┘                 │
│                                                                  │
│ VARIANTES                                                        │
│ ┌──────────────────────────────────────────────────────────────┐ │
│ │ Combinación    │ SKU    │ Precio │ Stock │ Foto │           │ │
│ ├──────────────────────────────────────────────────────────────┤ │
│ │ S / Rojo       │ REM-S-R│ $XX.XXX│ 12   │ [40] │ [✕]      │ │
│ │ S / Azul       │ REM-S-A│ $XX.XXX│  8   │ [40] │ [✕]      │ │
│ │ M / Rojo       │ REM-M-R│ $XX.XXX│  5   │ [40] │ [✕]      │ │
│ │ M / Azul       │ REM-M-A│ $XX.XXX│  0   │ [40] │ [✕]      │ │
│ └──────────────────────────────────────────────────────────────┘ │
│                                                                  │
│ STOCK POR SUCURSAL (al seleccionar una variante)                 │
│ ┌──────────────────────────────────────────────────────────────┐ │
│ │ Sucursal           │ Stock │ Stock Infinito │               │ │
│ ├──────────────────────────────────────────────────────────────┤ │
│ │ Palermo            │   5   │ ○              │               │ │
│ │ Belgrano           │   3   │ ○              │               │ │
│ │ Centro             │   4   │ ○              │               │ │
│ └──────────────────────────────────────────────────────────────┘ │
│                                                                  │
├──────────────────────────────────────────────────────────────────┤
│ TAB: IMÁGENES                                                    │
│                                                                  │
│ ┌──────────────────────────────────────────────────────────────┐ │
│ │                                                              │ │
│ │   [Drag & drop imágenes o click para subir]                  │ │
│ │                                                              │ │
│ │ ┌──────┐ ┌──────┐ ┌──────┐ ┌──────┐ ┌──────┐              │ │
│ │ │[img1]│ │[img2]│ │[img3]│ │[img4]│ │ [+]  │              │ │
│ │ │ PRINC│ │      │ │      │ │      │ │Subir │              │ │
│ │ │ [✕]  │ │ [✕]  │ │ [✕]  │ │ [✕]  │ │      │              │ │
│ │ └──────┘ └──────┘ └──────┘ └──────┘ └──────┘              │ │
│ │   Ordenar arrastrando las imágenes                           │ │
│ └──────────────────────────────────────────────────────────────┘ │
│                                                                  │
├──────────────────────────────────────────────────────────────────┤
│ TAB: SEO (Fase 2 — opcional en MVP)                              │
│                                                                  │
│ Meta título:                                                     │
│ Meta descripción:                                                │
│ Keywords:                                                        │
└──────────────────────────────────────────────────────────────────┘
```

### Componentes React

`Breadcrumb`, `Tabs`, `Input`, `Select`, `Toggle` (estado), `Textarea` / Editor WYSIWYG, `Chip` (categorías, tags), `ImageUploader`, `AdminDataTable` (variantes), `Button`

### Comportamiento de Tabs

- **Información:** campos básicos del producto + descripción WYSIWYG. Los cambios no se guardan hasta hacer clic en "Guardar".
- **Variantes y Stock:** Si el producto no tiene propiedades creadas, mostrar "Agregá propiedades (Talle, Color, etc.) desde Configuración > Propiedades." Si tiene: tabla de combinaciones con posibilidad de generar variantes automáticamente ("Generar todas las combinaciones").
- **Imágenes:** drag-and-drop, reordenamiento, eliminar. La primera imagen es la principal.
- **SEO:** Fase 2. En MVP puede ser un toggle "Usar valores por defecto" que toma nombre y descripción.

### Estados

| Estado | Visual |
|---|---|
| **Loading** | Skeleton por tab: campos de texto, selects con placeholder. |
| **Guardando** | Botón "Guardar": `Spinner` + "Guardando...". |
| **Guardado exitoso** | Toast success "Producto guardado." |
| **Error de validación** | Campos con error resaltados en rojo. Scroll al primer error. Toast con resumen de errores. |
| **Subiendo imágenes** | Progress bar en cada imagen. Placeholder con blur mientras carga. |
| **Generando variantes** | Spinner en la tabla de variantes mientras se generan. |

---

## 15. Admin — CRUD de Pedidos (Desktop, 1440px)

> **Ruta:** `/admin/pedidos`, `/admin/pedidos/{id}` | **Componentes:** `AdminDataTable`, `OrderTimeline`, `Select`, `Button`, `Modal`

### Lista de Pedidos

Similar a la lista de productos pero con columnas específicas de pedidos.

```
┌──────────────────────────────────────────────────────────────────┐
│ PEDIDOS                                                          │
├──────────────────────────────────────────────────────────────────┤
│ [🔍 Buscar...]  [Estado ▼] [Pago ▼] [Desde: 📅] [Hasta: 📅]   │
├──────────────────────────────────────────────────────────────────┤
│ ┌──────────────────────────────────────────────────────────────┐ │
│ │#Hash │Fecha    │Cliente    │Email       │Total │Est. │Acc.│ │
│ ├──────────────────────────────────────────────────────────────┤ │
│ │#ABC12│15/06/26│Juan Pérez │juan@mail..│$XX.XXX│🟢Pag│ ⋮  │ │
│ │#DEF34│15/06/26│María Gómez│maria@mail.│$YY.YYY│🔵Env│ ⋮  │ │
│ │#GHI56│14/06/26│Carlos Ruiz│carlos@mail│$ZZ.ZZZ│🟡Pen│ ⋮  │ │
│ └──────────────────────────────────────────────────────────────┘ │
└──────────────────────────────────────────────────────────────────┘
```

### Detalle de Pedido

```
┌──────────────────────────────────────────────────────────────────┐
│ [← Pedidos]  /  Pedido #ABC123                                   │
│                                         [🖨 Imprimir] [Exportar] │
├────────────────────────────┬─────────────────────────────────────┤
│ ITEMS Y ESTADO             │ INFORMACIÓN DEL CLIENTE             │
│                            │                                     │
│ ┌────────────────────────┐ │ Cliente: Juan Pérez                │
│ │ Remera Algodón ×2      │ │ Email: juan@mail.com              │
│ │ SKU: REM-S-R           │ │ Tel: 11 45678901                  │
│ │ $XX.XXX c/u            │ │ Tipo: Persona                     │
│ │ Subt: $XX.XXX          │ │                                     │
│ └────────────────────────┘ │ DIRECCIÓN DE ENVÍO                 │
│ ┌────────────────────────┐ │ Av. Corrientes 1234              │
│ │ Pantalón Jean ×1       │ │ Palermo, CABA                    │
│ │ SKU: PAN-L-A           │ │ CP 1425                          │
│ │ $YY.YYY                │ │                                     │
│ └────────────────────────┘ │ DIRECCIÓN DE FACTURACIÓN           │
│                            │ (Misma que envío)                  │
│ ┌────────────────────────┐ │                                     │
│ │ Resumen                │ │ DATOS DE PAGO                      │
│ │ Subtotal      $XX.XXX │ │ Método: MercadoPago               │
│ │ Envío          $X.XXX │ │ Estado: Pagado                    │
│ │ Total         $XX.XXX │ │ Payment ID: 12345678              │
│ └────────────────────────┘ │ Cuotas: 3                         │
│                            │                                     │
│ TIMELINE                   │ ACCIONES                            │
│ ● Pedido creado            │                                     │
│ │ 15 jun, 14:30           │ Estado: [Activo ▼]                 │
│ ● Pago confirmado          │                                     │
│ │ 15 jun, 14:32           │ [Guardar estado]                   │
│ ● Preparando               │                                     │
│ │ 16 jun, 09:15           │ ─────────────────────               │
│ ○ Enviado (pendiente)     │ [Enviar email al cliente]          │
│ ○ Entregado                │ [Crear etiqueta envío]            │
│                            │                                     │
│ [+ Agregar nota]          │                                     │
└────────────────────────────┴─────────────────────────────────────┘
```

### Cambio de Estado

Al cambiar el estado con el `Select` y hacer clic en "Guardar estado":
- Modal de confirmación: "¿Cambiar el estado del pedido #ABC123 a 'Enviado'?"
- Si cambia a "Enviado": campo adicional para número de tracking.
- El cliente recibe un email de notificación (configurable).
- El timeline se actualiza automáticamente.

### Componentes React

`AdminDataTable` (pedidos), `Select` (filtros, cambio de estado), `DateRangePicker` (filtro por fecha), `OrderTimeline`, `CartItem` (read-only), `CartSummary` (readOnly), `Button`, `Modal` (confirmación)

---

## Consideraciones Transversales para Todos los Wireframes

### Accesibilidad (WCAG 2.1 AA)

| Elemento | Requisito |
|---|---|
| **Contraste** | Texto normal: 4.5:1 mínimo. Texto grande (18px+): 3:1. |
| **Focus visible** | Todos los interactivos tienen ring de focus de 2px con offset. |
| **Labels** | Todos los inputs tienen `<label>` asociado. |
| **Errores** | Identificados por color + ícono + texto. `aria-invalid` y `aria-describedby`. |
| **Imágenes** | `alt` descriptivo en fotos de producto. `alt=""` en decorativas. |
| **Teclado** | Navegación completa sin mouse. Orden de tab lógico. |
| **Skip links** | "Saltar al contenido" en el primer elemento del DOM. |
| **Landmarks** | `<header>`, `<main>`, `<nav>`, `<footer>` en todos los layouts. |

### Multi-Tenant

- **Colores:** Usar CSS custom properties (`--color-primary`, etc.). No hardcodear colores de tenant.
- **Logos:** Cargar desde `/{tenant}/logos/`. Alt text usa `tenant.nombreFantasia`.
- **Tipografías:** `--font-sans` y `--font-heading` configurables por tenant.
- **Fondo de login:** Imagen de fondo configurable por tenant.

### Animaciones y Transiciones

| Elemento | Animación |
|---|---|
| **Transición entre pasos (checkout)** | Slide horizontal, 300ms ease-out. |
| **Agregar al carrito** | Botón spinner + toast success. Badge del mini-cart: escala 1→1.3→1 (200ms). |
| **Eliminar item (carrito)** | Fade-out + slide right, 200ms. |
| **Drawer (filtros, menú mobile)** | Slide-in desde la izquierda, 300ms. Overlay fade-in, 200ms. |
| **Modal** | Fade-in + scale 0.95→1, 200ms. |
| **Accordion** | Height expand/colapse, 200ms ease-out. |
| **Toast** | Slide-in desde la derecha, 300ms. Auto-dismiss después de 5s. |
| **Skeleton** | Pulse animation (opacity 1→0.5→1), 1.5s infinite. |
| **Hover (desktop)** | Transiciones de color/opacidad: 150ms. Sombras: 200ms. |
| **Respetar `prefers-reduced-motion`** | Deshabilitar todas las animaciones no esenciales. |

---

> **Confianza global de este documento:** ALTA.
>
> **Hechos (del auditor/arquitecto):** 54 componentes React definidos, 72 endpoints REST, layouts y routing del frontend, flujos de negocio actuales.
>
> **Diseño UX (decisiones propias):** Layouts mobile-first, jerarquía visual por pantalla, comportamientos responsive, estados visuales (loading, empty, error, success), micro-interacciones y animaciones.
>
> **Próximo paso:** `01-ux-design-system.md` — Decisiones de sistema de diseño: tipografía, espaciado, colores, sombras, iconografía y patrones.
