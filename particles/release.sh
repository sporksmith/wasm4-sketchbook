#!/bin/bash

set -euo pipefail
set -x

zig build -Drelease-small=true

IN=zig-out/lib/cart.wasm
OUT=zig-out/lib/release.wasm
wasm-opt -Oz --strip-producers --strip-debug --dce --zero-filled-memory $IN -o $OUT -g

