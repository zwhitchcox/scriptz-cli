# This script takes care of testing your crate

set -ex

main() {
  # local targets=
  local target=
  if [ "$OS_NAME" == "linux" ]; then
    docker_targets=(
      aarch64-unknown-linux-gnu
      armv7-unknown-linux-gnueabihf
    )
    ls
    for target in "${docker_targets[@]}"; do
      arch=$(echo $target | sed 's/-.*//')
      docker build . -t runner -f ./ci/"$arch".Dockerfile
      docker run -v $PWD:/home/src runner
      sudo mv ./target/release/$PROJECT_NAME ./target/release/$PROJECT_NAME-$target
    done
    sudo chown -R $USER:$USER .
    target=x86_64-unknown-linux-gnu
    targets=(
      # x86_64-unknown-linux-gnu
      # x86_64-unknown-linux-musl
      # aarch64-unknown-linux-gnu
      # armv7-unknown-linux-gnueabihf
      # arm-unknown-linux-gnueabi
      # i686-unknown-linux-gnu
      # i686-unknown-linux-musl
      # mips-unknown-linux-gnu
      # mips64-unknown-linux-gnuabi64
      # mips64el-unknown-linux-gnuabi64
      # mipsel-unknown-linux-gnu
      # s390x-unknown-linux-gnu DISABLE_TESTS=1
    )
  else
    target=x86_64-apple-darwin
    # targets=(
    #   x86_64-apple-darwin
    # )
  fi

  cargo build --release
  mv target/release/$PROJECT_NAME target/release/$PROJECT_NAME-$target
}

main