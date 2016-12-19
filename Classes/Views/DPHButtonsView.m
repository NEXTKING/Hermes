//
//  DPButtonsView.m
//  dphHermes
//
//  Created by Tomasz Kransyk on 07.05.15.
//
//

#import "DPHButtonsView.h"

static const CGFloat buttonsMargin = 20.0f;

@implementation DPHButtonsView
@synthesize buttonsHeight;
@synthesize buttons;
@synthesize verticalArrangement;
@synthesize verticalSeparator;
@synthesize horizontalSeparator;

- (void) setButtons:(NSArray *)aButtons {
    if (buttons != aButtons) {
        for (id button in buttons) {
            [button removeFromSuperview];
        }
        buttons = aButtons;
        for (id button in buttons) {
            [self addSubview:button];
        }
        [self setNeedsLayout];
    }
}

- (void) setButtonsHeight:(CGFloat)height {
    buttonsHeight = height;
    [self setNeedsLayout];
}

- (void) setVerticalArrangement:(BOOL)aVerticalArrangement {
    verticalArrangement = aVerticalArrangement;
    [self setNeedsLayout];
}

- (void) setVerticalSeparator:(CGFloat)aVerticalSeparator {
    verticalSeparator = aVerticalSeparator;
    [self setNeedsLayout];
}

- (void) setHorizontalSeparator:(CGFloat)aHorizontalSeparator {
    horizontalSeparator = aHorizontalSeparator;
    [self setNeedsLayout];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
    }
    return self;
}


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void) commonInit {
    verticalArrangement = YES;
    buttonsHeight = 48.0f;
    verticalSeparator = 3.0f;
    horizontalSeparator = 20.0f;
}

- (UIButton *) buttonWithTitle:(NSString *) title {
    UIButton *result = nil;
    for (UIButton *button in buttons) {
        if ([[button titleForState:UIControlStateNormal] isEqualToString:title]) {
            result = button;
            break;
        }
    }
    return result;
}

- (void) layoutSubviews {
    [super layoutSubviews];
    
    if ([buttons count] == 0) return;
    
    CGFloat buttonsWidth = CGRectGetWidth(self.bounds) - 2 * buttonsMargin;
    CGFloat buttonsY = CGRectGetMaxY(self.bounds);
    CGFloat buttonsX = buttonsMargin;
    if (verticalArrangement) {
        for (NSInteger i = [buttons count]-1; i >= 0; --i) {
            UIButton *button = [buttons objectAtIndex:i];
            if (button.hidden) {
                continue;
            }
            button.frame = CGRectIntegral(CGRectMake(buttonsX, buttonsY - self.buttonsHeight, buttonsWidth, self.buttonsHeight));
            buttonsY = buttonsY - self.buttonsHeight - verticalSeparator;
        }
    } else {
        NSUInteger buttonsCount = 0;
        for (UIButton *button in buttons) {
            if (!button.hidden) {
                ++buttonsCount;
            }
        }
        buttonsWidth = floorf((CGRectGetWidth(self.bounds) - 2 * buttonsMargin - (buttonsCount - 1) * horizontalSeparator) / buttonsCount);
        for (UIButton *button in buttons) {
            if (button.hidden) {
                continue;
            }
            button.frame = CGRectIntegral(CGRectMake(buttonsX, CGRectGetMaxY(self.bounds) - self.buttonsHeight - verticalSeparator, buttonsWidth, self.buttonsHeight));
            buttonsX += (horizontalSeparator + buttonsWidth);
        }
    }
}

+ (UIButton *) grayButtonWithTitle:(NSString *) title {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *image = [UIImage imageNamed:@"b280x48_n.png"];
    image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(image.size.height / 2.0f, 13.0f, image.size.height / 2.0f, 13.0f)];
    UIImage *highlightedImage = [UIImage imageNamed:@"b280x48_h.png"];
    highlightedImage = [highlightedImage resizableImageWithCapInsets:UIEdgeInsetsMake(highlightedImage.size.height / 2.0f, 13.0f, highlightedImage.size.height / 2.0f, 13.0f)];
    button.frame = CGRectMake(0.0f, 0.0f, image.size.width, image.size.height);
    [button setBackgroundImage:image forState:UIControlStateNormal];
    [button setBackgroundImage:highlightedImage forState:UIControlStateHighlighted];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button.titleLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:24.0f]];
    button.titleLabel.adjustsFontSizeToFitWidth = YES;
    button.titleLabel.minimumFontSize = 9.0f;
    button.titleLabel.numberOfLines = 1;
    button.titleEdgeInsets = UIEdgeInsetsMake(0.0f, 10.0f, 0.0f, 10.0f);
    return button;
}

@end
