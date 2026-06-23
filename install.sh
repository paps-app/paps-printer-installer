#!/bin/bash
set -e

APP_NAME="Paps Printer"
APP_BUNDLE="${APP_NAME}.app"
INSTALL_DIR="/Applications"
INSTALLED="${INSTALL_DIR}/${APP_BUNDLE}"
URL="${1:-}"
TMP_DMG="/tmp/paps-printer-install.dmg"
VOLUME="/Volumes/${APP_NAME}"

echo ""
echo "🖨️  Installation de ${APP_NAME}"
echo "────────────────────────────────────────────────"

if [ -n "$URL" ]; then
  echo "   Téléchargement depuis :"
  echo "   $URL"
  curl -fL# "$URL" -o "$TMP_DMG"
  xattr -d com.apple.quarantine "$TMP_DMG" 2>/dev/null || true
  echo "   Montage du DMG..."
  hdiutil attach "$TMP_DMG" -nobrowse -quiet
  APP_PATH="${VOLUME}/${APP_BUNDLE}"
else
  APP_PATH=$(find . -maxdepth 4 -name "$APP_BUNDLE" \
    -not -path "*/node_modules/*" 2>/dev/null | head -1)
  if [ -z "$APP_PATH" ]; then
    echo "❌  Impossible de trouver ${APP_BUNDLE}."
    exit 1
  fi
  echo "   Trouvé : $APP_PATH"
fi

if [ -d "$INSTALLED" ]; then
  echo "   Remplacement de la version existante..."
  rm -rf "$INSTALLED"
fi

echo "   Copie vers ${INSTALL_DIR}..."
ditto "$APP_PATH" "$INSTALLED"          # ← préserve la signature

echo "   Suppression quarantine..."
xattr -d com.apple.quarantine "$INSTALLED" 2>/dev/null || true

if [ -n "$URL" ]; then
  hdiutil detach "$VOLUME" -quiet 2>/dev/null || true
  rm -f "$TMP_DMG"
fi

echo ""
echo "✅  ${APP_NAME} installé dans ${INSTALL_DIR}"
echo "    Lancez-le depuis le Launchpad ou Spotlight."
echo ""
