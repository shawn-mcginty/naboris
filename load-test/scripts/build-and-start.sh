#!/bin/bash
# exit if any return non 0
set -e
npm run build-load-test-server
echo old: $DUNE_BUILD_DIR
export DUNE_BUILD_DIR=""
source command-env
echo new: $DUNE_BUILD_DIR
$DUNE_BUILD_DIR/default/load-test/load_test.exe