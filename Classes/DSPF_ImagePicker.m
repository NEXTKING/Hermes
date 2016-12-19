//
//  DSPF_ImagePicker.m
//  Hermes
//
//  Created by Lutz  Thalmann on 29.03.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DSPF_ImagePicker.h"

NSString * const ImagePickerDescriptionTextFieldVisible = @"ImagePickerDescriptionTextFieldVisible";
NSString * const ImagePickerDescriptionTextRequired = @"ImagePickerDescriptionTextRequired";
NSString * const ImagePickerDescriptionText = @"ImagePickerDescriptionText";

const CGFloat toolbarHeight = 44.0f;

@interface DSPF_ImagePicker()
@property (nonatomic, strong) UIToolbar *controlsToolbar;
@property (nonatomic, strong) NSDictionary *parameters;
@end

@implementation DSPF_ImagePicker {
    UIBarButtonItem *saveButton;
}
@synthesize pickerDelegate;
@synthesize controlsToolbar;
@synthesize parameters;

#pragma mark - OverlayViewController

- (instancetype)init {
    return [self initWithParameters:nil];
}

- (instancetype) initWithParameters:(NSDictionary *) theParameters {
    if ((self = [super init])) {
        self.parameters = theParameters;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeShown:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeHidden:) name:UIKeyboardWillHideNotification object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) viewDidLoad {
    [super viewDidLoad];
    
    saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemOrganize target:self action:@selector(savePhoto:)];
    controlsToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0f, CGRectGetHeight(self.view.bounds) - toolbarHeight,
                                                                  CGRectGetWidth(self.view.bounds), toolbarHeight)];
    controlsToolbar.items = [self toolbarItemsToTakePhoto];
    
    self.sourceType          = UIImagePickerControllerSourceTypeCamera;
    self.showsCameraControls = NO;
    self.delegate            = self;
    
    CGRect overlayViewFrame     = self.cameraOverlayView.frame;
    CGRect toolbarRect = CGRectMake(0.0f, CGRectGetHeight(overlayViewFrame) - toolbarHeight, CGRectGetWidth(overlayViewFrame), toolbarHeight);
    CGRect imgFrame = CGRectMake(0.0f, 0.0f, CGRectGetWidth(overlayViewFrame), CGRectGetHeight(overlayViewFrame) - toolbarHeight);
    
    controlsToolbar.frame = toolbarRect;
    [self.cameraOverlayView addSubview:controlsToolbar];
    
    previewView = [[DPHImagePreviewView alloc] initWithFrame:imgFrame];
    previewView.textField.placeholder = NSLocalizedString(@"MESSAGE__102", nil);
    previewView.textField.delegate = self;
    [previewView.textField addTarget:self action:@selector(textFieldEditingChanged:) forControlEvents:UIControlEventEditingChanged];
    previewView.textField.hidden = ![self descriptionTextFieldVisible];
    previewView.textFieldRequired = [self descriptionRequired];
    
    [AppStyle customizePickerViewToolbar:controlsToolbar];
    
    [self textFieldEditingChanged:previewView.textField];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    
    previewView    = nil;
    self.controlsToolbar = nil;
}

- (NSArray *) toolbarItemsToTakePhoto {
    UIBarButtonItem *cameraButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(takePhoto:)];
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(cancleImagePicker:)];
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    return @[flexibleSpace, cancelButton, flexibleSpace, flexibleSpace, flexibleSpace, cameraButton, flexibleSpace];
}

- (NSArray *) toolbarItemsToAcceptPhoto {
    UIBarButtonItem *trashButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(retakePhoto:)];
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    return @[flexibleSpace, trashButton, flexibleSpace, flexibleSpace, flexibleSpace, saveButton, flexibleSpace];
}

#pragma mark - Image Processing

- (UIImage *)imageWithImage:(UIImage *)sourceImage scaledToSize:(CGSize )targetSize {
    UIImageOrientation imageOrientation;
    if (targetSize.height > targetSize.width) { 
        imageOrientation  = UIImageOrientationRight;
    } else {
        imageOrientation  = UIImageOrientationDown;
    }
    UIImage *newImage = [UIImage imageWithCGImage:sourceImage.CGImage scale:1.0 orientation:imageOrientation];
    UIGraphicsBeginImageContext(targetSize);
    [newImage drawInRect:CGRectMake(0, 0, targetSize.width, targetSize.height)];
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

#pragma mark - Camera Actions

- (IBAction)cancleImagePicker:(id)sender {
    [self.pickerDelegate didFinishWithoutPhoto];
}

- (IBAction)takePhoto:(id)sender {
    [self takePicture];
}

- (IBAction)retakePhoto:(id)sender {
    [self.controlsToolbar setItems:[self toolbarItemsToTakePhoto] animated:YES];
    [previewView removeFromSuperview];
}

- (IBAction)savePhoto:(id)sender {
    [self.pickerDelegate didFinishWithPhoto:previewView.imageView.image descriptionText:previewView.textField.text userInfo:nil];
}

#pragma mark - configuration

- (BOOL) descriptionRequired {
    return [[self.parameters objectForKey:ImagePickerDescriptionTextRequired] boolValue];
}

- (BOOL) descriptionTextFieldVisible {
    return [[self.parameters objectForKey:ImagePickerDescriptionTextFieldVisible] boolValue];
}

#pragma mark - UIImagePickerControllerDelegate


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    previewView.imageView.image = [self imageWithImage:(UIImage *)[info valueForKey:UIImagePickerControllerOriginalImage]
                             scaledToSize:CGSizeMake(480, 640)];
    [self.cameraOverlayView addSubview:previewView];
    [self.controlsToolbar setItems:[self toolbarItemsToAcceptPhoto] animated:YES];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self.pickerDelegate didFinishWithoutPhoto]; 
}

#pragma mark - Keyboard

- (void)keyboardWillBeShown:(NSNotification*)aNotification {
    NSDictionary* info = [aNotification userInfo];
    CGSize keyboardSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    [previewView.scrollView setContentOffset:CGPointMake(0.0f, keyboardSize.height - toolbarHeight) animated:YES];
}

- (void)keyboardWillBeHidden:(NSNotification*)aNotification {
    [previewView.scrollView setContentOffset:CGPointMake(0.0f, 0.0f) animated:YES];
}

#pragma mark - UITextField delegate

- (void)textFieldEditingChanged:(UITextField *) textField {
    if ([self descriptionRequired]) {
        saveButton.enabled =  (textField.text.length > 0);
        previewView.textFieldRequired = (textField.text.length == 0);
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

@end

