# Da LLVM toolchain
FROM alpine:3.21 as alpine

## Root User Tasks
RUN apk update ;\
  apk upgrade ;\
  apk add --no-cache build-base git cmake ninja clang llvm meson curl wget bash zsh;

# Create a group and user
RUN addgroup -S buildops && adduser -S buildops -G buildops

# Configure Git
RUN git config --global user.email "tenkai@zetaohm.com" ; git config --global user.name "tenkai"

WORKDIR /tmp
# Install LLVM-embedded-toolchain-for-Arm

ENV LLVM_VERSION="LLVM-ET-Arm-19.1.5-Linux-AArch64"

RUN export LLVM_URL="https://github.com/ARM-software/LLVM-embedded-toolchain-for-Arm/releases/download/release-19.1.5/LLVM-ET-Arm-19.1.5-Linux-AArch64.tar.xz -nv" ;\
  wget $LLVM_URL ;\
  tar -xf $LLVM_VERSION.tar.xz -C /opt/ ;\
  chmod -R 755 /opt/$LLVM_VERSION/bin

USER buildops
WORKDIR /home/buildops

# Install Rust nightly-2024-10-13 for buck2
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y  ;\
  . "$HOME/.cargo/env" ;\
  rustup install nightly-2024-10-13 ;\
  echo ". $HOME/.cargo/env" >> ~/.bashrc

# Install Buck2
RUN   . "$HOME/.cargo/env" ;\
  cargo +nightly-2024-10-13 install --git https://github.com/facebook/buck2.git buck2

# Set PATH and Cargo env
RUN touch .bashrc ;\
  echo 'export PATH="/opt/$LLVM_VERSION/bin:$PATH"' >> .bashrc ;\
  echo ". /home/buildops/.cargo/env" >> .bashrc

COPY docker_entrypoint.sh /home/buildops/entrypoint.sh

USER root
RUN chmod 755 /home/buildops/entrypoint.sh ;\
  chown buildops:buildops entrypoint.sh

USER buildops
ENTRYPOINT [ "/home/buildops/entrypoint.sh" ]
