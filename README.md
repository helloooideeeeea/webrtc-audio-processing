# About This Repository

Forked from https://gitlab.freedesktop.org/jbeich/webrtc-audio-processing. 

Repository for building XCFrameworks for macOS and iOS.

Refer to the instructions below for the build process.

***iOS/macOS***

```bash
$ meson setup mac_build_arm64 --cross-file cross_mac_arm64.ini -Dprefix=$PWD/pre_install/mac/arm64 -Ddefault_library=static && meson compile -C mac_build_arm64 && meson install -C mac_build_arm64

$ meson setup mac_build_x86 --cross-file cross_mac_x86.ini -Dprefix=$PWD/pre_install/mac/x86 -Ddefault_library=static && meson compile -C mac_build_x86 && meson install -C mac_build_x86

$ meson setup ios_build_simulator_arm64 --cross-file cross_ios_simulator_arm64.ini -Dprefix=$PWD/pre_install/simulator/arm64 -Ddefault_library=static && meson compile -C ios_build_simulator_arm64 && meson install -C ios_build_simulator_arm64

$ meson setup ios_build_simulator_x86 --cross-file cross_ios_simulator_x86.ini -Dprefix=$PWD/pre_install/simulator/x86 -Ddefault_library=static && meson compile -C ios_build_simulator_x86 && meson install -C ios_build_simulator_x86

$ /bin/bash create-lipo.sh

$ meson setup ios_build --cross-file cross_ios.ini -Dprefix=$PWD/install/ios -Ddefault_library=static && meson compile -C ios_build && meson install -C ios_build

$ /bin/bash create-framework.sh

$ ls webrtc_audio_processing.xcframework
```

***Android***

### **🔔 Android Build Notice: Set NDK\_PATH**

Before building for Android, you **must set the NDK path** in your environment.
Modify your `cross_android_${ANDROID_ABI}(ex.aarch64)`.ini (or similar files) to include:

```
[constants]
ndk_path    = '/Users/your_username/Library/Android/sdk/ndk/25.1.8937393' # Change this to your correct path
```

```bash
$ meson setup android_build_aarch64 --cross-file cross_android_aarch64.ini -Dprefix=$PWD/pre_install/android/aarch64 && meson compile -C android_build_aarch64 && meson install -C android_build_aarch64

$ meson setup android_build_armv7a --cross-file cross_android_armv7a.ini -Dprefix=$PWD/pre_install/android/armv7a && meson compile -C android_build_armv7a && meson install -C android_build_armv7a

$ meson setup android_build_x86 --cross-file cross_android_x86_64.ini -Dprefix=$PWD/pre_install/android/x86 && meson compile -C android_build_x86 && meson install -C android_build_x86

$ tree pre_install/android -L 3
```

# About

This is meant to be a more Linux packaging friendly copy of the AudioProcessing
module from the [ WebRTC ](https://webrtc.googlesource.com/src) project. The
ideal case is that we make no changes to the code to make tracking upstream
code easy.

This package currently only includes the AudioProcessing bits, but I am very
open to collaborating with other projects that wish to distribute other bits of
the code and hopefully eventually have a single point of packaging all the
WebRTC code to help people reuse the code and avoid keeping private copies in
several different projects.

# Building

This project uses the [Meson build system](https://mesonbuild.com/). The
quickest way to build is:

```sh
# Initialise into the build/ directory, for a prefixed install into the
# install/ directory
meson . build -Dprefix=$PWD/install

# Run the actual build
ninja -C build

# Install locally
ninja -C build install

# The libraries, headers, and pkg-config files are now in the install/
# directory
```

# Feedback

Patches, suggestions welcome. You can file an issue on our Gitlab
[repository](https://gitlab.freedesktop.org/pulseaudio/webrtc-audio-processing/).

# Notes

1. It might be nice to try LTO on the library. We build a lot of code as part
   of the main AudioProcessing module deps, and it's possible that this could
   provide significant space savings.
