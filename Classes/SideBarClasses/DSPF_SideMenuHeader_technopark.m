//
//  DSPF_SideMenuHeader_technopark.m
//  dphHermes
//
//  Created by Denis Kurochkin on 18.11.15.
//
//

#import "DSPF_SideMenuHeader_technopark.h"
#import "AppStyle.h"
#import "User.h"

@implementation DSPF_SideMenuHeader_technopark

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void) awakeFromNib
{
    _nameLabel.textColor = [UIColor appMainFontColor];
    _truckLabel.textColor = [UIColor appMainFontColor];
    _tourNumberLabel.textColor = [UIColor appMainFontColor];
    _timeTextLabel.textColor = [UIColor appMainFontColor];
    _distanceTextLabel.textColor = [UIColor appMainFontColor];
    _amountTextLabel.textColor = [UIColor appMainFontColor];
    _amountValueLabel.textColor = [UIColor appMainFontColor];
    _timeValueLabel.textColor = [UIColor appMainFontColor];
    _distanceValueLabel.textColor = [UIColor appMainFontColor];
    
    User* currentUser = [User userWithUserID:[NSUserDefaults currentUserID] inCtx:ctx()];
    self.nameLabel.text = [currentUser firstAndLastName];
    Tour *tour = [Tour tourWithTourID:[NSUserDefaults currentTourId] inCtx:ctx()];
    Truck* truck = [Truck truckWithTruckID:[NSUserDefaults currentTruckId] inCtx:ctx()];
    self.truckLabel.text = truck.code;
    self.tourNumberLabel.text = tour.code;
}

- (void) setNeedsDisplay
{
    [super setNeedsDisplay];
    User* currentUser = [User userWithUserID:[NSUserDefaults currentUserID] inCtx:ctx()];
    self.nameLabel.text = [currentUser firstAndLastName];
    Tour *tour = [Tour tourWithTourID:[NSUserDefaults currentTourId] inCtx:ctx()];
    Truck* truck = [Truck truckWithTruckID:[NSUserDefaults currentTruckId] inCtx:ctx()];
    self.truckLabel.text = truck.description_text;
    
    NSString *jsonString = tour.description_text;
    if (!jsonString || jsonString.length < 1)
        return;
    
    NSDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
    id obj = [jsonObject objectForKey:@"time"];
    if (obj && [obj isKindOfClass:[NSString class]])
        _timeValueLabel.text = [NSString stringWithFormat:@"%@ ч", obj];
    obj = [jsonObject objectForKey:@"way"];
    if (obj && [obj isKindOfClass:[NSString class]])
        _distanceValueLabel.text = [NSString stringWithFormat:@"%@ км", obj];
    obj = [jsonObject objectForKey:@"amount"];
    if (obj && [obj isKindOfClass:[NSString class]])
        _amountValueLabel.text = [NSString stringWithFormat:@"%@ руб.", obj];
    obj = [jsonObject objectForKey:@"tourNumber"];
    if (obj && [obj isKindOfClass:[NSString class]])
        _tourNumberLabel.text = obj;
    else
        _tourNumberLabel.text = @"-";
}

- (void)dealloc {
    [_nameLabel release];
    [_truckLabel release];
    [_tourNumberLabel release];
    [_timeTextLabel release];
    [_distanceTextLabel release];
    [_amountTextLabel release];
    [_timeValueLabel release];
    [_distanceValueLabel release];
    [_amountValueLabel release];
    [super dealloc];
}
@end
