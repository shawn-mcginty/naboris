#!/bin/bash
npm run build-load-test-server
echo old: $DUNE_BUILD_DIR
export DUNE_BUILD_DIR=""
source command-env
echo new: $DUNE_BUILD_DIR
$DUNE_BUILD_DIR/default/load-test/load_test.exe &
# let the server fully start
test_load_pid=$!
sleep 10
/bin/bash load-test/scripts/load-test.sh
test_res=$?
kill -9 $test_load_pid
exit $test_res