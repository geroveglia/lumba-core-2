# 01 — API REST Specification (MVP)

> **Proyecto:** Lumba Ecommerce (Brownfield — migración PHP vanilla → NestJS + Tailwind)
> **Fecha:** 2026-06-08
> **Rol:** Backend Architect
> **Modelo:** deepseek-v4-pro
> **Nivel de confianza global:** ALTA (basado en 42 features MVP de `01-feature-prioritization.md`)
> **Fuentes:** `01-discovery-sistema-actual.md`, `01-modelo-datos-actual.md`, `01-flujos-negocio.md`, `01-feature-prioritization.md`, `01-backend-architecture.md`, `01-security-nestjs-config.md`

---

## Índice

1. [Convenciones de la API](#1-convenciones-de-la-api)
2. [Auth API — Autenticación](#2-auth-api--autenticación)
3. [Users API — Clientes](#3-users-api--clientes)
4. [Products API — Catálogo](#4-products-api--catálogo)
5. [Categories API — Categorías](#5-categories-api--categorías)
6. [Brands API — Marcas](#6-brands-api--marcas)
7. [Cart API — Carrito](#7-cart-api--carrito)
8. [Checkout API — Flujo de Compra](#8-checkout-api--flujo-de-compra)
9. [Orders API — Pedidos](#9-orders-api--pedidos)
10. [Payments API — Pagos](#10-payments-api--pagos)
11. [Shipping API — Envíos](#11-shipping-api--envíos)
12. [Content API — Contenido Web](#12-content-api--contenido-web)
13. [Contact API — Contacto y Devoluciones](#13-contact-api--contacto-y-devoluciones)
14. [Admin API — Panel de Administración](#14-admin-api--panel-de-administración)
15. [Geo API — Geolocalización](#15-geo-api--geolocalización)
16. [Webhooks — Endpoints de Proveedores](#16-webhooks--endpoints-de-proveedores)
17. [Esquemas de Respuesta y Error](#17-esquemas-de-respuesta-y-error)

---

## 1. Convenciones de la API

### 1.1 URL Base

```
Desarrollo:  http://localhost:3000/api
Producción:  https://{tenant}.lumba.com/api
Admin:       http://localhost:3000/api/admin
```

### 1.2 Autenticación

| Tipo | Header | Uso |
|---|---|---|
| **Público** | Ninguno | Catálogo, contenido, contacto |
| **Cliente JWT** | `Authorization: Bearer <access_token>` | Perfil, pedidos, checkout |
| **Admin JWT** | `Authorization: Bearer <admin_access_token>` | Panel de administración |
| **Webhook** | `x-signature` / `x-modo-signature` | Validación criptográfica (sin JWT) |

### 1.3 Formato de respuestas

Todas las respuestas siguen el envelope estándar:

```typescript
// Éxito
{
  "success": true,
  "data": T,                    // Payload de la respuesta
  "meta"?: {                    // Metadata (paginación, etc.)
    "page": number,
    "limit": number,
    "total": number,
    "totalPages": number
  }
}

// Error
{
  "success": false,
  "statusCode": number,
  "message": string,
  "errors"?: {                  // Errores de validación (opcional)
    "field": string,
    "constraints": Record<string, string>
  }[],
  "timestamp": string,
  "path": string
}
```

### 1.4 Códigos HTTP usados

| Código | Significado |
|---|---|
| `200` | OK — GET, PUT, PATCH exitoso |
| `201` | Created — POST exitoso |
| `204` | No Content — DELETE exitoso |
| `400` | Bad Request — Validación fallida |
| `401` | Unauthorized — Token inválido/expirado |
| `403` | Forbidden — Sin permisos |
| `404` | Not Found — Recurso no existe |
| `409` | Conflict — Stock insuficiente, cupón inválido |
| `422` | Unprocessable Entity — Error de negocio |
| `429` | Too Many Requests — Rate limit |

### 1.5 Paginación

```
Query params: ?page=1&limit=24
Response meta: { page, limit, total, totalPages }
```

### 1.6 Versionado

```
Prefijo: /api/v1/...
Header: Accept: application/vnd.lumba.v1+json
```

MVP usa prefijo `/api/v1/` implícito en `/api/`.

---

## 2. Auth API — Autenticación

> **Módulo:** `AuthModule`
> **Controller:** `CustomerAuthController`
> **Mapeo PHP:** `account_signin.php`, `account_register.php`, `account_recover.php`, `account_activate.php`

### 2.1 Login de Cliente

```typescript
@Controller('auth')
export class CustomerAuthController {

  /**
   * Iniciar sesión de cliente.
   * Rate limit: 5 intentos cada 15 minutos.
   * 
   * @route POST /api/auth/login
   * @mapeo account_signin.php
   */
  @Post('login')
  @Throttle({ default: { limit: 5, ttl: 900000 } })
  async login(@Body() dto: LoginDto, @Res({ passthrough: true }) res: Response)
```

| | |
|---|---|
| **Método** | `POST` |
| **Ruta** | `/api/auth/login` |
| **Auth** | Público |
| **Body** | `{ email: string, password: string }` |
| **Response 200** | `{ accessToken, expiresIn, refreshToken, user: { id, email, nombre, role } }` |
| **Response 401** | `{ message: "Email o contraseña incorrectos" }` |
| **Response 429** | Rate limit excedido |
| **Cookies** | `refreshToken` en cookie HTTP-only, Secure, SameSite=Strict |
| **Notas** | Estrategia de migración md5→bcrypt: si el hash es md5, verificar contra `password_md5_hash` legacy y re-hashear con bcrypt. |

### 2.2 Registro de Cliente

```typescript
  /**
   * Registrar nuevo cliente.
   * Rate limit: 3 registros por hora por IP.
   *
   * @route POST /api/auth/register
   * @mapeo account_register.php
   */
  @Post('register')
  @Throttle({ default: { limit: 3, ttl: 3600000 } })
  async register(@Body() dto: RegisterDto)
```

| | |
|---|---|
| **Método** | `POST` |
| **Ruta** | `/api/auth/register` |
| **Auth** | Público |
| **Body** | `{ email, password, nombre, apellido, newsletter?, tipoId? }` |
| **Response 201** | `{ message: "Registro exitoso. Revisá tu email para activar la cuenta." }` |
| **Response 409** | `{ message: "El email ya está registrado" }` |
| **Response 422** | `{ message: "La contraseña no cumple los requisitos de seguridad" }` |
| **Notas** | Crea cliente con `activo=0`. Genera `hash` de activación. Envía email con link `/account_activate/{hash}`. Contraseña hasheada con bcrypt (12 rounds). |

### 2.3 Activación de Cuenta

```typescript
  /**
   * Activar cuenta vía hash enviado por email.
   *
   * @route POST /api/auth/activate/:hash
   * @mapeo account_activate.php
   */
  @Post('activate/:hash')
  async activate(@Param('hash') hash: string)
```

| | |
|---|---|
| **Método** | `POST` |
| **Ruta** | `/api/auth/activate/:hash` |
| **Auth** | Público |
| **Response 200** | `{ accessToken, refreshToken, user: { id, email, nombre, role: 'customer' } }` |
| **Response 404** | `{ message: "Hash de activación inválido o expirado" }` |
| **Notas** | `UPDATE clientes SET activo=1`. Loguea automáticamente (devuelve tokens). Carga perfil completo (marcas, lista de precios, métodos de pago). |

### 2.4 Recuperación de Contraseña — Solicitar

```typescript
  /**
   * Solicitar recuperación de contraseña.
   * Rate limit: 3 solicitudes por hora.
   *
   * @route POST /api/auth/recover
   * @mapeo account_recover.php
   */
  @Post('recover')
  @Throttle({ default: { limit: 3, ttl: 3600000 } })
  async requestRecovery(@Body('email') email: string)
```

| | |
|---|---|
| **Método** | `POST` |
| **Ruta** | `/api/auth/recover` |
| **Auth** | Público |
| **Body** | `{ email: string }` |
| **Response 200** | `{ message: "Si el email existe, recibirás un link de recuperación" }` |
| **Notas** | **Siempre responde 200** (no revela si el email existe). Genera token con expiración de 1 hora. Envía email con link `/account_password_recover/{hash}`. |

### 2.5 Recuperación de Contraseña — Setear Nueva

```typescript
  /**
   * Establecer nueva contraseña vía hash de recuperación.
   *
   * @route POST /api/auth/recover/:hash
   * @mapeo account_password_recover.php
   */
  @Post('recover/:hash')
  async setNewPassword(@Param('hash') hash: string, @Body('password') password: string)
```

| | |
|---|---|
| **Método** | `POST` |
| **Ruta** | `/api/auth/recover/:hash` |
| **Auth** | Público |
| **Body** | `{ password: string }` |
| **Response 200** | `{ message: "Contraseña actualizada correctamente" }` |
| **Response 404** | `{ message: "Link inválido o expirado" }` |
| **Notas** | Valida expiración del hash. `UPDATE clientes SET contrasenia=bcrypt(password)`. |

### 2.6 Refresh Token

```typescript
  /**
   * Rotar refresh token (obtener nuevo access token).
   * El refresh token se envía como cookie HTTP-only.
   *
   * @route POST /api/auth/refresh
   */
  @Post('refresh')
  async refresh(@Req() req: Request, @Res({ passthrough: true }) res: Response)
```

| | |
|---|---|
| **Método** | `POST` |
| **Ruta** | `/api/auth/refresh` |
| **Auth** | Cookie `refreshToken` |
| **Response 200** | `{ accessToken, expiresIn }` |
| **Response 401** | `{ message: "Refresh token inválido o expirado" }` |
| **Notas** | Invalida el refresh token usado (rotación). Setea nueva cookie. |

### 2.7 Logout

```typescript
  /**
   * Cerrar sesión. Revoca refresh token.
   *
   * @route POST /api/auth/logout
   * @mapeo logout.php
   */
  @Post('logout')
  async logout(@Res({ passthrough: true }) res: Response)
```

| | |
|---|---|
| **Método** | `POST` |
| **Ruta** | `/api/auth/logout` |
| **Auth** | JWT (opcional — se acepta aunque esté expirado) |
| **Response 200** | `{ message: "Sesión cerrada" }` |
| **Notas** | Revoca el refresh token. Limpia la cookie. |

---

## 3. Users API — Clientes

> **Módulo:** `UsersModule`
> **Controllers:** `CustomerProfileController`, `AddressController`, `WishlistController`
> **Mapeo PHP:** `account_profile.php`, `account_company.php`, `account_addresses.php`, `account_wish_list.php`, `ajax/favoritos.php`

### 3.1 Perfil del Cliente

```typescript
@Controller('users')
export class CustomerProfileController {

  /**
   * Obtener perfil del cliente autenticado.
   * Carga datos personales + empresa + tipo de cliente + configuraciones.
   *
   * @route GET /api/users/me
   * @mapeo account_profile.php + account_company.php
   */
  @Get('me')
  @UseGuards(JwtAuthGuard)
  async getProfile(@CurrentUser() user: JwtPayload)
```

| | |
|---|---|
| **Método** | `GET` |
| **Ruta** | `/api/users/me` |
| **Auth** | JWT (cliente) |
| **Response 200** | `{ id, email, nombre, apellido, razonSocial, nombreFantasia, dni, cuit, area, telefono, situacionFiscal, tipoComprobante, tipoCliente, listaId, descuento, marketing, fechaRegistro, marcas[] }` |

### 3.2 Actualizar Perfil

```typescript
  /**
   * Actualizar datos personales del cliente.
   *
   * @route PATCH /api/users/me
   * @mapeo account_profile.php
   */
  @Patch('me')
  @UseGuards(JwtAuthGuard)
  async updateProfile(@CurrentUser() user: JwtPayload, @Body() dto: UpdateProfileDto)
```

| | |
|---|---|
| **Método** | `PATCH` |
| **Ruta** | `/api/users/me` |
| **Auth** | JWT (cliente) |
| **Body** | `{ nombre?, apellido?, area?, telefono?, dni?, email?, marketing? }` |
| **Response 200** | Perfil actualizado |
| **Response 409** | `{ message: "El email ya está en uso" }` |

### 3.3 Datos de Empresa

```typescript
  /**
   * Actualizar datos de empresa (razón social, CUIT).
   *
   * @route PATCH /api/users/me/company
   * @mapeo account_company.php
   */
  @Patch('me/company')
  @UseGuards(JwtAuthGuard)
  async updateCompany(@CurrentUser() user: JwtPayload, @Body() dto: UpdateCompanyDto)
```

| | |
|---|---|
| **Método** | `PATCH` |
| **Ruta** | `/api/users/me/company` |
| **Auth** | JWT (cliente) |
| **Body** | `{ razonSocial?, nombreFantasia?, cuit?, situacionFiscalId?, tipoComprobanteId? }` |
| **Response 200** | Datos de empresa actualizados |

### 3.4 Cambiar Contraseña

```typescript
  /**
   * Cambiar contraseña del cliente autenticado.
   *
   * @route PUT /api/users/me/password
   */
  @Put('me/password')
  @UseGuards(JwtAuthGuard)
  async changePassword(@CurrentUser() user: JwtPayload, @Body() dto: ChangePasswordDto)
```

| | |
|---|---|
| **Método** | `PUT` |
| **Ruta** | `/api/users/me/password` |
| **Auth** | JWT (cliente) |
| **Body** | `{ currentPassword: string, newPassword: string }` |
| **Response 200** | `{ message: "Contraseña actualizada" }` |
| **Response 422** | `{ message: "La contraseña actual es incorrecta" }` |

### 3.5 Listar Direcciones

```typescript
@Controller('users/me')
export class AddressController {

  /**
   * Listar direcciones guardadas del cliente.
   *
   * @route GET /api/users/me/addresses
   * @mapeo account_addresses.php
   */
  @Get('addresses')
  @UseGuards(JwtAuthGuard)
  async listAddresses(@CurrentUser() user: JwtPayload)
```

| | |
|---|---|
| **Método** | `GET` |
| **Ruta** | `/api/users/me/addresses` |
| **Auth** | JWT (cliente) |
| **Response 200** | `[{ id, calle, numero, departamento, provincia: {id, nombre}, localidad: {id, nombre}, cp, predeterminada, etiqueta }]` |

### 3.6 Crear Dirección

```typescript
  /**
   * Agregar nueva dirección.
   *
   * @route POST /api/users/me/addresses
   * @mapeo account_addresses.php
   */
  @Post('addresses')
  @UseGuards(JwtAuthGuard)
  async createAddress(@CurrentUser() user: JwtPayload, @Body() dto: CreateAddressDto)
```

| | |
|---|---|
| **Método** | `POST` |
| **Ruta** | `/api/users/me/addresses` |
| **Auth** | JWT (cliente) |
| **Body** | `{ calle, numero, departamento?, provinciaId, localidadId, cp, etiqueta?, predeterminada? }` |
| **Response 201** | Dirección creada |
| **Notas** | Si es `predeterminada=true`, desmarca las demás. Primera dirección = predeterminada automáticamente. |

### 3.7 Editar Dirección

```typescript
  /**
   * @route PUT /api/users/me/addresses/:id
   */
  @Put('addresses/:id')
  @UseGuards(JwtAuthGuard)
  async updateAddress(@Param('id') id: number, @Body() dto: UpdateAddressDto)
```

| | |
|---|---|
| **Método** | `PUT` |
| **Ruta** | `/api/users/me/addresses/:id` |
| **Auth** | JWT (cliente) |
| **Body** | Parcial de `CreateAddressDto` |
| **Response 200** | Dirección actualizada |

### 3.8 Eliminar Dirección

```typescript
  /**
   * @route DELETE /api/users/me/addresses/:id
   */
  @Delete('addresses/:id')
  @UseGuards(JwtAuthGuard)
  async deleteAddress(@Param('id') id: number)
```

| | |
|---|---|
| **Método** | `DELETE` |
| **Ruta** | `/api/users/me/addresses/:id` |
| **Auth** | JWT (cliente) |
| **Response 204** | Soft delete (`eliminado=1`) |

### 3.9 Lista de Favoritos

```typescript
@Controller('users/me')
export class WishlistController {

  /**
   * Ver wishlist del cliente.
   *
   * @route GET /api/users/me/wishlist
   * @mapeo account_wish_list.php
   */
  @Get('wishlist')
  @UseGuards(JwtAuthGuard)
  async getWishlist(@CurrentUser() user: JwtPayload)
```

| | |
|---|---|
| **Método** | `GET` |
| **Ruta** | `/api/users/me/wishlist` |
| **Auth** | JWT (cliente) |
| **Response 200** | `[{ productoId, nombre, url, foto, precioDesde, marca }]` |

### 3.10 Toggle Favorito

```typescript
  /**
   * Agregar/quitar producto de favoritos.
   *
   * @route POST /api/users/me/wishlist/:productId
   * @mapeo ajax/favoritos.php
   */
  @Post('wishlist/:productId')
  @UseGuards(JwtAuthGuard)
  async toggleFavorite(@CurrentUser() user: JwtPayload, @Param('productId') productId: number)
```

| | |
|---|---|
| **Método** | `POST` |
| **Ruta** | `/api/users/me/wishlist/:productId` |
| **Auth** | JWT (cliente) |
| **Response 200** | `{ added: boolean, message: "Agregado a favoritos" \| "Eliminado de favoritos" }` |
| **Notas** | Toggle: si existe → DELETE, si no → INSERT. |

---

## 4. Products API — Catálogo

> **Módulo:** `ProductsModule`
> **Controller:** `ProductCatalogController`
> **Mapeo PHP:** `routes/productos.php`, `routes/producto.php`, `routes/productos_grilla.php`, `inc/get_products.php`

### 4.1 Listado de Productos (Grilla con Filtros)

```typescript
@Controller('products')
export class ProductCatalogController {

  /**
   * Listar productos con filtros.
   * Soporta filtro por categoría, marca, tag, rango de precio, propiedades.
   * Aplica restricción de marcas si el cliente está logueado.
   *
   * @route GET /api/products
   * @mapeo productos.php + get_products.php
   */
  @Get()
  async listProducts(
    @Query() filters: ProductFilterDto,
    @CurrentUserOptional() user?: JwtPayload,
  )
```

| | |
|---|---|
| **Método** | `GET` |
| **Ruta** | `/api/products` |
| **Auth** | Opcional (afecta restricción de marcas y precios por lista) |
| **Query Params** | `categoriaId`, `marcaId`, `tagId`, `precioMin`, `precioMax`, `propiedades` (ej: `"10:25,11:30"`), `orden` (`precio_asc`, `precio_desc`, `nombre_asc`, `novedades`), `q` (búsqueda), `page` (default 1), `limit` (default 24, max 100) |
| **Response 200** | `{ success: true, data: ProductListItemDto[], meta: { page, limit, total, totalPages, filters: { precioMin, precioMax, categorias[], marcas[], propiedades{} } } }` |

**ProductListItemDto:**
```typescript
{
  id: number;
  nombre: string;
  url: string;
  foto: string;
  precioDesde: number;
  precioOriginal?: number;     // Si hay promoción aplicada
  descuento?: number;          // Porcentaje de descuento
  marca: { id: number; nombre: string };
  stock: 'disponible' | 'bajo' | 'sin_stock';  // Indicador visual
}
```

### 4.2 Detalle de Producto

```typescript
  /**
   * Obtener detalle completo de un producto por su URL slug.
   *
   * @route GET /api/products/:url
   * @mapeo producto.php
   */
  @Get(':url')
  async getProductDetail(
    @Param('url') url: string,
    @CurrentUserOptional() user?: JwtPayload,
  )
```

| | |
|---|---|
| **Método** | `GET` |
| **Ruta** | `/api/products/:url` |
| **Auth** | Opcional |
| **Response 200** | `ProductDetailResponseDto` (ver abajo) |
| **Response 404** | `{ message: "Producto no encontrado" }` |

**ProductDetailResponseDto:**
```typescript
{
  id: number;
  nombre: string;
  url: string;
  descripcion: string;       // HTML sanitizado
  foto: string;
  fotos: string[];           // Galería de imágenes
  precioDesde: number;
  precioOriginalDesde?: number;
  descuento?: number;
  iva: number;
  marca: { id: number; nombre: string; url: string };
  categorias: { id: number; nombre: string; url: string }[];
  tags: { id: number; nombre: string; url: string }[];
  propiedades: {              // Para filtros y display
    propiedad: string;
    valores: { id: number; valor: string }[];
  }[];
  variantes: {
    id: number;
    sku: string;
    combinacion: string;     // "Talle XL / Color Rojo"
    propiedades: { propiedad: string; valor: string }[];
    foto?: string;
    precio: number;          // Precio según lista del cliente
    precioOriginal?: number;
    stock: {
      sucursalId: number;
      sucursal: string;
      stock: number;
      stockInfinito: boolean;
    }[];
    stockTotal: number;
    disponible: boolean;
  }[];
  relacionados: ProductListItemDto[];  // Productos relacionados
  schemaOrg: object;         // Schema.org Product structured data
}
```

### 4.3 Productos Relacionados

```typescript
  /**
   * Obtener productos relacionados de un producto.
   *
   * @route GET /api/products/:url/related
   */
  @Get(':url/related')
  async getRelatedProducts(@Param('url') url: string)
```

| | |
|---|---|
| **Método** | `GET` |
| **Ruta** | `/api/products/:url/related` |
| **Auth** | Público |
| **Response 200** | `ProductListItemDto[]` |
| **Notas** | Primero busca relacionados manuales. Si no hay, sugiere por misma categoría/marca. |

### 4.4 Búsqueda de Productos

```typescript
  /**
   * Búsqueda textual de productos.
   * MVP: FULLTEXT en MySQL. Fase 2: Elasticsearch.
   *
   * @route GET /api/products/search
   */
  @Get('search')
  async search(@Query('q') q: string, @Query('page') page?: number)
```

| | |
|---|---|
| **Método** | `GET` |
| **Ruta** | `/api/products/search` |
| **Auth** | Público |
| **Query** | `q` (obligatorio, min 2 caracteres), `page`, `limit` |
| **Response 200** | `{ data: ProductListItemDto[], meta: { page, limit, total, totalPages } }` |

---

## 5. Categories API — Categorías

> **Módulo:** `CategoriesModule`
> **Controller:** `CategoryPublicController`
> **Mapeo PHP:** `admin/routes/categorias.php`

### 5.1 Árbol de Categorías

```typescript
@Controller('categories')
export class CategoryPublicController {

  /**
   * Árbol completo de categorías activas.
   *
   * @route GET /api/categories
   */
  @Get()
  async getTree()
```

| | |
|---|---|
| **Método** | `GET` |
| **Ruta** | `/api/categories` |
| **Auth** | Público |
| **Response 200** | `[{ id, nombre, url, foto, hijos: [...] }]` (árbol anidado) |

### 5.2 Detalle de Categoría

```typescript
  /**
   * Detalle de una categoría con subcategorías.
   *
   * @route GET /api/categories/:url
   */
  @Get(':url')
  async getByUrl(@Param('url') url: string)
```

| | |
|---|---|
| **Método** | `GET` |
| **Ruta** | `/api/categories/:url` |
| **Auth** | Público |
| **Response 200** | `{ id, nombre, url, foto, descripcion?, padre?, hijos[], breadcrumbs[] }` |
| **Response 404** | `{ message: "Categoría no encontrada" }` |

---

## 6. Brands API — Marcas

> **Módulo:** `BrandsModule`
> **Controller:** `BrandPublicController`

### 6.1 Listar Marcas

```typescript
@Controller('brands')
export class BrandPublicController {

  /**
   * Listar marcas activas.
   * Si hay cliente logueado, filtra por restricción de marcas del cliente.
   *
   * @route GET /api/brands
   */
  @Get()
  async list(@CurrentUserOptional() user?: JwtPayload)
```

| | |
|---|---|
| **Método** | `GET` |
| **Ruta** | `/api/brands` |
| **Auth** | Opcional |
| **Response 200** | `[{ id, nombre, url, foto }]` |

---

## 7. Cart API — Carrito

> **Módulo:** `CartModule`
> **Controller:** `CartController`
> **Mapeo PHP:** `ajax/agregarcarrito.php`, `routes/cart.php`

### 7.1 Ver Carrito

```typescript
@Controller('cart')
export class CartController {

  /**
   * Obtener carrito con resumen completo, promociones y cupones aplicados.
   *
   * @route GET /api/cart
   * @mapeo cart.php
   */
  @Get()
  async getCart(
    @CurrentUserOptional() user?: JwtPayload,
    @Req() req: Request,
  )
```

| | |
|---|---|
| **Método** | `GET` |
| **Ruta** | `/api/cart` |
| **Auth** | Opcional (anónimo usa `sessionToken` en cookie) |
| **Response 200** | `CartResponseDto` (ver abajo) |

**CartResponseDto:**
```typescript
{
  id: number;
  items: {
    productoId: number;
    varianteId: number;
    nombre: string;
    sku: string;
    foto: string;
    url: string;
    cantidad: number;
    precioUnitario: number;
    precioOriginal: number;
    subtotal: number;
    descuento: number;        // Descuento por promoción
    descuentoCupon: number;   // Descuento por cupón
    iva: number;
    promocion?: string;       // Nombre de la promoción aplicada
    stockBajo: boolean;       // Advertencia si stock < cantidad
    sinStock: boolean;        // Error si no hay stock
  }[];
  resumen: {
    subtotal: number;
    descuentoPromociones: number;
    descuentoCupon: number;
    iva: number;
    costoEnvio: number;
    envioGratis: boolean;
    total: number;
  };
  cuponAplicado?: {
    codigo: string;
    tipo: 'Porcentaje' | 'Monto fijo' | 'Envío gratis';
    valor: number;
  };
  compraMinima: number;
  compraMinimaAlcanzada: boolean;
}
```

### 7.2 Agregar al Carrito

```typescript
  /**
   * Agregar un producto/variante al carrito.
   * Valida stock y precio server-side (anti-tampering).
   *
   * @route POST /api/cart/items
   * @mapeo agregarcarrito.php
   */
  @Post('items')
  async addItem(
    @Body() dto: AddToCartDto,
    @CurrentUserOptional() user?: JwtPayload,
    @Req() req: Request,
  )
```

| | |
|---|---|
| **Método** | `POST` |
| **Ruta** | `/api/cart/items` |
| **Auth** | Opcional |
| **Body** | `{ productoId, varianteId, cantidad, precio, sku?, foto?, url?, iva?, producto? }` |
| **Response 201** | `CartResponseDto` (carrito actualizado) |
| **Response 409** | `{ message: "Stock insuficiente", stockDisponible: number }` |
| **Response 422** | `{ message: "Precio inválido" }` (si el precio del request no coincide con DB) |
| **Notas** | **Validación server-side:** (1) stock → consulta `productos_variantes_stock`, (2) precio → consulta `productos_variantes_precios` con `lista_id` del cliente, (3) promociones → busca promos aplicables. Si el precio del POST no coincide, usa el de DB. |

### 7.3 Modificar Cantidad

```typescript
  /**
   * Modificar cantidad de un item en el carrito.
   * Cantidad 0 = eliminar item.
   *
   * @route PATCH /api/cart/items/:productId/:variantId
   */
  @Patch('items/:productId/:variantId')
  async updateItemQuantity(
    @Param('productId') productId: number,
    @Param('variantId') variantId: number,
    @Body('cantidad') cantidad: number,
    @CurrentUserOptional() user?: JwtPayload,
  )
```

| | |
|---|---|
| **Método** | `PATCH` |
| **Ruta** | `/api/cart/items/:productId/:variantId` |
| **Auth** | Opcional |
| **Body** | `{ cantidad: number }` |
| **Response 200** | `CartResponseDto` |

### 7.4 Eliminar Item

```typescript
  /**
   * @route DELETE /api/cart/items/:productId/:variantId
   */
  @Delete('items/:productId/:variantId')
  async removeItem(@Param('productId') productId: number, @Param('variantId') variantId: number)
```

| | |
|---|---|
| **Método** | `DELETE` |
| **Ruta** | `/api/cart/items/:productId/:variantId` |
| **Response 200** | `CartResponseDto` |

### 7.5 Vaciar Carrito

```typescript
  /**
   * @route DELETE /api/cart
   */
  @Delete()
  async clearCart()
```

| | |
|---|---|
| **Método** | `DELETE` |
| **Ruta** | `/api/cart` |
| **Response 200** | `{ items: [], resumen: { subtotal: 0, total: 0 } }` |

### 7.6 Aplicar Cupón

```typescript
  /**
   * Aplicar cupón de descuento al carrito.
   *
   * @route POST /api/cart/coupon
   * @mapeo cupon.php
   */
  @Post('coupon')
  async applyCoupon(
    @Body('codigo') codigo: string,
    @CurrentUserOptional() user?: JwtPayload,
  )
```

| | |
|---|---|
| **Método** | `POST` |
| **Ruta** | `/api/cart/coupon` |
| **Auth** | Opcional |
| **Body** | `{ codigo: string }` |
| **Response 200** | `CartResponseDto` (con cupón aplicado) |
| **Response 422** | `{ message: "Cupón inválido o vencido" }` |
| **Response 422** | `{ message: "El cupón no aplica a estos productos" }` |
| **Notas** | Valida: vigencia, tipo de descuento, aplicabilidad (toda la tienda / categorías / productos), acumulabilidad con promociones activas. |

### 7.7 Quitar Cupón

```typescript
  /**
   * @route DELETE /api/cart/coupon
   */
  @Delete('coupon')
  async removeCoupon()
```

| | |
|---|---|
| **Método** | `DELETE` |
| **Ruta** | `/api/cart/coupon` |
| **Response 200** | `CartResponseDto` (sin cupón) |

### 7.8 Mini-Carrito (Resumen)

```typescript
  /**
   * Resumen compacto del carrito para el header.
   *
   * @route GET /api/cart/summary
   */
  @Get('summary')
  async getSummary(@CurrentUserOptional() user?: JwtPayload)
```

| | |
|---|---|
| **Método** | `GET` |
| **Ruta** | `/api/cart/summary` |
| **Auth** | Opcional |
| **Response 200** | `{ cantidadItems: number, total: number }` |
| **Notas** | Endpoint ligero para el mini-carrito del header. Sin joins pesados. |

---

## 8. Checkout API — Flujo de Compra

> **Módulo:** `CheckoutModule`
> **Controller:** `CheckoutController`
> **Mapeo PHP:** `routes/checkout_1.php`, `checkout_2.php`, `checkout_2_envio.php`, `checkout_3.php`, `checkout_4.php`

### 8.1 Iniciar / Obtener Estado del Checkout

```typescript
@Controller('checkout')
export class CheckoutController {

  /**
   * Iniciar checkout o recuperar estado actual.
   * Carga datos del carrito, configuración del cliente, y estado previo si existe.
   *
   * @route GET /api/checkout
   * @mapeo checkout_1.php (inicialización)
   */
  @Get()
  async getCheckoutState(
    @CurrentUserOptional() user?: JwtPayload,
    @Req() req: Request,
  )
```

| | |
|---|---|
| **Método** | `GET` |
| **Ruta** | `/api/checkout` |
| **Auth** | Opcional |
| **Response 200** | `CheckoutStateDto` (ver abajo) |
| **Response 422** | `{ message: "El carrito está vacío" }` |

**CheckoutStateDto:**
```typescript
{
  pasoActual: number;          // 1-4
  carrito: CartResponseDto;
  datosPersonales?: CheckoutDataDto;
  datosEnvio?: CheckoutShippingDto;
  datosPago?: CheckoutPaymentDto;
  cliente: {                   // Si está logueado
    id: number;
    email: string;
    nombre: string;
    apellido: string;
    tipoCliente: { id: number; nombre: string };
    metodosPago: string[];     // ['mercadopago', 'transferencia', 'efectivo']
    metodosEnvio: string[];    // ['retiro_sucursal', 'envio_domicilio', 'zipnova_sucursal']
    direcciones: AddressDto[];
    compraMinima: number;
    compraMinimaAlcanzada: boolean;
  };
  tiposClienteDisponibles?: { id: number; nombre: string }[];  // Si configuracion.tipos_cliente
  tieneCuponEnvioGratis: boolean;
}
```

### 8.2 Paso 1 — Datos Personales

```typescript
  /**
   * Guardar datos personales y de facturación.
   *
   * @route POST /api/checkout/step/1
   * @mapeo checkout_1.php + collect_checkout_info.php
   */
  @Post('step/1')
  async saveStep1(
    @Body() dto: CheckoutDataDto,
    @CurrentUserOptional() user?: JwtPayload,
  )
```

| | |
|---|---|
| **Método** | `POST` |
| **Ruta** | `/api/checkout/step/1` |
| **Auth** | Opcional |
| **Body** | `CheckoutDataDto` (ver §3.10 de arquitectura) |
| **Response 200** | `{ pasoActual: 2, datosPersonales: {...} }` |
| **Response 422** | `{ message: "El monto mínimo de compra es $X" }` |

### 8.3 Paso 2 — Forma de Entrega

```typescript
  /**
   * Guardar forma de entrega y dirección.
   *
   * @route POST /api/checkout/step/2
   * @mapeo checkout_2.php + checkout_2_envio.php
   */
  @Post('step/2')
  async saveStep2(
    @Body() dto: CheckoutShippingDto,
    @CurrentUserOptional() user?: JwtPayload,
  )
```

| | |
|---|---|
| **Método** | `POST` |
| **Ruta** | `/api/checkout/step/2` |
| **Auth** | Opcional |
| **Body** | `CheckoutShippingDto` |
| **Response 200** | `{ pasoActual: 3, datosEnvio: {...}, costoEnvio: number, envioGratis: boolean, carritoActualizado: CartResponseDto }` |
| **Response 422** | `{ message: "No hay cobertura para esta ubicación" }` |

### 8.4 Paso 3 — Medio de Pago

```typescript
  /**
   * Guardar medio de pago seleccionado.
   *
   * @route POST /api/checkout/step/3
   * @mapeo checkout_3.php
   */
  @Post('step/3')
  async saveStep3(
    @Body() dto: CheckoutPaymentDto,
    @CurrentUserOptional() user?: JwtPayload,
  )
```

| | |
|---|---|
| **Método** | `POST` |
| **Ruta** | `/api/checkout/step/3` |
| **Auth** | Opcional |
| **Body** | `{ formaPago: 'mercadopago' \| 'modo' \| 'transferencia' \| 'efectivo' }` |
| **Response 200** | `{ pasoActual: 4, datosPago: {...}, cuotasDisponibles?: number[] }` (para MP) |
| **Response 422** | `{ message: "Medio de pago no disponible para tu perfil" }` |

### 8.5 Paso 4 — Confirmar Pedido

```typescript
  /**
   * Confirmar pedido y procesar pago.
   * Transacción MySQL con SELECT ... FOR UPDATE para validación final de stock.
   * Registro automático de cliente si compra como invitado.
   *
   * @route POST /api/checkout/confirm
   * @mapeo checkout_4.php + guardar_pedido_parcial.php
   */
  @Post('confirm')
  async confirmCheckout(
    @Body() dto: CheckoutConfirmDto,
    @CurrentUserOptional() user?: JwtPayload,
    @Req() req: Request,
  )
```

| | |
|---|---|
| **Método** | `POST` |
| **Ruta** | `/api/checkout/confirm` |
| **Auth** | Opcional |
| **Body** | `{ observaciones?: string }` |
| **Response 200** | `CheckoutConfirmationResponseDto` (ver abajo) |
| **Response 409** | `{ message: "Stock insuficiente para: [productos]" }` |
| **Response 422** | `{ message: "Compra mínima no alcanzada" }` |

**CheckoutConfirmationResponseDto:**
```typescript
{
  pedido: {
    id: number;
    hash: string;
    total: number;
    estado: 'Activo';
    fecha: string;
  };
  pago: {
    metodo: string;
    // Según método:
    urlPago?: string;        // MercadoPago: URL de checkout
    qr?: string;             // Modo: QR para pago
    linkPago?: string;       // Modo: link de pago
    datosBancarios?: string; // Transferencia: HTML con datos
    comprobanteUrl?: string; // Transferencia: link para subir comprobante
    mensaje?: string;        // Efectivo: mensaje de confirmación
  };
  // Si se creó cuenta automáticamente:
  nuevaCuenta?: {
    email: string;
    mensaje: string;         // "Te enviamos un email para acceder a tu cuenta"
  };
}
```

### 8.6 Validar Stock en Tiempo Real

```typescript
  /**
   * Validar stock de los items del carrito (para polling antes de confirmar).
   *
   * @route POST /api/checkout/validate-stock
   */
  @Post('validate-stock')
  async validateStock(@CurrentUserOptional() user?: JwtPayload)
```

| | |
|---|---|
| **Método** | `POST` |
| **Ruta** | `/api/checkout/validate-stock` |
| **Auth** | Opcional |
| **Response 200** | `{ valido: boolean, items: [{ productoId, nombre, disponible, stockDisponible }] }` |

---

## 9. Orders API — Pedidos

> **Módulo:** `OrdersModule`
> **Controller:** `CustomerOrderController`
> **Mapeo PHP:** `routes/account_orders.php`, `routes/account_order.php`

### 9.1 Historial de Pedidos del Cliente

```typescript
@Controller('orders')
export class CustomerOrderController {

  /**
   * Listar pedidos del cliente autenticado.
   *
   * @route GET /api/orders
   * @mapeo account_orders.php
   */
  @Get()
  @UseGuards(JwtAuthGuard)
  async listOrders(
    @CurrentUser() user: JwtPayload,
    @Query('page') page?: number,
    @Query('limit') limit?: number,
  )
```

| | |
|---|---|
| **Método** | `GET` |
| **Ruta** | `/api/orders` |
| **Auth** | JWT (cliente) |
| **Query** | `page`, `limit` (default 10) |
| **Response 200** | `{ data: OrderListItemDto[], meta: { page, limit, total, totalPages } }` |

**OrderListItemDto:**
```typescript
{
  id: number;
  hash: string;
  fecha: string;
  total: number;
  estado: string;            // 'Activo', 'Reintegrado'
  estadoPago: string;        // 'Pendiente', 'Pagado', 'Reintegrado'
  estadoEntrega: string;     // 'Pendiente', 'Enviado', 'Entregado'
  cantidadItems: number;
}
```

### 9.2 Detalle de Pedido

```typescript
  /**
   * Ver detalle completo de un pedido por hash.
   *
   * @route GET /api/orders/:hash
   * @mapeo account_order.php
   */
  @Get(':hash')
  @UseGuards(JwtAuthGuard)
  async getOrderDetail(
    @CurrentUser() user: JwtPayload,
    @Param('hash') hash: string,
  )
```

| | |
|---|---|
| **Método** | `GET` |
| **Ruta** | `/api/orders/:hash` |
| **Auth** | JWT (cliente) |
| **Response 200** | `OrderDetailDto` (ver abajo) |
| **Response 404** | `{ message: "Pedido no encontrado" }` |

**OrderDetailDto:**
```typescript
{
  id: number;
  hash: string;
  fecha: string;
  estado: string;
  estadoPago: string;
  estadoEntrega: string;
  estadoFactura: string;
  tracking?: string;
  items: {
    producto: string;
    sku: string;
    foto: string;
    cantidad: number;
    precioUnitario: number;
    subtotal: number;
    propiedades: string;     // "Talle XL / Color Rojo"
  }[];
  totales: {
    subtotal: number;
    descuentos: number;
    costoEnvio: number;
    total: number;
  };
  envio: {
    formaEntrega: string;
    direccion?: string;
    sucursal?: string;
    costoEnvio: number;
  };
  pago: {
    formaPago: string;
    estado: string;
  };
  facturacion?: {
    tipoComprobante: string;
    razonSocial?: string;
    cuit?: string;
  };
}
```

### 9.3 Repetir Compra

```typescript
  /**
   * Cargar carrito desde un pedido anterior.
   *
   * @route POST /api/orders/:hash/repeat
   */
  @Post(':hash/repeat')
  @UseGuards(JwtAuthGuard)
  async repeatOrder(@CurrentUser() user: JwtPayload, @Param('hash') hash: string)
```

| | |
|---|---|
| **Método** | `POST` |
| **Ruta** | `/api/orders/:hash/repeat` |
| **Auth** | JWT (cliente) |
| **Response 200** | `CartResponseDto` (carrito cargado con items del pedido) |
| **Notas** | Solo productos que siguen activos y con stock. |

### 9.4 Retomar Compra (Carrito Abandonado)

```typescript
  /**
   * Retomar compra desde link de carrito abandonado.
   * Endpoint público (se accede desde email).
   *
   * @route POST /api/orders/:hash/resume
   * @mapeo acciones/retomar_compra.php
   */
  @Post(':hash/resume')
  async resumeOrder(
    @Param('hash') hash: string,
    @Query('cupon') cupon?: string,
  )
```

| | |
|---|---|
| **Método** | `POST` |
| **Ruta** | `/api/orders/:hash/resume` |
| **Auth** | Público (usa hash como secreto) |
| **Query** | `cupon` (código de cupón opcional) |
| **Response 200** | `CartResponseDto` (carrito restaurado) |
| **Response 404** | `{ message: "Pedido no encontrado o ya completado" }` |

---

## 10. Payments API — Pagos

> **Módulo:** `PaymentsModule`
> **Controllers:** `PaymentController`, `ComprobanteController`
> **Mapeo PHP:** `routes/checkout_4.php` (sección pagos), `routes/comprobantes.php`

### 10.1 Iniciar Pago MercadoPago

```typescript
@Controller('payments')
export class PaymentController {

  /**
   * Crear preferencia de pago en MercadoPago y obtener URL de checkout.
   *
   * @route POST /api/payments/mercadopago/init
   */
  @Post('mercadopago/init')
  @UseGuards(JwtAuthGuard)
  async initMercadoPago(
    @CurrentUser() user: JwtPayload,
    @Body() dto: InitMercadoPagoDto,
  )
```

| | |
|---|---|
| **Método** | `POST` |
| **Ruta** | `/api/payments/mercadopago/init` |
| **Auth** | JWT (cliente) |
| **Body** | `{ pedidoHash: string, cuotas?: number }` |
| **Response 200** | `{ urlPago: string, preferenceId: string }` |
| **Response 404** | Pedido no encontrado |
| **Response 422** | Pedido ya pagado |

### 10.2 Iniciar Pago Modo (Fase 2)

```typescript
  /**
   * Crear intención de pago en Modo y obtener QR/link.
   * Fase 2 — si Modo es requerido por algún cliente, subir a MVP.
   *
   * @route POST /api/payments/modo/init
   */
  @Post('modo/init')
  @UseGuards(JwtAuthGuard)
  async initModo(@CurrentUser() user: JwtPayload, @Body() dto: InitModoDto)
```

| | |
|---|---|
| **Método** | `POST` |
| **Ruta** | `/api/payments/modo/init` |
| **Auth** | JWT (cliente) |
| **Body** | `{ pedidoHash: string }` |
| **Response 200** | `{ urlPago: string, qr: string, linkPago: string }` |

### 10.3 Subir Comprobante de Transferencia

```typescript
@Controller('payments')
export class ComprobanteController {

  /**
   * Subir comprobante de pago para pedidos con transferencia bancaria.
   *
   * @route POST /api/payments/comprobante/:hash
   * @mapeo comprobantes.php
   */
  @Post('comprobante/:hash')
  @UseInterceptors(FileInterceptor('comprobante'))
  async uploadComprobante(
    @Param('hash') hash: string,
    @UploadedFile() file: Express.Multer.File,
  )
```

| | |
|---|---|
| **Método** | `POST` |
| **Ruta** | `/api/payments/comprobante/:hash` |
| **Auth** | Público (usa hash como secreto compartido) |
| **Body** | `multipart/form-data`: campo `comprobante` (imagen) |
| **Response 200** | `{ message: "Comprobante subido correctamente" }` |
| **Response 400** | `{ message: "Formato no permitido. Usar JPG, PNG o PDF" }` |
| **Response 413** | Archivo demasiado grande (max 5MB) |
| **Notas** | Validar MIME type real con `file-type`. Almacenar en filesystem/S3. |

### 10.4 Consultar Estado de Pago

```typescript
  /**
   * Consultar estado de pago (polling desde frontend post-redirección a MP).
   *
   * @route GET /api/payments/status/:hash
   */
  @Get('status/:hash')
  async getPaymentStatus(@Param('hash') hash: string)
```

| | |
|---|---|
| **Método** | `GET` |
| **Ruta** | `/api/payments/status/:hash` |
| **Auth** | Opcional |
| **Response 200** | `{ estadoPago: 'Pendiente' \| 'Pagado' \| 'Reintegrado', pedidoId: number }` |

---

## 11. Shipping API — Envíos

> **Módulo:** `ShippingModule`
> **Controller:** `ShippingController`
> **Mapeo PHP:** `routes/checkout_2_envio.php`, `ajax/cotizar_envio_con_cp.php`

### 11.1 Opciones de Envío Disponibles

```typescript
@Controller('shipping')
export class ShippingController {

  /**
   * Listar opciones de envío disponibles según perfil del cliente y ubicación.
   * Agrupa: retiro por sucursal, envíos propios, Zipnova.
   *
   * @route GET /api/shipping/options
   */
  @Get('options')
  async getShippingOptions(
    @CurrentUserOptional() user?: JwtPayload,
    @Query('provinciaId') provinciaId?: number,
    @Query('localidadId') localidadId?: number,
    @Query('cp') cp?: string,
  )
```

| | |
|---|---|
| **Método** | `GET` |
| **Ruta** | `/api/shipping/options` |
| **Auth** | Opcional |
| **Query** | `provinciaId`, `localidadId`, `cp` |
| **Response 200** | `ShippingOptionsDto` (ver abajo) |

**ShippingOptionsDto:**
```typescript
{
  retiroSucursal: {
    habilitado: boolean;
    sucursales: { id: number; nombre: string; direccion: string; telefono?: string }[];
    informacion: string;
    gratis: boolean;
  } | null;
  enviosPropios: {
    id: number;
    nombre: string;
    precio: number;
    informacion?: string;
    envioGratis: boolean;
    envioGratisMinimo?: number;
  }[];
  zipnova: {
    habilitado: boolean;
    domicilio?: { opciones: any[] };    // Opciones de envío a domicilio
    puntoRetiro?: { puntos: any[] };    // Puntos de retiro
  } | null;
}
```

### 11.2 Cotizar Envío

```typescript
  /**
   * Cotizar costo de envío para un método específico.
   *
   * @route POST /api/shipping/quote
   * @mapeo cotizar_envio_con_cp.php
   */
  @Post('quote')
  async quoteShipping(
    @Body() dto: ShippingQuoteDto,
    @CurrentUserOptional() user?: JwtPayload,
  )
```

| | |
|---|---|
| **Método** | `POST` |
| **Ruta** | `/api/shipping/quote` |
| **Auth** | Opcional |
| **Body** | `{ metodo: 'envio_propio' \| 'zipnova', envioPropioId?, provinciaId, localidadId, cp, zipnovaOpcion? }` |
| **Response 200** | `{ costo: number, envioGratis: boolean, detalle?: any }` |

### 11.3 Lista de Sucursales

```typescript
  /**
   * Listar todas las sucursales activas.
   *
   * @route GET /api/shipping/sucursales
   */
  @Get('sucursales')
  async getSucursales()
```

| | |
|---|---|
| **Método** | `GET` |
| **Ruta** | `/api/shipping/sucursales` |
| **Auth** | Público |
| **Response 200** | `[{ id, nombre, direccion, telefono, horarios? }]` |

### 11.4 Tracking de Envío

```typescript
  /**
   * Consultar tracking de un pedido (público).
   *
   * @route GET /api/shipping/tracking/:orderHash
   */
  @Get('tracking/:orderHash')
  async getTracking(@Param('orderHash') orderHash: string)
```

| | |
|---|---|
| **Método** | `GET` |
| **Ruta** | `/api/shipping/tracking/:orderHash` |
| **Auth** | Público |
| **Response 200** | `{ estadoEntrega: string, tracking?: string, timeline: [{ fecha, estado, descripcion }] }` |
| **Response 404** | `{ message: "Pedido no encontrado" }` |

---

## 12. Content API — Contenido Web

> **Módulo:** `ContentModule`
> **Controller:** `ContentPublicController`
> **Mapeo PHP:** `routes/preguntas-frecuentes.php`, `routes/secciones.php`

### 12.1 Slider del Home

```typescript
@Controller('content')
export class ContentPublicController {

  /**
   * Obtener slides activos del homepage ordenados.
   *
   * @route GET /api/content/slider
   */
  @Get('slider')
  async getSlider()
```

| | |
|---|---|
| **Método** | `GET` |
| **Ruta** | `/api/content/slider` |
| **Auth** | Público |
| **Response 200** | `[{ id, titulo, descripcion, foto, link, orden }]` |

### 12.2 Banners

```typescript
  /**
   * Obtener banners activos por ubicación.
   *
   * @route GET /api/content/banners
   */
  @Get('banners')
  async getBanners(@Query('ubicacion') ubicacion?: string)
```

| | |
|---|---|
| **Método** | `GET` |
| **Ruta** | `/api/content/banners` |
| **Auth** | Público |
| **Query** | `ubicacion` (opcional, filtra por ubicación configurada) |
| **Response 200** | `[{ id, titulo, foto, link, ubicacion }]` + `promocionesBancarias: [{ id, banco, foto }]` |

### 12.3 FAQ (Preguntas Frecuentes)

```typescript
  /**
   * Obtener preguntas frecuentes ordenadas.
   *
   * @route GET /api/content/faq
   * @mapeo preguntas-frecuentes.php
   */
  @Get('faq')
  async getFaq()
```

| | |
|---|---|
| **Método** | `GET` |
| **Ruta** | `/api/content/faq` |
| **Auth** | Público |
| **Response 200** | `[{ id, pregunta, respuesta, orden }]` |

### 12.4 Página de Sección Adicional

```typescript
  /**
   * Obtener contenido de una página/sección adicional.
   * Usado para: términos y condiciones, política de privacidad, etc.
   *
   * @route GET /api/content/page/:url
   * @mapeo secciones.php
   */
  @Get('page/:url')
  async getPage(@Param('url') url: string)
```

| | |
|---|---|
| **Método** | `GET` |
| **Ruta** | `/api/content/page/:url` |
| **Auth** | Público |
| **Response 200** | `{ titulo, url, contenido, secciones: [{ titulo?, contenido, orden }] }` |
| **Response 404** | `{ message: "Página no encontrada" }` |

### 12.5 Redes Sociales

```typescript
  /**
   * Obtener links de redes sociales.
   *
   * @route GET /api/content/social
   */
  @Get('social')
  async getSocialLinks()
```

| | |
|---|---|
| **Método** | `GET` |
| **Ruta** | `/api/content/social` |
| **Auth** | Público |
| **Response 200** | `[{ red, link, icono? }]` |

### 12.6 Home Layout

```typescript
  /**
   * Obtener orden de módulos del home.
   *
   * @route GET /api/content/home-layout
   */
  @Get('home-layout')
  async getHomeLayout()
```

| | |
|---|---|
| **Método** | `GET` |
| **Ruta** | `/api/content/home-layout` |
| **Auth** | Público |
| **Response 200** | `{ modulos: [{ tipo: 'slider' \| 'categorias' \| 'productos' \| 'banners' \| 'carousel', config: object, orden: number }] }` |

---

## 13. Contact API — Contacto y Devoluciones

> **Módulo:** `ContactModule`
> **Controllers:** `ContactPublicController`, `DevolutionsPublicController`
> **Mapeo PHP:** `routes/contacto.php`, `routes/devoluciones.php`

### 13.1 Enviar Mensaje de Contacto

```typescript
@Controller('contact')
export class ContactPublicController {

  /**
   * Enviar formulario de contacto.
   * Validación reCAPTCHA v3 si está configurado.
   *
   * @route POST /api/contact
   * @mapeo contacto.php
   */
  @Post()
  async sendMessage(@Body() dto: ContactMessageDto)
```

| | |
|---|---|
| **Método** | `POST` |
| **Ruta** | `/api/contact` |
| **Auth** | Público |
| **Body** | `{ nombre, email, telefono?, areaId, mensaje, recaptchaToken? }` |
| **Response 201** | `{ message: "Mensaje enviado correctamente" }` |
| **Response 422** | `{ message: "Verificación reCAPTCHA fallida" }` |

### 13.2 Listar Áreas de Contacto

```typescript
  /**
   * Listar áreas de contacto disponibles.
   *
   * @route GET /api/contact/areas
   */
  @Get('areas')
  async getAreas()
```

| | |
|---|---|
| **Método** | `GET` |
| **Ruta** | `/api/contact/areas` |
| **Auth** | Público |
| **Response 200** | `[{ id, area }]` |

### 13.3 Solicitar Devolución

```typescript
@Controller('devolutions')
export class DevolutionsPublicController {

  /**
   * Enviar solicitud de devolución.
   * Condicionado por configuracion.formulario_devoluciones.
   *
   * @route POST /api/devolutions
   * @mapeo devoluciones.php
   */
  @Post()
  async requestReturn(@Body() dto: ReturnRequestDto)
```

| | |
|---|---|
| **Método** | `POST` |
| **Ruta** | `/api/devolutions` |
| **Auth** | Público |
| **Body** | `{ nombre, apellido, email, area, telefono, compraId?, mensaje, recaptchaToken? }` |
| **Response 201** | `{ message: "Solicitud de devolución enviada" }` |
| **Response 404** | `{ message: "Formulario de devoluciones no disponible" }` (si config desactivado) |
| **Notas** | Validar `formulario_devoluciones` en tenant config. |

---

## 14. Admin API — Panel de Administración

> **Módulo:** `AdminModule`
> **Auth:** JWT Admin con `role='admin'` + `permissions[]`
> **Mapeo PHP:** 119 archivos en `admin/routes/`, `admin/ajax/`

### 14.1 Autenticación Admin

```typescript
@Controller('admin/auth')
export class AdminAuthController {

  /**
   * Login de administrador.
   * Rate limit: 3 intentos cada 15 minutos.
   *
   * @route POST /api/admin/auth/login
   * @mapeo admin/login.php
   */
  @Post('login')
  @Throttle({ default: { limit: 3, ttl: 900000 } })
  async login(@Body() dto: AdminLoginDto, @Res({ passthrough: true }) res: Response)
```

| | |
|---|---|
| **Método** | `POST` |
| **Ruta** | `/api/admin/auth/login` |
| **Auth** | Público |
| **Body** | `{ email, password }` |
| **Response 200** | `{ accessToken, refreshToken, admin: { id, nombre, email, tipo, home, permissions[] } }` |
| **Response 401** | `{ message: "Credenciales inválidas" }` |
| **Notas** | **bcrypt** (migrar de texto plano). Carga `permissions` desde `administradores_tipos_permisos`. |

### 14.2 Dashboard

```typescript
@Controller('admin/dashboard')
export class AdminDashboardController {

  /**
   * KPIs del dashboard.
   *
   * @route GET /api/admin/dashboard
   * @mapeo admin/routes/dashboard.php
   */
  @Get()
  @UseGuards(JwtAdminGuard)
  async getDashboard(@Query('mes') mes?: string, @Query('anio') anio?: string)
```

| | |
|---|---|
| **Método** | `GET` |
| **Ruta** | `/api/admin/dashboard` |
| **Auth** | Admin JWT |
| **Query** | `mes` (1-12), `anio` (YYYY) |
| **Response 200** | `{ ventasMes: number, ventasMesAnterior: number, variacion: number, cantidadPedidos: number, ticketPromedio: number, clientesNuevos: number, productosMasVendidos: [{ id, nombre, cantidad }] }` |

### 14.3 CRUD Productos (Admin)

```typescript
@Controller('admin/products')
@UseGuards(JwtAdminGuard)
export class AdminProductsController {

  // GET    /api/admin/products              → Listar (DataTable con filtros)
  // GET    /api/admin/products/:id           → Obtener producto completo
  // POST   /api/admin/products               → Crear producto
  // PUT    /api/admin/products/:id           → Editar producto
  // DELETE /api/admin/products/:id           → Soft delete
  // POST   /api/admin/products/:id/fotos     → Subir fotos
  // DELETE /api/admin/products/:id/fotos/:fotoId → Eliminar foto
  
  // GET    /api/admin/products/:id/variants  → Listar variantes
  // POST   /api/admin/products/:id/variants  → Crear variante
  // PUT    /api/admin/products/:id/variants/:vid → Editar variante
  // DELETE /api/admin/products/:id/variants/:vid → Soft delete variante
  
  // GET    /api/admin/products/:id/stock     → Ver stock por sucursal
  // PUT    /api/admin/products/:id/stock     → Actualizar stock masivo
  
  // GET    /api/admin/products/:id/prices    → Ver precios por lista
  // PUT    /api/admin/products/:id/prices    → Actualizar precios masivo
  
  // POST   /api/admin/products/import-excel  → Importar productos (Fase 2)
  // GET    /api/admin/products/export-excel  → Exportar productos (Fase 2)
}
```

**Mapeo de archivos PHP admin:**
| Endpoint NestJS | PHP Admin |
|---|---|
| `GET /api/admin/products` | `productos.php` |
| `POST /api/admin/products` | `productos_new.php` |
| `PUT /api/admin/products/:id` | `productos_edit.php` |
| `GET/POST /api/admin/products/:id/variants` | `productos_variantes.php` |
| `GET /api/admin/products/:id/stock` | `productos_stock.php` |
| `POST /api/admin/products/import-excel` | `importar_productos.php` / `productos_excel.php` |
| `GET /api/admin/products/export-excel` | `productos_excel_exportar.php` |

### 14.4 CRUD Pedidos (Admin)

```typescript
@Controller('admin/orders')
@UseGuards(JwtAdminGuard)
export class AdminOrdersController {

  // GET    /api/admin/orders                 → Listar (DataTable con filtros avanzados)
  // GET    /api/admin/orders/:id             → Detalle completo (vista)
  // POST   /api/admin/orders                 → Crear pedido manual
  // PUT    /api/admin/orders/:id             → Editar pedido
  // PATCH  /api/admin/orders/:id/status      → Cambiar estados
  
  // GET    /api/admin/orders/search-client?q= → Buscar cliente (AJAX)
  // GET    /api/admin/orders/search-product?q= → Buscar producto (AJAX)
  // GET    /api/admin/orders/client-data/:clientId → Datos de cliente
}
```

### 14.5 CRUD Clientes (Admin)

```typescript
@Controller('admin/customers')
@UseGuards(JwtAdminGuard)
export class AdminCustomersController {

  // GET    /api/admin/customers              → Listar (filtro tipo: clientes/prospectos)
  // GET    /api/admin/customers/:id          → Vista unificada (pedidos + direcciones + datos)
  // POST   /api/admin/customers              → Crear
  // PUT    /api/admin/customers/:id          → Editar
  
  // CRUD de tipos de cliente:
  // GET/POST/PUT/DELETE /api/admin/customer-types
  // GET/POST/PUT/DELETE /api/admin/customer-types/comprobantes
  // GET/POST/PUT/DELETE /api/admin/customer-situations
}
```

### 14.6 CRUD Administradores (Admin)

```typescript
@Controller('admin/users')
@UseGuards(JwtAdminGuard)
@RequirePermission('usuarios')
export class AdminUsersController {

  // GET    /api/admin/users                 → Listar administradores
  // POST   /api/admin/users                 → Crear (bcrypt)
  // PUT    /api/admin/users/:id             → Editar
  
  // GET/POST/PUT/DELETE /api/admin/user-types       → Tipos de admin
  // GET/PUT              /api/admin/user-types/:id/permissions → Asignar permisos
}
```

### 14.7 Configuración General (Admin)

```typescript
@Controller('admin/config')
@UseGuards(JwtAdminGuard)
export class AdminConfigController {

  // GET    /api/admin/config                   → Obtener toda la configuración tipada
  // PUT    /api/admin/config/business           → Config de negocio
  // PUT    /api/admin/config/payments           → Config de pagos (sin secretos)
  // PUT    /api/admin/config/shipping           → Config de envíos
  // PUT    /api/admin/config/theme              → Estilos visuales
  // PUT    /api/admin/config/web                → Config web (reCAPTCHA keys, redes)
  
  // POST   /api/admin/config/logos              → Subir logos
  // POST   /api/admin/config/favicon            → Subir favicon
  
  // GET    /api/admin/config/email-templates    → Listar plantillas de email
  // GET    /api/admin/config/email-templates/:id → Ver plantilla
  // PUT    /api/admin/config/email-templates/:id → Editar plantilla (con placeholders)
}
```

**Mapeo PHP admin:**
| NestJS | PHP |
|---|---|
| `GET /api/admin/config` | `configuracion.php` (panel pestañeado) |
| `PUT /api/admin/config/theme` | `configuracion_grafica.php` |
| `POST /api/admin/config/logos` | `logos.php` |
| `PUT /api/admin/config/email-templates/:id` | `emails_plantillas_edit.php` |

### 14.8 Búsqueda Global (Admin)

```typescript
@Controller('admin/search')
@UseGuards(JwtAdminGuard)
export class AdminSearchController {

  /**
   * Búsqueda unificada en admin: productos, pedidos, clientes.
   *
   * @route GET /api/admin/search
   * @mapeo global_search.php
   */
  @Get()
  async globalSearch(@Query('q') q: string)
```

| | |
|---|---|
| **Método** | `GET` |
| **Ruta** | `/api/admin/search` |
| **Auth** | Admin JWT |
| **Query** | `q` (texto, min 2 caracteres) |
| **Response 200** | `{ productos: [...], pedidos: [...], clientes: [...] }` |

### 14.9 Resto de CRUDs Admin

Los siguientes CRUDs siguen el patrón REST estándar (`GET list, GET :id, POST, PUT :id, DELETE :id`):

```
/api/admin/categories        → CRUD categorías (nestable, reordenar)
/api/admin/brands             → CRUD marcas
/api/admin/tags               → CRUD tags (reordenar)
/api/admin/properties         → CRUD propiedades + valores
/api/admin/shipping/methods   → CRUD envíos propios
/api/admin/shipping/sucursales → CRUD sucursales
/api/admin/shipping/config    → Envío gratis, compra mínima
/api/admin/coupons            → CRUD cupones
/api/admin/promotions         → CRUD promociones
/api/admin/content/slider     → CRUD slider (reordenar)
/api/admin/content/banners    → CRUD banners
/api/admin/content/faq         → CRUD FAQ (reordenar)
/api/admin/content/sections    → CRUD secciones adicionales
/api/admin/content/social      → CRUD redes sociales
/api/admin/content/reviews     → CRUD reseñas
/api/admin/content/home-order  → Orden de módulos home
/api/admin/contact             → Bandeja de mensajes
/api/admin/contact/areas       → CRUD áreas de contacto
/api/admin/devolutions         → Solicitudes de devolución
/api/admin/integration/padpio/stock  → Sincronizar stock (Fase 2)
/api/admin/integration/padpio/prices → Sincronizar precios (Fase 2)
```

---

## 15. Geo API — Geolocalización

> **Módulo:** `CommonModule`
> **Controller:** `GeoController`
> **Mapeo PHP:** `ajax/localidades.php`, `ajax/cp.php`, `ajax/localidades_con_cp.php`, `ajax/provincias_con_localidad.php`

### 15.1 Lista de Provincias

```typescript
@Controller('geo')
export class GeoController {

  /**
   * Listar todas las provincias.
   *
   * @route GET /api/geo/provincias
   * @mapeo provincias_con_localidad.php
   */
  @Get('provincias')
  async getProvincias()
```

| | |
|---|---|
| **Método** | `GET` |
| **Ruta** | `/api/geo/provincias` |
| **Auth** | Público |
| **Response 200** | `[{ id, nombre }]` |

### 15.2 Localidades por Provincia

```typescript
  /**
   * Listar localidades de una provincia.
   *
   * @route GET /api/geo/localidades
   * @mapeo localidades.php + localidades_con_cp.php
   */
  @Get('localidades')
  async getLocalidades(@Query('provinciaId') provinciaId: number)
```

| | |
|---|---|
| **Método** | `GET` |
| **Ruta** | `/api/geo/localidades` |
| **Auth** | Público |
| **Query** | `provinciaId` |
| **Response 200** | `[{ id, nombre, cp }]` |

### 15.3 Buscar por Código Postal

```typescript
  /**
   * Buscar localidad y provincia por CP.
   *
   * @route GET /api/geo/codigos-postales/:cp
   * @mapeo cp.php
   */
  @Get('codigos-postales/:cp')
  async getByCp(@Param('cp') cp: string)
```

| | |
|---|---|
| **Método** | `GET` |
| **Ruta** | `/api/geo/codigos-postales/:cp` |
| **Auth** | Público |
| **Response 200** | `{ cp, localidad: { id, nombre }, provincia: { id, nombre } }` |
| **Response 404** | `{ message: "Código postal no encontrado" }` |

---

## 16. Webhooks — Endpoints de Proveedores

> **Módulo:** `PaymentsModule` + `ShippingModule`
> **Seguridad:** Validación por firma criptográfica (no JWT)
> **Excluidos de CSRF:** `@SkipCsrf()`

### 16.1 Webhook MercadoPago

```typescript
@Controller('webhooks')
export class WebhookController {

  /**
   * IPN de MercadoPago.
   * Validación: header x-signature con webhook secret.
   *
   * @route POST /api/webhooks/mercadopago
   * @mapeo connect/mp_ipn.php
   */
  @Post('mercadopago')
  @SkipCsrf()
  async mercadoPagoWebhook(
    @Body() payload: any,
    @Headers('x-signature') signature: string,
    @Headers('x-request-id') requestId: string,
  )
```

| | |
|---|---|
| **Método** | `POST` |
| **Ruta** | `/api/webhooks/mercadopago` |
| **Auth** | Validación `x-signature` con `MERCADOPAGO_WEBHOOK_SECRET` |
| **Body** | `{ pedido_id, order_status }` (y otros campos de MP) |
| **Response 200** | `{ status: 'ok' }` |
| **Response 401** | `{ message: "Firma inválida" }` |
| **Acciones** | `paid` → actualizar estado, enviar emails, descontar stock, confirmar Zipnova. `reverted` → reponer stock, marcar reintegrado. |

### 16.2 Webhook Modo

```typescript
  /**
   * Webhook de Modo.
   *
   * @route POST /api/webhooks/modo
   * @mapeo connect/modo_webhook.php
   */
  @Post('modo')
  @SkipCsrf()
  async modoWebhook(@Body() payload: any, @Headers('x-modo-signature') signature: string)
```

| | |
|---|---|
| **Método** | `POST` |
| **Ruta** | `/api/webhooks/modo` |
| **Auth** | Validación de firma Modo |
| **Body** | `{ pedido_id (hash), order_status }` |
| **Notas** | Busca pedido por `hash`. Actualiza `estado_pago`. Envía emails. Descuenta stock. |

### 16.3 Webhook Zipnova (Tracking)

```typescript
  /**
   * Webhook de tracking de Zipnova.
   * ⚠️ CORREGIR BUG: usar variable real, no literal 'estado'.
   *
   * @route POST /api/webhooks/zipnova
   * @mapeo connect/zn_webhook.php
   */
  @Post('zipnova')
  @SkipCsrf()
  async zipnovaWebhook(@Body() payload: ZipnovaWebhookDto)
```

| | |
|---|---|
| **Método** | `POST` |
| **Ruta** | `/api/webhooks/zipnova` |
| **Auth** | Validación de firma Zipnova |
| **Body** | `{ pedido_id: number, estado: string }` |
| **Response 200** | `{ status: 'ok' }` |
| **Notas** | `UPDATE pedidos SET estado_entrega = :estado WHERE Id = :pedidoId`. **Usar variable correcta, no literal.** |

---

## 17. Esquemas de Respuesta y Error

### 17.1 Respuesta Exitosa (Envelope)

```typescript
// Éxito con datos
{
  "success": true,
  "data": { ... },                   // Payload
  "meta": {                          // Opcional — paginación
    "page": 1,
    "limit": 24,
    "total": 150,
    "totalPages": 7
  }
}

// Éxito 201 Created
{
  "success": true,
  "data": { id: 42, ... },
  "message": "Producto creado correctamente"
}

// Éxito 204 No Content
HTTP 204 (sin body)
```

### 17.2 Error de Validación (400)

```typescript
{
  "success": false,
  "statusCode": 400,
  "message": "Error de validación",
  "errors": [
    {
      "field": "email",
      "value": "no-es-email",
      "constraints": {
        "isEmail": "Debe proporcionar un email válido"
      }
    },
    {
      "field": "password",
      "value": "123",
      "constraints": {
        "minLength": "La contraseña debe tener al menos 8 caracteres"
      }
    }
  ],
  "timestamp": "2026-06-08T16:58:00.000Z",
  "path": "/api/auth/register"
}
```

### 17.3 Error de Negocio (409/422)

```typescript
// Conflicto (409)
{
  "success": false,
  "statusCode": 409,
  "message": "Stock insuficiente",
  "details": {
    "producto": "Zapatilla Runner",
    "stockDisponible": 2,
    "cantidadSolicitada": 5
  },
  "timestamp": "2026-06-08T16:58:00.000Z",
  "path": "/api/cart/items"
}

// Error de negocio (422)
{
  "success": false,
  "statusCode": 422,
  "message": "Cupón inválido o vencido",
  "timestamp": "2026-06-08T16:58:00.000Z",
  "path": "/api/cart/coupon"
}
```

### 17.4 Error de Autenticación (401)

```typescript
{
  "success": false,
  "statusCode": 401,
  "message": "Token inválido o expirado",
  "timestamp": "2026-06-08T16:58:00.000Z",
  "path": "/api/orders"
}
```

### 17.5 Error de Autorización (403)

```typescript
{
  "success": false,
  "statusCode": 403,
  "message": "No tenés permisos para acceder a esta sección",
  "timestamp": "2026-06-08T16:58:00.000Z",
  "path": "/api/admin/products"
}
```

### 17.6 Rate Limit (429)

```typescript
{
  "success": false,
  "statusCode": 429,
  "message": "Demasiadas solicitudes. Intente de nuevo en unos segundos.",
  "timestamp": "2026-06-08T16:58:00.000Z",
  "path": "/api/auth/login"
}
// Headers: Retry-After: 60, X-RateLimit-Limit: 5, X-RateLimit-Remaining: 0
```

### 17.7 Error Interno (500)

```typescript
{
  "success": false,
  "statusCode": 500,
  "message": "Error interno del servidor",
  "timestamp": "2026-06-08T16:58:00.000Z",
  "path": "/api/products"
}
// En desarrollo: incluye stack trace. En producción: solo mensaje genérico.
```

---

## Resumen de Endpoints MVP

| # | Método | Ruta | Módulo | Auth | PHP Actual |
|---|---|---|---|---|---|
| 1 | `POST` | `/api/auth/login` | Auth | Público | `account_signin.php` |
| 2 | `POST` | `/api/auth/register` | Auth | Público | `account_register.php` |
| 3 | `POST` | `/api/auth/activate/:hash` | Auth | Público | `account_activate.php` |
| 4 | `POST` | `/api/auth/recover` | Auth | Público | `account_recover.php` |
| 5 | `POST` | `/api/auth/recover/:hash` | Auth | Público | `account_password_recover.php` |
| 6 | `POST` | `/api/auth/refresh` | Auth | Cookie | *(nuevo)* |
| 7 | `POST` | `/api/auth/logout` | Auth | JWT | `logout.php` |
| 8 | `GET` | `/api/users/me` | Users | JWT | `account_profile.php` |
| 9 | `PATCH` | `/api/users/me` | Users | JWT | `account_profile.php` |
| 10 | `PATCH` | `/api/users/me/company` | Users | JWT | `account_company.php` |
| 11 | `PUT` | `/api/users/me/password` | Users | JWT | *(nuevo)* |
| 12 | `GET` | `/api/users/me/addresses` | Users | JWT | `account_addresses.php` |
| 13 | `POST` | `/api/users/me/addresses` | Users | JWT | `account_addresses.php` |
| 14 | `PUT` | `/api/users/me/addresses/:id` | Users | JWT | `account_addresses.php` |
| 15 | `DELETE` | `/api/users/me/addresses/:id` | Users | JWT | `account_addresses.php` |
| 16 | `GET` | `/api/users/me/wishlist` | Users | JWT | `account_wish_list.php` |
| 17 | `POST` | `/api/users/me/wishlist/:productId` | Users | JWT | `ajax/favoritos.php` |
| 18 | `GET` | `/api/products` | Products | Opcional | `productos.php` |
| 19 | `GET` | `/api/products/:url` | Products | Opcional | `producto.php` |
| 20 | `GET` | `/api/products/:url/related` | Products | Público | *(parte de producto.php)* |
| 21 | `GET` | `/api/products/search` | Products | Público | *(nuevo endpoint dedicado)* |
| 22 | `GET` | `/api/categories` | Categories | Público | *(nuevo)* |
| 23 | `GET` | `/api/categories/:url` | Categories | Público | *(nuevo)* |
| 24 | `GET` | `/api/brands` | Brands | Opcional | *(nuevo)* |
| 25 | `GET` | `/api/cart` | Cart | Opcional | `cart.php` |
| 26 | `POST` | `/api/cart/items` | Cart | Opcional | `agregarcarrito.php` |
| 27 | `PATCH` | `/api/cart/items/:pid/:vid` | Cart | Opcional | `cart.php` |
| 28 | `DELETE` | `/api/cart/items/:pid/:vid` | Cart | Opcional | `cart.php` |
| 29 | `DELETE` | `/api/cart` | Cart | Opcional | `cart.php` |
| 30 | `POST` | `/api/cart/coupon` | Cart | Opcional | `cupon.php` |
| 31 | `DELETE` | `/api/cart/coupon` | Cart | Opcional | *(nuevo)* |
| 32 | `GET` | `/api/cart/summary` | Cart | Opcional | *(nuevo)* |
| 33 | `GET` | `/api/checkout` | Checkout | Opcional | `checkout_1.php` |
| 34 | `POST` | `/api/checkout/step/1` | Checkout | Opcional | `checkout_1.php` |
| 35 | `POST` | `/api/checkout/step/2` | Checkout | Opcional | `checkout_2.php` |
| 36 | `POST` | `/api/checkout/step/3` | Checkout | Opcional | `checkout_3.php` |
| 37 | `POST` | `/api/checkout/confirm` | Checkout | Opcional | `checkout_4.php` |
| 38 | `POST` | `/api/checkout/validate-stock` | Checkout | Opcional | *(nuevo)* |
| 39 | `GET` | `/api/orders` | Orders | JWT | `account_orders.php` |
| 40 | `GET` | `/api/orders/:hash` | Orders | JWT | `account_order.php` |
| 41 | `POST` | `/api/orders/:hash/repeat` | Orders | JWT | `acciones/repetir_compra.php` |
| 42 | `POST` | `/api/orders/:hash/resume` | Orders | Público | `acciones/retomar_compra.php` |
| 43 | `POST` | `/api/payments/mercadopago/init` | Payments | JWT | *(checkout_4.php)* |
| 44 | `POST` | `/api/payments/comprobante/:hash` | Payments | Público | `comprobantes.php` |
| 45 | `GET` | `/api/payments/status/:hash` | Payments | Opcional | *(nuevo)* |
| 46 | `GET` | `/api/shipping/options` | Shipping | Opcional | `checkout_2_envio.php` |
| 47 | `POST` | `/api/shipping/quote` | Shipping | Opcional | `cotizar_envio_con_cp.php` |
| 48 | `GET` | `/api/shipping/sucursales` | Shipping | Público | *(nuevo)* |
| 49 | `GET` | `/api/shipping/tracking/:hash` | Shipping | Público | *(nuevo)* |
| 50 | `GET` | `/api/content/slider` | Content | Público | *(home.php)* |
| 51 | `GET` | `/api/content/banners` | Content | Público | *(home.php)* |
| 52 | `GET` | `/api/content/faq` | Content | Público | `preguntas-frecuentes.php` |
| 53 | `GET` | `/api/content/page/:url` | Content | Público | `secciones.php` |
| 54 | `GET` | `/api/content/social` | Content | Público | *(footer)* |
| 55 | `GET` | `/api/content/home-layout` | Content | Público | *(home.php)* |
| 56 | `POST` | `/api/contact` | Contact | Público | `contacto.php` |
| 57 | `GET` | `/api/contact/areas` | Contact | Público | *(contacto.php)* |
| 58 | `POST` | `/api/devolutions` | Contact | Público | `devoluciones.php` |
| 59 | `POST` | `/api/admin/auth/login` | Admin | Público | `admin/login.php` |
| 60 | `GET` | `/api/admin/dashboard` | Admin | Admin JWT | `dashboard.php` |
| 61 | `GET/POST/PUT/DELETE` | `/api/admin/products...` | Admin | Admin JWT | 12 archivos PHP |
| 62 | `GET/POST/PUT/DELETE` | `/api/admin/orders...` | Admin | Admin JWT | 5 archivos PHP |
| 63 | `GET/POST/PUT/DELETE` | `/api/admin/customers...` | Admin | Admin JWT | 8 archivos PHP |
| 64 | CRUDs | `/api/admin/{categories,brands,tags,...}` | Admin | Admin JWT | ~50 archivos PHP |
| 65 | `GET/PUT` | `/api/admin/config` | Admin | Admin JWT | 13 archivos PHP |
| 66 | `GET` | `/api/admin/search` | Admin | Admin JWT | `global_search.php` |
| 67 | `GET` | `/api/geo/provincias` | Common | Público | `provincias_con_localidad.php` |
| 68 | `GET` | `/api/geo/localidades` | Common | Público | `localidades.php` |
| 69 | `GET` | `/api/geo/codigos-postales/:cp` | Common | Público | `cp.php` |
| 70 | `POST` | `/api/webhooks/mercadopago` | Payments | Firma | `mp_ipn.php` |
| 71 | `POST` | `/api/webhooks/modo` | Payments | Firma | `modo_webhook.php` |
| 72 | `POST` | `/api/webhooks/zipnova` | Shipping | Firma | `zn_webhook.php` |

**Total: ~72 endpoints MVP** (sin contar los ~50 endpoints de CRUD admin que se detallan por patrón).

---

## Mapeo de Rutas PHP → NestJS (Quick Reference)

| URL/Ruta PHP Actual | NestJS Endpoint | Tipo de Cambio |
|---|---|---|
| `/productos` | `GET /api/products` | Query params en vez de URL mágicas |
| `/producto/{url}` | `GET /api/products/:url` | Sin cambio |
| `/categoria/{url}` | `GET /api/products?categoriaSlug={url}` | Unificado en products |
| `/marca/{url}` | `GET /api/products?marcaSlug={url}` | Unificado en products |
| `/tag/{url}` | `GET /api/products?tagSlug={url}` | Unificado en products |
| `/cart` | `GET /api/cart` | REST |
| `/checkout/1-4` | `/api/checkout/*` | Stateful single-page |
| `/login` → `account_signin` | `POST /api/auth/login` | JWT stateless |
| `/account_register` | `POST /api/auth/register` | bcrypt en vez de md5 |
| `/account_activate/{hash}` | `POST /api/auth/activate/:hash` | POST en vez de GET (idempotencia) |
| `/account_recover` | `POST /api/auth/recover` | Token con expiración |
| `/account_profile` | `GET/PATCH /api/users/me` | REST |
| `/account_addresses` | `/api/users/me/addresses` | REST anidado |
| `/account_orders` | `GET /api/orders` | REST |
| `/account_wish_list` | `GET /api/users/me/wishlist` | REST |
| `/comprobantes/{hash}` | `POST /api/payments/comprobante/:hash` | REST |
| `/preguntas-frecuentes` | `GET /api/content/faq` | REST |
| `ajax/agregarcarrito.php` | `POST /api/cart/items` | Validación server-side mantenida |
| `ajax/favoritos.php` | `POST /api/users/me/wishlist/:id` | Toggle REST |
| `ajax/cotizar_envio_con_cp.php` | `POST /api/shipping/quote` | REST |
| `ajax/localidades.php` + `cp.php` + etc | `/api/geo/*` | Unificado en GeoController |
| `connect/mp_ipn.php` | `POST /api/webhooks/mercadopago` | **+validación de firma** |
| `connect/modo_webhook.php` | `POST /api/webhooks/modo` | **+validación de firma** |
| `connect/zn_webhook.php` | `POST /api/webhooks/zipnova` | **+corrección de bug** |

---

> **Confianza global de este documento:** ALTA. Todos los endpoints están basados en las funcionalidades documentadas en el discovery del sistema PHP actual, priorizadas para MVP por el Product Owner. Las rutas, métodos HTTP, cuerpos de request y respuestas reflejan exactamente lo que el sistema hace hoy, adaptado a REST y las mejoras de seguridad definidas en `01-security-nestjs-config.md`.
>
> **Lo que ES hecho (del auditor):** funcionalidades del sistema actual, parámetros requeridos, flujos de negocio, comportamiento de cada endpoint PHP.
> **Lo que ES diseño (de este documento):** mapeo a REST, DTOs con class-validator, response envelopes, rate limits, estructura de rutas NestJS.
> **Lo que ES decisión de API design:** rutas REST anidadas vs planas, POST vs GET para ciertas operaciones, unificación de endpoints de catálogo, estructura de respuestas.

---

*Documento preparado por el Backend Architect basado en los outputs del System Auditor (2026-06-04), Product Owner (2026-06-08) y Security Agent (2026-06-08).*
