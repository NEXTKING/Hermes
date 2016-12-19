//
//  DPHDeviceHandOver.h
//  dphHermes
//
//  Created by Tomasz Krasnyk on 08.10.15.
//
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface DPHDeviceHandOver : NSObject
@property (nonatomic, assign, readonly) BOOL processingDeviceHandOver;

- (void) tryHandingDeviceOver;

@end
