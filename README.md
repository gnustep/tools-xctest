# tools-xctest

`tools-xctest` is a testing framework for Objective-C, providing functionalities identical to Apple's XCTest. It is designed for use with the GNUstep development environment. This framework allows developers to write and run unit tests for their Objective-C code in a way that is familiar to those accustomed to XCTest in Apple's ecosystem.

## Requirements
- GNUstep Base
- GNUstep Make

## Installation

### Dependencies
- GNUstep Base
- GNUstep Make

### Using Meson
1. Run `meson setup build`
2. Build XCTest with `ninja -C build`
3. Install XCTest with `ninja -C build install`

### Using GNUstep Make
1. Run `make` to build the project.
2. Run `make install` to install `tools-xctest` on your system.

## Usage
To use `tools-xctest`, include the header files in your test classes and link against the `tools-xctest` library. The usage is similar to Apple's XCTest:

```objc
#import <XCTest/XCTest.h>

@interface MyTestCase : XCTestCase
@end

@implementation MyTestCase

- (void)testExample {
    XCTAssertEqual(1 + 1, 2, @"Basic arithmetic doesn't seem to work!");
}

@end
```

You will need to compile the test cases into one or more bundles, as `xctest` expects `.bundle`'s. 

## Running Tests
Tests can be run using the command line tool provided by `tools-xctest`. This can be done by navigating to the directory containing your test cases and executing:

```bash
xctest [path to your test case bundle]
```

## License
`tools-xctest` is licensed under LGPL-2.1. Please refer to the COPYING.LIB file for detailed information. For files not explicitly licensed, they fall under the same LGPL.

## Contributions
Contributions to `tools-xctest` are welcome. Please submit pull requests or issues through the GitHub repository.