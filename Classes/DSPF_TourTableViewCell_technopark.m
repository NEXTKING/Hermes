//
//  DSPF_TourTableViewCell_technopark.m
//  dphHermes
//
//  Created by Denis Kurochkin on 02.11.15.
//
//

#import "DSPF_TourTableViewCell_technopark.h"
#import <QuartzCore/QuartzCore.h>
#import "AppStyle.h"

@implementation DSPF_TourTableViewCell_technopark

- (void)awakeFromNib {
    // Initialization code
    
    _addressLabel.textColor             = [UIColor appMainFontColor];
    _departureHoursLabel.textColor      = [UIColor appMainFontColor];
    _departureMinutesLabel.textColor    = [UIColor appMainFontColor];
    _arrivalHoursLabel.textColor        = [UIColor appMainFontColor];
    _arrivalMinutesLabel.textColor      = [UIColor appMainFontColor];
    _dashLabel.textColor                = [UIColor appMainFontColor];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void) setTourDeparture:(Departure *)tourDeparture
{
    NSDateFormatter *formatter = [[NSDateFormatter new] autorelease];
    formatter.dateStyle = NSDateFormatterShortStyle;
    formatter.timeStyle = NSDateFormatterShortStyle;
    
   // NSString *arrivalTime = [formatter stringFromDate:tourDeparture.arrivalDate];
   // NSString *departureTime = [formatter stringFromDate:tourDeparture.departure];
   // NSString *deliveryTime = [NSString stringWithFormat:@"%@ - %@", arrivalTime, departureTime];
    
    _addressLabel.text = [NSString stringWithFormat:@"%@", tourDeparture.location_id.city];
    
     NSCalendar* calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    
    if (tourDeparture.transport_group_id.deliveryFrom)
    {
        NSDateComponents* fromComponents = [calendar components:NSCalendarUnitHour|NSCalendarUnitMinute fromDate:tourDeparture.transport_group_id.deliveryFrom];
        _departureHoursLabel.text = [NSString stringWithFormat:@"%d", fromComponents.hour];
        _departureMinutesLabel.text = [NSString stringWithFormat:@"%02d", fromComponents.minute];
    }
    
    if (tourDeparture.transport_group_id.deliveryUntil)
    {
        NSDateComponents* toComponents = [calendar components:NSCalendarUnitHour|NSCalendarUnitMinute fromDate:tourDeparture.transport_group_id.deliveryUntil];
        _arrivalHoursLabel.text = [NSString stringWithFormat:@"%d", toComponents.hour];
        _arrivalMinutesLabel.text = [NSString stringWithFormat:@"%02d", toComponents.minute];
    }
}

- (void)dealloc {
    [_addressLabel release];
    [_containerView release];
    [_departureHoursLabel release];
    [_departureMinutesLabel release];
    [_arrivalMinutesLabel release];
    [_arrivalHoursLabel release];
    [_dashLabel release];
    [super dealloc];
}
@end
