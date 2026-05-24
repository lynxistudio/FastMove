#!/bin/bash
set -e

# FastMove - Build Script
# Requires: Xcode Command Line Tools
# Target: macOS 14.0, Apple Silicon

PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
BUILD_DIR="$PROJECT_DIR/build"
APP_NAME="FastMove"
BUNDLE_DIR="$BUILD_DIR/$APP_NAME.app"

echo "=== FastMove Build ==="
echo "Project: $PROJECT_DIR"
echo "Build dir: $BUILD_DIR"

# Clean previous build
rm -rf "$BUILD_DIR"
mkdir -p "$BUNDLE_DIR/Contents/MacOS"
mkdir -p "$BUNDLE_DIR/Contents/Resources"

# Collect Swift source files (array to handle paths with spaces, compatible with bash 3.x)
SWIFT_FILES=()
while IFS= read -r -d '' file; do
    SWIFT_FILES+=("$file")
done < <(find "$PROJECT_DIR/$APP_NAME" -name "*.swift" -type f -print0 | sort -z)

if [ ${#SWIFT_FILES[@]} -eq 0 ]; then
    echo "ERROR: No Swift source files found."
    exit 1
fi

echo "Compiling $APP_NAME..."

SDK_PATH=$(xcrun --show-sdk-path --sdk macosx)
swiftc \
    -sdk "$SDK_PATH" \
    -target arm64-apple-macos14.0 \
    -O \
    -framework SwiftUI \
    -framework AppKit \
    -framework Combine \
    -framework UniformTypeIdentifiers \
    -o "$BUNDLE_DIR/Contents/MacOS/$APP_NAME" \
    "${SWIFT_FILES[@]}"

# Create Info.plist
cat > "$BUNDLE_DIR/Contents/Info.plist" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDevelopmentRegion</key>
    <string>en</string>
    <key>CFBundleExecutable</key>
    <string>$APP_NAME</string>
    <key>CFBundleIdentifier</key>
    <string>com.fastmove.app</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>$APP_NAME</string>
    <key>CFBundleDisplayName</key>
    <string>$APP_NAME</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>LSMinimumSystemVersion</key>
    <string>14.0</string>
    <key>CFBundleIconFile</key>
    <string>AppIcon</string>
</dict>
</plist>
EOF

# Copy icon if available
if [ -f "$PROJECT_DIR/AppIcon.icns" ]; then
    cp "$PROJECT_DIR/AppIcon.icns" "$BUNDLE_DIR/Contents/Resources/AppIcon.icns"
fi

# Create PkgInfo
echo -n "APPL????" > "$BUNDLE_DIR/Contents/PkgInfo"

# Ad-hoc code sign
codesign --force --deep --sign - "$BUNDLE_DIR"

echo ""
echo "=== Build Complete ==="
echo "App: $BUNDLE_DIR"
echo "Run: open $BUNDLE_DIR"