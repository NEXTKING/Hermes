//
//  SVR_LocationManager.h
//  Hermes
//
//  Created by Lutz  Thalmann on 15.12.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface SVR_LocationManager : NSObject <CLLocationManagerDelegate> {
    CLLocation        *rcvLocation;
	BOOL               isRunning;
    
@private
    CLLocationManager *locationManager;
    NSInteger          numberOfErrors;
}

@property (nonatomic, retain)           CLLocation        *rcvLocation;
@property (nonatomic, readonly)         BOOL               isRunning;

@end
