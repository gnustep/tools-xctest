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

#import <Foundation/Foundation.h>
#import <XCTest/GSXCTestRunner.h>
#include <stdio.h>

static const char *usage = "Usage: xctest [-XCTest Class[.method][,...]] "
    "[-only-testing:Target[/Class[/method]]] [-skip-testing:Target[/Class[/method]]] "
    "test-bundle-path";

// Splits an Apple test identifier, Target[/Class[/method]], into its parts.
static NSArray *IdentifierParts(NSString *identifier)
{
    NSArray *parts = [identifier componentsSeparatedByString:@"/"];
    return [parts count] <= 3 && ![parts containsObject:@""] ? parts : nil;
}

// The runner's name for the tests an identifier selects, or nil for the whole target.
static NSString *RunnerName(NSArray *parts)
{
    if ([parts count] == 1) return nil;
    if ([parts count] == 2) return [parts objectAtIndex:1];
    return [NSString stringWithFormat:@"%@.%@", [parts objectAtIndex:1], [parts objectAtIndex:2]];
}

int main(int argc, char *argv[])
{
    @autoreleasepool {
        NSMutableArray *filters = [NSMutableArray array];
        NSMutableArray *only = [NSMutableArray array], *skip = [NSMutableArray array];
        NSString *path = nil;
        BOOL invalid = NO;
        for (int i = 1; i < argc; i++) {
            NSString *arg = [NSString stringWithUTF8String:argv[i]];
            if ([arg isEqual:@"--help"] || [arg isEqual:@"-h"]) {
                puts(usage);
                return 0;
            }
            if ([arg isEqual:@"-XCTest"]) {
                if (++i == argc) { invalid = YES; break; }
                [filters addObjectsFromArray:[[NSString stringWithUTF8String:argv[i]] componentsSeparatedByString:@","]];
            } else if ([arg hasPrefix:@"-only-testing:"] || [arg hasPrefix:@"-skip-testing:"]) {
                NSRange colon = [arg rangeOfString:@":"];
                NSArray *parts = IdentifierParts([arg substringFromIndex:NSMaxRange(colon)]);
                if (!parts) {
                    fprintf(stderr, "xctest: Invalid test identifier in %s, expected Target[/Class[/method]]\n", argv[i]);
                    invalid = YES;
                } else {
                    [[arg hasPrefix:@"-only-testing:"] ? only : skip addObject:parts];
                }
            } else if ([arg hasPrefix:@"-"] || path) {
                invalid = YES;
            } else {
                path = arg;
            }
        }
        if (invalid || !path) {
            fprintf(stderr, "%s\n", usage);
            return 1;
        }
        @try {
            path = [path stringByStandardizingPath];
            if (![path isAbsolutePath]) path = [[[NSFileManager defaultManager] currentDirectoryPath] stringByAppendingPathComponent:path];
            NSBundle *bundle = [NSBundle bundleWithPath:path];
            if (!bundle || ![bundle load]) {
                NSLog(@"XCTest: Could not load test bundle at %@", path);
                return 1;
            }
            // Apple's identifiers name the target, which is the bundle's name.
            NSString *target = [[path lastPathComponent] stringByDeletingPathExtension];
            BOOL all = NO;
            for (NSArray *parts in only) {
                if (![[parts objectAtIndex:0] isEqual:target]) {
                    NSLog(@"XCTest: -only-testing names target %@, but this bundle is %@", [parts objectAtIndex:0], target);
                    return 1;
                }
                NSString *name = RunnerName(parts);
                if (name) [filters addObject:name]; else all = YES;
            }
            NSMutableArray *skipped = [NSMutableArray array];
            for (NSArray *parts in skip) {
                if (![[parts objectAtIndex:0] isEqual:target]) continue;
                NSString *name = RunnerName(parts);
                if (!name) {
                    NSLog(@"XCTest: -skip-testing:%@ skips every test, so none executed", target);
                    return 1;
                }
                [skipped addObject:name];
            }
            NSArray *selection = [filters count] && !all ? filters : nil;
            if ([filters count] == 1 && [[filters objectAtIndex:0] isEqual:@"All"]) selection = nil;
            return [[GSXCTestRunner sharedRunner] runTestsNamed:selection skipping:skipped] ? 0 : 1;
        }
        @catch (id exception) {
            NSLog(@"XCTest: Could not run test bundle: %@", exception);
            return 1;
        }
    }
}
