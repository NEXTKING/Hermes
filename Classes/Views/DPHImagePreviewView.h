//
//  DPHImagePreviewView.h
//  dphHermes
//
//  Created by Tomasz Krasnyk on 22.07.15.
//
//

#import <UIKit/UIKit.h>

@interface DPHImagePreviewView : UIView

@property (nonatomic, strong, readonly) UIScrollView *scrollView;
@property (nonatomic, strong, readonly) UIImageView *imageView;
@property (nonatomic, strong, readonly) UITextField *textField;
@property (nonatomic, assign) BOOL textFieldRequired;

@end
