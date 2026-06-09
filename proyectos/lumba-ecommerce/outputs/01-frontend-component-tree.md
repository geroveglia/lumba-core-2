# 01 — Árbol de Componentes Frontend (React + Vite)

> **Proyecto:** Lumba Ecommerce (Brownfield — PHP vanilla + Bootstrap 5 → React + Tailwind CSS + NestJS API)
> **Fecha:** 2026-06-09 | **Rol:** Frontend Architect | **Modelo:** deepseek-v4-pro | **Confianza:** ALTA
> **Stack:** Vite + React 18 + TypeScript 5 + Tailwind CSS 4 + Axios + SWR + Zustand + React Hook Form + Zod + Radix UI + React Router DOM

---

## Índice

1. [Atómicos (19)](#1-componentes-atómicos)
2. [Compuestos (25)](#2-componentes-compuestos)
3. [Layouts (5)](#3-layouts)
4. [Otros (6)](#4-otros-componentes)
5. [Resumen (55 componentes)](#5-resumen)

---

Cada componente documenta: **Props interface (TypeScript)** · **Estados de UI** · **Variantes** · **Accesibilidad (WCAG 2.1 AA)** · **Tailwind classes** · **Responsive behavior**.

---

## 1. Componentes Atómicos

### 1.1 Button

```typescript
import { Link } from 'react-router-dom';
import { cva, type VariantProps } from 'class-variance-authority';

const buttonVariants = cva(
  'inline-flex items-center justify-center gap-2 rounded-lg font-semibold transition-all duration-150 focus:outline-none focus:ring-2 focus:ring-offset-2 disabled:cursor-not-allowed disabled:opacity-50',
  {
    variants: {
      variant: {
        primary: 'bg-primary text-white shadow-sm hover:opacity-90 focus:ring-primary',
        secondary: 'border border-gray-300 bg-white text-gray-700 shadow-sm hover:bg-gray-50 focus:ring-primary',
        ghost: 'text-gray-700 hover:bg-gray-100 focus:ring-primary',
        danger: 'bg-red-600 text-white hover:bg-red-700 focus:ring-red-500',
        outline: 'border-2 border-primary text-primary hover:bg-primary-50 focus:ring-primary',
        link: 'text-primary underline-offset-4 hover:underline focus:ring-primary',
      },
      size: { xs:'px-2 py-1 text-xs', sm:'px-3 py-1.5 text-sm', md:'px-4 py-2.5 text-sm', lg:'px-6 py-3 text-base', xl:'px-8 py-4 text-lg', icon:'p-2' },
      fullWidth: { true: 'w-full' },
    },
    defaultVariants: { variant: 'primary', size: 'md' },
  }
);

interface ButtonProps extends ButtonHTMLAttributes<HTMLButtonElement>, VariantProps<typeof buttonVariants> {
  loading?: boolean; leftIcon?: React.ReactNode; rightIcon?: React.ReactNode;
  to?: string;   // React Router Link
}

export const Button = forwardRef<HTMLButtonElement, ButtonProps>(
  ({ variant, size, fullWidth, loading, leftIcon, rightIcon, children, disabled, className, to, ...props }, ref) => {
    const classes = cn(buttonVariants({ variant, size, fullWidth }), className);
    const content = <>{loading ? <Spinner size="sm" /> : leftIcon}{children}{!loading && rightIcon}</>;
    if (to) return <Link to={to} className={classes}>{content}</Link>;
    return <button ref={ref} disabled={disabled || loading} className={classes} aria-busy={loading} {...props}>{content}</button>;
  }
);
```

**Estados:** idle | hover | active | focus (ring-2) | disabled (opacity-50) | loading (spinner + aria-busy) | fullWidth.
**A11y:** `aria-busy` en loading. Focus visible. Texto nunca reemplazado por spinner. `Link` de React Router cuando se usa `to`.
**Responsive:** `size="lg"` en mobile CTAs (touch target ≥ 44px).

---

### 1.2 Input

```typescript
interface InputProps extends Omit<InputHTMLAttributes<HTMLInputElement>, 'size'> {
  label?: string; hint?: string; error?: string;
  leftIcon?: React.ReactNode; rightIcon?: React.ReactNode;
  onRightIconClick?: () => void;
  inputSize?: 'sm' | 'md' | 'lg'; fullWidth?: boolean;
}

export const Input = forwardRef<HTMLInputElement, InputProps>(
  ({ label, hint, error, leftIcon, rightIcon, onRightIconClick, inputSize='md', fullWidth, className, id, required, ...props }, ref) => {
    const inputId = id || useId();
    const sizes = { sm:'px-2.5 py-1.5 text-xs', md:'px-3 py-2.5 text-sm', lg:'px-4 py-3 text-base' };
    const errorId = `${inputId}-error`; const hintId = `${inputId}-hint`;
    return (
      <div className={cn('flex flex-col gap-1.5', fullWidth && 'w-full')}>
        {label && <label htmlFor={inputId} className="text-sm font-medium text-gray-700">{label}{required && <span className="text-red-500 ml-0.5" aria-hidden>*</span>}</label>}
        <div className="relative">
          {leftIcon && <div className="pointer-events-none absolute inset-y-0 left-0 flex items-center pl-3 text-gray-400">{leftIcon}</div>}
          <input ref={ref} id={inputId}
            className={cn('input-field', leftIcon && 'pl-10', rightIcon && 'pr-10', error ? 'border-red-500 focus:ring-red-500' : 'focus:border-primary focus:ring-primary', sizes[inputSize], className)}
            aria-invalid={!!error} aria-describedby={cn(error && errorId, hint && hintId)} required={required} {...props} />
          {rightIcon && <button type="button" onClick={onRightIconClick} className="absolute inset-y-0 right-0 flex items-center pr-3 text-gray-400 hover:text-gray-600" tabIndex={-1}>{rightIcon}</button>}
        </div>
        {error && <p id={errorId} className="text-xs text-red-600" role="alert">{error}</p>}
        {hint && !error && <p id={hintId} className="text-xs text-gray-500">{hint}</p>}
      </div>
    );
  }
);
```

**Estados:** idle (border-gray-300) | focus (border-primary + ring-1) | error (border-red-500, aria-invalid, texto rojo) | disabled (bg-gray-50) | with icon (pl-10/pr-10).

---

### 1.3 Select

```typescript
interface SelectOption { value: string|number; label: string; disabled?: boolean; }
interface SelectProps extends Omit<SelectHTMLAttributes<HTMLSelectElement>, 'size'> {
  label?: string; hint?: string; error?: string; options: SelectOption[]; placeholder?: string;
  inputSize?: 'sm'|'md'|'lg'; fullWidth?: boolean;
}

export const Select = forwardRef<HTMLSelectElement, SelectProps>(
  ({ label, hint, error, options, placeholder, inputSize='md', fullWidth, className, ...props }, ref) => (
    <div className={cn('flex flex-col gap-1.5', fullWidth && 'w-full')}>
      {label && <label className="text-sm font-medium text-gray-700">{label}</label>}
      <div className="relative">
        <select ref={ref} className={cn('input-field appearance-none pr-10', error ? 'border-red-500 focus:ring-red-500' : 'focus:border-primary focus:ring-primary')} aria-invalid={!!error} {...props}>
          {placeholder && <option value="">{placeholder}</option>}
          {options.map(o => <option key={o.value} value={o.value} disabled={o.disabled}>{o.label}</option>)}
        </select>
        <ChevronDownIcon className="pointer-events-none absolute right-3 top-1/2 h-4 w-4 -translate-y-1/2 text-gray-400" />
      </div>
      {error && <p className="text-xs text-red-600" role="alert">{error}</p>}
      {hint && !error && <p className="text-xs text-gray-500">{hint}</p>}
    </div>
  )
);
```

---

### 1.4 Badge

```typescript
interface BadgeProps { children: React.ReactNode; variant?: 'default'|'success'|'warning'|'danger'|'info'|'neutral'; size?: 'sm'|'md'; dot?: boolean; }

export function Badge({ children, variant='default', size='md', dot }: BadgeProps) {
  const colors = { default:'bg-primary-100 text-primary-800', success:'bg-green-100 text-green-800', warning:'bg-amber-100 text-amber-800', danger:'bg-red-100 text-red-800', info:'bg-blue-100 text-blue-800', neutral:'bg-gray-100 text-gray-700' };
  return <span className={cn('inline-flex items-center gap-1 rounded-full font-medium', size==='sm'?'px-2 py-0.5 text-xs':'px-2.5 py-1 text-xs', colors[variant])}>{dot && <span className="h-1.5 w-1.5 rounded-full bg-current" aria-hidden />}{children}</span>;
}
```

---

### 1.5 Skeleton

```typescript
interface SkeletonProps { className?: string; variant?: 'text'|'circular'|'rectangular'; width?: string|number; height?: string|number; lines?: number; }

export function Skeleton({ className, variant='rectangular', width, height, lines=1 }: SkeletonProps) {
  if (variant==='text' && lines>1) return <div className="flex flex-col gap-2">{Array.from({length:lines}).map((_,i)=><div key={i} className={cn('skeleton h-3', i===lines-1&&'w-3/5')} />)}</div>;
  return <div className={cn('skeleton', variant==='circular'&&'rounded-full', className)} style={{width,height}} aria-hidden />;
}
```

---

### 1.6 Modal (Radix Dialog)

```typescript
import * as Dialog from '@radix-ui/react-dialog';

interface ModalProps {
  open: boolean; onOpenChange: (open:boolean) => void;
  title: string; description?: string; children: React.ReactNode; footer?: React.ReactNode;
  size?: 'sm'|'md'|'lg'|'xl';
}

export function Modal({ open, onOpenChange, title, description, children, footer, size='md' }: ModalProps) {
  const sizes = { sm:'max-w-sm', md:'max-w-lg', lg:'max-w-2xl', xl:'max-w-4xl' };
  return (
    <Dialog.Root open={open} onOpenChange={onOpenChange}>
      <Dialog.Portal>
        <Dialog.Overlay className="fixed inset-0 z-40 bg-black/50 data-[state=open]:animate-in data-[state=open]:fade-in-0" />
        <Dialog.Content className={cn('fixed left-1/2 top-1/2 z-50 -translate-x-1/2 -translate-y-1/2 w-full rounded-xl bg-white shadow-2xl focus:outline-none', sizes[size])}>
          <div className="flex items-start justify-between border-b px-6 py-4">
            <Dialog.Title className="text-lg font-semibold text-gray-900">{title}</Dialog.Title>
            <Dialog.Close className="rounded-lg p-1.5 text-gray-400 hover:bg-gray-100"><XIcon className="h-5 w-5" /></Dialog.Close>
          </div>
          <div className="px-6 py-4 overflow-y-auto max-h-[70vh]">{children}</div>
          {footer && <div className="flex justify-end gap-3 border-t px-6 py-4">{footer}</div>}
        </Dialog.Content>
      </Dialog.Portal>
    </Dialog.Root>
  );
}
```

**A11y (via Radix):** Focus trap, Escape cierra, foco al trigger, `aria-modal`, animaciones respetan `prefers-reduced-motion`.

---

### 1.7 Drawer

```typescript
interface DrawerProps { open: boolean; onOpenChange: (open:boolean) => void; title: string; children: React.ReactNode; side?: 'left'|'right'; size?: 'sm'|'md'|'lg'; }

export function Drawer({ open, onOpenChange, title, children, side='left', size='md' }: DrawerProps) {
  const sizes = { sm:'max-w-xs', md:'max-w-sm', lg:'max-w-md' };
  return (
    <Dialog.Root open={open} onOpenChange={onOpenChange}>
      <Dialog.Portal>
        <Dialog.Overlay className="fixed inset-0 z-40 bg-black/50" />
        <Dialog.Content className={cn('fixed top-0 z-50 h-full w-full bg-white shadow-xl data-[state=open]:animate-in data-[state=open]:duration-300', side==='left'?'left-0 data-[state=open]:slide-in-from-left':'right-0 data-[state=open]:slide-in-from-right', sizes[size])}>
          <div className="flex items-center justify-between border-b px-4 py-3">
            <Dialog.Title className="text-lg font-semibold">{title}</Dialog.Title>
            <Dialog.Close className="rounded-lg p-1.5 text-gray-400 hover:bg-gray-100"><XIcon className="h-5 w-5" /></Dialog.Close>
          </div>
          <div className="overflow-y-auto p-4" style={{height:'calc(100% - 57px)'}}>{children}</div>
        </Dialog.Content>
      </Dialog.Portal>
    </Dialog.Root>
  );
}
```

---

### 1.8 Dropdown (Radix DropdownMenu)

```typescript
interface DropdownItem { label: string; onClick?: () => void; icon?: React.ReactNode; danger?: boolean; disabled?: boolean; divider?: boolean; to?: string; }

export function Dropdown({ trigger, items, align='end' }: { trigger:React.ReactNode; items:DropdownItem[]; align?:'start'|'center'|'end' }) {
  return (
    <DropdownMenu.Root>
      <DropdownMenu.Trigger asChild>{trigger}</DropdownMenu.Trigger>
      <DropdownMenu.Portal>
        <DropdownMenu.Content align={align} sideOffset={8} className="z-50 min-w-[180px] rounded-lg border border-gray-200 bg-white p-1 shadow-lg animate-in fade-in-0 zoom-in-95">
          {items.map((item,i) => (
            <React.Fragment key={i}>
              {item.divider && <DropdownMenu.Separator className="my-1 h-px bg-gray-200" />}
              {item.to ? (
                <DropdownMenu.Item asChild>
                  <Link to={item.to} className={cn('flex items-center gap-2 rounded-md px-3 py-2 text-sm outline-none cursor-pointer', item.danger?'text-red-600 hover:bg-red-50':'text-gray-700 hover:bg-gray-100')}>{item.icon}{item.label}</Link>
                </DropdownMenu.Item>
              ) : (
                <DropdownMenu.Item onClick={item.onClick} disabled={item.disabled}
                  className={cn('flex items-center gap-2 rounded-md px-3 py-2 text-sm outline-none cursor-pointer select-none', item.danger?'text-red-600 hover:bg-red-50':'text-gray-700 hover:bg-gray-100', item.disabled&&'opacity-50')}>
                  {item.icon}{item.label}
                </DropdownMenu.Item>
              )}
            </React.Fragment>
          ))}
        </DropdownMenu.Content>
      </DropdownMenu.Portal>
    </DropdownMenu.Root>
  );
}
```

---

### 1.9 Toast (Zustand + Portal)

```typescript
// src/stores/ui-store.ts
interface Toast { id: string; type: 'success'|'error'|'warning'|'info'; title: string; description?: string; duration?: number; }

// Hook helper
export function useToast() {
  const add = useUiStore(s => s.addToast);
  return {
    success: (title:string, desc?:string) => add({type:'success',title,description:desc}),
    error: (title:string, desc?:string) => add({type:'error',title,description:desc}),
    warning: (title:string, desc?:string) => add({type:'warning',title,description:desc}),
    info: (title:string, desc?:string) => add({type:'info',title,description:desc}),
  };
}

// src/components/ui/Toast.tsx — container renderizado en App.tsx
const icons = { success:CheckCircleIcon, error:AlertCircleIcon, warning:AlertTriangleIcon, info:InfoIcon };
const colors = { success:'border-green-200 bg-green-50 text-green-800', error:'border-red-200 bg-red-50 text-red-800', warning:'border-amber-200 bg-amber-50 text-amber-800', info:'border-blue-200 bg-blue-50 text-blue-800' };

function ToastItem({ toast, onDismiss }:{ toast:Toast; onDismiss:()=>void }) {
  const Icon = icons[toast.type];
  useEffect(() => { if(toast.duration===0) return; const t=setTimeout(onDismiss,toast.duration||5000); return ()=>clearTimeout(t); }, [toast.duration,onDismiss]);
  return <div className={cn('pointer-events-auto flex items-start gap-3 rounded-lg border p-4 shadow-lg animate-in slide-in-from-right-full', colors[toast.type])} role="alert"><Icon className="h-5 w-5 shrink-0 mt-0.5"/><div className="flex-1 min-w-0"><p className="text-sm font-semibold">{toast.title}</p>{toast.description&&<p className="mt-1 text-sm opacity-80">{toast.description}</p>}</div><button onClick={onDismiss} className="shrink-0 rounded p-0.5 hover:bg-black/5"><XIcon className="h-4 w-4"/></button></div>;
}

export function ToastContainer() {
  const toasts = useUiStore(s=>s.toasts); const remove = useUiStore(s=>s.removeToast);
  if(!toasts.length) return null;
  return <div className="pointer-events-none fixed bottom-4 right-4 z-[100] flex flex-col gap-2 max-w-sm w-full" aria-live="polite">{toasts.map(t=><ToastItem key={t.id} toast={t} onDismiss={()=>remove(t.id)}/>)}</div>;
}
```

---

### 1.10 Pagination

```typescript
interface PaginationProps { page: number; totalPages: number; onPageChange: (p:number) => void; className?: string; }

export function Pagination({ page, totalPages, onPageChange, className }: PaginationProps) {
  if(totalPages<=1) return null;
  const pages = getPageNumbers(page,totalPages);
  return (
    <nav className={cn('flex items-center justify-center gap-1', className)} aria-label="Paginación">
      <button onClick={()=>onPageChange(page-1)} disabled={page===1} className="btn-ghost px-3 py-2" aria-label="Anterior"><ChevronLeftIcon className="h-4 w-4"/></button>
      {pages.map((p,i)=>p==='...'?<span key={i} className="px-2 text-gray-400">...</span>:<button key={p} onClick={()=>onPageChange(p as number)} className={cn('min-w-[2.5rem] rounded-lg px-3 py-2 text-sm font-medium', p===page?'bg-primary text-white':'text-gray-700 hover:bg-gray-100')} aria-current={p===page?'page':undefined}>{p}</button>)}
      <button onClick={()=>onPageChange(page+1)} disabled={page===totalPages} className="btn-ghost px-3 py-2" aria-label="Siguiente"><ChevronRightIcon className="h-4 w-4"/></button>
    </nav>
  );
}
```

---

### 1.11 Breadcrumb

```typescript
interface BreadcrumbItem { label: string; to?: string; }
export function Breadcrumb({ items }: { items:BreadcrumbItem[] }) {
  return <nav aria-label="Breadcrumb"><ol className="flex flex-wrap items-center gap-1.5 text-sm text-gray-500">{items.map((item,i)=>{const last=i===items.length-1; return <li key={i} className="flex items-center gap-1.5">{i>0&&<ChevronRightIcon className="h-3.5 w-3.5 text-gray-400" aria-hidden/>}{last||!item.to?<span className="font-medium text-gray-900" aria-current="page">{item.label}</span>:<Link to={item.to} className="hover:text-primary">{item.label}</Link>}</li>})}</ol></nav>;
}
```

---

### 1.12 Tabs (Radix)

```typescript
interface Tab { value:string; label:string; count?:number; disabled?:boolean; }
export function Tabs({ tabs, value, onValueChange, children }:{ tabs:Tab[]; value:string; onValueChange:(v:string)=>void; children:React.ReactNode }) {
  return <TabsRoot value={value} onValueChange={onValueChange}><TabsList className="flex border-b border-gray-200" aria-label="Secciones">{tabs.map(t=><TabsTrigger key={t.value} value={t.value} disabled={t.disabled} className={cn('flex items-center gap-2 border-b-2 px-4 py-3 text-sm font-medium transition-colors focus:outline-none focus:ring-2 focus:ring-primary', value===t.value?'border-primary text-primary':'border-transparent text-gray-500 hover:text-gray-700')}>{t.label}{t.count!==undefined&&<Badge variant="neutral" size="sm">{t.count}</Badge>}</TabsTrigger>)}</TabsList>{children}</TabsRoot>;
}
```

---

### 1.13 Accordion (Radix)

```typescript
interface AccordionItem { value:string; title:string; content:React.ReactNode; }
export function Accordion({ items, type='single' }:{ items:AccordionItem[]; type?:'single'|'multiple' }) {
  return <AccordionRoot type={type} className="divide-y divide-gray-200">{items.map(item=><AccordionItemEl key={item.value} value={item.value}><AccordionHeader><AccordionTrigger className="flex w-full items-center justify-between py-4 text-sm font-medium text-gray-900 hover:text-primary focus:outline-none focus:ring-2 focus:ring-primary rounded-md [&[data-state=open]>svg]:rotate-180">{item.title}<ChevronDownIcon className="h-5 w-5 shrink-0 text-gray-400 transition-transform" aria-hidden/></AccordionTrigger></AccordionHeader><AccordionContent className="overflow-hidden text-sm text-gray-600 data-[state=open]:animate-accordion-down data-[state=closed]:animate-accordion-up"><div className="pb-4">{item.content}</div></AccordionContent></AccordionItemEl>)}</AccordionRoot>;
}
```

---

### 1.14 QuantitySelector

```typescript
export function QuantitySelector({ value, onChange, min=1, max=99, disabled, isLoading, size='md' }:{ value:number; onChange:(v:number)=>void; min?:number; max?:number; disabled?:boolean; isLoading?:boolean; size?:'sm'|'md'|'lg' }) {
  const sz = { sm:'h-8 w-8 text-sm', md:'h-10 w-10 text-base', lg:'h-12 w-12 text-lg' };
  return <div className="inline-flex items-center rounded-lg border border-gray-300 bg-white shadow-sm">
    <button onClick={()=>onChange(value-1)} disabled={value<=min||disabled||isLoading} className={cn(sz[size],'flex items-center justify-center rounded-l-lg transition-colors focus:outline-none focus:ring-2 focus:ring-inset focus:ring-primary', value>min?'text-gray-600 hover:bg-gray-100':'text-gray-300 cursor-not-allowed')} aria-label="Reducir"><MinusIcon className="h-4 w-4"/></button>
    <span className={cn(sz[size],'flex items-center justify-center border-x font-medium text-gray-900 select-none')} aria-live="polite">{isLoading?<Spinner size="sm"/>:value}</span>
    <button onClick={()=>onChange(value+1)} disabled={value>=max||disabled||isLoading} className={cn(sz[size],'flex items-center justify-center rounded-r-lg transition-colors focus:outline-none focus:ring-2 focus:ring-inset focus:ring-primary', value<max?'text-gray-600 hover:bg-gray-100':'text-gray-300 cursor-not-allowed')} aria-label="Aumentar"><PlusIcon className="h-4 w-4"/></button>
  </div>;
}
```

---

### 1.15 Spinner

```typescript
export function Spinner({ size='md', className }:{ size?:'xs'|'sm'|'md'|'lg'; className?:string }) {
  const sz = { xs:'h-3 w-3', sm:'h-4 w-4', md:'h-6 w-6', lg:'h-8 w-8' };
  return <svg className={cn('animate-spin text-primary', sz[size], className)} xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" aria-hidden><circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4"/><path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4z"/></svg>;
}
```

---

### 1.16 StockIndicator

```typescript
export function StockIndicator({ stockTotal, showLabel=true }:{ stockTotal:number; showLabel?:boolean }) {
  if(stockTotal<=0) return <div className="flex items-center gap-1.5 text-sm text-red-600"><div className="h-2 w-2 rounded-full bg-red-500"/>{showLabel&&'Sin stock'}</div>;
  if(stockTotal<=5) return <div className="flex items-center gap-1.5 text-sm text-amber-600"><div className="h-2 w-2 rounded-full bg-amber-500"/>{showLabel&&`Quedan ${stockTotal}`}</div>;
  return <div className="flex items-center gap-1.5 text-sm text-green-600"><div className="h-2 w-2 rounded-full bg-green-500"/>{showLabel&&'Disponible'}</div>;
}
```

---

### 1.17 Alert

```typescript
export function Alert({ variant, title, children, onDismiss }:{ variant:'info'|'success'|'warning'|'error'; title?:string; children:React.ReactNode; onDismiss?:()=>void }) {
  const styles = { info:'bg-blue-50 border-blue-200 text-blue-800', success:'bg-green-50 border-green-200 text-green-800', warning:'bg-amber-50 border-amber-200 text-amber-800', error:'bg-red-50 border-red-200 text-red-800' };
  const Icon = { info:InfoIcon, success:CheckCircleIcon, warning:AlertTriangleIcon, error:AlertCircleIcon }[variant];
  return <div className={cn('flex items-start gap-3 rounded-lg border p-4', styles[variant])} role="alert"><Icon className="h-5 w-5 shrink-0 mt-0.5"/><div className="flex-1">{title&&<p className="font-semibold text-sm">{title}</p>}<div className="text-sm">{children}</div></div>{onDismiss&&<button onClick={onDismiss} className="shrink-0 rounded p-0.5 hover:bg-black/5" aria-label="Cerrar"><XIcon className="h-4 w-4"/></button>}</div>;
}
```

---

### 1.18 Toggle (Switch)

```typescript
export function Toggle({ label, checked, onChange, disabled }:{ label:string; checked:boolean; onChange:(c:boolean)=>void; disabled?:boolean }) {
  return <button type="button" role="switch" aria-checked={checked} onClick={()=>onChange(!checked)} disabled={disabled} className={cn('relative inline-flex h-6 w-11 shrink-0 rounded-full border-2 border-transparent transition-colors focus:outline-none focus:ring-2 focus:ring-primary focus:ring-offset-2', checked?'bg-primary':'bg-gray-200', disabled&&'opacity-50 cursor-not-allowed')}><span className={cn('pointer-events-none inline-block h-5 w-5 rounded-full bg-white shadow transform ring-0 transition', checked?'translate-x-5':'translate-x-0')}/><span className="sr-only">{label}</span></button>;
}
```

---

### 1.19 Tooltip (Radix)

```typescript
export function Tooltip({ content, children, side='top', delay=300 }:{ content:React.ReactNode; children:React.ReactNode; side?:'top'|'bottom'|'left'|'right'; delay?:number }) {
  return <TooltipProvider delayDuration={delay}><TooltipRoot><TooltipTrigger asChild>{children}</TooltipTrigger><TooltipPortal><TooltipContent side={side} sideOffset={4} className="z-50 max-w-xs rounded-md bg-gray-900 px-3 py-1.5 text-xs text-white shadow-md">{content}<TooltipArrow className="fill-gray-900"/></TooltipContent></TooltipPortal></TooltipRoot></TooltipProvider>;
}
```

---

## 2. Componentes Compuestos

### 2.1 ProductCard

```typescript
import { Link } from 'react-router-dom';
import { useCartStore } from '@/stores/cart-store';
import { useToast } from '@/components/ui/Toast';
import { useAddToCart } from '@/swr/use-cart';

interface ProductCardProps { product: ProductListItemDto; onToggleFavorite?: () => void; isFavorite?: boolean; }

export function ProductCard({ product, onToggleFavorite, isFavorite }: ProductCardProps) {
  const descuento = product.descuento && product.descuento>0;
  const setCount = useCartStore(s => s.setFromApi);
  const toast = useToast();
  const { trigger: addToCart, isMutating } = useAddToCart();

  const handleAdd = async (e: React.MouseEvent) => {
    e.preventDefault();
    const data = await addToCart({ productoId: product.id, varianteId: product.variantes[0]?.id, cantidad: 1, precio: product.precioDesde, foto: product.foto, url: product.url, iva: product.iva });
    setCount(data);
    toast.success('Agregado al carrito');
  };

  return (
    <article className="group card overflow-hidden transition-shadow hover:shadow-md">
      <Link to={`/productos/${product.url}`} className="relative block">
        <div className="aspect-square overflow-hidden rounded-t-xl bg-gray-100">
          <img src={product.foto} alt={product.nombre} loading="lazy" className="h-full w-full object-cover transition-transform group-hover:scale-105"/>
        </div>
        <div className="absolute top-2 left-2 flex flex-col gap-1">
          {descuento && <Badge variant="danger">{product.descuento}% OFF</Badge>}
          {product.stock==='sin_stock' && <Badge variant="neutral">Sin stock</Badge>}
          {product.stock==='bajo' && <Badge variant="warning">Poco stock</Badge>}
        </div>
        {onToggleFavorite && <button onClick={e=>{e.preventDefault();onToggleFavorite()}} className="absolute top-2 right-2 rounded-full bg-white/80 p-1.5 shadow-sm hover:bg-white" aria-label={isFavorite?'Quitar':'Agregar a favoritos'}><HeartIcon className={cn('h-5 w-5',isFavorite?'fill-red-500 text-red-500':'text-gray-400')}/></button>}
      </Link>
      <div className="p-4">
        {product.marca && <p className="text-xs font-medium text-gray-500 uppercase tracking-wide mb-1">{product.marca.nombre}</p>}
        <Link to={`/productos/${product.url}`}><h3 className="text-sm font-medium text-gray-900 line-clamp-2 hover:text-primary">{product.nombre}</h3></Link>
        <div className="mt-2"><PriceDisplay price={product.precioDesde} originalPrice={product.precioOriginal} discountPercent={product.descuento}/></div>
        {product.stock!=='sin_stock' && <Button size="sm" fullWidth onClick={handleAdd} loading={isMutating} className="mt-3 sm:opacity-0 sm:group-hover:opacity-100 transition-opacity">Agregar al carrito</Button>}
      </div>
    </article>
  );
}
```

**Estados:** Default, con descuento, sin stock (badge + add disabled), poco stock (badge amarillo), favorito (heart rojo), hover desktop (sombra + zoom + botón visible), loading (skeleton). **A11y:** `<article>` semántico, `alt` descriptivo, aria-labels en botones, `loading="lazy"` en img. **Responsive:** AddToCart siempre visible en mobile, solo hover en desktop.

---

### 2.2 ProductGrid

```typescript
export function ProductGrid({ products, isLoading, isValidating, error, onRetry, ...props }: ProductGridProps) {
  if(isLoading) return <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6">{Array.from({length:12}).map((_,i)=><div key={i} className="card p-4 space-y-4"><Skeleton className="aspect-square w-full"/><Skeleton variant="text" lines={3}/></div>)}</div>;
  if(error) return <EmptyState icon={<AlertCircleIcon className="h-12 w-12 text-red-400"/>} title="Error al cargar" action={onRetry?{label:'Reintentar',onClick:onRetry}:undefined}/>;
  if(products.length===0) return <EmptyState icon={<PackageOpenIcon className="h-12 w-12 text-gray-300"/>} title="No encontramos productos" description="Probá con otros filtros."/>;
  return <div className="relative">{isValidating&&<div className="absolute inset-0 z-10 flex items-start justify-center pt-8 bg-white/60"><Spinner size="lg"/></div>}<div className={cn('grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6', isValidating&&'opacity-60')}>{products.map(p=><ProductCard key={p.id} product={p} {...props}/>)}</div></div>;
}
```

---

### 2.3 CartItem

SWR mutation para update/delete:

```typescript
export function CartItem({ item }: { item:CartItemResponseDto }) {
  const { trigger: updateQty, isMutating } = useUpdateCartItem(item.productoId, item.varianteId);
  const { trigger: removeItem } = useRemoveCartItem(item.productoId, item.varianteId);

  return (
    <div className="flex gap-4 rounded-lg border border-gray-200 bg-white p-4">
      <Link to={`/productos/${item.url}`} className="shrink-0"><img src={item.foto} alt={item.nombre} className="h-20 w-20 sm:h-24 sm:w-24 rounded-lg object-cover"/></Link>
      <div className="flex flex-1 flex-col justify-between min-w-0">
        <div><Link to={`/productos/${item.url}`}><h3 className="text-sm font-medium text-gray-900 hover:text-primary line-clamp-2">{item.nombre}</h3></Link><p className="text-xs text-gray-500 mt-0.5">SKU: {item.sku}</p>{item.promocion&&<Badge variant="success" size="sm" className="mt-1">{item.promocion}</Badge>}</div>
        <div className="flex items-center justify-between mt-2"><QuantitySelector value={item.cantidad} onChange={q=>updateQty({cantidad:q})} min={1} size="sm" isLoading={isMutating}/><div className="text-right"><PriceDisplay price={item.precioUnitario} originalPrice={item.precioOriginal} size="sm"/><p className="mt-0.5 text-xs font-medium text-gray-900">Subtotal: {formatCurrency(item.subtotal)}</p></div></div>
      </div>
      <button onClick={()=>removeItem()} className="self-start rounded p-1 text-gray-400 hover:bg-gray-100 hover:text-red-500" aria-label={`Eliminar ${item.nombre}`}><TrashIcon className="h-5 w-5"/></button>
    </div>
  );
}
```

---

### 2.4 CartSummary

```typescript
export function CartSummary({ resumen, cuponAplicado }:{ resumen:CartResumenDto; cuponAplicado?:{codigo:string;tipo:string;valor:number} }) {
  return <div className="rounded-xl border border-gray-200 bg-gray-50 p-6"><h3 className="text-lg font-semibold">Resumen</h3><dl className="mt-4 space-y-3 text-sm"><div className="flex justify-between"><dt className="text-gray-600">Subtotal</dt><dd className="font-medium">{formatCurrency(resumen.subtotal)}</dd></div>{resumen.descuentoPromociones>0&&<div className="flex justify-between text-green-600"><dt>Desc. promociones</dt><dd>-{formatCurrency(resumen.descuentoPromociones)}</dd></div>}{resumen.descuentoCupon>0&&<div className="flex justify-between text-green-600"><dt>Cupón {cuponAplicado?.codigo}</dt><dd>-{formatCurrency(resumen.descuentoCupon)}</dd></div>}<div className="flex justify-between"><dt className="text-gray-600">IVA</dt><dd>{formatCurrency(resumen.iva)}</dd></div><div className="flex justify-between"><dt className="text-gray-600">Envío</dt><dd>{resumen.envioGratis?<span className="text-green-600">GRATIS</span>:formatCurrency(resumen.costoEnvio)}</dd></div><div className="border-t pt-3 flex justify-between"><dt className="text-base font-semibold">Total</dt><dd className="text-base font-semibold">{formatCurrency(resumen.total)}</dd></div></dl></div>;
}
```

---

### 2.5 PriceDisplay

```typescript
export function PriceDisplay({ price, originalPrice, discountPercent, size='md', showIva }:{ price:number; originalPrice?:number; discountPercent?:number; size?:'sm'|'md'|'lg'|'xl'; showIva?:boolean }) {
  const hasDisc = originalPrice && originalPrice>price;
  const effDisc = discountPercent || (originalPrice?Math.round((1-price/originalPrice)*100):0);
  const sz={sm:'text-sm',md:'text-base',lg:'text-xl',xl:'text-2xl'};
  return <div className="flex flex-wrap items-baseline gap-2"><span className={cn('font-bold text-gray-900',sz[size])}>{formatCurrency(price)}</span>{hasDisc&&<span className="text-sm text-gray-400 line-through">{formatCurrency(originalPrice!)}</span>}{hasDisc&&effDisc>0&&<Badge variant="danger" size="sm">-{effDisc}%</Badge>}{showIva&&<span className="text-xs text-gray-400">IVA incl.</span>}</div>;
}
```

`formatCurrency`: `Intl.NumberFormat('es-AR', {style:'currency',currency:'ARS'})`.

---

### 2.6 VariantSelector

```typescript
export function VariantSelector({ variantes, propiedades, selected, onSelect }: VariantSelectorProps) {
  return <div className="space-y-5">{propiedades.map(prop=><div key={prop.propiedadId}><p className="text-sm font-medium text-gray-900 mb-2">{prop.propiedad}: <span className="font-normal text-gray-500">{selected[prop.propiedadId]?prop.valores.find(v=>v.id===selected[prop.propiedadId])?.valor:'Seleccionar'}</span></p><div className="flex flex-wrap gap-2" role="radiogroup" aria-label={prop.propiedad}>{prop.valores.map(valor=>{const posible=variantes.some(v=>v.propiedades.some(p=>p.propiedadId===prop.propiedadId&&p.valorId===valor.id)&&v.disponible);const sel=selected[prop.propiedadId]===valor.id;return prop.propiedad.toLowerCase()==='color'&&valor.colorHex?<Tooltip key={valor.id} content={valor.valor}><button role="radio" aria-checked={sel} onClick={()=>posible&&onSelect(prop.propiedadId,valor.id)} disabled={!posible} className={cn('h-10 w-10 rounded-full border-2 transition-all focus:outline-none focus:ring-2 focus:ring-primary focus:ring-offset-2',sel?'border-primary ring-2 ring-primary-300 scale-110':'border-gray-300',!posible&&'opacity-30 cursor-not-allowed')} style={{backgroundColor:valor.colorHex}}><span className="sr-only">{valor.valor}</span></button></Tooltip>:<button key={valor.id} role="radio" aria-checked={sel} onClick={()=>posible&&onSelect(prop.propiedadId,valor.id)} disabled={!posible} className={cn('rounded-lg border px-4 py-2 text-sm font-medium transition-all focus:outline-none focus:ring-2 focus:ring-primary',sel?'border-primary bg-primary text-white':'border-gray-300 bg-white text-gray-700 hover:border-gray-400',!posible&&'opacity-30 cursor-not-allowed line-through')}>{valor.valor}</button>;})}</div></div>)}</div>;
}
```

**A11y:** `role="radiogroup"`, `role="radio"`, `aria-checked`. Arrow keys entre opciones. `sr-only` en swatches de color.

---

### 2.7 CheckoutForm

```typescript
export function CheckoutForm() {
  const { data: state, isLoading } = useCheckout();
  const [step, setStep] = useState(0);
  const save1 = useSaveCheckoutStep(1); const save2 = useSaveCheckoutStep(2); const save3 = useSaveCheckoutStep(3);
  const { trigger: confirm, isMutating: confirming } = useConfirmCheckout();

  if(isLoading) return <CheckoutSkeleton/>;

  const steps = [
    {key:'datos',label:'Datos',comp:<CheckoutStep1 defaultValues={state.datosPersonales} onSuccess={()=>setStep(1)}/>},
    {key:'envio',label:'Envío',comp:<CheckoutStep2 defaultValues={state.datosEnvio} onSuccess={()=>setStep(2)}/>},
    {key:'pago',label:'Pago',comp:<CheckoutStep3 metodos={state.cliente?.metodosPago} onSuccess={()=>setStep(3)}/>},
    {key:'confirmar',label:'Confirmar',comp:<CheckoutStep4 state={state} onConfirm={confirm} confirming={confirming} onEdit={setStep}/>},
  ];

  return <div className="grid grid-cols-1 gap-8 lg:grid-cols-3"><div className="lg:col-span-2"><StepIndicator steps={steps.map(s=>({key:s.key,label:s.label}))} current={step}/><div className="mt-6">{steps[step].comp}</div></div><aside className="lg:col-span-1"><div className="sticky top-4"><CartSummary resumen={state.carrito.resumen} cuponAplicado={state.carrito.cuponAplicado}/></div></aside></div>;
}
```

Post-confirm: si `data.pago.urlPago` → `window.location.href = data.pago.urlPago` (MP). Si `data.pago.comprobanteUrl` → redirigir a comprobante (transferencia). Si efectivo → mostrar pantalla de éxito.

---

### 2.8 PaymentMethodSelector

```typescript
export function PaymentMethodSelector({ metodos, selected, onSelect, cuotasMP, datosBancarios }: PaymentMethodSelectorProps) {
  const options = metodos.map(m=>{switch(m){case'mercadopago':return{value:m,label:'MercadoPago',desc:'Tarjetas, dinero en cuenta. Hasta 12 cuotas.',icon:<CreditCardIcon className="h-6 w-6"/>};case'transferencia':return{value:m,label:'Transferencia',desc:'Transferí y subí el comprobante.',icon:<BankIcon className="h-6 w-6"/>};case'efectivo':return{value:m,label:'Efectivo',desc:'Pagá al retirar.',icon:<CashIcon className="h-6 w-6"/>};default:return null;}}).filter(Boolean);
  return <div><RadioGroup label="Elegí cómo pagar" name="formaPago" value={selected} onChange={onSelect} options={options.map(o=>({value:o.value,label:<div className="flex items-center gap-3">{o.icon}<div><span className="text-sm font-medium">{o.label}</span><p className="text-xs text-gray-500 mt-0.5">{o.desc}</p></div></div>}))}/>{selected==='mercadopago'&&cuotasMP&&<Alert variant="info" className="mt-3">Hasta {cuotasMP} cuotas sin interés.</Alert>}{selected==='transferencia'&&datosBancarios&&<Alert variant="info" className="mt-3"><div dangerouslySetInnerHTML={{__html:datosBancarios}}/></Alert>}</div>;
}
```

---

### 2.9 AddressForm

```typescript
export function AddressForm({ onSubmit, defaultValues, isSubmitting }: AddressFormProps) {
  const { register, handleSubmit, watch, setValue, formState:{errors} } = useForm({ resolver:zodResolver(addressSchema), defaultValues, mode:'onChange' });
  const provId = watch('provinciaId'); const cp = watch('cp');
  const { data:provincias } = useSWR('/geo/provincias', fetcher); const { data:localidades } = useSWR(provId?`/geo/localidades?provinciaId=${provId}`:null, fetcher);
  const debouncedCp = useDebounce(cp,500); const { data:cpData } = useSWR(debouncedCp?`/geo/codigos-postales/${debouncedCp}`:null, fetcher);
  useEffect(()=>{ if(cpData){ setValue('provinciaId',cpData.provincia.id); setValue('localidadId',cpData.localidad.id); } }, [cpData,setValue]);

  return <form onSubmit={handleSubmit(onSubmit)} className="space-y-4">
    <div className="grid grid-cols-1 sm:grid-cols-2 gap-4"><Input label="Código postal" placeholder="Ej: 1425" error={errors.cp?.message} {...register('cp')}/><Input label="Etiqueta" placeholder="Casa, Trabajo..." hint="Opcional" {...register('etiqueta')}/></div>
    <Select label="Provincia" options={provincias?.map(p=>({value:p.id,label:p.nombre}))||[]} error={errors.provinciaId?.message} {...register('provinciaId',{valueAsNumber:true})}/>
    <Select label="Localidad" options={localidades?.map(l=>({value:l.id,label:l.nombre}))||[]} disabled={!provId} error={errors.localidadId?.message} {...register('localidadId',{valueAsNumber:true})}/>
    <Input label="Calle" error={errors.calle?.message} {...register('calle')}/>
    <div className="grid grid-cols-2 gap-4"><Input label="Número" error={errors.numero?.message} {...register('numero')}/><Input label="Depto/Piso" hint="Opcional" {...register('departamento')}/></div>
    <Checkbox label="Dirección predeterminada" {...register('predeterminada')}/>
    <Button type="submit" loading={isSubmitting} fullWidth>Guardar dirección</Button>
  </form>;
}
```

---

### 2.10 AddressCard

```typescript
export function AddressCard({ address, selected, onSelect, onEdit, onDelete }: AddressCardProps) {
  return <div onClick={onSelect} className={cn('rounded-lg border p-4 transition-all cursor-pointer', selected?'border-primary bg-primary-50 ring-2 ring-primary-300':'border-gray-200 hover:border-gray-300')} role={onSelect?'radio':undefined} aria-checked={onSelect?selected:undefined} tabIndex={onSelect?0:undefined}>
    <div className="flex items-start justify-between"><div><div className="flex items-center gap-2"><p className="text-sm font-medium">{address.calle} {address.numero}{address.departamento&&`, ${address.departamento}`}</p>{address.predeterminada&&<Badge variant="info" size="sm">Predeterminada</Badge>}{address.etiqueta&&<Badge variant="neutral" size="sm">{address.etiqueta}</Badge>}</div><p className="text-sm text-gray-500 mt-1">{address.localidad.nombre}, {address.provincia.nombre} — CP {address.cp}</p></div><div className="flex gap-1">{onEdit&&<Button variant="ghost" size="icon" onClick={e=>{e.stopPropagation();onEdit()}} aria-label="Editar"><PencilIcon className="h-4 w-4"/></Button>}{onDelete&&<Button variant="ghost" size="icon" onClick={e=>{e.stopPropagation();onDelete()}} aria-label="Eliminar"><TrashIcon className="h-4 w-4"/></Button>}</div></div>
  </div>;
}
```

---

### 2.11 OrderCard

```typescript
export function OrderCard({ order, onRepeat }:{ order:OrderListItemDto; onRepeat?:()=>void }) {
  const status:Record<string,{variant:'success'|'warning'|'info'|'neutral';label:string}> = { Activo:{variant:'info',label:'Activo'}, Pagado:{variant:'success',label:'Pagado'}, Pendiente:{variant:'neutral',label:'Pendiente'}, Enviado:{variant:'info',label:'Enviado'}, Entregado:{variant:'success',label:'Entregado'} };
  const st = status[order.estado]||status.Pendiente;
  return <Link to={`/cuenta/pedidos/${order.hash}`} className="block"><div className="card p-5 hover:shadow-md transition-shadow"><div className="flex items-start justify-between mb-3"><div><p className="font-semibold">Pedido #{order.hash}</p><p className="text-sm text-gray-500">{new Date(order.fecha).toLocaleDateString('es-AR',{day:'numeric',month:'long',year:'numeric'})}</p></div><Badge variant={st.variant}>{st.label}</Badge></div><div className="flex flex-wrap gap-4 text-sm text-gray-600 mb-3"><span>{order.cantidadItems} {order.cantidadItems===1?'producto':'productos'}</span></div><div className="flex items-center justify-between pt-3 border-t"><PriceDisplay price={order.total} size="md"/><span className="text-sm text-primary font-medium">Ver detalle →</span></div></div></Link>;
}
```

---

### 2.12 OrderTimeline

```typescript
export function OrderTimeline({ events }:{ events:{date:string;status:string;description:string;completed:boolean;current:boolean}[] }) {
  return <ol className="relative border-l border-gray-200 ml-3">{events.map((e,i)=><li key={i} className="mb-6 ml-6 last:mb-0"><span className={cn('absolute -left-3 flex h-6 w-6 items-center justify-center rounded-full ring-8 ring-white', e.current?'bg-primary text-white':e.completed?'bg-green-500 text-white':'bg-gray-200 text-gray-400')}>{e.completed?<CheckIcon className="h-3 w-3"/>:<div className="h-2 w-2 rounded-full bg-current"/>}</span><time className="text-xs text-gray-500">{new Date(e.date).toLocaleDateString('es-AR',{day:'numeric',month:'short',hour:'2-digit',minute:'2-digit'})}</time><p className={cn('text-sm font-medium',e.current?'text-primary':'text-gray-900')}>{e.status}</p><p className="text-sm text-gray-500">{e.description}</p></li>)}</ol>;
}
```

---

### 2.13 AdminTable (TanStack Table + SWR)

```typescript
import { useReactTable, getCoreRowModel, getSortedRowModel, flexRender, type ColumnDef, type SortingState, type PaginationState } from '@tanstack/react-table';
import useSWR from 'swr';
import { apiClient } from '@/lib/axios';

interface AdminTableProps<T> {
  columns: ColumnDef<T>[];
  url: string;
  searchable?: boolean;
  pageSize?: number;
  actions?: (row: T) => React.ReactNode;
  noResultsText?: string;
}

export function AdminTable<T extends object>({ columns, url, searchable, pageSize=25, actions, noResultsText }: AdminTableProps<T>) {
  const [search, setSearch] = useState('');
  const [sorting, setSorting] = useState<SortingState>([]);
  const [pagination, setPagination] = useState<PaginationState>({ pageIndex: 0, pageSize });

  // Construir URL con params
  const params = new URLSearchParams({ page: String(pagination.pageIndex+1), limit: String(pageSize) });
  if(search) params.set('q', search);
  if(sorting[0]) params.set('orden', `${sorting[0].id}_${sorting[0].desc?'desc':'asc'}`);

  const swrKey = `${url}?${params.toString()}`;
  const { data, isLoading, error, mutate } = useSWR(swrKey, (key) => apiClient.get(key).then(r => r.data));

  const table = useReactTable({
    data: data?.data || [],
    columns,
    pageCount: data?.meta?.totalPages || 0,
    state: { sorting, pagination },
    onSortingChange: setSorting,
    onPaginationChange: setPagination,
    manualPagination: true,
    manualSorting: true,
    getCoreRowModel: getCoreRowModel(),
    getSortedRowModel: getSortedRowModel(),
  });

  if(isLoading) return <div className="card overflow-hidden"><table className="w-full"><thead><tr className="border-b bg-gray-50">{columns.map((_,i)=><th key={i} className="px-4 py-3"><Skeleton className="h-4 w-24"/></th>)}</tr></thead><tbody>{Array.from({length:10}).map((_,i)=><tr key={i} className="border-b">{columns.map((_,j)=><td key={j} className="px-4 py-3"><Skeleton className="h-4 w-full max-w-[200px]"/></td>)}</tr>)}</tbody></table></div>;
  if(error) return <div className="card flex flex-col items-center justify-center py-16"><AlertCircleIcon className="h-10 w-10 text-red-400 mb-3"/><p className="text-base font-medium">Error al cargar</p><Button onClick={()=>mutate()} className="mt-4">Reintentar</Button></div>;
  if(!data?.data?.length) return <div className="card flex flex-col items-center justify-center py-16"><SearchIcon className="h-10 w-10 text-gray-300 mb-3"/><p className="text-base font-medium">{noResultsText||'Sin resultados'}</p></div>;

  return <div className="card overflow-hidden">
    {searchable && <div className="border-b px-4 py-3"><SearchBar value={search} onChange={v=>{setSearch(v);setPagination(p=>({...p,pageIndex:0}));}} className="max-w-sm"/></div>}
    <div className="overflow-x-auto"><table className="w-full"><thead><tr className="border-b bg-gray-50">{table.getFlatHeaders().map(h=><th key={h.id} onClick={h.column.getToggleSortingHandler()} className={cn('px-4 py-3 text-left text-xs font-semibold text-gray-600 uppercase',h.column.getCanSort()&&'cursor-pointer select-none')}><div className="flex items-center gap-1">{flexRender(h.column.columnDef.header,h.getContext())}{{asc:'▲',desc:'▼'}[h.column.getIsSorted() as string]}</div></th>)}{actions&&<th className="px-4 py-3 w-10"/>}</tr></thead><tbody>{table.getRowModel().rows.map(r=><tr key={r.id} className="border-b last:border-0 hover:bg-gray-50">{r.getVisibleCells().map(c=><td key={c.id} className="px-4 py-3 text-sm text-gray-700">{flexRender(c.column.columnDef.cell,c.getContext())}</td>)}{actions&&<td className="px-4 py-3"><div className="flex items-center gap-2">{actions(r.original)}</div></td>}</tr>)}</tbody></table></div>
    <div className="flex items-center justify-between border-t bg-gray-50 px-4 py-3"><p className="text-sm text-gray-600">Mostrando {data.data.length} de {data.meta.total}</p><div className="flex items-center gap-1"><Button variant="ghost" size="icon" onClick={()=>table.previousPage()} disabled={!table.getCanPreviousPage()}><ChevronLeftIcon className="h-4 w-4"/></Button><span className="text-sm text-gray-700 px-3">Pág. {pagination.pageIndex+1} de {data.meta.totalPages}</span><Button variant="ghost" size="icon" onClick={()=>table.nextPage()} disabled={!table.getCanNextPage()}><ChevronRightIcon className="h-4 w-4"/></Button></div></div>
  </div>;
}
```

---

### 2.14 AdminForm

```typescript
export function AdminForm({ title, description, children, onSubmit, isSubmitting, submitLabel='Guardar', onCancel }: AdminFormProps) {
  return <form onSubmit={e=>{e.preventDefault();onSubmit()}} className="space-y-6"><div className="flex items-center justify-between"><div><h2 className="text-xl font-semibold">{title}</h2>{description&&<p className="text-sm text-gray-500 mt-1">{description}</p>}</div><div className="flex gap-3">{onCancel&&<Button type="button" variant="secondary" onClick={onCancel}>Cancelar</Button>}<Button type="submit" loading={isSubmitting}>{submitLabel}</Button></div></div>{children}</form>;
}
```

---

### 2.15 FilterPanel

```typescript
export function FilterPanel({ categories, selectedCategoryId, precioMin, precioMax, onFilterChange, onClearFilters, activeFilterCount }: FilterPanelProps) {
  const isMobile = useMediaQuery('(max-width:1023px)');
  const [drawer, setDrawer] = useState(false);

  const content = <div className="space-y-6"><div className="flex items-center justify-between"><h3 className="font-semibold">Filtros</h3>{activeFilterCount>0&&<button onClick={onClearFilters} className="text-xs text-primary hover:underline">Limpiar ({activeFilterCount})</button>}</div>
    <FilterSection title="Categorías" defaultOpen><div className="space-y-1 max-h-64 overflow-y-auto">{categories.map(c=><label key={c.id} className="flex items-center gap-2 px-2 py-1.5 rounded-md hover:bg-gray-50 cursor-pointer"><input type="radio" name="categoria" checked={selectedCategoryId===c.id} onChange={()=>onFilterChange('categoriaId',String(c.id))} className="h-4 w-4 text-primary"/><span className="text-sm">{c.nombre}</span></label>)}</div></FilterSection>
    <FilterSection title="Precio"><div className="flex items-center gap-2"><Input type="number" placeholder="Mín" value={precioMin||''} onChange={e=>onFilterChange('precioMin',e.target.value)} inputSize="sm"/><span className="text-gray-400">—</span><Input type="number" placeholder="Máx" value={precioMax||''} onChange={e=>onFilterChange('precioMax',e.target.value)} inputSize="sm"/></div></FilterSection>
  </div>;

  if(isMobile) return <><Button variant="secondary" onClick={()=>setDrawer(true)}><FilterIcon className="h-4 w-4"/>Filtros{activeFilterCount>0&&` (${activeFilterCount})`}</Button><Drawer open={drawer} onOpenChange={setDrawer} title="Filtros">{content}</Drawer></>;
  return <aside className="w-64 shrink-0">{content}</aside>;
}
```

---

### 2.16 SearchBar

```typescript
export function SearchBar({ value, onChange, placeholder='Buscar...', className, autoFocus }:{ value:string; onChange:(v:string)=>void; placeholder?:string; className?:string; autoFocus?:boolean }) {
  const debounced = useDebouncedCallback(onChange,300);
  return <div className={cn('relative',className)}><SearchIcon className="pointer-events-none absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-gray-400"/><input type="search" value={value} onChange={e=>debounced(e.target.value)} placeholder={placeholder} autoFocus={autoFocus} className="input-field pl-10 pr-10"/>{value&&<button onClick={()=>onChange('')} className="absolute right-3 top-1/2 -translate-y-1/2 text-gray-400 hover:text-gray-600" aria-label="Limpiar"><XIcon className="h-4 w-4"/></button>}</div>;
}
```

---

### 2.17 ImageGallery

```typescript
export function ImageGallery({ images, alt }:{ images:string[]; alt:string }) {
  const [selected, setSelected] = useState(0); const [zoomed, setZoomed] = useState(false); const [coords, setCoords] = useState({x:50,y:50});
  return <div className="space-y-4"><div className="relative aspect-square overflow-hidden rounded-xl bg-gray-100" onMouseEnter={()=>setZoomed(true)} onMouseMove={e=>{const r=e.currentTarget.getBoundingClientRect();setCoords({x:((e.clientX-r.left)/r.width)*100,y:((e.clientY-r.top)/r.height)*100})}} onMouseLeave={()=>setZoomed(false)}><img src={images[selected]} alt={alt} className={cn('h-full w-full object-cover transition-transform duration-200',zoomed&&'scale-150')} style={zoomed?{transformOrigin:`${coords.x}% ${coords.y}%`}:undefined}/></div>{images.length>1&&<div className="flex gap-2 overflow-x-auto pb-1">{images.map((img,i)=><button key={i} onClick={()=>setSelected(i)} className={cn('h-20 w-20 shrink-0 overflow-hidden rounded-lg border-2 transition-all focus:outline-none focus:ring-2 focus:ring-primary',i===selected?'border-primary ring-2 ring-primary-300':'border-gray-200')} aria-label={`Imagen ${i+1} de ${images.length}`}><img src={img} alt={`${alt} ${i+1}`} className="h-full w-full object-cover"/></button>)}</div>}</div>;
}
```

---

### 2.18 ImageUploader

```typescript
export function ImageUploader({ images, onUpload, onDelete, maxFiles=10 }: ImageUploaderProps) {
  const { getRootProps, getInputProps, isDragActive } = useDropzone({ onDrop:async(files)=>{await onUpload(files)}, accept:{'image/*':['.jpg','.jpeg','.png','.webp']}, maxFiles:maxFiles-images.length, disabled:images.length>=maxFiles });
  return <div className="space-y-3">{images.length<maxFiles&&<div {...getRootProps()} className={cn('flex flex-col items-center justify-center rounded-lg border-2 border-dashed p-6 cursor-pointer',isDragActive?'border-primary bg-primary-50':'border-gray-300 bg-gray-50')}><input {...getInputProps()}/><UploadIcon className="h-8 w-8 text-gray-400 mb-2"/><p className="text-sm text-gray-600">{isDragActive?'Solía las imágenes':'Arrastrá o hacé click'}</p><p className="text-xs text-gray-400 mt-1">PNG, JPG o WebP. Máx {maxFiles}.</p></div>}<div className="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-5 gap-3">{images.map((img,i)=><div key={img.id||i} className="relative group aspect-square rounded-lg overflow-hidden bg-gray-100"><img src={img.url} alt={`Imagen ${i+1}`} className="h-full w-full object-cover"/><div className="absolute inset-0 flex items-center justify-center gap-2 bg-black/40 opacity-0 group-hover:opacity-100 transition-opacity">{img.id&&<button onClick={()=>onDelete(img.id!)} className="rounded-full bg-red-500 p-1.5 text-white hover:bg-red-600" aria-label="Eliminar"><TrashIcon className="h-4 w-4"/></button>}</div>{i===0&&<span className="absolute bottom-1 left-1 rounded bg-primary px-1.5 py-0.5 text-xs text-white">Principal</span>}</div>)}</div><p className="text-xs text-gray-500">Primera imagen = principal. Arrastrá para reordenar.</p></div>;
}
```

---

### 2.19 RatingStars

```typescript
export function RatingStars({ rating, maxRating=5, size='md', interactive, onChange, showValue }: RatingStarsProps) {
  const [hover,setHover] = useState(0); const display = hover||rating;
  const sz = { sm:'h-4 w-4', md:'h-5 w-5', lg:'h-6 w-6' };
  return <div className="flex items-center gap-1">{Array.from({length:maxRating}).map((_,i)=>{const v=i+1;const f=v<=display;const h=!f&&v-0.5<=display;const Comp=interactive?'button':'span';return <Comp key={i} type={interactive?'button':undefined} onClick={interactive?()=>onChange?.(v):undefined} onMouseEnter={interactive?()=>setHover(v):undefined} onMouseLeave={interactive?()=>setHover(0):undefined} className={cn('transition-colors',interactive&&'cursor-pointer hover:scale-110',f||h?'text-amber-400':'text-gray-300',sz[size])} aria-label={`${v} estrella${v>1?'s':''}`}>{(f?StarFilled:h?StarHalf:StarEmpty)({className:sz[size]})}</Comp>;})}{showValue&&<span className="ml-1 text-sm font-medium text-gray-700">{rating.toFixed(1)}</span>}</div>;
}
```

---

### 2.20 ReviewCard

```typescript
export function ReviewCard({ review }:{ review:{ nombre:string; texto:string; puntaje:number; fecha?:string; verificada?:boolean } }) {
  return <blockquote className="card p-5"><div className="flex items-center gap-3 mb-3"><Avatar alt={review.nombre} fallback={review.nombre.charAt(0)} size="md"/><div><p className="text-sm font-medium">{review.nombre}</p>{review.fecha&&<p className="text-xs text-gray-500">{new Date(review.fecha).toLocaleDateString('es-AR')}{review.verificada&&' · Compra verificada'}</p>}</div><RatingStars rating={review.puntaje} size="sm" className="ml-auto"/></div><p className="text-sm text-gray-700">"{review.texto}"</p></blockquote>;
}
```

---

### 2.21 CouponInput

```typescript
export function CouponInput({ onApply, onRemove, applied, error, isLoading }: CouponInputProps) {
  const [code,setCode] = useState('');
  return <div className="space-y-2">{applied?<div className="flex items-center justify-between rounded-lg border border-green-200 bg-green-50 px-4 py-3"><div className="flex items-center gap-2"><CheckCircleIcon className="h-5 w-5 text-green-600"/><div><p className="text-sm font-medium text-green-800">{applied.codigo}</p><p className="text-xs text-green-600">{applied.tipo==='Porcentaje'?`${applied.valor}%`:applied.tipo==='Monto fijo'?`$${applied.valor}`:'Envío gratis'}</p></div></div><button onClick={()=>{onRemove();setCode('')}} className="rounded p-0.5 text-green-600 hover:bg-green-100" aria-label="Quitar cupón"><XIcon className="h-4 w-4"/></button></div>:<form onSubmit={e=>{e.preventDefault();code.trim()&&onApply(code.trim().toUpperCase())}} className="flex gap-2"><input value={code} onChange={e=>setCode(e.target.value)} placeholder="Código de cupón" className="flex-1 rounded-lg border border-gray-300 px-3 py-2 text-sm uppercase focus:border-primary focus:ring-primary" disabled={isLoading} aria-label="Código de cupón"/><Button type="submit" variant="secondary" size="sm" loading={isLoading} disabled={!code.trim()}>Aplicar</Button></form>}{error&&<p className="text-xs text-red-600" role="alert">{error}</p>}</div>;
}
```

---

### 2.22 KpiCard

```typescript
export function KpiCard({ title, value, variation, variationLabel, icon, format='number', isLoading }: KpiCardProps) {
  if(isLoading) return <div className="card p-5 space-y-3"><Skeleton className="h-4 w-20"/><Skeleton className="h-8 w-32"/><Skeleton className="h-3 w-16"/></div>;
  const formatted = format==='currency'?formatCurrency(Number(value)):String(value);
  return <div className="card p-5"><div className="flex items-center justify-between"><p className="text-sm font-medium text-gray-600">{title}</p>{icon&&<div className="text-gray-400">{icon}</div>}</div><p className="mt-2 text-2xl font-bold text-gray-900">{formatted}</p>{variation!==undefined&&<div className="mt-1 flex items-center gap-1"><span className={cn('inline-flex items-center gap-0.5 text-sm font-medium',variation>0?'text-green-600':variation<0?'text-red-600':'text-gray-500')}>{variation>0?<TrendingUpIcon className="h-4 w-4"/>:variation<0?<TrendingDownIcon className="h-4 w-4"/>:null}{variation>0?'+':''}{variation}%</span>{variationLabel&&<span className="text-xs text-gray-400">{variationLabel}</span>}</div>}</div>;
}
```

---

### 2.23 MonthYearPicker

```typescript
export function MonthYearPicker({ value, onChange }:{ value:{month:number;year:number}; onChange:(v:{month:number;year:number})=>void }) {
  const months = ['Enero','Febrero','Marzo','Abril','Mayo','Junio','Julio','Agosto','Septiembre','Octubre','Noviembre','Diciembre'];
  return <div className="flex items-center gap-2"><Select options={months.map((m,i)=>({value:i+1,label:m}))} value={value.month} onChange={e=>onChange({...value,month:Number(e.target.value)})} inputSize="sm" aria-label="Mes"/><Select options={Array.from({length:10},(_,i)=>({value:2020+i,label:String(2020+i)}))} value={value.year} onChange={e=>onChange({...value,year:Number(e.target.value)})} inputSize="sm" aria-label="Año"/></div>;
}
```

---

### 2.24 StepIndicator

```typescript
export function StepIndicator({ steps, current }:{ steps:{key:string;label:string}[]; current:number }) {
  return <nav aria-label="Progreso"><ol className="flex items-center">{steps.map((s,i)=><li key={s.key} className={cn('flex items-center',i<steps.length-1&&'flex-1')}><div className="flex flex-col items-center"><span className={cn('flex h-8 w-8 items-center justify-center rounded-full text-sm font-semibold transition-colors',i<current?'bg-primary text-white':i===current?'bg-primary text-white ring-4 ring-primary-200':'bg-gray-200 text-gray-500')} aria-current={i===current?'step':undefined}>{i<current?<CheckIcon className="h-4 w-4"/>:i+1}</span><span className={cn('mt-1.5 text-xs font-medium text-center hidden sm:block',i<=current?'text-gray-900':'text-gray-400')}>{s.label}</span></div>{i<steps.length-1&&<div className={cn('flex-1 h-0.5 mx-2 mt-[-0.75rem]',i<current?'bg-primary':'bg-gray-200')}/>}</li>)}</ol></nav>;
}
```

**Responsive:** Mobile solo círculos. Labels visibles en `sm+`.

---

### 2.25 EmptyState

```typescript
export function EmptyState({ icon, title, description, action }:{ icon?:React.ReactNode; title:string; description?:string; action?:{label:string;onClick?:()=>void;to?:string} }) {
  return <div className="flex flex-col items-center justify-center py-16 text-center">{icon||<PackageOpenIcon className="h-12 w-12 text-gray-300 mb-4"/>}<p className="text-lg font-medium text-gray-900">{title}</p>{description&&<p className="text-sm text-gray-500 mt-1">{description}</p>}{action&&(action.to?<Button to={action.to} className="mt-4">{action.label}</Button>:<Button onClick={action.onClick} className="mt-4">{action.label}</Button>)}</div>;
}
```

---

## 3. Layouts

### 3.1 MainLayout

```typescript
import { Outlet } from 'react-router-dom';
export function MainLayout() { return <div className="flex min-h-screen flex-col bg-surface"><Header/><main className="flex-1"><Outlet/></main><Footer/></div>; }
```

### 3.2 CheckoutLayout

Header minimal con logo + link volver al carrito. Footer con seguridad SSL. Content area con `<Outlet/>`.

### 3.3 AccountLayout

Sidebar (Perfil, Pedidos, Direcciones, Favoritos, Empresa, Cerrar sesión) + `<Outlet/>`. Protegido: redirige a `/login` si `!user`.

### 3.4 AuthLayout

Centrado vertical y horizontal. Logo tenant. Fondo opcional con imagen de login del tenant.

### 3.5 AdminLayout

Sidebar fijo (secciones según permisos `admin.permissions[]`) + header (search global, avatar dropdown) + `<Outlet/>`. Protegido: redirige a `/admin/login` si `!admin || admin.role !== 'admin'`.

---

## 4. Otros Componentes

| Componente | Descripción |
|---|---|
| **Header** | Logo tenant, SearchBar (desktop), nav categorías, user dropdown/login link, mini-cart counter, mobile menu drawer |
| **Footer** | Logo tenant, links (FAQ, contacto, términos, privacidad), contacto (WhatsApp), newsletter, redes sociales |
| **AdminSidebar** | Secciones: Dashboard, Pedidos, Productos, Clientes, Categorías, Marcas, Tags, Cupones, Configuración... Filtradas por `permissions[]` |
| **AccountSidebar** | Links a: Perfil, Pedidos, Direcciones, Favoritos, Empresa. Link activo con `bg-primary-50 text-primary` |
| **ProductSchemaOrg** | `<script type="application/ld+json">` con Schema.org Product |
| **BreadcrumbSchemaOrg** | `<script type="application/ld+json">` con Schema.org BreadcrumbList |

---

## 5. Resumen

| Categoría | Componentes | Cantidad |
|---|---|---|
| **Atómicos** | Button, Input, Select, Badge, Skeleton, Modal, Drawer, Dropdown, Toast, Pagination, Breadcrumb, Tabs, Accordion, QuantitySelector, Spinner, StockIndicator, Alert, Toggle, Tooltip | **19** |
| **Compuestos** | ProductCard, ProductGrid, CartItem, CartSummary, PriceDisplay, VariantSelector, CheckoutForm, PaymentMethodSelector, AddressForm, AddressCard, OrderCard, OrderTimeline, AdminTable, AdminForm, FilterPanel, SearchBar, ImageGallery, ImageUploader, RatingStars, ReviewCard, CouponInput, KpiCard, MonthYearPicker, StepIndicator, EmptyState | **25** |
| **Layouts** | MainLayout, CheckoutLayout, AccountLayout, AuthLayout, AdminLayout | **5** |
| **Otros** | Header, Footer, AdminSidebar, AccountSidebar, ProductSchemaOrg, BreadcrumbSchemaOrg | **6** |
| **TOTAL** | | **55** |

---

> **Confianza global:** ALTA. Stack: Vite + React 18 + Tailwind CSS 4 + Axios + SWR + Zustand + React Hook Form + Zod + Radix UI + React Router DOM.
>
> **Principios:** WCAG 2.1 AA (roles ARIA, keyboard nav, focus management), Mobile-first (60%+ tráfico mobile), Multi-tenant via CSS custom properties (sin colores/logo hardcodeados), TypeScript strict en todas las interfaces.
>
> **Fuentes:** Basado en 72 endpoints REST (`01-backend-api-spec.md`), 42 features MVP (`01-feature-prioritization.md`), flujos de negocio (`01-flujos-negocio.md`), gaps UX (`01-gaps-and-improvements.md`).
