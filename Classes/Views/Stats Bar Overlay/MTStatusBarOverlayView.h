//
//  MTStatusBarOverlayView.h
//  UserInterfaceLibrary
//
//  Created by Tomasz Krasnyk on 11-01-24.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface MTStatusBarOverlayView : UIView {
	// Image of gray Status Bar
	UIImage *grayStatusBarImage_;
	UIImage *grayStatusBarImageSmall_;
	
	// holds all subviews, is touchable to change size of Status Bar
	UIControl *backgroundView_;
	// the view that is shown in animation mode "FallDown" when the user touches the status bar
	UIControl *detailView_;
	
	// background of Status Bar Black or gray
	UIImageView *statusBarBackgroundImageView_;
	// for displaying Text information
	UILabel *statusLabel1_;
	UILabel *statusLabel2_;
	// for displaying activity indication
	UIActivityIndicatorView *activityIndicator_;
	UILabel *finishedLabel_;
	
	// Detail View
	UITextView *detailTextView_;
	
	// Message history (is reset when finish is called)
	UITableView *historyTableView_;
}
// the view that holds all the components of the overlay (except for the detailView)
@property (nonatomic, strong) UIControl *backgroundView;
// the detailView is shown when animation is set to "FallDown"
@property (nonatomic, strong) UIControl *detailView;
// the label that holds the finished-indicator (either a checkmark, or a error-sign per default)
@property (nonatomic, strong) UILabel *finishedLabel;

@property (nonatomic, strong, readonly) UILabel *visibleStatusLabel;
@property (nonatomic, strong) UITableView *historyTableView;
@property (nonatomic, strong) UITextView *detailTextView;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) UIImageView *statusBarBackgroundImageView;
@property (nonatomic, strong) UIImage *grayStatusBarImage;
@property (nonatomic, strong) UIImage *grayStatusBarImageSmall;
@property (nonatomic, strong) UILabel *statusLabel1;
@property (nonatomic, strong) UILabel *statusLabel2;
@property (nonatomic, unsafe_unretained) UILabel *hiddenStatusLabel;

- (void)updateDetailTextViewHeight;
- (void)setColorSchemeForStatusBarStyle:(UIStatusBarStyle)style;
- (void)addSubviewToBackgroundView:(UIView *)view;

@end
