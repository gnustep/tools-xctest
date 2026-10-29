#!/bin/sh
set -eu
cd "$(dirname "$0")/.."
make
make -C Tests
export LD_LIBRARY_PATH="$PWD/XCTest/obj${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
Tests/obj/regression
obj/xctest --help
obj/xctest -XCTest CLIExample.testPass Tests/Fixture.bundle
obj/xctest -XCTest CLIExample/testPass Tests/Fixture.bundle
expect_failure() {
    if "$@"; then
        echo "Unexpected success: $*" >&2
        exit 1
    fi
}
expect_failure obj/xctest
expect_failure obj/xctest /does/not/exist.bundle
expect_failure obj/xctest --unknown Tests/Fixture.bundle
expect_failure obj/xctest -XCTest
expect_failure obj/xctest -XCTest Missing Tests/Fixture.bundle
expect_failure obj/xctest -XCTest CLIExample.testFail Tests/Fixture.bundle
expect_failure obj/xctest Tests/Fixture.bundle
expect_failure obj/xctest -XCTest All Tests/Fixture.bundle
expect_failure obj/xctest -XCTest CLIExample.testPass,Missing Tests/Fixture.bundle
expect_failure obj/xctest -XCTest CLIExample/testFail Tests/Fixture.bundle
echo "All regression and CLI checks passed."
