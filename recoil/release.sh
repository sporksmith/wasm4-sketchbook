#!/bin/bash

set -euo pipefail
set -x

zig build -Drelease-small=true

IN=zig-out/lib/cart.wasm
OUT=zig-out/lib/release.wasm
wasm-opt -Oz --strip-producers --strip-debug --dce --zero-filled-memory $IN -o $OUT -g

DIRNAME=$(basename $(pwd))
w4 bundle --html ../docs/$DIRNAME/index.html --description "https://github.com/sporksmith/wasm4-sketchbook/tree/main/$DIRNAME" zig-out/lib/release.wasm
