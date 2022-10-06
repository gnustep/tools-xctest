include $(GNUSTEP_MAKEFILES)/common.make

PACKAGE_NAME = XCTest

LIBRARY_NAME = libxctest
libxctest_HEADER_FILES = XCTest.h XCTestAssertions.h XCTestAssertionsImpl.h XCTestCase.h
libxctest_OBJC_FILES = XCTestAssertions.m XCTestCase.m
libxctest_INCLUDE_DIRS = -I../

-include GNUmakefile.preamble
include $(GNUSTEP_MAKEFILES)/library.make
-include GNUmakefile.postamble
