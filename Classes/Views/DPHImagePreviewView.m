//
//  DPHImagePreviewView.m
//  dphHermes
//
//  Created by Tomasz Krasnyk on 22.07.15.
//
//

#import "DPHImagePreviewView.h"

const CGFloat TextFieldHeight = 50.0f;
const CGFloat TextFieldMargin = 10.0f;

@implementation DPHImagePreviewView
@synthesize imageView;
@synthesize textField;
@synthesize textFieldRequired;
@synthesize scrollView;

- (void) setTextFieldRequired:(BOOL)aTextFieldRequired {
    textFieldRequired = aTextFieldRequired;
    if (textFieldRequired) {
        textField.layer.borderColor = [UIColor redColor].CGColor;
    } else {
        textField.layer.borderColor = [UIColor whiteColor].CGColor;
    }
}

- (id) initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        scrollView = [[UIScrollView alloc] initWithFrame:CGRectZero];
        scrollView.backgroundColor = [UIColor blackColor];
        
        imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.opaque = YES;
        
        textField = [[UITextField alloc] initWithFrame:CGRectZero];
        textField.backgroundColor = [UIColor whiteColor];
        textField.layer.cornerRadius = 5.0f;
        textField.layer.borderWidth = [[UIScreen mainScreen] scale] == 2.00 ? 2.0f : 4.0f;
        textField.layer.borderColor = [UIColor darkGrayColor].CGColor;
        textField.borderStyle = UITextBorderStyleRoundedRect;
        textField.clearButtonMode = UITextFieldViewModeAlways;
        
        [scrollView addSubview:imageView];
        [scrollView addSubview:textField];
        [self addSubview:scrollView];
    }
    return self;
}

- (void) layoutSubviews {
    [super layoutSubviews];
    
    scrollView.frame = self.bounds;
    
    CGFloat width = CGRectGetWidth(scrollView.frame);
    imageView.frame = CGRectMake(0.0f, 0.0f, width, CGRectGetHeight(scrollView.frame) - TextFieldHeight - TextFieldMargin);
    textField.frame = CGRectInset(CGRectMake(0.0f, CGRectGetMaxY(imageView.frame), width, TextFieldHeight), TextFieldMargin, TextFieldMargin);
}

@end
