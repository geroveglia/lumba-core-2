#!/usr/bin/env bash
# ============================================================
# LUMBA CORE — macOS/Linux Setup
# Ejecutar desde la raíz del repo
# ============================================================
set -e

echo ""
echo "⚡ LUMBA CORE — Setup"
echo "========================"
echo ""

# 1. Check Node.js
if ! command -v node &> /dev/null; then
    echo "[ERROR] Node.js no encontrado. Instálalo de https://nodejs.org (>=18)"
    exit 1
fi
echo "[OK] Node.js $(node -v) detectado"

# 2. Install/Update OpenClaw
echo "[INSTALL] Instalando OpenClaw..."
npm install -g openclaw
echo "[OK] OpenClaw instalado"

# 3. Set workspace path
LUMBA_WORKSPACE="$(cd "$(dirname "$0")" && pwd)"
echo "[CONFIG] Workspace: $LUMBA_WORKSPACE"

# 4. Check for existing openclaw.json
if [ -f "$HOME/.openclaw/openclaw.json" ]; then
    echo "[SKIP] openclaw.json ya existe. No lo sobreescribo para proteger tus credenciales."
    echo "       Si querés usar la config de Lumba Core, renombralo y corre setup de nuevo."
else
    echo "[INFO] No se encontró openclaw.json. Creando uno mínimo..."
    mkdir -p "$HOME/.openclaw"
    cat > "$HOME/.openclaw/openclaw.json" << EOF
{
  "agents": { "defaults": { "workspace": "$LUMBA_WORKSPACE" } }
}
EOF
    echo "[OK] openclaw.json creado"
fi

# 5. Start Gateway
echo ""
echo "[START] Arrancando el Gateway..."
echo "        Abrí http://localhost:18789 en tu navegador"
echo ""
openclaw gateway start

echo ""
echo "=========================="
echo " LUMBA CORE listo. ⚡"
echo "=========================="
