FROM rustembedded/cross:armv7-unknown-linux-gnueabihf-0.2.1

WORKDIR /home/src

RUN dpkg --add-architecture armhf

RUN apt-get update && \
    apt-get install --assume-yes libasound2-dev:armhf libssl-dev:armhf

ENV PKG_CONFIG_LIBDIR=/usr/local/lib/arm-linux-gnueabihf/pkgconfig:/usr/lib/arm-linux-gnueabihf/pkgconfig

RUN curl https://sh.rustup.rs -sSf | \
    sh -s -- --default-toolchain stable -y

ENV PATH=/root/.cargo/bin:$PATH

RUN apt-get install libssl-dev pkg-config -y

COPY . .

CMD cargo build --release