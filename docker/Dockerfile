# Godot Rust Cross Compiler
# -------------------------
#
# See https://github.com/macalimlim/godot-rust-cross-compiler for details

FROM ubuntu:focal

ARG GRCC_VERSION
LABEL maintainers="Michael Angelo Calimlim <macalimlim@gmail.com>,Christian Mauduit <ufoot@ufoot.org>" package="godot-rust-cross-compiler" version="$GRCC_VERSION" description="An image to cross-compile to Windows, Android, Mac OS X, iOS and Linux your godot-rust based libraries."

# Prepare the system, install Debian packages
# -------------------------------------------

RUN apt-get update
RUN DEBIAN_FRONTEND="noninteractive" apt-get -y install tzdata
RUN apt-get install -yq \
    sudo curl wget git zip unzip \
    file g++ cmake pkg-config \
    libasound2-dev bison flex \
    ant openjdk-8-jdk adb \
    lib32stdc++6 lib32z1 libssl-dev python \
    g++-multilib gcc-multilib libc6-dev-i386 \
    llvm-dev libclang-dev clang \
    libncurses5 libncurses5-dev \
    binutils-mingw-w64 gcc-mingw-w64 g++-mingw-w64 \
    libxml2-dev libz-dev \
    ca-certificates default-jre-headless \
#    godot3 mono-devel \
    libsaxon-java nunit xvfb \
    vim \
    && apt-get clean

ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64

# Install Rust
# ------------

ENV RUST_VERSION=1.72.0
RUN curl https://sh.rustup.rs -sSf | sh -s -- --default-toolchain $RUST_VERSION -y
ENV PATH /root/.cargo/bin:$PATH

RUN rustup target add \
    x86_64-pc-windows-gnu \
    aarch64-linux-android \
    armv7-linux-androideabi \
    x86_64-linux-android \
    i686-linux-android \
    x86_64-apple-darwin \
    aarch64-apple-darwin \
    x86_64-unknown-linux-gnu \
    i686-unknown-linux-gnu \
    aarch64-apple-ios

RUN mkdir /root/.cargo/git
RUN mkdir /root/.cargo/registry

# Install android SDK
# -------------------

ARG ANDROID_BUILD_TOOLS_PATH=/opt/android-build-tools
WORKDIR $ANDROID_BUILD_TOOLS_PATH

ARG ANDROID_BASE_URL=https://dl.google.com/android

ENV ANDROID_SDK_RELEASE=android-sdk_r24.4.1
ARG ANDROID_SDK_DIR=android-sdk-linux
ARG ANDROID_SDK_FILENAME=$ANDROID_SDK_RELEASE-linux.tgz
ARG ANDROID_SDK_URL=$ANDROID_BASE_URL/$ANDROID_SDK_FILENAME
ARG ANDROID_SDK_PATH=$ANDROID_BUILD_TOOLS_PATH/$ANDROID_SDK_DIR
ENV ANDROID_SDK_ROOT=$ANDROID_SDK_PATH

RUN wget -nc -nv $ANDROID_SDK_URL && tar -xzf $ANDROID_SDK_FILENAME && rm $ANDROID_SDK_FILENAME

# Install android commandline tools
# ---------------------------------

ENV ANDROID_CMDLINETOOLS_RELEASE=8512546
ARG ANDROID_CMDLINETOOLS_FILENAME=commandlinetools-linux-${ANDROID_CMDLINETOOLS_RELEASE}_latest.zip
ARG ANDROID_CMDLINETOOLS_URL=${ANDROID_BASE_URL}/repository/${ANDROID_CMDLINETOOLS_FILENAME}
ARG ANDROID_CMDLINETOOLS_PATH=${ANDROID_SDK_PATH}/cmdline-tools
WORKDIR ${ANDROID_CMDLINETOOLS_PATH}
RUN wget -nc -nv $ANDROID_CMDLINETOOLS_URL && unzip -d latest $ANDROID_CMDLINETOOLS_FILENAME && rm ${ANDROID_CMDLINETOOLS_FILENAME}
WORKDIR ${ANDROID_CMDLINETOOLS_PATH}/latest
RUN mv cmdline-tools/* .
RUN rm -rf cmdline-tools/

# Install android NDK
# -------------------

ENV ANDROID_NDK_VERSION=26.1.10909125
RUN yes | bin/sdkmanager --licenses
RUN bin/sdkmanager --install "ndk;${ANDROID_NDK_VERSION}" --channel=3
ARG ANDROID_NDK_DIR=ndk/${ANDROID_NDK_VERSION}
ARG ANDROID_NDK_PATH=${ANDROID_SDK_PATH}/${ANDROID_NDK_DIR}

# Install uber APK signer
# -----------------------

ARG UBER_APK_SIGNER_VERSION=1.2.1
ARG UBER_APK_SIGNER_BASE_URL=https://github.com/patrickfav/uber-apk-signer/releases/download/v$UBER_APK_SIGNER_VERSION
ARG UBER_APK_SIGNER_FILENAME=uber-apk-signer-$UBER_APK_SIGNER_VERSION.jar
ARG UBER_APK_SIGNER_URL=$UBER_APK_SIGNER_BASE_URL/$UBER_APK_SIGNER_FILENAME
WORKDIR $ANDROID_BUILD_TOOLS_PATH
RUN wget -nc -nv $UBER_APK_SIGNER_URL && ln -s $UBER_APK_SIGNER_FILENAME uber-apk-signer.jar

# Configure Rust for Android cross-compiling
# ------------------------------------------

RUN echo "[target.aarch64-linux-android]" >> /root/.cargo/config
RUN find $ANDROID_NDK_PATH -name aarch64-linux-android21-clang++ -printf 'linker = "%p"\n' >> /root/.cargo/config
RUN echo >> /root/.cargo/config

RUN echo "[target.armv7-linux-androideabi]" >> /root/.cargo/config
RUN find $ANDROID_NDK_PATH -name armv7a-linux-androideabi21-clang++ -printf 'linker = "%p"\n' >> /root/.cargo/config
RUN echo >> /root/.cargo/config

RUN echo "[target.x86_64-linux-android]" >> /root/.cargo/config
RUN find $ANDROID_NDK_PATH -name x86_64-linux-android21-clang++ -printf 'linker = "%p"\n' >> /root/.cargo/config
RUN echo >> /root/.cargo/config

RUN echo "[target.i686-linux-android]" >> /root/.cargo/config
RUN find $ANDROID_NDK_PATH -name i686-linux-android21-clang++ -printf 'linker = "%p"\n' >> /root/.cargo/config
RUN echo >> /root/.cargo/config

# Install OSX cross build env
# ---------------------------

ENV MACOSX_SDK_VERSION=11.3
ARG OSXCROSS_COMMIT=ff8d100f3f026b4ffbe4ce96d8aac4ce06f1278b
ARG MACOSX_BUILD_TOOLS_PATH=/opt/macosx-build-tools
ARG OSXCROSS_PATH=$MACOSX_BUILD_TOOLS_PATH/osxcross
ARG MACOSX_CROSS_COMPILER_PATH=$MACOSX_BUILD_TOOLS_PATH/cross-compiler
ARG MACOSX_SDK_BASE_URL=https://github.com/phracker/MacOSX-SDKs/releases/download/${MACOSX_SDK_VERSION}
ARG MACOSX_SDK_FILENAME=MacOSX$MACOSX_SDK_VERSION.sdk.tar.xz
WORKDIR $MACOSX_BUILD_TOOLS_PATH
RUN git clone https://github.com/tpoechtrager/osxcross
WORKDIR $OSXCROSS_PATH
RUN git checkout $OSXCROSS_COMMIT
RUN echo install $MACOSX_SDK_BASE_URL/$MACOSX_SDK_FILENAME
RUN wget -nc -nv $MACOSX_SDK_BASE_URL/$MACOSX_SDK_FILENAME
RUN mv $MACOSX_SDK_FILENAME tarballs/
RUN UNATTENDED=yes TARGET_DIR=$MACOSX_CROSS_COMPILER_PATH ./build.sh 2>&1 | tee build.log
ARG MACOSX_SDK_PATH=${MACOSX_CROSS_COMPILER_PATH}/SDK

# Configure Rust for Mac OS X cross-compiling
# -------------------------------------------

RUN echo "[target.x86_64-apple-darwin]" >> /root/.cargo/config
RUN OSXCROSS_TARGET=$( ${MACOSX_CROSS_COMPILER_PATH}/bin/osxcross-conf | grep OSXCROSS_TARGET= | awk -F'=' '{print $2}' ) && find ${MACOSX_CROSS_COMPILER_PATH} -name x86_64-apple-$OSXCROSS_TARGET-cc -printf 'linker = "%p"\n' >> /root/.cargo/config
RUN echo >> /root/.cargo/config

RUN echo "[target.aarch64-apple-darwin]" >> /root/.cargo/config
RUN OSXCROSS_TARGET=$( ${MACOSX_CROSS_COMPILER_PATH}/bin/osxcross-conf | grep OSXCROSS_TARGET= | awk -F'=' '{print $2}' ) && find ${MACOSX_CROSS_COMPILER_PATH} -name aarch64-apple-$OSXCROSS_TARGET-cc -printf 'linker = "%p"\n' >> /root/.cargo/config
RUN echo >> /root/.cargo/config

# Install iPhoneOS SDK and iOS toolchain
# --------------------------------------

ENV IOS_SDK_VERSION=14.5
ARG IOS_BUILD_TOOLS_PATH=/opt/ios-build-tools
ARG IOS_CROSS_COMPILER_PATH=$IOS_BUILD_TOOLS_PATH/cross-compiler
WORKDIR $IOS_BUILD_TOOLS_PATH
RUN git clone https://github.com/theos/sdks
ARG IOS_SDK_PATH=${IOS_BUILD_TOOLS_PATH}/sdks
WORKDIR ${IOS_SDK_PATH}
RUN tar -cf - ./iPhoneOS${IOS_SDK_VERSION}.sdk | xz -9 -c - > iPhoneOS${IOS_SDK_VERSION}.sdk.tar.xz
WORKDIR ${OSXCROSS_PATH}/build/cctools-port/usage_examples/ios_toolchain
RUN ./build.sh ${IOS_SDK_PATH}/iPhoneOS${IOS_SDK_VERSION}.sdk.tar.xz arm64
WORKDIR ${IOS_CROSS_COMPILER_PATH}
RUN mv ${OSXCROSS_PATH}/build/cctools-port/usage_examples/ios_toolchain/target/* .

# Configure Rust for iOS cross-compiling
# -------------------------------------------

RUN echo "[target.aarch64-apple-ios]" >> /root/.cargo/config
RUN find ${IOS_CROSS_COMPILER_PATH} -name arm-apple-darwin11-ar -printf 'ar = "%p"\n' >> /root/.cargo/config
RUN find ${IOS_CROSS_COMPILER_PATH} -name arm-apple-darwin11-clang -printf 'linker = "%p"\n' >> /root/.cargo/config
RUN echo >> /root/.cargo/config

# Copy xcrun script
# -----------------

ARG IOS_BUILD_TOOLS_BIN_PATH=${IOS_BUILD_TOOLS_PATH}/bin
WORKDIR ${IOS_BUILD_TOOLS_BIN_PATH}
COPY ./xcrun .
RUN sed -i "s|<macosx-sdk-path>|${MACOSX_SDK_PATH}|;s|<macosx-sdk-version>|${MACOSX_SDK_VERSION}|;s|<ios-sdk-path>|${IOS_SDK_PATH}|;s|<ios-sdk-version>|${IOS_SDK_VERSION}|g" xcrun
RUN chmod +x ./xcrun
ENV PATH=${IOS_BUILD_TOOLS_BIN_PATH}:$PATH

# Install all flavors of Godot
# ----------------------------

ENV GODOT_VERSION=3.5.2
ARG GODOT_BASE_URL=https://downloads.tuxfamily.org/godotengine
ENV GODOT_DIR=/opt/godotengine
WORKDIR $GODOT_DIR
RUN for i in x11 linux_headless linux_server ; do wget -nc -nv $GODOT_BASE_URL/$GODOT_VERSION/Godot_v$GODOT_VERSION-stable_$i.64.zip ; done && for i in *.zip ; do unzip -q $i ; done && rm *.zip
# RUN for i in x11 linux_headless linux_server ; do wget -nc -nv $GODOT_BASE_URL/$GODOT_VERSION/mono/Godot_v$GODOT_VERSION-stable_mono_${i}_64.zip ; done && for i in *.zip ; do unzip -q $i ; done && rm *.zip
RUN ln -s Godot_v$GODOT_VERSION-stable_x11.64 godot3 && \
    ln -s Godot_v$GODOT_VERSION-stable_x11.64 godot && \
    ln -s Godot_v$GODOT_VERSION-stable_linux_headless.64 godot3_headless && \
    ln -s Godot_v$GODOT_VERSION-stable_linux_headless.64 godot_headless && \
    ln -s Godot_v$GODOT_VERSION-stable_linux_server.64 godot3_server && \
    ln -s Godot_v$GODOT_VERSION-stable_linux_server.64 godot_server
#    ln -s Godot_v$GODOT_VERSION-stable_mono_x11_64 godot3_mono && \
#    ln -s Godot_v$GODOT_VERSION-stable_mono_x11_64 godot_mono && \
#    ln -s Godot_v$GODOT_VERSION-stable_mono_linux_headless_64 godot3_mono_headless && \
#    ln -s Godot_v$GODOT_VERSION-stable_mono_linux_headless_64 godot_mono_headless && \
#    ln -s Godot_v$GODOT_VERSION-stable_mono_linux_server_64 godot3_mono_server && \
#    ln -s Godot_v$GODOT_VERSION-stable_mono_linux_server_64 godot_mono_server && \
#    ln -s Godot_v$GODOT_VERSION-stable_mono_x11.64 godot3_mono/godot3_mono && \
#    ln -s Godot_v$GODOT_VERSION-stable_mono_x11.64 godot_mono/godot_mono && \
#    ln -s Godot_v$GODOT_VERSION-stable_mono_linux_headless.64 godot3_mono_headless/godot3_mono_headless && \
#    ln -s Godot_v$GODOT_VERSION-stable_mono_linux_headless.64 godot_mono_headless/godot_mono_headless && \
#    ln -s Godot_v$GODOT_VERSION-stable_mono_linux_server.64 godot3_mono_server/godot3_mono_server && \
#    ln -s Godot_v$GODOT_VERSION-stable_mono_linux_server.64 godot_mono_server/godot_mono_server
# ENV PATH=$GODOT_DIR:$GODOT_DIR/godot3_mono:$GODOT_DIR/godot3_mono_headless:$GODOT_DIR/godot3_mono_server:$PATH
ENV PATH=$GODOT_DIR:$PATH

# Install Godot export templates
# ------------------------------

ARG GODOT_TEMPLATE_DIR=/root/.local/share/godot/templates
WORKDIR $GODOT_TEMPLATE_DIR
RUN wget -nc -nv $GODOT_BASE_URL/$GODOT_VERSION/Godot_v$GODOT_VERSION-stable_export_templates.tpz && unzip -q Godot_v$GODOT_VERSION-stable_export_templates.tpz && rm Godot_v$GODOT_VERSION-stable_export_templates.tpz && mv templates $GODOT_VERSION.stable
# RUN wget -nc -nv $GODOT_BASE_URL/$GODOT_VERSION/mono/Godot_v$GODOT_VERSION-stable_mono_export_templates.tpz && unzip -q Godot_v$GODOT_VERSION-stable_mono_export_templates.tpz && rm Godot_v$GODOT_VERSION-stable_mono_export_templates.tpz && mv templates $GODOT_VERSION.stable.mono

# Setup editor defaults so that export works
# ------------------------------------------

ARG ANDROID_KEYSTORE_DIR=/root/.android
WORKDIR $ANDROID_KEYSTORE_DIR
RUN keytool -keyalg RSA -genkeypair -alias androiddebugkey -keypass android -keystore debug.keystore -storepass android -dname "CN=Android Debug,O=Android,C=US" -validity 9999 -deststoretype pkcs12
ARG GODOT_EDITOR_CONFIG_DIR=/root/.config/godot
ARG GODOT_EDITOR_CONFIG_FILENAME=editor_settings-3.tres
WORKDIR $GODOT_EDITOR_CONFIG_DIR
RUN echo '[gd_resource type="EditorSettings" format=2]' >> $GODOT_EDITOR_CONFIG_FILENAME
RUN echo >> $GODOT_EDITOR_CONFIG_FILENAME
RUN echo '[resource]' >> $GODOT_EDITOR_CONFIG_FILENAME
RUN echo 'export/android/adb = "/usr/bin/adb"' >> $GODOT_EDITOR_CONFIG_FILENAME
RUN echo 'export/android/jarsigner = "/usr/bin/jarsigner"' >> $GODOT_EDITOR_CONFIG_FILENAME
RUN echo 'export/android/debug_keystore = "/root/.android/debug.keystore"' >> $GODOT_EDITOR_CONFIG_FILENAME
RUN echo 'export/android/debug_keystore_user = "androiddebugkey"' >> $GODOT_EDITOR_CONFIG_FILENAME
RUN echo 'export/android/debug_keystore_pass = "android"' >> $GODOT_EDITOR_CONFIG_FILENAME

# Mark the sytem as being a godot-run-cross-compiler image
# --------------------------------------------------------

WORKDIR /opt
RUN echo $GRCC_VERSION > godot-rust-cross-compiler.txt

# Work in /build
# --------------

WORKDIR /build

# Example usage:
# docker run -v $(pwd):/build macalimlim/godot-rust-cross-compiler cargo build --release --target aarch64-linux-android
#
# Using a cache:
# install -d /tmp/.cargo/git
# install -d /tmp/.cargo/registry
# docker run -v $(pwd):/build macalimlim/godot-rust-cross-compiler -v/tmp/.cargo/git:/root/.cargo/git -v/tmp/.cargo/registry:/root/.cargo/registry macalimlim/godot-rust-cross-compiler cargo build --release --target aarch64-linux-android
