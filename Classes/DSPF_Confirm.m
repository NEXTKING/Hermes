//
//  DSPF_Confirm.m
//  Hermes
//
//  Created by Lutz  Thalmann on 16.12.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "DSPF_Confirm.h"


@implementation DSPF_Confirm

@synthesize actionSheet;
@synthesize	item;
@synthesize delegate;

+ (DSPF_Confirm *)question:(NSString *)question item:(NSObject *)item
            buttonTitleYES:(NSString *)buttonTitleYES
             buttonTitleNO:(NSString *)buttonTitleNO
                showInView:(UIView *)aView {
	return [[DSPF_Confirm alloc] initWithQuestion:question item:item
                                   buttonTitleYES:buttonTitleYES
                                    buttonTitleNO:buttonTitleNO
                                       showInView:aView];
}

+ (DSPF_Confirm *)question:(NSString *)question item:(NSObject *)item
             buttonTitleOK:(NSString *)buttonTitleOK
            buttonTitleYES:(NSString *)buttonTitleYES
             buttonTitleNO:(NSString *)buttonTitleNO
                showInView:(UIView *)aView {
	return [[DSPF_Confirm alloc] initWithQuestion:question item:item
                                    buttonTitleOK:buttonTitleOK
                                   buttonTitleYES:buttonTitleYES
                                    buttonTitleNO:buttonTitleNO
                                       showInView:aView];
}

- (id) initWithQuestion:(NSString *)aQuestion item:(NSObject *)aItem
         buttonTitleYES:(NSString *)aButtonTitleYES
          buttonTitleNO:(NSString *)aButtonTitleNO
             showInView:(UIView *)aView {
    self = [super init];
    if(self) {
        self.item			= aItem;
        self.actionSheet    = [[[UIActionSheet alloc] initWithTitle:aQuestion
                                                           delegate:self
                                                  cancelButtonTitle:aButtonTitleNO
                                             destructiveButtonTitle:aButtonTitleYES
                                                  otherButtonTitles:nil] autorelease];
        self.actionSheet.actionSheetStyle = UIActionSheetStyleAutomatic;
        //      self.actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
        [self.actionSheet showInView:aView];
    }
	return self;
}

- (id) initWithQuestion:(NSString *)aQuestion item:(NSObject *)aItem
          buttonTitleOK:(NSString *)aButtonTitleOK
         buttonTitleYES:(NSString *)aButtonTitleYES
          buttonTitleNO:(NSString *)aButtonTitleNO
             showInView:(UIView *)aView {
    self = [super init];
    if (self) {
        self.item			= aItem;
        self.actionSheet    = [[[UIActionSheet alloc] initWithTitle:aQuestion
                                                           delegate:self
                                                  cancelButtonTitle:aButtonTitleNO
                                             destructiveButtonTitle:aButtonTitleYES
                                                  otherButtonTitles:aButtonTitleOK, nil] autorelease];
        self.actionSheet.actionSheetStyle = UIActionSheetStyleAutomatic;
        //      self.actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
        [self.actionSheet showInView:aView];
    }
	return self;
}

- (void)actionSheet:(UIActionSheet *)aActionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    [self.delegate dspf_Confirm:self didConfirmQuestion:self.actionSheet.title item:self.item withButtonTitle:[self.actionSheet buttonTitleAtIndex:buttonIndex]];
    [self autorelease];
}

-(void) dealloc {
    [actionSheet    release];
	[item           release];
    [super    dealloc];
}

@end
