//
//  test.h
//  testCrash
//
//  Created by Jacob Jiang on 2/23/18.
//  Copyright © 2018 Jacob Jiang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TestCrash : NSObject


+(TestCrash *)shared;
-(void) start ;
-(void)cppTest;
@end
