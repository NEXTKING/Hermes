//
//  DSPF_TourMapAnnotation.m
//  Hermes
//
//  Created by Lutz on 05.12.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "DSPF_TourMapAnnotation.h"

@implementation DSPF_TourMapAnnotation

@synthesize coordinate;
@synthesize title;
@synthesize subtitle;
@synthesize item;

+ (DSPF_TourMapAnnotation *)annotationWithCoordinate:(CLLocationCoordinate2D)aCoordinate item:(NSObject *)aItem {
	return [[[self alloc] initWithCoordinate:aCoordinate item:aItem] autorelease];
}

+ (DSPF_TourMapAnnotation *)annotationWithCoordinate:(CLLocationCoordinate2D)aCoordinate item:(NSObject *)aItem title:(NSString *)aTitle {
	return [[[self alloc] initWithCoordinate:aCoordinate item:aItem title:aTitle] autorelease];
}

+ (DSPF_TourMapAnnotation *)annotationWithCoordinate:(CLLocationCoordinate2D)aCoordinate item:(NSObject *)aItem title:(NSString *)aTitle subtitle:(NSString *)aSubtitle {
	return [[[self alloc] initWithCoordinate:aCoordinate item:aItem title:aTitle subtitle:aSubtitle] autorelease];
}

- (id) initWithCoordinate:(CLLocationCoordinate2D)aCoordinate item:(NSObject *)aItem {
    self.coordinate = aCoordinate;
	self.item		= [aItem retain];
    return self;
}

- (id) initWithCoordinate:(CLLocationCoordinate2D)aCoordinate item:(NSObject *)aItem title:(NSString*)aTitle {
    self.coordinate = aCoordinate;
	self.item		= [aItem retain];
    self.title      = aTitle;
    return self;
}

- (id) initWithCoordinate:(CLLocationCoordinate2D)aCoordinate item:(NSObject *)aItem title:(NSString*)aTitle subtitle:(NSString*)aSubtitle {
    self.coordinate = aCoordinate;
	self.item		= [aItem retain];
    self.title      = aTitle;
    self.subtitle   = aSubtitle;
    return self;
}

-(void) dealloc {
    [title    release];
    [subtitle release];
	[item	  release];
    [super    dealloc];
}

@end