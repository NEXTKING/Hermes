//
//  DSPF_ColoredAlert.m
//  Hermes
//
//  Created by Lutz  Thalmann on 29.08.13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "DSPF_ColoredAlert.h"

@interface DSPF_ColoredAlert (Private)

- (void) drawRoundedRect:(CGRect) rect inContext:(CGContextRef) 
context withRadius:(CGFloat) radius;

@end

@implementation DSPF_ColoredAlert

@synthesize delegate;

static UIColor *fillColor = nil;
static UIColor *borderColor = nil;

+ (DSPF_ColoredAlert *)coloredAlertWithTitle:(NSString *)title
                                     message:(NSString *)message
                             backgroundColor:(UIColor *)backgroundColor
                                 borderColor:(UIColor *)borderColor
                                    delegate:(id)delegate
                           cancelButtonTitle:(NSString *)cancelButtonTitle
                           otherButtonTitles:(NSString *)otherButtonTitles, ... NS_REQUIRES_NIL_TERMINATION {
    return [[[DSPF_ColoredAlert alloc] initWithTitle:title
                                             message:message
                                     backgroundColor:(UIColor *)backgroundColor
                                         borderColor:(UIColor *)borderColor
                                            delegate:delegate
                                   cancelButtonTitle:cancelButtonTitle
                                   otherButtonTitles:otherButtonTitles, nil] autorelease];
}

- (id)initWithTitle:(NSString *)title
            message:(NSString *)message
    backgroundColor:(UIColor *)theBackgroundColor
        borderColor:(UIColor *)theBorderColor
           delegate:(id)theDelegate
  cancelButtonTitle:(NSString *)cancelButtonTitle
  otherButtonTitles:(NSString *)otherButtonTitles, ... NS_REQUIRES_NIL_TERMINATION {
    if (fillColor) {
        [fillColor release];
        fillColor = nil;
    }
    if (borderColor) {
        [borderColor release];
        borderColor = nil;
    }
    fillColor   = [[UIColor colorWithCGColor:[theBackgroundColor CGColor]] retain];
    borderColor = [[UIColor colorWithCGColor:[theBorderColor     CGColor]] retain];
    self = [super initWithTitle:title message:message delegate:theDelegate cancelButtonTitle:cancelButtonTitle otherButtonTitles:otherButtonTitles, nil];
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
	for (UIView *sub in [self subviews]) {
		if([sub class] == [UIImageView class] && sub.tag == 0) {
			// The alert background UIImageView tag is 0, 
			// if you are adding your own UIImageView's 
			// make sure your tags != 0 or this fix 
			// will remove your UIImageView's as well!
			[sub removeFromSuperview];
			break;
		}
	}
}

- (void)drawRect:(CGRect)rect {	
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	CGContextClearRect(context, rect);
	CGContextSetAllowsAntialiasing(context, true);
	CGContextSetLineWidth(context, 0.0);
	CGContextSetAlpha(context, 0.95); 
	CGContextSetLineWidth(context, 2.0);
	CGContextSetStrokeColorWithColor(context, [borderColor CGColor]);
	CGContextSetFillColorWithColor(context, [fillColor CGColor]);
	
	// Draw background
	CGFloat backOffset = 2;
	CGRect backRect = CGRectMake(rect.origin.x + backOffset, 
								 rect.origin.y + backOffset, 
								 rect.size.width - backOffset*2, 
								 rect.size.height - backOffset*2);
	
	[self drawRoundedRect:backRect inContext:context withRadius:8];
	CGContextDrawPath(context, kCGPathFillStroke);
	
	// Clip Context
	CGRect clipRect = CGRectMake(backRect.origin.x + backOffset-1, 
								 backRect.origin.y + backOffset-1, 
								 backRect.size.width - (backOffset-1)*2, 
								 backRect.size.height - (backOffset-1)*2);
	
	[self drawRoundedRect:clipRect inContext:context withRadius:8];
	CGContextClip (context);
	
	//Draw highlight
	CGGradientRef glossGradient;
	CGColorSpaceRef rgbColorspace;
	size_t num_locations = 2;
	CGFloat locations[2] = { 0.0, 1.0 };
	CGFloat components[8] = { 1.0, 1.0, 1.0, 0.35, 1.0, 1.0, 1.0, 0.06 };
	rgbColorspace = CGColorSpaceCreateDeviceRGB();
	glossGradient = CGGradientCreateWithColorComponents(rgbColorspace, 
														components, locations, num_locations);
	
	CGRect ovalRect = CGRectMake(-130, -115, (rect.size.width*2), 
								 rect.size.width/2);
	
	CGPoint start = CGPointMake(rect.origin.x, rect.origin.y);
	CGPoint end = CGPointMake(rect.origin.x, rect.size.height/5);
	
	CGContextSetAlpha(context, 1.0); 
	CGContextAddEllipseInRect(context, ovalRect);
	CGContextClip (context);
	
	CGContextDrawLinearGradient(context, glossGradient, start, end, 0);
	
	CGGradientRelease(glossGradient);
	CGColorSpaceRelease(rgbColorspace); 
}

- (void) drawRoundedRect:(CGRect) rrect inContext:(CGContextRef) context 
			  withRadius:(CGFloat) radius {
	CGContextBeginPath (context);
	
	CGFloat minx = CGRectGetMinX(rrect), midx = CGRectGetMidX(rrect), 
	maxx = CGRectGetMaxX(rrect);
	
	CGFloat miny = CGRectGetMinY(rrect), midy = CGRectGetMidY(rrect), 
	maxy = CGRectGetMaxY(rrect);
	
	CGContextMoveToPoint(context, minx, midy);
	CGContextAddArcToPoint(context, minx, miny, midx, miny, radius);
	CGContextAddArcToPoint(context, maxx, miny, maxx, midy, radius);
	CGContextAddArcToPoint(context, maxx, maxy, midx, maxy, radius);
	CGContextAddArcToPoint(context, minx, maxy, minx, midy, radius);
	CGContextClosePath(context);
}

- (void)dismissWithClickedButtonIndex:(NSInteger)buttonIndex animated:(BOOL)animated {
    [self.delegate alertView:self willDismissWithButtonIndex:buttonIndex];
    [self.delegate alertView:self didDismissWithButtonIndex:buttonIndex];
	[super dismissWithClickedButtonIndex:buttonIndex animated:animated];
}

- (void)dealloc {
    [super dealloc];
}

@end
