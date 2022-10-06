#import <Foundation/Foundation.h>
#import "GSXCTestRunner.h"

int main(int argc, char *argv[]) {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    if (argc == 1) {
        NSLog(@"Usage: xctest [test bundle path]");
        return 1;
    }
    
    NSString *testBundlePath = [NSString stringWithUTF8String: argv[1]];
    NSURL *testBundleUrl = [NSURL fileURLWithPath: testBundlePath];
    NSBundle *testBundle = [NSBundle bundleWithURL: testBundleUrl];
    [testBundle load];

    BOOL result = [[GSXCTestRunner sharedRunner] runAll];
    [pool release];
    return result == YES ? 0 : 1;
}