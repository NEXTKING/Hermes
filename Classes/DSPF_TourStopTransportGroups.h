//
//  DSPF_TourStopTransportGroups.h
//  Hermes
//
//  Created by Lutz on 03.10.14.
//  Copyright 2014 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DSPF_Warning.h"
#import "DSPF_LocationInfo.h"
#import "DSPF_TourLocation.h"

#import "Departure.h"

@protocol DSPF_TourStopTransportGroupsDelegate;

@interface DSPF_TourStopTransportGroups : UITableViewController <DSPF_WarningDelegate,
                                                                 DSPF_LocationInfoDelegate,
                                                                 DSPF_TourLocationDelegate> {
    id                         <DSPF_TourStopTransportGroupsDelegate> delegate;
    UITableView                *tableView;
    NSString                   *tourTask;
    BOOL				        showOptionalTransport_Groups;
    Departure                  *departure;
    BOOL                        isFirstTourDeparture;
    BOOL                        isLastTourDeparture;
    
@private
    NSArray                    *transportGroups;
    NSString                   *subTitle;
    BOOL                        didItOnce;
    BOOL                        toolbarHiddenBackup;
    BOOL                        hidesBackButton;
}

@property (assign)              id                         <DSPF_TourStopTransportGroupsDelegate> delegate;
@property (nonatomic, retain)   NSString                   *subTitle;
@property (nonatomic, retain)   UITableView                *tableView;
@property (nonatomic, retain)   NSString                   *tourTask;
@property (nonatomic)           BOOL				        showOptionalTransport_Groups;
@property (nonatomic, retain)   Departure                  *departure;
@property (nonatomic)           BOOL				        isFirstTourDeparture;
@property (nonatomic)           BOOL				        isLastTourDeparture;

@property (nonatomic, retain)   NSArray                    *transportGroups;
@property (nonatomic)           BOOL                        didItOnce;
@property (nonatomic)           BOOL                        toolbarHiddenBackup;
@property (nonatomic)           BOOL                        hidesBackButton;

@end

@protocol DSPF_TourStopTransportGroupsDelegate

- (void) dspf_TourStopTransportGroups:(DSPF_TourStopTransportGroups *)sender didFinishTourStopForItem:(id )item;

@end