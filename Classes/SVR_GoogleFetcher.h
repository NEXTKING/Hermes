//
//  SVR_GoogleFetcher.h
//
//  Created by Lutz  Thalmann on 08.04.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
//  http://code.google.com/intl/de-DE/apis/maps/documentation/directions/#RequestParameters
 

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface SVR_GoogleFetcher : NSObject

+ (NSMutableArray *)googlePolylineFrom:(CLLocationCoordinate2D )fromCoordinate withMapPoints:(NSArray *)mapPoints;
+ (NSMutableArray *)googlePolylineWithMapPoints:(NSArray *)mapPoints;

@end
