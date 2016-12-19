//
//  DSPF_ImagePicker.h
//  Hermes
//
//  Created by Lutz  Thalmann on 29.03.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DPHImagePreviewView.h"
#import <AudioToolbox/AudioServices.h>

@protocol DSPF_ImagePickerDelegate;

extern NSString * const ImagePickerDescriptionTextFieldVisible;
extern NSString * const ImagePickerDescriptionTextRequired;

@interface DSPF_ImagePicker : UIImagePickerController <UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextFieldDelegate> {
    id<DSPF_ImagePickerDelegate> __unsafe_unretained pickerDelegate;
    DPHImagePreviewView *previewView;
}

- (instancetype) initWithParameters:(NSDictionary *) parameters;

@property (nonatomic, unsafe_unretained)          id <DSPF_ImagePickerDelegate> pickerDelegate;

- (void)cancleImagePicker:(id)sender;
- (void)takePhoto:(id)sender;
- (void)retakePhoto:(id)sender;
- (void)savePhoto:(id)sender;

@end


@protocol DSPF_ImagePickerDelegate
- (void)didFinishWithPhoto:(UIImage *)picture descriptionText:(NSString *)descriptionText userInfo:(NSDictionary *) userInfo;
- (void)didFinishWithoutPhoto;
@end
