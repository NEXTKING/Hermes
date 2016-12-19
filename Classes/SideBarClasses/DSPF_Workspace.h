//
//  SimpleTableViewController.h
//  MobileBanking
//
//  Created by Kurochkin on 15/01/14.
//  Copyright (c) 2014 BPC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UINavigationJumpThroughController:UINavigationController
@end

@interface DSPF_Workspace : UIViewController
    <UINavigationControllerDelegate>

@property (nonatomic, retain) UINavigationController *navigationController;
@property (nonatomic, assign) BOOL sideBarGestureEnabled;
//@property (nonatomic, retain, readonly) UIViewController *rootViewController;
//@property (nonatomic, assign, readonly) UIViewController *selectedViewController;

- (IBAction)toggleMenu:(id)sender;
- (void) switchToExternalViewController:(UIViewController*) viewController;
- (void) switchBackToWorkspace;
- (void) updateSideBar;

@end
