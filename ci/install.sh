set -ex

main() {
    local target=
    if [ $OS_NAME = linux ]; then
        sudo apt-get install libssl-dev pkg-config
        sudo apt-get install openssl
        export PKG_CONFIG_PATH=/usr/lib/x86_64-linux-gnu/pkgconfig
        target=x86_64-unknown-linux-musl
        tree /usr/lib
        sort=sort
    else
        brew install coreutils
        target=x86_64-apple-darwin
        sort=gsort  # for `sort --sort-version`, from brew's coreutils.
    fi

    # This fetches latest stable release
    local tag=$(git ls-remote --tags --refs --exit-code https://github.com/japaric/cross \
                       | cut -d/ -f3 \
                       | grep -E '^v[0.1.0-9.]+$' \
                       | $sort --version-sort \
                       | tail -n1)
    curl -LSfs https://japaric.github.io/trust/install.sh | \
        sh -s -- \
           --force \
           --git japaric/cross \
           --tag $tag \
           --target $target
}

main
