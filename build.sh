#!/bin/sh
# Bootstrap only; application source generation and packaging run in Flexscript.
set -eu
root=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
cd "$root"
[ -f .flexscript/compiler/main.flex ] || { echo 'Run ./configure --sdk /path/to/flexscript first.' >&2; exit 1; }
export FLEXSCRIPT_LIB="$root/.flexscript/libs"
seed=${FLEXSCRIPT_COMPILER:-flexscript}
mkdir -p build
# Compile the selected SDK every time, so SDK changes cannot reuse a stale host.
"$seed" .flexscript/compiler/main.flex -o build/compiler.new
mv build/compiler.new build/compiler
compiler="$root/build/compiler"
target=${1:-desktop}
if [ "$#" -gt 0 ]; then shift; fi
case "$target" in
    cli) "$compiler" scripts/build-collie.flex -o build/build-collie; exec build/build-collie --compiler "$compiler" "$@" ;;
    desktop) "$compiler" desktop/build.flex -o build/build-desktop; exec build/build-desktop --compiler "$compiler" "$@" ;;
    android) "$compiler" scripts/build-collie-android.flex -o build/build-android; exec build/build-android --compiler "$compiler" "$@" ;;
    tools) "$compiler" scripts/build-tools.flex -o build/build-tools; exec build/build-tools --compiler "$compiler" "$@" ;;
    test) "$compiler" scripts/test-collie.flex -o build/test-collie-driver; exec build/test-collie-driver --compiler "$compiler" "$@" ;;
    *) echo 'Usage: ./build.sh {cli|desktop|android|tools|test} [builder options]' >&2; exit 2 ;;
esac
