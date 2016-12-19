//
//  DSPF_TourTableViewCell_CCC.h
//  Hermes
//
//  Created by iLutz on 05.03.15.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Departure.h"

@interface DSPF_TourTableViewCell_CCC : UITableViewCell {
    Departure *tourDeparture;
    UILabel   *cityLabel;
    UILabel   *nameLabel;
    UILabel   *departureLabel;
    UILabel   *infoLabel;
    NSInteger  pickCountForTourLocation;
    NSInteger  unitCountForTourLocation;
    NSInteger  palletCountForTourLocation;
    BOOL       hasPaymentOnDelivery;
    BOOL       hasTransportGroupInfos;
    NSString  *tourTask;
}

@property (nonatomic, strong) Departure     *tourDeparture;
@property (nonatomic, strong) UILabel       *cityLabel;
@property (nonatomic, strong) UILabel       *nameLabel;
@property (nonatomic, strong) UILabel       *departureLabel;
@property (nonatomic, strong) UILabel       *infoLabel;
@property (nonatomic)         NSInteger      pickCountForTourLocation;
@property (nonatomic)         NSInteger      unitCountForTourLocation;
@property (nonatomic)         NSInteger      palletCountForTourLocation;
@property (nonatomic)         BOOL           hasPaymentOnDelivery;
@property (nonatomic)         BOOL           hasTransportGroupInfos;
@property (nonatomic, strong) NSString      *tourTask;

@end
