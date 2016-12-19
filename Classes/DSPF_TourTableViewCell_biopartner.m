//
//  DSPF_TourTableViewCell_biopartner.m
//  Hermes
//
//  Created by iLutz on 16.09.13.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DSPF_TourTableViewCell_biopartner.h"
#import "Location.h"
#import "Transport.h"
#import "Transport_Group.h"
#import "Tour_Exception.h"

@implementation DSPF_TourTableViewCell_biopartner

@synthesize tourDeparture;
@synthesize cityLabel;
@synthesize nameLabel;
@synthesize departureLabel;
@synthesize infoLabel;
@synthesize pickCountForTourLocation;
@synthesize unitCountForTourLocation;
@synthesize palletCountForTourLocation;
@synthesize hasPaymentOnDelivery;
@synthesize hasTransportGroupInfos;
@synthesize tourTask;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentView.backgroundColor = [[UIColor alloc] initWithRed:255.0 / 255 green:255.0 / 255 blue:255.0 / 255 alpha: 0.16];
        // Initialization code
        //      imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        //      imageView.contentMode = UIViewContentModeScaleAspectFit;
        //      [self.contentView addSubview:imageView];
        
        departureLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        departureLabel.backgroundColor = self.contentView.backgroundColor;
        [departureLabel setFont:[UIFont systemFontOfSize:14.0]];
        [departureLabel setTextColor:[UIColor darkGrayColor]];
        [departureLabel setHighlightedTextColor:[UIColor whiteColor]];
        departureLabel.minimumFontSize = 7.0;
        departureLabel.lineBreakMode = UILineBreakModeTailTruncation;
        [self.contentView addSubview:departureLabel];
        
        infoLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        infoLabel.backgroundColor = self.contentView.backgroundColor;
        [infoLabel setFont:[UIFont fontWithName:@"AppleColorEmoji" size:12.0]];
        [infoLabel setTextColor:[UIColor darkGrayColor]];
        [infoLabel setHighlightedTextColor:[UIColor whiteColor]];
        infoLabel.minimumFontSize = 7.0;
        infoLabel.lineBreakMode = UILineBreakModeTailTruncation;
        [self.contentView addSubview:infoLabel];
        
        nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        nameLabel.backgroundColor = self.contentView.backgroundColor;
        [nameLabel setFont:[UIFont  fontWithName:@"Helvetica-Bold" size:14]];
        [nameLabel setTextColor:[UIColor darkGrayColor]];
        [nameLabel setHighlightedTextColor:[UIColor whiteColor]];
        nameLabel.minimumFontSize = 8.0;
        nameLabel.lineBreakMode = UILineBreakModeTailTruncation;
        [self.contentView addSubview:nameLabel];
        
        cityLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        cityLabel.backgroundColor = self.contentView.backgroundColor;
        [cityLabel setFont:[UIFont  fontWithName:@"Helvetica-Bold" size:16]];
        [cityLabel setTextColor:[UIColor blackColor]];
        [cityLabel setHighlightedTextColor:[UIColor whiteColor]];
        cityLabel.minimumFontSize = 8.0;
        cityLabel.lineBreakMode = UILineBreakModeTailTruncation;
        [self.contentView addSubview:cityLabel];
    }
    return self;
}

#pragma mark - Laying out subviews

#define TEXT_LEFT_MARGIN    8.0
#define TEXT_RIGHT_MARGIN   34.0

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [cityLabel setFrame:
     CGRectMake(TEXT_LEFT_MARGIN,  
                3.0, 
                [self.cityLabel.text sizeWithFont:self.cityLabel.font].width, 
                [self.cityLabel.text sizeWithFont:self.cityLabel.font].height)];
    [nameLabel setFrame:
     CGRectMake(2 * TEXT_LEFT_MARGIN + [self.cityLabel.text sizeWithFont:self.cityLabel.font].width, 
                3.0, 
                self.frame.size.width 
                - (2 * TEXT_LEFT_MARGIN + [self.cityLabel.text sizeWithFont:self.cityLabel.font].width)
                - TEXT_RIGHT_MARGIN,
                [self.nameLabel.text sizeWithFont:self.nameLabel.font].height)];
    [departureLabel setFrame:
     CGRectMake(TEXT_LEFT_MARGIN, 
                24.0, 
                [self.departureLabel.text sizeWithFont:self.departureLabel.font].width, 
                [self.departureLabel.text sizeWithFont:self.departureLabel.font].height)];
    [infoLabel setFrame:
     CGRectMake(2 * TEXT_LEFT_MARGIN + [self.departureLabel.text sizeWithFont:self.departureLabel.font].width, 
                26.0,
                [self.infoLabel.text sizeWithFont:self.infoLabel.font].width, 
                [self.infoLabel.text sizeWithFont:self.infoLabel.font].height)];
}

#pragma mark - Departure set accessor

- (void)setTourDeparture:(Departure *)newDeparture {
    if (newDeparture != tourDeparture) {
        tourDeparture = newDeparture;
    }
    BOOL hasTourExceptionForToday = NO;
    self.nameLabel.text = [NSString stringWithFormat:@"%@", self.tourDeparture.location_id.location_name];
    self.cityLabel.text = [NSString stringWithFormat:@"%@:", self.tourDeparture.location_id.city ]; 
    if ([self.tourDeparture.canceled boolValue]) { 
        departureLabel.text = @"⚠ ❌";
    } else { 
        Tour_Exception *todaysTourException = [Tour_Exception todaysTourExceptionForLocation:self.tourDeparture.location_id];
        if (todaysTourException) {
            hasTourExceptionForToday = YES;
        }
        if (todaysTourException &&
            ![self.tourDeparture.confirmed boolValue]) {
            departureLabel.text = [NSString stringWithFormat:@"⚠ %@", todaysTourException.tour_exception_reason];
        } else {
            if (self.tourDeparture.departure) {
                departureLabel.text = [NSString stringWithFormat:@"🕑 %@ %@", [NSDateFormatter localizedStringFromDate:self.tourDeparture.departure
                                                                                                              dateStyle:NSDateFormatterNoStyle 
                                                                                                              timeStyle:NSDateFormatterShortStyle],
                                       NSLocalizedString(@"MESSAGE__103", @"Uhr")];
            } else if (self.tourDeparture.arrival) { 
                departureLabel.text = [NSString stringWithFormat:@"🕙 %@ %@", [NSDateFormatter localizedStringFromDate:self.tourDeparture.arrival
                                                                                                              dateStyle:NSDateFormatterNoStyle 
                                                                                                              timeStyle:NSDateFormatterShortStyle],
                                       NSLocalizedString(@"MESSAGE__103", @"Uhr")];
            } else if (self.tourDeparture.location_id.code && self.tourDeparture.location_id.code.length > 0) {
                departureLabel.text = [NSString stringWithFormat:@"📝 %@", self.tourDeparture.location_id.code];
            } else if (self.tourDeparture.location_id.location_code && self.tourDeparture.location_id.location_code.length > 0) {
                departureLabel.text = [NSString stringWithFormat:@"📝 %@", self.tourDeparture.location_id.location_code];
            } else if (self.tourDeparture.transport_group_id.task && self.tourDeparture.transport_group_id.task.length > 0) {
                departureLabel.text = [NSString stringWithFormat:@"📝 %@", self.tourDeparture.transport_group_id.task];
            } else {
                departureLabel.text = [NSString stringWithFormat:@"📝 %@", self.tourDeparture.departure_id];
            }
        }
    }
    if ([self.tourDeparture.currentTourStatus intValue] < 50) { 
        if ((self.pickCountForTourLocation + self.unitCountForTourLocation + self.palletCountForTourLocation) != 0
            || [self.tourTask isEqualToString:TourTaskLoadingOnly]) {
            BOOL demoMode = PFCurrentModeIsDemo();
            NSMutableString *infoSigns = [NSMutableString string];
            [infoSigns appendString:@""];
            if ([self.tourTask isEqualToString:TourTaskLoadingOnly]) {
                for (NSString *sign in [Transport allInfoSigns]) {
                    if (demoMode || [Transport hasStagingInfo:sign
                                                  forLocation:self.tourDeparture.location_id.location_id
                                               transportGroup:self.tourDeparture.transport_group_id.transport_group_id inCtx:self.tourDeparture.managedObjectContext])
                    {
                        [infoSigns appendString:@"🚩"];
                    } else {
                        [infoSigns appendString:@" "];
                    }
                }
            } else {
                for (NSString *sign in [Transport allInfoSigns]) {
                    if (demoMode || [Transport hasStagingInfo:sign
                                                   toLocation:self.tourDeparture.location_id.location_id
                                               transportGroup:self.tourDeparture.transport_group_id.transport_group_id inCtx:self.tourDeparture.managedObjectContext])
                    {
                        [infoSigns appendString:@"🚩"];
                    } else {
                        [infoSigns appendString:@" "];
                    }
                }
            }
            [infoSigns appendString:@" "];
            if (self.hasPaymentOnDelivery)   [infoSigns appendFormat:@" %@", @"💰"];
            if (self.hasTransportGroupInfos) [infoSigns appendFormat:@" %@", @"📲"];
            if ([self.tourTask isEqualToString:TourTaskLoadingOnly]) {
                self.infoLabel.text = [NSString stringWithFormat:@"📦%2i %@",
                                       self.unitCountForTourLocation,
                                       infoSigns];
            } else {
                self.infoLabel.text = [NSString stringWithFormat:@"📦%2i %@",
                                       self.unitCountForTourLocation + self.palletCountForTourLocation,
                                       infoSigns];
            }
        } else if (self.hasTransportGroupInfos) {
            self.infoLabel.text = @"📲";
        } else {
            self.infoLabel.text = nil;
        }
    } else {
        self.infoLabel.text = [NSString stringWithFormat:@"☑ %@", self.tourDeparture.location_id.street];
    }
    if (hasTourExceptionForToday) {
        cityLabel.textColor      = [UIColor grayColor];
        nameLabel.textColor      = [UIColor lightGrayColor];
        departureLabel.textColor = [UIColor blueColor];
        infoLabel.textColor      = [UIColor blueColor];
    } else if (([self.tourDeparture.currentTourStatus intValue] == 20 && [self.tourTask isEqualToString:TourTaskLoadingOnly]) || 
               [self.tourDeparture.currentTourStatus intValue] == 50) { 
        cityLabel.textColor      = [[UIColor alloc] initWithRed:0.0 / 255 green:128.0 / 255 blue:64.0 / 255 alpha: 1.0];
        nameLabel.textColor      = [[UIColor alloc] initWithRed:0.0 / 255 green:128.0 / 255 blue:64.0 / 255 alpha: 0.9];
        departureLabel.textColor = [[UIColor alloc] initWithRed:0.0 / 255 green:128.0 / 255 blue:64.0 / 255 alpha: 0.8];
        infoLabel.textColor      = [[UIColor alloc] initWithRed:0.0 / 255 green:128.0 / 255 blue:64.0 / 255 alpha: 0.8];
    } else  if (([self.tourDeparture.currentTourStatus intValue] == 15 && [self.tourTask isEqualToString:TourTaskLoadingOnly]) ||
                [self.tourDeparture.currentTourStatus intValue] == 45) { 
        cityLabel.textColor      = [[UIColor alloc] initWithRed:232.0 / 255 green:31.0 / 255 blue:23.0 / 255 alpha: 1.0];
        nameLabel.textColor      = [[UIColor alloc] initWithRed:232.0 / 255 green:31.0 / 255 blue:23.0 / 255 alpha: 0.9];
        departureLabel.textColor = [[UIColor alloc] initWithRed:232.0 / 255 green:31.0 / 255 blue:23.0 / 255 alpha: 0.8];
        infoLabel.textColor      = [[UIColor alloc] initWithRed:232.0 / 255 green:31.0 / 255 blue:23.0 / 255 alpha: 0.8];
    } else  if (([self.tourDeparture.currentTourStatus intValue] == 30 && [self.tourTask isEqualToString:TourTaskLoadingOnly]) ||
                [self.tourDeparture.currentTourStatus intValue] == 60) { 
        cityLabel.textColor      = [UIColor grayColor];
        nameLabel.textColor      = [UIColor lightGrayColor];
        departureLabel.textColor = [UIColor lightGrayColor];
        infoLabel.textColor      = [UIColor lightGrayColor];
    } else { 
        cityLabel.textColor      = [UIColor blackColor];
        nameLabel.textColor      = [UIColor darkGrayColor];
        if ([self.tourDeparture.onDemand boolValue]) {
            departureLabel.textColor = [[UIColor alloc] initWithRed:255.0 / 255 green:128.0 / 255 blue:0.0 / 255 alpha: 1.0];
            infoLabel.textColor      = [[UIColor alloc] initWithRed:255.0 / 255 green:128.0 / 255 blue:0.0 / 255 alpha: 1.0];
        } else { 
            departureLabel.textColor = [UIColor grayColor];
            infoLabel.textColor      = [UIColor grayColor];
        }
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}


@end