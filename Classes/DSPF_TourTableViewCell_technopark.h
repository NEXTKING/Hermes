//
//  DSPF_TourTableViewCell_technopark.h
//  dphHermes
//
//  Created by Denis Kurochkin on 02.11.15.
//
//

#import <UIKit/UIKit.h>
#import "Departure.h"

@interface DSPF_TourTableViewCell_technopark : UITableViewCell


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


@property (retain, nonatomic) IBOutlet UILabel *addressLabel;
@property (retain, nonatomic) IBOutlet UIView *containerView;
@property (retain, nonatomic) IBOutlet UILabel *departureHoursLabel;
@property (retain, nonatomic) IBOutlet UILabel *departureMinutesLabel;
@property (retain, nonatomic) IBOutlet UILabel *arrivalMinutesLabel;
@property (retain, nonatomic) IBOutlet UILabel *arrivalHoursLabel;
@property (retain, nonatomic) IBOutlet UILabel *dashLabel;



@end
