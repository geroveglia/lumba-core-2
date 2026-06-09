# 01 — UX Flows (Diseño de Flujos de Usuario para MVP)

> **Proyecto:** Lumba Ecommerce (Brownfield — migración PHP vanilla + Bootstrap 5 → NestJS API + React + Tailwind CSS)
> **Fecha:** 2026-06-08
> **Rol:** UX Designer
> **Modelo:** deepseek-v4-pro
> **Nivel de confianza global:** ALTA (basado en 8 outputs previos: System Auditor, Product Owner, Security Agent, Backend Architect, Data Architect, Frontend Architect)
> **Fuentes:** `01-flujos-negocio.md`, `01-functional-spec.md`, `01-feature-prioritization.md`, `01-gaps-and-improvements.md`, `01-frontend-architecture.md`, `01-frontend-component-tree.md`, `01-backend-api-spec.md`

---

## Índice

1. [Flujo 1: Descubrimiento y Compra](#flujo-1-descubrimiento-y-compra)
2. [Flujo 2: Registro y Login](#flujo-2-registro-y-login)
3. [Flujo 3: Recuperación de Contraseña](#flujo-3-recuperación-de-contraseña)
4. [Flujo 4: Compra como Invitado](#flujo-4-compra-como-invitado)
5. [Flujo 5: Gestión de Cuenta](#flujo-5-gestión-de-cuenta)
6. [Flujo 6: Panel Admin (Flujos Principales)](#flujo-6-panel-admin-flujos-principales)
7. [Flujo 7: Mobile Checkout (Variante Responsive Crítica)](#flujo-7-mobile-checkout-variante-responsive-crítica)

---

## Leyenda

| Símbolo | Significado |
|---|---|
| 🟢 **Hecho** | Basado en outputs del System Auditor o Product Owner |
| 🔵 **Diseño UX** | Decisión de diseño UX tomada para el nuevo sistema |
| 📐 **Recomendación** | Recomendación para el UI Designer / equipo de desarrollo |

---

## Flujo 1: Descubrimiento y Compra

> **Flujo core del ecommerce.** Home → Catálogo (filtros, búsqueda) → Detalle producto → Agregar carrito → Checkout 4 pasos → Pago → Confirmación.

### 1.0 Objetivo del Usuario

El cliente quiere encontrar productos de su interés, evaluarlos, y completar una compra de forma rápida, segura y sin fricciones.

### 1.1 Punto de Entrada

| Punto de entrada | Contexto |
|---|---|
| **Home (`/`)** | Visitante nuevo o recurrente. Ver novedades, destacados, categorías. |
| **URL directa de producto** | Link compartido, email marketing, redes sociales, Google. |
| **Categoría (`/categoria/{slug}`)** | Navegación desde menú principal. |
| **Búsqueda** | Intención específica de producto. |
| **Marca (`/marca/{slug}`)** | Cliente fiel a una marca. |
| **Tag (`/tag/{slug}`)** | Promociones, colecciones, "Ofertas", "Nuevo". |

---

### 1.2 Paso 0: Home

**Objetivo del paso:** Dar bienvenida, inspirar descubrimiento, guiar al catálogo.

| Aspecto | Detalle |
|---|---|
| **Página o ruta** | `/` (ISR 300s) |
| **Endpoint REST** | `GET /api/content/slider`, `GET /api/content/banners`, `GET /api/content/home-layout`, `GET /api/products?destacados=1` |
| **Componentes React** | `MainLayout` > `Header` (logo, nav, `SearchBar`, mini-cart), `Slider` (swiper), `ProductCard` × N en carousel, `BannerGrid`, `Footer` |
| **Estado loading** | Skeleton de slider (rectángulo grande `h-64`), 4 skeletons `ProductCard` en el carousel de destacados. Animación de pulso. |
| **Estado empty** | Si no hay slider configurado: no mostrar sección. Si no hay destacados: mostrar sección "Próximamente" con categorías como fallback. |
| **Estado error** | Si falla `GET /api/content`: mostrar home con datos cacheados (ISR ya tiene versión anterior). Si falla todo: mensaje "Estamos actualizando la tienda, volvé en minutos" + mostrar categorías como navegación de emergencia. |
| **Decisiones del usuario** | ¿Exploro categorías? ¿Uso la búsqueda? ¿Veo un producto que me interesa? ¿Hago scroll a destacados? |
| **Transiciones** | Click en slider → link del slide. Click en categoría → `/categoria/{slug}`. Click en producto → `/productos/{slug}`. Click en búsqueda → abre o redirige a PLP con query `?q=`. |

📐 **Recomendación:** El home debe ser un "hub de navegación", no un muro de productos. Slider con 3-5 slides máximo. Categorías destacadas en grid 2×2 (mobile) o 4×1 (desktop) con íconos/fotos. Productos destacados en scroll horizontal (mobile) o carousel (desktop). Banners promocionales entre secciones.

---

### 1.3 Paso 1: Catálogo / PLP (Product List Page)

**Objetivo del paso:** El usuario encuentra productos mediante filtros, búsqueda y ordenamiento. Explora opciones y encuentra candidatos para ver en detalle.

| Aspecto | Detalle |
|---|---|
| **Página o ruta** | `/productos`, `/categoria/{slug}`, `/marca/{slug}`, `/tag/{slug}` |
| **Render** | Hybrid (Server Shell + Client Islands) |
| **Endpoint REST** | `GET /api/products?{filtros}`, `GET /api/categories` |
| **Componentes React** | `MainLayout` > `Breadcrumb`, `FilterPanel` (Drawer en mobile), `SearchBar`, `SortSelect`, `ActiveFilters` (chips), `ProductGrid` > `ProductCard` × N, `Pagination` |
| **Estado loading inicial** | 12 skeletons `ProductCard` (rect imagen + 3 líneas texto). La estructura de página (breadcrumb, filter panel) se renderiza inmediatamente (Server Shell). |
| **Estado fetching (filtros aplicados)** | Overlay semi-transparente sobre la grilla existente con `Spinner` centrado. Los productos anteriores permanecen visibles pero atenuados (`opacity-60`). |
| **Estado empty** | Ilustración de caja vacía + texto "No encontramos productos" + sugerencias: "Probá con otros filtros", "Limpiar filtros" (botón). Si es búsqueda con 0 resultados: "No hay resultados para '[query]'. Probá con menos palabras o revisá la ortografía." |
| **Estado error** | Icono de alerta + "Error al cargar productos" + botón "Reintentar". No perder los filtros aplicados (URL preserva los query params). |
| **Decisiones del usuario** | ¿Qué categoría veo? ¿Filtro por precio/talle/color? ¿Ordeno por precio o novedades? ¿Hago clic en un producto? ¿Sigo scrolleando (paginación/carga infinita)? ¿Uso la búsqueda? |
| **Transiciones** | Click en producto → `/productos/{slug}`. Cambio de filtro → URL update + fetch. Click en paginación → scroll to top + fetch. |

🔵 **Diseño UX — Filtros:**
- **Mobile:** `FilterPanel` se abre como `Drawer` desde la izquierda, cubriendo 85% de la pantalla. Header con "Filtrar" + botón "Limpiar". Footer sticky con "Aplicar filtros" + conteo de resultados.
- **Desktop:** Sidebar fijo a la izquierda, siempre visible. Categorías como accordion (expandible). Precio como slider de rango con inputs para min/max manual. Propiedades como chips (pills). Cada filtro aplicado se muestra como `Chip` removible en `ActiveFilters`.
- **Comportamiento:** Cada cambio de filtro actualiza la URL (`useSearchParams`) y dispara un fetch a la API. Debounce de 300ms en el slider de precio.
- **A11y:** Cada filtro es un grupo nombrado con `aria-label`. El slider de precio tiene inputs numéricos asociados. El conteo de resultados se anuncia con `aria-live="polite"`.

🔵 **Diseño UX — Búsqueda:**
- `SearchBar` en el header con ícono de lupa. Al hacer focus, se expande (mobile: full-width bajo el header). Debounce de 300ms antes de buscar.
- Sugerencias predictivas si el backend lo soporta (Fase 2). En MVP: búsqueda por submit o debounce.
- Si la búsqueda devuelve 0 resultados: mostrar mensaje + sugerencias de categorías populares.

🔵 **Diseño UX — Grilla de productos:**
- **Mobile:** 2 columnas. `ProductCard` compacto (foto + nombre 2 líneas + precio + badge descuento).
- **Tablet:** 3 columnas.
- **Desktop:** 3-4 columnas.
- Cada `ProductCard`: foto cuadrada, marca (opcional), nombre (2 líneas con `line-clamp-2`), `PriceDisplay` (precio actual + original tachado si hay descuento + badge "% OFF"), corazón de favoritos (desktop: hover, mobile: siempre visible), botón "Agregar" (desktop: aparece en hover, mobile: siempre visible).
- **Badges:** "X% OFF" (rojo), "Sin stock" (gris con opacidad), "Poco stock" (ámbar).

---

### 1.4 Paso 2: Detalle de Producto / PDP (Product Detail Page)

**Objetivo del paso:** El usuario evalúa el producto a fondo: ve fotos, selecciona variante (talle, color), verifica stock, ve precio con IVA y descuentos, y decide agregar al carrito.

| Aspecto | Detalle |
|---|---|
| **Página o ruta** | `/productos/{slug}` |
| **Render** | ISR 60s (Server Component) + Client Islands |
| **Endpoint REST** | `GET /api/products/:url`, `GET /api/products/:url/related` |
| **Componentes React** | `MainLayout` > `Breadcrumb`, `ProductSchemaOrg`, `ImageGallery`, `VariantSelector`, `StockIndicator`, `PriceDisplay`, `QuantitySelector`, `Button` (CTA Agregar), `Accordion` (descripción, envíos), `ProductCarousel` (relacionados) |
| **Estado loading** | Skeleton específico: rectángulo grande (`aspect-square`) para galería + 4 líneas texto para nombre/precio + 3 filas de chips para variantes + botón rectangular. |
| **Estado 404** | Producto no encontrado. Mensaje "Producto no disponible" + posiblemente "Este producto ya no está a la venta o la URL es incorrecta." + link a catálogo. |
| **Estado sin stock** | `StockIndicator` muestra "Sin stock" en rojo. Variantes sin stock aparecen disabled (opacidad 30% + tachado). Botón CTA dice "Sin stock" y está disabled. Mostrar "Dejanos tu email y te avisamos cuando vuelva" (Fase 2 — MVP: solo mostrar mensaje). |
| **Estado agregando** | Botón CTA muestra `Spinner` + texto "Agregando...". El botón se deshabilita para prevenir doble click. Al completar: toast success "Agregado al carrito" + el mini-cart en header se actualiza con animación (badge de conteo). |
| **Estado error al agregar** | Si la API rechaza (stock agotado en el ínterin, precio cambiado): toast error con mensaje específico. El producto se mantiene en la página. |
| **Decisiones del usuario** | ¿Veo todas las fotos? ¿Qué talle/color elijo? ¿Hay stock? ¿Me convence el precio? ¿Cuántas unidades compro? ¿Agrego al carrito? ¿Voy a productos relacionados? |
| **Transiciones** | Agregar al carrito exitoso → toast + badge mini-cart se actualiza + usuario sigue en PDP. Click en relacionados → `/productos/{slug}` del relacionado. Click en breadcrumb → categoría padre. |

🔵 **Diseño UX — Galería de imágenes:**
- **Mobile:** Swiper horizontal con dots. Swipe para navegar. Pinch-to-zoom en la imagen activa. Contador "2/5" abajo a la derecha.
- **Desktop:** Grid de thumbnails a la izquierda (vertical, scrollable) + imagen principal grande a la derecha. Click en thumbnail cambia la imagen principal con fade. Hover en imagen principal: lupa/zoom (librería `medium-zoom` o similar). Si hay solo 1 foto, se muestra centrada sin thumbnails.

🔵 **Diseño UX — Selector de variantes:**
- **Colores:** Swatches circulares de 40×40px con borde. El seleccionado tiene borde primary + ring. Tooltip con nombre del color al hover/focus. Colores no disponibles: opacidad 30% + línea diagonal (o X).
- **Talles / otras propiedades:** Chips rectangulares con el valor (ej: "XL", "42"). El seleccionado: fondo primary, texto blanco. No disponible: gris claro, texto tachado, cursor not-allowed.
- **Comportamiento inteligente:** Al seleccionar una propiedad (ej: Color "Rojo"), los valores de otras propiedades que no existen en combinación con "Rojo" se deshabilitan automáticamente. Esto previene seleccionar combinaciones imposibles.
- **Stock por variante:** `StockIndicator` se actualiza al seleccionar variante. Muestra: "Stock disponible" (verde), "Pocas unidades: X" (ámbar), "Sin stock" (rojo).
- **Precio por variante:** El precio se actualiza dinámicamente al cambiar de variante (si diferentes variantes tienen diferentes precios según lista).

🔵 **Diseño UX — CTA de compra:**
- Cantidad: `QuantitySelector` con botones − y + a los lados, valor numérico en el centro. Mínimo 1, máximo 99 (o stock disponible si es menor). En mobile, botones de 48×48px (touch target).
- Botón CTA: "Agregar al carrito" (primary, full-width en mobile, ancho natural en desktop). Si hay descuento, mostrar precio final grande y precio original tachado al lado.
- **Compra mínima:** Si el total del carrito + este producto no alcanza la compra mínima del cliente, NO se bloquea el botón de agregar (la validación se hace en el carrito, no en el PDP).

---

### 1.5 Paso 3: Carrito

**Objetivo del paso:** El usuario revisa los productos seleccionados, ajusta cantidades, aplica cupón de descuento, ve el resumen con totales y descuentos, y decide iniciar el checkout.

| Aspecto | Detalle |
|---|---|
| **Página o ruta** | `/carrito` |
| **Render** | Client Component |
| **Endpoint REST** | `GET /api/cart`, `PATCH /api/cart/items/:pid/:vid`, `DELETE /api/cart/items/:pid/:vid`, `POST /api/cart/coupon`, `DELETE /api/cart/coupon` |
| **Componentes React** | `MainLayout` > `CartItem` × N, `CouponInput`, `CartSummary`, `Alert` (compra mínima), `Button` (Iniciar compra) |
| **Estado loading** | Skeleton de 3 `CartItem` (rect imagen + texto) + skeleton `CartSummary`. |
| **Estado vacío** | Ilustración de carrito vacío + "Tu carrito está vacío" + "¿No sabés qué comprar? ¡Mirá nuestros destacados!" + botón "Ver productos". |
| **Estado updating (cantidad)** | `QuantitySelector` en el item específico muestra `Spinner`. Los demás items siguen interactivos. |
| **Estado removing** | El `CartItem` hace fade-out (200ms) con opacidad bajando. El `CartSummary` se recalcula con animación de números. |
| **Estado error stock** | Si al actualizar cantidad el backend rechaza (sin stock): toast error + la cantidad vuelve al valor anterior. El item muestra badge rojo "Sin stock suficiente". |
| **Estado error precio** | Si el precio cambió (anti-tampering): se actualiza silenciosamente al precio correcto. No mostrar error (el backend ya corrigió). |
| **Estado cupón aplicado** | El `CouponInput` muestra el código aplicado como chip verde removible. `CartSummary` muestra la línea "Cupón XXXX: −$XXXX". |
| **Estado cupón inválido** | Toast error "El cupón no es válido o ya expiró". El input se limpia pero mantiene el foco. |
| **Estado compra mínima no alcanzada** | `Alert` warning amarillo debajo del `CartSummary`: "El monto mínimo de compra es $XX.XXX. Te faltan $X.XXX para completar tu pedido." Botón "Iniciar compra" disabled. |
| **Decisiones del usuario** | ¿Ajusto cantidades? ¿Elimino algún producto? ¿Aplico un cupón? ¿El total me cierra? ¿Inicio el checkout? ¿Sigo comprando? |
| **Transiciones** | Click "Iniciar compra" → `/checkout`. Click en producto → `/productos/{slug}`. Click "Seguir comprando" → volver a la página anterior o catálogo. |

🔵 **Diseño UX — Cupón:**
- Input con placeholder "¿Tenés un cupón?" + botón "Aplicar" al lado. Validación al blur o al hacer click en Aplicar. Feedback inmediato: éxito (chip verde), error (mensaje inline rojo debajo del input).
- Loading en el botón mientras valida.
- El cupón aplicado se muestra como chip con el código + botón X para remover.

---

### 1.6 Paso 4: Checkout (4 Pasos → Single Page)

**Objetivo del paso:** El usuario completa sus datos, elige envío y pago, confirma la compra y es redirigido a pagar. Completar en el menor tiempo posible, con la menor fricción.

| Aspecto | Detalle |
|---|---|
| **Página o ruta** | `/checkout` |
| **Render** | Client Component |
| **Endpoint REST** | `GET /api/checkout`, `POST /api/checkout/step/1`, `POST /api/checkout/step/2`, `POST /api/checkout/step/3`, `POST /api/checkout/confirm`, `GET /api/geo/*`, `GET /api/shipping/options` |
| **Componentes React** | `CheckoutLayout` > `StepIndicator`, `CheckoutStep1` / `CheckoutStep2` / `CheckoutStep3` / `CheckoutStep4`, `CartSummary` (sidebar sticky) |
| **Layout** | Grid 2 columnas (desktop): izquierda = formulario del paso actual, derecha = `CartSummary` sticky. Mobile: `CartSummary` colapsable en top, formulario debajo. |

#### 1.6.1 Checkout Paso 1 — Datos Personales

| Aspecto | Detalle |
|---|---|
| **Componentes** | `CheckoutStep1` > `Select` (tipo de cliente), `Input` × N (campos dinámicos), `Checkbox` (marketing), `Button` (Continuar) |
| **Endpoint** | `POST /api/checkout/step/1` |
| **Campos dinámicos** | Si `tipoClienteId === 1` (persona): nombre, apellido, DNI. Si `tipoClienteId === 2` (empresa): razón social, CUIT, nombre fantasía. Campos comunes: email, área, teléfono. |
| **Validación** | Zod schema en frontend con `mode: 'onChange'`. Errores inline debajo de cada campo. Validaciones: email formato, DNI 7-8 dígitos, CUIT formato XX-XXXXXXXX-X, teléfono 6-10 dígitos. |
| **Estado loading** | `Button` muestra `Spinner` + "Guardando...". |
| **Estado error** | Errores de validación inline. Error de API: toast con mensaje específico. |
| **Autocompletado** | Si el cliente está logueado: pre-llenar nombre, apellido, email, teléfono desde el perfil. |
| **Compra mínima** | Si no se alcanza: `Alert` warning en el paso 1. No se puede avanzar. |
| **Transición** | Submit exitoso → avanzar a paso 2 (animación slide). |

#### 1.6.2 Checkout Paso 2 — Forma de Entrega

| Aspecto | Detalle |
|---|---|
| **Componentes** | `CheckoutStep2` > `RadioGroup` (tipo de entrega), `AddressCard` × N (direcciones guardadas), `AddressForm` (nueva dirección), `Select` (sucursal / envío propio / punto Zipnova), `Checkbox` (misma dirección facturación) |
| **Endpoint** | `POST /api/checkout/step/2`, `GET /api/geo/provincias`, `GET /api/geo/localidades?provinciaId=`, `GET /api/geo/cp?codigo=` |
| **Opciones de entrega** | `RadioGroup` visual con 3 opciones: ① Retiro por sucursal (ícono tienda), ② Envío a domicilio (ícono camión), ③ Punto Zipnova (ícono mapa). Cada opción muestra su costo ("GRATIS" en verde o "$XXX" en gris). |
| **Direcciones guardadas** | Si está logueado y tiene direcciones: `AddressCard` seleccionables con radio visual. La predeterminada viene pre-seleccionada. Botón "+ Nueva dirección" que despliega el `AddressForm` inline. |
| **Formulario de dirección** | `AddressForm` con: CP (autocompleta provincia + localidad vía `GET /api/geo/cp?codigo=`), Provincia (select), Localidad (select, depende de provincia), Calle, Número, Depto/Piso (opcional), Etiqueta (Casa/Trabajo, opcional), Checkbox "Guardar como predeterminada". |
| **Misma dirección para facturación** | Checkbox "Usar estos datos para la factura". Si se destilda: aparecen campos de dirección de facturación separados (mismos campos). |
| **Validación** | CP cubierto por las zonas de envío configuradas. Si no hay cobertura: mensaje "No realizamos envíos a tu zona. Probá con retiro en sucursal." |
| **Costo de envío** | Se calcula en tiempo real al seleccionar provincia/localidad + método de envío. Se refleja en el `CartSummary` del sidebar. |
| **Transición** | Submit exitoso → avanzar a paso 3. |

#### 1.6.3 Checkout Paso 3 — Medio de Pago

| Aspecto | Detalle |
|---|---|
| **Componentes** | `CheckoutStep3` > `PaymentMethodSelector` (`RadioGroup` visual), `Alert` (info cuotas / datos bancarios), `Button` (Continuar) |
| **Endpoint** | `POST /api/checkout/step/3` |
| **Opciones** | Según perfil del cliente. Cada opción como card seleccionable con ícono grande + nombre + descripción. ① MercadoPago: "Tarjetas de crédito/débito, dinero en cuenta. Hasta 12 cuotas." ② Transferencia bancaria: "Transferí y subí el comprobante." ③ Efectivo: "Pagá cuando retirás." |
| **MercadoPago** | Mostrar cuotas disponibles (ej: "3 cuotas sin interés de $X.XXX"). |
| **Transferencia** | Al seleccionar, mostrar `Alert` info con datos bancarios (CBU, alias, titular — del admin). |
| **Transición** | Submit exitoso → avanzar a paso 4 (Confirmación). |

#### 1.6.4 Checkout Paso 4 — Confirmación y Pago

| Aspecto | Detalle |
|---|---|
| **Componentes** | `CheckoutStep4` > resumen completo de datos (dirección, envío, pago), `CartSummary` (readOnly con todo), `Button` (Confirmar compra), `Button` ghost (Editar paso N) |
| **Endpoint** | `POST /api/checkout/confirm` |
| **Resumen** | Secciones colapsables/expandibles mostrando: Datos personales, Dirección de envío, Dirección de facturación (si es diferente), Forma de envío, Medio de pago. Cada sección tiene botón "Editar" que vuelve a ese paso. |
| **Estado confirmando** | Botón muestra `Spinner` + "Procesando...". Overlay semi-transparente sobre todo el formulario para prevenir doble confirmación. |
| **Estado error** | Si falla la confirmación (stock, precio, etc.): toast error con mensaje específico. NO se pierden los datos ingresados. |
| **POST-confirmación** | Según medio de pago: |
| | **MercadoPago:** Redirección a URL de checkout MP (`window.location.href = data.pago.urlPago`). Mostrar brevemente "Redirigiendo a MercadoPago..." |
| | **Transferencia:** Página de éxito con datos bancarios + botón/link "Subir comprobante" → `/comprobantes/{hash}`. |
| | **Efectivo:** Página de éxito con número de pedido + instrucciones. |

---

### 1.7 Punto de Salida Exitoso

| Medio de pago | Página de salida | Comportamiento |
|---|---|---|
| **MercadoPago** | Redirigido a MP → vuelve a `/checkout/resultado?status=...` | Éxito: "¡Gracias por tu compra!" + resumen + link a cuenta. Pendiente: "Estamos esperando la confirmación de tu pago" + polling. Error: "El pago no se pudo completar" + reintentar. |
| **Transferencia** | `/checkout/exito/{hash}` | "¡Pedido registrado!" + datos bancarios + botón "Subir comprobante". |
| **Efectivo** | `/checkout/exito/{hash}` | "¡Pedido confirmado!" + número de pedido + instrucciones de retiro. |

🔵 **Diseño UX — Página de éxito post-compra:**
- Header: ícono de check verde grande + "¡Gracias, [nombre]!"
- Cuerpo: número de pedido (`#{hash}`), resumen de items comprados, total pagado, método de pago, método de envío.
- Acciones: "Ver mi pedido" → `/cuenta/pedidos/{hash}`, "Seguir comprando" → `/`.
- Emails: "Te enviamos un email a [email] con los detalles de tu compra."

---

### 1.8 Métricas de Éxito del Flujo

| Métrica | Cómo se mide | Objetivo |
|---|---|---|
| **Tasa de conversión** | Pedidos completados / Visitas únicas | > 3% (ecommerce argentino saludable) |
| **Tasa de abandono de carrito** | Carritos creados / Pedidos completados | < 70% |
| **Tasa de abandono por paso del checkout** | Usuarios que inician paso X / llegan a paso X+1 | Identificar pasos con mayor fricción |
| **Tasa de clic en PDP desde PLP** | Clics en producto / Vistas de PLP | > 15% |
| **Tasa de agregado al carrito desde PDP** | Clics en "Agregar" / Vistas de PDP | > 20% |
| **Tiempo hasta completar checkout** | Timestamp inicio - timestamp confirmación | < 3 minutos |
| **Tasa de error en checkout** | Checkouts con error / Total checkouts iniciados | < 5% |
| **Tasa de pago exitoso (MP)** | Pagos aprobados / Redirecciones a MP | > 85% |

---

## Flujo 2: Registro y Login

> Visitante → Registro → Activación email → Login → Perfil.

### 2.0 Objetivo del Usuario

Crear una cuenta para tener historial de pedidos, direcciones guardadas, favoritos, y comprar más rápido en el futuro.

### 2.1 Punto de Entrada

| Punto de entrada | Contexto |
|---|---|
| **Header** | Link "Ingresar" / "Crear cuenta" en el header. |
| **Checkout como invitado** | "¿Ya tenés cuenta? Iniciá sesión" en el paso 1. |
| **Post-compra** | "Creá tu cuenta para seguir tu pedido" después de comprar como invitado. |
| **Favoritos** | "Creá una cuenta para guardar favoritos." |

---

### 2.2 Paso 1: Registro

| Aspecto | Detalle |
|---|---|
| **Página o ruta** | `/registro` |
| **Layout** | `AuthLayout` (split: izquierda logo/ilustración, derecha formulario. Mobile: solo formulario centrado) |
| **Endpoint REST** | `POST /api/auth/register` |
| **Componentes React** | `Input` (nombre, apellido, email, contraseña, repetir contraseña), `Checkbox` (términos), `Button` (Crear cuenta), `Alert` (info/error) |
| **Validación frontend** | Zod: nombre ≥ 2 chars, email formato, contraseña ≥ 8 chars con al menos 1 mayúscula + 1 número, coincidencia de contraseñas. `mode: 'onChange'` con debounce en email (verificar disponibilidad via API). |
| **Estado loading** | Botón muestra `Spinner` + "Creando cuenta...". |
| **Estado error (email duplicado)** | Error inline en campo email: "Este email ya está registrado. ¿Querés iniciar sesión?" + link a `/login`. |
| **Estado error (rate limit)** | Toast error: "Demasiados intentos. Esperá X minutos y volvé a intentar." |
| **Estado error (servidor)** | Toast error genérico. El formulario mantiene los datos ingresados. |
| **Estado éxito** | `Alert` success: "¡Cuenta creada! Te enviamos un email a [email] para activar tu cuenta." |
| **Seguridad** | Rate limiting por IP + email (`@nestjs/throttler`). reCAPTCHA v3 invisible. |

🔵 **Diseño UX — Formulario de registro:**
- 5 campos máximo (nombre, apellido, email, contraseña, repetir contraseña).
- Indicador de fortaleza de contraseña en tiempo real (barra de color: rojo → amarillo → verde a medida que se cumplen criterios).
- Mostrar/ocultar contraseña con botón de ojo en ambos campos de contraseña.
- Checkbox "Acepto los términos y condiciones" con link a `/secciones/terminos`.
- Link "¿Ya tenés cuenta? Iniciá sesión" debajo del botón.

---

### 2.3 Paso 2: Activación de Email

| Aspecto | Detalle |
|---|---|
| **Página o ruta** | Link en email → `/activar-cuenta/{hash}` |
| **Endpoint REST** | `POST /api/auth/activate/:hash` |
| **Estado éxito** | Página de bienvenida: "¡Cuenta activada! Ya podés iniciar sesión." + botón "Iniciar sesión". Login automático (redirigir a `/cuenta/perfil`). |
| **Estado error (hash inválido/expirado)** | "El link de activación no es válido o ya expiró. Solicitá uno nuevo." + botón "Reenviar email de activación". |

---

### 2.4 Paso 3: Login

| Aspecto | Detalle |
|---|---|
| **Página o ruta** | `/login` |
| **Layout** | `AuthLayout` |
| **Endpoint REST** | `POST /api/auth/login` |
| **Componentes React** | `Input` (email, contraseña), `Checkbox` ("Recordarme"), `Button` (Iniciar sesión), `Button` link ("Olvidé mi contraseña") |
| **Validación** | Zod: email formato, contraseña no vacía. |
| **Estado loading** | Botón `Spinner` + "Ingresando...". |
| **Estado error (credenciales inválidas)** | `Alert` error genérico "Email o contraseña incorrectos." (no revelar si el email existe). |
| **Estado error (cuenta no activada)** | "Tu cuenta no está activada. Revisá tu email o solicitá un nuevo link de activación." + botón "Reenviar". |
| **Estado error (bloqueo temporal)** | "Demasiados intentos fallidos. Tu cuenta está bloqueada por 15 minutos." |
| **Estado error (rate limit)** | Toast: "Demasiados intentos. Esperá y volvé a intentar." |
| **Estado éxito** | Login exitoso: redirigir a `/` o a la página de donde venía (redirect guardado en query param `?redirect=`). Guardar JWT en memoria + refresh token en cookie HTTP-only. Cargar carrito de DB si existe. |
| **Recordarme** | Si está tildado: refresh token con expiración larga (30 días). Si no: sesión de navegador (expira al cerrar). |

🔵 **Diseño UX — Login:**
- Formulario simple: email, contraseña, "Recordarme", "Iniciar sesión".
- Links: "Olvidé mi contraseña" y "Crear cuenta".
- Si viene del checkout con `?redirect=/checkout`, después del login volver al paso del checkout donde estaba.
- **Mobile:** Formulario ocupa todo el ancho, sin el panel ilustrativo de la izquierda.

### 2.5 Paso 4: Perfil (post-login)

El usuario logueado accede a `/cuenta/perfil`. Ver [Flujo 5: Gestión de Cuenta](#flujo-5-gestión-de-cuenta).

### 2.6 Métricas de Éxito del Flujo

| Métrica | Cómo se mide | Objetivo |
|---|---|---|
| **Tasa de registro completado** | Registros completados / Registros iniciados | > 80% |
| **Tasa de activación** | Cuentas activadas / Registros completados | > 90% |
| **Tasa de login exitoso** | Logins exitosos / Intentos de login | > 95% |
| **Tiempo de registro** | Timestamp inicio - timestamp submit exitoso | < 60 segundos |
| **Tasa de rebote en registro** | Usuarios que abandonan el form / Usuarios que lo abren | < 30% |

---

## Flujo 3: Recuperación de Contraseña

> Login → "Olvidé mi contraseña" → Email con link → Nueva contraseña → Login.

### 3.0 Objetivo del Usuario

Recuperar el acceso a su cuenta porque olvidó la contraseña.

### 3.1 Punto de Entrada

| Punto de entrada | Contexto |
|---|---|
| **Login** | Link "Olvidé mi contraseña" debajo del formulario de login. |

### 3.2 Paso 1: Solicitar Recuperación

| Aspecto | Detalle |
|---|---|
| **Página o ruta** | `/recuperar` |
| **Layout** | `AuthLayout` |
| **Endpoint REST** | `POST /api/auth/recover` |
| **Componentes React** | `Input` (email), `Button` (Enviar instrucciones) |
| **Estado loading** | Botón `Spinner` + "Enviando...". |
| **Estado error** | Error inline: "No encontramos una cuenta con ese email." |
| **Estado éxito** | `Alert` success: "Si el email está registrado, recibirás instrucciones para recuperar tu contraseña." (Mensaje genérico por seguridad — no revelar si el email existe realmente). Link "Volver al login". |
| **Seguridad** | Rate limiting estricto: 3 intentos por email por hora. Token de recuperación con expiración de 1 hora. |

🔵 **Diseño UX:**
- Pantalla minimalista: logo + título "Recuperar contraseña" + descripción "Ingresá tu email y te enviaremos instrucciones" + input email + botón.
- Link "Volver al login" debajo.
- Después del submit exitoso, mostrar confirmación y redirigir automáticamente al login después de 5 segundos (o el usuario hace clic en "Volver").

### 3.3 Paso 2: Email de Recuperación

📐 **Recomendación — Contenido del email:**
- Asunto: "Recuperá tu contraseña — [Nombre Tienda]"
- Cuerpo: "Hola [nombre], recibimos una solicitud para restablecer tu contraseña. Hacé clic en el siguiente botón para crear una nueva contraseña. Este link expira en 1 hora."
- Botón: "Restablecer contraseña" → `/recuperar/{token}`
- Abajo: "Si no solicitaste esto, ignorá este email."

### 3.4 Paso 3: Nueva Contraseña

| Aspecto | Detalle |
|---|---|
| **Página o ruta** | `/recuperar/{token}` |
| **Layout** | `AuthLayout` |
| **Endpoint REST** | `POST /api/auth/recover/:token` |
| **Componentes React** | `Input` (nueva contraseña, repetir nueva contraseña), `Button` (Restablecer) |
| **Validación** | Zod: contraseña ≥ 8 chars, mayúscula + número, coincidencia. Indicador de fortaleza. |
| **Estado error (token inválido/expirado)** | "Este link ya no es válido. Solicitá uno nuevo." + botón "Volver a solicitar". |
| **Estado éxito** | "¡Contraseña actualizada! Ya podés iniciar sesión." + botón "Iniciar sesión" que redirige a `/login`. |

### 3.5 Métricas de Éxito del Flujo

| Métrica | Cómo se mide | Objetivo |
|---|---|---|
| **Tasa de recuperación completada** | Contraseñas restablecidas / Solicitudes de recuperación | > 70% |
| **Tasa de clic en email de recuperación** | Clics en el link / Emails enviados | > 50% |
| **Tiempo medio de recuperación** | Timestamp solicitud - timestamp nueva contraseña | < 5 minutos |

---

## Flujo 4: Compra como Invitado

> Catálogo → Detalle → Carrito → Checkout con registro automático.

### 4.0 Objetivo del Usuario

Completar una compra sin tener que crear una cuenta manualmente. Mínima fricción posible.

### 4.1 Punto de Entrada

| Punto de entrada | Contexto |
|---|---|
| **Cualquier página de la tienda** | Usuario no logueado navega y agrega al carrito. |
| **Checkout** | El checkout NO fuerza login. El paso 1 es "Datos personales" tanto para logueados como invitados. |

### 4.2 Diferencias con el Flujo de Compra Logueado

| Aspecto | Invitado | Logueado |
|---|---|---|
| **Paso 1: Datos** | Campos completos. Email es obligatorio y será su identificador. | Datos pre-llenados del perfil. |
| **Paso 2: Envío** | Sin direcciones guardadas. Debe ingresar dirección nueva. | Puede seleccionar direcciones guardadas. |
| **Paso 4: Confirmación** | El sistema **crea automáticamente** una cuenta al confirmar la compra. | La cuenta ya existe. |

### 4.3 Registro Automático (Paso 4)

🟢 **Hecho (basado en sistema actual):** El sistema actual ya implementa registro automático. Al confirmar la compra de un email no registrado, crea cliente con contraseña random y envía email de bienvenida.

🔵 **Diseño UX — Mejora para el nuevo sistema:**

1. Al confirmar la compra con email no registrado: backend crea cliente con `activo=1` (ya no requiere activación por email, la compra valida el email).
2. Backend genera un **magic link** (token único de un solo uso).
3. **Email post-compra:** "¡Gracias por tu compra, [nombre]! Creamos una cuenta para que puedas seguir tu pedido. Hacé clic aquí para acceder a tu cuenta:" → botón "Acceder a mi cuenta" (magic link).
4. El magic link redirige a `/cuenta/pedidos/{hash}` con sesión iniciada automáticamente.
5. En su primer acceso, el cliente puede (opcionalmente) setear una contraseña desde `/cuenta/perfil`.

📐 **Recomendación:** El magic link es superior al email con contraseña random (sistema actual) porque:
- No requiere que el cliente copie/pegue una contraseña.
- Es más seguro (un solo uso, expira).
- La experiencia es más fluida (un clic = dentro de su cuenta).
- El cliente puede setear su contraseña cuando quiera, sin presión.

### 4.4 Métricas de Éxito

| Métrica | Cómo se mide | Objetivo |
|---|---|---|
| **Tasa de compras como invitado** | Compras invitado / Total compras | Monitorear, no tiene objetivo fijo |
| **Tasa de conversión invitado vs logueado** | Comparativa de tasas | Invitado debería ser ≥ logueado |
| **Tasa de activación post-compra** | Clientes que acceden vía magic link / Magic links enviados | > 60% |
| **Tasa de seteo de contraseña** | Clientes que setean contraseña / Cuentas creadas automáticamente | > 40% |

---

## Flujo 5: Gestión de Cuenta

> Login → Perfil / Direcciones / Pedidos / Favoritos.

### 5.0 Objetivo del Usuario

Gestionar su información personal, direcciones, revisar el historial y estado de sus pedidos, administrar su lista de favoritos.

### 5.1 Punto de Entrada

| Punto de entrada | Contexto |
|---|---|
| **Header** | Nombre del usuario o ícono de persona → dropdown con "Mi cuenta", "Pedidos", "Cerrar sesión". |
| **Post-login** | Redirigir a la URL de origen o al home. |
| **Email post-compra** | Link al detalle del pedido. |

---

### 5.2 Layout de Cuenta

| Aspecto | Detalle |
|---|---|
| **Layout** | `AccountLayout` |
| **Componentes React** | `Header`, `AccountSidebar` (desktop) / `Tabs` (mobile), `Footer` |
| **Navegación** | **Desktop:** Sidebar izquierda con links: Mi Perfil, Mis Pedidos, Direcciones, Favoritos, Datos de Empresa (si es empresa), Cerrar sesión. Ícono + texto. Item activo resaltado con fondo primary-50. **Mobile:** Tabs horizontales scrollables con íconos (solo 4-5 tabs). O bien menú hamburguesa "Mi Cuenta" que despliega las opciones. |
| **Endpoint REST** | `GET /api/users/me` (carga datos del perfil para el layout) |

---

### 5.3 Sub-flujo: Mi Perfil

| Aspecto | Detalle |
|---|---|
| **Página o ruta** | `/cuenta/perfil` |
| **Endpoint REST** | `GET /api/users/me`, `PATCH /api/users/me` |
| **Componentes React** | `Input` × N (nombre, apellido, email, teléfono, área), `Button` (Guardar cambios), sección "Cambiar contraseña" (contraseña actual, nueva, repetir nueva) |
| **Estado loading** | Skeleton del formulario (4 campos). |
| **Estado guardando** | Botón `Spinner` + "Guardando...". |
| **Estado éxito** | Toast success "Perfil actualizado." |
| **Estado error** | Errores inline por campo. Toast para errores de servidor. |
| **Cambio de contraseña** | Sección separada con 3 campos. Validación de contraseña actual antes de permitir el cambio. Indicador de fortaleza en nueva contraseña. |

---

### 5.4 Sub-flujo: Mis Pedidos

| Aspecto | Detalle |
|---|---|
| **Página o ruta** | `/cuenta/pedidos` |
| **Endpoint REST** | `GET /api/orders` |
| **Componentes React** | `OrderCard` × N (lista), `Pagination`, `Tabs` o `Select` (filtro por estado: Todos, Activos, Entregados) |
| **Estado loading** | 5 skeletons `OrderCard` (rectángulo con badges y texto). |
| **Estado vacío** | Ilustración + "Todavía no hiciste ningún pedido." + botón "Ver productos". |
| **Estado error** | Toast error + botón "Reintentar". |
| **OrderCard** | Muestra: número de pedido (`#{hash}`), fecha, estado (badge de color), cantidad de items, total, badges de estado de pago y envío. Link al detalle. Botón "Repetir compra" (agrega los mismos items al carrito actual). |

---

### 5.5 Sub-flujo: Detalle de Pedido

| Aspecto | Detalle |
|---|---|
| **Página o ruta** | `/cuenta/pedidos/{hash}` |
| **Endpoint REST** | `GET /api/orders/:hash` |
| **Componentes React** | `Breadcrumb`, `OrderTimeline`, `CartItem` × N (read-only), `CartSummary`, `Button` (Repetir compra) |
| **OrderTimeline** | Timeline vertical con eventos: Pedido creado → Pago confirmado → Preparando → Enviado → Entregado. Cada evento con fecha, hora y descripción. Evento actual resaltado con color primary. Eventos completados con check verde. |
| **Items** | Lista de productos comprados (read-only): foto, nombre, SKU, cantidad, precio unitario, subtotal. |
| **Resumen** | `CartSummary` con subtotal, descuentos, envío, total. |
| **Acciones** | "Repetir compra" (agrega al carrito). "Descargar factura" (si está disponible, Fase 2). |

---

### 5.6 Sub-flujo: Direcciones

| Aspecto | Detalle |
|---|---|
| **Página o ruta** | `/cuenta/direcciones` |
| **Endpoint REST** | `GET /api/users/me/addresses`, `POST /api/users/me/addresses`, `PUT /api/users/me/addresses/:id`, `DELETE /api/users/me/addresses/:id` |
| **Componentes React** | `AddressCard` × N, `Button` (+ Nueva dirección) → `Modal` con `AddressForm`, `Button` ghost (Editar, Eliminar) |
| **Estado loading** | 3 skeletons `AddressCard`. |
| **Estado vacío** | "No tenés direcciones guardadas." + botón "Agregar dirección". |
| **Agregar/Editar** | `Modal` con `AddressForm` completo (mismos campos que en checkout). |
| **Eliminar** | `Modal` de confirmación: "¿Estás seguro de eliminar esta dirección?" con botones "Cancelar" / "Eliminar". |
| **Predeterminada** | La dirección predeterminada tiene un badge azul. Al guardar una nueva como predeterminada, la anterior se desmarca automáticamente. |

---

### 5.7 Sub-flujo: Favoritos

| Aspecto | Detalle |
|---|---|
| **Página o ruta** | `/cuenta/favoritos` |
| **Endpoint REST** | `GET /api/users/me/wishlist`, `POST /api/users/me/wishlist/:productId`, `DELETE /api/users/me/wishlist/:productId` |
| **Componentes React** | `ProductGrid` (modo favoritos), `Button` (Agregar al carrito desde favoritos) |
| **Estado loading** | 8 skeletons `ProductCard`. |
| **Estado vacío** | Corazón vacío + "No tenés productos en favoritos" + "Guardá productos que te gusten para encontrarlos fácil." + botón "Ver productos". |
| **Remover** | Corazón en cada `ProductCard` se muestra rojo relleno. Click → remueve de favoritos con toast "Quitado de favoritos". Con opción "Deshacer" en el toast. |

---

### 5.8 Métricas de Éxito

| Métrica | Cómo se mide | Objetivo |
|---|---|---|
| **Uso de favoritos** | Productos en favoritos / Usuarios activos | Creciente |
| **Repetición de compra** | Órdenes "Repetir compra" / Total órdenes | > 5% |
| **Direcciones por usuario** | Direcciones guardadas / Usuarios con cuenta | > 1.5 |
| **Visitas a Mis Pedidos** | Pageviews `/cuenta/pedidos` / Usuarios activos | > 50% mensual |

---

## Flujo 6: Panel Admin (Flujos Principales)

> Login admin → Dashboard → CRUD productos → Gestión pedidos.

### 6.0 Objetivo del Usuario

El administrador gestiona el catálogo de productos, monitorea ventas, procesa pedidos y administra clientes. Eficiencia y claridad son prioritarias.

### 6.1 Punto de Entrada

| Punto de entrada | Contexto |
|---|---|
| **`/admin/login`** | Login exclusivo para administradores. Separado del login de clientes. |
| **`/admin`** | Si ya tiene sesión admin activa, va directo al dashboard. |

---

### 6.2 Login Admin

| Aspecto | Detalle |
|---|---|
| **Página o ruta** | `/admin/login` |
| **Layout** | Minimalista: logo + formulario centrado. Sin header/footer de la tienda. |
| **Endpoint REST** | `POST /api/admin/auth/login` |
| **Componentes React** | `Input` (email, contraseña), `Button` (Ingresar), `Alert` (error) |
| **Seguridad** | bcrypt + rate limiting + bloqueo tras N intentos. |
| **Estado éxito** | Redirigir a `/admin` (dashboard). |

---

### 6.3 Dashboard

| Aspecto | Detalle |
|---|---|
| **Página o ruta** | `/admin` |
| **Layout** | `AdminLayout`: sidebar izquierda (colapsable) + header (usuario, notificaciones) + contenido |
| **Endpoint REST** | `GET /api/admin/dashboard` |
| **Componentes React** | `KpiCard` × 4-6 (ventas del mes, pedidos, ticket promedio, productos activos, clientes nuevos), gráficos `Recharts` (ventas por día/semana, productos más vendidos), `AdminDataTable` (últimos pedidos) |
| **Estado loading** | 6 skeletons `KpiCard` (rectángulos con texto) + skeleton de gráfico (rectángulo grande). |
| **Selector de mes** | `MonthYearPicker` permite cambiar el período de los KPIs. |
| **KPIs** | Cada `KpiCard`: ícono + valor grande + label + comparación con período anterior (▲/▼ % en verde/rojo). |
| **Pedidos recientes** | `AdminDataTable` compacto con últimos 5-10 pedidos: #hash, cliente, fecha, total, estado. Cada fila link al detalle del pedido. |

---

### 6.4 CRUD Productos (Lista)

| Aspecto | Detalle |
|---|---|
| **Página o ruta** | `/admin/productos` |
| **Endpoint REST** | `GET /api/admin/products` (con paginación, sorting, filtros server-side) |
| **Componentes React** | `SearchBar`, `Button` (+ Nuevo producto), `AdminDataTable` (TanStack Table server-side), `Pagination` |
| **AdminDataTable** | Columnas: foto (thumbnail 40px), nombre, SKU, marca, categorías, precio desde, stock, estado (activo/inactivo). Sorting por columnas. Filtros: búsqueda textual, filtro por marca, filtro por categoría, filtro por estado. |
| **Bulk actions** | Checkbox por fila + acciones masivas en toolbar: "Activar seleccionados", "Desactivar seleccionados", "Cambiar categoría", "Eliminar seleccionados". |
| **Estado loading** | Skeleton de tabla (filas con rectángulos). |
| **Estado vacío** | "No hay productos. Creá el primero." + botón "Nuevo producto". |
| **Row actions** | Dropdown por fila: Editar, Duplicar, Activar/Desactivar, Eliminar. |
| **Transiciones** | Click en fila o "Editar" → `/admin/productos/{id}`. Click en "+ Nuevo" → `/admin/productos/nuevo`. |

🔵 **Diseño UX — DataTable del admin:**
- **Server-side todo:** Paginación, sorting y filtrado se envían al backend. TanStack Query maneja el cache.
- **Sticky header:** La fila de encabezado queda fija al hacer scroll.
- **Densidad:** Filas compactas (py-2) para maximizar información visible.
- **Selección:** Click en checkbox selecciona la fila. Shift+click para rango.

---

### 6.5 CRUD Productos (Editar / Crear)

| Aspecto | Detalle |
|---|---|
| **Página o ruta** | `/admin/productos/{id}` o `/admin/productos/nuevo` |
| **Endpoint REST** | `GET /api/admin/products/:id`, `POST /api/admin/products`, `PUT /api/admin/products/:id` |
| **Componentes React** | `Breadcrumb` (Productos > Nombre), `Tabs` (Información, Variantes y Stock, Imágenes, SEO), `AdminForm`, `ImageUploader`, `VariantSelector`, `Button` (Guardar) |
| **Tabs** | ① **Información:** nombre, URL automática (slug), descripción (editor HTML), marca (select), categorías (multi-select con chips), tags (multi-select), estado (toggle activo/inactivo). ② **Variantes y Stock:** tabla de variantes existentes + botón "+ Agregar variante". Cada variante: combinación de propiedades, SKU, precio por lista, stock por sucursal. ③ **Imágenes:** `ImageUploader` con drag-and-drop, preview, ordenamiento, foto principal. ④ **SEO:** meta título, meta descripción, keywords (opcional, Fase 2). |
| **Validación** | Zod: nombre requerido, URL única, al menos 1 categoría, al menos 1 variante con precio y SKU. |
| **Estado guardando** | Botón `Spinner` + "Guardando...". |
| **Estado éxito** | Toast success "Producto guardado" + permanecer en la página de edición. |
| **Estado error** | Toast error + campos con error resaltados. |
| **ImageUploader** | Zona de drop con "Arrastrá las imágenes o hacé clic para subir". Preview de imágenes subidas con botón X para remover. La primera imagen es la principal (indicada con badge "Principal"). Ordenamiento con drag-and-drop entre las imágenes. |

---

### 6.6 Gestión de Pedidos

| Aspecto | Detalle |
|---|---|
| **Página o ruta** | `/admin/pedidos` |
| **Endpoint REST** | `GET /api/admin/orders`, `GET /api/admin/orders/:id`, `PATCH /api/admin/orders/:id` |
| **Componentes React** | `AdminDataTable` (pedidos), `Select` (filtro por estado), `DateRangePicker` (filtro por fecha), `Button` (Exportar) |

**Lista de pedidos:**
- Columnas: #hash, fecha, cliente, email, total, estado (badge), estado pago (badge), estado envío (badge), items.
- Filtros: por estado, por rango de fechas, por búsqueda (cliente, email, #pedido).
- Sorting: por fecha, total.
- Fila click → `/admin/pedidos/{id}`.

**Detalle de pedido (`/admin/pedidos/{id}`):**
- Layout 2 columnas: izquierda = items + timeline de estados, derecha = datos del cliente + resumen + acciones.
- **Timeline:** `OrderTimeline` con todos los eventos del pedido. Admin puede agregar eventos manualmente (ej: "Llamar al cliente").
- **Cambio de estado:** `Select` con los estados posibles según el estado actual. Ej: Activo → Preparando → Enviado → Entregado. Cada cambio requiere confirmación.
- **Acciones:** "Imprimir pedido", "Exportar a Excel" (RoTSis), "Enviar email al cliente", "Crear etiqueta de envío" (Zipnova).
- **Datos del cliente:** nombre, email, teléfono, dirección de envío, datos de facturación.

---

### 6.7 Métricas de Éxito del Admin

| Métrica | Cómo se mide | Objetivo |
|---|---|---|
| **Tiempo para crear un producto** | Timestamp inicio creación - timestamp guardado | < 3 minutos |
| **Tiempo para procesar un pedido** | Timestamp apertura pedido - timestamp cambio de estado | < 2 minutos |
| **Tasa de errores en carga de productos** | Productos con datos faltantes / Total productos | < 2% |
| **Uso de bulk actions** | Operaciones bulk / Operaciones totales | > 20% |

---

## Flujo 7: Mobile Checkout (Variante Responsive Crítica)

> **Contexto:** 60%+ del tráfico es mobile. El checkout debe ser flawless en pantallas chicas (320-428px de ancho).

### 7.0 Diferencias Clave con Desktop

| Aspecto | Mobile | Desktop |
|---|---|---|
| **Layout** | Single column. `CartSummary` colapsable en top. | 2 columnas: form + sidebar sticky. |
| **StepIndicator** | Barra de progreso horizontal compacta (4 dots + labels). Muestra solo el paso actual con texto. | Barra completa con los 4 pasos etiquetados. |
| **Navegación entre pasos** | Solo botón "Continuar" al final del formulario. No se puede saltar entre pasos haciendo clic en el StepIndicator (evitar pérdida de datos). | Se puede clickear en pasos ya completados para volver. |
| **Formularios** | Campos full-width. `Input` tamaño `lg` (44px+ touch target). Labels arriba del input. | Campos pueden estar en grid 2 columnas. Labels más compactos. |
| **Teclado** | Tipos de input optimizados: `type="email"` para email (teclado con @), `type="tel"` para teléfono (teclado numérico), `inputMode="numeric"` para DNI/CUIT/CP. |
| **Resumen** | `CartSummary` colapsado en un `Accordion` al inicio de la página: "Ver resumen ($XX.XXX)". Expandible con tap. | `CartSummary` siempre visible en sidebar sticky. |
| **Botones CTA** | Full-width, altura 48px mínimo. Texto grande. Separación generosa del resto del contenido (margin-top 24px). | Ancho natural, altura 40-44px. |

### 7.1 Paso 1 Mobile — Datos Personales

| Aspecto | Detalle |
|---|---|
| **Layout** | Stack vertical: tipo de cliente (si aplica) → campos dinámicos → email → teléfono → checkbox marketing → botón Continuar. |
| **Campos dinámicos** | Transición suave al cambiar tipo de cliente (Persona → Empresa). Los campos que cambian tienen animación de fade/slide. |
| **Validación** | Errores inline debajo de cada campo. Al hacer submit, scroll automático al primer campo con error. |
| **Teclado** | Email: `type="email"`. Teléfono/área: `type="tel"`. DNI/CUIT: `inputMode="numeric"`. |

### 7.2 Paso 2 Mobile — Forma de Entrega

| Aspecto | Detalle |
|---|---|
| **Layout** | Stack vertical: tipo de entrega (`RadioGroup` con cards visuales) → selector de sucursal/envío → dirección → dirección facturación (opcional) → botón Continuar. |
| **Radio de entrega** | Cards grandes con ícono + título + descripción + costo. Fácil de tappear (touch target generoso). |
| **Dirección nueva** | Campos en orden lógico de llenado: CP → Provincia → Localidad → Calle + Número (lado a lado en grid 2 columnas) → Depto (opcional). El CP hace autocomplete de provincia y localidad con debounce 500ms. |
| **Mapa** | Si hay sucursales/puntos Zipnova: mini-mapa embebido (o link "Ver en mapa" que abre Google Maps). |

### 7.3 Paso 3 Mobile — Medio de Pago

| Aspecto | Detalle |
|---|---|
| **Layout** | Stack vertical: métodos de pago como cards grandes (`RadioGroup` con íconos) → info extra (cuotas MP, datos bancarios) → botón Continuar. |
| **Cards de pago** | Cada opción es una card tappeable con ícono grande (40px), nombre y descripción breve. La card seleccionada tiene borde primary + fondo primary-50. |
| **Cuotas MP** | `Alert` info con las cuotas disponibles. Podría ser un `Accordion` "Ver cuotas disponibles". |
| **Datos bancarios** | Si es transferencia: `Alert` info con CBU, alias, titular, CUIT. Botón "Copiar CBU" que copia al portapapeles y muestra toast "CBU copiado". |

### 7.4 Paso 4 Mobile — Confirmación

| Aspecto | Detalle |
|---|---|
| **Layout** | Stack vertical: resumen de datos (colapsable por sección) → resumen de compra → total grande → botón Confirmar. |
| **Secciones de datos** | Cada una colapsable: "Datos personales ▼", "Envío ▼", "Pago ▼". Al expandir, muestra los datos ingresados con botón "Editar" que vuelve a ese paso. |
| **Confirmar** | Botón full-width, altura 48px, texto "Confirmar compra por $XX.XXX". Muy visible (primary, shadow). Animación sutil de pulso para llamar la atención. |
| **Post-confirmación** | Mismo flujo que desktop (redirigir a MP, o mostrar éxito con datos bancarios). |

### 7.5 Estados Mobile Específicos

| Estado | Comportamiento Mobile |
|---|---|
| **Loading inicial del checkout** | Skeleton de formulario: 4-5 rectángulos de input + botón rectangular al final. |
| **Transiciones entre pasos** | Slide horizontal (el paso N se va a la izquierda, el paso N+1 entra desde la derecha). Animación 300ms ease-out. |
| **Error de red** | Si el POST falla: toast error. El usuario permanece en el paso actual con todos los datos intactos. |
| **Teclado abierto** | Al hacer submit, cerrar el teclado antes de mostrar errores o avanzar de paso. Si hay error, hacer scroll al campo con error + abrir teclado en ese campo. |
| **Browser back** | Si el usuario presiona "atrás" en el navegador: confirmar "¿Querés salir del checkout? Tus datos se perderán." (usar `beforeunload` + estado de navegación). |
| **Conexión lenta** | Mostrar timeout después de 10 segundos: "Está tardando más de lo normal. No cierres la página." |

### 7.6 Métricas de Éxito Mobile

| Métrica | Cómo se mide | Objetivo |
|---|---|---|
| **Tasa de conversión mobile** | Pedidos mobile / Visitas únicas mobile | ≥ tasa desktop (o diferencia < 15%) |
| **Abandono por paso (mobile)** | Abandono en paso X mobile vs desktop | Identificar pasos con fricción específica mobile |
| **Tiempo de checkout mobile** | Timestamp inicio - timestamp confirmación | < 4 minutos |
| **Tasa de error en mobile** | Checkouts con error mobile / Total checkouts mobile | < 7% |
| **Tasa de éxito de pago mobile (MP)** | Pagos aprobados mobile / Redirecciones mobile | > 80% |

---

## Resumen de Métricas Globales

| Métrica | Objetivo | Prioridad |
|---|---|---|
| Tasa de conversión global | > 3% | 🔴 Crítica |
| Tasa de abandono de carrito | < 70% | 🔴 Crítica |
| Tasa de completación de checkout | > 75% | 🔴 Crítica |
| Tasa de conversión mobile vs desktop | Diferencia < 15% | 🟠 Alta |
| Tasa de registro completado | > 80% | 🟡 Media |
| Tasa de activación post-registro | > 90% | 🟡 Media |
| Tiempo medio de checkout | < 3 min (desktop), < 4 min (mobile) | 🟡 Media |
| Tasa de error en checkout | < 5% | 🟠 Alta |
| NPS post-compra | > 50 | 🟡 Media |

---

> **Confianza global de este documento:** ALTA.
>
> **Hechos (del auditor/PO):** Flujos de negocio, endpoints REST, features MVP, gaps UX identificados, estructura de componentes React.
>
> **Diseño UX (decisiones propias):** Comportamiento responsive, estados visuales por paso, micro-interacciones, flujos de error y recuperación, métricas de éxito.
>
> **Recomendaciones:** Magic link para registro automático, mejoras de validación en tiempo real, patrones de navegación mobile.
>
> **Próximo paso:** `01-ux-wireframes.md` — Wireframes textuales mobile-first de las 15 pantallas clave del MVP.
