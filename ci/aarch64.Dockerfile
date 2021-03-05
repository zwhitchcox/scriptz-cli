FROM rustembedded/cross:aarch64-unknown-linux-gnu-0.2.1

WORKDIR /home/src

RUN dpkg --add-architecture arm64

RUN apt-get update && \
    apt-get install --assume-yes libssl-dev:arm64

CMD tail -f /dev/null

ENV PKG_CONFIG_LIBDIR=/usr/lib/aarch64-linux-gnu/pkgconfig

RUN curl https://sh.rustup.rs -sSf | \
    sh -s -- --default-toolchain stable -y

ENV PATH=/root/.cargo/bin:$PATH

RUN apt-get install libssl-dev pkg-config -y

COPY . .

CMD cargo build --release