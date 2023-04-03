/*
 This file is part of the GNUstep XCTEST Library.

 This library is free software; you can redistribute it and/or
 modify it under the terms of the GNU Lesser General Public
 License as published by the Free Software Foundation; either
 version 2 of the License, or (at your option) any later version.

 This library is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.     See the GNU
 Lesser General Public License for more details.

 You should have received a copy of the GNU Lesser General Public
 License along with this library; see the file COPYING.LIB.
 If not, see <http://www.gnu.org/licenses/> or write to the
 Free Software Foundation, 51 Franklin Street, Fifth Floor,
 Boston, MA 02110-1301, USA.
*/

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

