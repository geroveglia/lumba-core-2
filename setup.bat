@echo off
:: ============================================================
:: LUMBA CORE — Windows Setup
:: Ejecutar desde la raiz del repo como admin (o con permisos)
:: ============================================================
echo.
echo ⚡ LUMBA CORE — Setup para Windows
echo ======================================
echo.

:: 1. Check Node.js
where node >nul 2>nul
if %errorlevel% neq 0 (
    echo [ERROR] Node.js no encontrado. Instalalo de https://nodejs.org (>=18)
    exit /b 1
)
echo [OK] Node.js %node_version% detectado

:: 2. Install/Update OpenClaw
echo [INSTALL] Instalando OpenClaw...
call npm install -g openclaw
if %errorlevel% neq 0 (
    echo [ERROR] No se pudo instalar OpenClaw
    exit /b 1
)
echo [OK] OpenClaw instalado

:: 3. Set workspace path
set LUMBA_WORKSPACE=%~dp0
echo [CONFIG] Workspace: %LUMBA_WORKSPACE%

:: 4. Check for existing openclaw.json
if exist "%USERPROFILE%\.openclaw\openclaw.json" (
    echo [SKIP] openclaw.json ya existe. No lo sobreescribo para proteger tus credenciales.
    echo        Si queres usar la config de Lumba Core, renombralo y corre setup de nuevo.
) else (
    echo [INFO] No se encontro openclaw.json. Creando uno minimo...
    echo { > "%USERPROFILE%\.openclaw\openclaw.json"
    echo   "agents": { "defaults": { "workspace": "%LUMBA_WORKSPACE:\=\\%" } } >> "%USERPROFILE%\.openclaw\openclaw.json"
    echo } >> "%USERPROFILE%\.openclaw\openclaw.json"
    echo [OK] openclaw.json creado
)

:: 5. Start Gateway
echo.
echo [START] Arrancando el Gateway...
echo         Abri http://localhost:18789 en tu navegador
echo.
start openclaw gateway start
echo [OK] Gateway corriendo

echo.
echo ======================================
echo  LUMBA CORE listo. ⚡
echo  Proximo paso: openclaw gateway start
echo ======================================
pause
