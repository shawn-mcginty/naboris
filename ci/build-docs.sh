#!/bin/bash
set -e
esy b dune build @doc
rm -f tmp-docs-build-env
esy build-env | grep DUNE_BUILD_DIR > tmp-docs-build-env
echo old: $DUNE_BUILD_DIR
export DUNE_BUILD_DIR=""
source tmp-docs-build-env
echo new: $DUNE_BUILD_DIR
rm -rf docs/html
rm -f tmp-docs-build-env
cp -r $DUNE_BUILD_DIR/default/_doc/_html ./docs/html