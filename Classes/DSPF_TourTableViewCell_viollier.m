//
//  DSPF_TourTableViewCell_viollier.m
//  Hermes
//
//  Created by iLutz on 31.05.13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "DSPF_TourTableViewCell_viollier.h"
#import "Location.h"
#import "Transport_Group.h"
#import "Tour_Exception.h"

@implementation DSPF_TourTableViewCell_viollier

@synthesize tourDeparture;
@synthesize cityLabel;
@synthesize streetLabel;
@synthesize nameView;
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
        self.layer.backgroundColor = [[[UIColor alloc] initWithRed:14.0 / 255 green:81.0 / 255 blue:141.0 / 255 alpha: 0.75] CGColor];
        self.layer.borderColor = [[[UIColor alloc] initWithRed:14.0 / 255 green:81.0 / 255 blue:141.0 / 255 alpha: 0.75] CGColor];
        self.layer.borderWidth  = 2.0;
        self.layer.cornerRadius = 5.0;
        // Initialization code
        //      imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        //      imageView.contentMode = UIViewContentModeScaleAspectFit;
        //      [self.contentView addSubview:imageView];
        
        departureLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        departureLabel.backgroundColor = self.contentView.backgroundColor;
        [departureLabel setFont:[UIFont fontWithName:@"HelveticaNeue-CondensedBold" size:15]];
        [departureLabel setTextColor:[UIColor darkGrayColor]];
        [departureLabel setHighlightedTextColor:[UIColor whiteColor]];
        departureLabel.minimumFontSize = 7.0;
        departureLabel.lineBreakMode = UILineBreakModeTailTruncation;
        [self.contentView addSubview:departureLabel];
        
        infoLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        infoLabel.backgroundColor = self.contentView.backgroundColor;
        [infoLabel setFont:[UIFont fontWithName:@"HelveticaNeue-CondensedBold" size:15]];
        [infoLabel setTextColor:[UIColor darkGrayColor]];
        [infoLabel setHighlightedTextColor:[UIColor whiteColor]];
        infoLabel.minimumFontSize = 7.0;
        infoLabel.lineBreakMode = UILineBreakModeTailTruncation;
        [self.contentView addSubview:infoLabel];

        nameView = [[UIView alloc] initWithFrame:CGRectZero];
        nameView.backgroundColor   = [UIColor clearColor];
        nameView.layer.borderColor = [[[UIColor alloc] initWithRed:14.0 / 255 green:81.0 / 255 blue:141.0 / 255 alpha: 0.75] CGColor];
        nameView.layer.borderWidth  = 2.0;
        nameView.layer.cornerRadius = 5.0;
        
        nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        nameLabel.backgroundColor = [UIColor clearColor];
        [nameLabel setFont:[UIFont  fontWithName:@"HelveticaNeue-CondensedBold" size:15]];
        [nameLabel setTextColor:[UIColor whiteColor]];
        [nameLabel setHighlightedTextColor:[UIColor whiteColor]];
        nameLabel.minimumFontSize = 8.0;
        nameLabel.lineBreakMode = UILineBreakModeWordWrap;
        nameLabel.numberOfLines = 2.0;
        nameLabel.textAlignment = UITextAlignmentCenter;
        nameLabel.shadowColor = [UIColor darkGrayColor];
        nameLabel.shadowOffset = CGSizeMake(1.0, -1.0);
        [nameView         addSubview:nameLabel];
        [self.contentView addSubview:nameView];
        
        cityLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        cityLabel.backgroundColor = self.contentView.backgroundColor;
        [cityLabel setFont:[UIFont  fontWithName:@"HelveticaNeue-CondensedBold" size:17]];
        [cityLabel setTextColor:[UIColor blackColor]];
        [cityLabel setHighlightedTextColor:[UIColor whiteColor]];
        cityLabel.minimumFontSize = 8.0;
        cityLabel.lineBreakMode = UILineBreakModeTailTruncation;
        cityLabel.baselineAdjustment = UIBaselineAdjustmentAlignBaselines;
        [self.contentView addSubview:cityLabel];
        
        streetLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        streetLabel.backgroundColor = self.contentView.backgroundColor;
        [streetLabel setFont:[UIFont  fontWithName:@"HelveticaNeue-CondensedBold" size:15]];
        [streetLabel setTextColor:[UIColor darkGrayColor]];
        [streetLabel setHighlightedTextColor:[UIColor whiteColor]];
        streetLabel.minimumFontSize = 8.0;
        streetLabel.lineBreakMode = UILineBreakModeMiddleTruncation;
        streetLabel.baselineAdjustment = UIBaselineAdjustmentAlignBaselines;
        [self.contentView addSubview:streetLabel];
    }
    return self;
}

#pragma mark - Laying out subviews

#define TEXT_LEFT_MARGIN    8.0
#define TEXT_RIGHT_MARGIN   39.0

- (void)layoutSubviews {
    [super layoutSubviews];
//
// Line 1: departureLabel | infoLabel
    [departureLabel setFrame:
     CGRectMake(TEXT_LEFT_MARGIN,
                3.0,
                [self.departureLabel.text sizeWithFont:self.departureLabel.font].width,
                [@"anyText" sizeWithFont:self.departureLabel.font].height)];
    [infoLabel setFrame:
     CGRectMake(2 * TEXT_LEFT_MARGIN + departureLabel.frame.size.width,
                3.0,
                self.frame.size.width - 2 * TEXT_LEFT_MARGIN - TEXT_RIGHT_MARGIN
                - departureLabel.frame.size.width,
                [@"anyText" sizeWithFont:self.departureLabel.font].height)];
//
// Line 2: nameLabel
    [nameView setFrame:
     CGRectMake(TEXT_LEFT_MARGIN,
                23,
                self.frame.size.width
                - TEXT_LEFT_MARGIN
                - TEXT_RIGHT_MARGIN,
                3 + 2 * [@"anyText" sizeWithFont:self.nameLabel.font].height)];
    if (nameView.layer.sublayers.count > 1) {
        [[nameView.layer.sublayers objectAtIndex:0] removeFromSuperlayer];
    }
    if (nameView.layer.sublayers.count == 1) {
        CAGradientLayer *nameViewGradientLayer = [CAGradientLayer layer];
        nameViewGradientLayer.frame = CGRectMake(TEXT_LEFT_MARGIN,
                                                 23,
                                                 self.frame.size.width
                                                 - TEXT_LEFT_MARGIN
                                                 - TEXT_RIGHT_MARGIN,
                                                 3 + 2 * [@"anyText" sizeWithFont:self.nameLabel.font].height);
        nameViewGradientLayer.cornerRadius = nameView.layer.cornerRadius;
        // setting our colors - since this is a mask the color itself is irrelevant
        //                   - all that matters is the alpha.
        // A clear color will completely hide the masked layer, an alpha of 1.0 will completely show the masked layer.
        BOOL hasInfoMessage = NO;
        if (self.tourDeparture.infoMessage &&
            self.tourDeparture.infoMessage.length > 0 &&
            self.tourDeparture.infoMessageDate) {
            NSDate *date = [DPHDateFormatter dateFromString:[NSUserDefaults currentStintStart]
                                              withDateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterMediumStyle locale:[NSLocale currentLocale]];
            NSInteger tmpInterval_1 = [self.tourDeparture.infoMessageDate timeIntervalSinceNow];
            NSInteger tmpInterval_2 = [self.tourDeparture.infoMessageDate timeIntervalSinceDate:date];
            if ((tmpInterval_1 / 86400) == 0 || (tmpInterval_2 / 86400) == 0) {
                hasInfoMessage = YES;
            }
        }
        if (self.accessoryView) {
            nameViewGradientLayer.colors = [NSArray arrayWithObjects:
                                            (id)[[[UIColor alloc] initWithRed:10.0 / 255 green:139.0 / 255 blue:181.0 / 255 alpha: 0.0] CGColor],
                                            (id)[[[UIColor alloc] initWithRed:10.0 / 255 green:139.0 / 255 blue:181.0 / 255 alpha: 0.3] CGColor],
                                            (id)[[[UIColor alloc] initWithRed:10.0 / 255 green:139.0 / 255 blue:181.0 / 255 alpha: 0.5] CGColor],
                                            (id)[[[UIColor alloc] initWithRed:10.0 / 255 green:139.0 / 255 blue:181.0 / 255 alpha: 0.7] CGColor],
                                            (id)[[[UIColor alloc] initWithRed:10.0 / 255 green:139.0 / 255 blue:181.0 / 255 alpha: 0.8] CGColor],
                                            (id)[[[UIColor alloc] initWithRed:10.0 / 255 green:139.0 / 255 blue:181.0 / 255 alpha: 0.9] CGColor],
                                            (id)[[[UIColor alloc] initWithRed:10.0 / 255 green:139.0 / 255 blue:181.0 / 255 alpha: 0.9] CGColor],
                                            (id)[[[UIColor alloc] initWithRed:10.0 / 255 green:139.0 / 255 blue:181.0 / 255 alpha: 1.0] CGColor],
                                            (id)[[[UIColor alloc] initWithRed:10.0 / 255 green:139.0 / 255 blue:181.0 / 255 alpha: 1.0] CGColor],
                                            (id)[[[UIColor alloc] initWithRed:10.0 / 255 green:139.0 / 255 blue:181.0 / 255 alpha: 1.0] CGColor],
                                            (id)[[[UIColor alloc] initWithRed:10.0 / 255 green:139.0 / 255 blue:181.0 / 255 alpha: 1.0] CGColor],
                                            (id)[[[UIColor alloc] initWithRed:10.0 / 255 green:139.0 / 255 blue:181.0 / 255 alpha: 1.0] CGColor],
                                            nil];
        } else if (hasInfoMessage) {
            nameViewGradientLayer.colors = [NSArray arrayWithObjects:
                                            (id)[[[UIColor alloc] initWithRed:192.0 / 255 green:192.0 / 255 blue:0.0 / 255 alpha: 0.0] CGColor],
                                            (id)[[[UIColor alloc] initWithRed:192.0 / 255 green:192.0 / 255 blue:0.0 / 255 alpha: 0.3] CGColor],
                                            (id)[[[UIColor alloc] initWithRed:192.0 / 255 green:192.0 / 255 blue:0.0 / 255 alpha: 0.5] CGColor],
                                            (id)[[[UIColor alloc] initWithRed:192.0 / 255 green:192.0 / 255 blue:0.0 / 255 alpha: 0.7] CGColor],
                                            (id)[[[UIColor alloc] initWithRed:192.0 / 255 green:192.0 / 255 blue:0.0 / 255 alpha: 0.8] CGColor],
                                            (id)[[[UIColor alloc] initWithRed:192.0 / 255 green:192.0 / 255 blue:0.0 / 255 alpha: 0.9] CGColor],
                                            (id)[[[UIColor alloc] initWithRed:192.0 / 255 green:192.0 / 255 blue:0.0 / 255 alpha: 0.9] CGColor],
                                            (id)[[[UIColor alloc] initWithRed:192.0 / 255 green:192.0 / 255 blue:0.0 / 255 alpha: 1.0] CGColor],
                                            (id)[[[UIColor alloc] initWithRed:192.0 / 255 green:192.0 / 255 blue:0.0 / 255 alpha: 1.0] CGColor],
                                            (id)[[[UIColor alloc] initWithRed:192.0 / 255 green:192.0 / 255 blue:0.0 / 255 alpha: 1.0] CGColor],
                                            (id)[[[UIColor alloc] initWithRed:192.0 / 255 green:192.0 / 255 blue:0.0 / 255 alpha: 1.0] CGColor],
                                            (id)[[[UIColor alloc] initWithRed:192.0 / 255 green:192.0 / 255 blue:0.0 / 255 alpha: 1.0] CGColor],
                                            nil];
        } else {
            nameViewGradientLayer.colors = [NSArray arrayWithObjects:
                                            (id)[[[UIColor alloc] initWithRed:14.0 / 255 green:81.0 / 255 blue:141.0 / 255 alpha: 0.0] CGColor],
                                            (id)[[UIColor colorWithWhite:0.25 alpha: 0.3] CGColor],
                                            (id)[[UIColor colorWithWhite:0.25 alpha: 0.5] CGColor],
                                            (id)[[UIColor colorWithWhite:0.25 alpha: 0.7] CGColor],
                                            (id)[[UIColor colorWithWhite:0.25 alpha: 0.8] CGColor],
                                            (id)[[UIColor colorWithWhite:0.25 alpha: 0.9] CGColor],
                                            (id)[[UIColor colorWithWhite:0.25 alpha: 0.9] CGColor],
                                            (id)[[UIColor colorWithWhite:0.25 alpha: 1.0] CGColor],
                                            (id)[[UIColor colorWithWhite:0.25 alpha: 1.0] CGColor],
                                            (id)[[UIColor colorWithWhite:0.25 alpha: 1.0] CGColor],
                                            (id)[[UIColor colorWithWhite:0.25 alpha: 1.0] CGColor],
                                            (id)[[UIColor colorWithWhite:0.25 alpha: 1.0] CGColor],
                                            nil];
        }
        nameViewGradientLayer.frame = nameView.layer.bounds;
        [nameView.layer insertSublayer:nameViewGradientLayer atIndex:0];
    }
    [nameLabel setFrame:
     CGRectMake(5,
                1,
                nameView.frame.size.width  - 10,
                nameView.frame.size.height - 2)];
//
// Line 3: cityLabel | streetLabel
    [cityLabel setFrame:
     CGRectMake(TEXT_LEFT_MARGIN,
                66.0,
                [self.cityLabel.text sizeWithFont:self.cityLabel.font].width,
                [@"anyText"   sizeWithFont:self.cityLabel.font].height)];
    [streetLabel setFrame:
     CGRectMake(2 * TEXT_LEFT_MARGIN + cityLabel.frame.size.width,
                66.0 + cityLabel.frame.size.height - [@"anyText" sizeWithFont:self.streetLabel.font].height,
                self.frame.size.width - 2 * TEXT_LEFT_MARGIN - TEXT_RIGHT_MARGIN
                - cityLabel.frame.size.width,
                [@"anyText"   sizeWithFont:self.streetLabel.font].height)];
}

#pragma mark - Departure set accessor

- (void)setTourDeparture:(Departure *)newDeparture {
    if (newDeparture != tourDeparture) {
        tourDeparture = newDeparture;
    }
    BOOL hasEraseFlag = NO;
    BOOL hasTourExceptionForToday = NO;
    self.nameLabel.text   = [NSString stringWithFormat:@"%@", self.tourDeparture.location_id.location_name];
    self.cityLabel.text   = [NSString stringWithFormat:@"%@", self.tourDeparture.location_id.city];
    self.streetLabel.text = [NSString stringWithFormat:@"%@", self.tourDeparture.location_id.street];
    if ([self.tourDeparture.canceled boolValue]) { 
        departureLabel.text = @"⚠ ❌";
    } else {
        if (self.tourDeparture.location_id.erase_flag) {
            hasEraseFlag = YES;
            departureLabel.text = [NSString stringWithFormat:@"⚠ %@", NSLocalizedString(@"MESSAGE_042", @"Kunde gelöscht")];
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
                                                                                                                  timeStyle:NSDateFormatterShortStyle], NSLocalizedString(@"MESSAGE__103", @"Uhr")];
                } else if (self.tourDeparture.location_id.location_code && self.tourDeparture.location_id.location_code.length > 0) {
                    departureLabel.text = [NSString stringWithFormat:@"📝 %@", self.tourDeparture.location_id.location_code];
                } else if (self.tourDeparture.transport_group_id.task && self.tourDeparture.transport_group_id.task.length > 0) {
                    departureLabel.text = [NSString stringWithFormat:@"📝 %@", self.tourDeparture.transport_group_id.task];
                } else {
                    departureLabel.text = [NSString stringWithFormat:@"📝 %@", self.tourDeparture.departure_id];
                }
            }
        }
    }
    if ((self.pickCountForTourLocation + self.unitCountForTourLocation + self.palletCountForTourLocation) != 0) {
        NSMutableString *infoSigns = [NSMutableString string];
        if (self.hasPaymentOnDelivery)   [infoSigns appendFormat:@" %@", @"💰"];
        if (self.hasTransportGroupInfos) [infoSigns appendFormat:@" %@", @"📲"];
        self.infoLabel.text = [NSString stringWithFormat:@"⬆ %i  ⬇ %i ▫ %i ☐ %@",
                               self.pickCountForTourLocation,
                               self.unitCountForTourLocation,
                               self.palletCountForTourLocation,
                               infoSigns];
    } else if (self.hasTransportGroupInfos) {
        self.infoLabel.text = @"📲";
    } else {
        self.infoLabel.text = @"";
    }
    if ([self.tourDeparture.currentTourStatus intValue] >= 50) {
        self.infoLabel.text = [NSString stringWithFormat:@"☑ %@", self.infoLabel.text];
    }
    if (hasEraseFlag) {
        cityLabel.textColor      = [UIColor grayColor];
        streetLabel.textColor    = [UIColor lightGrayColor];
        nameLabel.textColor      = [UIColor lightGrayColor];
        nameLabel.shadowColor    = [UIColor blackColor];
        departureLabel.textColor = [[UIColor alloc] initWithRed:232.0 / 255 green:31.0 / 255 blue:23.0 / 255 alpha: 1.0];
        infoLabel.textColor      = [[UIColor alloc] initWithRed:232.0 / 255 green:31.0 / 255 blue:23.0 / 255 alpha: 1.0];
    } else if (hasTourExceptionForToday) {
        cityLabel.textColor      = [UIColor grayColor];
        streetLabel.textColor    = [UIColor lightGrayColor];
        nameLabel.textColor      = [UIColor lightGrayColor];
        nameLabel.shadowColor    = [UIColor blackColor];
        departureLabel.textColor = [UIColor blueColor];
        infoLabel.textColor      = [UIColor blueColor];
    } else if (([self.tourDeparture.currentTourStatus intValue] == 20 && [self.tourTask isEqualToString:TourTaskLoadingOnly]) || 
               [self.tourDeparture.currentTourStatus intValue] == 50) { 
        cityLabel.textColor      = [[UIColor alloc] initWithRed:0.0 / 255 green:128.0 / 255 blue:64.0 / 255 alpha: 1.0];
        streetLabel.textColor    = [[UIColor alloc] initWithRed:0.0 / 255 green:128.0 / 255 blue:64.0 / 255 alpha: 0.9];
        nameLabel.textColor      = [[UIColor alloc] initWithRed:0.0 / 255 green:128.0 / 255 blue:64.0 / 255 alpha: 0.9];
        float h, s, b, a;
        if ([nameLabel.textColor getHue:&h saturation:&s brightness:&b alpha:&a])
            nameLabel.textColor  = [UIColor colorWithHue:h saturation:s brightness:MIN(b * 2.0, 1.0) alpha:a];
        nameLabel.shadowColor    = [UIColor blackColor];
        departureLabel.textColor = [[UIColor alloc] initWithRed:0.0 / 255 green:128.0 / 255 blue:64.0 / 255 alpha: 1.0];
        infoLabel.textColor      = [[UIColor alloc] initWithRed:0.0 / 255 green:128.0 / 255 blue:64.0 / 255 alpha: 0.9];
    } else  if (([self.tourDeparture.currentTourStatus intValue] == 15 && [self.tourTask isEqualToString:TourTaskLoadingOnly]) ||
                [self.tourDeparture.currentTourStatus intValue] == 45) { 
        cityLabel.textColor      = [[UIColor alloc] initWithRed:232.0 / 255 green:31.0 / 255 blue:23.0 / 255 alpha: 1.0];
        streetLabel.textColor    = [[UIColor alloc] initWithRed:232.0 / 255 green:31.0 / 255 blue:23.0 / 255 alpha: 0.9];
        nameLabel.textColor      = [[UIColor alloc] initWithRed:232.0 / 255 green:31.0 / 255 blue:23.0 / 255 alpha: 0.9];
        float h, s, b, a;
        if ([nameLabel.textColor getHue:&h saturation:&s brightness:&b alpha:&a])
            nameLabel.textColor  = [UIColor colorWithHue:h saturation:(s * 0.5)  brightness:MIN(b * 2.5, 1.0) alpha:a];
        nameLabel.shadowColor    = [UIColor blackColor];
        departureLabel.textColor = [[UIColor alloc] initWithRed:232.0 / 255 green:31.0 / 255 blue:23.0 / 255 alpha: 1.0];
        infoLabel.textColor      = [[UIColor alloc] initWithRed:232.0 / 255 green:31.0 / 255 blue:23.0 / 255 alpha: 0.9];
    } else  if (([self.tourDeparture.currentTourStatus intValue] == 30 && [self.tourTask isEqualToString:TourTaskLoadingOnly]) ||
                [self.tourDeparture.currentTourStatus intValue] == 60) { 
        cityLabel.textColor      = [UIColor grayColor];
        streetLabel.textColor    = [UIColor lightGrayColor];
        nameLabel.textColor      = [UIColor lightGrayColor];
        nameLabel.shadowColor    = [UIColor blackColor];
        departureLabel.textColor = [UIColor grayColor];
        infoLabel.textColor      = [UIColor lightGrayColor];
    } else { 
        cityLabel.textColor      = [UIColor blackColor];
        streetLabel.textColor    = [UIColor darkGrayColor];
        nameLabel.textColor      = [UIColor whiteColor];
        nameLabel.shadowColor    = [UIColor darkGrayColor];
        if ([self.tourDeparture.onDemand boolValue]) {
            departureLabel.textColor = [[UIColor alloc] initWithRed:255.0 / 255 green:128.0 / 255 blue:0.0 / 255 alpha: 1.0];
            infoLabel.textColor      = [[UIColor alloc] initWithRed:255.0 / 255 green:128.0 / 255 blue:0.0 / 255 alpha: 0.9];
        } else { 
            departureLabel.textColor = [UIColor blackColor];
            infoLabel.textColor      = [UIColor darkGrayColor];
        }
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}


@end