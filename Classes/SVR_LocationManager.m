//
//  SVR_LocationManager.m
//  Hermes
//
//  Created by Lutz  Thalmann on 15.12.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "HermesAppDelegate.h"
#import "SVR_LocationManager.h"
#import "DSPF_Error.h"

@implementation SVR_LocationManager
@synthesize rcvLocation;
@synthesize isRunning;

- (id) init {
    self = [super init];
    if (self != nil) {
        locationManager = [[CLLocationManager alloc] init];
        locationManager.delegate		= self; // send loc updates to myself
        locationManager.purpose         = NSLocalizedString(@"TITLE_066", @"Finden der Haltestellen auf der Tour");
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
        
        CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
        if (status == kCLAuthorizationStatusRestricted || status == kCLAuthorizationStatusDenied) {
            NSError *error = [NSError errorWithDomain:@"Dataphone" code:kCLErrorDenied userInfo:nil];
            [self locationManager:locationManager didFailWithError:error];
        } else if (status == kCLAuthorizationStatusNotDetermined && PFOsVersionCompareGE(@"8.0")) {
            [locationManager performSelector:NSSelectorFromString(@"requestWhenInUseAuthorization") withObject:nil];
        } else {
            [self startUpdatingLocation];
        }
    }
    return self;
}

- (void) startUpdatingLocation {
    [locationManager startUpdatingLocation];
    [(HermesAppDelegate *)[[UIApplication sharedApplication] delegate] setLocationServicesProblemIndicatorVisible:NO];
}

// iOS >= 6.0
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    isRunning        = YES;
    if ([locations count] > 0) {
        self.rcvLocation = [locations lastObject]; // the most current location is last in the array
    }
}

- (void)locationManager:(CLLocationManager *)manager didFinishDeferredUpdatesWithError:(NSError *)error {
    [self locationManager:manager didFailWithError:error];
}

- (void) locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if (status == kCLAuthorizationStatusRestricted || status == kCLAuthorizationStatusDenied) {
        NSError *error = [NSError errorWithDomain:@"Dataphone" code:kCLErrorDenied userInfo:nil];
        [self locationManager:locationManager didFailWithError:error];
    } else {
        [self startUpdatingLocation];
    }
}

// iOS < 6.0
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
	isRunning        = YES;
	self.rcvLocation = newLocation;
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error { 
    isRunning = NO;
    [manager stopUpdatingLocation];
    switch([error code]) {
            
        case kCLErrorDenied:
            if (!PFBrandingSupported(BrandingTechnopark, nil))
                [DSPF_Error messageTitle:NSLocalizedString(@"TITLE_067", @"Finden der Haltestellen")
                         messageText:NSLocalizedString(@"ERROR_MESSAGE_024", @"Die Ortungsdienste sind nicht freigegeben. Dadurch sind aktuell nicht alle Funktionen nutzbar.") 
                            delegate:self];
            break;
            
        default:
            if([[error userInfo] objectForKey:NSDetailedErrorsKey]) {
                for(NSError* detailedError in [[error userInfo] objectForKey:NSDetailedErrorsKey]) {
                    NSLog(@"SVR_LocationManager: %@", [detailedError userInfo]);
                }
            } else {
                NSLog(@"SVR_LocationManager: %@, %@", error, [error userInfo]);
            }
            numberOfErrors ++;
            if (numberOfErrors < 16) {
                [self performSelector:@selector(startUpdatingLocation) withObject:nil afterDelay:arc4random() % 3];
            } else if (numberOfErrors == 16) { 
                [(HermesAppDelegate *)[[UIApplication sharedApplication] delegate] setLocationServicesProblemIndicatorVisible:YES];
            }
            break;
    }
} 

- (void)dealloc {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [locationManager stopUpdatingLocation];
    [locationManager release];
    [rcvLocation     release];
    [super dealloc];
}

@end