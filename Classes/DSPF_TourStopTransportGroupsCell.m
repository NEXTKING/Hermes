//
//  DSPF_TourStopTransportGroupsCell.m
//  Hermes
//
//  Created by iLutz on 06.10.14.
//  Copyright 2014 __MyCompanyName__. All rights reserved.
//

#import "DSPF_TourStopTransportGroupsCell.h"
#import "Location.h"
#import "Transport_Group.h"
#import "Tour_Exception.h"

@implementation DSPF_TourStopTransportGroupsCell

@synthesize transportGroup;
@synthesize transportGroupTourStop;
@synthesize task_documentLabel;
@synthesize cityLabel;
@synthesize streetLabel;
@synthesize nameLabel;
@synthesize departureLabel;
@synthesize for_cityLabel;
@synthesize for_nameLabel;
@synthesize infoLabel;
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
        
        task_documentLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        task_documentLabel.backgroundColor = self.contentView.backgroundColor;
        [task_documentLabel setFont:[UIFont systemFontOfSize:14.0]];
        [task_documentLabel setTextColor:[UIColor darkGrayColor]];
        [task_documentLabel setHighlightedTextColor:[UIColor whiteColor]];
        task_documentLabel.minimumFontSize = 7.0;
        task_documentLabel.lineBreakMode = UILineBreakModeTailTruncation;
        [self.contentView addSubview:task_documentLabel];
        
        departureLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        departureLabel.backgroundColor = self.contentView.backgroundColor;
        [departureLabel setFont:[UIFont systemFontOfSize:14.0]];
        [departureLabel setTextColor:[UIColor darkGrayColor]];
        [departureLabel setHighlightedTextColor:[UIColor whiteColor]];
        departureLabel.minimumFontSize = 7.0;
        departureLabel.lineBreakMode = UILineBreakModeTailTruncation;
        [self.contentView addSubview:departureLabel];
        
        nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        nameLabel.backgroundColor = self.contentView.backgroundColor;
        [nameLabel setFont:[UIFont  fontWithName:@"Helvetica-Bold" size:14]];
        [nameLabel setTextColor:[UIColor darkGrayColor]];
        [nameLabel setHighlightedTextColor:[UIColor whiteColor]];
        nameLabel.minimumFontSize = 8.0;
        nameLabel.lineBreakMode = UILineBreakModeTailTruncation;
        [self.contentView addSubview:nameLabel];
        
        streetLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        streetLabel.backgroundColor = self.contentView.backgroundColor;
        [streetLabel setFont:[UIFont  fontWithName:@"Helvetica-Bold" size:14]];
        [streetLabel setTextColor:[UIColor darkGrayColor]];
        [streetLabel setHighlightedTextColor:[UIColor whiteColor]];
        streetLabel.minimumFontSize = 8.0;
        streetLabel.lineBreakMode = UILineBreakModeTailTruncation;
        [self.contentView addSubview:streetLabel];
        
        cityLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        cityLabel.backgroundColor = self.contentView.backgroundColor;
        [cityLabel setFont:[UIFont  fontWithName:@"Helvetica-Bold" size:16]];
        [cityLabel setTextColor:[UIColor blackColor]];
        [cityLabel setHighlightedTextColor:[UIColor whiteColor]];
        cityLabel.minimumFontSize = 8.0;
        cityLabel.lineBreakMode = UILineBreakModeTailTruncation;
        [self.contentView addSubview:cityLabel];
        
        infoLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        infoLabel.backgroundColor = self.contentView.backgroundColor;
        [infoLabel setFont:[UIFont systemFontOfSize:14.0]];
        [infoLabel setTextColor:[UIColor darkGrayColor]];
        [infoLabel setHighlightedTextColor:[UIColor whiteColor]];
        infoLabel.minimumFontSize = 7.0;
        infoLabel.lineBreakMode = UILineBreakModeTailTruncation;
        [self.contentView addSubview:infoLabel];
        
        for_nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        for_nameLabel.backgroundColor = self.contentView.backgroundColor;
        [for_nameLabel setFont:[UIFont  fontWithName:@"Helvetica-Bold" size:14]];
        [for_nameLabel setTextColor:[UIColor darkGrayColor]];
        [for_nameLabel setHighlightedTextColor:[UIColor whiteColor]];
        for_nameLabel.minimumFontSize = 8.0;
        for_nameLabel.lineBreakMode = UILineBreakModeTailTruncation;
        [self.contentView addSubview:for_nameLabel];
                
        for_cityLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        for_cityLabel.backgroundColor = self.contentView.backgroundColor;
        [for_cityLabel setFont:[UIFont  fontWithName:@"Helvetica-Bold" size:16]];
        [for_cityLabel setTextColor:[UIColor blackColor]];
        [for_cityLabel setHighlightedTextColor:[UIColor whiteColor]];
        for_cityLabel.minimumFontSize = 8.0;
        for_cityLabel.lineBreakMode = UILineBreakModeTailTruncation;
        [self.contentView addSubview:for_cityLabel];
    }
    return self;
}

#pragma mark - Laying out subviews

#define TEXT_LEFT_MARGIN    8.0
#define TEXT_RIGHT_MARGIN   34.0

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [task_documentLabel setFrame:
     CGRectMake(TEXT_LEFT_MARGIN,
                3.0,
                [self.task_documentLabel.text sizeWithFont:self.task_documentLabel.font].width,
                [self.task_documentLabel.text sizeWithFont:self.task_documentLabel.font].height)];
    [departureLabel setFrame:
     CGRectMake(2 * TEXT_LEFT_MARGIN + [self.task_documentLabel.text sizeWithFont:self.task_documentLabel.font].width,
                3.0,
                self.frame.size.width
                - (2 * TEXT_LEFT_MARGIN + [self.task_documentLabel.text sizeWithFont:self.task_documentLabel.font].width)
                - TEXT_RIGHT_MARGIN,
                [self.departureLabel.text sizeWithFont:self.departureLabel.font].height)];
    
    [nameLabel setFrame:
     CGRectMake(TEXT_LEFT_MARGIN,
                24.0,
                self.frame.size.width
                - TEXT_LEFT_MARGIN
                - TEXT_RIGHT_MARGIN,
                [self.nameLabel.text sizeWithFont:self.nameLabel.font].height)];

    [streetLabel setFrame:
     CGRectMake(TEXT_LEFT_MARGIN,
                45.0,
                self.frame.size.width
                - TEXT_LEFT_MARGIN
                - TEXT_RIGHT_MARGIN,
                [self.streetLabel.text sizeWithFont:self.streetLabel.font].height)];
    
    [cityLabel setFrame:
     CGRectMake(TEXT_LEFT_MARGIN,
                64.0,
                (self.frame.size.width - 2 * TEXT_LEFT_MARGIN - TEXT_RIGHT_MARGIN) * 0.66,
                [self.cityLabel.text sizeWithFont:self.cityLabel.font].height)];
    [infoLabel setFrame:
     CGRectMake(2 * TEXT_LEFT_MARGIN + self.cityLabel.frame.size.width,
                66.0,
                (self.frame.size.width - 2 * TEXT_LEFT_MARGIN - TEXT_RIGHT_MARGIN) * 0.33,
                [self.infoLabel.text sizeWithFont:self.infoLabel.font].height)];
}

#pragma mark - Departure set accessor

- (void)setTransportGroup:(Transport_Group *)newTransportGroup {
    if (newTransportGroup != transportGroup) {
        transportGroup = newTransportGroup;
    }
    Location *tmpLocation;
    if ([self.transportGroup.isPickup boolValue]) {
        tmpLocation = self.transportGroup.addressee_id;
    } else {
        tmpLocation = self.transportGroup.sender_id;
    }
    if (!tmpLocation) {
        tmpLocation = ((Departure *)[[self.transportGroup.departure_id
                                      sortedArrayUsingDescriptors:[NSArray arrayWithObjects:
                                                                   [NSSortDescriptor sortDescriptorWithKey:@"sequence" ascending:NO],
                                                                   nil]] lastObject]).location_id;
    }
    self.task_documentLabel.text = [NSString stringWithFormat:@"📝 %@", self.transportGroup.task];
    self.for_cityLabel.text = [NSString stringWithFormat:@"%@:", self.transportGroup.freightpayer_id.city];
    self.for_nameLabel.text = [NSString stringWithFormat:@"%@", self.transportGroup.freightpayer_id.location_name];
    NSInteger transportGroupTourStopStatus = 0;
    if ([self.tourTask isEqualToString:TourTaskLoadingOnly]) {
        self.cityLabel.text = @"⬆";
        self.cityLabel.text = [NSString stringWithFormat:@"%@ %@ %@", self.cityLabel.text,
                               self.transportGroup.sender_id.zip,
                               self.transportGroup.sender_id.city ];
        self.nameLabel.text = [NSString stringWithFormat:@"%@",
                               [self.transportGroup.sender_id.location_name
                                stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
        self.streetLabel.text = [NSString stringWithFormat:@"%@", self.transportGroup.sender_id.street];
        NSNumber *locationId = self.transportGroup.addressee_id.location_id;
        NSNumber *transportGroupId = self.transportGroup.transport_group_id;
        if ([Transport countOf:OpenPallet|OpenRollContainer|OpenUnit
               forTourLocation:locationId transportGroup:transportGroupId ctx:self.transportGroupTourStop.managedObjectContext] == 0)
        {
            transportGroupTourStopStatus = 50;
        }
    } else {
        if ([self.transportGroupTourStop.location_id isEqual:self.transportGroup.addressee_id]) {
            self.cityLabel.text = @"⬇";
            self.cityLabel.text = [NSString stringWithFormat:@"%@ %@ %@", self.cityLabel.text,
                                   self.transportGroup.sender_id.zip,
                                   self.transportGroup.sender_id.city ];
            self.nameLabel.text = [NSString stringWithFormat:@"%@",
                                   [self.transportGroup.sender_id.location_name
                                    stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
            self.streetLabel.text = [NSString stringWithFormat:@"%@", self.transportGroup.sender_id.street];
            NSNumber *locationId = self.transportGroup.addressee_id.location_id;
            NSNumber *transportGroupId = self.transportGroup.transport_group_id;
            if ([self.transportGroupTourStop.location_id isEqual:self.transportGroup.addressee_id] &&
                [Transport countOf:Pallet|RollContainer|Unit
                   forTourLocation:locationId transportGroup:transportGroupId ctx:self.transportGroupTourStop.managedObjectContext] == 0)
            {
                transportGroupTourStopStatus = 50;
            }
        } else {
            self.cityLabel.text = @"⬆";
            self.cityLabel.text = [NSString stringWithFormat:@"%@ %@ %@", self.cityLabel.text,
                                   self.transportGroup.addressee_id.zip,
                                   self.transportGroup.addressee_id.city ];
            self.nameLabel.text = [NSString stringWithFormat:@"%@",
                                   [self.transportGroup.addressee_id.location_name
                                    stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
            self.streetLabel.text = [NSString stringWithFormat:@"%@", self.transportGroup.addressee_id.street];
            if ([self.transportGroupTourStop.location_id isEqual:self.transportGroup.sender_id] &&
                [Transport countOf:Pick
                   forTourLocation:self.transportGroup.sender_id.location_id
                    transportGroup:self.transportGroup.transport_group_id ctx:self.transportGroupTourStop.managedObjectContext] == 0)
            {
                transportGroupTourStopStatus = 50;
            }
        }
    }
    if (self.transportGroup.deliveryFrom) {
        self.departureLabel.text = [NSString stringWithFormat:@"%@",
                                    [NSDateFormatter localizedStringFromDate:self.transportGroup.deliveryFrom
                                                                   dateStyle:NSDateFormatterNoStyle
                                                                   timeStyle:NSDateFormatterShortStyle]];
    } else {
        self.departureLabel.text = @"";
    }
    if (self.transportGroup.deliveryUntil) {
        if (self.departureLabel.text.length > 0) {
            self.departureLabel.text = [NSString stringWithFormat:@"%@-%@",
                                        self.departureLabel.text,
                                        [NSDateFormatter localizedStringFromDate:self.transportGroup.deliveryUntil
                                                                       dateStyle:NSDateFormatterNoStyle
                                                                       timeStyle:NSDateFormatterShortStyle]];
        } else {
            self.departureLabel.text = [NSString stringWithFormat:@"%@",
                                        [NSDateFormatter localizedStringFromDate:self.transportGroup.deliveryUntil
                                                                       dateStyle:NSDateFormatterNoStyle
                                                                       timeStyle:NSDateFormatterShortStyle]];
        }
    }
    if (self.departureLabel.text.length > 0) {
        self.departureLabel.text = [NSString stringWithFormat:@"🕑 %@", self.departureLabel.text];
    }
    BOOL hasTourExceptionForToday = NO;
    Tour_Exception *todaysTourException = [Tour_Exception todaysTourExceptionForLocation:tmpLocation];
    if (todaysTourException) {
        hasTourExceptionForToday = YES;
    }
    if (transportGroupTourStopStatus < 50) {
        NSMutableString *infoSigns = [NSMutableString string];
        if ([self.transportGroupTourStop.location_id isEqual:self.transportGroup.addressee_id]) {
            if ([self.transportGroup.paymentOnDelivery compare:[NSDecimalNumber zero]] != NSOrderedSame)
                [infoSigns appendFormat:@" %@", @"💰"];
        } else if ([self.transportGroupTourStop.location_id isEqual:self.transportGroup.sender_id]) {
            if ([self.transportGroup.paymentOnPickup compare:[NSDecimalNumber zero]] != NSOrderedSame)
                [infoSigns appendFormat:@" %@", @"💰"];
        }
        if (self.transportGroup.info_text && self.transportGroup.info_text.length > 0) [infoSigns appendFormat:@" %@", @"📲"];
        for (Transport *tmpTransport in self.transportGroup.transport_id) {
            if ([tmpTransport.temperatureZone isEqualToString:@"FS1"]) {
                if (self.transportGroup.transport_id) [infoSigns appendFormat:@" %@", [NSString stringWithUTF8String:"\u2744"]]; // @"❄️" is not shown correctly
                break;
            }
        }
        for (Transport *tmpTransport in self.transportGroup.transport_id) {
            if ([tmpTransport.temperatureZone isEqualToString:@"FS2"]) {
                if (self.transportGroup.transport_id) [infoSigns appendFormat:@" %@", @"⛄"];
                break;
            }
        }
        for (Transport *tmpTransport in self.transportGroup.transport_id) {
            if ([tmpTransport.temperatureZone isEqualToString:@"FS5"]) {
                if (self.transportGroup.transport_id) [infoSigns appendFormat:@" %@", @"⚓️"];
                break;
            }
        }
        for (Transport *tmpTransport in self.transportGroup.transport_id) {
            if (tmpTransport.item_id && [tmpTransport.item_id.itemID isEqualToString:@"Tel. Avis"]) {
                if (self.transportGroup.transport_id) [infoSigns appendFormat:@" %@", @"📞"];
                break;
            }
        }
        for (Transport *tmpTransport in self.transportGroup.transport_id) {
            if (tmpTransport.item_id && [tmpTransport.item_id.itemID isEqualToString:@"Stockwerklieferung"]) {
                if (self.transportGroup.transport_id) [infoSigns appendFormat:@" %@", @"🏢"];
                break;
            }
        }
        self.infoLabel.text = infoSigns;
    } else {
        self.infoLabel.text = @"☑";
    }
    if (hasTourExceptionForToday) {
        /*
        cityLabel.textColor      = [UIColor grayColor];
        streetLabel.textColor    = [UIColor grayColor];
        nameLabel.textColor      = [UIColor lightGrayColor];
        departureLabel.textColor = [UIColor blueColor];
        infoLabel.textColor      = [UIColor blueColor];
         */
    } else if ((transportGroupTourStopStatus == 20 && [self.tourTask isEqualToString:TourTaskLoadingOnly]) ||
                transportGroupTourStopStatus == 50) {
        cityLabel.textColor        = [[UIColor alloc] initWithRed:0.0 / 255 green:128.0 / 255 blue:64.0 / 255 alpha: 1.0];
        streetLabel.textColor      = [[UIColor alloc] initWithRed:0.0 / 255 green:128.0 / 255 blue:64.0 / 255 alpha: 1.0];
        nameLabel.textColor        = [[UIColor alloc] initWithRed:0.0 / 255 green:128.0 / 255 blue:64.0 / 255 alpha: 0.9];
        departureLabel.textColor   = [[UIColor alloc] initWithRed:0.0 / 255 green:128.0 / 255 blue:64.0 / 255 alpha: 0.8];
        infoLabel.textColor        = [[UIColor alloc] initWithRed:0.0 / 255 green:128.0 / 255 blue:64.0 / 255 alpha: 0.8];
    } else  if ((transportGroupTourStopStatus == 15 && [self.tourTask isEqualToString:TourTaskLoadingOnly]) ||
                 transportGroupTourStopStatus == 45) {
        cityLabel.textColor        = [[UIColor alloc] initWithRed:232.0 / 255 green:31.0 / 255 blue:23.0 / 255 alpha: 1.0];
        streetLabel.textColor      = [[UIColor alloc] initWithRed:232.0 / 255 green:31.0 / 255 blue:23.0 / 255 alpha: 1.0];
        nameLabel.textColor        = [[UIColor alloc] initWithRed:232.0 / 255 green:31.0 / 255 blue:23.0 / 255 alpha: 0.9];
        departureLabel.textColor   = [[UIColor alloc] initWithRed:232.0 / 255 green:31.0 / 255 blue:23.0 / 255 alpha: 0.8];
        infoLabel.textColor        = [[UIColor alloc] initWithRed:232.0 / 255 green:31.0 / 255 blue:23.0 / 255 alpha: 0.8];
    } else  if ((transportGroupTourStopStatus == 30 && [self.tourTask isEqualToString:TourTaskLoadingOnly]) ||
                 transportGroupTourStopStatus == 60) {
        cityLabel.textColor        = [UIColor grayColor];
        streetLabel.textColor      = [UIColor grayColor];
        nameLabel.textColor        = [UIColor lightGrayColor];
        departureLabel.textColor   = [UIColor lightGrayColor];
        infoLabel.textColor        = [UIColor lightGrayColor];
    } else { 
        cityLabel.textColor   = [UIColor blackColor];
        streetLabel.textColor = [UIColor blackColor];
        nameLabel.textColor   = [UIColor darkGrayColor];
        departureLabel.textColor   = [UIColor grayColor];
        infoLabel.textColor        = [UIColor grayColor];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}


@end