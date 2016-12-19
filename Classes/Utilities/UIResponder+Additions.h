//
//  UIResponder.h
//  dphHermes
//
//  Created by Tomasz Krasnyk on 22.05.15.
//
//

#import <UIKit/UIKit.h>

@interface UIResponder(Additions)

+ (void) dismissCurrentAlertController;
- (void) dismissCurrentAlertController:(id)sender;

@end
