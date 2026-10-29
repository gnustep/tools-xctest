# tools-xctest

An Objective-C XCTest compatibility library and command-line test runner for
GNUstep. Build with `make` in a configured GNUstep development environment.
The library requires Objective-C exceptions and blocks support.

Link test bundles or standalone test programs against `libXCTest` and import
`<XCTest/XCTest.h>`. For an uninstalled build, add this repository to the header
search path and `XCTest/obj` to the library search path. On Linux, put
`XCTest/obj` in `LD_LIBRARY_PATH` when running against the local library.

```sh
xctest path/to/Tests.bundle
xctest -XCTest ExampleTests path/to/Tests.bundle
xctest -XCTest ExampleTests/testAddition,OtherTests/testParsing path/to/Tests.bundle
```

`-XCTest All` runs all discovered tests. A test is selected as `Class/method`,
as with Apple's xctest; `Class.method` works too. Exit status is zero only when at least
one test executes and every selected test succeeds. Invalid bundles, unmatched
filters, empty runs, assertion failures, and uncaught exceptions return nonzero.

## Building with Meson

As an alternative to GNUstep Make, use Meson with Clang and a configured
GNUstep environment:

```sh
OBJC=clang meson setup build
meson compile -C build
meson install -C build
```

The runner is part of `libXCTest`; its public header is
`<XCTest/GSXCTestRunner.h>`.

## Supported behavior

- Discovery of `void` instance methods whose names start with `test` and which
  take no arguments, including inherited methods and subclass overrides.
  Classes and methods run in alphabetical order, with a fresh instance per test.
- Class `+setUp` / `+tearDown` and instance `-setUp` / `-tearDown`. Instance
  teardown runs even when setup or the test throws; class teardown runs after
  class setup failures. Uncaught exceptions are recorded as failures.
- Selector- and invocation-based test construction, `name`, `invocation`,
  `invokeTest`, `continueAfterFailure` (default `YES`), and overridable
  `recordFailureWithDescription:inFile:atLine:expected:`. The GNUstep extension
  `failureCount` reports failures for the latest invocation. Standalone cases
  work without linking the runner.
- Boolean, nil, object/scalar equality, ordering, accuracy, and exception
  assertions. Diagnostics include expressions, values, file/line, and optional
  formatted messages. Expressions are evaluated once. Accuracy comparisons
  support integers and floating-point values without integer subtraction
  overflow. NaN operands or a negative/NaN accuracy never yield equality.
- `XCTestExpectation`, fulfillment counts, inverted expectations, and optional
  over-fulfillment checks while waiting. `fulfill` is thread-safe.
  `waitForExpectationsWithTimeout:handler:` and
  `waitForExpectations:timeout:` pump the calling thread's default run loop.
  Timeouts and expectation violations record failures; completion handlers
  receive an `NSError` on failure. Case-created expectations must be waited on.

Create and wait on expectations on the test thread; callbacks on other threads
may fulfill them. Inverted expectations require waiting for the entire timeout.
Nested waits and empty expectation lists are rejected. Callbacks should finish
before the test returns; late fulfillment after a completed wait is not checked.

This is a subset of XCTest, not full Apple XCTest compatibility. Test suites/run
objects, observation APIs, performance measurement, UI testing, specialized
notification/predicate expectations, and `XCTWaiter` are not implemented.

## Regression tests

```sh
sh Tests/run.sh
```

This builds a standalone regression program and a loadable test bundle, checks
assertions, lifecycle, discovery, filtering, asynchronous waits, and CLI exit
statuses. Some fixtures fail deliberately; the script succeeds only when these
failures are detected correctly.

## License

The license for some files is in their headers. Files without an explicit
license are under the LGPL; see COPYING.LIB.
