//
//  DPHUpdatesChecker.m
//  dphHermes
//
//  Created by Tomasz Krasnyk on 02.11.15.
//
//

#import "DPHUpdatesChecker.h"

@implementation DPHUpdatesChecker {
    NSMutableData *plistData;
}
@synthesize URLToApplicationPlist;

- (instancetype)initWithURLToApplicationPlist:(NSString *) url {
    self = [super init];
    if (self) {
        URLToApplicationPlist = url;
    }
    return self;
}

#pragma mark -

+ (BOOL) isVersion:(NSString *)version1 newerThan:(NSString *) version2 {
    BOOL result = NO;
    NSComparisonResult r = [version1 compare:version2 options:NSNumericSearch];
    if (r == NSOrderedDescending) {
        result = YES;
    }
    return result;
}

- (void)checkForApplicationUpdates {
    if (PFDeviceIsSimulator()) {
        return;
    }
    
    if ([UIApplication sharedApplication].applicationIconBadgeNumber == 0) {
        if (plistData == nil) {
            plistData = [[NSMutableData alloc] init];
            NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:URLToApplicationPlist] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:60];
            NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
            [connection start];
            
        }
    }
}

- (void) connection:(NSURLConnection *)connection didFinishLoadingWithError:(NSError *) errorOrNil {
    NSAssert([NSThread currentThread] == [NSThread mainThread], @"Oops, the connection callbacks are not running in the main thread!");
    if (errorOrNil == nil) {
        NSError *error = nil;
        NSString *filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"LastUpdateChecked.plist"];
        if ([plistData writeToFile:filePath options:NSDataWritingAtomic error:&error]) {
            NSDictionary *plist = [[NSDictionary alloc] initWithContentsOfFile:filePath];
            NSString *tmpVersionCheck = [[[[plist valueForKey:@"items"] lastObject] valueForKey:@"metadata"] valueForKey:@"bundle-version"];
            if (tmpVersionCheck) {
                if ([DPHUpdatesChecker isVersion:tmpVersionCheck newerThan:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]]) {
                    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:1];
                }
            }
        } else {
            NSLog(@"Could not write downloaded plist data to file: %@, reason: %@", filePath, error);
        }
    } else {
        NSLog(@"Could not download %@, reason: %@", [[connection currentRequest] URL], errorOrNil);
    }
    
    plistData = nil;
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [self connection:connection didFinishLoadingWithError:error];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [self connection:connection didFinishLoadingWithError:nil];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [plistData appendData:data];
}


@end
