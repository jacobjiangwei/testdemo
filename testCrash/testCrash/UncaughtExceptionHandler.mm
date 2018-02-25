//
//  UncaughtExceptionHandler.m
//  UncaughtExceptions
//
//  Created by Matt Gallagher on 2010/05/25.
//  Copyright 2010 Matt Gallagher. All rights reserved.
//
//  Permission is given to use this source code file, free of charge, in any
//  project, commercial or otherwise, entirely at your risk, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in compiled projects is
//  appreciated but not required.
//

#import "UncaughtExceptionHandler.h"
#include <libkern/OSAtomic.h>
#include <execinfo.h>
#include <string>
#include <signal.h>
using namespace std;
 

volatile int32_t UncaughtExceptionCount = 0;
const int32_t UncaughtExceptionMaximum = 10;
typedef void (*signal_handler)(int n,struct __siginfo *siginfo,void *myact);
static signal_handler s_sigkill_handler = nullptr;
static signal_handler s_sigabrt_handler = nullptr;
static signal_handler s_sigsegv_handler = nullptr;
static signal_handler s_sigfpe_handler = nullptr;
static signal_handler s_sigbus_handler = nullptr;
static signal_handler s_sigtrap_handler = nullptr;
static NSUncaughtExceptionHandler * s_oldExceptionHandler = nullptr;

static void DumpCrashLog(NSArray *callStack, int signal)
{
    
    std::string backtrace_string;
    if(signal != -1)
    {
        char buf[255] = {};
        snprintf(buf, sizeof(buf), "Crash,Signal=%d,backtrace:\n", signal);
        backtrace_string.append(buf);
    }
    else
    {
        backtrace_string.append("Uncaught Exception found, backtrace:\n");
    }
    
    for(id obj in callStack)
    {
        NSString* str = (NSString*)obj;
        backtrace_string.append([str UTF8String]);
        backtrace_string.append("\n");
    }
    NSString * docURL = [[[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject] absoluteString];
    NSString * fileUrl = [[docURL stringByAppendingString:@"crash.log"] stringByReplacingOccurrencesOfString:@"file://" withString:@""];
    NSString * result = [[NSString alloc]initWithCString:backtrace_string.c_str() encoding:NSUTF8StringEncoding];
    [result writeToFile:fileUrl atomically:YES encoding:NSUTF8StringEncoding error:nil];
//    ELOG("crash", backtrace_string);
//
//    glip_mobile::OutputWritter::sharedInstance()->flushAndClose();
//    std::string oldLogFileName = glip_mobile::OutputWritter::sharedInstance()->getLogFileName();
//    std::string newLogFileName = oldLogFileName;
//    auto pos = newLogFileName.rfind('.');
//    if(pos == -1) {
//        newLogFileName.append("_crash");
//    } else {
//        newLogFileName.insert(pos, "_crash");
//    }
//
//    rename(oldLogFileName.c_str(), newLogFileName.c_str());
}

static void HandleException(NSException *exception)
{
    auto exception_name_str = [exception name];
    auto exception_reason_str = [exception reason];
    std::string exception_name;
    std::string exception_reason;
    if(exception_name_str) {
        exception_name = [exception_name_str UTF8String];
    }
    
    if(exception_reason_str) {
        exception_reason = [exception_reason_str UTF8String];
    }
//    DLOG("crash", "uncought exception found, name=", exception_name, ",reason:", exception_reason);
    NSSetUncaughtExceptionHandler(s_oldExceptionHandler);
    int32_t exceptionCount = OSAtomicIncrement32(&UncaughtExceptionCount);
    if (exceptionCount > UncaughtExceptionMaximum)
    {
        return;
    }
    
    NSMutableArray *callStack = [exception callStackSymbols];
//    [callStack addObjectsFromArray:[exception callStackReturnAddresses]];
    DumpCrashLog(callStack, -1);
    [exception raise];
}

static void register_handler(int signal_no, signal_handler handler, signal_handler* old_handler) {
    struct sigaction act = {};
    struct sigaction old = {};
    sigemptyset(&act.sa_mask);
    act.sa_flags= SA_SIGINFO;
    act.sa_sigaction = handler;
    sigaction(signal_no, &act, &old);
    
    if(old_handler) {
        *old_handler = old.sa_sigaction;
    }
}

static void SignalHandler(int n,struct __siginfo *siginfo,void *myact)
{
    // restore signal process
    //sa_sigaction(
    register_handler(SIGABRT, s_sigabrt_handler, nullptr);
    register_handler(SIGKILL, s_sigkill_handler, nullptr);
    register_handler(SIGSEGV, s_sigsegv_handler, nullptr);
    register_handler(SIGFPE, s_sigfpe_handler, nullptr);
    register_handler(SIGBUS, s_sigbus_handler, nullptr);
    register_handler(SIGTRAP, s_sigtrap_handler, nullptr);
    
    signal_handler old_handler = nullptr;
    
    // print log
    NSArray *callStack = [NSThread callStackSymbols];
    DumpCrashLog(callStack, n);
    
    switch(n) {
        case SIGABRT:
            old_handler = s_sigabrt_handler;
            break;
        case SIGKILL:
            old_handler = s_sigkill_handler;
            break;
        case SIGSEGV:
            old_handler = s_sigsegv_handler;
            break;
        case SIGFPE:
            old_handler = s_sigfpe_handler;
            break;
        case SIGBUS:
            old_handler = s_sigbus_handler;
            break;
        case SIGTRAP:
            old_handler = s_sigtrap_handler;
            break;
    }
    
    if(old_handler) {
        old_handler(n, siginfo, myact);
    }
}

void InstallUncaughtExceptionHandler()
{
    //return;
    s_oldExceptionHandler = NSGetUncaughtExceptionHandler();
    NSSetUncaughtExceptionHandler(&HandleException);
    
    register_handler(SIGABRT, SignalHandler, &s_sigabrt_handler);
    register_handler(SIGKILL, SignalHandler, &s_sigkill_handler);
    register_handler(SIGSEGV, SignalHandler, &s_sigsegv_handler);
    register_handler(SIGFPE, SignalHandler, &s_sigfpe_handler);
    register_handler(SIGBUS, SignalHandler, &s_sigbus_handler);
    register_handler(SIGTRAP, SignalHandler, &s_sigtrap_handler);
    signal(SIGPIPE, SIG_IGN);
}

