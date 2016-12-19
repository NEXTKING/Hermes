//
//  DSPF_TransportCell_technopark.m
//  dphHermes
//
//  Created by Denis Kurochkin on 13.11.15.
//
//

#import "DSPF_TransportCell_technopark.h"
#import "AppStyle.h"
#import "ItemDescription.h"

@implementation DSPF_TransportCell_technopark

- (void)awakeFromNib {
    // Initialization code
    
    _mainLabel.textColor = [UIColor appMainFontColor];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void) setTransport:(Transport *)transport isLoad:(BOOL)isLoad
{
    NSString *itemDescription = nil;

#ifndef _DEBUG
    ItemDescription *descriptionItem = transport.item_id.itemDescription.allObjects.firstObject;
    if (descriptionItem)
        itemDescription = descriptionItem.text;
    else
        itemDescription = transport.code;
#else
    itemDescription = transport.code;
#endif
    
    NSString *cellTitle = (transport.itemQTY.intValue > 1) ? [NSString stringWithFormat:@"%@ (%d шт.)", itemDescription, transport.itemQTY.intValue]:itemDescription;
    self.mainLabel.text = cellTitle;
    
    if (isLoad)
        self.accessoryType = ([transport.trace_type_id.trace_type_id intValue] == TraceTypeValueLoad) ? UITableViewCellAccessoryCheckmark:UITableViewCellAccessoryNone;
    else
        self.accessoryType = ([transport.trace_type_id.trace_type_id intValue] == TraceTypeValueUnload) ? UITableViewCellAccessoryCheckmark:UITableViewCellAccessoryNone;
}

- (void)dealloc {
    [_mainLabel release];
    [super dealloc];
}
@end
