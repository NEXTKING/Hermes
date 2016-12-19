//
//  PasteboardLabel.m
//  ChatModule
//
//  Created by Виктория on 31.03.16.
//  Copyright © 2016 Виктория. All rights reserved.
//

#import "PasteboardLabel.h"

@implementation PasteboardLabel

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    return (action == @selector(copy:));
}

#pragma mark - UIResponderStandardEditActions

- (UIMenuItem *)menuItemRemove
{
    return [[UIMenuItem alloc] initWithTitle:@"Remove" action:@selector(remove:)];
}

- (void)remove:(id)sender
{
    self.text = @"";
}

- (UIMenuItem *)menuItemCopy
{
    return [[UIMenuItem alloc] initWithTitle:@"Copy" action:@selector(copy:)];
}

- (void)copy:(id)sender
{
    self.text = self.text;
}


@end
