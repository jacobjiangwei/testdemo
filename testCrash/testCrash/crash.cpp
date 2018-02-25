//
//  crash.cpp
//  testCrash
//
//  Created by Jacob Jiang on 2/24/18.
//  Copyright © 2018 Jacob Jiang. All rights reserved.
//

#include "crash.hpp"


CPPCrash::CPPCrash()
{
    
}

void CPPCrash::crash() {
    int* a = nullptr;
    *a = 4;
 }
