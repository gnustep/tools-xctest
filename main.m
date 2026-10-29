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

int main(int argc, char *argv[])
{
    @autoreleasepool {
        NSMutableArray *filters = [NSMutableArray array];
        NSString *path = nil;
        BOOL invalid = NO;
        for (int i = 1; i < argc; i++) {
            NSString *arg = [NSString stringWithUTF8String:argv[i]];
            if ([arg isEqual:@"--help"] || [arg isEqual:@"-h"]) {
                puts("Usage: xctest [-XCTest Class[/method][,...]] test-bundle-path");
                return 0;
            }
            if ([arg isEqual:@"-XCTest"]) {
                if (++i == argc) { invalid = YES; break; }
                [filters addObjectsFromArray:[[NSString stringWithUTF8String:argv[i]] componentsSeparatedByString:@","]];
            } else if ([arg hasPrefix:@"-"] || path) {
                invalid = YES;
            } else {
                path = arg;
            }
        }
        if (invalid || !path) {
            fprintf(stderr, "Usage: xctest [-XCTest Class[/method][,...]] test-bundle-path\n");
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
            NSArray *selection = [filters count] ? filters : nil;
            if ([filters count] == 1 && [[filters objectAtIndex:0] isEqual:@"All"]) selection = nil;
            return [[GSXCTestRunner sharedRunner] runTestsNamed:selection] ? 0 : 1;
        }
        @catch (id exception) {
            NSLog(@"XCTest: Could not run test bundle: %@", exception);
            return 1;
        }
    }
}
