//
//  MTStatusBarOverlayDefines.h
//  UserInterfaceLibrary
//
//  Created by Tomasz Krasnyk on 11-01-24.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

// macro for checking if we are on the iPad
#define IsIPad UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad
// the height of the status bar
#define kStatusBarHeight 20.0f
// width of the screen in portrait-orientation
#define kScreenWidth [UIScreen mainScreen].bounds.size.width
// height of the screen in portrait-orientation
#define kScreenHeight [UIScreen mainScreen].bounds.size.height



// Text that is displayed in the finished-Label when the finish was successful
#define kFinishedText		@"✔"
#define kFinishedFontSize	22.f

// Text that is displayed when an error occured
#define kErrorText			@"✗"
#define kErrorFontSize		19.f


///////////////////////////////////////////////////////
// Light Theme (for UIStatusBarStyleDefault)
///////////////////////////////////////////////////////

#define kLightThemeTextColor						[UIColor blackColor]
#define kLightThemeActivityIndicatorViewStyle		UIActivityIndicatorViewStyleGray
#define kLightThemeDetailViewBackgroundColor		[UIColor blackColor]
#define kLightThemeDetailViewBorderColor			[UIColor darkGrayColor]
#define kLightThemeHistoryTextColor					[UIColor colorWithRed:0.749f green:0.749f blue:0.749f alpha:1.0f]


///////////////////////////////////////////////////////
// Dark Theme (for UIStatusBarStyleBlackOpaque)
///////////////////////////////////////////////////////

#define kDarkThemeTextColor							[UIColor colorWithRed:0.749f green:0.749f blue:0.749f alpha:1.0f]
#define kDarkThemeActivityIndicatorViewStyle		UIActivityIndicatorViewStyleWhite
#define kDarkThemeDetailViewBackgroundColor			[UIColor colorWithRed:0.3f green:0.3f blue:0.3f alpha:1.0f]
#define kDarkThemeDetailViewBorderColor				[UIColor whiteColor]
#define kDarkThemeHistoryTextColor					[UIColor whiteColor]


///////////////////////////////////////////////////////
// Animations
///////////////////////////////////////////////////////

// minimum time that a message is shown, when messages are queued
#define kMinimumMessageVisibleTime				0.5f

// duration of the animation to show next status message in seconds
#define kNextStatusAnimationDuration			0.8f

// duration the statusBarOverlay takes to appear when it was hidden
#define kAppearAnimationDuration				0.5f

// animation duration of animation mode shrink
#define kAnimationDurationShrink				0.3f

// animation duration of animation mode fallDown
#define kAnimationDurationFallDown				0.4f

// delay after that the status bar gets visible again after rotation
#define kRotationAppearDelay					[UIApplication sharedApplication].statusBarOrientationAnimationDuration



///////////////////////////////////////////////////////
// Detail View
///////////////////////////////////////////////////////

#define kHistoryTableRowHeight		25
#define kMaxHistoryTableRowCount	5

#define kDetailViewAlpha			0.9f
#define kDetailViewWidth			(IsIPad ? 400 : 280)
// default frame of detail view when it is hidden
#define kDefaultDetailViewFrame CGRectMake((kScreenWidth - kDetailViewWidth)/2, -(kHistoryTableRowHeight*kMaxHistoryTableRowCount + kStatusBarHeight),\
kDetailViewWidth, kHistoryTableRowHeight*kMaxHistoryTableRowCount + kStatusBarHeight)


///////////////////////////////////////////////////////
// Size
///////////////////////////////////////////////////////

// Size of the text in the status labels
#define kStatusLabelSize				12.f

// default-width of the small-mode
#define kWidthSmall						26

@interface MTStatusBarOverlayDefines : NSObject {

}

@end
