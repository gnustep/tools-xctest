include $(GNUSTEP_MAKEFILES)/common.make

PACKAGE_NAME = xctest
TOOL_NAME = xctest
SUBPROJECTS = XCTest

xctest_HEADER_FILES = GSXCTestRunner.h
xctest_OBJC_FILES = main.m GSXCTestRunner.m
ADDITIONAL_TOOL_LIBS = -lxctest
ADDITIONAL_LIB_DIRS = -L./XCTest/obj

-include GNUmakefile.preamble
include $(GNUSTEP_MAKEFILES)/aggregate.make
include $(GNUSTEP_MAKEFILES)/tool.make

-include GNUmakefile.postamble