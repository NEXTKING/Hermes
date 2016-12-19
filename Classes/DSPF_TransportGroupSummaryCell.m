//
//  DSPF_TransportGroupSummaryCell.m
//  Hermes
//
//  Created by iLutz on 06.10.14.
//  Copyright 2014 __MyCompanyName__. All rights reserved.
//

#import "DSPF_TransportGroupSummaryCell.h"

#import "Item.h"

@implementation DSPF_TransportGroupSummaryCell

@synthesize transportGroup;
@synthesize transportGroupSummary;
@synthesize qtyLabel;
@synthesize itemLabel;
@synthesize weightLabel;
@synthesize temperatureLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentView.backgroundColor = [[UIColor alloc] initWithRed:255.0 / 255 green:255.0 / 255 blue:255.0 / 255 alpha: 0.16];
        // Initialization code
        //      imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        //      imageView.contentMode = UIViewContentModeScaleAspectFit;
        //      [self.contentView addSubview:imageView];
        
        qtyLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        qtyLabel.backgroundColor = self.contentView.backgroundColor;
        [qtyLabel setFont:[UIFont  fontWithName:@"HelveticaNeue-CondensedBold" size:17]];
        [qtyLabel setTextColor:[UIColor darkGrayColor]];
        [qtyLabel setHighlightedTextColor:[UIColor whiteColor]];
        qtyLabel.minimumFontSize = 7.0;
        qtyLabel.lineBreakMode = UILineBreakModeTailTruncation;
        qtyLabel.textAlignment = UITextAlignmentRight;
        [self.contentView addSubview:qtyLabel];
        
        itemLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        itemLabel.backgroundColor = self.contentView.backgroundColor;
        [itemLabel setFont:[UIFont  fontWithName:@"HelveticaNeue-CondensedBold" size:17]];
        [itemLabel setTextColor:[UIColor darkGrayColor]];
        [itemLabel setHighlightedTextColor:[UIColor whiteColor]];
        itemLabel.minimumFontSize = 7.0;
        itemLabel.lineBreakMode = UILineBreakModeTailTruncation;
        itemLabel.textAlignment = UITextAlignmentLeft;
        [self.contentView addSubview:itemLabel];
        
        weightLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        weightLabel.backgroundColor = self.contentView.backgroundColor;
        [weightLabel setFont:[UIFont  fontWithName:@"HelveticaNeue-CondensedBold" size:17]];
        [weightLabel setTextColor:[UIColor darkGrayColor]];
        [weightLabel setHighlightedTextColor:[UIColor whiteColor]];
        weightLabel.minimumFontSize = 8.0;
        weightLabel.lineBreakMode = UILineBreakModeTailTruncation;
        weightLabel.textAlignment = UITextAlignmentRight;
        [self.contentView addSubview:weightLabel];
        
        temperatureLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        temperatureLabel.backgroundColor = self.contentView.backgroundColor;
        [temperatureLabel setFont:[UIFont fontWithName:@"AppleColorEmoji" size:17]];
        [temperatureLabel setTextColor:[UIColor darkGrayColor]];
        [temperatureLabel setHighlightedTextColor:[UIColor whiteColor]];
        temperatureLabel.minimumFontSize = 15.0;
        temperatureLabel.lineBreakMode = UILineBreakModeTailTruncation;
        temperatureLabel.textAlignment = UITextAlignmentCenter;
        [self.contentView addSubview:temperatureLabel];
    }
    return self;
}

#pragma mark - Laying out subviews

#define TEXT_LEFT_MARGIN    8.0
#define TEXT_RIGHT_MARGIN   34.0

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [qtyLabel setFrame:
     CGRectMake(TEXT_LEFT_MARGIN,
                22.0,
                48,
                22)];
    [itemLabel setFrame:
     CGRectMake(2 * TEXT_LEFT_MARGIN + 48,
                22.0,
                136,
                22)];
    
    [weightLabel setFrame:
     CGRectMake(self.frame.size.width
                - TEXT_RIGHT_MARGIN
                - 22
                - TEXT_LEFT_MARGIN
                - 76,
                22.0,
                76,
                22)];
    [temperatureLabel setFrame:
     CGRectMake(self.frame.size.width
                - TEXT_RIGHT_MARGIN
                - 22,
                20.0,
                22,
                22)];
}

#pragma mark - Departure set accessor

- (void)setTransportGroupSummary:(NSDictionary *)newTransportGroupSummary {
    if (newTransportGroupSummary != transportGroupSummary) {
        transportGroupSummary = newTransportGroupSummary;
    }
    self.qtyLabel.text = [NSString stringWithFormat:@"%@", [transportGroupSummary valueForKey:@"totalQTY"]];
    self.itemLabel.text = [Item localDescriptionTextForItem:[Item itemWithItemID:[transportGroupSummary valueForKey:@"itemID"]
                                                                           inCtx:self.transportGroup.managedObjectContext]];
    self.weightLabel.text = [NSString stringWithFormat:@"%@ kg", [transportGroupSummary valueForKey:@"totalWeight"]];
    id checkNull = [transportGroupSummary valueForKey:@"temperatureZone"];
    if ([checkNull isEqual:[NSNull null]]) checkNull = @"";
    else                                   checkNull = [[[[transportGroupSummary valueForKey:@"temperatureZone"]
                                                          // @"❄️" is not shown correctly
                                                          stringByReplacingOccurrencesOfString:@"FS1" withString:[NSString stringWithUTF8String:"\u2744"]]
                                                         stringByReplacingOccurrencesOfString:@"FS2" withString:@"⛄"]
                                                        stringByReplacingOccurrencesOfString:@"FS5" withString:@"⚓️"];
    self.temperatureLabel.text = checkNull;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}


@end