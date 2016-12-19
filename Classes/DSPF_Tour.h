//
//  DSPF_Tour.h
//  Hermes
//
//  Created by Lutz on 04.12.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "SVR_LocationManager.h"
#import "DSPF_Warning.h"
#import "DSPF_LocationInfo.h"
#import "DSPF_TourLocation.h"
#import "DSPF_TourStopTransportGroups.h"
#import "DSPF_TourMapAnnotation.h"

#import "Departure.h"

@interface DSPF_Tour : UITableViewController <NSFetchedResultsControllerDelegate, 
                                              MKMapViewDelegate, 
                                              DSPF_WarningDelegate,
                                              DSPF_LocationInfoDelegate,
                                              DSPF_TourLocationDelegate,
                                              DSPF_TourStopTransportGroupsDelegate> {
	SVR_LocationManager        *svr_LocationManager;
    NSString                   *subTitle;
    UITableView                *tableView;
    MKMapView                  *mapView;
    NSString                   *tourTask;
    BOOL				        showOptionalDepartures;
    
@private
	NSManagedObjectContext     *ctx;
    NSMutableArray             *tourMapPoints;
    BOOL                        tourMapPointsDidLoad;
	NSFetchedResultsController *tourDeparturesAtWork;
	MKPolyline                 *tourMapLines;
	DSPF_TourMapAnnotation     *pinForTruck;                                                  
}

@property (nonatomic, retain) SVR_LocationManager        *svr_LocationManager;
@property (nonatomic, retain) NSString                   *subTitle;
@property (nonatomic, retain) UITableView                *tableView;
@property (nonatomic, retain) MKMapView                  *mapView;
@property (nonatomic, retain) NSString                   *tourTask;
@property (nonatomic)		  BOOL				          showOptionalDepartures;

@property (nonatomic, retain) NSMutableArray			 *tourMapPoints;
@property (nonatomic)		  BOOL                        tourMapPointsDidLoad;
@property (nonatomic, retain) NSFetchedResultsController *tourDeparturesAtWork;
@property (nonatomic, retain) MKPolyline				 *tourMapLines;
@property (retain)			  DSPF_TourMapAnnotation	 *pinForTruck;

- (void)updatePinForTruck;

@end