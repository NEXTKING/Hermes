//
//  DSPF_CustomButton_technopark.m
//  dphHermes
//
//  Created by Denis Kurochkin on 29/10/15.
//
//

#import "DSPF_CustomButton_technopark.h"

@interface DSPF_CustomButton_technopark ()
{
    CALayer *borderLayer;
}

@end

@implementation DSPF_CustomButton_technopark

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void) awakeFromNib
{
    borderLayer = [CALayer layer];
    CGRect borderFrame = self.frame;
    borderFrame.size.height -=12;
    borderFrame.origin.y = 6;
    borderFrame.origin.x = 0;
    
    [self.layer addSublayer:borderLayer];
    borderLayer.frame = borderFrame;
    borderLayer.borderColor = [UIColor whiteColor].CGColor;
    borderLayer.borderWidth = 1.0;
    
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    
    if (highlighted) {
        borderLayer.backgroundColor = [UIColor grayColor].CGColor;
    }
    else
        borderLayer.backgroundColor = [UIColor clearColor].CGColor;
    
}

- (void) setEnabled:(BOOL)enabled
{
    [super setEnabled:enabled];
    
    if (enabled)
        self.alpha = 1.0;
    else
        self.alpha = 0.3;
}

@end
