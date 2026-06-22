#!/bin/bash
# ============================================================
#  Paps Printer — installateur macOS
#
#  Mode 1 — téléchargement automatique :
#    bash install.sh https://example.com/Paps-Printer-arm64.dmg
#
#  Mode 2 — depuis un DMG déjà monté / dossier local :
#    bash install.sh
# ============================================================
set -e

APP_NAME="Paps Printer"
APP_BUNDLE="${APP_NAME}.app"
INSTALL_DIR="/Applications"
INSTALLED="${INSTALL_DIR}/${APP_BUNDLE}"
URL="${1:-}"                  # URL optionnelle passée en argument
TMP_DMG="/tmp/paps-printer-install.dmg"
VOLUME="/Volumes/${APP_NAME}"

echo ""
echo "🖨️  Installation de ${APP_NAME}"
echo "────────────────────────────────────────────────"

# ── Mode téléchargement ────────────────────────────────────
if [ -n "$URL" ]; then
  echo "   Téléchargement depuis :"
  echo "   $URL"
  curl -fL# "$URL" -o "$TMP_DMG"
  echo "   Suppression de l'attribut quarantine (DMG)..."
  xattr -cr "$TMP_DMG"
  echo "   Montage du DMG..."
  hdiutil attach "$TMP_DMG" -nobrowse -quiet
  APP_PATH="${VOLUME}/${APP_BUNDLE}"
else
  # ── Mode local — cherche le .app dans le répertoire courant ──
  APP_PATH=$(find . -maxdepth 4 -name "$APP_BUNDLE" \
    -not -path "*/node_modules/*" 2>/dev/null | head -1)
  if [ -z "$APP_PATH" ]; then
    echo ""
    echo "❌  Impossible de trouver ${APP_BUNDLE}."
    echo "    Passez l'URL du DMG en argument :"
    echo "    bash install.sh https://..."
    exit 1
  fi
  echo "   Trouvé : $APP_PATH"
fi

# ── Suppression quarantine sur le .app ────────────────────
echo "   Suppression de l'attribut quarantine (app)..."
xattr -cr "$APP_PATH"

# ── Installation dans /Applications ──────────────────────
if [ -d "$INSTALLED" ]; then
  echo "   Remplacement de la version existante..."
  rm -rf "$INSTALLED"
fi
echo "   Copie vers ${INSTALL_DIR}..."
cp -R "$APP_PATH" "$INSTALL_DIR"
xattr -cr "$INSTALLED"

# ── Nettoyage DMG ─────────────────────────────────────────
if [ -n "$URL" ]; then
  hdiutil detach "$VOLUME" -quiet 2>/dev/null || true
  rm -f "$TMP_DMG"
fi

echo ""
echo "✅  ${APP_NAME} installé dans ${INSTALL_DIR}"
echo "    Lancez-le depuis le Launchpad ou Spotlight."
echo ""
