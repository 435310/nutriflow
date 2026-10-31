#!/bin/bash
set -e

echo "Instalando Flutter..."
FLUTTER_SDK_PATH="$HOME/flutter"
if [ ! -d "$FLUTTER_SDK_PATH" ]; then
  git clone --branch stable https://github.com/flutter/flutter.git $FLUTTER_SDK_PATH
fi

export PATH="$FLUTTER_SDK_PATH/bin:$PATH"

echo "Configurando Flutter Web..."
flutter config --enable-web

echo "Baixando dependências..."
flutter pub get

echo "Compilando o app..."
flutter build web --release