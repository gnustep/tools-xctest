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
