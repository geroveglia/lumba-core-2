# 01 — Arquitectura Backend NestJS

> **Proyecto:** Lumba Ecommerce (Brownfield — migración PHP vanilla → NestJS + Tailwind)
> **Fecha:** 2026-06-08
> **Rol:** Backend Architect
> **Modelo:** deepseek-v4-pro
> **Nivel de confianza global:** ALTA (diseño basado en outputs del System Auditor, Product Owner y Security Agent)
> **Fuentes:** `01-discovery-sistema-actual.md`, `01-modelo-datos-actual.md`, `01-flujos-negocio.md`, `01-integraciones.md`, `01-functional-spec.md`, `01-feature-prioritization.md`, `01-gaps-and-improvements.md`, `01-security-nestjs-config.md`

---

## Índice

1. [Principios de Arquitectura](#1-principios-de-arquitectura)
2. [Estructura de Módulos](#2-estructura-de-módulos)
3. [Diseño por Módulo](#3-diseño-por-módulo)
   - [CommonModule](#31-commonmodule)
   - [TenantModule](#32-tenantmodule)
   - [AuthModule](#33-authmodule)
   - [UsersModule](#34-usersmodule)
   - [ProductsModule](#35-productsmodule)
   - [CategoriesModule](#36-categoriesmodule)
   - [BrandsModule](#37-brandsmodule)
   - [TagsModule](#38-tagsmodule)
   - [CartModule](#39-cartmodule)
   - [CheckoutModule](#310-checkoutmodule)
   - [OrdersModule](#311-ordersmodule)
   - [PaymentsModule](#312-paymentsmodule)
   - [ShippingModule](#313-shippingmodule)
   - [AdminModule](#314-adminmodule)
   - [CouponsModule](#315-couponsmodule)
   - [PromotionsModule](#316-promotionsmodule)
   - [ContentModule](#317-contentmodule)
   - [ReviewsModule](#318-reviewsmodule)
   - [ContactModule](#319-contactmodule)
   - [ChatModule](#320-chatmodule-post-mvp)
   - [SurveysModule](#321-surveysmodule-post-mvp)
   - [IntegrationModule](#322-integrationmodule)
4. [Diseño Transversal](#4-diseño-transversal)
5. [Diagrama de Dependencias](#5-diagrama-de-dependencias)
6. [Estrategia Multi-Tenant](#6-estrategia-multi-tenant)
7. [Mapeo: PHP Actual → NestJS](#7-mapeo-php-actual--nestjs)

---

## 1. Principios de Arquitectura

### Decisiones arquitectónicas clave

| Decisión | Elección | Justificación (basada en evidencia del sistema actual) |
|---|---|---|
| **ORM** | TypeORM | Migraciones versionadas. Soporte para soft deletes (`@DeleteDateColumn()`), transacciones (`@Transaction()`), multi-conexión (multi-tenant). El sistema actual tiene ~20 tablas MySQL con soft deletes ubicuos. |
| **Base de datos** | MySQL (mantener) | Los datos ya existen en MySQL. Migrar a PostgreSQL sería costo sin beneficio inmediato (ver `01-gaps-and-improvements.md` §4.2). Se puede evaluar post-MVP. |
| **Autenticación** | JWT + Passport (stateless) | Reemplaza sesiones PHP. Access token 15 min, refresh token 7 días en cookie HTTP-only. El sistema actual usa `$_SESSION` con md5. |
| **Validación** | class-validator + class-transformer | ValidationPipe global con whitelist estricta. El sistema actual no tiene validación tipada. |
| **Cache** | Redis | Para queries de catálogo, sesiones de checkout, rate limiting distribuido. |
| **Job queue** | BullMQ (Redis) | Sincronización PadPio, carritos abandonados, emails asíncronos. El sistema actual usa cron del SO y botones manuales. |
| **Email** | Nodemailer + Handlebars | Templates compilados. Cola con reintentos. El sistema actual usa PHPMailer con plantillas `{{VAR}}`. |
| **Logging** | Winston | Structured JSON logs con redacción de datos sensibles. El sistema actual no tiene logging. |
| **API Docs** | Swagger (`@nestjs/swagger`) | Auto-generado de decoradores. Documentación viva. |
| **Multi-tenant** | DB por tenant + resolución por dominio | Mantiene el modelo de aislamiento actual (DB separada por cliente) pero reemplaza branches Git por variable de entorno. Ver §6. |

### Estructura de capas por módulo

```
src/modules/{nombre}/
├── {nombre}.module.ts          # Definición del módulo NestJS
├── controllers/                # Controllers HTTP (solo rutas y status codes)
│   ├── {nombre}.controller.ts
│   └── dto/                    # DTOs de request/response
├── services/                   # Lógica de negocio
│   └── {nombre}.service.ts
├── entities/                   # Entidades TypeORM
│   └── {nombre}.entity.ts
├── repositories/               # Repositorios (opcional, TypeORM provee repos base)
├── guards/                     # Guards específicos del módulo
└── interfaces/                 # Interfaces y tipos
```

**Regla de oro:** Los controllers nunca contienen lógica de negocio. Solo delegan en services y retornan DTOs. Los services son la única fuente de verdad para la lógica de negocio.

---

## 2. Estructura de Módulos

### 2.1 Árbol de módulos completo

```
AppModule
├── ConfigModule (global)         # @nestjs/config con validación tipada
├── TypeOrmModule (global)        # Conexión MySQL dinámica por tenant
├── ThrottlerModule (global)      # Rate limiting multi-nivel
├── ScheduleModule (global)       # @nestjs/schedule para cron jobs
├── CommonModule (global)         # Utilidades compartidas (mail, upload, pdf, geo)
├── TenantModule (global)         # Resolución de tenant + configuración tipada
│
├── AuthModule                    # Login, registro, recuperación, JWT, activación
│   └── (importa UsersModule)
├── UsersModule                   # Perfil, direcciones, empresa, wishlist, tipos
├── ProductsModule                # Catálogo, grilla, filtros, búsqueda, detalle
│   ├── (importa CategoriesModule)
│   ├── (importa BrandsModule)
│   └── (importa TagsModule)
├── CategoriesModule              # Jerarquía de categorías (árbol)
├── BrandsModule                  # Marcas
├── TagsModule                    # Etiquetas con colores y orden
├── InventoryModule               # Variantes, stock, precios, propiedades
├── CartModule                    # Carrito persistente, validación server-side
│   ├── (importa ProductsModule)
│   ├── (importa CouponsModule)
│   └── (importa PromotionsModule)
├── CheckoutModule                # Flujo de compra 4 pasos
│   ├── (importa CartModule)
│   ├── (importa ShippingModule)
│   ├── (importa PaymentsModule)
│   └── (importa UsersModule)
├── OrdersModule                  # Pedidos, estados, historial, detalle
├── PaymentsModule                # MercadoPago, Modo, Transferencia, Efectivo, webhooks
│   ├── strategies/               # Strategy pattern por medio de pago
│   └── webhooks/                 # Endpoints de IPN/webhook con validación de firma
├── ShippingModule                # Sucursal, envío propio, Zipnova, tracking
├── AdminModule                   # Dashboard, CRUDs, gestión, configuración
│   ├── (importa TODOS los módulos — es el backoffice)
│   └── admin/                    # Sub-módulos por área de admin
├── CouponsModule                 # Cupones de descuento
├── PromotionsModule              # Promociones automáticas y manuales
├── ContentModule                 # Banners, sliders, FAQ, páginas estáticas, secciones
├── ReviewsModule                 # Reseñas y testimonios
├── ContactModule                 # Formulario de contacto
├── DevolutionsModule             # Devoluciones
├── ChatModule (Post-MVP)         # Chatbot IA con OpenAI
├── SurveysModule (Post-MVP)      # Encuestas
└── IntegrationModule             # PadPio, Dicomere, APIs externas
```

### 2.2 Clasificación por tipo de módulo

| Tipo | Módulos | Característica |
|---|---|---|
| **Core** | Common, Tenant | Importados por todos. Utilidades transversales. |
| **Dominio** | Products, Categories, Brands, Tags, Inventory | Catálogo y datos maestros. |
| **Transaccional** | Cart, Checkout, Orders, Payments, Shipping | Flujo de compra. Alta cohesión entre sí. |
| **Identidad** | Auth, Users | Autenticación y perfil de usuario. |
| **Marketing** | Coupons, Promotions, Content, Reviews, Contact | Engagement y conversión. |
| **Operaciones** | Admin | Backoffice. Depende de todos. |
| **Integración** | Integration | Conexiones externas (PadPio, Dicomere). |
| **Post-MVP** | Chat, Surveys | No bloquean la operación inicial. |

---

## 3. Diseño por Módulo

> **Convenciones:**
> - 🔗 **Mapeo desde:** indica qué archivos/rutas PHP actuales origina este módulo
> - 🟢 **Confianza:** ALTA (basado en código auditado), MEDIA (inferido), BAJA (requiere más investigación)
> - Los DTOs usan `class-validator` para validación. Los decoradores están implícitos en el diseño.
> - Las entidades mapean 1:1 las tablas inferidas en `01-modelo-datos-actual.md`.

---

### 3.1 CommonModule

> **Tipo:** Core (Global) — Provee utilidades compartidas a todos los módulos.
> 🔗 **Mapeo desde:** `inc/funciones.php` (~700 líneas), `inc/base.php`, `inc/varios.php`
> 🟢 **Confianza:** ALTA

#### Servicios exportados

| Servicio | Responsabilidad | Equivalente PHP actual |
|---|---|---|
| `MailService` | Envío de emails transaccionales con plantillas Handlebars. Cola de envío con reintentos (BullMQ). Soporte para `pedidos_emails` (cola de emails diferidos para MP/Modo). | `enviarmail()`, `enviar_mail_plantilla()`, tabla `pedidos_emails` |
| `UploadService` | Subida de archivos (imágenes de producto, comprobantes, logos). Validación de MIME type real con `file-type`. Almacenamiento local o S3. | `$_FILES` en PHP, `move_uploaded_file()` |
| `PdfService` | Generación de PDFs (facturas, pedidos imprimibles). | jsPDF/html2pdf (actualmente client-side) |
| `GeoService` | Consulta de provincias, localidades, códigos postales. Reemplaza los 4 AJAX endpoints de geolocalización. | `ajax/localidades.php`, `ajax/cp.php`, `ajax/localidades_con_cp.php`, `ajax/provincias_con_localidad.php` |
| `ExcelService` | Importación/exportación Excel (productos). Reemplaza PhpSpreadsheet. | `admin/ajax/productos_excel_exportar.php`, `admin/components/productos_plantilla_import_xlsx.php` |
| `RecaptchaService` | Validación de Google reCAPTCHA v3. | `recaptcha_site_key` + `recaptcha_secret_key` |

#### Entidades auxiliares

| Entidad | Tabla MySQL | Propósito |
|---|---|---|
| `Provincia` | `provincias` | Catálogo de provincias argentinas |
| `Localidad` | `localidades` | Catálogo de localidades |
| `CodigoPostal` | `codigos_postales` | Relación CP → localidad |
| `EmailTemplate` | `emails_plantillas` | Plantillas de email con placeholders `{{VAR}}` |

#### Dependencias del CommonModule

```
CommonModule NO importa ningún módulo de dominio.
Solo depende de:
  - ConfigModule (para SMTP, storage paths)
  - TypeOrmModule.forFeature([Provincia, Localidad, CodigoPostal, EmailTemplate])
  - BullModule (cola de emails)
```

#### DTOs principales

```typescript
// send-email.dto.ts
export class SendEmailDto {
  @IsString() templateName: string;         // 'pedido_confirmacion_cliente', etc.
  @IsObject() variables: Record<string, any>; // {nombre, pedido_id, total, ...}
  @IsEmail() to: string;
  @IsOptional() @IsString() attachments?: string[];
}

// upload-file.dto.ts
export class UploadFileDto {
  @IsString() entityType: string;  // 'producto', 'comprobante', 'logo'
  @IsNumber() entityId: number;
}

// geo-query.dto.ts
export class GeoQueryDto {
  @IsOptional() @IsNumber() provinciaId?: number;
  @IsOptional() @IsString() codigoPostal?: string;
}
```

---

### 3.2 TenantModule

> **Tipo:** Core (Global) — Resuelve el tenant activo y expone configuración tipada.
> 🔗 **Mapeo desde:** `inc/db.php` (selección de DB por branch Git), tabla `configuracion` (key-value)
> 🟢 **Confianza:** ALTA

#### Servicios

| Servicio | Responsabilidad |
|---|---|
| `TenantService` | Resuelve tenant desde subdominio (`{tenant}.lumba.com`), header (`X-Tenant-ID`), o variable de entorno (`TENANT_ID`). Expone `TenantConfig`. |
| `TenantConfigService` | Carga configuración de negocio tipada desde DB (hereda de `configuracion` key-value actual). No incluye secretos (esos van en `.env`). |

#### Configuración tipada por tenant (reemplaza tabla `configuracion`)

```typescript
// tenant-config.interface.ts
export interface TenantConfig {
  // Negocio
  business: {
    compraMinima: number;
    compraMinimaSinImpuestos: boolean;
    nombreFantasia: string;
    emailCompras: string;          // Email que recibe notificaciones de pedidos
    tiposCliente: boolean;          // Mostrar selector de tipo de cliente en checkout
    marcas: boolean;                // Mostrar marcas en menú
    formularioDevoluciones: boolean;
  };

  // Pagos
  payments: {
    metodosPago: string[];          // ['mercadopago', 'modo', 'transferencia', 'efectivo']
    cuotasMercadoPago: number;      // Máximo de cuotas
    datosBancarios: string;         // HTML con datos para transferencia
  };

  // Envíos
  shipping: {
    envioHabilitado: boolean;
    retiroPorSucursal: boolean;
    retiroPorSucursalInfo: string;
  };

  // Visual
  theme: {
    logoMenu: string;
    logoHeader: string;
    logoFooter: string;
    favicon: string;
    fondoLogin: string;
    imgShare: string;
    colores: Record<string, string>;   // Paleta de colores
    tipografias: Record<string, string>; // Fuentes
  };

  // Cron
  cron: {
    carritosAbandonadosHoras: number;   // 0 = desactivado
    carritosAbandonadosCuponId: number;
  };

  // Contacto
  contact: {
    telefonoWhatsapp: string;
    whatsapp: string;
  };
}
```

#### Guard `TenantGuard`

```typescript
// Resuelve el tenant antes de cualquier request.
// Inyecta TenantContext en el request (accesible vía @CurrentTenant() decorator).
@Injectable()
export class TenantGuard implements CanActivate {
  async canActivate(context: ExecutionContext): Promise<boolean> {
    const request = context.switchToHttp().getRequest();
    const tenantId = this.resolveTenant(request);
    request.tenantContext = await this.tenantService.getContext(tenantId);
    return true;
  }
}
```

---

### 3.3 AuthModule

> **Tipo:** Identidad — Autenticación de clientes y administradores.
> 🔗 **Mapeo desde:** `routes/account_signin.php`, `routes/account_register.php`, `routes/account_recover.php`, `routes/account_activate.php`, `routes/home.php` (action=account_activate), `admin/login.php`
> 🟢 **Confianza:** ALTA

#### Controladores y rutas

| Controller | Método | Ruta | Mapeo desde PHP | Descripción |
|---|---|---|---|---|
| `CustomerAuthController` | POST | `/api/auth/login` | `account_signin.php` | Login cliente → devuelve `{accessToken, refreshToken}` |
| `CustomerAuthController` | POST | `/api/auth/register` | `account_register.php` | Registro cliente → envía email activación |
| `CustomerAuthController` | POST | `/api/auth/activate/:hash` | `account_activate.php` | Activar cuenta vía hash |
| `CustomerAuthController` | POST | `/api/auth/recover` | `account_recover.php` | Solicitar recuperación de contraseña |
| `CustomerAuthController` | POST | `/api/auth/recover/:hash` | `account_password_recover.php` | Setear nueva contraseña |
| `CustomerAuthController` | POST | `/api/auth/refresh` | *(nuevo)* | Rotar refresh token → nuevo par de tokens |
| `CustomerAuthController` | POST | `/api/auth/logout` | `logout.php` | Revocar refresh token |
| `AdminAuthController` | POST | `/api/admin/auth/login` | `admin/login.php` | Login admin → JWT con role='admin' + permissions[] |
| `AdminAuthController` | POST | `/api/admin/auth/refresh` | *(nuevo)* | Refresh token admin |
| `AdminAuthController` | POST | `/api/admin/auth/logout` | `admin/logout.php` | Logout admin |

#### Servicios

| Servicio | Responsabilidad |
|---|---|
| `AuthService` | Login, registro, validación de credenciales. Estrategia de migración md5→bcrypt (re-hash en primer login). |
| `TokenService` | Generación, rotación y revocación de JWT tokens (ver `01-security-nestjs-config.md` §5). |
| `PasswordService` | Hashing con bcrypt (12 rounds). Validación de fortaleza. Migración legacy md5. |
| `ActivationService` | Generación de hash de activación, envío de email de bienvenida. |
| `RecoveryService` | Generación de token de recuperación con expiración (1 hora), envío de email. |

#### Estrategias Passport

```typescript
// jwt.strategy.ts — Estrategia principal para clientes
@Injectable()
export class JwtStrategy extends PassportStrategy(Strategy, 'jwt') {
  async validate(payload: JwtPayload) {
    return { userId: payload.sub, email: payload.email, role: payload.role };
  }
}

// jwt-admin.strategy.ts — Estrategia para administradores
@Injectable()
export class JwtAdminStrategy extends PassportStrategy(Strategy, 'jwt-admin') {
  async validate(payload: AdminJwtPayload) {
    return {
      adminId: payload.sub,
      email: payload.email,
      role: 'admin',
      permissions: payload.permissions,  // string[] desde administradores_tipos_permisos
      tipoId: payload.tipoId,
    };
  }
}
```

#### DTOs

```typescript
// login.dto.ts
export class LoginDto {
  @IsEmail() email: string;
  @IsString() @MinLength(8) password: string;
}

// register.dto.ts
export class RegisterDto {
  @IsEmail() email: string;
  @IsString() @MinLength(8)
  @Matches(/(?=.*[a-z])(?=.*[A-Z])(?=.*\d)/)
  password: string;
  @IsString() @MinLength(2) @MaxLength(100) nombre: string;
  @IsString() @MinLength(2) @MaxLength(100) apellido: string;
  @IsOptional() @IsBoolean() newsletter?: boolean;
  @IsOptional() @IsNumber() tipoId?: number;  // Tipo de cliente
  @IsOptional() @IsString() codigoRegistro?: string;  // Código de invitación (legacy)
}

// admin-login.dto.ts
export class AdminLoginDto {
  @IsEmail() email: string;
  @IsString() password: string;
}

// token-response.dto.ts
export class TokenResponseDto {
  accessToken: string;
  expiresIn: number;  // 900 (15 minutos en segundos)
  user: {
    id: number;
    email: string;
    nombre: string;
    role: 'customer' | 'admin';
  };
}
```

#### Dependencias

```
AuthModule imports:
  - UsersModule (para buscar/crear clientes y administradores)
  - JwtModule (configuración JWT)
  - PassportModule
  - CommonModule (MailService para emails de activación/recuperación)
```

---

### 3.4 UsersModule

> **Tipo:** Identidad — Gestión de clientes, perfiles, direcciones, favoritos.
> 🔗 **Mapeo desde:** `routes/account_profile.php`, `routes/account_company.php`, `routes/account_addresses.php`, `routes/account_wish_list.php`, `routes/account_orders.php`, `routes/account_order.php`, `ajax/favoritos.php`
> 🟢 **Confianza:** ALTA

#### Controladores y rutas

| Controller | Método | Ruta | Auth | Mapeo desde PHP |
|---|---|---|---|---|
| `CustomerProfileController` | GET | `/api/users/me` | JWT | `account_profile.php` |
| `CustomerProfileController` | PATCH | `/api/users/me` | JWT | `account_profile.php` (editar datos personales) |
| `CustomerProfileController` | PATCH | `/api/users/me/company` | JWT | `account_company.php` (razón social, CUIT) |
| `CustomerProfileController` | PUT | `/api/users/me/password` | JWT | *Nuevo* (cambio de contraseña) |
| `AddressController` | GET | `/api/users/me/addresses` | JWT | `account_addresses.php` |
| `AddressController` | POST | `/api/users/me/addresses` | JWT | `account_addresses.php` (nueva dirección) |
| `AddressController` | PUT | `/api/users/me/addresses/:id` | JWT | `account_addresses.php` (editar) |
| `AddressController` | DELETE | `/api/users/me/addresses/:id` | JWT | `account_addresses.php` (eliminar, soft delete) |
| `WishlistController` | GET | `/api/users/me/wishlist` | JWT | `account_wish_list.php` |
| `WishlistController` | POST | `/api/users/me/wishlist/:productId` | JWT | `ajax/favoritos.php` (toggle) |
| `WishlistController` | DELETE | `/api/users/me/wishlist/:productId` | JWT | `ajax/favoritos.php` (quitar) |

#### Servicios

| Servicio | Responsabilidad |
|---|---|
| `CustomerService` | CRUD de clientes. Búsqueda por email, ID, hash. Asignación de vendedor predeterminado, lista de precios, tipo de cliente. |
| `CustomerTypeService` | Gestión de `clientes_tipos`: métodos de pago, envíos, compra mínima, marcas permitidas, campos requeridos en checkout. |
| `AddressService` | CRUD de `clientes_direcciones`. Dirección predeterminada. Validación de CP. |
| `WishlistService` | Toggle de favoritos. Listado. La tabla `clientes_favoritos` es la fuente de verdad. |
| `CustomerComprobanteService` | Tipos de comprobante (`clientes_tipos_comprobante`). Situaciones fiscales (`clientes_situaciones`). |

#### Entidades (TypeORM)

| Entidad | Tabla MySQL | Notas |
|---|---|---|
| `Cliente` | `clientes` | Cambiar `contrasenia` de md5 a bcrypt. Campo legacy `password_md5_hash` para migración temporal. Campo `activo` para activación. Campo `hash` para activación/recuperación. `marcas` como JSON. |
| `ClienteTipo` | `clientes_tipos` | Perfil con configuraciones de checkout. Los campos `datos_*` controlan qué campos son requeridos/visibles en checkout paso 1. |
| `ClienteTipoComprobante` | `clientes_tipos_comprobante` | Tipos de factura permitidos. |
| `ClienteSituacion` | `clientes_situaciones` | Situaciones fiscales (Consumidor Final, RI, etc.). |
| `ClienteDireccion` | `clientes_direcciones` | Direcciones guardadas. `predeterminada` (solo una por cliente). |
| `ClienteFavorito` | `clientes_favoritos` | Producto favorito (M:N simplificada). |

#### DTOs

```typescript
// update-profile.dto.ts
export class UpdateProfileDto {
  @IsOptional() @IsString() @MinLength(2) @MaxLength(100) nombre?: string;
  @IsOptional() @IsString() @MinLength(2) @MaxLength(100) apellido?: string;
  @IsOptional() @IsString() area?: string;
  @IsOptional() @IsString() telefono?: string;
  @IsOptional() @IsString() dni?: string;
  @IsOptional() @IsEmail() email?: string;
  @IsOptional() @IsBoolean() marketing?: boolean;
}

// create-address.dto.ts
export class CreateAddressDto {
  @IsString() calle: string;
  @IsString() numero: string;
  @IsOptional() @IsString() departamento?: string;
  @IsNumber() provinciaId: number;
  @IsNumber() localidadId: number;
  @IsString() cp: string;
  @IsOptional() @IsString() etiqueta?: string; // 'Casa', 'Trabajo' (mejora)
  @IsOptional() @IsBoolean() predeterminada?: boolean;
}
```

#### Dependencias

```
UsersModule:
  NO importa otros módulos de dominio.
  Exporta: CustomerService, CustomerTypeService (usados por Auth, Checkout, Orders, Admin).
```

---

### 3.5 ProductsModule

> **Tipo:** Dominio — Catálogo de productos: grilla, filtros, búsqueda, detalle individual.
> 🔗 **Mapeo desde:** `routes/productos.php`, `routes/producto.php`, `routes/productos_grilla.php`, `inc/get_products.php` (~500 líneas)
> 🟢 **Confianza:** ALTA

#### Controladores y rutas

| Controller | Método | Ruta | Auth | Mapeo desde PHP |
|---|---|---|---|---|
| `ProductCatalogController` | GET | `/api/products` | Público | `productos.php` (grilla con filtros) |
| `ProductCatalogController` | GET | `/api/products/:url` | Público | `producto.php` (detalle) |
| `ProductCatalogController` | GET | `/api/products/:url/related` | Público | Productos relacionados |
| `ProductCatalogController` | GET | `/api/products/search` | Público | Búsqueda textual (query param `q`) |
| `ProductCatalogController` | POST | `/api/products/filter` | Público | Filtros avanzados (POST para body complejo) |

**Query params para `GET /api/products`:**
```
?categoriaId=5           → Filtro por categoría
?marcaId=2              → Filtro por marca
?tagId=7                → Filtro por tag
?precioMin=1000&precioMax=5000  → Rango de precio
?propiedades=10:25,11:30  → Filtro por propiedades (propiedadId:valorId)
?orden=precio_asc        → Ordenamiento
?page=1&limit=24         → Paginación
?q=zapatilla             → Búsqueda textual
```

#### Servicios

| Servicio | Responsabilidad | Notas de diseño |
|---|---|---|
| `ProductCatalogService` | Builder de queries de catálogo (reemplaza `inc/get_products.php`). Filtros dinámicos con QueryBuilder. | Refactorizar las ~500 líneas de queries concatenadas en un servicio limpio con métodos por tipo de filtro. Usar cache Redis para queries frecuentes. |
| `ProductDetailService` | Carga el producto completo: variantes con stock y precio, propiedades, categorías, relacionados. | El precio mostrado depende de la `lista_id` del cliente (si está logueado) o la lista predeterminada. La restricción de marcas (`clientes.marcas`) se aplica aquí si el cliente está logueado. |
| `ProductSearchService` | Búsqueda full-text (FULLTEXT en MySQL MVP, Elasticsearch en Fase 2). | MVP: índice FULLTEXT en `productos.producto` + `productos.descripcion`. |
| `ProductPriceService` | Calcula el precio de un producto para un cliente dado (lista de precios). | Centraliza la lógica de `productos_variantes_precios` con la `lista_id`. |
| `ProductStockService` | Consulta stock de un producto/variante por sucursal. | Usado por el carrito para validar, por el detalle para mostrar disponibilidad. |

#### Entidades

| Entidad | Tabla MySQL | Notas |
|---|---|---|
| `Producto` | `productos` | Campos: `producto`, `url` (slug), `descripcion`, `foto`, `precio_desde` (calculado), `destacado`, `orden`, `activo`, `iva`. Sin `categoria_id` directo (relación M:N). |
| `ProductoCategoria` | `productos_categorias` | Relación M:N con `categorias`. |
| `ProductoPropiedadValor` | `productos_propiedades_valores` | Relación para filtros: qué valores de propiedad aplican a este producto. |
| `ProductoTag` | `productos_tags` | Relación M:N con `tags`. |
| `ProductoKeyword` | `productos_keywords` | Relación M:N con `keywords` (para búsqueda). |
| `ProductoRelacionado` | `productos_relacionados` | Relación auto-referenciada. |

#### DTOs

```typescript
// product-filter.dto.ts
export class ProductFilterDto {
  @IsOptional() @IsNumber() categoriaId?: number;
  @IsOptional() @IsNumber() marcaId?: number;
  @IsOptional() @IsNumber() tagId?: number;
  @IsOptional() @IsNumber() @Min(0) precioMin?: number;
  @IsOptional() @IsNumber() @Min(0) precioMax?: number;
  @IsOptional() @IsString() propiedades?: string;  // "10:25,11:30"
  @IsOptional() @IsString() orden?: string;         // 'precio_asc', 'precio_desc', 'nombre_asc', 'novedades'
  @IsOptional() @IsNumber() @Min(1) page?: number;
  @IsOptional() @IsNumber() @Min(1) @Max(100) limit?: number;
  @IsOptional() @IsString() q?: string;             // Búsqueda textual
}

// product-list-response.dto.ts
export class ProductListResponseDto {
  items: ProductListItemDto[];
  total: number;
  page: number;
  limit: number;
  totalPages: number;
  filters: {
    precioMin: number;
    precioMax: number;
    // ... rangos de filtros disponibles
  };
}

// product-detail-response.dto.ts
export class ProductDetailResponseDto {
  id: number;
  nombre: string;
  url: string;
  descripcion: string;
  marca: { id: number; nombre: string };
  categorias: { id: number; nombre: string; url: string }[];
  tags: { id: number; nombre: string; url: string }[];
  foto: string;
  fotos: string[];  // Galería
  precioDesde: number;
  variantes: ProductVariantDto[];
  stock: ProductStockDto[];
  relacionados: ProductListItemDto[];
  propiedades: ProductPropertyDto[];
}
```

#### Dependencias

```
ProductsModule imports:
  - CategoriesModule (filtro por categoría, tree de categorías)
  - BrandsModule (filtro por marca)
  - TagsModule (filtro por tag)
  
ProductsModule exports:
  - ProductCatalogService (usado por Cart, Orders, Admin)
  - ProductPriceService (usado por Cart, Checkout)
  - ProductStockService (usado por Cart, Checkout, Orders)
```

---

### 3.6 CategoriesModule

> **Tipo:** Dominio — Jerarquía de categorías (árbol nestable).
> 🔗 **Mapeo desde:** `admin/routes/categorias.php`, `admin/routes/categorias_edit.php`, `admin/routes/categorias_foto.php`
> 🟢 **Confianza:** ALTA

#### Controladores y rutas

| Controller | Método | Ruta | Auth | Descripción |
|---|---|---|---|---|
| `CategoryPublicController` | GET | `/api/categories` | Público | Árbol completo de categorías activas |
| `CategoryPublicController` | GET | `/api/categories/:url` | Público | Detalle de categoría con subcategorías |
| `CategoryAdminController` | GET | `/api/admin/categories` | Admin | Listar todas (incluye inactivas) |
| `CategoryAdminController` | POST | `/api/admin/categories` | Admin | Crear categoría |
| `CategoryAdminController` | PUT | `/api/admin/categories/:id` | Admin | Editar categoría |
| `CategoryAdminController` | DELETE | `/api/admin/categories/:id` | Admin | Soft delete |
| `CategoryAdminController` | PUT | `/api/admin/categories/order` | Admin | Reordenar (nestable array) |

#### Servicios

| Servicio | Responsabilidad |
|---|---|
| `CategoryService` | CRUD + árbol jerárquico. Ordenamiento drag-and-drop. Soft delete. |

#### Entidades

| Entidad | Tabla MySQL |
|---|---|
| `Categoria` | `categorias` (con `categoria_padre_id` auto-referenciada para jerarquía) |

#### Dependencias

```
CategoriesModule:
  NO importa otros módulos de dominio.
  Exporta: CategoryService (usado por Products, Admin).
```

---

### 3.7 BrandsModule

> **Tipo:** Dominio — Marcas de productos.
> 🔗 **Mapeo desde:** `admin/routes/marcas.php`, `admin/routes/marcas_new.php`, `admin/routes/marcas_edit.php`
> 🟢 **Confianza:** ALTA

#### Controladores y rutas

| Controller | Método | Ruta | Auth | Descripción |
|---|---|---|---|---|
| `BrandPublicController` | GET | `/api/brands` | Público | Lista de marcas activas (con restricción si cliente logueado) |
| `BrandPublicController` | GET | `/api/brands/:url` | Público | Detalle de marca |
| `BrandAdminController` | GET | `/api/admin/brands` | Admin | Listar todas |
| `BrandAdminController` | POST | `/api/admin/brands` | Admin | Crear |
| `BrandAdminController` | PUT | `/api/admin/brands/:id` | Admin | Editar |
| `BrandAdminController` | DELETE | `/api/admin/brands/:id` | Admin | Soft delete |

#### Servicios

| Servicio | Responsabilidad |
|---|---|
| `BrandService` | CRUD de marcas. Filtro por restricción de cliente (`clientes.marcas` / `clientes_tipos.marcas`). |

#### Entidades

| Entidad | Tabla MySQL |
|---|---|
| `Marca` | `marcas` |

#### Dependencias

```
BrandsModule:
  NO importa otros módulos de dominio.
  Exporta: BrandService (usado por Products, Admin).
```

---

### 3.8 TagsModule

> **Tipo:** Dominio — Etiquetas de navegación secundaria.
> 🔗 **Mapeo desde:** `admin/routes/tags.php`, `admin/routes/tags_new.php`, `admin/routes/tags_edit.php`, `admin/routes/tags_order.php`
> 🟢 **Confianza:** ALTA

#### Controladores y rutas

| Controller | Método | Ruta | Auth | Descripción |
|---|---|---|---|---|
| `TagPublicController` | GET | `/api/tags` | Público | Tags visibles en menú (`visible_menu=1`) |
| `TagAdminController` | GET/POST/PUT/DELETE | `/api/admin/tags` | Admin | CRUD completo + reordenar |

#### Entidades

| Entidad | Tabla MySQL |
|---|---|
| `Tag` | `tags` (con campos de estilo: `color_fondo_menu`, `color_texto_menu`, `bold_menu`) |

#### Dependencias

```
TagsModule:
  NO importa otros módulos.
  Exporta: TagService (usado por Products, Admin).
```

---

### 3.9 CartModule

> **Tipo:** Transaccional — Carrito de compras persistente con validación server-side.
> 🔗 **Mapeo desde:** `ajax/agregarcarrito.php`, `routes/cart.php`, `components/resumen_carrito.php`, `inc/cupon.php`
> 🟢 **Confianza:** ALTA

#### Controladores y rutas

| Controller | Método | Ruta | Auth | Mapeo desde PHP |
|---|---|---|---|---|
| `CartController` | GET | `/api/cart` | Opcional | `cart.php` (ver carrito) |
| `CartController` | POST | `/api/cart/items` | Opcional | `agregarcarrito.php` (agregar item) |
| `CartController` | PATCH | `/api/cart/items/:productId/:variantId` | Opcional | Modificar cantidad |
| `CartController` | DELETE | `/api/cart/items/:productId/:variantId` | Opcional | Eliminar item |
| `CartController` | DELETE | `/api/cart` | Opcional | Vaciar carrito |
| `CartController` | POST | `/api/cart/coupon` | Opcional | Aplicar cupón |
| `CartController` | DELETE | `/api/cart/coupon` | Opcional | Quitar cupón |
| `CartController` | GET | `/api/cart/summary` | Opcional | Mini-carrito (resumen para header) |

#### Servicios

| Servicio | Responsabilidad | Notas de diseño |
|---|---|---|
| `CartService` | Gestión del carrito: agregar, modificar, eliminar, vaciar. Carrito persistente en DB. | **Mejora crítica:** el carrito actual vive en `$_SESSION`. Migrar a tabla `carritos` + `carritos_items` en DB. Asociado a `cliente_id` (si logueado) o a `session_token` (JWT anónimo en cookie). Recuperación cross-dispositivo. |
| `CartValidationService` | Validación server-side de stock y precio (anti-tampering). | **Migrar igual:** la validación actual es excelente. Se consulta `productos_variantes_stock` y `productos_variantes_precios` al agregar. Si el precio del request no coincide, se usa el de DB. |
| `CartPricingService` | Cálculo de totales: subtotal, promociones aplicadas, descuento de cupón, IVA, costo de envío. | Reemplaza la lógica dispersa en `cart.php` y `buscarPromoPorProducto()`. Servicio centralizado que orquesta: promociones → cupones → envío gratis. |
| `CartCouponService` | Validación y aplicación de cupones. Verifica vigencia, tipo, acumulabilidad, aplicabilidad por producto/categoría. | Migrar de `inc/cupon.php` (~100 líneas). |

#### Entidades (nuevas — mejora sobre sistema actual)

```typescript
// cart.entity.ts
@Entity('carritos')
export class Carrito {
  @PrimaryGeneratedColumn() id: number;
  @Column({ nullable: true }) clienteId: number;     // NULL si anónimo
  @Column({ nullable: true }) sessionToken: string;  // JWT anónimo
  @Column({ nullable: true }) cuponCodigo: string;
  @Column({ type: 'decimal', precision: 12, scale: 2, default: 0 })
  cuponValor: number;
  @Column({ nullable: true }) cuponTipo: string;      // 'Porcentaje', 'Monto fijo', 'Envío gratis'
  @Column({ default: () => 'CURRENT_TIMESTAMP' })
  createdAt: Date;
  @UpdateDateColumn() updatedAt: Date;
  @OneToMany(() => CarritoItem, item => item.carrito, { cascade: true })
  items: CarritoItem[];
}

// cart-item.entity.ts
@Entity('carritos_items')
export class CarritoItem {
  @PrimaryGeneratedColumn() id: number;
  @ManyToOne(() => Carrito) carrito: Carrito;
  @Column() productoId: number;
  @Column() varianteId: number;
  @Column() cantidad: number;
  @Column({ type: 'decimal', precision: 12, scale: 2 }) precio: number;
  @Column({ nullable: true }) foto: string;
  @Column({ nullable: true }) sku: string;
  @ManyToOne(() => Producto) producto: Producto;  // Solo para joins
}
```

#### DTOs

```typescript
// add-to-cart.dto.ts
export class AddToCartDto {
  @IsNumber() productoId: number;
  @IsNumber() varianteId: number;
  @IsNumber() @Min(1) cantidad: number;
  @IsNumber() @Min(0) precio: number;    // Validado contra DB (anti-tampering)
  @IsOptional() @IsString() sku?: string;
  @IsOptional() @IsString() foto?: string;
  @IsOptional() @IsString() url?: string;
  @IsOptional() @IsNumber() iva?: number;
  @IsOptional() @IsString() producto?: string; // Nombre denormalizado
}

// cart-response.dto.ts
export class CartResponseDto {
  items: CartItemResponseDto[];
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
    tipo: string;
    valor: number;
    descripcion: string;
  };
  compraMinima: number;
  compraMinimaAlcanzada: boolean;
}
```

#### Dependencias

```
CartModule imports:
  - ProductsModule (ProductPriceService, ProductStockService — para validación)
  - PromotionsModule (buscarPromoPorProducto)
  - CouponsModule (validar y aplicar cupón)
  - UsersModule (CustomerService — para asociar carrito a cliente)
  
CartModule exports:
  - CartService (usado por Checkout, Orders)
```

---

### 3.10 CheckoutModule

> **Tipo:** Transaccional — Flujo de compra completo (4 pasos → single-page en mejora).
> 🔗 **Mapeo desde:** `routes/checkout_1.php`, `routes/checkout_2.php`, `routes/checkout_2_envio.php`, `routes/checkout_3.php`, `routes/checkout_4.php`, `inc/collect_checkout_info.php`, `inc/guardar_pedido_parcial.php`
> 🟢 **Confianza:** ALTA

#### Controladores y rutas

| Controller | Método | Ruta | Auth | Mapeo desde PHP |
|---|---|---|---|---|
| `CheckoutController` | GET | `/api/checkout` | Opcional | Iniciar checkout (carga datos del carrito) |
| `CheckoutController` | POST | `/api/checkout/step/1` | Opcional | Guardar datos personales |
| `CheckoutController` | POST | `/api/checkout/step/2` | Opcional | Guardar forma de entrega + dirección |
| `CheckoutController` | POST | `/api/checkout/step/3` | Opcional | Guardar medio de pago |
| `CheckoutController` | POST | `/api/checkout/confirm` | Opcional | Confirmar pedido (paso 4) |
| `CheckoutController` | GET | `/api/checkout/state` | Opcional | Obtener estado actual del checkout |

#### Servicios

| Servicio | Responsabilidad | Notas de diseño |
|---|---|---|
| `CheckoutService` | Orquesta el flujo de checkout. Mantiene estado en DB (tabla `checkouts` o en `pedidos` con estado 'Incompleto'). | Reemplaza `$_SESSION['checkout']` y `guardar_pedido_parcial.php`. Cada paso persiste en DB. |
| `CheckoutValidationService` | Validaciones de negocio: compra mínima, stock disponible, campos requeridos según tipo de cliente. | Las validaciones de campos dinámicos por `clientes_tipos.datos_*` se implementan aquí. |
| `CheckoutConfirmationService` | **Transacción MySQL:** validación final de stock con `FOR UPDATE`, creación de pedido, registro automático de cliente si no existe, ruteo por forma de pago. | **Migrar igual:** la lógica transaccional actual con `BEGIN TRANSACTION` + `SELECT ... FOR UPDATE` es correcta. Se reimplementa con TypeORM `@Transaction()`. |
| `CheckoutAutoRegistrationService` | Registro automático de cliente nuevo al confirmar compra como invitado. Genera contraseña random (o magic link en mejora). Envía email de bienvenida. | **Mejora:** en vez de contraseña random por email, generar magic link. |

#### DTOs

```typescript
// checkout-data.dto.ts (Paso 1)
export class CheckoutDataDto {
  @IsOptional() @IsNumber() tipoClienteId?: number;
  @IsEmail() email: string;
  @IsOptional() @IsString() nombre?: string;
  @IsOptional() @IsString() apellido?: string;
  @IsOptional() @IsString() razonSocial?: string;
  @IsOptional() @IsString() nombreFantasia?: string;
  @IsOptional() @IsString() dni?: string;
  @IsOptional() @IsString() cuit?: string;
  @IsOptional() @IsNumber() situacionFiscalId?: number;
  @IsOptional() @IsNumber() tipoComprobanteId?: number;
  @IsOptional() @IsString() area?: string;
  @IsOptional() @IsString() telefono?: string;
  @IsOptional() @IsBoolean() newsletter?: boolean;
}

// checkout-shipping.dto.ts (Paso 2)
export class CheckoutShippingDto {
  @IsString() formaEntrega: string;   // 'retiro_sucursal', 'envio_domicilio', 'zipnova_sucursal'
  @IsOptional() @IsNumber() sucursalId?: number;
  @IsOptional() @IsNumber() direccionId?: number;     // Dirección guardada
  @IsOptional() @IsString() calle?: string;           // O nueva dirección
  @IsOptional() @IsString() numero?: string;
  @IsOptional() @IsString() departamento?: string;
  @IsOptional() @IsNumber() provinciaId?: number;
  @IsOptional() @IsNumber() localidadId?: number;
  @IsOptional() @IsString() cp?: string;
  @IsOptional() @IsNumber() envioPropioId?: number;   // Método de envío propio
  @IsOptional() @IsString() zipnovaOpcion?: string;
  @IsOptional() @IsString() zipnovaPointId?: string;
  @IsOptional() @IsObject() zipnovaJson?: any;        // JSON de cotización
  @IsOptional() @IsBoolean() mismaDireccionFacturacion?: boolean;
  @IsOptional() @IsString() facturacionCalle?: string;
  @IsOptional() @IsString() facturacionNumero?: string;
  @IsOptional() @IsString() facturacionDepartamento?: string;
  @IsOptional() @IsNumber() facturacionProvinciaId?: number;
  @IsOptional() @IsNumber() facturacionLocalidadId?: number;
  @IsOptional() @IsString() facturacionCp?: string;
}

// checkout-payment.dto.ts (Paso 3)
export class CheckoutPaymentDto {
  @IsString() formaPago: string;  // 'mercadopago', 'modo', 'transferencia', 'efectivo'
}

// checkout-confirm.dto.ts (Paso 4)
export class CheckoutConfirmDto {
  @IsOptional() @IsString() observaciones?: string;
}
```

#### Estado del checkout (persistido)

```typescript
// checkout-state.entity.ts (o como parte de pedidos con estado='Incompleto')
@Entity('checkouts')
export class Checkout {
  @PrimaryGeneratedColumn() id: number;
  @Column() carritoId: number;
  @Column({ nullable: true }) pedidoId: number;    // Se crea en paso 1 como estado 'Incompleto'
  @Column() pasoActual: number;                     // 1-4
  @Column({ type: 'json', nullable: true }) datosPersonales: any;
  @Column({ type: 'json', nullable: true }) datosEnvio: any;
  @Column({ type: 'json', nullable: true }) datosPago: any;
  @Column({ default: false }) completado: boolean;
  @CreateDateColumn() createdAt: Date;
  @UpdateDateColumn() updatedAt: Date;
}
```

#### Dependencias

```
CheckoutModule imports:
  - CartModule (CartService — leer carrito, obtener resumen)
  - ShippingModule (ShippingService — calcular envío, listar opciones)
  - PaymentsModule (PaymentService — ruteo por forma de pago)
  - UsersModule (CustomerService, AddressService, CustomerTypeService)
  - OrdersModule (OrderService — crear pedido)
  - CommonModule (MailService — emails de confirmación)
```

---

### 3.11 OrdersModule

> **Tipo:** Transaccional — Pedidos, estados, historial, detalle.
> 🔗 **Mapeo desde:** `routes/account_orders.php`, `routes/account_order.php`, `admin/routes/pedidos.php`, `admin/routes/pedidos_edit.php`, `admin/routes/pedidos_view.php`, `admin/ajax/actualizar_estados.php`
> 🟢 **Confianza:** ALTA

#### Controladores y rutas (Frontend — cliente)

| Controller | Método | Ruta | Auth | Descripción |
|---|---|---|---|---|
| `CustomerOrderController` | GET | `/api/orders` | JWT | Historial de pedidos del cliente |
| `CustomerOrderController` | GET | `/api/orders/:hash` | JWT | Detalle de un pedido |
| `CustomerOrderController` | POST | `/api/orders/:hash/repeat` | JWT | Repetir compra (carga carrito desde pedido anterior) |
| `CustomerOrderController` | POST | `/api/orders/:hash/resume` | Público | Retomar compra (desde link de carrito abandonado) |

#### Controladores y rutas (Admin)

| Controller | Método | Ruta | Auth | Descripción |
|---|---|---|---|---|
| `AdminOrderController` | GET | `/api/admin/orders` | Admin | Listado con filtros avanzados (DataTable) |
| `AdminOrderController` | GET | `/api/admin/orders/:id` | Admin | Detalle completo imprimible |
| `AdminOrderController` | POST | `/api/admin/orders` | Admin | Crear pedido manual |
| `AdminOrderController` | PUT | `/api/admin/orders/:id` | Admin | Editar pedido (estados, tracking, items) |
| `AdminOrderController` | PATCH | `/api/admin/orders/:id/status` | Admin | Cambiar estado (general, pago, entrega, factura) |

#### Servicios

| Servicio | Responsabilidad |
|---|---|
| `OrderService` | CRUD de pedidos. Creación desde checkout. Búsqueda por hash. Historial por cliente. Validación de transiciones de estado. |
| `OrderStateService` | Máquina de estados: 'Incompleto' → 'Activo' → 'Reintegrado'. Validación de transiciones permitidas. |
| `OrderEmailService` | Gestión de `pedidos_emails`: creación de emails pendientes, envío diferido (MP/Modo), envío inmediato (Transferencia/Efectivo). |
| `OrderDetailService` | Sincronización de `pedidos_detalle`. Snapshot de producto, precio, foto al momento de la compra. |
| `OrderTrackingService` | Tracking visual: timeline de estados del pedido (Fase 2). |

#### Entidades

| Entidad | Tabla MySQL | Notas |
|---|---|---|
| `Pedido` | `pedidos` | Estados: `estado`, `estado_pago`, `estado_entrega`, `estado_factura`. Datos del cliente denormalizados. `hash` único. `cron_notificado` para carritos abandonados. |
| `PedidoDetalle` | `pedidos_detalle` | Snapshot de producto al momento de la compra (precio, foto, promoción aplicada, cupón). |
| `PedidoEmail` | `pedidos_emails` | Cola de emails: `enviado=0` → pendiente, `enviado=1` → enviado. |
| `PedidoEstado` | `pedidos_estados` | Catálogo de estados posibles por tipo (pago, entrega, factura, general). |

#### DTOs

```typescript
// order-list-query.dto.ts
export class OrderListQueryDto {
  @IsOptional() @IsNumber() clienteId?: number;
  @IsOptional() @IsString() estado?: string;
  @IsOptional() @IsString() estadoPago?: string;
  @IsOptional() @IsString() estadoEntrega?: string;
  @IsOptional() @IsDateString() fechaDesde?: string;
  @IsOptional() @IsDateString() fechaHasta?: string;
  @IsOptional() @IsNumber() page?: number;
  @IsOptional() @IsNumber() limit?: number;
}

// update-order-status.dto.ts
export class UpdateOrderStatusDto {
  @IsOptional() @IsString() estado?: string;       // 'Activo', 'Reintegrado'
  @IsOptional() @IsString() estadoPago?: string;    // 'Pagado', 'Reintegrado'
  @IsOptional() @IsString() estadoEntrega?: string; // 'Enviado', 'Entregado'
  @IsOptional() @IsString() estadoFactura?: string; // 'Facturado'
  @IsOptional() @IsString() tracking?: string;
}
```

#### Estados y transiciones

```
Pedido:    Incompleto ──→ Activo ──→ Reintegrado
Pago:      Pendiente ──→ Pagado ──→ Reintegrado
Entrega:   Pendiente ──→ Enviado ──→ Entregado
Factura:   Pendiente ──→ Facturado
```

#### Dependencias

```
OrdersModule imports:
  - ProductsModule (ProductPriceService, ProductStockService — para crear pedido manual)
  - UsersModule (CustomerService — para búsqueda de clientes)
  - ShippingModule (ShippingService — para tracking)
  - CommonModule (MailService — para envío de emails)
  - PaymentsModule (para consultar estado de pago)

OrdersModule exports:
  - OrderService (usado por Checkout, Payments, Admin)
```

---

### 3.12 PaymentsModule

> **Tipo:** Transaccional — Procesamiento de pagos: MercadoPago, Modo, Transferencia, Efectivo.
> 🔗 **Mapeo desde:** `connect/mp_ipn.php`, `connect/modo_webhook.php`, `routes/mercadopago.php`, `routes/checkout_4.php` (sección de pagos), `routes/comprobantes.php`
> 🟢 **Confianza:** ALTA

#### Controladores y rutas

| Controller | Método | Ruta | Auth | Descripción |
|---|---|---|---|---|
| `PaymentController` | POST | `/api/payments/mercadopago/init` | Opcional | Iniciar pago MP → devuelve `{url_pago}` |
| `PaymentController` | POST | `/api/payments/modo/init` | Opcional | Iniciar pago Modo → devuelve `{url_pago, qr}` |
| `WebhookController` | POST | `/api/webhooks/mercadopago` | *Validado por firma* | IPN de MercadoPago |
| `WebhookController` | POST | `/api/webhooks/modo` | *Validado por firma* | Webhook de Modo |
| `ComprobanteController` | POST | `/api/payments/comprobante/:hash` | Opcional | Subir comprobante de transferencia |
| `ComprobanteController` | GET | `/api/payments/comprobante/:hash` | Opcional | Ver estado del comprobante |

#### Arquitectura interna: Strategy Pattern

```typescript
// payment-strategy.interface.ts
export interface PaymentStrategy {
  readonly name: string;  // 'mercadopago' | 'modo' | 'transferencia' | 'efectivo'
  initPayment(order: Pedido, config: TenantConfig): Promise<PaymentInitResult>;
  handleWebhook(payload: any, signature: string): Promise<WebhookResult>;
  getPaymentStatus(orderId: number): Promise<PaymentStatus>;
}

// Tipos concretos
export class MercadoPagoStrategy implements PaymentStrategy { /* ... */ }
export class ModoStrategy implements PaymentStrategy { /* ... */ }
export class TransferenciaStrategy implements PaymentStrategy { /* ... */ }
export class EfectivoStrategy implements PaymentStrategy { /* ... */ }

// Factory
@Injectable()
export class PaymentStrategyFactory {
  constructor(
    private readonly mp: MercadoPagoStrategy,
    private readonly modo: ModoStrategy,
    private readonly transferencia: TransferenciaStrategy,
    private readonly efectivo: EfectivoStrategy,
  ) {}

  get(name: string): PaymentStrategy {
    const strategies = {
      mercadopago: this.mp,
      modo: this.modo,
      transferencia: this.transferencia,
      efectivo: this.efectivo,
    };
    return strategies[name] || this.efectivo;
  }
}
```

#### Servicios

| Servicio | Responsabilidad |
|---|---|
| `PaymentService` | Orquesta el pago según la estrategia. `iniciarPago(pedido, formaPago)` → delega en la estrategia. |
| `PaymentWebhookService` | Recibe webhooks, valida firma criptográfica, delega en la estrategia correspondiente. |
| `PaymentStatusService` | Consulta estado de pago (polling desde frontend post-redirección a MP/Modo). |
| `ComprobanteService` | Subida y gestión de comprobantes de transferencia. |

#### Webhook validation (implementar según `01-security-nestjs-config.md`)

```typescript
// webhooks/mercadopago-webhook.controller.ts
@Post('mercadopago')
@SkipCsrf()  // Excluir de CSRF — se valida por firma
async handleMercadoPagoWebhook(
  @Body() payload: any,
  @Headers('x-signature') signature: string,
  @Headers('x-request-id') requestId: string,
) {
  // Validar firma criptográfica
  const isValid = this.webhookService.validateMercadoPagoSignature(payload, signature);
  if (!isValid) {
    this.securityLogger.logWebhookRejected('mercadopago', 'Invalid signature', ip);
    throw new UnauthorizedException('Firma inválida');
  }
  
  // Procesar pago
  const result = await this.paymentWebhookService.processPayment('mercadopago', payload);
  
  // Acciones post-pago (eventos)
  if (result.status === 'paid') {
    await this.eventEmitter.emitAsync('payment.confirmed', {
      pedidoId: result.pedidoId,
      provider: 'mercadopago',
      paymentId: result.paymentId,
    });
  }
  
  return { status: 'ok' };
}
```

#### Listeners de eventos (desacoplados)

```typescript
// listeners/payment-confirmed.listener.ts
@Injectable()
export class PaymentConfirmedListener {
  @OnEvent('payment.confirmed')
  async handlePaymentConfirmed(event: PaymentConfirmedEvent) {
    // 1. Descontar stock
    await this.stockService.discountStock(event.pedidoId);
    
    // 2. Enviar emails pendientes
    await this.orderEmailService.sendPendingEmails(event.pedidoId);
    
    // 3. Confirmar envío Zipnova
    if (event.usaZipnova) {
      await this.shippingService.confirmarEnvioZipnova(event.pedidoId);
    }
  }
}

@OnEvent('payment.reverted')
async handlePaymentReverted(event: PaymentRevertedEvent) {
  // Reponer stock
  await this.stockService.restoreStock(event.pedidoId);
}
```

#### Dependencias

```
PaymentsModule imports:
  - OrdersModule (OrderService — actualizar estado de pago)
  - UsersModule (CustomerService — datos para Modo)
  - ShippingModule (ShippingService — confirmar envío Zipnova)
  - CommonModule (MailService)
  - EventEmitterModule
  
PaymentsModule exports:
  - PaymentService (usado por Checkout, Admin)
```

---

### 3.13 ShippingModule

> **Tipo:** Transaccional — Envíos: sucursal, envío propio, Zipnova, tracking.
> 🔗 **Mapeo desde:** `routes/checkout_2_envio.php`, `admin/routes/envios_propios.php`, `admin/routes/sucursales.php`, `connect/zn_webhook.php`, `ajax/cotizar_envio_con_cp.php`
> 🟢 **Confianza:** ALTA (envíos propios y sucursal), MEDIA (Zipnova — API no totalmente visible)

#### Controladores y rutas

| Controller | Método | Ruta | Auth | Descripción |
|---|---|---|---|---|
| `ShippingController` | GET | `/api/shipping/options` | Opcional | Listar opciones de envío disponibles para el cliente (según perfil y ubicación) |
| `ShippingController` | POST | `/api/shipping/quote` | Opcional | Cotizar envío (CP, localidad, provincia) |
| `ShippingController` | GET | `/api/shipping/sucursales` | Público | Listar sucursales disponibles |
| `ShippingController` | GET | `/api/shipping/tracking/:orderId` | Público | Tracking público de un pedido |
| `WebhookController` | POST | `/api/webhooks/zipnova` | *Validado por firma* | Webhook de tracking Zipnova |
| `AdminShippingController` | GET/POST/PUT/DELETE | `/api/admin/shipping` | Admin | CRUD de envíos propios |
| `AdminSucursalController` | GET/POST/PUT/DELETE | `/api/admin/sucursales` | Admin | CRUD de sucursales |
| `AdminShippingConfigController` | GET/PUT | `/api/admin/shipping/config` | Admin | Configuración: envío gratis global, compra mínima |

#### Servicios

| Servicio | Responsabilidad |
|---|---|
| `ShippingOptionService` | Lista opciones de envío disponibles para un cliente: (1) retiro por sucursal, (2) envíos propios filtrados por provincia/localidad, (3) Zipnova. Filtra por perfil de cliente (`clientes_tipos`). |
| `ShippingQuoteService` | Cotiza costo de envío según método seleccionado. Para Zipnova: llama a API externa. Para envíos propios: precio fijo + regla de envío gratis. |
| `ShippingFreeService` | Evalúa si aplica envío gratis: (a) envío gratis global (`envio_gratis`), (b) envío gratis del método propio, (c) cupón tipo "Envío gratis". |
| `ZipnovaService` | Integración con API de Zipnova: cotización, selección de punto de retiro, confirmación de envío. **Corregir bug:** `SET estado_envio='estado'` literal → usar variable correcta. |
| `TrackingService` | Actualización de estado de envío desde webhooks. Timeline de tracking para el cliente. |
| `SucursalService` | CRUD de sucursales. |
| `EnvioPropioService` | CRUD de métodos de envío propio con reglas de zona y envío gratis. |

#### Entidades

| Entidad | Tabla MySQL |
|---|---|
| `EnvioPropio` | `envios_propios` (con `localidades` como JSON) |
| `Sucursal` | `sucursales` |
| `EnvioGratis` | `envio_gratis` (fila única, Id=1) |
| `CompraMinima` | `compra_minima` (fila única, Id=1) |

#### Dependencias

```
ShippingModule imports:
  - CommonModule (GeoService — provincias, localidades, CP)
  - UsersModule (CustomerTypeService — verificar permisos de envío por perfil)
  
ShippingModule exports:
  - ShippingOptionService (usado por Checkout)
  - ShippingQuoteService (usado por Checkout)
  - TrackingService (usado por Orders)
```

---

### 3.14 AdminModule

> **Tipo:** Operaciones — Panel de administración completo.
> 🔗 **Mapeo desde:** 119 archivos en `admin/routes/`, `admin/ajax/`, `admin/index.php`, `admin/login.php`
> 🟢 **Confianza:** ALTA

#### Estructura del AdminModule

```
src/modules/admin/
├── admin.module.ts
├── controllers/
│   ├── admin-dashboard.controller.ts      # Dashboard con KPIs
│   ├── admin-products.controller.ts       # CRUD productos, variantes, stock, Excel
│   ├── admin-categories.controller.ts     # CRUD categorías (nestable)
│   ├── admin-brands.controller.ts         # CRUD marcas
│   ├── admin-tags.controller.ts           # CRUD tags
│   ├── admin-properties.controller.ts     # CRUD propiedades y valores
│   ├── admin-orders.controller.ts         # CRUD pedidos, estados
│   ├── admin-customers.controller.ts      # CRUD clientes, tipos, comprobantes
│   ├── admin-users.controller.ts          # CRUD administradores, tipos, permisos
│   ├── admin-content.controller.ts        # Slider, banners, FAQ, secciones, redes, reseñas
│   ├── admin-config.controller.ts         # Configuración tipada por sección
│   ├── admin-coupons.controller.ts        # CRUD cupones
│   ├── admin-promotions.controller.ts     # CRUD promociones
│   ├── admin-shipping.controller.ts       # CRUD envíos propios + sucursales
│   ├── admin-contact.controller.ts        # Bandeja de mensajes de contacto
│   ├── admin-devolutions.controller.ts    # Solicitudes de devolución
│   ├── admin-excel.controller.ts          # Import/Export Excel (Fase 2)
│   └── admin-integration.controller.ts    # Sincronización PadPio, Dicomere
└── services/
    ├── admin-dashboard.service.ts
    ├── admin-global-search.service.ts      # Búsqueda global (reemplaza global_search.php)
    └── admin-permissions.service.ts        # Validación granular de permisos (119 secciones)
```

#### Servicios key del admin

| Servicio | Responsabilidad |
|---|---|
| `AdminDashboardService` | KPIs: ventas del mes, comparativa mes anterior, pedidos, ticket promedio, productos más vendidos. |
| `AdminGlobalSearchService` | Búsqueda global unificada: productos, pedidos, clientes. Reemplaza `global_search.php`. |
| `AdminPermissionsService` | Validación de permisos granulares. Mapea `administradores_tipos_permisos` a un guard `PermissionsGuard`. |
| `AdminConfigService` | CRUD de configuración tipada por sección (reemplaza la tabla `configuracion` key-value). Separa settings visuales (theme) de reglas de negocio. |

#### Sistema de permisos (migrar de `administradores_tipos_permisos`)

```typescript
// permissions.decorator.ts
export const RequirePermission = (...permissions: string[]) =>
  SetMetadata('permissions', permissions);

// permissions.guard.ts
@Injectable()
export class PermissionsGuard implements CanActivate {
  canActivate(context: ExecutionContext): boolean {
    const required = this.reflector.getAllAndOverride<string[]>('permissions', [
      context.getHandler(), context.getClass(),
    ]);
    if (!required) return true;
    
    const { user } = context.switchToHttp().getRequest();
    return required.every(p => user.permissions?.includes(p));
  }
}

// Uso en controller
@Controller('admin/products')
@RequirePermission('productos')  // Sección del admin
export class AdminProductsController {
  @Post()
  @RequirePermission('productos_new')  // Permiso específico
  async create(@Body() dto: CreateProductDto) { /* ... */ }
}
```

#### Dependencias

```
AdminModule imports TODOS los módulos de dominio/transaccionales.
Es el agregador del backoffice.
```

---

### 3.15 CouponsModule

> **Tipo:** Marketing — Cupones de descuento.
> 🔗 **Mapeo desde:** `inc/cupon.php` (~100 líneas), `admin/routes/cupones.php`
> 🟢 **Confianza:** ALTA

#### Servicios

| Servicio | Responsabilidad |
|---|---|
| `CouponService` | CRUD de cupones. Validación: vigencia (fechas), tipo ('Porcentaje', 'Monto fijo', 'Envío gratis'), aplicabilidad (toda la tienda / categorías / productos), acumulabilidad. |
| `CouponValidationService` | Valida un cupón en el contexto de un carrito: ¿está vigente? ¿aplica a los productos del carrito? ¿es acumulable con las promociones activas? |

#### Entidades

| Entidad | Tabla MySQL |
|---|---|
| `Cupon` | `cupones` (con `aplica_a_categorias` y `aplica_a_productos` como JSON) |

#### Dependencias

```
CouponsModule:
  NO importa otros módulos de dominio.
  Exporta: CouponValidationService (usado por Cart, Checkout).
```

---

### 3.16 PromotionsModule

> **Tipo:** Marketing — Promociones automáticas (PadPio) y manuales.
> 🔗 **Mapeo desde:** `inc/funciones.php::buscarPromoPorProducto()`, `admin/routes/promociones.php`, `connect/padpio.php` (promos automáticas)
> 🟢 **Confianza:** ALTA

#### Servicios

| Servicio | Responsabilidad |
|---|---|
| `PromotionService` | CRUD de promociones manuales. Tipos: `00` (porcentaje PadPio), `0` (descuento por cantidad desde N), otros vía `promociones_tipos`. |
| `PromotionAutoService` | Sincronización de promos automáticas desde PadPio: detecta ofertas, calcula porcentajes, crea/elimina promos tipo `00`. |
| `PromotionEngineService` | Motor de pricing: dado un producto y cantidad, devuelve qué promociones aplican y el precio resultante. Reemplaza `buscarPromoPorProducto()`. |

#### Entidades

| Entidad | Tabla MySQL |
|---|---|
| `Promocion` | `promociones` (con `aplica_a_categorias`, `aplica_a_productos`, `excluir_*` como JSON) |
| `PromocionTipo` | `promociones_tipos` |

#### Dependencias

```
PromotionsModule imports:
  - ProductsModule (ProductPriceService — para verificar precios base)
  
PromotionsModule exports:
  - PromotionEngineService (usado por Cart, Checkout, Products)
```

---

### 3.17 ContentModule

> **Tipo:** Marketing — Contenido web: banners, sliders, FAQ, páginas estáticas, redes sociales.
> 🔗 **Mapeo desde:** `admin/routes/slider.php`, `admin/routes/banners.php`, `admin/routes/preguntas_frecuentes.php`, `admin/routes/secciones_adicionales.php`, `admin/routes/redes.php`, `admin/routes/carouseles.php`, `routes/preguntas-frecuentes.php`, `routes/secciones.php`
> 🟢 **Confianza:** ALTA

#### Controladores y rutas

| Controller | Método | Ruta | Auth | Descripción |
|---|---|---|---|---|
| `ContentPublicController` | GET | `/api/content/slider` | Público | Slides activos del homepage |
| `ContentPublicController` | GET | `/api/content/banners` | Público | Banners activos |
| `ContentPublicController` | GET | `/api/content/faq` | Público | Preguntas frecuentes |
| `ContentPublicController` | GET | `/api/content/page/:url` | Público | Página de sección adicional |
| `ContentPublicController` | GET | `/api/content/social` | Público | Redes sociales |
| `ContentPublicController` | GET | `/api/content/home-layout` | Público | Orden de módulos del home |
| `AdminContentController` | CRUD | `/api/admin/content/*` | Admin | CRUD de todos los contenidos |

#### Servicios

| Servicio | Responsabilidad |
|---|---|
| `SliderService` | CRUD de slides con ordenamiento. |
| `BannerService` | CRUD de banners con ubicación. Banners de promociones bancarias. |
| `FaqService` | CRUD de FAQ con ordenamiento. |
| `SectionService` | CRUD de secciones adicionales (CMS básico para páginas estáticas). |
| `SocialService` | CRUD de redes sociales. |
| `CarouselService` | Configuración de carouseles del home. |
| `HomeLayoutService` | Orden de módulos del home (`home_order`). |

#### Entidades

| Entidad | Tabla MySQL |
|---|---|
| `Slide` | `slider` |
| `Banner` | `banners` |
| `BannerPromocionBancaria` | `banners_promociones_bancarias` |
| `PreguntaFrecuente` | `preguntas_frecuentes` |
| `SeccionAdicional` | `secciones_adicionales` |
| `SeccionContenido` | `secciones_adicionales_contenido` |
| `RedSocial` | `redes` |
| `Carousel` | `carouseles` |
| `HomeOrder` | `home_order` |
| `HeaderSecundario` | `header_secundario` |

#### Dependencias

```
ContentModule:
  NO importa otros módulos de dominio.
  Exporta: (mínimo — el admin usa el módulo directamente)
```

---

### 3.18 ReviewsModule

> **Tipo:** Marketing — Reseñas y testimonios.
> 🔗 **Mapeo desde:** `admin/routes/resenias.php`
> 🟢 **Confianza:** MEDIA (alcance frontend no visible)

#### Controladores y rutas

| Controller | Método | Ruta | Auth | Descripción |
|---|---|---|---|---|
| `ReviewPublicController` | GET | `/api/reviews` | Público | Reseñas publicadas |
| `AdminReviewController` | CRUD | `/api/admin/reviews` | Admin | Gestión de reseñas |

#### Entidades

| Entidad | Tabla MySQL |
|---|---|
| `Resenia` | `resenias` |

#### Nota de mejora (Fase 2)
El sistema actual son testimonios manuales. En Fase 2 se migrará a reseñas reales de clientes sobre productos comprados, con verificación de compra y moderación. La tabla `resenias` puede extenderse con `producto_id`, `pedido_id`, `cliente_id`, `verificada`.

---

### 3.19 ContactModule

> **Tipo:** Marketing — Formulario de contacto.
> 🔗 **Mapeo desde:** `routes/contacto.php`, `routes/contacto-gracias.php`, `admin/routes/contacto.php`
> 🟢 **Confianza:** ALTA

#### Controladores y rutas

| Controller | Método | Ruta | Auth | Descripción |
|---|---|---|---|---|
| `ContactPublicController` | POST | `/api/contact` | Público | Enviar mensaje de contacto |
| `ContactPublicController` | GET | `/api/contact/areas` | Público | Listar áreas de contacto |
| `AdminContactController` | GET/PUT/DELETE | `/api/admin/contact` | Admin | Bandeja de mensajes, marcar leído |
| `AdminContactAreaController` | CRUD | `/api/admin/contact/areas` | Admin | CRUD de áreas |

#### Servicios

| Servicio | Responsabilidad |
|---|---|
| `ContactService` | Recepción de mensajes. Validación reCAPTCHA. Notificación al admin. |
| `ContactAreaService` | CRUD de áreas de contacto. |

#### Entidades

| Entidad | Tabla MySQL |
|---|---|
| `Contacto` | `contacto` |
| `ContactoArea` | `contacto_areas` |

---

### 3.20 ChatModule (Post-MVP)

> **Tipo:** Marketing — Chatbot IA con OpenAI.
> 🔗 **Mapeo desde:** `ajax/chat_handler.php`
> 🟡 **Post-MVP** (ver `01-feature-prioritization.md` F3-01)
> 🟢 **Confianza:** ALTA (pero diseño simplificado por ser Post-MVP)

#### Diseño conceptual (para Fase 3)

```typescript
@Controller('chat')
export class ChatController {
  @Post('message')
  @Throttle({ default: { limit: 10, ttl: 60000 } })
  async sendMessage(@Body() dto: ChatMessageDto, @CurrentUser() user?: any) {
    // 1. Cargar knowledge (cacheado en Redis, no en sesión)
    // 2. Inyectar system prompt con productos, precios (según lista cliente), stock
    // 3. Llamar a OpenAI (gpt-4o-mini, configurable por tenant .env)
    // 4. Parsear COMMAND_ADD_TO_CART en respuesta
    // 5. Devolver respuesta (Markdown → HTML)
  }
}
```

---

### 3.21 SurveysModule (Post-MVP)

> **Tipo:** Marketing — Encuestas post-compra.
> 🔗 **Mapeo desde:** `routes/encuesta.php`, `cron/encuestas.php`, `admin/routes/encuestas.php`
> 🟡 **Post-MVP** (ver `01-feature-prioritization.md` F3-02)
> 🟢 **Confianza:** ALTA

#### Entidades (referencia para migración futura)

| Entidad | Tabla MySQL |
|---|---|
| `Encuesta` | `encuestas` |
| `EncuestaPregunta` | `encuestas_preguntas` |
| `EncuestaEnvio` | `encuestas_envios` |
| `EncuestaRespuesta` | `encuestas_respuestas` |

---

### 3.22 IntegrationModule

> **Tipo:** Integración — Conexiones a sistemas externos.
> 🔗 **Mapeo desde:** `connect/padpio.php`, `importar_web/importar_dicomere.php`
> 🟢 **Confianza:** ALTA (PadPio), BAJA (Dicomere — no visible)

#### Servicios

| Servicio | Responsabilidad | Prioridad |
|---|---|---|
| `PadpioService` | Conexión a SQL Server (MSSQL) vía `node-mssql`. Sincronización de stock (tabla `Stock`) y precios (tabla `Precios`). Aplica multiplicadores de propiedades. Dispara `PromotionAutoService`. 2 BBDD: `PadPioResist:9143` y `PadPioMaxPaz:9144`. | **Fase 2** (MVP-11) |
| `PadpioSchedulerService` | Job programado con `@nestjs/schedule` + BullMQ para sincronización periódica. Reemplaza el botón manual del admin. | **Fase 2** |
| `DicomereService` | Importación de productos, clientes y pedidos desde Dicomere ERP. | **Post-MVP** (requiere investigación adicional) |

---

## 4. Diseño Transversal

### 4.1 Guards (Globales y por módulo)

| Guard | Scope | Descripción |
|---|---|---|
| `TenantGuard` | Global | Resuelve el tenant desde subdominio/header/env. Inyecta `TenantContext`. |
| `JwtAuthGuard` | Global (excluye rutas públicas) | Valida JWT access token. Extiende `AuthGuard('jwt')`. |
| `JwtAdminGuard` | Admin routes | Valida JWT admin con permisos. Extiende `AuthGuard('jwt-admin')`. |
| `PermissionsGuard` | Admin routes | Valida `user.permissions` contra los permisos requeridos por el endpoint (119 secciones). |
| `OptionalAuthGuard` | Rutas mixtas (catálogo, carrito) | Si hay token, carga usuario. Si no, continúa como anónimo. |
| `CsrfGuard` | Rutas con cookie-based auth | Solo aplica si el endpoint usa cookies de sesión (admin). Excluye webhooks vía `@SkipCsrf()`. |
| `ThrottlerGuard` | Global | Rate limiting multi-nivel (global + por endpoint). |

### 4.2 Interceptors

| Interceptor | Scope | Descripción |
|---|---|---|
| `AuditLogInterceptor` | Global | Loggea request/response con correlación ID. Redacta datos sensibles. |
| `TransformInterceptor` | Global | Envuelve respuestas en `{ success: true, data: T, meta?: { page, total } }`. |
| `CacheInterceptor` | Catálogo | Cachea respuestas GET de catálogo en Redis. Invalida por evento (`producto.updated`). |

### 4.3 Filtros de Excepción

| Filtro | Scope | Descripción |
|---|---|---|
| `HttpExceptionFilter` | Global | Formatea errores HTTP: `{ statusCode, message, errors?, timestamp, path }`. |
| `EntityNotFoundFilter` | Global | Captura `EntityNotFoundError` de TypeORM → 404. |
| `QueryFailedFilter` | Global | Captura errores de DB (unique constraint, FK) → 409/422. |
| `PaymentExceptionFilter` | Payments | Errores de APIs de pago → mensajes amigables. |

### 4.4 Middleware Pipeline

```
Request
  → cookieParser (refresh token en cookie)
  → SecurityHeadersMiddleware (X-Powered-By, Permissions-Policy, Cache-Control)
  → HttpsRedirectMiddleware (solo producción)
  → TenantMiddleware (resuelve tenant, configura DataSource)
  → Helmet (CSP, HSTS, headers de seguridad)
  → CORS
  → Rate Limiting (ThrottlerGuard)
  → Authentication (JwtAuthGuard / OptionalAuthGuard)
  → Authorization (PermissionsGuard - admin)
  → CSRF (CsrfGuard - solo cookie-based routes)
  → ValidationPipe (global)
  → Controller
  → Interceptors (AuditLog, Transform)
  → Exception Filters
  → Response
```

### 4.5 Eventos del Sistema (Event Emitter)

> **Mejora arquitectónica:** desacoplar acciones post-compra con eventos (ver `01-gaps-and-improvements.md` §2.1).

| Evento | Emitido por | Listeners |
|---|---|---|
| `payment.confirmed` | `PaymentWebhookService` | `StockService.descontarStock()`, `OrderEmailService.enviarEmailsPendientes()`, `ShippingService.confirmarEnvioZipnova()` |
| `payment.reverted` | `PaymentWebhookService` | `StockService.reponerStock()`, `OrderStateService.marcarReintegrado()` |
| `order.created` | `CheckoutConfirmationService` | `OrderEmailService.crearEmailsPendientes()`, `CustomerService.marcarClienteCompro()` |
| `order.status_changed` | `OrderStateService` | `OrderEmailService.notificarCambioEstado()` (Fase 2) |
| `product.updated` | Admin CRUD | `CacheService.invalidarCatalogo()` |
| `stock.low` | `StockService` | `NotificationService.alertaAdmin()` (Fase 2) |

---

## 5. Diagrama de Dependencias

```
                          ┌─────────────────────────────────────────┐
                          │              AppModule                  │
                          │  ConfigModule  TypeOrmModule  Throttler │
                          │  CommonModule           TenantModule    │
                          └─────────────────────────────────────────┘
                                              │
            ┌────────────┬──────────┬─────────┼─────────┬──────────┬────────────┐
            ▼            ▼          ▼         ▼         ▼          ▼            ▼
     ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────┐ ┌──────┐ ┌──────────┐ ┌──────────┐
     │AuthModule│ │UsersModule│ │ProductsMod│ │CartMod│ │Orders│ │PaymentsMod│ │ShippingMod│
     │          │ │          │ │          │ │      │ │      │ │          │ │          │
     │ JWT      │ │ Clientes │ │ Catálogo │ │Carrito│ │Pedidos│ │ MP,Modo, │ │ Envíos   │
     │ Passport │ │ Perfiles │ │ Filtros  │ │Cupones│ │Estados│ │ Transf.  │ │ Zipnova  │
     │ bcrypt   │ │ Direc.   │ │ Búsqueda │ │Pricing│ │Histor.│ │ Webhooks │ │ Tracking │
     └────┬─────┘ └────┬─────┘ └────┬─────┘ └──┬───┘ └──┬───┘ └────┬─────┘ └────┬─────┘
          │            │            │          │        │          │            │
          └────────────┼────────────┼──────────┼────────┼──────────┼────────────┘
                       │            │          │        │          │
                       ▼            ▼          ▼        ▼          ▼
              ┌──────────────────────────────────────────────────────────┐
              │                    CheckoutModule                        │
              │  Orquestador del flujo de compra (4 pasos)              │
              │  Importa: Cart, Shipping, Payments, Users, Orders       │
              └──────────────────────────────────────────────────────────┘
                                              │
            ┌────────────┬──────────┬─────────┼─────────┬──────────┬────────────┐
            ▼            ▼          ▼         ▼         ▼          ▼            ▼
     ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────┐ ┌──────┐ ┌──────────┐ ┌──────────┐
     │ Categories│ │BrandsMod │ │TagsModule│ │Coupons│ │Promot│ │ContentMod│ │ReviewsMod│
     │ Módulo   │ │          │ │          │ │Módulo│ │Módulo│ │          │ │          │
     │          │ │ Marcas   │ │ Tags     │ │Cupones│ │Promos │ │Banners  │ │ Reseñas  │
     │ Árbol    │ │          │ │          │ │      │ │Engine │ │FAQ,etc  │ │          │
     └──────────┘ └──────────┘ └──────────┘ └──────┘ └──────┘ └──────────┘ └──────────┘

                          ┌─────────────────────────────────────────┐
                          │              AdminModule                │
                          │  Agregador. Importa TODOS los módulos.  │
                          │  Dashboard, CRUDs, Config, Excel, Perms │
                          └─────────────────────────────────────────┘
                                              │
                          ┌───────────────────┴───────────────────┐
                          ▼                                       ▼
                   ┌──────────────┐                      ┌──────────────┐
                   │IntegrationMod│                      │ContactModule │
                   │ PadPio       │                      │ Formulario   │
                   │ Dicomere     │                      │ Devoluciones │
                   └──────────────┘                      └──────────────┘

Leyenda:
  ──→  Importa (dependencia directa)
  ═══  Eventos (dependencia indirecta vía EventEmitter)

Flujo de dependencias principal:
  Products ← Categories, Brands, Tags
  Cart ← Products, Coupons, Promotions
  Checkout ← Cart, Shipping, Payments, Users, Orders
  Admin ← TODOS los módulos
```

### Reglas de dependencia

1. **Ningún módulo de dominio importa a un módulo transaccional.** (Products no importa Cart, Categories no importa Checkout).
2. **AdminModule es la excepción:** importa a todos porque es el backoffice.
3. **CommonModule y TenantModule son globales:** disponibles en todos los módulos sin import explícito.
4. **La comunicación entre módulos transaccionales usa servicios exportados, NO acceso directo a repositorios.**
5. **Las acciones post-compra usan EventEmitter, NO llamadas directas entre módulos.**

---

## 6. Estrategia Multi-Tenant

> Basado en `01-gaps-and-improvements.md` §4.4

### Modelo: Base de datos por tenant (mantener aislamiento actual)

**Resolución de tenant:**

```typescript
// tenant.middleware.ts
@Injectable()
export class TenantMiddleware implements NestMiddleware {
  use(req: Request, res: Response, next: NextFunction) {
    // 1. Resolver tenant ID
    const tenantId =
      req.headers['x-tenant-id'] as string ||           // Header
      req.subdomains?.[0] ||                             // Subdominio: {tenant}.lumba.com
      process.env.TENANT_ID ||                           // Variable de entorno
      'default';

    // 2. Configurar DataSource para este tenant
    const dataSource = this.tenantService.getDataSource(tenantId);

    // 3. Inyectar en request
    (req as any).tenantContext = { tenantId, dataSource };

    next();
  }
}
```

**Conexiones TypeORM dinámicas:**

```typescript
// tenant.service.ts
@Injectable()
export class TenantService {
  private dataSources = new Map<string, DataSource>();

  async getDataSource(tenantId: string): Promise<DataSource> {
    if (this.dataSources.has(tenantId)) {
      return this.dataSources.get(tenantId);
    }

    const config = await this.loadTenantDbConfig(tenantId);
    const dataSource = new DataSource({
      type: 'mysql',
      ...config,
      entities: [__dirname + '/../**/*.entity{.ts,.js}'],
      migrations: [__dirname + '/../database/migrations/*{.ts,.js}'],
    });

    await dataSource.initialize();
    this.dataSources.set(tenantId, dataSource);
    return dataSource;
  }
}
```

**Configuración por tenant:**

| Tipo de configuración | Dónde se almacena | Ejemplos |
|---|---|---|
| **Secretos** (API keys, passwords) | `.env.{tenant}` o vault | `MERCADOPAGO_ACCESS_TOKEN`, `SMTP_PASSWORD` |
| **Settings de negocio** | DB del tenant (tabla `configuracion` migrada a entidad tipada `TenantSetting`) | `compra_minima`, `cuotas_mercadopago`, `metodos_pago` |
| **Identidad visual** | DB del tenant + archivos (logos, CSS) | `logo_menu`, `colores`, `tipografias` |
| **Contenido** | Tablas de contenido en DB del tenant | `slider`, `banners`, `preguntas_frecuentes` |

---

## 7. Mapeo: PHP Actual → NestJS

### 7.1 Mapeo de endpoints frontend

| URL Pública PHP | Ruta NestJS | Módulo | Cambio |
|---|---|---|---|
| `/productos` | `GET /api/products` | Products | Parámetros vía query string |
| `/producto/{url}` | `GET /api/products/:url` | Products | Sin cambio conceptual |
| `/categoria/{url}` | `GET /api/products?categoriaSlug={url}` | Products | Se unifica en products con filtro |
| `/marca/{url}` | `GET /api/products?marcaSlug={url}` | Products | Se unifica en products con filtro |
| `/tag/{url}` | `GET /api/products?tagSlug={url}` | Products | Se unifica en products con filtro |
| `/cart` | `GET /api/cart` | Cart | API REST |
| `/checkout/1` | `GET/POST /api/checkout` | Checkout | Single-page stateful |
| `/checkout/2` | `POST /api/checkout/step/2` | Checkout | Paso unificado |
| `/checkout/3` | `POST /api/checkout/step/3` | Checkout | Paso unificado |
| `/checkout/4` | `POST /api/checkout/confirm` | Checkout | Confirmación final |
| `/login` / `/account_signin` | `POST /api/auth/login` | Auth | JWT en vez de sesión |
| `/account_register` | `POST /api/auth/register` | Auth | bcrypt en vez de md5 |
| `/account_recover` | `POST /api/auth/recover` | Auth | Token con expiración |
| `/account_profile` | `GET/PATCH /api/users/me` | Users | API REST |
| `/account_addresses` | `GET/POST /api/users/me/addresses` | Users | API REST |
| `/account_orders` | `GET /api/orders` | Orders | API REST |
| `/account_order/{hash}` | `GET /api/orders/:hash` | Orders | API REST |
| `/account_wish_list` | `GET /api/users/me/wishlist` | Users | API REST |
| `/contacto` | `POST /api/contact` | Contact | API REST |
| `/devoluciones` | `POST /api/devolutions` | Contact | API REST |
| `/comprobantes/{hash}` | `POST /api/payments/comprobante/:hash` | Payments | API REST |
| `/preguntas-frecuentes` | `GET /api/content/faq` | Content | API REST |
| `/secciones/{url}` | `GET /api/content/page/:url` | Content | API REST |

### 7.2 Mapeo de AJAX endpoints

| AJAX PHP | NestJS Endpoint | Módulo |
|---|---|---|
| `agregarcarrito.php` | `POST /api/cart/items` | Cart |
| `favoritos.php` | `POST /api/users/me/wishlist/:productId` | Users |
| `buscarpropiedades.php` | `GET /api/products/filter/properties` | Products |
| `buscarsku.php` | `GET /api/admin/products/search?sku=` | Admin |
| `calcular_cantidad_carrito.php` | `GET /api/cart/summary` | Cart |
| `cotizar_envio_con_cp.php` | `POST /api/shipping/quote` | Shipping |
| `cp.php` | `GET /api/geo/codigos-postales?cp=` | Common |
| `localidades.php` | `GET /api/geo/localidades` | Common |
| `localidades_con_cp.php` | `GET /api/geo/localidades?provinciaId=` | Common |
| `provincias_con_localidad.php` | `GET /api/geo/provincias` | Common |

### 7.3 Mapeo de webhooks

| PHP Webhook | NestJS Endpoint | Módulo | Seguridad |
|---|---|---|---|
| `connect/mp_ipn.php` | `POST /api/webhooks/mercadopago` | Payments | **Nuevo:** validar `x-signature` |
| `connect/modo_webhook.php` | `POST /api/webhooks/modo` | Payments | **Nuevo:** validar firma |
| `connect/zn_webhook.php` | `POST /api/webhooks/zipnova` | Shipping | **Corregir bug:** usar variable real, no literal |

---

## Resumen de Decisiones Arquitectónicas

| Decisión | Elección | Impacto |
|---|---|---|
| ORM | TypeORM con migraciones | Trazabilidad del schema. Rollback de migraciones. |
| Autenticación | JWT stateless (access 15min + refresh 7d) | Escalabilidad horizontal. Sin sesiones en servidor. |
| Carrito | Persistente en DB (reemplaza sesión PHP) | Cross-device. Recuperación post-sesión. No se pierde. |
| Checkout | Estado en DB + single-page (Fase 2) | Reduce abandono. No depende de sesión. |
| Pricing | Servicio centralizado `PricingService` | Consistencia. Testeable. Reutilizable. |
| Post-compra | Event-driven (EventEmitter) | Desacoplamiento. Reintentos independientes. |
| Webhooks | Validación de firma criptográfica | **Crítico:** el sistema actual no valida. |
| Multi-tenant | DB por tenant + resolución por dominio | Mantiene aislamiento. Reemplaza branches Git. |
| Admin | Permisos granulares (119 secciones) | Migrar modelo actual. Agregar bcrypt urgente. |
| Logging | Winston estructurado con redacción | Auditoría de seguridad. Debugging. |

---

> **Confianza global de este documento:** ALTA. El diseño está basado 100% en los outputs de discovery del System Auditor, el modelo de datos inferido, y las decisiones del Product Owner. Las entidades, servicios y endpoints mapean directamente a los artefactos del sistema PHP actual. Las decisiones de mejora están justificadas en los gaps y antipatrones documentados. Las configuraciones de seguridad están alineadas con `01-security-nestjs-config.md`.
>
> **Lo que ES hecho (del auditor):** estructura de archivos PHP, endpoints, tablas MySQL, flujos de negocio, integraciones.
> **Lo que ES diseño (de este documento):** arquitectura de módulos NestJS, DTOs, servicios, entidades TypeORM, strategy patterns, eventos, pipeline de middleware, mapeo de rutas.
> **Lo que ES decisión arquitectónica:** TypeORM vs Prisma, JWT stateless vs sesiones, carrito en DB vs Redis, event-driven vs llamadas directas, multi-tenant por DB vs schema.

---

*Documento preparado por el Backend Architect basado exclusivamente en los outputs del System Auditor (2026-06-04), Product Owner (2026-06-08) y Security Agent (2026-06-08).*
