//
//  SVR_GoogleFetcher.m
//
//  Created by Lutz  Thalmann on 08.04.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SVR_GoogleFetcher.h"
#import "DSPF_TourMapAnnotation.h"
#import "JSON.h"

@implementation SVR_GoogleFetcher

+ (NSDictionary *)googleQuery:(NSString *)queryString {
    NSString *urlString = [NSString stringWithFormat:@"http://maps.google.com/maps/api/directions/json?%@&mode=driving&sensor=true", queryString];
//  NSLog(@"%@", urlString);
    NSData   *jsonData  = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlString]];
//  NSLog(@"%@", jsonData);
    if (jsonData) {
        return [[[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding] autorelease] JSONValue];
    }
    return nil;
}

+ (NSMutableArray *) decodePolyline:(NSString *)encodedPoints { 
    NSString *escapedEncodedPoints;
    if (NO) {
    /* Only for escapedEncodedPoints e.g. string from javascript */ 
        escapedEncodedPoints = [encodedPoints stringByReplacingOccurrencesOfString:@"\\\\" withString:@"\\" 
                                                                           options:NSLiteralSearch
                                                                             range:NSMakeRange(0, [encodedPoints length])];
    } else { 
    /* This string is from Objective-C */
        escapedEncodedPoints = encodedPoints;
    }
    NSInteger len = [escapedEncodedPoints length];
    NSMutableArray *waypoints = [[NSMutableArray alloc] init];
    NSInteger index = 0;
    NSInteger lat   = 0;
    NSInteger lng   = 0;
    
    while (index < len) {
        NSInteger b;
        NSInteger shift = 0;
        NSInteger result = 0;
        
        do {
            b = [escapedEncodedPoints characterAtIndex:index++] - 63;
            result |= (b & 0x1f) << shift;
            shift += 5;
        } while (b >= 0x20); 
        NSInteger dlat = ((result & 1) ? ~(result >> 1) : (result >> 1));
        lat    += dlat;
        
        shift = 0;
        result = 0;
        do {
            b = [escapedEncodedPoints characterAtIndex:index++] - 63;
            result |= (b & 0x1f) << shift;
            shift += 5;
        } while (b >= 0x20);        
        NSInteger dlng = ((result & 1) ? ~(result >> 1) : (result >> 1));
        lng    += dlng;
        
        [waypoints addObject:[NSArray arrayWithObjects:[NSNumber numberWithFloat: lat * 1e-5],
                                                       [NSNumber numberWithFloat: lng * 1e-5],
                                                        nil]];
    }
    return [waypoints autorelease];
}

+ (NSMutableArray *)googlePolylineFrom:(CLLocationCoordinate2D )fromCoordinate withMapPoints:(NSArray *)mapPoints { 
    NSUInteger maxIndex  = [mapPoints count];
    if        (maxIndex < 1) {
                return nil;
    }
    NSUInteger       tmpIndex  = 0;
    NSMutableString *wayPoints = [[NSMutableString alloc] init];
	for (DSPF_TourMapAnnotation *aMapAnnotation in [mapPoints objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, (maxIndex - 1))]]) {
        if ([wayPoints length]) {
            [wayPoints appendFormat:@"%@%f,%f", @"%7C", aMapAnnotation.coordinate.latitude, aMapAnnotation.coordinate.longitude];
        } else {
            [wayPoints appendFormat:@"&waypoints=optimize:false%@%f,%f", @"%7C", aMapAnnotation.coordinate.latitude, aMapAnnotation.coordinate.longitude];
        }
        if (tmpIndex == 7) {
            break;
        } else {
            tmpIndex ++;
        }
	}
	NSDictionary *googleQueryResults = [self googleQuery:[NSString stringWithFormat:@"origin=%f,%f&destination=%f,%f%@",
                                                          fromCoordinate.latitude, 
                                                          fromCoordinate.longitude, 
                                                          ((DSPF_TourMapAnnotation *)[mapPoints lastObject]).coordinate.latitude,
                                                          ((DSPF_TourMapAnnotation *)[mapPoints lastObject]).coordinate.longitude,
                                                          [wayPoints autorelease]]];
    if (![[googleQueryResults objectForKey:@"routes"] lastObject]) {
        return nil;
    }
	return [self decodePolyline:[[[[googleQueryResults objectForKey:@"routes"] objectAtIndex:0] objectForKey:@"overview_polyline"] valueForKey:@"points"]];
}

+ (NSMutableArray *)googlePolylineWithMapPoints:(NSArray *)mapPoints {
    NSUInteger maxIndex = [mapPoints count];
    if        (maxIndex < 2) {
                return nil;
    }
    NSUInteger       tmpIndex  = 0;
    NSMutableString *wayPoints = [[NSMutableString alloc] init];
	for (DSPF_TourMapAnnotation *aMapAnnotation in [mapPoints objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, (maxIndex - 2))]]) {
        if ([wayPoints length]) {
            [wayPoints appendFormat:@"%@%f,%f", @"%7C", aMapAnnotation.coordinate.latitude, aMapAnnotation.coordinate.longitude];
        } else {
            [wayPoints appendFormat:@"&waypoints=optimize:false%@%f,%f", @"%7C", aMapAnnotation.coordinate.latitude, aMapAnnotation.coordinate.longitude];
        }
        if (tmpIndex == 7) {
            break;
        } else {
            tmpIndex ++;
        }
	}
	NSDictionary *googleQueryResults = [self googleQuery:[NSString stringWithFormat:@"origin=%f,%f&destination=%f,%f%@",
                                                          ((DSPF_TourMapAnnotation *)[mapPoints objectAtIndex:0]).coordinate.latitude,
                                                          ((DSPF_TourMapAnnotation *)[mapPoints objectAtIndex:0]).coordinate.longitude, 
                                                          ((DSPF_TourMapAnnotation *)[mapPoints lastObject]).coordinate.latitude,
                                                          ((DSPF_TourMapAnnotation *)[mapPoints lastObject]).coordinate.longitude,
                                                          [wayPoints autorelease]]];
    if (![[googleQueryResults objectForKey:@"routes"] lastObject]) {
        return nil;
    }
	return [self decodePolyline:[[[[googleQueryResults objectForKey:@"routes"] objectAtIndex:0] objectForKey:@"overview_polyline"] valueForKey:@"points"]];
}

@end