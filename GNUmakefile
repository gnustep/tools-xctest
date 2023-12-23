ifeq ($(GNUSTEP_MAKEFILES),)
 GNUSTEP_MAKEFILES := $(shell gnustep-config --variable=GNUSTEP_MAKEFILES 2>/dev/null)
endif
ifeq ($(GNUSTEP_MAKEFILES),)
 $(error You need to set GNUSTEP_MAKEFILES before compiling!)
endif

include $(GNUSTEP_MAKEFILES)/common.make

PACKAGE_NAME = xctest
TOOL_NAME = xctest
SUBPROJECTS = XCTest

xctest_OBJC_FILES = main.m
ADDITIONAL_TOOL_LIBS = -lXCTest
ADDITIONAL_LIB_DIRS = -L./XCTest/obj

-include GNUmakefile.preamble
include $(GNUSTEP_MAKEFILES)/aggregate.make
include $(GNUSTEP_MAKEFILES)/tool.make

-include GNUmakefile.postamble