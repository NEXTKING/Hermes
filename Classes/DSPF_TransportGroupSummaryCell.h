//
//  DSPF_TransportGroupSummaryCell.h
//  Hermes
//
//  Created by iLutz on 06.10.14.
//  Copyright 2014 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Transport_Group.h"

@interface DSPF_TransportGroupSummaryCell : UITableViewCell {
    Transport_Group     *transportGroup;
    NSDictionary        *transportGroupSummary;
    UILabel             *qtyLabel;
    UILabel             *itemLabel;
    UILabel             *weightLabel;
    UILabel             *temperatureLabel;
}

@property (nonatomic, strong) Transport_Group     *transportGroup;
@property (nonatomic, strong) NSDictionary        *transportGroupSummary;
@property (nonatomic, strong) UILabel             *qtyLabel;
@property (nonatomic, strong) UILabel             *itemLabel;
@property (nonatomic, strong) UILabel             *weightLabel;
@property (nonatomic, strong) UILabel             *temperatureLabel;

@end
