# This script takes care of testing your crate

set -ex

cross build --target $TARGET --release