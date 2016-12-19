//
//  SVR_NetworkMonitor.h
//
//  Created by Lutz  Thalmann on 14.04.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SystemConfiguration/SystemConfiguration.h>

@interface SVR_NetworkMonitor: NSObject {
}

+ (BOOL)reachabilityForHostName:(NSString *)hostName; 
+ (BOOL)reachabilityForAddress:(struct sockaddr*)hostAddress;
+ (BOOL)reachabilityForInternetConnection;
+ (BOOL)reachabilityForLocalWiFi;

@end
