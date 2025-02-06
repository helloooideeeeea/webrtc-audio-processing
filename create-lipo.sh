#!/bin/bash

set -e

# ソースとターゲットのディレクトリ
PRE_INSTALL_DIR="pre_install"
INSTALL_DIR="install"

# 対象のプラットフォーム
PLATFORMS=("mac" "simulator")
LIBRARIES=("libwebrtc-audio-coding-1.a" "libwebrtc-audio-processing-1.a")

# install ディレクトリを作成
mkdir -p "$INSTALL_DIR"

for PLATFORM in "${PLATFORMS[@]}"; do
    echo "Processing platform: $PLATFORM"

    # インクルードディレクトリのコピー（arm64のみ）
    INCLUDE_SRC_ARM="$PRE_INSTALL_DIR/$PLATFORM/arm64/include"
    INCLUDE_DEST="$INSTALL_DIR/$PLATFORM/include"

    mkdir -p "$INCLUDE_DEST"
    cp -R "$INCLUDE_SRC_ARM/"* "$INCLUDE_DEST/"

    # ライブラリの結合
    LIB_DEST="$INSTALL_DIR/$PLATFORM/lib"
    mkdir -p "$LIB_DEST"

    for LIB in "${LIBRARIES[@]}"; do
        ARM64_LIB="$PRE_INSTALL_DIR/$PLATFORM/arm64/lib/$LIB"
        X86_LIB="$PRE_INSTALL_DIR/$PLATFORM/x86/lib/$LIB"
        UNIVERSAL_LIB="$LIB_DEST/$LIB"

        echo "Creating universal binary for $LIB"

        # lipo でユニバーサルバイナリを作成
        lipo -create "$ARM64_LIB" "$X86_LIB" -output "$UNIVERSAL_LIB"

        # ユニバーサルバイナリの確認
        lipo -info "$UNIVERSAL_LIB"
    done
done

echo "All libraries have been combined and installed to $INSTALL_DIR."
