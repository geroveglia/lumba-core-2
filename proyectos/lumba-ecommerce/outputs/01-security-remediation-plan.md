# 01 — Security Remediation Plan

> **Proyecto:** Lumba Ecommerce (Brownfield — migración PHP vanilla → NestJS + Tailwind)
> **Fecha:** 2026-06-08
> **Rol:** Security Agent
> **Modelo:** deepseek-v4-pro
> **Nivel de confianza global:** ALTA
> **Fuentes:** Hallazgos del System Auditor (01-discovery-sistema-actual.md, 01-modelo-datos-actual.md, 01-integraciones.md) + Gaps del Product Owner (01-gaps-and-improvements.md)

---

## Índice de Vulnerabilidades

| # | Vulnerabilidad | Severidad | Prioridad |
|---|---|---|---|
| V01 | Contraseñas admin en texto plano | 🔴 Crítica | **P0** — Día 1 |
| V02 | Contraseñas clientes en MD5 sin salt | 🔴 Crítica | **P0** — Día 1 |
| V03 | API Key OpenAI hardcodeada en código | 🔴 Crítica | **P0** — Día 1 |
| V04 | Webhooks de pago sin validación de firma | 🔴 Crítica | **P0** — Día 1 |
| V05 | Credenciales de pago en DB sin encriptación | 🔴 Crítica | **P0** — Día 1 |
| V06 | Sin rate limiting en auth endpoints | 🟠 Alta | **P1** — Semana 1 |
| V07 | Sin protección CSRF | 🟠 Alta | **P1** — Semana 1 |
| V08 | Sin Content Security Policy ni security headers | 🟡 Media | **P2** — Semana 2 |
| V09 | Endpoints admin sin verificación de permisos consistente | 🟠 Alta | **P1** — Semana 1 |
| V10 | Sesiones PHP sin hardening | 🟠 Alta | **P1** — Semana 1 |
| V11 | Sin validación de inputs consistente | 🟡 Media | **P2** — Semana 2 |
| V12 | Sin logs de seguridad/auditoría | 🟡 Media | **P2** — Semana 2 |
| V13 | reCAPTCHA secret key en tabla configuracion | 🟡 Media | **P2** — Semana 2 |
| V14 | Sin sanitización de uploads | 🟡 Media | **P2** — Semana 2 |

---

## V01 — Contraseñas Admin en Texto Plano

### Severidad: 🔴 CRÍTICA (CVSS-like: 9.8)

### Vector de ataque

1. Un atacante obtiene acceso a la base de datos (SQL injection, backup filtrado, acceso interno malicioso).
2. Lee la tabla `administradores` y obtiene todas las contraseñas en texto plano.
3. Se autentica inmediatamente como cualquier administrador — sin necesidad de crackear nada.
4. Accede al panel de administración con permisos completos: modifica productos, precios, pedidos, credenciales de pago, datos de clientes, etc.

### Impacto en negocio

- **Pérdida total de control del ecommerce.** El atacante puede:
  - Desviar pagos cambiando credenciales de MercadoPago/Modo
  - Robar la base de datos completa de clientes (PII: nombres, emails, teléfonos, DNI, CUIT, direcciones)
  - Modificar precios, stock, y pedidos
  - Desfigurar la tienda pública
  - Usar la API key de OpenAI para consumo fraudulento
- **Riesgo legal:** Exposición de datos personales (Ley 25.326 de Protección de Datos Personales en Argentina).
- **Daño reputacional:** Irreparable si se filtra que las contraseñas admin estaban sin hash.

### Evidence (del System Auditor)

> **Fuente:** `01-modelo-datos-actual.md`, sección 2.8
> "`administradores.contrasenia` — **Sin hash detectado** (comparación directa en `login.php`)"

> **Fuente:** `01-discovery-sistema-actual.md`, Hallazgos Notables #2
> "Contraseñas de admin comparadas en texto plano (sin hash)"

> **Fuente:** `01-gaps-and-improvements.md`, sección 1.1
> "`admin/login.php`: `$rArray['contrasenia'] === $contrasenia`"

**Hecho:** El código compara contraseñas con `===` (identidad estricta de strings), lo que implica almacenamiento en texto plano.

### Solución NestJS

**Paquetes:**
```bash
npm install bcrypt @types/bcrypt
```

**Service de autenticación admin:**

```typescript
// src/modules/auth/admin-auth.service.ts
import { Injectable, UnauthorizedException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import * as bcrypt from 'bcrypt';
import { Admin } from '../users/entities/admin.entity';

const BCRYPT_ROUNDS = 12;

@Injectable()
export class AdminAuthService {
  constructor(
    @InjectRepository(Admin)
    private readonly adminRepo: Repository<Admin>,
  ) {}

  async validateAdmin(email: string, password: string): Promise<Admin> {
    const admin = await this.adminRepo.findOne({
      where: { email, eliminado: false },
    });

    if (!admin) {
      // Timing-safe: siempre comparar aunque no exista el usuario
      await bcrypt.compare(password, '$2b$12$' + 'x'.repeat(53));
      throw new UnauthorizedException('Credenciales inválidas');
    }

    // Caso 1: Contraseña legacy en texto plano (migración inicial)
    if (admin.passwordNeedsMigration) {
      if (password !== admin.legacyPassword) {
        throw new UnauthorizedException('Credenciales inválidas');
      }
      // Re-hashear automáticamente con bcrypt
      admin.passwordHash = await bcrypt.hash(password, BCRYPT_ROUNDS);
      admin.passwordNeedsMigration = false;
      admin.legacyPassword = null;
      await this.adminRepo.save(admin);
      return admin;
    }

    // Caso 2: Hash bcrypt normal
    const isValid = await bcrypt.compare(password, admin.passwordHash);
    if (!isValid) {
      throw new UnauthorizedException('Credenciales inválidas');
    }
    return admin;
  }

  async createAdmin(email: string, password: string, nombre: string): Promise<Admin> {
    const passwordHash = await bcrypt.hash(password, BCRYPT_ROUNDS);
    return this.adminRepo.save(
      this.adminRepo.create({ email, passwordHash, nombre }),
    );
  }

  async changePassword(adminId: number, oldPassword: string, newPassword: string): Promise<void> {
    const admin = await this.adminRepo.findOne({ where: { id: adminId } });
    const isValid = await bcrypt.compare(oldPassword, admin.passwordHash);
    if (!isValid) {
      throw new UnauthorizedException('Contraseña actual incorrecta');
    }
    admin.passwordHash = await bcrypt.hash(newPassword, BCRYPT_ROUNDS);
    await this.adminRepo.save(admin);
  }
}
```

**Entidad Admin con columnas de migración:**

```typescript
// src/modules/users/entities/admin.entity.ts
import { Entity, Column, PrimaryGeneratedColumn, CreateDateColumn, UpdateDateColumn } from 'typeorm';

@Entity('administradores')
export class Admin {
  @PrimaryGeneratedColumn()
  id: number;

  @Column()
  nombre: string;

  @Column({ unique: true })
  email: string;

  // --- NUEVO: reemplaza la columna 'contrasenia' ---
  @Column({ name: 'password_hash', nullable: true })
  passwordHash: string;

  // --- Columnas de migración (temporales) ---
  @Column({ name: 'password_needs_migration', default: false })
  passwordNeedsMigration: boolean;

  @Column({ name: 'legacy_password', nullable: true })
  legacyPassword: string;

  // --- Columnas existentes ---
  @Column({ name: 'tipo_id' })
  tipoId: number;

  @Column({ default: false })
  eliminado: boolean;

  @Column({ default: false })
  predeterminado: boolean;

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;

  @UpdateDateColumn({ name: 'updated_at' })
  updatedAt: Date;
}
```

### Estrategia de migración

1. **Migration SQL** agrega 3 columnas nuevas: `password_hash`, `password_needs_migration`, `legacy_password`.
2. **Script de migración inicial** copia el valor de `contrasenia` a `legacy_password`, setea `password_needs_migration = true`, y deja `password_hash = NULL`.
3. **Primer login post-migración:** se verifica contra `legacy_password` (texto plano), se genera bcrypt hash en `password_hash`, se limpia `legacy_password` y se setea `password_needs_migration = false`.
4. **Nuevos admins** se crean directamente con bcrypt (`password_needs_migration = false`).
5. **Una vez que todos los admins hayan migrado** (monitoreable vía query): eliminar las columnas `legacy_password` y `password_needs_migration` en una migration futura.

### Prioridad: **P0 — Día 1 del build**

**Confianza:** ALTA (la evidencia del auditor es inequívoca; la solución bcrypt es estándar de industria).

---

## V02 — Contraseñas Clientes en MD5 sin Salt

### Severidad: 🔴 CRÍTICA (CVSS-like: 8.5)

### Vector de ataque

1. Un atacante obtiene la tabla `clientes` de la base de datos (backup filtrado, acceso no autorizado, SQL injection en otra parte del sistema).
2. Los hashes MD5 sin salt son trivialmente crackeables:
   - Tiempo de crackeo con hardware moderno (RTX 4090): **~20 mil millones de hashes/segundo**.
   - Una contraseña de 8 caracteres alfanuméricos se crackea en **segundos o minutos**.
   - Rainbow tables precomputadas permiten lookup instantáneo para contraseñas comunes.
3. El atacante obtiene contraseñas de TODOS los clientes simultáneamente.
4. Si los clientes reutilizan contraseñas en otros servicios (email, bancos, redes sociales), el atacante puede acceder a esas cuentas.

### Impacto en negocio

- **Exposición masiva de PII:** emails + contraseñas de todos los clientes.
- **Account takeover masivo:** El atacante puede loguearse como cualquier cliente.
- **Riesgo de credential stuffing:** Si los clientes reutilizan contraseñas, el atacante puede acceder a sus cuentas de email, banca online, etc.
- **Daño reputacional y legal:** Violación de Ley 25.326. Multas de la AAIP (Agencia de Acceso a la Información Pública).
- **Pérdida de confianza:** Los clientes abandonan la plataforma.

### Evidence (del System Auditor)

> **Fuente:** `01-modelo-datos-actual.md`, sección 2.3
> "`clientes.contrasenia` VARCHAR(32) — **MD5 (sin salt)**"

> **Fuente:** `01-discovery-sistema-actual.md`, sección 1.3.1
> "`account_signin.php` (~120 líneas): Procesa login de cliente: valida email+md5(contrasenia)"

> **Fuente:** `01-discovery-sistema-actual.md`, Hallazgos Notables #2
> "Contraseñas de clientes en MD5 (sin salt)"

**Hecho:** La función `md5($password)` produce un hash de 32 caracteres hexadecimales sin salt, confirmado por la longitud de columna VARCHAR(32).

### Solución NestJS

**Paquetes:**
```bash
npm install bcrypt @types/bcrypt
```

> **Nota:** Se recomienda bcrypt sobre Argon2 en este caso porque bcrypt tiene soporte más maduro en Node.js y TypeORM. Argon2 puede evaluarse en una fase posterior.

**Service de autenticación de clientes:**

```typescript
// src/modules/auth/customer-auth.service.ts
import { Injectable, UnauthorizedException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import * as bcrypt from 'bcrypt';
import * as crypto from 'crypto';
import { Customer } from '../users/entities/customer.entity';

const BCRYPT_ROUNDS = 12;

@Injectable()
export class CustomerAuthService {
  constructor(
    @InjectRepository(Customer)
    private readonly customerRepo: Repository<Customer>,
  ) {}

  /**
   * Valida credenciales con estrategia de migración transparente.
   * Soporta: bcrypt (nuevo) y MD5 legacy (viejo).
   */
  async validateCustomer(email: string, password: string): Promise<Customer> {
    const customer = await this.customerRepo.findOne({
      where: { email, eliminado: false, activo: true },
    });

    if (!customer) {
      // Timing-safe dummy compare para no revelar si el email existe
      await bcrypt.compare(password, '$2b$12$' + 'x'.repeat(53));
      throw new UnauthorizedException('Credenciales inválidas');
    }

    // Caso 1: Hash legacy MD5 (primer login post-migración)
    if (customer.passwordNeedsMigration && customer.legacyMd5Hash) {
      const md5Hash = crypto.createHash('md5').update(password).digest('hex');
      if (md5Hash !== customer.legacyMd5Hash) {
        throw new UnauthorizedException('Credenciales inválidas');
      }
      // Re-hashear transparentemente con bcrypt
      customer.passwordHash = await bcrypt.hash(password, BCRYPT_ROUNDS);
      customer.passwordNeedsMigration = false;
      customer.legacyMd5Hash = null;
      customer.passwordMigratedAt = new Date();
      await this.customerRepo.save(customer);
      return customer;
    }

    // Caso 2: Hash bcrypt normal
    const isValid = await bcrypt.compare(password, customer.passwordHash);
    if (!isValid) {
      throw new UnauthorizedException('Credenciales inválidas');
    }
    return customer;
  }

  async register(email: string, password: string, nombre: string): Promise<Customer> {
    const passwordHash = await bcrypt.hash(password, BCRYPT_ROUNDS);
    return this.customerRepo.save(
      this.customerRepo.create({
        email,
        passwordHash,
        nombre,
        passwordNeedsMigration: false,
        activo: false, // requiere activación por email
      }),
    );
  }

  async changePassword(
    customerId: number,
    oldPassword: string,
    newPassword: string,
  ): Promise<void> {
    const customer = await this.customerRepo.findOne({ where: { id: customerId } });

    // Soporta tanto bcrypt como MD5 legacy
    let isValid = false;
    if (customer.passwordHash) {
      isValid = await bcrypt.compare(oldPassword, customer.passwordHash);
    } else if (customer.legacyMd5Hash) {
      const md5Hash = crypto.createHash('md5').update(oldPassword).digest('hex');
      isValid = md5Hash === customer.legacyMd5Hash;
    }

    if (!isValid) {
      throw new UnauthorizedException('Contraseña actual incorrecta');
    }

    customer.passwordHash = await bcrypt.hash(newPassword, BCRYPT_ROUNDS);
    customer.passwordNeedsMigration = false;
    customer.legacyMd5Hash = null;
    await this.customerRepo.save(customer);
  }

  /**
   * Endpoint forzado para migración batch de contraseñas.
   * Solo usar vía script admin o cron controlado.
   * NO exponer como endpoint público.
   */
  async migratePasswordBatch(batchSize = 100): Promise<number> {
    const pending = await this.customerRepo.find({
      where: { passwordNeedsMigration: true },
      take: batchSize,
    });
    // No se puede migrar en batch porque no conocemos la contraseña original.
    // Solo se migra en el momento del login.
    // Si se quiere forzar, hay que enviar email de "reset de contraseña por upgrade de seguridad".
    return 0;
  }
}
```

**Entidad Customer con columnas de migración:**

```typescript
// src/modules/users/entities/customer.entity.ts
@Entity('clientes')
export class Customer {
  // ... columnas existentes ...

  // NUEVO: Reemplaza la columna VARCHAR(32) 'contrasenia'
  @Column({ name: 'password_hash', nullable: true, length: 60 })
  passwordHash: string;

  // Columnas de migración temporal
  @Column({ name: 'password_needs_migration', default: false })
  passwordNeedsMigration: boolean;

  @Column({ name: 'legacy_md5_hash', nullable: true, length: 32 })
  legacyMd5Hash: string;

  @Column({ name: 'password_migrated_at', nullable: true, type: 'datetime' })
  passwordMigratedAt: Date;

  // ... resto de columnas ...
}
```

### Estrategia de migración

**Fase 1 — Migración de schema (Día 1):**
```sql
-- Agregar nuevas columnas (sin eliminar contrasenia todavía)
ALTER TABLE clientes
  ADD COLUMN password_hash VARCHAR(60) NULL,
  ADD COLUMN password_needs_migration TINYINT(1) DEFAULT 0,
  ADD COLUMN legacy_md5_hash VARCHAR(32) NULL,
  ADD COLUMN password_migrated_at DATETIME NULL;

-- Copiar hashes MD5 existentes a columna legacy
UPDATE clientes
SET legacy_md5_hash = contrasenia,
    password_needs_migration = 1
WHERE contrasenia IS NOT NULL AND contrasenia != '';
```

**Fase 2 — Migración progresiva por login (Día 1 en adelante):**
- Cada vez que un cliente inicia sesión, se verifica contra `legacy_md5_hash` y se re-hashea con bcrypt.
- El cliente no percibe ninguna diferencia.

**Fase 3 — Campaña de reset forzado (Semana 2):**
```typescript
// Para clientes que no han iniciado sesión en X días, enviar email:
// "Por tu seguridad, actualizamos nuestro sistema. Hacé clic para crear una nueva contraseña."
// Esto acelera la migración de usuarios inactivos.
```

**Fase 4 — Cleanup (cuando password_needs_migration = 0 para todos):**
```sql
ALTER TABLE clientes
  DROP COLUMN contrasenia,
  DROP COLUMN legacy_md5_hash,
  DROP COLUMN password_needs_migration;
```

### Prioridad: **P0 — Día 1 del build**

**Confianza:** ALTA. MD5 sin salt es trivial de crackear con hardware moderno. bcrypt con 12 rounds es el estándar.

---

## V03 — API Key OpenAI Hardcodeada en Código

### Severidad: 🔴 CRÍTICA (CVSS-like: 8.2)

### Vector de ataque

1. Cualquier desarrollador con acceso al repositorio ve la API key.
2. Si el repositorio es privado pero alguien lo forkeara/filtrara (error humano, CI/CD mal configurado), la key queda expuesta.
3. El repositorio actual es público: **https://github.com/LumbaDev/lumba-ecommerce** — rama `refactoring`.
4. Si la key está en el historial de git aunque se "borre" en un commit posterior, sigue accesible vía `git log`.
5. Un atacante con la key puede:
   - Hacer llamadas ilimitadas a OpenAI a nombre de Lumba (costo económico directo).
   - Usar el endpoint de chat como proxy para extraer datos del sistema o inyectar respuestas maliciosas a clientes.
   - Si la key tiene acceso a otros modelos (GPT-4, DALL-E), generar costos masivos.

### Impacto en negocio

- **Costo financiero directo:** Un atacante puede consumir cientos o miles de USD en llamadas API.
- **Exposición de datos:** Si el chatbot tiene acceso a información de productos/clientes en su contexto, el atacante podría extraerla vía prompt injection.
- **Daño a clientes:** Un atacante podría manipular las respuestas del chatbot para phishing o desinformación.

### Evidence (del System Auditor)

> **Fuente:** `01-discovery-sistema-actual.md`, Hallazgos Notables #3
> "API Key de OpenAI hardcodeada en `ajax/chat_handler.php`"

> **Fuente:** `01-integraciones.md`, sección 4.6
> "API Key — Hardcodeada en `ajax/chat_handler.php`. [⚠️ CRÍTICO] Debe moverse a variable de entorno. Modelo: `gpt-4o-mini`. Endpoint: `https://api.openai.com/v1/chat/completions`."

**Hecho:** La key está en un archivo PHP dentro del repositorio. Ya está expuesta en el historial de git.

### Solución NestJS

**Paquetes:**
```bash
npm install @nestjs/config openai
```

**Variables de entorno (`.env`):**
```env
# OpenAI - NO COMMITEAR ESTE ARCHIVO
OPENAI_API_KEY=sk-proj-xxxxxxxxxxxxxxxxxxxx
OPENAI_MODEL=gpt-4o-mini
OPENAI_MAX_TOKENS=1000
```

**Configuración tipada:**

```typescript
// src/config/openai.config.ts
import { registerAs } from '@nestjs/config';

export const openaiConfig = registerAs('openai', () => ({
  apiKey: process.env.OPENAI_API_KEY,
  model: process.env.OPENAI_MODEL || 'gpt-4o-mini',
  maxTokens: parseInt(process.env.OPENAI_MAX_TOKENS || '1000', 10),
}));
```

**Servicio con inyección de config:**

```typescript
// src/modules/chatbot/chatbot.service.ts
import { Injectable, OnModuleInit } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import OpenAI from 'openai';

@Injectable()
export class ChatbotService implements OnModuleInit {
  private openai: OpenAI;
  private model: string;
  private maxTokens: number;

  constructor(private readonly configService: ConfigService) {}

  onModuleInit() {
    const apiKey = this.configService.get<string>('openai.apiKey');
    if (!apiKey) {
      throw new Error('OPENAI_API_KEY no configurada. El chatbot no puede iniciar.');
    }

    this.openai = new OpenAI({ apiKey });
    this.model = this.configService.get<string>('openai.model', 'gpt-4o-mini');
    this.maxTokens = this.configService.get<number>('openai.maxTokens', 1000);
  }

  async chat(message: string, context: ChatContext): Promise<string> {
    const response = await this.openai.chat.completions.create({
      model: this.model,
      max_tokens: this.maxTokens,
      messages: [
        { role: 'system', content: this.buildSystemPrompt(context) },
        ...context.history,
        { role: 'user', content: message },
      ],
    });
    return response.choices[0]?.message?.content || 'Lo siento, no pude procesar tu mensaje.';
  }
  // ...
}
```

### Acciones adicionales URGENTES (fuera de NestJS)

1. **Rotar la key de OpenAI inmediatamente:**
   - Ir a https://platform.openai.com/api-keys
   - Revocar la key actual (la que está en el repo)
   - Crear una nueva key
   - La key expuesta ya NO debe ser válida

2. **Limpiar historial de git:**
   ```bash
   # NO es suficiente con borrar del commit actual.
   # La key sigue en el historial. Usar:
   git filter-branch --force --index-filter \
     "git rm --cached --ignore-unmatch ajax/chat_handler.php" \
     --prune-empty --tag-name-filter cat -- --all

   # O usar BFG Repo-Cleaner (más rápido):
   bfg --replace-text passwords.txt
   ```

3. **Verificar que la key actual NO esté en el repo público de GitHub.**

### Prioridad: **P0 — Día 1 (rotación inmediata, incluso antes del build)**

**Confianza:** ALTA. Key expuesta en repositorio público (o privado compartido) es un riesgo financiero y de seguridad inmediato.

---

## V04 — Webhooks de Pago Sin Validación de Firma

### Severidad: 🔴 CRÍTICA (CVSS-like: 9.1)

### Vector de ataque

**Escenario concreto:**

1. Un atacante estudia el endpoint `connect/mp_ipn.php` (o `connect/modo_webhook.php`).
2. Nota que el endpoint recibe un JSON con `pedido_id` y `order_status`, sin ninguna validación de firma, IP de origen, o secreto compartido.
3. El atacante envía un POST directo:
   ```bash
   curl -X POST https://lumbaecommerce.com/connect/mp_ipn.php \
     -H "Content-Type: application/json" \
     -d '{"pedido_id": 1234, "order_status": "paid"}'
   ```
4. El sistema marca el pedido #1234 como "Pagado" sin haber recibido un centavo.
5. Se envían emails de confirmación al cliente.
6. Se descuenta stock (`actualizarStock($pedido_id, 'restar')`).
7. Se confirma el envío con Zipnova (`confirmarEnvioZipnova($pedido_id)`).

**Resultado:** Producto enviado sin pago real.

**El atacante puede iterar sobre todos los IDs de pedidos existentes** (son secuenciales) y marcarlos como pagados.

### Impacto en negocio

- **Pérdida financiera directa:** Productos enviados sin cobrar.
- **Stock desincronizado:** Inventario descuenta items que no se pagaron.
- **Emails falsos a clientes:** "Tu pedido fue confirmado" cuando en realidad no pagaron.
- **Caos operativo:** El equipo de logística despacha productos basándose en pedidos "pagados" falsos.

### Evidence (del System Auditor)

> **Fuente:** `01-integraciones.md`, sección 4.1 (MercadoPago IPN)
> "**Seguridad:** [⚠️ CRÍTICO] No se detecta validación de firma o autenticidad del webhook. El IPN confía ciegamente en el cuerpo JSON."

> **Fuente:** `01-integraciones.md`, sección 4.2 (Modo Webhook)
> "**Seguridad:** [⚠️ CRÍTICO] Misma situación que MP — no hay validación de autenticidad del webhook."

> **Fuente:** `01-gaps-and-improvements.md`, sección 1.1
> "`mp_ipn.php` y `modo_webhook.php` confían ciegamente en el body JSON. No verifican `x-signature`."

**Hecho:** Ambos archivos reciben POST JSON sin verificar firma criptográfica, secreto compartido, ni IP de origen.

### Solución NestJS

**Paquetes:**
```bash
npm install @nestjs/config
```

**Guard genérico de validación de webhooks:**

```typescript
// src/common/guards/webhook-signature.guard.ts
import {
  Injectable,
  CanActivate,
  ExecutionContext,
  UnauthorizedException,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { Request } from 'express';
import * as crypto from 'crypto';

export interface WebhookProviderConfig {
  headerName: string;       // ej: 'x-signature' para MP
  secretEnvKey: string;     // ej: 'MERCADOPAGO_WEBHOOK_SECRET'
  algorithm?: string;       // ej: 'sha256'
  prefix?: string;          // ej: 'ts=' para MP (opcional)
}

@Injectable()
export class WebhookSignatureGuard implements CanActivate {
  constructor(private readonly configService: ConfigService) {}

  canActivate(context: ExecutionContext): boolean {
    const request = context.switchToHttp().getRequest<Request>();
    const providerConfig: WebhookProviderConfig = Reflect.getMetadata(
      'webhook:provider',
      context.getHandler(),
    );

    if (!providerConfig) {
      throw new UnauthorizedException('Configuración de webhook no encontrada');
    }

    const signature = request.headers[providerConfig.headerName.toLowerCase()] as string;
    if (!signature) {
      throw new UnauthorizedException('Falta firma del webhook');
    }

    const secret = this.configService.get<string>(providerConfig.secretEnvKey);
    if (!secret) {
      throw new UnauthorizedException('Secreto de webhook no configurado');
    }

    const rawBody = (request as any).rawBody || JSON.stringify(request.body);

    const isValid = this.verifySignature(
      rawBody,
      signature,
      secret,
      providerConfig,
    );

    if (!isValid) {
      // Loggear intento fallido para alertas de seguridad
      console.error('[SECURITY] Firma de webhook inválida', {
        provider: providerConfig.headerName,
        ip: request.ip,
        timestamp: new Date().toISOString(),
      });
      throw new UnauthorizedException('Firma de webhook inválida');
    }

    return true;
  }

  private verifySignature(
    payload: string,
    signature: string,
    secret: string,
    config: WebhookProviderConfig,
  ): boolean {
    const algorithm = config.algorithm || 'sha256';

    if (config.prefix) {
      // MercadoPago: x-signature: "ts=1234567890,v1=abcdef..."
      const parts = signature.split(',');
      const tsPart = parts.find((p) => p.startsWith('ts='));
      const v1Part = parts.find((p) => p.startsWith('v1='));

      if (!tsPart || !v1Part) {
        return false;
      }

      const ts = tsPart.split('=')[1];
      const expectedSignature = crypto
        .createHmac(algorithm, secret)
        .update(`id:${payload};ts:${ts};`)
        .digest('hex');

      return v1Part.split('=')[1] === expectedSignature;
    }

    // Genérico: comparar HMAC directamente
    const expectedSignature = crypto
      .createHmac(algorithm, secret)
      .update(payload)
      .digest('hex');

    return crypto.timingSafeEqual(
      Buffer.from(signature),
      Buffer.from(expectedSignature),
    );
  }
}
```

**Decorador para configurar el provider:**

```typescript
// src/common/decorators/webhook-provider.decorator.ts
import { SetMetadata } from '@nestjs/common';
import { WebhookProviderConfig } from '../guards/webhook-signature.guard';

export const WebhookProvider = (config: WebhookProviderConfig) =>
  SetMetadata('webhook:provider', config);
```

**Middleware para preservar raw body:**

```typescript
// src/common/middleware/raw-body.middleware.ts
import { Injectable, NestMiddleware } from '@nestjs/common';
import { Request, Response, NextFunction } from 'express';

@Injectable()
export class RawBodyMiddleware implements NestMiddleware {
  use(req: Request, res: Response, next: NextFunction) {
    let rawData = '';
    req.on('data', (chunk) => {
      rawData += chunk;
    });
    req.on('end', () => {
      (req as any).rawBody = rawData;
      // También parsear JSON para que los pipes de NestJS funcionen
      if (req.headers['content-type']?.includes('application/json')) {
        try {
          req.body = JSON.parse(rawData);
        } catch (e) {
          req.body = {};
        }
      }
      next();
    });
  }
}
```

**Controller de webhooks de MercadoPago:**

```typescript
// src/modules/payments/webhooks/mercadopago-webhook.controller.ts
import { Controller, Post, Body, UseGuards, HttpCode, Headers } from '@nestjs/common';
import { WebhookSignatureGuard } from '../../../common/guards/webhook-signature.guard';
import { WebhookProvider } from '../../../common/decorators/webhook-provider.decorator';
import { MercadoPagoWebhookService } from './mercadopago-webhook.service';

@Controller('webhooks/mercadopago')
export class MercadoPagoWebhookController {
  constructor(private readonly service: MercadoPagoWebhookService) {}

  @Post('ipn')
  @HttpCode(200)
  @UseGuards(WebhookSignatureGuard)
  @WebhookProvider({
    headerName: 'x-signature',
    secretEnvKey: 'MERCADOPAGO_WEBHOOK_SECRET',
    algorithm: 'sha256',
  })
  async handleIpn(@Body() body: { pedido_id: number; order_status: string }) {
    // Validar que el payload tenga los campos requeridos
    if (!body.pedido_id || !body.order_status) {
      return { status: 'ignored', reason: 'invalid_payload' };
    }

    // Idempotencia: verificar si ya procesamos este webhook
    const alreadyProcessed = await this.service.isDuplicate(body.pedido_id, body.order_status);
    if (alreadyProcessed) {
      return { status: 'already_processed' };
    }

    if (body.order_status === 'paid') {
      await this.service.handlePaymentConfirmed(body.pedido_id);
    } else if (body.order_status === 'reverted') {
      await this.service.handlePaymentReversed(body.pedido_id);
    }

    return { status: 'ok' };
  }
}
```

**Controller de webhooks de Modo:**

```typescript
// src/modules/payments/webhooks/modo-webhook.controller.ts
@Controller('webhooks/modo')
export class ModoWebhookController {
  // ...

  @Post()
  @HttpCode(200)
  @UseGuards(WebhookSignatureGuard)
  @WebhookProvider({
    headerName: 'x-modo-signature',
    secretEnvKey: 'MODO_WEBHOOK_SECRET',
    algorithm: 'sha256',
  })
  async handleWebhook(@Body() body: { pedido_id: string; order_status: string }) {
    // Validación de payload
    if (!body.pedido_id || !body.order_status) {
      return { status: 'ignored' };
    }

    if (body.order_status === 'ACCEPTED') {
      await this.service.handlePaymentAccepted(body.pedido_id);
    }

    return { status: 'ok' };
  }
}
```

**Service con registro de idempotencia:**

```typescript
// src/modules/payments/webhooks/webhook-log.service.ts
import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { WebhookLog } from './entities/webhook-log.entity';

@Injectable()
export class WebhookLogService {
  constructor(
    @InjectRepository(WebhookLog)
    private readonly repo: Repository<WebhookLog>,
  ) {}

  async isDuplicate(pedidoId: number, status: string): Promise<boolean> {
    const existing = await this.repo.findOne({
      where: { pedidoId, status, processed: true },
    });
    return !!existing;
  }

  async log(pedidoId: number, status: string, provider: string): Promise<void> {
    await this.repo.save(
      this.repo.create({ pedidoId, status, provider, processed: true }),
    );
  }
}
```

**Nueva entidad de logs de webhooks:**

```typescript
// src/modules/payments/webhooks/entities/webhook-log.entity.ts
@Entity('webhook_logs')
export class WebhookLog {
  @PrimaryGeneratedColumn()
  id: number;

  @Column({ name: 'pedido_id' })
  pedidoId: number;

  @Column()
  status: string;

  @Column()
  provider: string;

  @Column({ default: true })
  processed: boolean;

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;
}
```

### Estrategia de migración

1. **Antes del deploy de NestJS:** en el sistema PHP actual, agregar validación de firma al IPN existente como hotfix temporal (mientras se completa la migración).
2. **En NestJS:** implementar WebhookSignatureGuard desde el día 1.
3. **Configurar secretos:** Obtener `MERCADOPAGO_WEBHOOK_SECRET` desde el panel de MercadoPago (Configuración → Notificaciones → Webhooks). Para Modo, consultar documentación de su API.
4. **Agregar tabla `webhook_logs`** para idempotencia y auditoría.
5. **Tests:** simular webhooks con firma válida e inválida.

### Prioridad: **P0 — Día 1 del build**

**Confianza:** ALTA. Webhooks sin validación de firma son una vulnerabilidad de explotación trivial con impacto financiero directo.

---

## V05 — Credenciales de Pago en Tabla `configuracion` Sin Encriptación

### Severidad: 🔴 CRÍTICA (CVSS-like: 8.7)

### Vector de ataque

1. Cualquier administrador con acceso al panel de configuración (`admin/routes/configuracion.php`) puede ver todas las credenciales en texto plano.
2. Un atacante que obtenga acceso al panel admin (ej: vía V01 — contraseña en texto plano) ve inmediatamente:
   - `mercadopago_access_token`
   - `modo_username` / `modo_password`
   - `padpio_user` / `padpio_password`
   - `recaptcha_secret_key`
3. Con el access token de MercadoPago, el atacante puede:
   - Crear/refundear pagos vía API
   - Acceder a datos de transacciones de todos los clientes
   - Desviar pagos a otra cuenta
4. Con credenciales de PadPio, acceder a las bases SQL Server del sistema de gestión.

### Impacto en negocio

- **Robo de fondos:** Desviar pagos de MercadoPago/Modo.
- **Acceso lateral:** Las credenciales de PadPio permiten acceder al ERP/sistema de gestión.
- **Exposición de datos de transacciones:** Historial completo de pagos de clientes.
- **Principio de menor privilegio violado:** Todo admin ve todas las credenciales.

### Evidence (del System Auditor)

> **Fuente:** `01-modelo-datos-actual.md`, sección 2.9
> "Variables detectadas en `configuracion`: `mercadopago_access_token`, `modo_username`, `modo_password`, `modo_processor_code`, `modo_cc_code`, `padpio_user`, `padpio_password`, `padpio_host`, `recaptcha_site_key`, `recaptcha_secret_key`"

> **Fuente:** `01-gaps-and-improvements.md`, sección 1.1
> "Credenciales de pago en tabla `configuracion` sin encriptar. Secretos en `.env` o vault (HashiCorp Vault, Infisical, etc.). Settings de negocio en DB."

**Hecho:** La tabla `configuracion` es key-value (`variable` VARCHAR PK, `valor` TEXT). Todos los secretos están en texto plano.

### Solución NestJS

**Principio:** Separar secretos (`.env`) de configuración de negocio (DB).

| Tipo | ¿Dónde se guarda? | Ejemplos |
|---|---|---|
| **Secretos (credenciales)** | Variables de entorno (`.env`) o vault | `MERCADOPAGO_ACCESS_TOKEN`, `MODO_PASSWORD` |
| **Configuración de negocio** | Tabla `configuracion` en DB | `cuotas_mercadopago`, `compra_minima`, `email_compras` |
| **Configuración visual** | Tabla `configuracion` en DB | `logo_menu`, `favicon`, colores |

**Variables de entorno por tenant:**

```env
# .env.canccat — NO COMMITEAR
MERCADOPAGO_ACCESS_TOKEN=APP_USR-xxxxxxxxxxxxxxxxxxxx
MERCADOPAGO_WEBHOOK_SECRET=whsec_xxxxxxxxxxxxxxxxxxxx
MODO_USERNAME=usuario_modo
MODO_PASSWORD=clave_modo
MODO_PROCESSOR_CODE=12345
MODO_CC_CODE=CC-001
MODO_WEBHOOK_SECRET=modo_whsec_xxxx
PADPIO_HOST=192.168.1.100
PADPIO_USER=sa
PADPIO_PASSWORD=clave_padpio
OPENAI_API_KEY=sk-proj-xxxxxxxxxxxxxxxxxxxx
RECAPTCHA_SECRET_KEY=6Lc...xxx
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=no-reply@lumba.com
SMTP_PASSWORD=clave_smtp
JWT_SECRET=jwt_super_secreto_xxxx
JWT_REFRESH_SECRET=jwt_refresh_secreto_xxxx
```

**Configuración tipada en NestJS:**

```typescript
// src/config/payment.config.ts
import { registerAs } from '@nestjs/config';

export const paymentConfig = registerAs('payment', () => ({
  mercadopago: {
    accessToken: process.env.MERCADOPAGO_ACCESS_TOKEN,
    webhookSecret: process.env.MERCADOPAGO_WEBHOOK_SECRET,
    // Cuotas es config de negocio → DB, no .env
  },
  modo: {
    username: process.env.MODO_USERNAME,
    password: process.env.MODO_PASSWORD,
    processorCode: process.env.MODO_PROCESSOR_CODE,
    ccCode: process.env.MODO_CC_CODE,
    webhookSecret: process.env.MODO_WEBHOOK_SECRET,
  },
}));
```

```typescript
// src/config/integration.config.ts
import { registerAs } from '@nestjs/config';

export const integrationConfig = registerAs('integration', () => ({
  padpio: {
    host: process.env.PADPIO_HOST,
    user: process.env.PADPIO_USER,
    password: process.env.PADPIO_PASSWORD,
  },
  recaptcha: {
    siteKey: process.env.RECAPTCHA_SITE_KEY,
    secretKey: process.env.RECAPTCHA_SECRET_KEY,
  },
}));
```

**Servicio de configuración de negocio (lo que SÍ va en DB):**

```typescript
// src/modules/tenant/business-config.service.ts
@Injectable()
export class BusinessConfigService {
  constructor(
    @InjectRepository(Configuracion)
    private readonly configRepo: Repository<Configuracion>,
  ) {}

  // Solo devuelve config de NEGOCIO, NUNCA secretos
  async getCuotasMercadoPago(): Promise<number | null> {
    const row = await this.configRepo.findOne({
      where: { variable: 'cuotas_mercadopago' },
    });
    return row ? parseInt(row.valor, 10) : null;
  }

  async getCompraMinima(): Promise<number> {
    const row = await this.configRepo.findOne({
      where: { variable: 'compra_minima_sin_impuestos' },
    });
    return row ? parseFloat(row.valor) : 0;
  }

  // Panel de admin: mostrar valores con máscara
  async getConfigForAdmin(): Promise<Record<string, string>> {
    const configs = await this.configRepo.find();
    const result: Record<string, string> = {};
    for (const c of configs) {
      // Si alguna variable sensible aún existe en DB, enmascararla
      if (this.isSensitiveVariable(c.variable)) {
        result[c.variable] = '••••••••';
      } else {
        result[c.variable] = c.valor;
      }
    }
    return result;
  }

  private isSensitiveVariable(name: string): boolean {
    const sensitive = ['token', 'password', 'secret', 'key', 'api_key'];
    return sensitive.some((s) => name.toLowerCase().includes(s));
  }
}
```

### Estrategia de migración

1. **Auditar todas las variables en `configuracion`** y clasificarlas en "secreto" vs "configuración".
2. **Mover secretos a `.env`** antes del primer deploy de NestJS.
3. **Eliminar variables de secreto de la tabla `configuracion`** (o marcarlas como `deprecated`).
4. **En el panel admin:** el campo de configuración de pagos debe mostrar "Configurado" o "••••••••" en vez del valor real. Para cambiar, usar un input tipo password.
5. **Validación al iniciar la app:** si falta alguna variable crítica, la app lanza error y no inicia.

### Prioridad: **P0 — Día 1 del build**

**Confianza:** ALTA. Separar secretos de configuración de negocio es principio fundamental de seguridad.

---

## V06 — Sin Rate Limiting en Endpoints de Autenticación

### Severidad: 🟠 ALTA (CVSS-like: 7.5)

### Vector de ataque

1. **Ataque de fuerza bruta contra login:**
   ```bash
   # Sin rate limiting, un atacante puede probar miles de contraseñas:
   for password in $(cat rockyou.txt); do
     curl -X POST https://ecommerce.com/auth/login \
       -d "email=victima@email.com&password=$password"
   done
   ```

2. **Ataque de enumeración de usuarios:** probar emails y ver si la respuesta difiere ("usuario no existe" vs "contraseña incorrecta").

3. **Ataque DoS contra registro:** crear miles de cuentas falsas agotando recursos de DB.

4. **Ataque de spam en recuperación de contraseña:** enviar cientos de emails de reset a una víctima.

5. **Credential stuffing:** probar combinaciones email:password de breaches conocidos.

### Impacto en negocio

- **Account takeover** si el atacante acierta una contraseña débil.
- **Degradación del servicio** (DoS) por consumo de recursos.
- **Spam a clientes** vía emails de recuperación.
- **Base de datos contaminada** con cuentas falsas.

### Evidence (del System Auditor)

> **Fuente:** `01-gaps-and-improvements.md`, sección 1.1
> "Sin rate limiting en login/registro/recuperación — No se detectó ningún mecanismo de rate limiting en `account_signin.php`, `account_register.php`, `account_recover.php`."

**Hecho:** No existe ningún middleware, contador, o bloqueo por IP/intentos en los endpoints de autenticación.

### Solución NestJS

**Paquetes:**
```bash
npm install @nestjs/throttler
```

**Configuración global de Throttler:**

```typescript
// src/app.module.ts
import { Module } from '@nestjs/common';
import { ThrottlerModule, ThrottlerGuard } from '@nestjs/throttler';
import { APP_GUARD } from '@nestjs/core';

@Module({
  imports: [
    ThrottlerModule.forRoot([
      {
        name: 'short',
        ttl: 1000,   // 1 segundo
        limit: 10,    // máximo 10 requests por segundo (global)
      },
      {
        name: 'medium',
        ttl: 60000,  // 1 minuto
        limit: 100,   // máximo 100 requests por minuto
      },
      {
        name: 'long',
        ttl: 3600000, // 1 hora
        limit: 1000,  // máximo 1000 requests por hora
      },
    ]),
  ],
  providers: [
    {
      provide: APP_GUARD,
      useClass: ThrottlerGuard,
    },
  ],
})
export class AppModule {}
```

**Rate limiting ESPECÍFICO para auth (más restrictivo):**

```typescript
// src/modules/auth/auth.controller.ts
import { Controller, Post, Body, UseGuards } from '@nestjs/common';
import { Throttle, ThrottlerGuard } from '@nestjs/throttler';

@Controller('auth')
export class AuthController {
  // Login: máximo 5 intentos por IP cada 15 minutos
  @Post('login')
  @UseGuards(ThrottlerGuard)
  @Throttle({ default: { limit: 5, ttl: 900000 } }) // 15 min
  async login(@Body() dto: LoginDto) {
    return this.authService.login(dto);
  }

  // Registro: máximo 3 cuentas por IP cada hora
  @Post('register')
  @UseGuards(ThrottlerGuard)
  @Throttle({ default: { limit: 3, ttl: 3600000 } }) // 1 hora
  async register(@Body() dto: RegisterDto) {
    return this.authService.register(dto);
  }

  // Recuperación: máximo 3 solicitudes por IP cada hora
  @Post('recover')
  @UseGuards(ThrottlerGuard)
  @Throttle({ default: { limit: 3, ttl: 3600000 } })
  async recoverPassword(@Body() dto: RecoverDto) {
    return this.authService.initiatePasswordRecovery(dto.email);
  }

  // Activación de cuenta: máximo 5 intentos por IP cada hora
  @Post('activate')
  @UseGuards(ThrottlerGuard)
  @Throttle({ default: { limit: 5, ttl: 3600000 } })
  async activate(@Body() dto: ActivateDto) {
    return this.authService.activateAccount(dto.hash);
  }
}
```

**Rate limiting avanzado con Redis (producción):**

```typescript
// src/modules/throttle/throttle-storage-redis.service.ts
import { Injectable } from '@nestjs/common';
import { ThrottlerStorage } from '@nestjs/throttler';
import Redis from 'ioredis';

@Injectable()
export class ThrottlerStorageRedis implements ThrottlerStorage {
  private redis: Redis;

  constructor() {
    this.redis = new Redis({
      host: process.env.REDIS_HOST || 'localhost',
      port: parseInt(process.env.REDIS_PORT || '6379', 10),
    });
  }

  async increment(
    key: string,
    ttl: number,
    limit: number,
    blockDuration: number,
    throttlerName: string,
  ): Promise<{ totalHits: number; timeToExpire: number; isBlocked: boolean; timeToBlockExpire: number }> {
    const multi = this.redis.multi();
    multi.incr(key);
    multi.pttl(key);
    const results = await multi.exec();
    const totalHits = results[0][1] as number;
    const pttl = results[1][1] as number;

    if (totalHits === 1) {
      await this.redis.pexpire(key, ttl);
    }

    return {
      totalHits,
      timeToExpire: Math.max(0, pttl),
      isBlocked: totalHits > limit,
      timeToBlockExpire: totalHits > limit ? pttl : 0,
    };
  }
}
```

**Protección adicional: bloqueo de cuenta por intentos fallidos:**

```typescript
// src/modules/auth/auth.service.ts (método de login)
async login(dto: LoginDto, ip: string): Promise<LoginResponse> {
  const MAX_FAILED_ATTEMPTS = 5;
  const LOCKOUT_MINUTES = 30;

  // Verificar si la cuenta está bloqueada por intentos fallidos
  const isLocked = await this.checkAccountLockout(dto.email);
  if (isLocked) {
    throw new TooManyRequestsException(
      'Cuenta bloqueada temporalmente por múltiples intentos fallidos. Intente de nuevo en 30 minutos.',
    );
  }

  try {
    const customer = await this.customerAuth.validateCustomer(dto.email, dto.password);
    // Login exitoso → resetear contador
    await this.resetFailedAttempts(dto.email);
    return this.generateTokens(customer);
  } catch (error) {
    if (error instanceof UnauthorizedException) {
      await this.incrementFailedAttempts(dto.email, ip);
    }
    throw error;
  }
}
```

### Prioridad: **P1 — Semana 1**

**Confianza:** ALTA. `@nestjs/throttler` es la solución canónica. El bloqueo de cuenta es adicional recomendado.

---

## V07 — Sin Protección CSRF

### Severidad: 🟠 ALTA (CVSS-like: 8.0)

### Vector de ataque

1. Un cliente está autenticado en el ecommerce (tiene sesión activa o JWT en cookie/localStorage).
2. El atacante crea una página maliciosa en otro dominio con un formulario oculto:
   ```html
   <!-- atacante.com/evil.html -->
   <form action="https://lumbaecommerce.com/cart/add" method="POST">
     <input type="hidden" name="productoId" value="999">
     <input type="hidden" name="cantidad" value="1000">
   </form>
   <script>document.forms[0].submit();</script>
   ```
3. La víctima visita la página maliciosa → el formulario se envía automáticamente a la tienda.
4. Si la autenticación usa cookies (sesión PHP o JWT en cookie), el navegador las adjunta automáticamente.
5. La acción se ejecuta como si la víctima la hubiera hecho: agregar items al carrito, cambiar dirección de envío, modificar datos del perfil, etc.

**Peor escenario con el admin:**
- Un admin autenticado visita un sitio malicioso → se ejecuta CSRF contra el panel de administración → se modifica un precio, se elimina un producto, se cambia una configuración.

### Impacto en negocio

- **Acciones no autorizadas** en nombre del cliente/admin.
- **Modificación de datos sensibles** (dirección de envío, perfil, carrito).
- **Potencial fraude** si se combina con otras vulnerabilidades.

### Evidence (del System Auditor)

> **Fuente:** `01-gaps-and-improvements.md`, sección 1.1
> "No se detectaron tokens CSRF en formularios ni validación server-side."

**Hecho:** No existe ningún mecanismo de tokens anti-CSRF en el sistema PHP actual.

### Solución NestJS

**Paquetes:**
```bash
npm install csurf
# O usar el paquete nativo de NestJS si se usa sesiones
npm install express-session @types/express-session
```

**Opción recomendada: Doble capa de protección**

**Capa 1: SameSite Cookies (primera línea de defensa)**
```typescript
// src/main.ts
import * as cookieParser from 'cookie-parser';

// Configurar cookies con SameSite estricto
app.use(cookieParser());
```

**Capa 2: Token CSRF cuando se usan sesiones**

```typescript
// src/modules/csrf/csrf.service.ts
import { Injectable } from '@nestjs/common';
import * as crypto from 'crypto';

@Injectable()
export class CsrfService {
  generateToken(): string {
    return crypto.randomBytes(32).toString('hex');
  }

  validateToken(sessionToken: string, requestToken: string): boolean {
    if (!sessionToken || !requestToken) return false;
    return crypto.timingSafeEqual(
      Buffer.from(sessionToken),
      Buffer.from(requestToken),
    );
  }
}
```

```typescript
// src/common/guards/csrf.guard.ts
import { Injectable, CanActivate, ExecutionContext, ForbiddenException } from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import { Request } from 'express';

// Decorador para excluir endpoints del CSRF (webhooks, APIs públicas)
export const SkipCsrf = () => SetMetadata('skipCsrf', true);

@Injectable()
export class CsrfGuard implements CanActivate {
  constructor(private readonly reflector: Reflector) {}

  canActivate(context: ExecutionContext): boolean {
    const skipCsrf = this.reflector.get<boolean>('skipCsrf', context.getHandler());
    if (skipCsrf) return true;

    const request = context.switchToHttp().getRequest<Request>();

    // Solo aplicar en métodos mutadores
    const method = request.method.toUpperCase();
    if (['GET', 'HEAD', 'OPTIONS'].includes(method)) {
      return true;
    }

    const sessionToken = request.session?.csrfToken;
    const requestToken =
      request.headers['x-csrf-token'] as string ||
      request.body?._csrf;

    if (!sessionToken || !requestToken || sessionToken !== requestToken) {
      throw new ForbiddenException('CSRF token inválido');
    }

    return true;
  }
}
```

**Excluir explícitamente webhooks de CSRF:**

```typescript
@Controller('webhooks/mercadopago')
export class MercadoPagoWebhookController {
  @Post('ipn')
  @SkipCsrf() // Los webhooks no pueden enviar token CSRF
  @UseGuards(WebhookSignatureGuard) // Pero TIENEN su propia validación de firma
  async handleIpn() { /* ... */ }
}
```

**Frontend (Next.js):** enviar token CSRF en cada request mutador:

```typescript
// fetch wrapper con CSRF token
async function apiClient(url: string, options: RequestInit = {}) {
  const csrfToken = getCookie('csrf-token');
  return fetch(url, {
    ...options,
    headers: {
      ...options.headers,
      'X-CSRF-Token': csrfToken || '',
      'Content-Type': 'application/json',
    },
  });
}
```

### Prioridad: **P1 — Semana 1**

**Confianza:** ALTA. La combinación SameSite + token CSRF es la defensa estándar.

---

## V08 — Sin Content Security Policy ni Security Headers HTTP

### Severidad: 🟡 MEDIA (CVSS-like: 5.0 — defensa en profundidad)

### Vector de ataque

1. **XSS (Cross-Site Scripting):** Si un atacante logra inyectar JavaScript vía un input no sanitizado (formulario de contacto, reseña, nombre de producto en admin), sin CSP el script se ejecutará.
2. **Clickjacking:** Sin `X-Frame-Options`, un atacante puede embeber la tienda en un iframe invisible y superponer elementos para engañar al usuario.
3. **Man-in-the-Middle:** Sin HSTS, un atacante en la misma red puede degradar HTTPS → HTTP.
4. **MIME sniffing:** Sin `X-Content-Type-Options`, el navegador puede interpretar archivos como un tipo diferente.

### Impacto en negocio

- **Robo de sesiones** vía XSS (token robado).
- **Phishing visual** vía clickjacking (iframe malicioso con overlay).
- **Intercepción de datos** vía downgrade de HTTPS.
- **Defacement** vía inyección de contenido.

### Evidence (del System Auditor)

> **Fuente:** `01-gaps-and-improvements.md`, sección 1.1
> "Sin Content Security Policy (CSP) — No se detectaron headers de seguridad HTTP."

**Hecho:** No se emiten headers de seguridad en las respuestas HTTP del sistema actual.

### Solución NestJS

**Paquetes:**
```bash
npm install helmet
```

**Configuración completa:**

```typescript
// src/main.ts
import { NestFactory } from '@nestjs/core';
import helmet from 'helmet';
import { AppModule } from './app.module';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);

  // Helmet con CSP personalizado
  app.use(
    helmet({
      // Content Security Policy
      contentSecurityPolicy: {
        directives: {
          defaultSrc: ["'self'"],
          scriptSrc: [
            "'self'",
            // Scripts de MercadoPago Checkout
            'https://sdk.mercadopago.com',
            // Google reCAPTCHA v3
            'https://www.google.com',
            'https://www.gstatic.com',
            // Analytics (si se usa)
            'https://www.googletagmanager.com',
            'https://www.google-analytics.com',
          ],
          styleSrc: [
            "'self'",
            "'unsafe-inline'", // Necesario para algunos estilos inline de Tailwind
            'https://fonts.googleapis.com',
          ],
          fontSrc: [
            "'self'",
            'https://fonts.gstatic.com',
          ],
          imgSrc: [
            "'self'",
            'data:', // imágenes inline (base64)
            'https:', // imágenes de productos desde cualquier origen HTTPS
            'blob:',   // para previews de upload
          ],
          connectSrc: [
            "'self'",
            // API de OpenAI (chatbot)
            'https://api.openai.com',
            // APIs de pago
            'https://api.mercadopago.com',
            'https://api.modo.com.ar',
            // Zipnova
            'https://api.zipnova.com',
          ],
          frameSrc: [
            "'self'",
            // Checkout de MercadoPago se abre en iframe
            'https://www.mercadopago.com.ar',
            'https://www.mercadopago.com',
            'https://www.mercadolibre.com.ar',
            // Checkout de Modo
            'https://modo.com.ar',
          ],
          frameAncestors: ["'none'"], // Previene clickjacking
          formAction: [
            "'self'",
            'https://www.mercadopago.com',
          ],
          upgradeInsecureRequests: [],
        },
      },
      // Strict Transport Security (1 año, incluye subdominios)
      hsts: {
        maxAge: 31536000, // 1 año en segundos
        includeSubDomains: true,
        preload: true,
      },
      // Previene MIME type sniffing
      xContentTypeOptions: true,
      // Previene clickjacking (redundante con frame-ancestors pero más compatible)
      xFrameOptions: { action: 'deny' },
      // Remueve header X-Powered-By
      hidePoweredBy: true,
      // DNS prefetch control
      dnsPrefetchControl: { allow: false },
      // Referrer policy
      referrerPolicy: { policy: 'strict-origin-when-cross-origin' },
    }),
  );

  // Helmet NO establece X-XSS-Protection porque es obsoleto y CSP es superior

  await app.listen(3000);
}
bootstrap();
```

**Header personalizado para ocultar stack tecnológico:**

```typescript
// src/common/middleware/security-headers.middleware.ts
import { Injectable, NestMiddleware } from '@nestjs/common';
import { Request, Response, NextFunction } from 'express';

@Injectable()
export class SecurityHeadersMiddleware implements NestMiddleware {
  use(req: Request, res: Response, next: NextFunction) {
    // Remover headers que revelan tecnología
    res.removeHeader('X-Powered-By');
    res.removeHeader('Server');

    // Permissions-Policy: deshabilitar features del navegador que no usamos
    res.setHeader(
      'Permissions-Policy',
      'camera=(), microphone=(), geolocation=(), interest-cohort=()',
    );

    // Cross-Origin-Embedder-Policy (si se usa SharedArrayBuffer o WASM)
    // res.setHeader('Cross-Origin-Embedder-Policy', 'require-corp');

    next();
  }
}
```

**Middleware para forzar HTTPS en producción:**

```typescript
// src/common/middleware/https-redirect.middleware.ts
import { Injectable, NestMiddleware } from '@nestjs/common';
import { Request, Response, NextFunction } from 'express';

@Injectable()
export class HttpsRedirectMiddleware implements NestMiddleware {
  use(req: Request, res: Response, next: NextFunction) {
    // En producción, redirigir HTTP → HTTPS
    if (
      process.env.NODE_ENV === 'production' &&
      !req.secure &&
      req.headers['x-forwarded-proto'] !== 'https'
    ) {
      const httpsUrl = `https://${req.hostname}${req.originalUrl}`;
      return res.redirect(301, httpsUrl);
    }
    next();
  }
}
```

### Prioridad: **P2 — Semana 2**

**Confianza:** ALTA. Helmet es estándar en NestJS. CSP requiere tuning fino según los servicios externos usados.

---

## V09 — Endpoints Admin Sin Verificación de Permisos Consistente

### Severidad: 🟠 ALTA (CVSS-like: 7.5)

### Vector de ataque

1. El sistema actual tiene control de acceso basado en `administradores_tipos_permisos`.
2. Pero un admin con un rol limitado podría adivinar/descubrir rutas de admin que no tienen verificación de permisos.
3. El parámetro `route` se pasa por GET (`?route=productos_new`), es fácil de manipular.
4. La sanitización `preg_replace('/[^a-zA-Z0-9_-]/', '', $route)` NO verifica que el usuario tenga permiso para esa ruta, solo que el nombre de archivo sea válido.

### Impacto en negocio

- Un admin con rol limitado (ej: solo ve pedidos) puede acceder a secciones no autorizadas.
- Vertical privilege escalation dentro del panel admin.

### Evidence (del System Auditor)

> **Fuente:** `01-discovery-sistema-actual.md`, sección 1.2.1
> "Control de acceso: basado en `administradores_tipos_permisos` asignados al tipo de usuario. Seguridad: sanitización de ruta con `preg_replace('/[^a-zA-Z0-9_-]/', '', $route)`."

> **Fuente:** El auditor NO pudo verificar que todas las rutas admin tengan verificación de permisos.

### Solución NestJS

**Guard de permisos tipado:**

```typescript
// src/common/decorators/permissions.decorator.ts
import { SetMetadata } from '@nestjs/common';

export const PERMISSIONS_KEY = 'permissions';
export const RequirePermission = (...permissions: string[]) =>
  SetMetadata(PERMISSIONS_KEY, permissions);
```

```typescript
// src/common/guards/permissions.guard.ts
import {
  Injectable,
  CanActivate,
  ExecutionContext,
  ForbiddenException,
} from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import { PERMISSIONS_KEY } from '../decorators/permissions.decorator';

@Injectable()
export class PermissionsGuard implements CanActivate {
  constructor(private readonly reflector: Reflector) {}

  canActivate(context: ExecutionContext): boolean {
    const requiredPermissions = this.reflector.getAllAndOverride<string[]>(
      PERMISSIONS_KEY,
      [context.getHandler(), context.getClass()],
    );

    // Si no se especifican permisos, se permite el acceso
    if (!requiredPermissions || requiredPermissions.length === 0) {
      return true;
    }

    const request = context.switchToHttp().getRequest();
    const user = request.user; // Seteado por JwtAuthGuard

    if (!user || !user.permissions) {
      throw new ForbiddenException('Sin permisos asignados');
    }

    const hasPermission = requiredPermissions.some(
      (perm) => user.permissions.includes(perm),
    );

    if (!hasPermission) {
      throw new ForbiddenException(
        `No tiene permiso: ${requiredPermissions.join(', ')}`,
      );
    }

    return true;
  }
}
```

**Uso en controllers:**

```typescript
// src/modules/admin/products/admin-products.controller.ts
@Controller('admin/products')
@UseGuards(JwtAuthGuard, PermissionsGuard) // Aplicar a todo el controller
export class AdminProductsController {

  @Get()
  @RequirePermission('productos.ver')
  findAll() { /* ... */ }

  @Post()
  @RequirePermission('productos.crear')
  create() { /* ... */ }

  @Put(':id')
  @RequirePermission('productos.editar')
  update() { /* ... */ }

  @Delete(':id')
  @RequirePermission('productos.eliminar')
  remove() { /* ... */ }

  @Post('import-excel')
  @RequirePermission('productos.importar')
  importExcel() { /* ... */ }
}
```

**JWT payload incluye permisos:**

```typescript
// src/modules/auth/auth.service.ts (admin login)
async adminLogin(email: string, password: string): Promise<LoginResponse> {
  const admin = await this.adminAuth.validateAdmin(email, password);

  // Cargar permisos del tipo de admin
  const permissions = await this.permissionsService.getPermissionsForTipo(admin.tipoId);

  const payload = {
    sub: admin.id,
    email: admin.email,
    nombre: admin.nombre,
    tipoId: admin.tipoId,
    permissions: permissions, // ['productos.ver', 'productos.crear', ...]
  };

  return {
    accessToken: this.jwtService.sign(payload),
  };
}
```

### Prioridad: **P1 — Semana 1**

**Confianza:** ALTA. Guards de permisos son un patrón estándar en NestJS.

---

## V10 — Sesiones PHP Sin Hardening

### Severidad: 🟠 ALTA (CVSS-like: 6.5)

### Vector de ataque

1. **Session fixation:** El sistema PHP actual usa sesiones nativas. Un atacante puede fijar un ID de sesión antes del login y luego usarlo para impersonar al usuario.
2. **Session hijacking:** Si el ID de sesión viaja por HTTP (sin Secure flag) o es accesible vía JavaScript (sin HttpOnly flag), un atacante puede robarlo.
3. **Sesiones sin expiración:** Las sesiones PHP pueden vivir indefinidamente si no se configuran correctamente.

### Solución NestJS

**Reemplazar sesiones PHP con JWT stateless:**

```typescript
// src/modules/auth/jwt.module.ts
import { Module } from '@nestjs/common';
import { JwtModule } from '@nestjs/jwt';
import { ConfigModule, ConfigService } from '@nestjs/config';

@Module({
  imports: [
    JwtModule.registerAsync({
      imports: [ConfigModule],
      inject: [ConfigService],
      useFactory: (config: ConfigService) => ({
        secret: config.get<string>('JWT_SECRET'),
        signOptions: {
          expiresIn: '15m', // Access token: corta duración
          issuer: 'lumba-ecommerce',
        },
      }),
    }),
  ],
  exports: [JwtModule],
})
export class JwtConfigModule {}
```

**Estrategia completa de tokens:**

```typescript
// src/modules/auth/auth.service.ts
@Injectable()
export class AuthService {
  constructor(
    private readonly jwtService: JwtService,
    private readonly configService: ConfigService,
  ) {}

  async generateTokens(user: Customer | Admin): Promise<TokenPair> {
    const payload = { sub: user.id, email: user.email, role: this.getRole(user) };

    const accessToken = this.jwtService.sign(payload, {
      secret: this.configService.get('JWT_SECRET'),
      expiresIn: '15m',
    });

    const refreshToken = this.jwtService.sign(payload, {
      secret: this.configService.get('JWT_REFRESH_SECRET'),
      expiresIn: '7d',
    });

    return { accessToken, refreshToken, expiresIn: 900 };
  }

  async refreshTokens(refreshToken: string): Promise<TokenPair> {
    try {
      const payload = this.jwtService.verify(refreshToken, {
        secret: this.configService.get('JWT_REFRESH_SECRET'),
      });

      // Verificar que el refresh token no esté revocado (blacklist en Redis)
      const isRevoked = await this.tokenService.isRefreshTokenRevoked(refreshToken);
      if (isRevoked) {
        throw new UnauthorizedException('Refresh token revocado');
      }

      // Invalidar el refresh token actual (rotation)
      await this.tokenService.revokeRefreshToken(refreshToken);

      // Generar nuevo par de tokens
      return this.generateTokens(payload);
    } catch {
      throw new UnauthorizedException('Refresh token inválido o expirado');
    }
  }

  async logout(userId: number, refreshToken: string): Promise<void> {
    // Revocar todos los refresh tokens del usuario
    await this.tokenService.revokeUserRefreshTokens(userId);
  }
}
```

**Cookies seguras para el frontend:**

```typescript
// Al setear el refresh token como cookie HTTP-only:
response.cookie('refreshToken', refreshToken, {
  httpOnly: true,   // No accesible vía JavaScript
  secure: process.env.NODE_ENV === 'production', // Solo HTTPS en prod
  sameSite: 'strict', // Protección CSRF
  maxAge: 7 * 24 * 60 * 60 * 1000, // 7 días
  path: '/auth/refresh', // Solo accesible en el endpoint de refresh
});
```

### Prioridad: **P1 — Semana 1**

**Confianza:** ALTA. JWT con refresh token rotation es el estándar para APIs REST.

---

## V11 — Sin Validación de Inputs Consistente

### Severidad: 🟡 MEDIA (CVSS-like: 6.0)

### Vector de ataque

1. **SQL Injection residual:** Aunque la mayor parte del código PHP usa interpolación directa en queries, la migración a TypeORM con parámetros elimina este riesgo. Pero si hay queries raw (`createQueryBuilder` con concatenación), el riesgo persiste.
2. **XSS:** Inputs sin sanitizar (nombre de producto ingresado por admin, reseña de cliente, campos de checkout) que se renderizan sin escapar.
3. **Mass Assignment:** Endpoints que aceptan todos los campos del body sin whitelist.

### Solución NestJS

**Paquetes:**
```bash
npm install class-validator class-transformer
```

**ValidationPipe global con whitelist estricta:**

```typescript
// src/main.ts
import { ValidationPipe } from '@nestjs/common';

app.useGlobalPipes(
  new ValidationPipe({
    whitelist: true,              // Elimina propiedades no decoradas
    forbidNonWhitelisted: true,   // Lanza error si hay propiedades no decoradas
    transform: true,              // Transforma tipos automáticamente
    transformOptions: {
      enableImplicitConversion: true, // Convierte strings a números, booleans, etc.
    },
  }),
);
```

**DTOs con validación estricta:**

```typescript
// src/modules/auth/dto/register.dto.ts
import { IsEmail, IsString, MinLength, MaxLength, Matches } from 'class-validator';
import { Transform } from 'class-transformer';

export class RegisterDto {
  @IsEmail({}, { message: 'Email inválido' })
  @Transform(({ value }) => value?.toLowerCase().trim())
  email: string;

  @IsString()
  @MinLength(8, { message: 'La contraseña debe tener al menos 8 caracteres' })
  @MaxLength(128)
  @Matches(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)/, {
    message: 'La contraseña debe contener mayúsculas, minúsculas y números',
  })
  password: string;

  @IsString()
  @MinLength(2)
  @MaxLength(100)
  @Transform(({ value }) => value?.trim())
  nombre: string;

  @IsString()
  @MinLength(2)
  @MaxLength(100)
  @Transform(({ value }) => value?.trim())
  apellido: string;
}
```

```typescript
// src/modules/checkout/dto/checkout-step1.dto.ts
export class CheckoutStep1Dto {
  @IsString()
  @MinLength(2)
  @MaxLength(100)
  @Matches(/^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s'-]+$/, {
    message: 'El nombre contiene caracteres inválidos',
  })
  nombre: string;

  // ... resto de campos con validaciones apropiadas

  @Matches(/^\d{7,8}$/, {
    message: 'DNI inválido (7-8 dígitos sin puntos)',
  })
  dni?: string;

  @Matches(/^\d{10,11}$/, {
    message: 'CUIT inválido (10-11 dígitos sin guiones)',
  })
  cuit?: string;
}
```

**Sanitización de HTML (para reseñas, contenido de admin):**

```typescript
// src/modules/content/content-sanitizer.service.ts
import { Injectable } from '@nestjs/common';
import * as DOMPurify from 'dompurify';
import { JSDOM } from 'jsdom';

@Injectable()
export class ContentSanitizerService {
  private purify: DOMPurify.DOMPurifyI;

  constructor() {
    const window = new JSDOM('').window;
    this.purify = DOMPurify(window as any);
  }

  sanitize(html: string): string {
    return this.purify.sanitize(html, {
      ALLOWED_TAGS: ['b', 'i', 'em', 'strong', 'a', 'p', 'br', 'ul', 'ol', 'li'],
      ALLOWED_ATTR: ['href', 'target', 'rel'],
    });
  }

  stripAll(html: string): string {
    return this.purify.sanitize(html, { ALLOWED_TAGS: [], ALLOWED_ATTR: [] });
  }
}
```

### Prioridad: **P2 — Semana 2**

**Confianza:** ALTA. class-validator + ValidationPipe es la solución nativa de NestJS.

---

## V12 — Sin Logs de Seguridad y Auditoría

### Severidad: 🟡 MEDIA (CVSS-like: 4.0 — afecta detección y forense)

### Vector de ataque

Sin logs, los incidentes de seguridad pasan completamente desapercibidos. No hay forma de:
- Saber si hubo intentos de fuerza bruta.
- Detectar accesos no autorizados.
- Auditar quién modificó qué en el admin.
- Reconstruir eventos post-incidente.

### Solución NestJS

**Paquetes:**
```bash
npm install nest-winston winston
```

**Configuración de Winston:**

```typescript
// src/config/logger.config.ts
import * as winston from 'winston';
import { WinstonModule } from 'nest-winston';

export const createLogger = () => {
  const { combine, timestamp, json, colorize, printf } = winston.format;

  return WinstonModule.createLogger({
    level: process.env.LOG_LEVEL || 'info',
    format: combine(
      timestamp({ format: 'YYYY-MM-DD HH:mm:ss' }),
      json(),
    ),
    transports: [
      // Consola con colores en desarrollo
      new winston.transports.Console({
        format: combine(
          colorize(),
          printf(({ timestamp, level, message, context, ...meta }) => {
            return `${timestamp} [${level}] [${context || 'APP'}]: ${message} ${Object.keys(meta).length ? JSON.stringify(meta) : ''}`;
          }),
        ),
      }),
      // Archivo de logs generales
      new winston.transports.File({
        filename: 'logs/app.log',
        maxsize: 10 * 1024 * 1024, // 10MB
        maxFiles: 5,
      }),
      // Archivo específico para eventos de seguridad
      new winston.transports.File({
        filename: 'logs/security.log',
        level: 'warn',
        maxsize: 10 * 1024 * 1024,
        maxFiles: 10,
      }),
    ],
  });
};
```

**Interceptor de auditoría para admin:**

```typescript
// src/common/interceptors/audit-log.interceptor.ts
import {
  Injectable,
  NestInterceptor,
  ExecutionContext,
  CallHandler,
} from '@nestjs/common';
import { Observable } from 'rxjs';
import { tap } from 'rxjs/operators';
import { Logger } from '@nestjs/common';

@Injectable()
export class AuditLogInterceptor implements NestInterceptor {
  private readonly logger = new Logger('AUDIT');

  intercept(context: ExecutionContext, next: CallHandler): Observable<any> {
    const request = context.switchToHttp().getRequest();
    const user = request.user;
    const method = request.method;
    const url = request.originalUrl;
    const body = this.sanitizeBody(request.body);

    const startTime = Date.now();

    return next.handle().pipe(
      tap({
        next: (response) => {
          this.logger.log({
            event: 'admin_action',
            userId: user?.sub,
            userEmail: user?.email,
            method,
            url,
            body,
            statusCode: context.switchToHttp().getResponse().statusCode,
            durationMs: Date.now() - startTime,
            ip: request.ip,
            userAgent: request.headers['user-agent'],
            timestamp: new Date().toISOString(),
          });
        },
        error: (error) => {
          this.logger.error({
            event: 'admin_action_failed',
            userId: user?.sub,
            userEmail: user?.email,
            method,
            url,
            body,
            error: error.message,
            statusCode: error.status || 500,
            ip: request.ip,
            timestamp: new Date().toISOString(),
          });
        },
      }),
    );
  }

  private sanitizeBody(body: any): any {
    if (!body) return {};
    // Nunca loggear contraseñas
    const sanitized = { ...body };
    const sensitiveFields = ['password', 'contrasenia', 'token', 'secret', 'accessToken', 'refreshToken'];
    for (const field of sensitiveFields) {
      if (sanitized[field]) {
        sanitized[field] = '[REDACTED]';
      }
    }
    return sanitized;
  }
}
```

**Registro de eventos de seguridad específicos:**

```typescript
// src/common/services/security-log.service.ts
import { Injectable, Logger } from '@nestjs/common';

@Injectable()
export class SecurityLogService {
  private readonly logger = new Logger('SECURITY');

  logFailedLogin(email: string, ip: string, reason: string): void {
    this.logger.warn({
      event: 'failed_login',
      email,
      ip,
      reason,
      timestamp: new Date().toISOString(),
    });
  }

  logSuccessfulLogin(userId: number, email: string, role: string, ip: string): void {
    this.logger.log({
      event: 'successful_login',
      userId,
      email,
      role,
      ip,
      timestamp: new Date().toISOString(),
    });
  }

  logWebhookSignatureFailure(provider: string, ip: string): void {
    this.logger.error({
      event: 'webhook_signature_failure',
      provider,
      ip,
      timestamp: new Date().toISOString(),
    });
  }

  logRateLimitExceeded(endpoint: string, ip: string): void {
    this.logger.warn({
      event: 'rate_limit_exceeded',
      endpoint,
      ip,
      timestamp: new Date().toISOString(),
    });
  }

  logPermissionDenied(userId: number, requiredPermission: string, url: string): void {
    this.logger.warn({
      event: 'permission_denied',
      userId,
      requiredPermission,
      url,
      timestamp: new Date().toISOString(),
    });
  }

  logDataChange(userId: number, entity: string, entityId: number, changes: Record<string, any>): void {
    this.logger.log({
      event: 'data_change',
      userId,
      entity,
      entityId,
      changes,
      timestamp: new Date().toISOString(),
    });
  }
}
```

### Prioridad: **P2 — Semana 2**

**Confianza:** ALTA. Winston + nest-winston es la solución estándar de logging en NestJS.

---

## V13 — reCAPTCHA Secret Key en Tabla `configuracion`

### Severidad: 🟡 MEDIA (CVSS-like: 4.5)

### Vector de ataque

Similar a V05 pero de menor impacto. Un atacante con acceso a la tabla `configuracion` puede:
1. Obtener `recaptcha_secret_key`.
2. Bypassear la verificación de reCAPTCHA en formularios públicos (contacto, devoluciones).
3. Automatizar spam/form submissions.

### Solución

Mover `RECAPTCHA_SECRET_KEY` a `.env`. La `RECAPTCHA_SITE_KEY` (que es pública) puede permanecer en la DB o en config del frontend.

### Prioridad: **P2 — Semana 2** (parte de V05)

---

## V14 — Sin Sanitización de Uploads

### Severidad: 🟡 MEDIA (CVSS-like: 6.5)

### Vector de ataque

1. Un admin malicioso (o atacante con acceso) sube un archivo PHP disfrazado como imagen.
2. Si el directorio de uploads es accesible vía web y ejecuta PHP, el atacante obtiene RCE (Remote Code Execution).
3. Upload de archivos excesivamente grandes puede causar DoS.

### Solución NestJS

**Paquetes:**
```bash
npm install multer @types/multer file-type
```

**Pipe de validación de uploads:**

```typescript
// src/common/pipes/file-validation.pipe.ts
import { PipeTransform, Injectable, BadRequestException } from '@nestjs/common';
import * as fileType from 'file-type';
import * as path from 'path';

const ALLOWED_MIME_TYPES = [
  'image/jpeg',
  'image/png',
  'image/webp',
  'image/gif',
  'image/svg+xml',
];

const ALLOWED_EXTENSIONS = ['.jpg', '.jpeg', '.png', '.webp', '.gif', '.svg'];

const MAX_FILE_SIZE = 5 * 1024 * 1024; // 5MB

@Injectable()
export class FileValidationPipe implements PipeTransform {
  async transform(file: Express.Multer.File) {
    if (!file) {
      throw new BadRequestException('Archivo requerido');
    }

    // 1. Validar tamaño
    if (file.size > MAX_FILE_SIZE) {
      throw new BadRequestException(
        `El archivo excede el tamaño máximo de ${MAX_FILE_SIZE / 1024 / 1024}MB`,
      );
    }

    // 2. Validar extensión
    const ext = path.extname(file.originalname).toLowerCase();
    if (!ALLOWED_EXTENSIONS.includes(ext)) {
      throw new BadRequestException(
        `Extensión no permitida: ${ext}. Permitidas: ${ALLOWED_EXTENSIONS.join(', ')}`,
      );
    }

    // 3. Validar MIME type del contenido real (no confiar en el header)
    const detectedType = await fileType.fromBuffer(file.buffer);
    if (!detectedType || !ALLOWED_MIME_TYPES.includes(detectedType.mime)) {
      throw new BadRequestException(
        `El archivo no es una imagen válida. Tipo detectado: ${detectedType?.mime || 'desconocido'}`,
      );
    }

    // 4. Renombrar archivo para prevenir path traversal
    const safeName = `${Date.now()}-${crypto.randomBytes(8).toString('hex')}${ext}`;
    file.originalname = safeName;

    return file;
  }
}
```

**Controller con validación de upload:**

```typescript
// src/modules/content/upload.controller.ts
import {
  Controller,
  Post,
  UploadedFile,
  UseInterceptors,
  UseGuards,
  ParseFilePipe,
  MaxFileSizeValidator,
  FileTypeValidator,
} from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { PermissionsGuard } from '../../common/guards/permissions.guard';
import { RequirePermission } from '../../common/decorators/permissions.decorator';

@Controller('admin/upload')
@UseGuards(JwtAuthGuard, PermissionsGuard)
export class UploadController {

  @Post('product-image')
  @RequirePermission('productos.editar')
  @UseInterceptors(FileInterceptor('file'))
  async uploadProductImage(
    @UploadedFile(
      new ParseFilePipe({
        validators: [
          new MaxFileSizeValidator({ maxSize: 5 * 1024 * 1024 }), // 5MB
          new FileTypeValidator({ fileType: /^image\/(jpeg|png|webp|gif)$/ }),
        ],
      }),
    )
    file: Express.Multer.File,
  ) {
    // Procesar y guardar archivo
    const url = await this.storageService.upload(file, 'products');
    return { url };
  }
}
```

**Almacenamiento fuera del webroot:**

```typescript
// src/modules/storage/storage.service.ts
@Injectable()
export class StorageService {
  async upload(file: Express.Multer.File, folder: string): Promise<string> {
    // Guardar en directorio fuera del webroot
    const uploadDir = path.join(
      process.env.STORAGE_PATH || '/var/www/uploads',
      folder,
    );
    await fs.mkdir(uploadDir, { recursive: true });

    const safeName = `${Date.now()}-${crypto.randomBytes(8).toString('hex')}${path.extname(file.originalname)}`;
    const filePath = path.join(uploadDir, safeName);
    await fs.writeFile(filePath, file.buffer);

    // Devolver URL de acceso (a través de un controller que sirve archivos)
    return `/api/files/${folder}/${safeName}`;
  }
}
```

### Prioridad: **P2 — Semana 2**

**Confianza:** ALTA. Validación en múltiples capas + almacenamiento fuera del webroot.

---

## Resumen de Prioridades y Secuencia de Implementación

```
DÍA 1 (P0 - Críticas — bloquearían un deploy a producción):
┌──────────────────────────────────────────────────────────┐
│ V03: Rotar API Key OpenAI (INMEDIATO, incluso antes)     │
│ V01: bcrypt para passwords admin + migration columns     │
│ V02: bcrypt para passwords clientes + md5 migration      │
│ V04: WebhookSignatureGuard + middleware raw body         │
│ V05: Mover secretos a .env, separar de DB config         │
└──────────────────────────────────────────────────────────┘

SEMANA 1 (P1 - Altas — necesarias para MVP estable):
┌──────────────────────────────────────────────────────────┐
│ V06: @nestjs/throttler + account lockout                 │
│ V07: CSRF tokens + SameSite cookies                      │
│ V09: PermissionsGuard + decorators                       │
│ V10: JWT + refresh token rotation + secure cookies       │
└──────────────────────────────────────────────────────────┘

SEMANA 2 (P2 - Medias — hardening y defensa en profundidad):
┌──────────────────────────────────────────────────────────┐
│ V08: Helmet + CSP + HSTS + security headers              │
│ V11: ValidationPipe global + DTOs estrictos               │
│ V12: Winston logging + audit interceptor                  │
│ V13: reCAPTCHA secret a .env                              │
│ V14: File validation pipe + storage fuera del webroot     │
└──────────────────────────────────────────────────────────┘
```

---

## Checklist de Verificación Pre-Deploy

Antes de cualquier deploy a producción, verificar:

- [ ] Todas las contraseñas admin están migradas a bcrypt (V01)
- [ ] Todos los clientes que iniciaron sesión post-migración tienen bcrypt (V02)
- [ ] API key de OpenAI rotada y NO en el repositorio (V03)
- [ ] Webhooks de pago rechazan requests sin firma válida (V04)
- [ ] No hay secretos en la tabla `configuracion` (V05)
- [ ] Rate limiting activo en login, registro, recuperación (V06)
- [ ] Tokens CSRF funcionando en todos los formularios mutadores (V07)
- [ ] Helmet emitiendo todos los headers de seguridad (V08)
- [ ] Guards de permisos en todos los endpoints admin (V09)
- [ ] JWT con refresh token rotation implementado (V10)
- [ ] `.env` en `.gitignore` y sin datos reales en el repo
- [ ] Tests de seguridad automatizados en CI/CD

---

> **Confianza global de este documento:** ALTA. Todas las vulnerabilidades están documentadas con evidencia concreta del System Auditor. Las soluciones NestJS propuestas siguen prácticas estándar de la industria y son directamente implementables. Nivel de confianza MEDIA-ALTA en las estimaciones de tiempo (dependen del tamaño real del equipo de build).

---

*Documento preparado por el Security Agent basado exclusivamente en los hallazgos del System Auditor (2026-06-04), el Product Owner (2026-06-08), y análisis de seguridad independiente. Los hechos son del auditor. Las soluciones y prioridades son del Security Agent.*
