//
//  UIViewController.h
//  dphHermes
//
//  Created by Tomasz Krasnyk on 22.05.15.
//
//

#import <UIKit/UIKit.h>

extern NSString * const ControllerParameterItem;
extern NSString * const ControllerParameterTourTask;
extern NSString * const ControllerParameterPreventScanning;
extern NSString * const ControllerParameterDelegate;
extern NSString * const ControllerTransportGroupTourStop;
extern NSString * const ControllerTransportBoxCode;
extern NSString * const ControllerTriggerSynchronisationOnExit;

@interface UIViewController (Additions)

- (instancetype) swizzledInitWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil;
- (instancetype) swizzledInit;

//Override this method in concrete class
//to implement jump through logic of the controller in navigation stack
- (void) jumpThroughWhilePushing:(BOOL) push;

- (void) forceSetReadOnlyPropertyOfSearchDisplayController:(id) searchDisplayController;

@end

@protocol UIViewControllerJumpThrough <NSObject>

@property (nonatomic, copy) NSString* jumpThroughOption;
@property (nonatomic, retain) UINavigationController* navigationController;
- (void) jumpThrough;

@end
