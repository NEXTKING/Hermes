//
//  UIViewSwitchController.h
//  CoresuiteMobile
//
//  Created by Tomasz Krasnyk on 7/21/10.
//  Copyright 2010 coresystems ag. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface UILIBViewSwitcher : UIView

@property (nonatomic, readonly) UIView *activeView;
@property (nonatomic) BOOL resizesViewsFillTheSourceView;

- (void) switchViewFadeAnimationToView:(UIView *) view;
- (void) switchToView:(UIView *) targetView withTransitionType:(NSString *) transitionTypeOrNil andSubtype:(NSString *) transitionSubtypeOrNil;

@end
