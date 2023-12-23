//
//  GSXCTestRunner.h
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

#import <Foundation/Foundation.h>

@interface GSXCTestRunner : NSObject {
    NSUInteger assertionFailureCount;
    NSLock *runLock;
}

- (BOOL)runAll;
- (BOOL)runTestsNamed:(NSArray *)testNames; // nil for all tests

- (void)waitForCompletion;

+ (GSXCTestRunner *)sharedRunner;

@end
