#!/usr/bin/env bash
set -e

echo "=== 1. Checking Flutter SDK ==="
if ! command -v flutter &> /dev/null; then
  echo "Flutter not found in PATH. Setting up Flutter SDK..."
  if [ ! -d "$HOME/flutter" ]; then
    git clone https://github.com/flutter/flutter.git --depth 1 -b stable "$HOME/flutter"
  fi
  export PATH="$PATH:$HOME/flutter/bin"
fi

echo "=== 2. Flutter Environment ==="
flutter --version

echo "=== 3. Resolving Dependencies ==="
flutter pub get

echo "=== 4. Compiling Flutter Web Production Release ==="
flutter build web --release

echo "=== 5. Build Complete: Ready in build/web ==="
