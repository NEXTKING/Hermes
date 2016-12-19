//
//  UISmartScrollView.m
//  MobileBanking
//
//  Created by power on 26.11.14.
//  Copyright (c) 2014 BPC. All rights reserved.
//

#import "UISmartScrollView.h"

@interface UISmartScrollView ()
{
    BOOL _areInsetsSaved;
    UIEdgeInsets _savedContentInsets;
    UIEdgeInsets _savedScrollIndicatorInsets;
    UITapGestureRecognizer *_tapRecognizer;
}

-(void) keyboardWillShow:(NSNotification *) notif;
-(void) keyboardDidShow:(NSNotification *) notif;
-(void) keyboardWillHide:(NSNotification *) notif;
-(void) keyboardDidHide:(NSNotification *) notif;
-(void) didTapAnywhere:(UITapGestureRecognizer*) recognizer;

@end

@implementation UISmartScrollView

- (void)initialize
{
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    
    [nc addObserver:self selector:@selector(keyboardWillShow:) name:
     UIKeyboardWillShowNotification object:nil];
    [nc addObserver:self selector:@selector(keyboardDidShow:) name:
     UIKeyboardDidShowNotification object:nil];
    [nc addObserver:self selector:@selector(keyboardWillHide:) name:
     UIKeyboardWillHideNotification object:nil];
    [nc addObserver:self selector:@selector(keyboardDidHide:) name:
     UIKeyboardDidHideNotification object:nil];
    
    if ( !_tapRecognizer )
        _tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                 action:@selector(didTapAnywhere:)];
}

- (void)uninitialize
{
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    
    [nc removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [nc removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [nc removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [nc removeObserver:self name:UIKeyboardDidHideNotification object:nil];
    
    if ( _tapRecognizer )
    {
        [_tapRecognizer release];
        _tapRecognizer = Nil;
    }
}

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code
        [self initialize];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self initialize];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initialization code
        [self initialize];
    }
    return self;
}

- (void) dealloc
{
    [self uninitialize];
    
    [_tapRecognizer release];
    [super dealloc];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (UIView *) findFirstResponderView:(UIView *)view
{
    if ( [view isFirstResponder] )
        return view;
    
    UIView *firstResponder = Nil;
    NSArray *subviews = view.subviews;
    if ( subviews && subviews.count > 0 )
    {
        for (NSUInteger i=0; i<subviews.count; ++i )
        {
            id subview = [subviews objectAtIndex:i];
            
            if ( subview && [subview isKindOfClass:[UIView class]] )
            {
                firstResponder = [self findFirstResponderView:subview];
                if ( firstResponder )
                    return firstResponder;
            }
        }
    }
    
    return Nil;
}

-(void) keyboardWillShow:(NSNotification *) note
{
    [self addGestureRecognizer:_tapRecognizer];
}

-(void) keyboardDidShow:(NSNotification *) notification
{
    // Get keyboard size
    NSDictionary* info = [notification userInfo];
    CGSize keyboardSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    // Get screen size
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    // Get scroll view rect
    CGRect scrollRect = self.frame;
    
    {
        UIView *topView = self;
        while ( topView.superview )
            topView = topView.superview;
        scrollRect = [topView convertRect:scrollRect fromView:self.superview];
    }
    
    if ( scrollRect.origin.y+scrollRect.size.height > screenSize.height-keyboardSize.height )
    {   // keyboard overlays scroll view
        // calculate overlay height
        CGFloat overlayHeight = keyboardSize.height - (screenSize.height-scrollRect.origin.y-scrollRect.size.height);
        
        // Increase scroll view content insets to overlay height
        UIEdgeInsets contentInsets = self.contentInset;
        contentInsets.bottom = overlayHeight;
        UIEdgeInsets scrollIndicatorInsets = self.scrollIndicatorInsets;
        scrollIndicatorInsets.bottom = overlayHeight;
        _savedContentInsets = self.contentInset;
        _savedScrollIndicatorInsets = self.scrollIndicatorInsets;
        _areInsetsSaved = YES;
        if ( _savedContentInsets.bottom <= contentInsets.bottom )
        {
            self.contentInset = contentInsets;
            self.scrollIndicatorInsets = scrollIndicatorInsets;
        }
    }
    
    // If active text field is hidden by keyboard, scroll it so it's visible
    // Find first responder view automatically.
    UIView *firstResponder = [self findFirstResponderView:self];
    CGRect aRect = self.frame;
    aRect.size.height -= keyboardSize.height;
    CGRect frRect = [self convertRect:firstResponder.frame fromView:firstResponder.superview];
    CGPoint testPoint = CGPointMake(frRect.origin.x+frRect.size.width/2, frRect.origin.y+frRect.size.height);
    if (!CGRectContainsPoint(aRect, testPoint) ) {
        [self scrollRectToVisible:frRect animated:YES];
    }
}

-(void) keyboardWillHide:(NSNotification *) note
{
    [self removeGestureRecognizer:_tapRecognizer];
}

-(void) keyboardDidHide:(NSNotification *)notif
{
    if ( !_areInsetsSaved )
        return;
    
    [UIView beginAnimations:@"removeContentInset" context:nil];
    [UIView setAnimationDuration:0.3];

    self.contentInset = _savedContentInsets;
    self.scrollIndicatorInsets = _savedScrollIndicatorInsets;
    _areInsetsSaved = NO;

    [UIView commitAnimations];
}

-(void) didTapAnywhere: (UITapGestureRecognizer*) recognizer
{
    [self endEditing:YES];
}

@end
