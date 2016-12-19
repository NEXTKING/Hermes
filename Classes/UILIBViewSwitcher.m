//
//  UIViewSwitchController.m
//  CoresuiteMobile
//
//  Created by Tomasz Krasnyk on 7/21/10.
//  Copyright 2010 coresystems ag. All rights reserved.
//

#import "UILIBViewSwitcher.h"
#import <QuartzCore/CAAnimation.h>
#import <QuartzCore/QuartzCore.h>

@interface UILIBViewSwitcher()
@property (nonatomic) UIView *activeView;
@end


@implementation UILIBViewSwitcher
@synthesize activeView;
@synthesize resizesViewsFillTheSourceView;

//--------------------------------------------------------------------------------------------
#pragma mark - Inits/dealloc
//---------------------------------------------------------------------------------------------
- (instancetype) initWithCoder:(NSCoder *)aDecoder {
    if((self = [super initWithCoder:aDecoder])){
        resizesViewsFillTheSourceView = YES;
    }
    return self;
}

- (instancetype) initWithFrame:(CGRect)frame {
    if((self = [super initWithFrame:frame])){
        resizesViewsFillTheSourceView = YES;
    }
    return self;
}

- (void) dealloc {
	[activeView removeFromSuperview];
}

//---------------------------------------------------------------------------------------------
- (void) switchViewFadeAnimationToView:(UIView *) view {
	[self switchToView:view withTransitionType:kCATransitionFade andSubtype:kCATransitionFromTop];
}

- (void) switchToView:(UIView *) targetView withTransitionType:(NSString *) transitionType andSubtype:(NSString *) transitionSubtype {
	if(targetView == activeView){
		return;
	}
	if(resizesViewsFillTheSourceView){
		targetView.frame = self.bounds;
	}
	BOOL animationRequested = transitionType != nil;
	if(animationRequested && activeView != nil){
		// First create a CATransition object to describe the transition
		CATransition *transition = [CATransition animation];
		
		// Animate over 3/4 of a second
		transition.duration = 0.35f;
		// using the ease in/out timing function
		transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
		transition.type = transitionType;
		transition.subtype = transitionSubtype;
		transition.removedOnCompletion = YES;
		[self.layer addAnimation:transition forKey:nil];
	} else {
		//[self.sourceView.layer removeAllAnimations];
	}
	
	// change that triggers animation
	[self.activeView removeFromSuperview];
	[self addSubview:targetView];
	
	self.activeView = targetView;
}


@end
