//
//  DSPF_TourMapAnnotation.h
//  Hermes
//
//  Created by Lutz on 05.12.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface DSPF_TourMapAnnotation : NSObject <MKAnnotation>  { 

@private
    NSString               *title;
    NSString               *subtitle;
    CLLocationCoordinate2D coordinate;
	NSObject			   *item;
}

+ (DSPF_TourMapAnnotation *)annotationWithCoordinate:(CLLocationCoordinate2D)coordinate item:(NSObject *)aItem;
+ (DSPF_TourMapAnnotation *)annotationWithCoordinate:(CLLocationCoordinate2D)coordinate item:(NSObject *)aItem title:(NSString *)aTitle;
+ (DSPF_TourMapAnnotation *)annotationWithCoordinate:(CLLocationCoordinate2D)coordinate item:(NSObject *)aItem title:(NSString *)aTitle subtitle:(NSString *)aSubtitle;

@property (nonatomic, copy)   NSString               *title;
@property (nonatomic, copy)   NSString               *subtitle;
@property (nonatomic)         CLLocationCoordinate2D  coordinate;
@property (nonatomic, retain) NSObject               *item;

- (id) initWithCoordinate:(CLLocationCoordinate2D)coordinate item:(NSObject *)aItem;
- (id) initWithCoordinate:(CLLocationCoordinate2D)coordinate item:(NSObject *)aItem title:(NSString *)aTitle;
- (id) initWithCoordinate:(CLLocationCoordinate2D)coordinate item:(NSObject *)aItem title:(NSString *)aTitle subtitle:(NSString *)aSubtitle;

@end
