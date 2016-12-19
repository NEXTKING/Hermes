//
//  UIResponder.m
//  dphHermes
//
//  Created by Tomasz Krasnyk on 22.05.15.
//
//

#import "UIResponder+Additions.h"

@implementation UIResponder (Additions)

+ (void) dismissCurrentAlertController {
    [[UIApplication sharedApplication] sendAction:@selector(dismissCurrentAlertController:) to:nil from:nil forEvent:nil];
}

- (void) dismissCurrentAlertController:(id)sender {
    if ([NSStringFromClass([self class]) isEqualToString:@"UIAlertController"]) {
        [self resignFirstResponder];
    }
}

@end