
#import <XCTest/XCTestAssertions.h>
#import <GSXCTestRunner.h>

@implementation _XCTestCaseInterruptionException
@end

@interface GSXCTestRunner (GSPrivate)
- (void)registerAssertionFailed;
@end

void _XCTFailureHandler(XCTestCase *test, BOOL expected, const char *filePath, NSUInteger lineNumber, NSString *condition, NSString *format, ...)
{
    NSString *message = nil;
    
    if ([format length] > 0) {
        va_list args;
        va_start(args, format);
        message = [[[NSString alloc] initWithFormat:format arguments:args] autorelease];
        va_end(args);
    }
    
    _XCTPreformattedFailureHandler(test, expected, [NSString stringWithUTF8String:filePath], lineNumber, condition, message);
}

void _XCTPreformattedFailureHandler(XCTestCase *test, BOOL expected, NSString *filePath, NSUInteger lineNumber, NSString *condition, NSString *message)
{
    NSLog(@"XCTest:     Assertion FAILED at %@:%lu, %@%@", 
        filePath, 
        (unsigned long)lineNumber, 
        condition, 
        ([message length] > 0 ? [NSString stringWithFormat:@": %@", message] : @""));
    
    [[GSXCTestRunner sharedRunner] registerAssertionFailed];
}

NSString * _XCTFailureFormat (_XCTAssertionType assertionType, NSUInteger formatIndex)
{
    switch (assertionType) {
        case _XCTAssertion_Nil:
            return @"expected nil value";
        case _XCTAssertion_NotNil:
            return @"expected non-nil value";
        default:
            return @"assertion failed";
    }
}

NSString * _XCTDescriptionForValue (NSValue *value)
{
    return [value description];
}

