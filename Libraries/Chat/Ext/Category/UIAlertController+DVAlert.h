//
//  UIAlertController+DVAlert.h
//  DotVPN
//
//  Created by hena on 1/12/15.
//  Copyright (c) 2015 hena. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIAlertController (DVAlert)

//@property (nonatomic, weak) id <UIAlertControllerDelegate> delegateCustomAlert;

+ (UIAlertController *)showErrorAlert:(NSError *)error;
+ (UIAlertController *)showSuccessAlert:(NSString *)message;

@end
