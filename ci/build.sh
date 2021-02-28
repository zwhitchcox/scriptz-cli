# This script takes care of testing your crate

set -ex

#         strip target/release/$PROJECT_NAME && mv target/$TARGET/release/$PROJECT_NAME target/release/$PROJECT_NAME-$TARGET
main() {
  local targets=
  if [ "$OS_NAME" == "linux" ]; then
    targets=(
      aarch64-unknown-linux-gnu
      x86_64-unknown-linux-gnu
      # arm-unknown-linux-gnueabi
      # armv7-unknown-linux-gnueabihf
      # i686-unknown-linux-gnu
      # i686-unknown-linux-musl
      # mips-unknown-linux-gnu
      # mips64-unknown-linux-gnuabi64
      # mips64el-unknown-linux-gnuabi64
      # mipsel-unknown-linux-gnu
      # s390x-unknown-linux-gnu DISABLE_TESTS=1
      # x86_64-unknown-linux-musl
    )
  else
    targets=(
      x86_64-apple-darwin
    )
  fi
  for target in "${targets[@]}"; do
    echo building $target
    cross build --target $target --release
    mv target/$target/release/$PROJECT_NAME target/release/$PROJECT_NAME-$target
  done
}

main