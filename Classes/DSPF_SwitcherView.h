//
//  DSPF_SwitcherView.h
//  dphHermes
//
//  Created by Denis Kurochkin on 09.11.15.
//
//

#import <UIKit/UIKit.h>

@class DSPF_SwitcherView;

@protocol SwitcherViewDelegate <NSObject>

@optional
- (void) switcherView:(DSPF_SwitcherView*)switcher didSwitchToStateWithOptions:(NSDictionary*) options;

@end

@interface DSPF_SwitcherView : UIView

@property (nonatomic, assign) id<SwitcherViewDelegate> delegate;
@property (nonatomic, assign, readonly) NSInteger numberOfStates;
@property (nonatomic, assign, readonly) NSInteger currentState;
@property (retain, nonatomic) IBOutlet UIButton *prevButton;
@property (retain, nonatomic) IBOutlet UIButton *nextButton;

- (void) addStateWithTitle:(NSString*)title options:(NSDictionary*) options;
- (void) switchNext:(id)sender;
- (void) switchPrev:(id)sender;
- (void) switchToState:(NSInteger) state;

@end
