//
//  SimpleTableViewController.m
//  MobileBanking
//
//  Created by Kurochkin on 15/01/14.
//  Copyright (c) 2014 BPC. All rights reserved.
//


#import "DSPF_Workspace.h"
#import "STMenuViewController.h"
#import "STMenuDataSource.h"

#import <QuartzCore/QuartzCore.h>

//#define STATIC_MENU

@implementation UINavigationJumpThroughController

- (void) pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if ([viewController conformsToProtocol:@protocol(UIViewControllerJumpThrough)])
    {
        id<UIViewControllerJumpThrough> jumpVC = (id<UIViewControllerJumpThrough>)viewController;
        [jumpVC setNavigationController:self];
        
        if (jumpVC.jumpThroughOption)
            [jumpVC jumpThrough];
        else
            [super pushViewController:viewController animated:animated];
    }
    else
        [super pushViewController:viewController animated:animated];
}

@end

@interface DSPF_Workspace ()
{
    
    UIActionSheet* _logoutPrompt;
    
    BOOL _menuVisible;
    STMenuViewController *_menuCtrl;
    UIImageView *_menuImage;
    
    BOOL _inAnimation;
    CGPoint _endOfAnimation;
    CGPoint _startOfAnimation;
    CGRect _initialFrame;
    int _overlapWidth;
    int _hiddenWidth;
    BOOL _isSystemGreaterThan6;
    UIView *_temporaryStatusBar;
    NSArray *navigationBarTitles;
    NSArray *toolbarTitles;
    NSArray *sideBarTitles;
    STMenuDataSource    * menuDataSource;
    NSMutableDictionary * presentingControllers;
    
    UIPanGestureRecognizer *_panGestureRecognizer;
}

@property (nonatomic, retain) NSArray* workflowStack;

- (IBAction)toggleMenu:(id)sender;
- (IBAction)panGestureHandler:(UIPanGestureRecognizer *)sender;

- (void) beginMovementAnimation;
- (void) animateMovementFromPoint:(CGPoint)pstart toPoint:(CGPoint)pcurr;
- (void) completeMovementAnimation;

@end

@implementation DSPF_Workspace

- (void)internalInit
{
    _navigationController = Nil;
    _menuVisible = NO;
    _menuCtrl = Nil;
    _menuImage = Nil;
    
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
        _isSystemGreaterThan6 = YES;
    }
    
    _inAnimation = NO;
    _overlapWidth = 3;
    _hiddenWidth = 5;
    
    if ( !_panGestureRecognizer )
        _panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureHandler:)];
}

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
        //STItemsViewController *itemsController = [[STItemsViewController alloc] initWithStyle:UITableViewStyleGrouped];
        //itemsController.delegate = self;
        //_rootViewController = itemsController;
        
        //_navigationController = [[UINavigationController alloc] initWithRootViewController:_rootViewController];
        _navigationController.delegate = self;
        _sideBarGestureEnabled = YES;
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [self internalInit];
    }
    return self;
}

- (void)dealloc
{
    [_navigationController release];
    [_menuCtrl release];
    [_menuImage release];
    [_panGestureRecognizer release];
    [_workflowStack release];
    [sideBarTitles release];
    [navigationBarTitles release];
    [menuDataSource release];
    [_menuCtrl release];
    [presentingControllers release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // Pan gesture handler for menu
    _panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureHandler:)];
    [self.view addGestureRecognizer:_panGestureRecognizer];
    self.view.backgroundColor = [UIColor scrollViewTexturedBackgroundColor];
    
    // Add views as subviews to the current view
    [self.view addSubview:_navigationController.view];
    _navigationController.delegate = self;
    
    // Set up view size for navigation controller; use full bounds minus 60pt at the bottom
    CGRect navigationControllerFrame = self.view.frame;
    navigationControllerFrame.size.height -= 60;
    _navigationController.view.frame = navigationControllerFrame;
    
    // Enable autoresizing for both the navigation controller and the tab bar
    _navigationController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    // Correct navigation bar position in navigation view
    CGRect rect = _navigationController.navigationBar.frame;
    
    if ( _isSystemGreaterThan6 )
    {   // iOS 7 and above
        rect.origin.y = 20;
    }
    else
    {   // iOS 6.1 and below
        rect.origin.y = 0;
    }
    _navigationController.navigationBar.frame = rect;
    
    menuDataSource = [[STMenuDataSource alloc] init];
    presentingControllers = [NSMutableDictionary new];
    
    _menuCtrl = [[STMenuViewController alloc] init];
    _menuCtrl.menuDataSource = menuDataSource;
    [self.view insertSubview:_menuCtrl.view belowSubview:_navigationController.view];
    
    CGRect favoritesFrame = _menuCtrl.view.frame;
    CGRect mainFrame = _navigationController.view.frame;
    //int coffs = (_startOfAnimation.x - _endOfAnimation.x);
    favoritesFrame.origin.x = mainFrame.origin.x+mainFrame.size.width;
    _menuCtrl.view.frame = favoritesFrame;
    
    // Create a temporary status bar overlay
    /*if (_isSystemGreaterThan6)
    {
        _temporaryStatusBar = [[UIView alloc] initWithFrame:[[UIApplication sharedApplication] statusBarFrame]];
        _temporaryStatusBar.backgroundColor = [UIColor blackColor];
        _temporaryStatusBar.alpha = 0.0;
        [self.view addSubview:_temporaryStatusBar];
        [_temporaryStatusBar release];
    }*/
    
    if (PFBrandingSupported(BrandingTechnopark, nil))
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

- (void)viewDidLayoutSubviews
{
    // We need this to suppress view's resizing from UIImagePickerController side
    CGRect navigationControllerFrame = _navigationController.view.frame;
    navigationControllerFrame.origin.y = 0;
    navigationControllerFrame.size.height = self.view.frame.size.height;
    _navigationController.view.frame = navigationControllerFrame;
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void) enableMovementEffects
{
    // Shadows for navigation view
    _navigationController.view.clipsToBounds = NO;
    _navigationController.view.layer.shadowOpacity = 1;
    _navigationController.view.layer.shadowOffset = CGSizeMake(0, 0);
    _navigationController.view.layer.shadowRadius = 5.0;
    
    CGRect path = _navigationController.view.frame;
    path.size.width = 5.0;
    path.origin.x -=3;
    path.size.height+=2;
    _navigationController.view.layer.shadowPath = [UIBezierPath bezierPathWithRect:_navigationController.view.frame].CGPath;
}

- (void) disableMovementEffects
{
    // Shadows for navigation view
    _navigationController.view.clipsToBounds = YES;
    _navigationController.view.layer.shadowOpacity = 0;
    _navigationController.view.layer.shadowRadius = 0;
}

- (IBAction)panGestureHandler:(UIPanGestureRecognizer *)sender
{
    if (menuDataSource.cells.count < 1)
        return;
    
    //UIView *piece = sender.view;
    CGPoint locationInView = [sender locationInView:sender.view.superview];
    
    switch ( sender.state )
    {
        case UIGestureRecognizerStatePossible:
            break;
        case UIGestureRecognizerStateBegan:
            _inAnimation = YES;
            _startOfAnimation = locationInView;
            [self beginMovementAnimation];
            break;
        case UIGestureRecognizerStateChanged:
            [self animateMovementFromPoint:_startOfAnimation toPoint:locationInView];
            break;
        case UIGestureRecognizerStateEnded:
            _inAnimation = NO;
            _endOfAnimation = locationInView;
            [self completeMovementAnimation];
            break;
        case UIGestureRecognizerStateCancelled:
            break;
        case UIGestureRecognizerStateFailed:
            break;
    }
}

- (void) beginMovementAnimation
{
    _inAnimation = YES;
    _initialFrame = _navigationController.view.frame;
    
    if (!_menuVisible)
        [self enableMovementEffects];
    
#ifdef STATIC_MENU
    if ( YES )
    {   // show menu
        if ( !_menuCtrl )
        {
            TWMenuViewController* controller = [[TWMenuViewController alloc] initWithNibName:@"TWMenuView" bundle:Nil];
            controller.delegate = self;
            _menuCtrl = controller;
        }
        CGRect menuFrame = _menuCtrl.view.frame;
        menuFrame.origin.x = -1*_hiddenWidth;
        menuFrame.origin.y = 20;
        menuFrame.size.height = self.view.bounds.size.height-_tabBar.frame.size.height;
#ifdef MENU_ABOVE
        [self.view insertSubview:_menuCtrl.view aboveSubview:_navigationController.view];
#else
        [self.view insertSubview:_menuCtrl.view belowSubview:_navigationController.view];
#endif
        [self.view sendSubviewToBack:_menuCtrl.view];
        _menuCtrl.view.frame = menuFrame;
    }
#endif
}

- (void) animateMovementFromPoint:(CGPoint)pstart toPoint:(CGPoint)pcurr
{
    
    if (_isSystemGreaterThan6)
    {
        _temporaryStatusBar.alpha = _navigationController.view.frame.origin.x/600.0;
    
        //if (_temporaryStatusBar.alpha >0.1)
        //    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
        //else
        //    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
    }
    
    int xoffs = (int)(pcurr.x-pstart.x);
    if ( !_inAnimation && xoffs == 0 )
        return;
    
    CGRect mainFrame = _initialFrame;
    mainFrame.origin.x += xoffs;
    if ( mainFrame.origin.x >= 0 )
        return;
    if ( _menuVisible && _menuCtrl )
    {
#ifndef STATIC_MENU
        if ( xoffs <= 0 )
            return;
        CGRect menuFrame = _menuCtrl.view.frame;
        menuFrame.origin.x = mainFrame.origin.x+mainFrame.size.width-_overlapWidth;
        _menuCtrl.view.frame = menuFrame;
#endif
    }
    
    _navigationController.view.frame = mainFrame;
}

- (void) completeMovementAnimation
{
    _inAnimation = NO;
    float triggering_offset = self.view.bounds.size.width/4;    // 25.0 %
    if ( _menuVisible )
        triggering_offset = self.view.bounds.size.width/6;      // 16.5 %
    
    if ( (_endOfAnimation.x-_startOfAnimation.x) >= triggering_offset )
    { // left-side move gesture is performed: hide menu
        if ( _menuVisible )
            [self toggleMenu:Nil];  // hide currently visible menu
    }
    else
        if ((_startOfAnimation.x-_endOfAnimation.x) >= triggering_offset )
        { // right-side move gesture is performed: show menu
            if ( !_menuVisible )
                [self toggleMenu:Nil];  // show currently invisible favorites
        }
        else
        { // rollback to initial positions
            float animation_time = 0.25;
            CGRect tmpFrame = _initialFrame;
            CGRect menuFrame;
            if ( _menuVisible && _menuCtrl )
            {
                menuFrame = _menuCtrl.view.frame;
                menuFrame.origin.x = tmpFrame.origin.x+tmpFrame.size.width-_overlapWidth;
            }
            [UIView transitionWithView:self.view duration:animation_time options:UIViewAnimationOptionAllowAnimatedContent | UIViewAnimationOptionLayoutSubviews
                            animations:^{
                                _navigationController.view.frame = tmpFrame;
                                if ( _menuVisible && _menuCtrl )
                                {
                                    _menuCtrl.view.frame = menuFrame;
                                    _temporaryStatusBar.alpha = 0.5;
                                }
                                else
                                {
                                    //_temporaryStatusBar.alpha= 0.0;
                                    //if (_isSystemGreaterThan6)
                                    //    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
                                }
                            } completion:^(BOOL finished) {
                                if (!(_menuVisible && _menuCtrl))
                                 [self disableMovementEffects];
                            }];
        }
    _startOfAnimation = _endOfAnimation;
}

- (IBAction)toggleMenu:(id)sender
{
    if ( _menuVisible )
    {
        //if (_isSystemGreaterThan6)
        //    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
        
        [self showRightMenu:NO withAnimation:YES];
    }
    else
    {
        //if (_isSystemGreaterThan6)
        //    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
        
        if (sender)
            [self enableMovementEffects];
        [self showRightMenu:YES withAnimation:YES];
    }
}

#ifndef STATIC_MENU
- (void) showMenu:(BOOL)show withAnimation:(BOOL)animation
{
    float animation_time = 0.25;
    if ( _menuVisible && !show )
    {   // hide menu
        CGRect menuFrame = _menuCtrl.view.frame;
        CGRect mainFrame = _navigationController.view.frame;
        mainFrame.origin.x = 0;
        menuFrame.origin.x = mainFrame.origin.x-menuFrame.size.width;
        
        void (^animations_block)() = ^{
            _menuCtrl.view.frame = menuFrame;
            _navigationController.view.frame = mainFrame;
            _temporaryStatusBar.alpha = 0.0;
            if (_isSystemGreaterThan6)
                [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
        };
        void (^completion_block)(BOOL) = ^(BOOL finished) {
            //[self.view sendSubviewToBack:_tabBar];
            [_menuCtrl.view removeFromSuperview];
            [_menuCtrl release];
            _menuCtrl = Nil;
            _navigationController.view.userInteractionEnabled = YES;
        };
        if ( animation )
        {
            [UIView transitionWithView:self.view duration:animation_time options:UIViewAnimationOptionAllowAnimatedContent | UIViewAnimationOptionLayoutSubviews
                            animations:animations_block completion:completion_block];
        }
        else
        {
            // instead of animation:
            animations_block();
            // instead of completion:
            completion_block(YES);
        }
    }
    else
        if ( !_menuVisible && show )
        { // show menu
            if ( !_menuCtrl )
            {
                STMenuViewController* controller = [[STMenuViewController alloc] init];
                //controller.delegate = self;
                _menuCtrl = controller;
                
            }
            
            
            CGRect menuFrame = _menuCtrl.view.frame;
            CGRect mainFrame = _navigationController.view.frame;
            CGRect mainToSelfFrame = [self.view convertRect:mainFrame fromView:_navigationController.view];
            menuFrame.origin.x = -1*menuFrame.size.width;
            if ( menuFrame.origin.x > mainFrame.origin.x - menuFrame.size.width )
                menuFrame.origin.x = mainFrame.origin.x - menuFrame.size.width;
            menuFrame.origin.y = mainToSelfFrame.origin.y;
            
            if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1)
            {
        }
            
            menuFrame.size.height = mainToSelfFrame.size.height;
#ifdef MENU_ABOVE
            [self.view insertSubview:_menuCtrl.view aboveSubview:_navigationController.view];
#else
            [self.view insertSubview:_menuCtrl.view belowSubview:_navigationController.view];
#endif
            _menuCtrl.view.frame = menuFrame;
            int coffs = (_startOfAnimation.x - _endOfAnimation.x);
            mainFrame.origin.x += menuFrame.size.width+coffs-(_hiddenWidth+_overlapWidth);
            menuFrame.origin.x = mainFrame.origin.x-menuFrame.size.width+_overlapWidth;
            
            void (^animations_block)() = ^{
                _menuCtrl.view.frame = menuFrame;
                _navigationController.view.frame = mainFrame;
                //_temporaryStatusBar.alpha = 0.5;
            };
            void (^completion_block)(BOOL) = ^(BOOL finished) {
                //_navigationController.view.userInteractionEnabled = NO;
            };
            if ( animation )
            {
                [UIView transitionWithView:self.view duration:animation_time options:UIViewAnimationOptionAllowAnimatedContent | UIViewAnimationOptionLayoutSubviews
                                animations:animations_block completion:completion_block];
            }
            else
            {
                // instead of animation:
                animations_block();
                // instead of completion:
                completion_block(YES);
            }
            
#ifdef MENU_ABOVE
           // _menuCtrl.view.layer.shadowOpacity = 1;
            //_menuCtrl.view.layer.shadowOffset = CGSizeMake(1, 1);
            //_menuCtrl.view.layer.shadowRadius = 3.0;
            //CGRect shadowRect = _menuCtrl.tableView.bounds;
            //shadowRect.size = _menuCtrl.tableView.contentSize;
            //if ( shadowRect.size.height < self.view.frame.size.height )
            //    shadowRect.size.height = self.view.frame.size.height;
            //shadowRect.origin.y -= shadowRect.size.height/2;
            //shadowRect.size.height *= 2;
            //_menuCtrl.view.layer.shadowPath = [UIBezierPath bezierPathWithRect:shadowRect].CGPath;
#endif
        }
    _menuVisible = show;
}
#else
- (void) showMenu:(BOOL)show withAnimation:(BOOL)animation
{
    float animation_time = 0.25;
    if ( _menuVisible && !show )
    { // hide menu
        CGRect menuFrame = _menuCtrl.view.frame;
        CGRect mainFrame = _navigationController.view.frame;
        int coffs = (_startOfAnimation.x - _endOfAnimation.x);
        mainFrame.origin.x -= menuFrame.size.width-coffs-(_hiddenWidth+_overlapWidth);
        menuFrame.origin.x = mainFrame.origin.x-menuFrame.size.width;
        
        void (^animations_block)() = ^{
            _navigationController.view.frame = mainFrame;
        };
        void (^completion_block)(BOOL) = ^(BOOL finished) {
            _navigationController.view.userInteractionEnabled = YES;
        };
        if ( animation )
        {
            [UIView transitionWithView:self.view duration:animation_time options:UIViewAnimationOptionAllowAnimatedContent | UIViewAnimationOptionLayoutSubviews
                            animations:animations_block completion:completion_block];
        }
        else
        {
            // instead of animation:
            animations_block();
            // instead of completion:
            completion_block(YES);
        }
    }
    else
        if ( !_menuVisible && show )
        { // show menu
            CGRect menuFrame = _menuCtrl.view.frame;
            CGRect mainFrame = _navigationController.view.frame;
            CGRect mainToSelfFrame = [self.view convertRect:mainFrame fromView:_navigationController.view];
            menuFrame.origin.x = -1*menuFrame.size.width;
            if ( menuFrame.origin.x > mainFrame.origin.x - menuFrame.size.width )
                menuFrame.origin.x = mainFrame.origin.x - menuFrame.size.width;
            menuFrame.origin.y = mainToSelfFrame.origin.y;
            menuFrame.size.height = mainToSelfFrame.size.height;
            int coffs = (_startOfAnimation.x - _endOfAnimation.x);
            mainFrame.origin.x += menuFrame.size.width+coffs-(_hiddenWidth+_overlapWidth);
            menuFrame.origin.x = mainFrame.origin.x-menuFrame.size.width+_overlapWidth;
            
            void (^animations_block)() = ^{
                _navigationController.view.frame = mainFrame;
            };
            void (^completion_block)(BOOL) = ^(BOOL finished) {
                //_navigationController.view.userInteractionEnabled = NO;
            };
            if ( animation )
            {
                [UIView transitionWithView:self.view duration:animation_time options:UIViewAnimationOptionAllowAnimatedContent | UIViewAnimationOptionLayoutSubviews
                                animations:animations_block completion:completion_block];
            }
            else
            {
                // instead of animation:
                animations_block();
                // instead of completion:
                completion_block(YES);
            }
        }
    _menuVisible = show;
}
#endif

- (void) showRightMenu:(BOOL)show withAnimation:(BOOL)animation
{
    float animation_time = 0.25;
    if ( _menuVisible && !show )
    { // hide favorites

        CGRect favoritesFrame = _menuCtrl.view.frame;
        CGRect mainFrame = _navigationController.view.frame;
        //int coffs = (_startOfAnimation.x - _endOfAnimation.x);
        mainFrame.origin.x = 0;
        favoritesFrame.origin.x = mainFrame.origin.x+mainFrame.size.width;
        
        void (^animations_block)() = ^{
#ifndef STATIC_MENU
            _menuCtrl.view.frame = favoritesFrame;
#endif
            _navigationController.view.frame = mainFrame;
        };
        void (^completion_block)(BOOL) = ^(BOOL finished) {
//#ifndef STATIC_MENU
//            [_menuCtrl.view removeFromSuperview];
//            [_menuCtrl release];
//            _menuCtrl = Nil;
//#else
            _menuCtrl.view.hidden = YES;
//#endif
            _navigationController.visibleViewController.view.userInteractionEnabled = YES;
        };
        if ( animation )
        {
            [UIView transitionWithView:self.view duration:animation_time options:UIViewAnimationOptionAllowAnimatedContent | UIViewAnimationOptionLayoutSubviews
                            animations:animations_block completion:completion_block];
        }
        else
        {
            // instead of animation:
            animations_block();
            // instead of completion:
            completion_block(YES);
        }
    }
    else
        if ( !_menuVisible && show )
        { // show favorites
//#ifndef STATIC_MENU
//            if ( !_menuCtrl )
//            {
//                _menuCtrl = [[STMenuViewController alloc] init];
//                _menuCtrl.menuDataSource = menuDataSource;
                
 //           }
//#else
            _menuCtrl.view.hidden = NO;
//#endif
            CGRect favoritesFrame = _menuCtrl.view.frame;
            CGRect mainFrame = _navigationController.view.frame;
            favoritesFrame.origin.x = self.view.bounds.size.width;
            if ( favoritesFrame.origin.x < mainFrame.origin.x + mainFrame.size.width )
                favoritesFrame.origin.x = mainFrame.origin.x + mainFrame.size.width;
            favoritesFrame.origin.y = self.view.frame.origin.y;
            if ( (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) &&
                (self.navigationController.navigationBar.translucent) )
            {
                favoritesFrame.origin.y+=64;
            }
            favoritesFrame.size.height = self.view.bounds.size.height;
#ifndef STATIC_MENU
            _menuCtrl.view.frame = favoritesFrame;
#endif
            
            // handle menu
            CGRect menuFrame;
            if ( _menuVisible )
            {
                menuFrame = _menuCtrl.view.frame;
                menuFrame.origin.x -= menuFrame.size.width-_hiddenWidth;
                menuFrame.origin.x -= favoritesFrame.size.width-(_hiddenWidth+_overlapWidth);
                mainFrame.origin.x -= menuFrame.size.width-(_hiddenWidth+_overlapWidth);
                favoritesFrame.origin.x -= favoritesFrame.size.width-(_hiddenWidth+_overlapWidth);
            }
            int coffs = (_endOfAnimation.x - _startOfAnimation.x);
            mainFrame.origin.x -= favoritesFrame.size.width+coffs-(_hiddenWidth+_overlapWidth);
            favoritesFrame.origin.x = mainFrame.origin.x+mainFrame.size.width-_overlapWidth;
            
            void (^animations_block)() = ^{
#ifndef STATIC_MENU
                if ( _menuVisible )
                    _menuCtrl.view.frame = menuFrame;
                _menuCtrl.view.frame = favoritesFrame;
#endif
                _navigationController.view.frame = mainFrame;
            };
            void (^completion_block)(BOOL) = ^(BOOL finished) {
                if ( _menuVisible )
                {
#ifndef STATIC_MENU
                    //[_menuCtrl.view removeFromSuperview];
                    //[_menuCtrl release];
                    //_menuCtrl = Nil;
#else
                    _menuCtrl.view.hidden = NO;
#endif
                    //_menuVisible = NO;
                }
                _navigationController.visibleViewController.view.userInteractionEnabled = NO;
            };
            if ( animation )
            {
                [UIView transitionWithView:self.view duration:animation_time options:UIViewAnimationOptionAllowAnimatedContent | UIViewAnimationOptionLayoutSubviews
                                animations:animations_block completion:completion_block];
            }
            else
            {
                // instead of animation:
                animations_block();
                // instead of completion:
                completion_block(YES);
            }
            
#ifndef STATIC_MENU
            _menuCtrl.view.layer.shadowOpacity = 1;
            _menuCtrl.view.layer.shadowOffset = CGSizeMake(1, 1);
            _menuCtrl.view.layer.shadowRadius = 3.0;
            CGRect shadowRect = _menuCtrl.tableView.bounds;
            shadowRect.size = _menuCtrl.tableView.contentSize;
            if ( shadowRect.size.height < self.view.frame.size.height )
                shadowRect.size.height = self.view.frame.size.height;
            shadowRect.origin.y -= shadowRect.size.height/2;
            shadowRect.size.height *= 2;
            _menuCtrl.view.layer.shadowPath = [UIBezierPath bezierPathWithRect:shadowRect].CGPath;
#endif
        }
    _menuVisible = show;
}

#pragma mark - Navigation Logic

- (void) navigationController:(UINavigationController *)navigationCont willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    _panGestureRecognizer.enabled       = [self viewControllerShouldShowSideBar:viewController];
    [navigationCont setNavigationBarHidden:![self viewControllerShouldShowNavigationBar:viewController] animated:YES];
     navigationCont.toolbarHidden = ![self viewControllerShouldShowToolbar:viewController];
}

- (BOOL) viewControllerShouldShowNavigationBar: (UIViewController*) controller
{
    // An array of class names of view controllers (stored in strings)
    // that should NOT show the navigation bar
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        if (PFBrandingSupported(BrandingTechnopark, nil))
            navigationBarTitles = @[@"DSPF_Login"];
        else
            navigationBarTitles = @[];
        [navigationBarTitles retain];
    });
    
    Class class     = [controller class];
    NSInteger index = [navigationBarTitles indexOfObject:NSStringFromClass(class)];
    return (index == NSNotFound);
}

- (BOOL) viewControllerShouldShowToolbar: (UIViewController*) controller
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        if (PFBrandingSupported(BrandingTechnopark, nil))
            toolbarTitles = @[@"DSPF_TourLocation", @"DSPF_Tour"];
        else
            toolbarTitles = @[];
        [toolbarTitles retain];
    });
    
    Class class     = [controller class];
    NSInteger index = [toolbarTitles indexOfObject:NSStringFromClass(class)];
    return (index != NSNotFound);

}

- (id<UIViewControllerAnimatedTransitioning>) navigationController:(UINavigationController *)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation fromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC
{
    if (PFBrandingSupported(BrandingTechnopark, nil))
    {
        toVC.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navItem_sidePanel.png"]
                                                                                            style:UIBarButtonItemStyleBordered
                                                                                           target:self
                                                                                           action:@selector(toggleMenu:)];
    }
    return nil;
}

- (BOOL) viewControllerShouldShowSideBar: (UIViewController*) controller
{
    // An array of class names of view controllers (stored in strings)
    // that should NOT show the side bar
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sideBarTitles = @[@"DSPF_Login"];
        [sideBarTitles retain];
    });
    
    Class class     = [controller class];
    NSInteger index = [sideBarTitles indexOfObject:NSStringFromClass(class)];
    return (index == NSNotFound);
}


#pragma mark - Interface Methods

- (void) updateSideBar
{
    [_menuCtrl.tableView.tableHeaderView setNeedsDisplay];
}

- (void) switchBackToWorkspace
{
    [self toggleMenu:nil];
    
    if (_workflowStack)
    {
        [self.navigationController setViewControllers:_workflowStack animated:NO];
        self.workflowStack = nil;
    }
}

- (void) switchToExternalViewController:(UIViewController *)viewController
{
    [self toggleMenu:nil];
    if (![self.navigationController.visibleViewController isKindOfClass:[viewController class]])
    {
        if (!_workflowStack)
            self.workflowStack = [NSArray arrayWithArray:self.navigationController.viewControllers];
        
        [self.navigationController setViewControllers:@[viewController] animated:NO];
    }
}

- (void) setSideBarGestureEnabled:(BOOL)sideBarGestureEnabled
{
    _sideBarGestureEnabled = sideBarGestureEnabled;
    _panGestureRecognizer.enabled = sideBarGestureEnabled;
}

@end
