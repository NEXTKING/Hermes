//
//  UIViewController.m
//  dphHermes
//
//  Created by Tomasz Krasnyk on 22.05.15.
//
//

#import "UIViewController+Additions.h"
#import <objc/runtime.h>

NSString * const ControllerParameterItem = @"ControllerParameterItem";
NSString * const ControllerParameterTourTask = @"ControllerParameterTourTask";
NSString * const ControllerParameterPreventScanning = @"ControllerParameterPreventScanning";
NSString * const ControllerParameterDelegate = @"ControllerParameterDelegate";
NSString * const ControllerTransportGroupTourStop = @"ControllerTransportGroupTourStop";
NSString * const ControllerTransportBoxCode = @"ControllerTransportBoxCode";
NSString * const ControllerTriggerSynchronisationOnExit = @"ControllerTriggerSynchronisationOnExit";

@implementation UIViewController (Additions)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        /*
         If the method we're swizzling is actually defined in a superclass,
         we have to use class_addMethod to add an implementation to the target class.
         Then we can use class_replaceMethod to replace the swizzled one with the superclass's implementation,
         so our new version will be able to correctly call the "old" one.
         If the method is defined in the target class, class_addMethod will fail,
         but then we can use method_exchangeImplementations to just swap the new and old versions.
         */
        Class class = [self class];
        
        SEL originalSelector = @selector(init);
        SEL swizzledSelector = @selector(swizzledInit);
        Method originalMethod = class_getInstanceMethod(class, originalSelector);
        Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
        
        BOOL didAddMethod = class_addMethod(class, originalSelector,
                                            method_getImplementation(swizzledMethod),
                                            method_getTypeEncoding(swizzledMethod));
        if (didAddMethod) {
            class_replaceMethod(class, swizzledSelector,
                                method_getImplementation(originalMethod),
                                method_getTypeEncoding(originalMethod));
        } else {
            method_exchangeImplementations(originalMethod, swizzledMethod);
        }
        
        originalSelector = @selector(initWithNibName:bundle:);
        swizzledSelector = @selector(swizzledInitWithNibName:bundle:);
        originalMethod   = class_getInstanceMethod(class, originalSelector);
        swizzledMethod   = class_getInstanceMethod(class, swizzledSelector);
        
        didAddMethod = class_addMethod(class, originalSelector,
                                       method_getImplementation(swizzledMethod),
                                       method_getTypeEncoding(swizzledMethod));
        if (didAddMethod) {
            class_replaceMethod(class, swizzledSelector,
                                method_getImplementation(originalMethod),
                                method_getTypeEncoding(originalMethod));
        } else {
            method_exchangeImplementations(originalMethod, swizzledMethod);
        }
    });
}

- (instancetype) swizzledInitWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    // calling UIViewController -initWithNibName:bundle: method which is now named swizzledInitWithNibName:bundle
    UIViewController *controller = [self swizzledInitWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    [self setLayoutEdgesToNone];
    return controller;
}

- (instancetype) swizzledInit {
    // calling UIViewController -init method which is now named swizzledInit
    UIViewController *controller = [self swizzledInit];
    [self setLayoutEdgesToNone];
    return controller;
}

- (void) setLayoutEdgesToNone {
    if (PFOsVersionCompareGE(@"7.0")) {
        [self setValue:@(0) forKeyPath:@"edgesForExtendedLayout"];
    }
}

- (void) forceSetReadOnlyPropertyOfSearchDisplayController:(id) searchDisplayController {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    [self performSelector:NSSelectorFromString(@"setSearchDisplayController:") withObject:searchDisplayController];
#pragma clang diagnostic pop
}

@end
