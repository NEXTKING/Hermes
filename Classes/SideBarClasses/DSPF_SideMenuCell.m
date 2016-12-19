//
//  DSPF_SideMenuCell.m
//  dphHermes
//
//  Created by Denis Kurochkin on 05.11.15.
//
//

#import "DSPF_SideMenuCell.h"

@implementation DSPF_SideMenuCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void) dealloc
{
    [_cellAction release];
    [_menuIcon release];
    [_menuTitle release];
    [super dealloc];
}

@end
