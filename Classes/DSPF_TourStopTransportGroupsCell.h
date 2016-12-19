//
//  DSPF_TourStopTransportGroupsCell.h
//  Hermes
//
//  Created by iLutz on 06.10.14.
//  Copyright 2014 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Transport_Group.h"
#import "Departure.h"

@interface DSPF_TourStopTransportGroupsCell : UITableViewCell {
    Transport_Group     *transportGroup;
    Departure           *transportGroupTourStop;
    UILabel             *task_documentLabel;
    UILabel             *cityLabel;
    UILabel             *streetLabel;
    UILabel             *nameLabel;
    UILabel             *departureLabel;
    UILabel             *for_cityLabel;
    UILabel             *for_nameLabel;
    UILabel             *infoLabel;
    NSString            *tourTask;
}

@property (nonatomic, strong) Transport_Group     *transportGroup;
@property (nonatomic, strong) Departure           *transportGroupTourStop;
@property (nonatomic, strong) UILabel             *task_documentLabel;
@property (nonatomic, strong) UILabel             *cityLabel;
@property (nonatomic, strong) UILabel             *streetLabel;
@property (nonatomic, strong) UILabel             *nameLabel;
@property (nonatomic, strong) UILabel             *departureLabel;
@property (nonatomic, strong) UILabel             *for_cityLabel;
@property (nonatomic, strong) UILabel             *for_nameLabel;
@property (nonatomic, strong) UILabel             *infoLabel;
@property (nonatomic, strong) NSString            *tourTask;

@end
