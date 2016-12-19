//
//  SVR_NetworkMonitor.m
//
//  Created by Lutz  Thalmann on 14.04.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SVR_NetworkMonitor.h"
#import <sys/socket.h>
#import <netinet/in.h>

@implementation SVR_NetworkMonitor

+ (BOOL)reachabilityForHostName:(NSString *)hostName {
    // Part 1 - Create target in format need by SCNetwork
    SCNetworkReachabilityRef target = SCNetworkReachabilityCreateWithName(NULL, [hostName UTF8String]);
    // Part 2 - Get the flags
    SCNetworkReachabilityFlags flags;
    SCNetworkReachabilityGetFlags(target, &flags);
    CFRelease(target);
    //
    if (flags & kSCNetworkFlagsReachable) return YES;
    return NO;
}

+ (BOOL)reachabilityForAddress:(struct sockaddr *)hostAddress {
    // Part 1 - Create target in format need by SCNetwork
    SCNetworkReachabilityRef target = SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, (struct sockaddr *)hostAddress);
    // Part 2 - Get the flags
    SCNetworkReachabilityFlags flags;
    SCNetworkReachabilityGetFlags(target, &flags);
    CFRelease(target);
    //
    if (flags & kSCNetworkFlagsReachable) return YES;
    return NO;
}

+ (BOOL)reachabilityForInternetConnection {
    // Part 1 - Create Internet socket addr of zero
    struct sockaddr_in           zeroAddr;
    bzero(&zeroAddr,      sizeof(zeroAddr));
    zeroAddr.sin_len    = sizeof(zeroAddr);
    zeroAddr.sin_family = AF_INET;
    // Part 2 - Create target in format need by SCNetwork and Get the flags
    return [self reachabilityForAddress:(struct sockaddr *)&zeroAddr];
}

+ (BOOL)reachabilityForLocalWiFi {
    NSString *server = [[NSUserDefaults standardUserDefaults] stringForKey:@"HermesApp_SYSVAL_HOST"];
    // Part 1 - Create target in format need by SCNetwork
    SCNetworkReachabilityRef target;
    if (server && server.length > 0) {
        // use the server from the settings
        target = SCNetworkReachabilityCreateWithName(NULL, [server UTF8String]);
    } else {
        // use an internet socket addr of zero
        struct sockaddr_in           zeroAddr;
        bzero(&zeroAddr,      sizeof(zeroAddr));
        zeroAddr.sin_len    = sizeof(zeroAddr);
        zeroAddr.sin_family = AF_INET;
        target = SCNetworkReachabilityCreateWithAddress(NULL, (struct sockaddr *) &zeroAddr);
    }
    // Part 2 - Get the flags
    SCNetworkReachabilityFlags flags;
    SCNetworkReachabilityGetFlags(target, &flags);
    CFRelease(target);
    //
    if (!(flags & kSCNetworkFlagsReachable))       return NO;
    if (flags & kSCNetworkReachabilityFlagsIsWWAN) return NO;
    return YES;
}

@end