//
//  test.m
//  testCrash
//
//  Created by Jacob Jiang on 2/23/18.
//  Copyright © 2018 Jacob Jiang. All rights reserved.
//

#import "TestCrash.h"
#import "UncaughtExceptionHandler.h"
#include "crash.hpp"
static TestCrash * instance = nil;

@implementation TestCrash

+(TestCrash *)shared {
    if (instance == nil) {
        instance = [[TestCrash alloc] init];
    }
    return instance;
};

-(void) start
{
    InstallUncaughtExceptionHandler();
};

-(void)cppTest
{
    CPPCrash *d = new CPPCrash();
    d->crash();
};

@end
