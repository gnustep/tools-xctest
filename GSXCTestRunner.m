//
//  GSXCTestRunner.m
//  Eggplant
//
//  Created by Adam Fox on 9/17/18.
//  Copyright © 2018 TestPlant, Inc. All rights reserved.
//
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


#import <GSXCTestRunner.h>
#import <XCTest/XCTestCase.h>

#import <objc/runtime.h>

// From: https://www.cocoawithlove.com/2010/01/getting-subclasses-of-objective-c-class.html
NSArray *ClassGetSubclasses(Class parentClass)
{
    int numClasses = objc_getClassList(NULL, 0);
    Class *classes = NULL;

    classes = malloc(sizeof(Class) * numClasses);
    numClasses = objc_getClassList(classes, numClasses);
    
    NSMutableArray *result = [NSMutableArray array];
    for (NSInteger i = 0; i < numClasses; i++)
    {
        Class superClass = classes[i];
        do
        {
            superClass = class_getSuperclass(superClass);
        } while(superClass && superClass != parentClass);
        
        if (superClass == nil)
        {
            continue;
        }
        
        [result addObject:classes[i]];
    }

    free(classes);
    
    return result;
}

@implementation GSXCTestRunner

- (id)init
{
    self = [super init];
    if (self) {
        runLock = [[NSLock alloc] init];
    }
    
    return self;
}

- (void)dealloc
{
    [runLock release];
    [super dealloc];
}

- (BOOL)runAll
{
    return [self runTestsNamed:nil];
}

- (BOOL)runTestsNamed:(NSArray *)testNames
{
    [runLock lock];
    
    NSLog(@"XCTest: Running Unit Tests");
    NSUInteger testCaseFailureCount = 0;
    NSUInteger testCaseSuccessCount = 0;
    
    NSArray *testCaseClasses = ClassGetSubclasses([XCTestCase class]);
    for (Class testCaseClass in testCaseClasses)
    {
        @autoreleasepool {
            BOOL classNamePrinted = NO;
            NSString *className = NSStringFromClass(testCaseClass);
            
            unsigned int methodCount = 0;
            NSUInteger methodFailureCount = 0;
            NSUInteger methodSuccessCount = 0;
            Method *methods = class_copyMethodList(testCaseClass, &methodCount);
        
            for (unsigned int i = 0; i < methodCount; i++) {
                Method method = methods[i];
        
                SEL selector = method_getName(method);
                NSString *methodName = [NSString stringWithUTF8String:sel_getName(selector)];
                
                BOOL testIsEnabled = YES;
                if (testNames) {
                    testIsEnabled = NO; // default to disabled when tests are specified
                    for (NSString *s in testNames)
                    {
                        NSArray *tuple = [s componentsSeparatedByString:@"."];
                        
                        // match ClassName.methodName
                        if (tuple.count == 2) {
                            if ([className isEqualToString:[tuple objectAtIndex:0]] &&
                                [methodName isEqualToString:[tuple objectAtIndex:1]])
                            {
                                testIsEnabled = YES;
                                break;
                            }
                            
                            // match ClassName (run all tests in the class)
                        } else if (tuple.count == 1) {
                            if ([className isEqualToString:[tuple objectAtIndex:0]])
                            {
                                testIsEnabled = YES;
                                break;
                            }
                        }
                    }
                }
                
                if ([methodName hasPrefix:@"test"]
                    && method_getNumberOfArguments(method) == 2
                    && testIsEnabled)
                {
                    IMP testFunction = method_getImplementation(method);
                    if (testFunction) {
                        BOOL testSucceeded = YES;
                        
                        if (!classNamePrinted) {
                            NSLog(@"XCTest:   Running %@", className);
                            classNamePrinted = YES;
                        }
                        
                        NSLog(@"XCTest:     %@...", methodName);
                        
                        NS_DURING {
                            @autoreleasepool {
                                XCTestCase *testCase = [[[testCaseClass alloc] init] autorelease];
                                assertionFailureCount = 0;
                                [testCase setUp];
                                testFunction(testCase, selector);
                                [testCase tearDown];
                                if (assertionFailureCount > 0) {
                                    testSucceeded = NO;
                                    NSLog(@"XCTest:     %@ FAILED", methodName);
                                }
                            }
                        }
                        NS_HANDLER {
                            testSucceeded = NO;
                            NSLog(@"XCTest:     %@ FAILED, threw exception: %@", methodName, localException);
                        }
                        NS_ENDHANDLER
                        
                        if (testSucceeded)
                            methodSuccessCount++;
                        else
                            methodFailureCount++;
                    }
                }
            }
        
            free(methods);
            
            if (methodFailureCount == 0 && methodSuccessCount == 0) {
                NSLog(@"XCTest:   %@ SKIPPED", className);
            }
            else if (methodFailureCount > 0) {
                testCaseFailureCount++;
                NSLog(@"XCTest:   %@: %lu/%lu tests FAILED", className, methodFailureCount, methodFailureCount + methodSuccessCount);
            } else {
                testCaseSuccessCount++;
                if (methodSuccessCount > 0) {
                    NSLog(@"XCTest:   %@: %lu tests PASSED", className, methodSuccessCount);
                }
            }
        } // @autoreleasepool
    }
    
    if (testCaseSuccessCount == 0 && testCaseFailureCount == 0) {
        NSLog(@"XCTest: No tests found.");
    }
    else if (testCaseFailureCount > 0) {
        NSLog(@"XCTest: %lu/%lu test cases FAILED", testCaseFailureCount, testCaseFailureCount + testCaseSuccessCount);
    } else {
        NSLog(@"XCTest: %lu tests PASSED", testCaseSuccessCount);
    }
    
    [runLock unlock];
    
    return testCaseFailureCount == 0;
}

- (void)waitForCompletion
{
    [runLock lock];
    [runLock unlock];
}

- (void)registerAssertionFailed
{
    @synchronized (self) {
        assertionFailureCount++;
    }
}

+ (GSXCTestRunner *)sharedRunner
{
    static GSXCTestRunner *runner = nil;
    if (!runner) {
        runner = [[GSXCTestRunner alloc] init];
    }
    
    return runner;
}

@end
