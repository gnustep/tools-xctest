project('xctest', 'objc', version : '0.1.0', default_options : ['warning_level=3'])

pkg = import('pkgconfig')

# Ensure clang is used for Objective-C
objc_compiler = meson.get_compiler('objc')
if objc_compiler.get_id() != 'clang'
  error('Clang is required for this project. Please set CC=clang, and OBJC=clang before running Meson.')
endif
 
dependencies_to_link = []
# Common Objective-C flags
objc_flags = []

# Use GNUstep on non-Darwin platforms
if host_machine.system() != 'darwin'
    # Objective-C (GNUstep) support from gnustep-config
    gnustep_config = find_program('gnustep-config', required: true)
    if not gnustep_config.found()
        error('GNUstep is required for this project. Please install GNUstep and ensure gnustep-config is in your PATH. You might want to source GNUstep.sh before running Meson.')
    endif

    gnustep_flags = run_command(gnustep_config, '--objc-flags', check: true).stdout().strip().split()
    gnustep_base_libs = run_command(gnustep_config, '--base-libs', check: true).stdout().strip().split()

    # Filter out flags that are handled by Meson's built-in options
    foreach flag : gnustep_flags
    if flag != '-Wall' and flag != '-g' and flag != '-O2' and flag != '-MMD'
        objc_flags += flag
    endif
    endforeach

    add_project_link_arguments(gnustep_base_libs, language: 'objc')
else
  # Properly link against the Foundation framework
  foundation_dep = dependency('appleframeworks', modules: ['Foundation'])
  dependencies_to_link += foundation_dep

  add_project_link_arguments('-lobjc', language: 'objc')
endif

# Add Objective-C flags
add_project_arguments(objc_flags, language: 'objc')

source = [
	'XCTest/XCTestAssertions.m',
	'XCTest/XCTestCase.m',
	'XCTest/GSXCTestRunner.m',
]

headers = [
	'XCTest/XCTest.h',
	'XCTest/XCTestAssertions.h',
	'XCTest/XCTestAssertionsImpl.h',
	'XCTest/XCTestCase.h',
	'XCTest/GSXCTestRunner.h',
]

include_dirs = include_directories(
    'XCTest',
)

# Build XCTest library
xctest_lib = library(
  'XCTest',
  source,
  dependencies: dependencies_to_link,
  include_directories: include_dirs,
  install: true,
)

install_headers(
  headers,
  install_dir: join_paths(get_option('prefix'), get_option('includedir'), 'XCTest'),
)

pkg.generate(libraries : xctest_lib,
             version : meson.project_version(),
             name : 'XCTest',
             filebase : 'XCTest',
             description : 'Reimplementation of XCTest for GNUstep',
)

# Build XCTest tool
executable('xctest', 'main.m', link_with: xctest_lib, install: true)