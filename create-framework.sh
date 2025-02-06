#!/bin/bash

set -e  # エラーが発生したら即終了

FRAMEWORK_NAME="webrtc_audio_processing"
OUTPUT_DIR="build_frameworks"
INSTALL_DIR_MAC="install/mac"
INSTALL_DIR_IOS="install/ios"
INSTALL_DIR_SIMULATOR="install/simulator"

# リネーム処理関数
rename_library() {
    local INSTALL_PATH=$1
    local ORIGINAL_LIB="${INSTALL_PATH}/lib/libwebrtc-audio-processing-1.a"
    local RENAMED_LIB="${INSTALL_PATH}/lib/webrtc-audio-processing"

    if [ -f "${ORIGINAL_LIB}" ]; then
        echo "🔄 Renaming ${ORIGINAL_LIB} to ${RENAMED_LIB}..."
        mv "${ORIGINAL_LIB}" "${RENAMED_LIB}"
    else
        echo "⚠️ Warning: ${ORIGINAL_LIB} not found! Skipping renaming."
    fi
}

# `.framework` を作成する関数
create_framework() {
    local PLATFORM=$1
    local INSTALL_PATH=$2
    local FRAMEWORK_PATH="${OUTPUT_DIR}/${PLATFORM}/${FRAMEWORK_NAME}.framework"
    local LIB_PATH="${INSTALL_PATH}/lib/webrtc-audio-processing"  # リネーム後のパス
    local HEADERS_PATH="${INSTALL_PATH}/include"

    echo "🔨 Creating ${FRAMEWORK_PATH}..."

    # `.framework` のディレクトリ構造を作成
    mkdir -p "${FRAMEWORK_PATH}/Headers"
    mkdir -p "${FRAMEWORK_PATH}/Modules"

    # 静的ライブラリを `.framework` にコピー（.a 拡張子なし）
    cp "${LIB_PATH}" "${FRAMEWORK_PATH}/${FRAMEWORK_NAME}"

    # ヘッダーファイルを再帰的にコピー
    cp -R "${HEADERS_PATH}/" "${FRAMEWORK_PATH}/Headers/"

    # Info.plist を生成
    cat > "${FRAMEWORK_PATH}/Info.plist" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>${FRAMEWORK_NAME}</string>
    <key>CFBundleIdentifier</key>
    <string>com.example.${FRAMEWORK_NAME}</string>
    <key>CFBundleName</key>
    <string>${FRAMEWORK_NAME}</string>
    <key>CFBundleVersion</key>
    <string>1.3.0</string>
    <key>CFBundleShortVersionString</key>
    <string>1.3.0</string>
</dict>
</plist>
EOF

    # Swift対応用の module.modulemap を作成
    cat > "${FRAMEWORK_PATH}/Modules/module.modulemap" <<EOF
framework module ${FRAMEWORK_NAME} {
    umbrella header "${FRAMEWORK_NAME}.h"
    export *
    module * { export * }
}
EOF

    echo "✅ ${FRAMEWORK_PATH} created."
}

# ライブラリのリネーム
rename_library "${INSTALL_DIR_MAC}"
rename_library "${INSTALL_DIR_IOS}"
rename_library "${INSTALL_DIR_SIMULATOR}"

# 各プラットフォーム用の framework を作成
create_framework "macos" "${INSTALL_DIR_MAC}"
create_framework "ios" "${INSTALL_DIR_IOS}"
create_framework "ios_simulator" "${INSTALL_DIR_SIMULATOR}"

# xcframework を作成
echo "🔗 Creating xcframework..."
xcodebuild -create-xcframework \
    -framework "${OUTPUT_DIR}/macos/${FRAMEWORK_NAME}.framework" \
    -framework "${OUTPUT_DIR}/ios/${FRAMEWORK_NAME}.framework" \
    -framework "${OUTPUT_DIR}/ios_simulator/${FRAMEWORK_NAME}.framework" \
    -output "${FRAMEWORK_NAME}.xcframework"

echo "🎉 ${FRAMEWORK_NAME}.xcframework has been created successfully!"
