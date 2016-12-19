//
//  DPButtonsView.h
//  dphHermes
//
//  Created by Tomasz Kransyk on 07.05.15.
//
//

#import <UIKit/UIKit.h>

@interface DPHButtonsView : UIView

@property (nonatomic, assign) CGFloat buttonsHeight;
@property (nonatomic, assign) CGFloat verticalSeparator;
@property (nonatomic, assign) CGFloat horizontalSeparator;
@property (nonatomic, strong) NSArray *buttons;
@property (nonatomic, assign) BOOL verticalArrangement;

- (UIButton *) buttonWithTitle:(NSString *) title;

+ (UIButton *) grayButtonWithTitle:(NSString *) title;

@end
