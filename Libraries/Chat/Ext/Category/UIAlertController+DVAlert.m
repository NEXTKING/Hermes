//
//  UIAlertController+DVAlert.m
//  DotVPN
//
//  Created by hena on 1/12/15.
//  Copyright (c) 2015 hena. All rights reserved.
//

#import "UIAlertController+DVAlert.h"

@implementation UIAlertController (DVAlert)

+ (UIAlertController *)showErrorAlert:(NSError *)error
{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Error"
                                                                   message:error.localizedDescription
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {}];
    
    [alert addAction:defaultAction];
    return alert;
}

+ (UIAlertController *)showSuccessAlert:(NSString *)message {
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Success"
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {}];
    
    [alert addAction:defaultAction];
    return alert;
}

@end
