# This script takes care of testing your crate

set -ex

main() {
  local targets=
  if [ "$OS_NAME" == "linux" ]; then
    if grep -i ubuntu /etc/os-release >/dev/null; then
        sed 's/http:\/\/\(.*\).ubuntu.com\/ubuntu\//[arch-=amd64,i386] http:\/\/ports.ubuntu.com\/ubuntu-ports\//g' /etc/apt/sources.list | sudo tee /etc/apt/sources.list.d/ports.list
        sudo sed -i 's/http:\/\/\(.*\).ubuntu.com\/ubuntu\//[arch=amd64,i386] http:\/\/\1.archive.ubuntu.com\/ubuntu\//g' /etc/apt/sources.list
    fi
    architectures=(
      armhf
      arm64
    )
    for arch in "${architectures[@]}"; do
      dpkg --add-architecture $arch
    done
    apt update
    for arch in "${architectures[@]}"; do
      dpkg --add-architecture $arch
      apt-get update && \
          apt-get install --assume-yes libssl-dev:"$arch"
    done

    targets=(
      aarch64-unknown-linux-gnu
      x86_64-unknown-linux-gnu
      # arm-unknown-linux-gnueabi
      armv7-unknown-linux-gnueabihf
      # i686-unknown-linux-gnu
      # i686-unknown-linux-musl
      # mips-unknown-linux-gnu
      # mips64-unknown-linux-gnuabi64
      # mips64el-unknown-linux-gnuabi64
      # mipsel-unknown-linux-gnu
      # s390x-unknown-linux-gnu DISABLE_TESTS=1
      x86_64-unknown-linux-musl
    )
  else
    targets=(
      x86_64-apple-darwin
    )
  fi
  # export PKG_CONFIG_PATH=/usr/lib/x86_64-linux-gnu/pkgconfig
  for target in "${targets[@]}"; do
    # local PKG_CONFIG_PATH=
    # if [ "$OS_NAME" == "linux" ]; then
    #   PKG_CONFIG_PATH=$(echo $target | sed 's/-unknown//')
    # fi
      cross build --target $target --release
      mv target/$target/release/$PROJECT_NAME target/release/$PROJECT_NAME-$target
  done
}

main