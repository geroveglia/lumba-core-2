# 01 — Arquitectura Frontend Lumba Ecommerce

> **Proyecto:** Lumba Ecommerce (Brownfield — migración PHP vanilla + Bootstrap 5 → React + Tailwind CSS + NestJS API)
> **Fecha:** 2026-06-09
> **Rol:** Frontend Architect
> **Modelo:** deepseek-v4-pro
> **Nivel de confianza global:** ALTA
> **Stack decidido por Gero:** Vite + React + Tailwind CSS + Axios + SWR + React Hook Form + Zod + React Router DOM

---

## Índice

1. [Stack Completo](#1-stack-completo)
2. [Estructura del Proyecto](#2-estructura-del-proyecto)
3. [Sistema de Rutas (React Router)](#3-sistema-de-rutas)
4. [Data Fetching (Axios + SWR)](#4-data-fetching)
5. [Estrategia de Estado (Zustand)](#5-estrategia-de-estado)
6. [Formularios (React Hook Form + Zod)](#6-formularios)
7. [Estilos — Tailwind CSS](#7-estilos--tailwind-css)
8. [SEO (React Helmet + prerendering)](#8-seo)
9. [Páginas y Layouts MVP](#9-páginas-y-layouts-mvp)
10. [Estrategia Multi-Tenant](#10-estrategia-multi-tenant)
11. [Integraciones](#11-integraciones)
12. [Build & Deploy (Vite)](#12-build--deploy)
13. [Riesgos](#13-riesgos)

---

## 1. Stack Completo

```
Vite 6                     → Build tool (dev server HMR, build production con Rollup)
React 18                   → UI library
TypeScript 5 (strict)      → Lenguaje
Tailwind CSS 4             → Sistema de estilos (decidido por Gero)
Axios 1                    → HTTP client (interceptors, cancel, timeout, error handling)
SWR 2                      → Data fetching + cache + revalidation (usa Axios como fetcher)
Zustand v5                 → Estado global cliente (carrito, auth, tenant, UI)
React Hook Form v7         → Formularios performantes (uncontrolled inputs)
Zod v3                     → Schemas de validación (client-side, coherencia con class-validator del backend)
React Router DOM v6        → Routing SPA (BrowserRouter, lazy loading, loaders)
React Helmet Async         → Meta tags dinámicos (SEO en SPA)
Radix UI                   → Primitives headless accesibles (Dialog, Dropdown, Tabs, Accordion)
React Dropzone             → Upload de imágenes/comprobantes
Swiper                     → Carousel/Slider
Recharts                   → Gráficos del admin dashboard
```

### Justificación de cada herramienta

| Herramienta | Justificación |
|---|---|
| **Vite** | Build tool moderno. HMR instantáneo en dev. Build con Rollup (tree-shaking, code-splitting). Reemplaza a CRA (deprecado) y es más simple que Next.js para SPA. |
| **Axios** | HTTP client con interceptores (JWT refresh automático), cancelación, timeout, transformación de responses. Más ergonómico que `fetch` para APIs REST. |
| **SWR** | Estrategia stale-while-revalidate. Cache automático. Revalidación en focus. Mutations con optimistic updates. Más simple que TanStack Query para este caso. |
| **React Router DOM** | Router estándar para SPAs. Lazy loading por ruta. Layout routes. Search params para filtros. |
| **React Helmet Async** | Meta tags dinámicos por página. Necesario porque no hay SSR. Google indexa JS-rendered content en SPA (con limitaciones). |
| **Zustand** | Selector-based → sin re-renders en cascada. Menos boilerplate que Context. Persist middleware para carrito. |

### Lo que NO se usa (y por qué)

| Herramienta descartada | Motivo |
|---|---|
| Next.js | Gero decidió Vite. Next.js agrega complejidad de SSR/SSG/RSC innecesaria para este proyecto. |
| TanStack Query | SWR es más simple. Misma funcionalidad core (cache, revalidation, mutations). Menos API surface. |
| fetch nativo | Axios provee interceptores, cancelación, timeout y mejor DX para APIs REST. |
| Redux / Context | Zustand es más simple, menos boilerplate, mejor performance (selectors sin re-renders). |
| Angular / Vue | Gero decidió React. Equipo tiene experiencia React. |

---

## 2. Estructura del Proyecto

```
apps/frontend/
├── vite.config.ts                # Configuración de Vite
├── tsconfig.json
├── tailwind.config.ts
├── package.json
├── .env                          # VITE_API_URL=http://localhost:3000/api
├── .env.production               # VITE_API_URL=https://api.lumba.com/api
├── index.html                    # Entry point HTML
│
├── public/
│   ├── logos/{tenant}/           # Logos por tenant (cacheables)
│   └── favicons/{tenant}/        # Favicons por tenant
│
├── src/
│   ├── main.tsx                   # Entry point React: BrowserRouter + providers
│   ├── App.tsx                    # Rutas principales
│   │
│   ├── routes/                    # Definición de rutas
│   │   └── index.tsx              # createBrowserRouter o <Routes>
│   │
│   ├── pages/                     # Páginas (una por ruta)
│   │   ├── HomePage.tsx
│   │   ├── CatalogPage.tsx
│   │   ├── ProductDetailPage.tsx
│   │   ├── CartPage.tsx
│   │   ├── CheckoutPage.tsx
│   │   ├── LoginPage.tsx
│   │   ├── RegisterPage.tsx
│   │   ├── RecoverPage.tsx
│   │   ├── ResetPasswordPage.tsx
│   │   ├── ProfilePage.tsx
│   │   ├── OrdersPage.tsx
│   │   ├── OrderDetailPage.tsx
│   │   ├── AddressesPage.tsx
│   │   ├── FavoritesPage.tsx
│   │   ├── ContactPage.tsx
│   │   ├── DevolutionsPage.tsx
│   │   ├── FaqPage.tsx
│   │   ├── SectionPage.tsx        # Páginas de contenido (términos, privacidad, etc.)
│   │   ├── NotFoundPage.tsx
│   │   └── admin/
│   │       ├── AdminLoginPage.tsx
│   │       ├── DashboardPage.tsx
│   │       ├── ProductsListPage.tsx
│   │       ├── ProductFormPage.tsx
│   │       ├── OrdersListPage.tsx
│   │       ├── OrderDetailPage.tsx
│   │       ├── CustomersListPage.tsx
│   │       ├── CategoriesListPage.tsx
│   │       ├── BrandsListPage.tsx
│   │       ├── TagsListPage.tsx
│   │       ├── PropertiesListPage.tsx
│   │       ├── CouponsListPage.tsx
│   │       ├── ConfigPage.tsx
│   │       └── ...
│   │
│   ├── components/                # Componentes reutilizables
│   │   ├── ui/                    # Atómicos
│   │   │   ├── Button.tsx
│   │   │   ├── Input.tsx
│   │   │   ├── Select.tsx
│   │   │   ├── Badge.tsx
│   │   │   ├── Skeleton.tsx
│   │   │   ├── Modal.tsx
│   │   │   ├── Drawer.tsx
│   │   │   ├── Dropdown.tsx
│   │   │   ├── Toast.tsx
│   │   │   ├── Pagination.tsx
│   │   │   ├── Breadcrumb.tsx
│   │   │   ├── Tabs.tsx
│   │   │   ├── Accordion.tsx
│   │   │   ├── QuantitySelector.tsx
│   │   │   ├── Spinner.tsx
│   │   │   ├── StockIndicator.tsx
│   │   │   ├── Alert.tsx
│   │   │   ├── Toggle.tsx
│   │   │   ├── Tooltip.tsx
│   │   │   └── EmptyState.tsx
│   │   ├── layout/                # Layouts + shells
│   │   │   ├── MainLayout.tsx
│   │   │   ├── Header.tsx
│   │   │   ├── Footer.tsx
│   │   │   ├── AdminLayout.tsx
│   │   │   ├── AdminSidebar.tsx
│   │   │   ├── CheckoutLayout.tsx
│   │   │   ├── AccountLayout.tsx
│   │   │   ├── AuthLayout.tsx
│   │   │   └── StepIndicator.tsx
│   │   ├── catalog/
│   │   │   ├── ProductCard.tsx
│   │   │   ├── ProductGrid.tsx
│   │   │   ├── FilterPanel.tsx
│   │   │   ├── ImageGallery.tsx
│   │   │   └── VariantSelector.tsx
│   │   ├── cart/
│   │   │   ├── CartItem.tsx
│   │   │   ├── CartSummary.tsx
│   │   │   └── CouponInput.tsx
│   │   ├── checkout/
│   │   │   ├── CheckoutForm.tsx
│   │   │   ├── CheckoutStep1.tsx
│   │   │   ├── CheckoutStep2.tsx
│   │   │   ├── CheckoutStep3.tsx
│   │   │   ├── CheckoutStep4.tsx
│   │   │   ├── PaymentMethodSelector.tsx
│   │   │   └── AddressForm.tsx
│   │   ├── account/
│   │   │   ├── OrderCard.tsx
│   │   │   ├── OrderTimeline.tsx
│   │   │   └── AddressCard.tsx
│   │   ├── admin/
│   │   │   ├── AdminTable.tsx
│   │   │   ├── AdminForm.tsx
│   │   │   ├── KpiCard.tsx
│   │   │   ├── ImageUploader.tsx
│   │   │   └── MonthYearPicker.tsx
│   │   └── shared/
│   │       ├── PriceDisplay.tsx
│   │       ├── SearchBar.tsx
│   │       ├── ProductSchemaOrg.tsx
│   │       └── BreadcrumbSchemaOrg.tsx
│   │
│   ├── hooks/                     # Custom hooks
│   │   ├── use-debounce.ts
│   │   ├── use-media-query.ts
│   │   ├── use-recaptcha.ts
│   │   ├── use-geo.ts             # Provincias, localidades, CP
│   │   └── use-auth.ts
│   │
│   ├── lib/                       # Utilidades
│   │   ├── axios.ts               # Instancia de Axios + interceptores JWT refresh
│   │   ├── currency.ts            # formatCurrency (Intl.NumberFormat es-AR)
│   │   ├── validators.ts          # Schemas Zod
│   │   └── constants.ts
│   │
│   ├── stores/                    # Zustand stores
│   │   ├── cart-store.ts
│   │   ├── auth-store.ts
│   │   ├── tenant-store.ts
│   │   └── ui-store.ts            # Modales, toasts, sidebar mobile
│   │
│   ├── swr/                       # SWR hooks (data fetching)
│   │   ├── use-products.ts
│   │   ├── use-cart.ts
│   │   ├── use-checkout.ts
│   │   ├── use-orders.ts
│   │   ├── use-auth.ts
│   │   ├── use-users.ts
│   │   ├── use-content.ts
│   │   ├── use-geo.ts
│   │   └── admin/
│   │       ├── use-dashboard.ts
│   │       ├── use-admin-products.ts
│   │       └── ...
│   │
│   ├── providers/                 # React providers
│   │   ├── tenant-provider.tsx    # CSS custom properties + tenant config
│   │   └── toast-provider.tsx
│   │
│   └── types/                     # TypeScript interfaces
│       ├── product.ts
│       ├── cart.ts
│       ├── checkout.ts
│       ├── order.ts
│       ├── user.ts
│       └── api.ts                 # API response envelope
```

---

## 3. Sistema de Rutas (React Router DOM)

### Configuración principal

```typescript
// src/App.tsx
import { BrowserRouter, Routes, Route, Outlet } from 'react-router-dom';
import { lazy, Suspense } from 'react';

// Lazy loading por página
const HomePage = lazy(() => import('./pages/HomePage'));
const CatalogPage = lazy(() => import('./pages/CatalogPage'));
const ProductDetailPage = lazy(() => import('./pages/ProductDetailPage'));
const CartPage = lazy(() => import('./pages/CartPage'));
const CheckoutPage = lazy(() => import('./pages/CheckoutPage'));
const LoginPage = lazy(() => import('./pages/LoginPage'));
// ... resto de páginas

export default function App() {
  return (
    <BrowserRouter>
      <TenantProvider>
        <ToastProvider>
          <Suspense fallback={<PageSkeleton />}>
            <Routes>
              {/* Ruta pública — MainLayout */}
              <Route element={<MainLayout />}>
                <Route index element={<HomePage />} />
                <Route path="productos" element={<CatalogPage />} />
                <Route path="productos/:slug" element={<ProductDetailPage />} />
                <Route path="categoria/:slug" element={<CatalogPage />} />
                <Route path="marca/:slug" element={<CatalogPage />} />
                <Route path="tag/:slug" element={<CatalogPage />} />
                <Route path="carrito" element={<CartPage />} />
                <Route path="contacto" element={<ContactPage />} />
                <Route path="devoluciones" element={<DevolutionsPage />} />
                <Route path="preguntas-frecuentes" element={<FaqPage />} />
                <Route path="secciones/:slug" element={<SectionPage />} />
              </Route>

              {/* Checkout — layout propio */}
              <Route element={<CheckoutLayout />}>
                <Route path="checkout" element={<CheckoutPage />} />
              </Route>

              {/* Auth — layout centrado */}
              <Route element={<AuthLayout />}>
                <Route path="login" element={<LoginPage />} />
                <Route path="registro" element={<RegisterPage />} />
                <Route path="recuperar" element={<RecoverPage />} />
                <Route path="recuperar/:hash" element={<ResetPasswordPage />} />
              </Route>

              {/* Cuenta — protegido */}
              <Route element={<ProtectedRoute><AccountLayout /></ProtectedRoute>}>
                <Route path="cuenta/perfil" element={<ProfilePage />} />
                <Route path="cuenta/pedidos" element={<OrdersPage />} />
                <Route path="cuenta/pedidos/:hash" element={<OrderDetailPage />} />
                <Route path="cuenta/direcciones" element={<AddressesPage />} />
                <Route path="cuenta/favoritos" element={<FavoritesPage />} />
                <Route path="empresa" element={<CompanyPage />} />
              </Route>

              {/* Admin — protegido con role='admin' */}
              <Route element={<ProtectedRoute role="admin"><AdminLayout /></ProtectedRoute>}>
                <Route path="admin" element={<DashboardPage />} />
                <Route path="admin/productos" element={<ProductsListPage />} />
                <Route path="admin/productos/nuevo" element={<ProductFormPage />} />
                <Route path="admin/productos/:id" element={<ProductFormPage />} />
                <Route path="admin/pedidos" element={<OrdersListPage />} />
                <Route path="admin/pedidos/:id" element={<AdminOrderDetailPage />} />
                <Route path="admin/clientes" element={<CustomersListPage />} />
                <Route path="admin/categorias" element={<CategoriesListPage />} />
                <Route path="admin/marcas" element={<BrandsListPage />} />
                <Route path="admin/tags" element={<TagsListPage />} />
                <Route path="admin/propiedades" element={<PropertiesListPage />} />
                <Route path="admin/configuracion" element={<ConfigPage />} />
                {/* ... resto de rutas admin */}
              </Route>

              {/* Admin login */}
              <Route path="admin/login" element={<AdminLoginPage />} />

              {/* 404 */}
              <Route path="*" element={<NotFoundPage />} />
            </Routes>
          </Suspense>
        </ToastProvider>
      </TenantProvider>
    </BrowserRouter>
  );
}
```

### Ruta protegida (guard)

```typescript
// src/components/layout/ProtectedRoute.tsx
import { Navigate, useLocation } from 'react-router-dom';
import { useAuthStore } from '@/stores/auth-store';

interface ProtectedRouteProps {
  children: React.ReactNode;
  role?: 'admin';
}

export function ProtectedRoute({ children, role }: ProtectedRouteProps) {
  const { user, isLoading } = useAuth();
  const location = useLocation();

  if (isLoading) return <PageSkeleton />;

  if (!user) {
    return <Navigate to={role === 'admin' ? '/admin/login' : '/login'} state={{ from: location.pathname }} replace />;
  }

  if (role === 'admin' && user.role !== 'admin') {
    return <Navigate to="/" replace />;
  }

  return <>{children}</>;
}
```

### Mapeo completo de rutas

| Ruta | Página | Layout | Auth | Endpoints API principales |
|---|---|---|---|---|
| `/` | HomePage | MainLayout | Público | `GET /api/content/slider`, `/banners`, `/products?destacados=1` |
| `/productos` | CatalogPage | MainLayout | Público | `GET /api/products`, `/categories` |
| `/productos/:slug` | ProductDetailPage | MainLayout | Público | `GET /api/products/:url`, `/products/:url/related` |
| `/categoria/:slug` | CatalogPage | MainLayout | Público | `GET /api/products?categoriaId=X` |
| `/marca/:slug` | CatalogPage | MainLayout | Público | `GET /api/products?marcaId=X` |
| `/carrito` | CartPage | MainLayout | Opcional | `GET /api/cart` |
| `/checkout` | CheckoutPage | CheckoutLayout | Opcional | `GET /api/checkout` |
| `/login` | LoginPage | AuthLayout | Público | `POST /api/auth/login` |
| `/registro` | RegisterPage | AuthLayout | Público | `POST /api/auth/register` |
| `/recuperar` | RecoverPage | AuthLayout | Público | `POST /api/auth/recover` |
| `/recuperar/:hash` | ResetPasswordPage | AuthLayout | Público | `POST /api/auth/recover/:hash` |
| `/cuenta/perfil` | ProfilePage | AccountLayout | JWT | `GET PATCH /api/users/me` |
| `/cuenta/pedidos` | OrdersPage | AccountLayout | JWT | `GET /api/orders` |
| `/cuenta/pedidos/:hash` | OrderDetailPage | AccountLayout | JWT | `GET /api/orders/:hash` |
| `/cuenta/direcciones` | AddressesPage | AccountLayout | JWT | `GET POST PUT DELETE /api/users/me/addresses` |
| `/cuenta/favoritos` | FavoritesPage | AccountLayout | JWT | `GET POST /api/users/me/wishlist` |
| `/admin` | DashboardPage | AdminLayout | Admin JWT | `GET /api/admin/dashboard` |
| `/admin/productos` | ProductsListPage | AdminLayout | Admin JWT | `GET /api/admin/products` |
| `*` | NotFoundPage | MainLayout | Público | — |

---

## 4. Data Fetching (Axios + SWR)

### Configuración de Axios

```typescript
// src/lib/axios.ts
import axios from 'axios';
import { useAuthStore } from '@/stores/auth-store';

const API_BASE = import.meta.env.VITE_API_URL || 'http://localhost:3000/api';

export const apiClient = axios.create({
  baseURL: API_BASE,
  timeout: 15000,
  headers: { 'Content-Type': 'application/json' },
  withCredentials: true,  // Cookies para refresh token
});

// Request interceptor — JWT
apiClient.interceptors.request.use((config) => {
  const token = useAuthStore.getState().accessToken;
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});

// Response interceptor — 401 → refresh token
let isRefreshing = false;
let failedQueue: Array<{ resolve: (token: string) => void; reject: (err: unknown) => void }> = [];

const processQueue = (error: unknown, token: string | null = null) => {
  failedQueue.forEach(p => {
    if (error) p.reject(error);
    else p.resolve(token!);
  });
  failedQueue = [];
};

apiClient.interceptors.response.use(
  (response) => response,
  async (error) => {
    const originalRequest = error.config;

    // Si es 401 y no es la ruta de refresh ni auth
    if (error.response?.status === 401 && !originalRequest._retry
        && !originalRequest.url?.includes('/auth/')) {
      
      if (isRefreshing) {
        // Encolar request hasta que termine el refresh
        return new Promise((resolve, reject) => {
          failedQueue.push({ resolve, reject });
        }).then(token => {
          originalRequest.headers.Authorization = `Bearer ${token}`;
          return apiClient(originalRequest);
        });
      }

      originalRequest._retry = true;
      isRefreshing = true;

      try {
        const { data } = await axios.post(`${API_BASE}/auth/refresh`, {}, { withCredentials: true });
        const newToken = data.accessToken;
        useAuthStore.getState().setAccessToken(newToken);
        processQueue(null, newToken);
        originalRequest.headers.Authorization = `Bearer ${newToken}`;
        return apiClient(originalRequest);
      } catch (refreshError) {
        processQueue(refreshError, null);
        useAuthStore.getState().logout();
        window.location.href = '/login';
        return Promise.reject(refreshError);
      } finally {
        isRefreshing = false;
      }
    }

    return Promise.reject(error);
  }
);
```

### SWR hooks

```typescript
// src/swr/use-products.ts
import useSWR from 'swr';
import { apiClient } from '@/lib/axios';

export function useProducts(params?: Record<string, string>) {
  const queryString = params ? '?' + new URLSearchParams(params).toString() : '';

  return useSWR(
    `/products${queryString}`,
    (url: string) => apiClient.get(url).then(res => res.data.data),
    {
      revalidateOnFocus: false,  // Ecommerce: no revalidar al volver a la pestaña
      dedupingInterval: 2000,    // 2s entre requests idénticos
    }
  );
}

export function useProduct(slug: string) {
  return useSWR(
    slug ? `/products/${slug}` : null,
    (url: string) => apiClient.get(url).then(res => res.data.data),
    {
      revalidateOnFocus: false,
      dedupingInterval: 60000,   // 1 min para detalle de producto
    }
  );
}
```

```typescript
// src/swr/use-cart.ts
import useSWR from 'swr';
import useSWRMutation from 'swr/mutation';
import { apiClient } from '@/lib/axios';

export function useCart() {
  return useSWR('/cart', (url) => apiClient.get(url).then(r => r.data.data));
}

export function useCartSummary() {
  // Endpoint ligero para el mini-carrito del header
  return useSWR('/cart/summary', (url) => apiClient.get(url).then(r => r.data.data), {
    revalidateOnFocus: false,
    refreshInterval: 30000,      // Polling cada 30s para mantener fresco el counter
  });
}

export function useAddToCart() {
  const { mutate } = useCart();

  return useSWRMutation(
    '/cart/items',
    (url, { arg }: { arg: AddToCartDto }) => apiClient.post(url, arg).then(r => r.data.data),
    {
      onSuccess: (data) => {
        mutate(data, false);  // Optimistic update
      },
    }
  );
}
```

```typescript
// src/swr/use-checkout.ts
import useSWR from 'swr';
import useSWRMutation from 'swr/mutation';

export function useCheckout() {
  return useSWR('/checkout', (url) => apiClient.get(url).then(r => r.data.data));
}

export function useSaveCheckoutStep(step: number) {
  const { mutate } = useCheckout();

  return useSWRMutation(
    `/checkout/step/${step}`,
    (url, { arg }: { arg: unknown }) => apiClient.post(url, arg).then(r => r.data.data),
    {
      onSuccess: (data) => mutate(data, false),
    }
  );
}

export function useConfirmCheckout() {
  return useSWRMutation(
    '/checkout/confirm',
    (url) => apiClient.post(url).then(r => r.data.data),
  );
}
```

### Convención de respuestas

Todas las respuestas de SWR siguen la estructura:

```typescript
const {
  data,           // T | undefined — los datos
  error,          // ApiError | undefined
  isLoading,      // boolean — primera carga
  isValidating,   // boolean — revalidación (filtros aplicándose)
  mutate,         // (data?, opts?) => Promise — actualización manual / optimistic
} = useSWR(key, fetcher);
```

### Mutations (POST, PUT, PATCH, DELETE)

```typescript
// Para operaciones sin SWR (ej: logout, upload de comprobante)
export async function uploadComprobante(hash: string, file: File) {
  const formData = new FormData();
  formData.append('comprobante', file);
  return apiClient.post(`/payments/comprobante/${hash}`, formData, {
    headers: { 'Content-Type': 'multipart/form-data' },
  });
}

// Mutation con SWR para operaciones que modifican datos cacheados
export function useUpdateProfile() {
  const { mutate } = useSWR('/users/me');

  return useSWRMutation(
    '/users/me',
    (url, { arg }) => apiClient.patch(url, arg).then(r => r.data.data),
    {
      onSuccess: (data) => mutate(data, false),
    }
  );
}
```

---

## 5. Estrategia de Estado (Zustand)

### Matriz de estado

| Estado | Dónde vive | Persistencia |
|---|---|---|
| **Carrito** | Zustand `cartStore` | `localStorage` (visitante), sincronizado con API vía SWR (logueado) |
| **Auth** | Zustand `authStore` | Access token en memoria, refresh token en cookie HTTP-only |
| **Tenant** | Zustand `tenantStore` + CSS vars en `:root` | Cookie `X-Tenant-ID` |
| **UI** | Zustand `uiStore` | Memoria (efímero) |
| **Datos API** | SWR cache | Memoria (cache de SWR) |
| **Formularios** | React Hook Form (local) | Memoria |

```typescript
// src/stores/cart-store.ts
import { create } from 'zustand';
import { persist } from 'zustand/middleware';

interface CartState {
  itemsCount: number;
  total: number;
  setFromApi: (data: { items: Array<{ cantidad: number }>; resumen: { total: number } }) => void;
  clear: () => void;
}

export const useCartStore = create<CartState>()(
  persist(
    (set) => ({
      itemsCount: 0,
      total: 0,
      setFromApi: (data) => set({
        itemsCount: data.items.reduce((s, i) => s + i.cantidad, 0),
        total: data.resumen.total,
      }),
      clear: () => set({ itemsCount: 0, total: 0 }),
    }),
    { name: 'lumba-cart', partialize: (s) => ({ itemsCount: s.itemsCount, total: s.total }) }
  )
);
```

```typescript
// src/stores/auth-store.ts
import { create } from 'zustand';

interface AuthState {
  accessToken: string | null;
  user: { id: number; email: string; nombre: string; role: 'customer' | 'admin' } | null;
  isLoading: boolean;
  setAccessToken: (token: string) => void;
  setUser: (user: AuthState['user']) => void;
  logout: () => void;
}

export const useAuthStore = create<AuthState>((set) => ({
  accessToken: null,
  user: null,
  isLoading: true,
  setAccessToken: (token) => set({ accessToken: token }),
  setUser: (user) => set({ user, isLoading: false }),
  logout: () => set({ accessToken: null, user: null, isLoading: false }),
}));
```

```typescript
// src/stores/tenant-store.ts
export const useTenantStore = create<TenantState>((set) => ({
  tenant: null,
  setTenant: (config: TenantConfig) => {
    // Inyectar CSS custom properties
    const root = document.documentElement;
    root.setAttribute('data-tenant', config.id);
    if (config.theme.colors) {
      Object.entries(config.theme.colors).forEach(([k, v]) => {
        root.style.setProperty(`--color-${k}`, v);
      });
    }
    set({ tenant: config });
  },
}));
```

---

## 6. Formularios (React Hook Form + Zod)

```typescript
// src/lib/validators.ts
import { z } from 'zod';

export const checkoutDataSchema = z.object({
  tipoClienteId: z.number().optional(),
  email: z.string().email('Email inválido'),
  nombre: z.string().min(2, 'Mínimo 2 caracteres').optional(),
  apellido: z.string().min(2, 'Mínimo 2 caracteres').optional(),
  razonSocial: z.string().min(2).optional(),
  dni: z.string().regex(/^\d{7,8}$/, 'DNI inválido').optional(),
  cuit: z.string().regex(/^\d{2}-\d{8}-\d{1}$/, 'CUIT inválido').optional(),
  area: z.string().regex(/^\d{2,4}$/).optional(),
  telefono: z.string().regex(/^\d{6,10}$/).optional(),
}).refine(
  (d) => d.tipoClienteId === 2 ? !!d.razonSocial : (!!d.nombre && !!d.apellido),
  { message: 'Completá los campos requeridos para tu tipo de cliente' }
);

export type CheckoutDataDto = z.infer<typeof checkoutDataSchema>;
```

```typescript
// src/components/checkout/CheckoutStep1.tsx
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { checkoutDataSchema, type CheckoutDataDto } from '@/lib/validators';
import { useSaveCheckoutStep } from '@/swr/use-checkout';
import { Input, Select, Button } from '@/components/ui';

export function CheckoutStep1({ defaultValues, tiposCliente }: Props) {
  const { register, handleSubmit, watch, formState: { errors, isSubmitting } } = useForm<CheckoutDataDto>({
    resolver: zodResolver(checkoutDataSchema),
    defaultValues,
    mode: 'onChange',
  });

  const { trigger: save } = useSaveCheckoutStep(1);
  const tipoClienteId = watch('tipoClienteId');

  const onSubmit = async (data: CheckoutDataDto) => {
    await save(data);
  };

  return (
    <form onSubmit={handleSubmit(onSubmit)} className="space-y-4">
      {tiposCliente.length > 1 && (
        <Select label="Tipo de cliente" options={tiposCliente}
          error={errors.tipoClienteId?.message}
          {...register('tipoClienteId', { valueAsNumber: true })} />
      )}

      {tipoClienteId === 2 ? (
        <>
          <Input label="Razón Social" error={errors.razonSocial?.message} {...register('razonSocial')} />
          <Input label="CUIT" placeholder="XX-XXXXXXXX-X" error={errors.cuit?.message} {...register('cuit')} />
        </>
      ) : (
        <>
          <Input label="Nombre" error={errors.nombre?.message} {...register('nombre')} />
          <Input label="Apellido" error={errors.apellido?.message} {...register('apellido')} />
          <Input label="DNI" error={errors.dni?.message} {...register('dni')} />
        </>
      )}

      <Input label="Email" type="email" error={errors.email?.message} {...register('email')} />

      <div className="grid grid-cols-2 gap-4">
        <Input label="Área" placeholder="11" error={errors.area?.message} {...register('area')} />
        <Input label="Teléfono" error={errors.telefono?.message} {...register('telefono')} />
      </div>

      <Button type="submit" loading={isSubmitting} fullWidth>
        Continuar al envío
      </Button>
    </form>
  );
}
```

---

## 7. Estilos — Tailwind CSS

### Configuración

```typescript
// tailwind.config.ts
export default {
  content: ['./src/**/*.{ts,tsx}'],
  theme: {
    extend: {
      colors: {
        primary: {
          DEFAULT: 'var(--color-primary)',
          50:  'var(--color-primary-50)',
          100: 'var(--color-primary-100)',
          200: 'var(--color-primary-200)',
          300: 'var(--color-primary-300)',
          400: 'var(--color-primary-400)',
          500: 'var(--color-primary-500)',
          600: 'var(--color-primary-600)',
          700: 'var(--color-primary-700)',
          800: 'var(--color-primary-800)',
          900: 'var(--color-primary-900)',
        },
        accent: { DEFAULT: 'var(--color-accent)' },
        surface: {
          DEFAULT: 'var(--color-surface)',
          secondary: 'var(--color-surface-secondary)',
        },
      },
      fontFamily: {
        sans: ['var(--font-sans)', 'system-ui', 'sans-serif'],
        heading: ['var(--font-heading)', 'var(--font-sans)', 'sans-serif'],
      },
    },
  },
  plugins: [],
};
```

### CSS base con variables multi-tenant

```css
/* src/index.css */
@tailwind base;
@tailwind components;
@tailwind utilities;

@layer base {
  :root {
    --color-primary: #2563eb;
    --color-primary-50: #eff6ff;
    --color-primary-100: #dbeafe;
    --color-primary-200: #bfdbfe;
    --color-primary-300: #93c5fd;
    --color-primary-400: #60a5fa;
    --color-primary-500: #3b82f6;
    --color-primary-600: #2563eb;
    --color-primary-700: #1d4ed8;
    --color-primary-800: #1e40af;
    --color-primary-900: #1e3a8a;
    --color-accent: #f59e0b;
    --color-surface: #ffffff;
    --color-surface-secondary: #f9fafb;
    --font-sans: 'Inter', system-ui, -apple-system, sans-serif;
    --font-heading: 'Inter', system-ui, -apple-system, sans-serif;
  }
}

@layer components {
  .btn-primary {
    @apply inline-flex items-center justify-center gap-2 rounded-lg bg-primary
           px-4 py-2.5 text-sm font-semibold text-white shadow-sm transition-all
           hover:opacity-90 focus:outline-none focus:ring-2 focus:ring-primary
           focus:ring-offset-2 disabled:cursor-not-allowed disabled:opacity-50;
  }
  .card {
    @apply rounded-xl border border-gray-200 bg-white shadow-sm;
  }
  .input-field {
    @apply block w-full rounded-lg border border-gray-300 bg-white px-3 py-2.5
           text-sm shadow-sm transition-colors placeholder:text-gray-400
           focus:border-primary focus:outline-none focus:ring-1 focus:ring-primary
           disabled:cursor-not-allowed disabled:bg-gray-50 disabled:text-gray-500;
  }
  .skeleton {
    @apply animate-pulse rounded-lg bg-gray-200;
  }
}
```

---

## 8. SEO (React Helmet + Schema.org)

Como es una SPA sin SSR, el SEO se maneja con React Helmet Async para meta tags dinámicos y Schema.org JSON-LD inline.

```typescript
// src/pages/ProductDetailPage.tsx
import { Helmet } from 'react-helmet-async';
import { useParams } from 'react-router-dom';
import { useProduct } from '@/swr/use-products';
import { ProductSchemaOrg } from '@/components/shared/ProductSchemaOrg';
import { useTenantStore } from '@/stores/tenant-store';

export default function ProductDetailPage() {
  const { slug } = useParams<{ slug: string }>();
  const { data: product, isLoading } = useProduct(slug!);
  const tenant = useTenantStore(s => s.tenant);

  if (isLoading) return <ProductDetailSkeleton />;
  if (!product) return <NotFoundPage />;

  return (
    <>
      <Helmet>
        <title>{product.nombre} — {tenant?.business.nombreFantasia}</title>
        <meta name="description" content={product.descripcion?.replace(/<[^>]*>/g, '').slice(0, 160)} />
        <meta property="og:title" content={product.nombre} />
        <meta property="og:description" content={product.descripcion?.slice(0, 200)} />
        <meta property="og:image" content={product.foto} />
        <meta property="og:type" content="product" />
        <link rel="canonical" href={`https://${tenant?.id}.lumba.com/productos/${product.url}`} />
        <meta name="robots" content="index, follow, max-snippet:-1, max-image-preview:large" />
      </Helmet>

      <ProductSchemaOrg product={product} />

      {/* ... resto de la página */}
    </>
  );
}
```

### Schema.org (JSON-LD)

```typescript
// src/components/shared/ProductSchemaOrg.tsx
export function ProductSchemaOrg({ product }: { product: ProductDetailResponseDto }) {
  const schema = {
    '@context': 'https://schema.org',
    '@type': 'Product',
    name: product.nombre,
    description: product.descripcion?.replace(/<[^>]*>/g, ''),
    image: product.fotos,
    sku: product.variantes[0]?.sku,
    brand: { '@type': 'Brand', name: product.marca.nombre },
    offers: {
      '@type': 'AggregateOffer',
      lowPrice: product.precioDesde,
      priceCurrency: 'ARS',
      availability: product.variantes.some(v => v.disponible)
        ? 'https://schema.org/InStock'
        : 'https://schema.org/OutOfStock',
    },
  };

  return (
    <script type="application/ld+json">
      {JSON.stringify(schema)}
    </script>
  );
}
```

### Sitemap.xml (generado en build-time)

```typescript
// scripts/generate-sitemap.ts — ejecutado en CI/CD
import { apiClient } from '../src/lib/axios';

async function generateSitemap() {
  const { data: products } = await apiClient.get('/products?limit=10000');
  const xml = `<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
  <url><loc>https://${tenant}.lumba.com/</loc><priority>1.0</priority></url>
  ${products.items.map((p: any) => `
  <url><loc>https://${tenant}.lumba.com/productos/${p.url}</loc><priority>0.8</priority></url>
  `).join('')}
</urlset>`;
  // Escribir a public/sitemap.xml
}

generateSitemap();
```

---

## 9. Páginas y Layouts MVP

### MainLayout

```typescript
// src/components/layout/MainLayout.tsx
import { Outlet } from 'react-router-dom';
import { Header } from './Header';
import { Footer } from './Footer';

export function MainLayout() {
  return (
    <div className="flex min-h-screen flex-col bg-surface">
      <Header />
      <main className="flex-1">
        <Outlet />    {/* React Router: renderiza la página activa */}
      </main>
      <Footer />
    </div>
  );
}
```

### HomePage

Componentes: `<Helmet>` (SEO), `<Slider>` (Swiper), `<ProductCarousel>` (destacados), `<BannerGrid>`.

**Estados:** Los datos llegan vía SWR. Mientras carga, skeletons. Si `slides.length === 0`, sección oculta. Si `destacados.length === 0`, sección oculta.

### CatalogPage (PLP)

```typescript
export default function CatalogPage() {
  const [searchParams] = useSearchParams();
  const { data, isLoading, isValidating, error } = useProducts(
    Object.fromEntries(searchParams.entries())
  );
  const { data: categories } = useSWR('/categories', fetcher);

  return (
    <>
      <Helmet><title>Productos — {tenant?.nombreFantasia}</title></Helmet>
      <div className="container mx-auto px-4 py-8">
        <Breadcrumb items={breadcrumbs} />

        <div className="mt-6 grid grid-cols-1 gap-8 lg:grid-cols-4">
          <FilterPanel categories={categories || []} />
          <div className="lg:col-span-3">
            {/* Sort + total */}
            <ProductGrid
              products={data?.items || []}
              isLoading={isLoading}
              isFetching={isValidating && !isLoading}
              error={error}
            />
            <Pagination page={data?.page} totalPages={data?.totalPages} />
          </div>
        </div>
      </div>
    </>
  );
}
```

### ProductDetailPage (PDP)

Componentes: `<Helmet>` + `<ProductSchemaOrg>` (SEO), `<Breadcrumb>`, `<ImageGallery>`, `<PriceDisplay>`, `<VariantSelector>`, `<StockIndicator>`, `<QuantitySelector>` + `<Button>` (AddToCart), `<Accordion>` (descripción, envíos), `<ProductCarousel>` (relacionados).

### CartPage

```typescript
export default function CartPage() {
  const { data, isLoading, error } = useCart();

  if (isLoading) return <CartSkeleton />;
  if (!data || data.items.length === 0) return <EmptyState title="Tu carrito está vacío" action={{ label: 'Ver productos', to: '/productos' }} />;

  return (
    <>
      <Helmet><title>Carrito — {tenant?.nombreFantasia}</title><meta name="robots" content="noindex, nofollow" /></Helmet>
      <div className="container mx-auto px-4 py-8">
        <h1>Carrito ({data.items.length} productos)</h1>
        <div className="mt-6 grid grid-cols-1 gap-8 lg:grid-cols-3">
          <div className="lg:col-span-2 space-y-4">
            {data.items.map(item => <CartItem key={item.varianteId} item={item} />)}
          </div>
          <aside>
            <CouponInput />
            <CartSummary resumen={data.resumen} cuponAplicado={data.cuponAplicado} />
            <Button as={Link} to="/checkout" fullWidth disabled={!data.compraMinimaAlcanzada}>
              Iniciar compra
            </Button>
          </aside>
        </div>
      </div>
    </>
  );
}
```

### CheckoutPage (Single-Page, 4 Steps)

```typescript
export default function CheckoutPage() {
  const { data: state, isLoading } = useCheckout();
  const [step, setStep] = useState(0);
  const { trigger: save1 } = useSaveCheckoutStep(1);
  const { trigger: save2 } = useSaveCheckoutStep(2);
  const { trigger: save3 } = useSaveCheckoutStep(3);
  const { trigger: confirm, isMutating: confirming } = useConfirmCheckout();

  if (isLoading) return <CheckoutSkeleton />;

  return (
    <>
      <Helmet><title>Checkout — {tenant?.nombreFantasia}</title><meta name="robots" content="noindex, nofollow" /></Helmet>

      <StepIndicator steps={[{key:'datos',label:'Datos'},{key:'envio',label:'Envío'},{key:'pago',label:'Pago'},{key:'confirmar',label:'Confirmar'}]} current={step} />

      <div className="grid grid-cols-1 gap-8 lg:grid-cols-3 mt-6">
        <div className="lg:col-span-2">
          {step === 0 && <CheckoutStep1 defaultValues={state.datosPersonales} onSuccess={() => setStep(1)} />}
          {step === 1 && <CheckoutStep2 defaultValues={state.datosEnvio} onSuccess={() => setStep(2)} />}
          {step === 2 && <CheckoutStep3 metodos={state.cliente?.metodosPago} defaultValues={state.datosPago} onSuccess={() => setStep(3)} />}
          {step === 3 && <CheckoutStep4 state={state} onConfirm={confirm} confirming={confirming} onEdit={setStep} />}
        </div>
        <aside>
          <CartSummary resumen={state.carrito.resumen} cuponAplicado={state.carrito.cuponAplicado} />
        </aside>
      </div>
    </>
  );
}
```

**Post-confirmación según medio de pago:**

- **MercadoPago:** `confirm()` devuelve `{ pago: { urlPago } }`. `window.location.href = data.pago.urlPago`.
- **Transferencia:** `{ pago: { comprobanteUrl } }`. `window.location.href = data.pago.comprobanteUrl`.
- **Efectivo:** Muestra pantalla de confirmación.

### Admin

| Ruta | Componentes clave |
|---|---|
| `/admin` | `KpiCard` grid + `Recharts` gráficos + `MonthYearPicker` |
| `/admin/productos` | `AdminTable` server-side con TanStack Table + bulk actions |
| `/admin/productos/nuevo` | `AdminForm` + `ImageUploader` + `VariantSelector` |
| `/admin/pedidos/:id` | Detalle + change status + timeline |

---

## 10. Estrategia Multi-Tenant

### Provider

```typescript
// src/providers/tenant-provider.tsx
import { useEffect } from 'react';
import { useTenantStore } from '@/stores/tenant-store';
import useSWR from 'swr';
import { apiClient } from '@/lib/axios';

export function TenantProvider({ children }: { children: React.ReactNode }) {
  const setTenant = useTenantStore(s => s.setTenant);

  // Cargar configuración del tenant al iniciar
  useEffect(() => {
    // El tenant se resuelve del subdominio o header X-Tenant-ID
    const tenantId = window.location.hostname.split('.')[0];
    apiClient.get(`/admin/config?tenant=${tenantId}`).then(res => {
      setTenant(res.data.data);
    }).catch(() => {
      // Fallback: usar defaults de :root
      setTenant({ id: 'default', business: {}, theme: {} });
    });
  }, [setTenant]);

  return <>{children}</>;
}
```

### Logo dinámico

```typescript
export function Header() {
  const tenant = useTenantStore(s => s.tenant);
  return (
    <header>
      <Link to="/">
        <img
          src={`/logos/${tenant?.id || 'default'}/header.svg`}
          onError={(e) => { (e.target as HTMLImageElement).src = '/logos/default/header.svg'; }}
          alt={tenant?.business.nombreFantasia || 'Tienda'}
          className="h-10 w-auto"
        />
      </Link>
    </header>
  );
}
```

---

## 11. Integraciones

### MercadoPago

**MVP:** Redirección server-side. `POST /api/checkout/confirm` devuelve `{ pago: { urlPago } }`. Frontend: `window.location.href = data.pago.urlPago`.

### reCAPTCHA v3

```typescript
// src/hooks/use-recaptcha.ts
export function useRecaptcha() {
  const execute = useCallback(async (action: string): Promise<string> => {
    if (!window.grecaptcha) return '';
    return await window.grecaptcha.execute(
      import.meta.env.VITE_RECAPTCHA_SITE_KEY,
      { action }
    );
  }, []);
  return { execute };
}
```

### Chatbot IA (Post-MVP Fase 3)

Widget flotante con React Portal. API key por tenant. `gpt-4o-mini`.

---

## 12. Build & Deploy (Vite)

### vite.config.ts

```typescript
import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';
import path from 'path';

export default defineConfig({
  plugins: [react()],
  resolve: {
    alias: {
      '@': path.resolve(__dirname, './src'),
    },
  },
  server: {
    port: 5173,
    proxy: {
      '/api': {
        target: 'http://localhost:3000',  // NestJS backend
        changeOrigin: true,
      },
    },
  },
  build: {
    rollupOptions: {
      output: {
        manualChunks: {
          vendor: ['react', 'react-dom', 'react-router-dom'],
          swr: ['swr'],
          radix: ['@radix-ui/react-dialog', '@radix-ui/react-dropdown-menu', '@radix-ui/react-tabs', '@radix-ui/react-accordion'],
        },
      },
    },
  },
});
```

### Deploy

- **Dev:** `vite dev` con HMR + proxy a NestJS `localhost:3000`.
- **Build:** `vite build` → output en `dist/`. Servir con Nginx, CDN, o incluir en el mismo servidor NestJS como archivos estáticos.
- **CI/CD:** GitHub Actions: `npm ci && npm run build && npm run test`. Desplegar `dist/` a CDN.

---

## 13. Riesgos

| Riesgo | Mitigación |
|---|---|
| SEO limitado en SPA (sin SSR) | React Helmet para meta tags. Schema.org JSON-LD inline. Sitemap pre-generado. Google indexa SPAs razonablemente. |
| Bundle size grande | Code-splitting con `React.lazy`. Manual chunks en Vite. Tailwind purges CSS. |
| Performance en catálogo con filtros | SWR cache + deduping. Debounce en filtros. Paginación server-side. |
| Admin DataTable con 10k+ rows | Server-side pagination/sorting/filtering. SWR con `keepPreviousData`. |
| Refresh token en SPA | Axios interceptor con queue de requests pendientes. Cookie HTTP-only. |

---

## Resumen de Decisiones

| Decisión | Elección |
|---|---|
| Build tool | Vite 6 |
| Framework UI | React 18 |
| HTTP client | Axios 1 (interceptors, cancel, timeout) |
| Data fetching | SWR 2 (stale-while-revalidate, cache, mutations) |
| Estado global | Zustand v5 (selector-based, persist middleware) |
| Formularios | React Hook Form v7 + Zod v3 |
| Routing | React Router DOM v6 (layout routes, lazy loading) |
| SEO | React Helmet Async + Schema.org JSON-LD |
| Estilos | Tailwind CSS 4 (CSS custom properties multi-tenant) |
| Componentes UI | Radix UI (headless, accesible, WCAG 2.1 AA) |
| Admin Table | TanStack Table v8 (server-side) |
| Gráficos | Recharts |

---

> **Confianza global:** ALTA.
> **Stack decidido por Gero:** Vite + React + Tailwind CSS + Axios + SWR + React Hook Form + Zod + React Router DOM.
> **Principio:** SPA con data fetching declarativo (SWR), formularios type-safe (RHF + Zod), estilos utility-first (Tailwind), y componentes accesibles (Radix UI).
>
> **Próximo paso:** `01-frontend-component-tree.md` — 55 componentes React con TypeScript interfaces, SWR hooks, Zustand stores, Tailwind classes, y WCAG 2.1 AA.
