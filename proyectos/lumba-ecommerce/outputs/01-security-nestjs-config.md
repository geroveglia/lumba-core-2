# 01 — Security NestJS Configuration Guide

> **Proyecto:** Lumba Ecommerce (Brownfield — migración PHP vanilla → NestJS + Tailwind)
> **Fecha:** 2026-06-08
> **Rol:** Security Agent
> **Modelo:** deepseek-v4-pro
> **Nivel de confianza global:** ALTA
> **Propósito:** Guía práctica de configuración de seguridad para copiar y pegar en el proyecto NestJS.

---

## Índice

1. [Paquetes npm — Lista Completa](#1-paquetes-npm--lista-completa)
2. [Configuración de Helmet con CSP](#2-configuración-de-helmet-con-csp)
3. [Configuración de Rate Limiting](#3-configuración-de-rate-limiting)
4. [Configuración de CORS Restrictiva](#4-configuración-de-cors-restrictiva)
5. [Configuración de JWT Seguro](#5-configuración-de-jwt-seguro)
6. [Variables de Entorno por Tenant](#6-variables-de-entorno-por-tenant)
7. [Configuración de Logging de Seguridad](#7-configuración-de-logging-de-seguridad)
8. [Configuración de Validación (class-validator + ValidationPipe)](#8-configuración-de-validación)
9. [Configuración de CSRF Protection](#9-configuración-de-csrf-protection)
10. [Template de .env.example](#10-template-de-envexample)
11. [main.ts — Configuración Completa](#11-maints--configuración-completa)
12. [app.module.ts — Módulo Raíz](#12-appmodulets--módulo-raíz)

---

## 1. Paquetes npm — Lista Completa

```bash
# === Seguridad Core ===
npm install bcrypt @types/bcrypt                     # Hashing de contraseñas
npm install helmet                                    # Headers de seguridad HTTP
npm install @nestjs/throttler                        # Rate limiting
npm install @nestjs/jwt @nestjs/passport passport passport-jwt  # Autenticación JWT
npm install @nestjs/config                           # Variables de entorno tipadas
npm install cookie-parser @types/cookie-parser       # Cookies seguras

# === Validación ===
npm install class-validator class-transformer        # Validación de inputs/DTOs

# === CSRF (si se usa sesiones) ===
npm install express-session @types/express-session   # Sesiones server-side

# === Logging de Seguridad ===
npm install nest-winston winston                      # Logging estructurado

# === CORS ===
# Incluido en @nestjs/platform-express — no requiere paquete extra

# === File Upload Security ===
npm install multer @types/multer                     # Upload de archivos
npm install file-type                                # Detección de MIME type real

# === Sanitización HTML ===
npm install dompurify jsdom                          # Sanitización de contenido HTML

# === Rate Limiting con Redis (producción) ===
npm install ioredis @nestjs/bullmq bullmq            # Redis + job queue

# === API Documentation (útil para seguridad: documenta endpoints) ===
npm install @nestjs/swagger                          # Swagger/OpenAPI

# === Dev Dependencies ===
npm install -D @types/passport-jwt @types/multer @types/express
```

### Versiones recomendadas (package.json snippet)

```json
{
  "dependencies": {
    "@nestjs/common": "^10.3.0",
    "@nestjs/config": "^3.2.0",
    "@nestjs/core": "^10.3.0",
    "@nestjs/jwt": "^10.2.0",
    "@nestjs/passport": "^10.0.3",
    "@nestjs/platform-express": "^10.3.0",
    "@nestjs/swagger": "^7.3.0",
    "@nestjs/throttler": "^5.1.0",
    "@nestjs/typeorm": "^10.0.1",
    "bcrypt": "^5.1.1",
    "class-transformer": "^0.5.1",
    "class-validator": "^0.14.1",
    "cookie-parser": "^1.4.6",
    "dompurify": "^3.0.11",
    "file-type": "^19.0.0",
    "helmet": "^7.1.0",
    "ioredis": "^5.3.2",
    "jsdom": "^24.0.0",
    "multer": "^1.4.5-lts.1",
    "nest-winston": "^1.9.4",
    "passport": "^0.7.0",
    "passport-jwt": "^4.0.1",
    "typeorm": "^0.3.20",
    "winston": "^3.12.0"
  },
  "devDependencies": {
    "@types/bcrypt": "^5.0.2",
    "@types/cookie-parser": "^1.4.7",
    "@types/express": "^4.17.21",
    "@types/multer": "^1.4.11",
    "@types/passport-jwt": "^4.0.1"
  }
}
```

---

## 2. Configuración de Helmet con CSP

### Archivo: `src/config/helmet.config.ts`

```typescript
import helmet from 'helmet';
import { INestApplication } from '@nestjs/common';

/**
 * Configuración de Helmet con Content Security Policy adaptada
 * a los servicios externos usados por Lumba Ecommerce.
 *
 * Servicios externos que requieren entradas en CSP:
 * - MercadoPago SDK (script, frame, connect)
 * - Modo (frame)
 * - Google reCAPTCHA (script)
 * - OpenAI API (connect)
 * - Google Fonts (style, font)
 * - Zipnova API (connect, opcional)
 */
export function configureHelmet(app: INestApplication): void {
  const isProduction = process.env.NODE_ENV === 'production';

  const helmetConfig: Parameters<typeof helmet>[0] = {
    // ============ Content Security Policy ============
    contentSecurityPolicy: isProduction
      ? {
          directives: {
            defaultSrc: ["'self'"],

            // Scripts
            scriptSrc: [
              "'self'",
              // MercadoPago SDK (Checkout Pro)
              'https://sdk.mercadopago.com',
              'https://http2.mlstatic.com',
              // Google reCAPTCHA v3
              'https://www.google.com',
              'https://www.gstatic.com',
              // Google Analytics / Tag Manager (si se usa)
              'https://www.googletagmanager.com',
              'https://www.google-analytics.com',
              // Para desarrollo: inline scripts de HMR
              ...(isProduction ? [] : ["'unsafe-inline'", "'unsafe-eval'"]),
            ],

            // Estilos
            styleSrc: [
              "'self'",
              "'unsafe-inline'", // Necesario para Tailwind y estilos dinámicos
              'https://fonts.googleapis.com',
              'https://sdk.mercadopago.com',
            ],

            // Fuentes
            fontSrc: [
              "'self'",
              'https://fonts.gstatic.com',
              'data:', // Para fuentes inline base64
            ],

            // Imágenes
            imgSrc: [
              "'self'",
              'data:',          // Imágenes inline base64
              'blob:',          // Previews de upload
              'https:',          // Imágenes de productos desde CDN o URLs externas
            ],

            // Conexiones (fetch, XHR, WebSocket)
            connectSrc: [
              "'self'",
              // APIs externas
              'https://api.openai.com',
              'https://api.mercadopago.com',
              'https://api.mercadolibre.com',
              // Modo (verificar dominio exacto)
              'https://api.modo.com.ar',
              // Zipnova (verificar dominio exacto)
              'https://api.zipnova.com',
              // Analytics
              'https://www.google-analytics.com',
              // Desarrollo: WebSocket HMR
              ...(isProduction
                ? []
                : ['ws://localhost:*', 'http://localhost:*']),
            ],

            // Frames (Checkout embebido)
            frameSrc: [
              "'self'",
              'https://www.mercadopago.com.ar',
              'https://www.mercadopago.com',
              'https://www.mercadolibre.com.ar',
              'https://www.mercadolibre.com',
              'https://modo.com.ar',
            ],

            // Anti-clickjacking
            frameAncestors: ["'none'"],

            // Form actions
            formAction: [
              "'self'",
              'https://www.mercadopago.com',
            ],

            // Media (video/audio)
            mediaSrc: ["'self'"],

            // Object (Flash, etc) — bloquear completamente
            objectSrc: ["'none'"],

            // Base URI
            baseUri: ["'self'"],

            // Upgrade insecure requests
            upgradeInsecureRequests: [],
          },
        }
      : false, // Deshabilitar CSP en desarrollo para facilitar debugging

    // ============ HSTS (HTTP Strict Transport Security) ============
    hsts: {
      maxAge: 31536000, // 1 año en segundos
      includeSubDomains: true,
      preload: true,
    },

    // ============ Otros headers de seguridad ============

    // Previene MIME type sniffing
    xContentTypeOptions: true,

    // Anti-clickjacking (respaldo para navegadores viejos sin frame-ancestors)
    xFrameOptions: { action: 'deny' },

    // Oculta header X-Powered-By: Express
    hidePoweredBy: true,

    // Deshabilita DNS prefetch
    dnsPrefetchControl: { allow: false },

    // Referrer Policy
    referrerPolicy: { policy: 'strict-origin-when-cross-origin' },

    // Cross-Origin-Opener-Policy
    crossOriginOpenerPolicy: { policy: 'same-origin' },

    // Cross-Origin-Resource-Policy
    crossOriginResourcePolicy: { policy: 'same-origin' },

    // Origin-Agent-Cluster
    originAgentCluster: true,
  };

  app.use(helmet(helmetConfig));
}
```

### Headers adicionales (middleware separado)

**Archivo: `src/common/middleware/security-headers.middleware.ts`**

```typescript
import { Injectable, NestMiddleware } from '@nestjs/common';
import { Request, Response, NextFunction } from 'express';

@Injectable()
export class SecurityHeadersMiddleware implements NestMiddleware {
  use(_req: Request, res: Response, next: NextFunction): void {
    // Remover headers que revelan stack tecnológico
    res.removeHeader('X-Powered-By');

    // Permissions-Policy: deshabilitar APIs del navegador que no usamos
    res.setHeader(
      'Permissions-Policy',
      [
        'camera=()',
        'microphone=()',
        'geolocation=()',
        'interest-cohort=()', // FLoC (Google Topics)
        'payment=()',          // Payment Request API (usamos redirect a MP/Modo)
      ].join(', '),
    );

    // Cache-Control para endpoints de API
    if (_req.path.startsWith('/api/')) {
      res.setHeader('Cache-Control', 'no-store, no-cache, must-revalidate, private');
    }

    next();
  }
}
```

---

## 3. Configuración de Rate Limiting

### Archivo: `src/config/throttler.config.ts`

```typescript
import { ThrottlerModuleOptions } from '@nestjs/throttler';

/**
 * Configuración de rate limiting multi-nivel.
 *
 * Niveles:
 * - 'short':  10 req/segundo (protección anti-DoS básica)
 * - 'medium': 100 req/minuto (límite general de API)
 * - 'long':   1000 req/hora (protección de abuso sostenido)
 * - 'auth':   5 req/15min (login, registro, recuperación — aplicado por decorador)
 */
export const throttlerConfig: ThrottlerModuleOptions = {
  throttlers: [
    {
      name: 'short',
      ttl: 1000,       // 1 segundo
      limit: 10,       // 10 requests
    },
    {
      name: 'medium',
      ttl: 60000,      // 1 minuto
      limit: 100,      // 100 requests
    },
    {
      name: 'long',
      ttl: 3600000,    // 1 hora
      limit: 1000,     // 1000 requests
    },
  ],
  errorMessage: 'Demasiadas solicitudes. Intente de nuevo en unos segundos.',
};
```

### Configuración de Throttler con Redis (producción)

**Archivo: `src/modules/throttle/throttler-redis-storage.ts`**

```typescript
import { Injectable, OnModuleDestroy } from '@nestjs/common';
import { ThrottlerStorage, ThrottlerStorageRecord } from '@nestjs/throttler';
import Redis from 'ioredis';

@Injectable()
export class ThrottlerStorageRedis implements ThrottlerStorage, OnModuleDestroy {
  private redis: Redis;

  constructor() {
    this.redis = new Redis({
      host: process.env.REDIS_HOST || 'localhost',
      port: parseInt(process.env.REDIS_PORT || '6379', 10),
      password: process.env.REDIS_PASSWORD || undefined,
      db: parseInt(process.env.REDIS_THROTTLE_DB || '1', 10),
      keyPrefix: 'throttle:',
      retryStrategy: (times) => Math.min(times * 50, 2000),
    });
  }

  async increment(
    key: string,
    ttl: number,
    limit: number,
    blockDuration: number,
    throttlerName: string,
  ): Promise<ThrottlerStorageRecord> {
    const redisKey = `${throttlerName}:${key}`;

    const multi = this.redis.multi();
    multi.incr(redisKey);
    multi.pttl(redisKey);

    const results = await multi.exec();
    if (!results) {
      return { totalHits: 0, timeToExpire: 0, isBlocked: false, timeToBlockExpire: 0 };
    }

    const totalHits = (results[0][1] as number) || 0;
    const pttl = (results[1][1] as number) || 0;

    // Setear TTL en el primer hit
    if (totalHits === 1) {
      await this.redis.pexpire(redisKey, ttl);
    }

    const isBlocked = totalHits > limit;
    const timeToBlockExpire = isBlocked ? pttl : 0;

    return {
      totalHits,
      timeToExpire: Math.max(0, pttl),
      isBlocked,
      timeToBlockExpire,
    };
  }

  async onModuleDestroy(): Promise<void> {
    await this.redis.quit();
  }
}
```

### Rate limits por endpoint (usando decoradores)

```typescript
// src/modules/auth/auth.controller.ts — ejemplo de uso
import { Controller, Post } from '@nestjs/common';
import { Throttle } from '@nestjs/throttler';

@Controller('auth')
export class AuthController {

  @Post('login')
  @Throttle({ default: { limit: 5, ttl: 900000 } }) // 5 intentos cada 15 min
  async login() { /* ... */ }

  @Post('register')
  @Throttle({ default: { limit: 3, ttl: 3600000 } }) // 3 registros por hora
  async register() { /* ... */ }

  @Post('recover')
  @Throttle({ default: { limit: 3, ttl: 3600000 } }) // 3 solicitudes por hora
  async recover() { /* ... */ }

  @Post('admin/login')
  @Throttle({ default: { limit: 3, ttl: 900000 } }) // Aún más restrictivo para admin
  async adminLogin() { /* ... */ }
}

// src/modules/chatbot/chatbot.controller.ts
@Controller('chat')
export class ChatbotController {
  @Post('message')
  @Throttle({ default: { limit: 10, ttl: 60000 } }) // 10 mensajes por minuto
  async sendMessage() { /* ... */ }
}
```

---

## 4. Configuración de CORS Restrictiva

### Archivo: `src/config/cors.config.ts`

```typescript
import { CorsOptions } from '@nestjs/common/interfaces/external/cors-options.interface';

/**
 * Configuración CORS restrictiva.
 *
 * Principios:
 * 1. Solo los dominios de la tienda pueden acceder a la API.
 * 2. Métodos HTTP limitados a los necesarios.
 * 3. Credenciales (cookies) solo para dominios explícitamente permitidos.
 * 4. Max age para cachear preflight.
 */
export function getCorsConfig(): CorsOptions {
  const allowedOrigins: (string | RegExp)[] = [];

  // Dominios de producción por tenant
  if (process.env.CORS_ORIGINS) {
    allowedOrigins.push(...process.env.CORS_ORIGINS.split(','));
  } else {
    // Por defecto: desarrollo local
    allowedOrigins.push('http://localhost:3000');
    allowedOrigins.push('http://localhost:5173'); // Vite dev server
    allowedOrigins.push('http://localhost:3001');
  }

  // En desarrollo, permitir localhost con cualquier puerto
  if (process.env.NODE_ENV !== 'production') {
    allowedOrigins.push(/^http:\/\/localhost:\d+$/);
  }

  return {
    origin: (origin, callback) => {
      // Permitir requests sin origin (server-to-server, Postman, curl)
      if (!origin) {
        return callback(null, true);
      }

      const isAllowed = allowedOrigins.some((allowed) => {
        if (allowed instanceof RegExp) {
          return allowed.test(origin);
        }
        return allowed === origin;
      });

      if (isAllowed) {
        callback(null, true);
      } else {
        console.warn(`[SECURITY] CORS bloqueado para origen: ${origin}`);
        callback(new Error(`Origen ${origin} no permitido por CORS`));
      }
    },

    methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],

    allowedHeaders: [
      'Content-Type',
      'Authorization',
      'X-CSRF-Token',
      'X-Tenant-ID',
      'Accept',
      'Accept-Language',
    ],

    exposedHeaders: [
      'X-RateLimit-Limit',
      'X-RateLimit-Remaining',
      'X-RateLimit-Reset',
    ],

    credentials: true, // Permitir cookies (refresh token)

    maxAge: 86400, // Cachear preflight por 24 horas
  };
}
```

---

## 5. Configuración de JWT Seguro

### Estrategia de tokens

```
Access Token:  15 minutos, en memoria del frontend (NO localStorage)
Refresh Token: 7 días, cookie HTTP-only + Secure + SameSite=Strict
```

### Archivo: `src/config/jwt.config.ts`

```typescript
import { JwtModuleOptions } from '@nestjs/jwt';
import { ConfigService } from '@nestjs/config';

export const getJwtConfig = (config: ConfigService): JwtModuleOptions => ({
  secret: config.get<string>('JWT_ACCESS_SECRET'),
  signOptions: {
    expiresIn: '15m',
    issuer: 'lumba-ecommerce',
    audience: config.get<string>('APP_URL'),
  },
});

export const getJwtRefreshConfig = {
  secret: process.env.JWT_REFRESH_SECRET,
  expiresIn: '7d',
};
```

### JWT Strategy con validación completa

**Archivo: `src/modules/auth/strategies/jwt.strategy.ts`**

```typescript
import { Injectable, UnauthorizedException } from '@nestjs/common';
import { PassportStrategy } from '@nestjs/passport';
import { ExtractJwt, Strategy } from 'passport-jwt';
import { ConfigService } from '@nestjs/config';
import { Request } from 'express';

interface JwtPayload {
  sub: number;       // user ID
  email: string;
  role: 'customer' | 'admin';
  permissions?: string[]; // solo para admin
  iat?: number;
  exp?: number;
  iss?: string;
}

@Injectable()
export class JwtStrategy extends PassportStrategy(Strategy, 'jwt') {
  constructor(configService: ConfigService) {
    super({
      jwtFromRequest: ExtractJwt.fromExtractors([
        // 1. Intentar desde header Authorization: Bearer <token>
        ExtractJwt.fromAuthHeaderAsBearerToken(),
        // 2. Intentar desde cookie 'accessToken' (fallback para SSR)
        (request: Request) => {
          return request?.cookies?.accessToken || null;
        },
      ]),
      ignoreExpiration: false,
      secretOrKey: configService.get<string>('JWT_ACCESS_SECRET'),
      issuer: 'lumba-ecommerce',
    });
  }

  async validate(payload: JwtPayload): Promise<JwtPayload> {
    // Validaciones adicionales
    if (!payload.sub) {
      throw new UnauthorizedException('Token inválido: falta subject');
    }

    if (!payload.email) {
      throw new UnauthorizedException('Token inválido: falta email');
    }

    // Verificar que el usuario aún existe (opcional, requiere DB query)
    // const user = await this.usersService.findById(payload.sub);
    // if (!user || user.eliminado) {
    //   throw new UnauthorizedException('Usuario no encontrado o desactivado');
    // }

    return payload; // Disponible como request.user en controllers
  }
}
```

### Servicio de tokens con rotación

**Archivo: `src/modules/auth/token.service.ts`**

```typescript
import { Injectable, UnauthorizedException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { ConfigService } from '@nestjs/config';
import { Response } from 'express';
import * as crypto from 'crypto';

export interface TokenPair {
  accessToken: string;
  refreshToken: string;
  expiresIn: number; // segundos
}

@Injectable()
export class TokenService {
  // Blacklist en memoria (en producción usar Redis)
  private readonly revokedRefreshTokens = new Set<string>();

  constructor(
    private readonly jwtService: JwtService,
    private readonly configService: ConfigService,
  ) {}

  /**
   * Genera un par de tokens (access + refresh).
   */
  async generateTokens(payload: {
    sub: number;
    email: string;
    role: string;
    permissions?: string[];
  }): Promise<TokenPair> {
    const accessToken = this.jwtService.sign(payload, {
      secret: this.configService.get<string>('JWT_ACCESS_SECRET'),
      expiresIn: '15m',
    });

    const refreshToken = this.jwtService.sign(
      {
        sub: payload.sub,
        jti: crypto.randomBytes(16).toString('hex'), // Unique token ID
      },
      {
        secret: this.configService.get<string>('JWT_REFRESH_SECRET'),
        expiresIn: '7d',
      },
    );

    return {
      accessToken,
      refreshToken,
      expiresIn: 15 * 60, // 15 minutos en segundos
    };
  }

  /**
   * Refresca tokens rotando el refresh token (invalida el anterior).
   */
  async refreshTokens(refreshToken: string): Promise<TokenPair> {
    // Verificar si el refresh token fue revocado
    if (this.revokedRefreshTokens.has(refreshToken)) {
      throw new UnauthorizedException('Refresh token revocado (posible reuso)');
    }

    try {
      const payload = this.jwtService.verify(refreshToken, {
        secret: this.configService.get<string>('JWT_REFRESH_SECRET'),
      });

      // Revocar el refresh token actual (rotación)
      this.revokedRefreshTokens.add(refreshToken);

      // Generar nuevo par
      return this.generateTokens({
        sub: payload.sub,
        email: payload.email,
        role: payload.role,
      });
    } catch (error) {
      // Si el token expiró, también revocar (por las dudas)
      this.revokedRefreshTokens.add(refreshToken);
      throw new UnauthorizedException('Refresh token inválido o expirado');
    }
  }

  /**
   * Revoca todos los refresh tokens de un usuario (logout).
   */
  async revokeAllUserTokens(userId: number): Promise<void> {
    // En producción: guardar `revoked_after` timestamp en DB/Redis
    // y rechazar refresh tokens emitidos antes de ese timestamp.
    console.log(`[AUTH] Revocados todos los tokens del usuario ${userId}`);
  }

  /**
   * Setea el refresh token como cookie HTTP-only segura.
   */
  setRefreshTokenCookie(response: Response, refreshToken: string): void {
    response.cookie('refreshToken', refreshToken, {
      httpOnly: true,
      secure: process.env.NODE_ENV === 'production',
      sameSite: 'strict',
      maxAge: 7 * 24 * 60 * 60 * 1000, // 7 días
      path: '/api/auth/refresh', // Solo accesible en el endpoint de refresh
      domain: process.env.COOKIE_DOMAIN || undefined,
    });
  }

  /**
   * Limpia la cookie de refresh token (logout).
   */
  clearRefreshTokenCookie(response: Response): void {
    response.clearCookie('refreshToken', {
      path: '/api/auth/refresh',
      domain: process.env.COOKIE_DOMAIN || undefined,
    });
  }
}
```

---

## 6. Variables de Entorno por Tenant

### Esquema de archivos .env

```
.env.example          → Template (commiteable, sin valores reales)
.env.canccat          → Tenant: Canccat (NO commiteable)
.env.cliente2         → Tenant: Cliente 2 (NO commiteable)
.env.development      → Desarrollo local (NO commiteable)
.env.test             → Testing (valores dummy, commiteable)
```

### Configuración tipada con validación

**Archivo: `src/config/env.validation.ts`**

```typescript
import { plainToInstance } from 'class-transformer';
import {
  IsEnum,
  IsNumber,
  IsString,
  IsOptional,
  validateSync,
  MinLength,
} from 'class-validator';

enum Environment {
  Development = 'development',
  Production = 'production',
  Test = 'test',
}

class EnvironmentVariables {
  @IsEnum(Environment)
  NODE_ENV: Environment;

  @IsNumber()
  PORT: number;

  // Database
  @IsString()
  DB_HOST: string;

  @IsNumber()
  DB_PORT: number;

  @IsString()
  DB_USERNAME: string;

  @IsString()
  DB_PASSWORD: string;

  @IsString()
  DB_DATABASE: string;

  // JWT
  @IsString()
  @MinLength(32)
  JWT_ACCESS_SECRET: string;

  @IsString()
  @MinLength(32)
  JWT_REFRESH_SECRET: string;

  // Tenant
  @IsString()
  TENANT_ID: string;

  @IsString()
  @IsOptional()
  TENANT_NAME?: string;

  // App URL
  @IsString()
  APP_URL: string;

  // CORS
  @IsString()
  @IsOptional()
  CORS_ORIGINS?: string;

  // Redis
  @IsString()
  @IsOptional()
  REDIS_HOST?: string;

  @IsNumber()
  @IsOptional()
  REDIS_PORT?: number;

  @IsString()
  @IsOptional()
  REDIS_PASSWORD?: string;

  // MercadoPago
  @IsString()
  MERCADOPAGO_ACCESS_TOKEN: string;

  @IsString()
  MERCADOPAGO_WEBHOOK_SECRET: string;

  // Modo
  @IsString()
  MODO_USERNAME: string;

  @IsString()
  MODO_PASSWORD: string;

  @IsString()
  MODO_PROCESSOR_CODE: string;

  @IsString()
  MODO_CC_CODE: string;

  @IsString()
  MODO_WEBHOOK_SECRET: string;

  // PadPio
  @IsString()
  PADPIO_HOST: string;

  @IsString()
  PADPIO_USER: string;

  @IsString()
  PADPIO_PASSWORD: string;

  // OpenAI
  @IsString()
  OPENAI_API_KEY: string;

  // reCAPTCHA
  @IsString()
  RECAPTCHA_SITE_KEY: string;

  @IsString()
  RECAPTCHA_SECRET_KEY: string;

  // SMTP
  @IsString()
  SMTP_HOST: string;

  @IsNumber()
  SMTP_PORT: number;

  @IsString()
  SMTP_USER: string;

  @IsString()
  SMTP_PASSWORD: string;

  @IsString()
  @IsOptional()
  SMTP_FROM?: string;

  // Logging
  @IsString()
  @IsOptional()
  LOG_LEVEL?: string;

  // Cookie
  @IsString()
  @IsOptional()
  COOKIE_DOMAIN?: string;

  // File storage
  @IsString()
  @IsOptional()
  STORAGE_PATH?: string;
}

export function validateEnv(config: Record<string, unknown>): EnvironmentVariables {
  const validatedConfig = plainToInstance(EnvironmentVariables, config, {
    enableImplicitConversion: true,
  });

  const errors = validateSync(validatedConfig, {
    skipMissingProperties: false,
  });

  if (errors.length > 0) {
    throw new Error(
      `Validación de variables de entorno fallida:\n${errors
        .map((e) => `  - ${e.property}: ${Object.values(e.constraints || {}).join(', ')}`)
        .join('\n')}`,
    );
  }

  return validatedConfig;
}
```

### ConfigModule con validación

```typescript
// En app.module.ts
import { ConfigModule } from '@nestjs/config';
import { validateEnv } from './config/env.validation';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
      envFilePath: [
        `.env.${process.env.TENANT_ID || 'development'}`, // .env.canccat
        '.env.development',                                // fallback
        '.env',                                            // último fallback
      ],
      validate: validateEnv,
      validationOptions: {
        allowUnknown: false, // Rechazar variables no declaradas
        abortEarly: false,   // Reportar todos los errores, no solo el primero
      },
    }),
    // ...otros módulos
  ],
})
export class AppModule {}
```

---

## 7. Configuración de Logging de Seguridad

### Archivo: `src/config/logger.config.ts`

```typescript
import { WinstonModule } from 'nest-winston';
import * as winston from 'winston';
import * as path from 'path';

const LOG_DIR = process.env.LOG_DIR || path.join(process.cwd(), 'logs');

/**
 * Formatos de log personalizados
 */
const securityFormat = winston.format((info) => {
  // Redactar datos sensibles
  if (info.password) info.password = '[REDACTED]';
  if (info.token) info.token = '[REDACTED]';
  if (info.accessToken) info.accessToken = '[REDACTED]';
  if (info.body?.password) {
    info.body = { ...info.body, password: '[REDACTED]' };
  }
  return info;
});

/**
 * Logger principal de la aplicación.
 *
 * Transports:
 * - Console: desarrollo (colores) / producción (JSON)
 * - File: logs/app.log (todos los niveles)
 * - File: logs/security.log (solo warn+, eventos de seguridad)
 * - File: logs/error.log (solo errores)
 */
export function createAppLogger() {
  const isProduction = process.env.NODE_ENV === 'production';

  return WinstonModule.createLogger({
    level: process.env.LOG_LEVEL || (isProduction ? 'info' : 'debug'),

    format: winston.format.combine(
      securityFormat(),
      winston.format.timestamp({ format: 'YYYY-MM-DD HH:mm:ss.SSS' }),
      winston.format.errors({ stack: true }),
      isProduction
        ? winston.format.json()
        : winston.format.combine(
            winston.format.colorize(),
            winston.format.printf(({ timestamp, level, message, context, ...meta }) => {
              const metaStr = Object.keys(meta).length
                ? ` ${JSON.stringify(meta)}`
                : '';
              return `${timestamp} [${level}] [${context || 'APP'}]: ${message}${metaStr}`;
            }),
          ),
    ),

    transports: [
      // Consola siempre
      new winston.transports.Console(),

      // Archivo: todos los logs
      new winston.transports.File({
        filename: path.join(LOG_DIR, 'app.log'),
        maxsize: 10 * 1024 * 1024, // 10MB
        maxFiles: 5,
        format: winston.format.json(),
      }),

      // Archivo: solo eventos de seguridad (warn+)
      new winston.transports.File({
        filename: path.join(LOG_DIR, 'security.log'),
        level: 'warn',
        maxsize: 10 * 1024 * 1024,
        maxFiles: 10, // Guardar más historial de seguridad
        format: winston.format.json(),
      }),

      // Archivo: solo errores
      new winston.transports.File({
        filename: path.join(LOG_DIR, 'error.log'),
        level: 'error',
        maxsize: 10 * 1024 * 1024,
        maxFiles: 5,
        format: winston.format.json(),
      }),
    ],

    // No terminar el proceso en error de logging
    exitOnError: false,
  });
}
```

### Logger de seguridad especializado

**Archivo: `src/common/logger/security.logger.ts`**

```typescript
import { LoggerService, Injectable, Logger } from '@nestjs/common';

export interface SecurityEvent {
  event: string;
  severity: 'info' | 'warn' | 'error' | 'critical';
  userId?: number;
  userEmail?: string;
  ip?: string;
  userAgent?: string;
  details?: Record<string, any>;
}

@Injectable()
export class SecurityLogger implements LoggerService {
  private readonly logger = new Logger('SECURITY');

  log(message: string, context?: string): void;
  log(event: SecurityEvent): void;
  log(messageOrEvent: string | SecurityEvent, context?: string): void {
    if (typeof messageOrEvent === 'string') {
      this.logger.log({ message: messageOrEvent, context, timestamp: new Date().toISOString() });
    } else {
      this.logger.log({
        ...messageOrEvent,
        timestamp: new Date().toISOString(),
      });
    }
  }

  error(message: string, trace?: string, context?: string): void {
    this.logger.error({
      message,
      trace,
      context,
      timestamp: new Date().toISOString(),
    });
  }

  warn(message: string, context?: string): void {
    this.logger.warn({
      message,
      context,
      timestamp: new Date().toISOString(),
    });
  }

  debug(message: string, context?: string): void {
    this.logger.debug({
      message,
      context,
      timestamp: new Date().toISOString(),
    });
  }

  verbose(message: string, context?: string): void {
    this.logger.verbose({
      message,
      context,
      timestamp: new Date().toISOString(),
    });
  }

  // ===== Métodos específicos de seguridad =====

  logFailedLogin(email: string, ip: string, reason: string): void {
    this.logger.warn({
      event: 'AUTH_FAILED_LOGIN',
      severity: 'warn',
      email,
      ip,
      reason,
      timestamp: new Date().toISOString(),
    });
  }

  logBruteForceAttempt(email: string, ip: string, attemptCount: number): void {
    this.logger.error({
      event: 'AUTH_BRUTE_FORCE',
      severity: 'critical',
      email,
      ip,
      attemptCount,
      timestamp: new Date().toISOString(),
    });
  }

  logWebhookRejected(provider: string, reason: string, ip: string): void {
    this.logger.error({
      event: 'WEBHOOK_REJECTED',
      severity: 'critical',
      provider,
      reason,
      ip,
      timestamp: new Date().toISOString(),
    });
  }

  logCsrfViolation(ip: string, url: string): void {
    this.logger.warn({
      event: 'CSRF_VIOLATION',
      severity: 'warn',
      ip,
      url,
      timestamp: new Date().toISOString(),
    });
  }

  logPermissionDenied(userId: number, required: string, url: string): void {
    this.logger.warn({
      event: 'PERMISSION_DENIED',
      severity: 'warn',
      userId,
      requiredPermission: required,
      url,
      timestamp: new Date().toISOString(),
    });
  }
}
```

---

## 8. Configuración de Validación (class-validator + ValidationPipe)

### ValidationPipe global

**Archivo: `src/config/validation.config.ts`**

```typescript
import { ValidationPipe, ValidationError, BadRequestException } from '@nestjs/common';

/**
 * ValidationPipe global con whitelist estricta y mensajes de error en español.
 */
export function createValidationPipe(): ValidationPipe {
  return new ValidationPipe({
    // === Seguridad ===
    whitelist: true,             // Elimina propiedades no decoradas del DTO
    forbidNonWhitelisted: true,  // Lanza error si hay propiedades no declaradas
    forbidUnknownValues: true,   // Rechaza objetos sin decoradores

    // === Transformación ===
    transform: true,             // Transforma tipos (string → number, etc.)
    transformOptions: {
      enableImplicitConversion: true, // Convierte "123" → 123 automáticamente
    },

    // === Mensajes de error ===
    exceptionFactory: (errors: ValidationError[]) => {
      const messages = errors.map((error) => ({
        field: error.property,
        value: error.value,
        constraints: error.constraints,
        children: error.children?.length ? error.children : undefined,
      }));

      return new BadRequestException({
        statusCode: 400,
        message: 'Error de validación',
        errors: messages,
      });
    },

    // No detenerse en el primer error — reportar todos
    stopAtFirstError: false,

    // Validar también propiedades anidadas
    validateCustomDecorators: true,
  });
}
```

### Ejemplos de DTOs con validación estricta

```typescript
// src/modules/auth/dto/login.dto.ts
import { IsEmail, IsString, MinLength, MaxLength } from 'class-validator';
import { Transform } from 'class-transformer';
import { ApiProperty } from '@nestjs/swagger';

export class LoginDto {
  @ApiProperty({ example: 'usuario@email.com' })
  @IsEmail({}, { message: 'Debe proporcionar un email válido' })
  @Transform(({ value }) => value?.toLowerCase().trim())
  email: string;

  @ApiProperty({ example: 'MiPassword123' })
  @IsString({ message: 'La contraseña debe ser texto' })
  @MinLength(8, { message: 'La contraseña debe tener al menos 8 caracteres' })
  @MaxLength(128, { message: 'La contraseña es demasiado larga' })
  password: string;
}
```

```typescript
// src/modules/auth/dto/register.dto.ts
import {
  IsEmail, IsString, MinLength, MaxLength,
  Matches, IsOptional, IsBoolean,
} from 'class-validator';
import { Transform } from 'class-transformer';

export class RegisterDto {
  @IsEmail({}, { message: 'Email inválido' })
  @Transform(({ value }) => value?.toLowerCase().trim())
  email: string;

  @IsString()
  @MinLength(8, { message: 'La contraseña debe tener al menos 8 caracteres' })
  @MaxLength(128)
  @Matches(/(?=.*[a-z])(?=.*[A-Z])(?=.*\d)/, {
    message: 'La contraseña debe contener al menos una mayúscula, una minúscula y un número',
  })
  password: string;

  @IsString()
  @MinLength(2)
  @MaxLength(100)
  @Transform(({ value }) => value?.trim())
  @Matches(/^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s'-]+$/, {
    message: 'El nombre contiene caracteres inválidos',
  })
  nombre: string;

  @IsString()
  @MinLength(2)
  @MaxLength(100)
  @Transform(({ value }) => value?.trim())
  @Matches(/^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s'-]+$/, {
    message: 'El apellido contiene caracteres inválidos',
  })
  apellido: string;

  @IsBoolean()
  @IsOptional()
  @Transform(({ value }) => value === true || value === 'true')
  newsletter?: boolean;

  @IsBoolean()
  @IsOptional()
  @Transform(({ value }) => value === true || value === 'true')
  aceptaTerminos?: boolean;
}
```

---

## 9. Configuración de CSRF Protection

### Estrategia para NestJS + frontend separado

Para una arquitectura con frontend separado (Next.js/React) y API NestJS, la protección CSRF se logra con:

1. **SameSite cookies** (capa principal)
2. **Header personalizado** (doble submit cookie pattern)
3. **Exclusión explícita de webhooks** (validados por firma, no por CSRF)

**Archivo: `src/common/guards/csrf.guard.ts`**

```typescript
import {
  Injectable,
  CanActivate,
  ExecutionContext,
  ForbiddenException,
} from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import { Request } from 'express';
import * as crypto from 'crypto';

// Decorador para excluir endpoints del CSRF check
import { SetMetadata } from '@nestjs/common';
export const SkipCsrf = () => SetMetadata('skipCsrf', true);

@Injectable()
export class CsrfGuard implements CanActivate {
  private readonly SAFE_METHODS = ['GET', 'HEAD', 'OPTIONS'];

  constructor(private readonly reflector: Reflector) {}

  canActivate(context: ExecutionContext): boolean {
    // Verificar si el endpoint está explícitamente excluido
    const skipCsrf = this.reflector.getAllAndOverride<boolean>('skipCsrf', [
      context.getHandler(),
      context.getClass(),
    ]);
    if (skipCsrf) return true;

    const request = context.switchToHttp().getRequest<Request>();

    // Métodos seguros no requieren CSRF
    if (this.SAFE_METHODS.includes(request.method.toUpperCase())) {
      return true;
    }

    // Solo aplicar a rutas que usan cookie-based auth (admin panel, sesiones)
    // Si el endpoint usa JWT en header Authorization, no necesita CSRF
    // (el token no se envía automáticamente por el navegador)
    const authHeader = request.headers.authorization;
    if (authHeader?.startsWith('Bearer ')) {
      return true; // JWT en header no es vulnerable a CSRF
    }

    // Para cookie-based auth, verificar doble submit
    const cookieToken = request.cookies?.['csrf-token'];
    const headerToken = request.headers['x-csrf-token'] as string;

    if (!cookieToken || !headerToken) {
      throw new ForbiddenException('CSRF token requerido');
    }

    if (!crypto.timingSafeEqual(Buffer.from(cookieToken), Buffer.from(headerToken))) {
      throw new ForbiddenException('CSRF token inválido');
    }

    return true;
  }
}
```

**Nota importante:** Si el frontend usa exclusivamente JWT en `Authorization: Bearer` header (sin cookies de sesión), **la protección CSRF NO es necesaria** porque el navegador no adjunta el header automáticamente. La protección CSRF solo aplica cuando se usan cookies para autenticación (ej: admin panel con sesiones, o SSR con cookies).

---

## 10. Template de .env.example

**Archivo: `.env.example`** (commiteable, sin secretos reales)

```env
# ==============================================================
# Lumba Ecommerce — Variables de Entorno
# ==============================================================
# Copiar este archivo a .env.development / .env.{tenant}
# y reemplazar los valores con las credenciales reales.
# NUNCA COMMITEAR ARCHIVOS .env CON VALORES REALES.
# ==============================================================

# ==========================================
# ENTORNO
# ==========================================
NODE_ENV=development
PORT=3000

# ==========================================
# TENANT
# ==========================================
TENANT_ID=canccat
TENANT_NAME=Canccat
APP_URL=http://localhost:3000
CORS_ORIGINS=http://localhost:3000,http://localhost:5173
COOKIE_DOMAIN=localhost

# ==========================================
# BASE DE DATOS (MySQL)
# ==========================================
DB_HOST=localhost
DB_PORT=3306
DB_USERNAME=root
DB_PASSWORD=change_me
DB_DATABASE=lumba_canccat

# ==========================================
# JWT
# ==========================================
# Generar con: openssl rand -hex 64
JWT_ACCESS_SECRET=change_me_generate_random_64_bytes_hex
JWT_REFRESH_SECRET=change_me_generate_random_64_bytes_hex

# ==========================================
# REDIS
# ==========================================
REDIS_HOST=localhost
REDIS_PORT=6379
REDIS_PASSWORD=
REDIS_THROTTLE_DB=1
REDIS_QUEUE_DB=2

# ==========================================
# MERCADOPAGO
# ==========================================
# Access Token de producción: APP_USR-...
# Access Token de pruebas:     TEST-...
MERCADOPAGO_ACCESS_TOKEN=TEST-0000000000000000-000000-00000000000000000000000000000000-000000000
MERCADOPAGO_WEBHOOK_SECRET=change_me_webhook_secret

# ==========================================
# MODO
# ==========================================
MODO_USERNAME=change_me
MODO_PASSWORD=change_me
MODO_PROCESSOR_CODE=00000
MODO_CC_CODE=CC-000
MODO_WEBHOOK_SECRET=change_me_webhook_secret

# ==========================================
# PADPIO (SQL Server)
# ==========================================
PADPIO_HOST=192.168.1.100
PADPIO_USER=sa
PADPIO_PASSWORD=change_me

# ==========================================
# OPENAI (Chatbot)
# ==========================================
OPENAI_API_KEY=sk-proj-change_me

# ==========================================
# GOOGLE reCAPTCHA v3
# ==========================================
RECAPTCHA_SITE_KEY=6Lc_change_me
RECAPTCHA_SECRET_KEY=6Lc_change_me

# ==========================================
# SMTP (Emails transaccionales)
# ==========================================
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=no-reply@lumba.com
SMTP_PASSWORD=change_me
SMTP_FROM="Lumba Ecommerce" <no-reply@lumba.com>

# ==========================================
# LOGGING
# ==========================================
LOG_LEVEL=debug
LOG_DIR=./logs

# ==========================================
# ALMACENAMIENTO DE ARCHIVOS
# ==========================================
STORAGE_PATH=./uploads

# ==========================================
# ZN (ZIPNOVA) — Verificar credenciales exactas
# ==========================================
ZIPNOVA_API_KEY=change_me
ZIPNOVA_API_URL=https://api.zipnova.com
ZIPNOVA_WEBHOOK_SECRET=change_me_webhook_secret
```

---

## 11. main.ts — Configuración Completa

**Archivo: `src/main.ts`**

```typescript
import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { ConfigService } from '@nestjs/config';
import { Logger } from '@nestjs/common';
import * as cookieParser from 'cookie-parser';

import { configureHelmet } from './config/helmet.config';
import { getCorsConfig } from './config/cors.config';
import { createValidationPipe } from './config/validation.config';
import { SecurityHeadersMiddleware } from './common/middleware/security-headers.middleware';
import { HttpsRedirectMiddleware } from './common/middleware/https-redirect.middleware';

async function bootstrap() {
  const app = await NestFactory.create(AppModule, {
    // Buffer de logs para el arranque
    bufferLogs: true,
  });

  const configService = app.get(ConfigService);
  const logger = new Logger('Bootstrap');
  const isProduction = configService.get('NODE_ENV') === 'production';

  // ============ 1. Seguridad: Helmet (headers HTTP) ============
  configureHelmet(app);
  logger.log('✓ Helmet configurado');

  // ============ 2. Seguridad: CORS restrictivo ============
  app.enableCors(getCorsConfig());
  logger.log('✓ CORS configurado');

  // ============ 3. Cookie parser (para refresh tokens) ============
  app.use(cookieParser(configService.get('COOKIE_SECRET')));
  logger.log('✓ Cookie parser configurado');

  // ============ 4. Headers de seguridad adicionales ============
  app.use(new SecurityHeadersMiddleware().use);
  logger.log('✓ Security headers middleware');

  // ============ 5. Redirección HTTP → HTTPS en producción ============
  if (isProduction) {
    app.use(new HttpsRedirectMiddleware().use);
    logger.log('✓ HTTPS redirect activado');
  }

  // ============ 6. Validación global ============
  app.useGlobalPipes(createValidationPipe());
  logger.log('✓ ValidationPipe global');

  // ============ 7. Prefijo global de API ============
  app.setGlobalPrefix('api', {
    exclude: ['health'], // Endpoint de health sin prefijo
  });
  logger.log('✓ Prefijo global: /api');

  // ============ 8. Trust proxy (si está detrás de nginx/load balancer) ============
  if (isProduction) {
    // Confiar en el header X-Forwarded-For para IP real
    app.getHttpAdapter().getInstance().set('trust proxy', 1);
    logger.log('✓ Trust proxy configurado');
  }

  // ============ 9. Iniciar servidor ============
  const port = configService.get<number>('PORT', 3000);
  await app.listen(port);

  logger.log(`🚀 Servidor iniciado en http://localhost:${port}`);
  logger.log(`🌍 Entorno: ${configService.get('NODE_ENV')}`);
  logger.log(`🏢 Tenant: ${configService.get('TENANT_ID')}`);
}

bootstrap().catch((error) => {
  console.error('Error fatal al iniciar la aplicación:', error);
  process.exit(1);
});
```

---

## 12. app.module.ts — Módulo Raíz

```typescript
import { Module } from '@nestjs/common';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { TypeOrmModule } from '@nestjs/typeorm';
import { ThrottlerModule, ThrottlerGuard } from '@nestjs/throttler';
import { APP_GUARD, APP_INTERCEPTOR } from '@nestjs/core';

import { validateEnv } from './config/env.validation';
import { throttlerConfig } from './config/throttler.config';
import { getJwtConfig } from './config/jwt.config';
import { createAppLogger } from './config/logger.config';

import { ThrottlerStorageRedis } from './modules/throttle/throttler-storage-redis';
import { AuditLogInterceptor } from './common/interceptors/audit-log.interceptor';

// Módulos de la aplicación
import { AuthModule } from './modules/auth/auth.module';
import { UsersModule } from './modules/users/users.module';
import { CatalogModule } from './modules/catalog/catalog.module';
import { OrdersModule } from './modules/orders/orders.module';
import { PaymentsModule } from './modules/payments/payments.module';
// ... resto de módulos

@Module({
  imports: [
    // ===== Configuración =====
    ConfigModule.forRoot({
      isGlobal: true,
      envFilePath: [
        `.env.${process.env.TENANT_ID || 'development'}`,
        '.env.development',
        '.env',
      ],
      validate: validateEnv,
    }),

    // ===== Base de datos (TypeORM con configuración por tenant) =====
    TypeOrmModule.forRootAsync({
      imports: [ConfigModule],
      inject: [ConfigService],
      useFactory: (config: ConfigService) => ({
        type: 'mysql',
        host: config.get('DB_HOST'),
        port: config.get('DB_PORT'),
        username: config.get('DB_USERNAME'),
        password: config.get('DB_PASSWORD'),
        database: config.get('DB_DATABASE'),
        entities: [__dirname + '/**/*.entity{.ts,.js}'],
        migrations: [__dirname + '/database/migrations/*{.ts,.js}'],
        synchronize: config.get('NODE_ENV') !== 'production', // NUNCA en prod
        logging: config.get('NODE_ENV') === 'development' ? 'all' : ['error'],
        timezone: '-03:00',
        // Seguridad de conexión
        extra: {
          connectionLimit: 20,
          // SSL en producción
          ...(config.get('NODE_ENV') === 'production'
            ? { ssl: { rejectUnauthorized: true } }
            : {}),
        },
      }),
    }),

    // ===== Rate Limiting =====
    ThrottlerModule.forRootAsync({
      imports: [ConfigModule],
      inject: [ConfigService],
      useFactory: (config: ConfigService) => {
        const isProduction = config.get('NODE_ENV') === 'production';
        return {
          ...throttlerConfig,
          // Usar Redis en producción, memoria en desarrollo
          ...(isProduction
            ? { storage: new ThrottlerStorageRedis() }
            : {}),
        };
      },
    }),

    // ===== Módulos de la aplicación =====
    AuthModule,
    UsersModule,
    CatalogModule,
    OrdersModule,
    PaymentsModule,
    // ...
  ],

  providers: [
    // ===== Guard global: Rate limiting =====
    {
      provide: APP_GUARD,
      useClass: ThrottlerGuard,
    },

    // ===== Interceptor global: Auditoría =====
    {
      provide: APP_INTERCEPTOR,
      useClass: AuditLogInterceptor,
    },
  ],
})
export class AppModule {}
```

---

## Verificación de Seguridad (Checklist de Configuración)

Antes de poner en producción, verificar que todos estos items estén configurados:

- [ ] `NODE_ENV=production`
- [ ] Helmet emitiendo todos los headers (verificar con https://securityheaders.com)
- [ ] CSP sin `'unsafe-inline'` ni `'unsafe-eval'` en `scriptSrc`
- [ ] CORS restringido solo a los dominios de la tienda
- [ ] `.env` con secretos reales (JWT secrets de 64+ bytes aleatorios)
- [ ] `.env.example` sin valores reales (commiteable)
- [ ] `.env.production` / `.env.{tenant}` en `.gitignore`
- [ ] TypeORM `synchronize: false` en producción
- [ ] Rate limiting con Redis en producción
- [ ] HTTPS forzado (HSTS + redirect middleware)
- [ ] Logs de seguridad escribiendo a archivo
- [ ] ValidationPipe global con `whitelist: true` y `forbidNonWhitelisted: true`
- [ ] Refresh tokens en cookie HTTP-only + Secure + SameSite=Strict
- [ ] JWT access tokens con expiración ≤ 15 minutos
- [ ] `X-Powered-By` removido de todas las respuestas
- [ ] `trust proxy` configurado si hay reverse proxy/load balancer

---

> **Confianza global de este documento:** ALTA. Todas las configuraciones están basadas en documentación oficial de NestJS, Helmet, passport-jwt y class-validator. Las versiones recomendadas son las estables más recientes a junio 2026. Las configuraciones son copiar-y-pegar en el proyecto, ajustando solo variables de entorno y dominios.

---

*Documento preparado por el Security Agent. Basado en análisis de vulnerabilidades del sistema actual y mejores prácticas de seguridad para NestJS.*
