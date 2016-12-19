//
//  UIView+Coordinate.m
//  ModelAlliance
//
//  Created by Imac on 25.11.15.
//  Copyright © 2015 Mac. All rights reserved.
//

#import "UIView+Coordinate.h"

@implementation UIView (Coordinate)
@dynamic top, bottom, centerY, centerX, width, height;

- (CGFloat)top {
    return self.frame.origin.y;
}

- (CGFloat)bottom {
    return self.frame.origin.y+self.frame.size.height;
}

- (CGFloat)centerX {
    return self.frame.origin.x+self.frame.size.width/2;
}

- (CGFloat)centerY {
    return self.frame.origin.y + self.frame.size.height/2;
}

- (CGFloat)width {
    return self.frame.size.width;
}

- (CGFloat)height {
    return self.frame.size.height;
}

@end
