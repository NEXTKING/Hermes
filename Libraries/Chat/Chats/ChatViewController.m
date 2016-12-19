//
//  ChatViewController.m
//  ChatModule
//
//  Created by Виктория on 06.04.16.
//  Copyright © 2016 Виктория. All rights reserved.
//

#import "ChatViewController.h"
#import "DBCameraViewController.h"
#import "DBCameraLibraryViewController.h"
#import "MWCommon.h"
#import "MWPhotoBrowser.h"
#import "TextMessageCell.h"
#import "UIImage+RoundedCorner.h"
#import "UIAlertController+DVAlert.h"
#import "User.h"

#define allTrim( object ) [object stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet] ]

@interface ChatViewController () <TextMessageCellDelegate, DBCameraViewControllerDelegate,MWPhotoBrowserDelegate>
{
    NSInteger userID;
}


@property (nonatomic, strong) NSMutableArray *photos;
@property (nonatomic, strong) NSMutableArray *thumbs;

@end

@implementation ChatViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    //userID = [[NSUserDefaults currentUserID] integerValue];
    User* currentUser =  [User userWithUserID:[NSUserDefaults currentUserID] inCtx:ctx()];
    userID = [currentUser.username integerValue];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    self.tableView.backgroundColor = [UIColor  clearColor];
    self.tableView.backgroundView.backgroundColor = [UIColor clearColor];
    self.tableView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
    
    //self.view.backgroundColor = [UIColor redColor];
    // slk settings
    
    self.bounces = NO;
    self.shakeToClearEnabled = YES;
    self.keyboardPanningEnabled = YES;
    self.shouldScrollToBottomAfterKeyboardShows = NO;
    self.inverted = YES;
    
    //input textview settings
    
    self.textView.placeholder = @"Введите сообщение";
    self.textView.placeholderColor = [UIColor lightGrayColor];
    self.textView.keyboardAppearance = UIKeyboardAppearanceLight;
    
    //input bar settings
    
    self.textInputbar.barTintColor = [UIColor colorWithRed:225.0/255.0 green:228.0/255.0 blue:231.0/255.0 alpha:1.0];
    self.textInputbar.autoHideRightButton = NO;
    self.textInputbar.tintColor = [UIColor colorWithRed:142.0/255.0 green:142.0/255.0 blue:147.0/255.0 alpha:1.0];
    self.textInputbar.translucent = NO;
    
    
    self.rightButton.tintColor = [UIColor colorWithRed:95.0/255.0 green:129.0/255.0 blue:243.0/255.0 alpha:1.0];
    [self.rightButton setTitle:@"Send" forState:UIControlStateNormal];
    [self.rightButton setTitleColor:[UIColor colorWithRed:142.0/255.0 green:142.0/255.0 blue:147.0/255.0 alpha:1.0] forState:UIControlStateNormal];
    self.rightButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:20.0f];
    
    
    UIImage *attachmentButtonImage = [UIImage imageNamed:@"conv_attachbutton"];
    [self.leftButton setImage:attachmentButtonImage forState:UIControlStateNormal];
    
    // setup background image
    
    self.backgroundImage.image = [UIImage imageNamed:@"background"];
    self.backgroundImage.contentMode = UIViewContentModeScaleAspectFill;
    
}

#pragma mark - Actions
//------------------------------------
//                Actions
//------------------------------------

- (void) didPressRightButton:(id)sender {
    
    // send message
    [self sendMessage];
    
    [super didPressRightButton:sender];
}

- (void) didPressLeftButton:(id)sender {
    
    [self openActionSheet];
    
    [super didPressLeftButton:sender];
    
}



#pragma mark - SEND MESSAGE

- (void)sendMessage {
    
    SLKTextView *field = self.textView;
    if (!allTrim(field.text).length){
        field.text = @"";
        return;
    }
    
    ChatMessageData *message = [ChatMessageData new];
    message.text = self.textView.text.length > 0 ? self.textView.text : @"";
    //message.from = current_user;
    message.user_data = [ChatUserData new];
    message.user_data.id = userID;
    message.date = [[NSDate date] dateByAddingTimeInterval:-3600*3];
    
    NSMutableDictionary *messageDict = [NSMutableDictionary new];
    
    if (message.text.length > 0) {
        
        messageDict[@"message"] = message.text;
        //COMMON OR ID
        [[HTTPClient sharedinstance] sendMessage:messageDict forChat:self.typeOfChat fromUser:userID onSuccess:^(id response) {
            [self addNewMessage:message];
        } onFailure:^(NSError *error) {
            [self presentViewController:[UIAlertController showErrorAlert:error] animated:YES completion:nil];
        }];
        
    }
    
}


- (void)sendMessageWithImage:(UIImage *) imageSend {
    
    SLKTextView *field = self.textView;
    
    ChatMessageData *message = [ChatMessageData new];
    message.text = field.text.length ? field.text : @"";
    message.user_data = [ChatUserData new];
    message.user_data.id = userID;//current_user.id
    message.date = [[NSDate date] dateByAddingTimeInterval:-3600*3];
    
    if (imageSend.size.width > imageSend.size.height) {
        message.local_photo = [imageSend imageByCroppingImage:imageSend toSize:CGSizeMake(imageSend.size.height, imageSend.size.height)];
    } else if(imageSend.size.width < imageSend.size.height) {
        message.local_photo = [imageSend imageByCroppingImage:imageSend toSize:CGSizeMake(imageSend.size.width, imageSend.size.width)];
    } else if(imageSend.size.width == imageSend.size.height)  {
        message.local_photo = imageSend;
    }
    
    NSMutableDictionary *messageDict = [NSMutableDictionary new];
    //NSMutableDictionary *bodyDict = [NSMutableDictionary new];
    
    CGFloat maxSize = 640.0f;
    
    UIImage *scaledImage;
    if (imageSend.size.width > maxSize) {
        UIGraphicsBeginImageContext(CGSizeMake(maxSize, maxSize * imageSend.size.height / imageSend.size.width));
        [imageSend drawInRect:CGRectMake(0, 0, maxSize, maxSize * imageSend.size.height / imageSend.size.width)];
        scaledImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    
    
    NSData *imageData = UIImageJPEGRepresentation(imageSend.size.width > maxSize ? scaledImage : imageSend, 0.8);
    messageDict[@"message"] = message.text.copy;
    messageDict[@"image"] = imageData;
    
    //COMMON OR ID
    [[HTTPClient sharedinstance] sendMessage:messageDict forChat:self.typeOfChat fromUser:userID onSuccess:^(id response) {
    
        [self addNewMessage:message];
    
    } onFailure:^(NSError *error) {
        [self presentViewController:[UIAlertController showErrorAlert:error] animated:YES completion:nil];
    }];
    self.textView.text = @"";
    
}




#pragma mark - TableView data source

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.chatData.messages count];
}

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ChatMessageData *message = [self messageAtIndexPath:indexPath];
    
    TextMessageCell *cell = [[TextMessageCell alloc] init];
    cell.bindedMessage = message;
    cell.delegate = self;
    cell.backgroundColor = [UIColor clearColor];
    cell.transform = self.tableView.transform;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ChatMessageData *message = [self messageAtIndexPath:indexPath];
    
    CGSize size = CGSizeMake(235-2, CGFLOAT_MAX);
    
    NSString *bodyString = [NSString stringWithFormat:@"%@ %@", message.text, @"             "];
    NSAttributedString *atrBodyString = [[NSAttributedString alloc] initWithString:bodyString attributes:@{NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Light" size:16]}];
    CGRect textRect = [atrBodyString boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin context:nil];
    
    
    if (message.user_data.id != userID) {
        textRect.size.height += 17;
    } else {
        textRect.size.height += 10;
    }
    CGFloat mainRect = ceil(textRect.size.height + 50);
    
    if ([message.local_photo CGImage] != nil || message.photo_url.length > 0) {
        
        mainRect = mainRect + 100;
        
    }
    
    return mainRect;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ChatMessageData *message = [self messageAtIndexPath:indexPath];
    
    TextMessageCell *txtCell = (TextMessageCell*)cell;
    txtCell.delegate = self;
    
    
    // detector huperlink!!!
    txtCell.bodyLabel.text = message.text;
    NSError *error = nil;
    NSDataDetector *detector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink
                                                               error:&error];
    
    NSString *string = message.text;
    
    [detector enumerateMatchesInString:string
                               options:kNilOptions
                                 range:NSMakeRange(0, [string length])
                            usingBlock:
     ^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
         if (result.resultType == NSTextCheckingTypeLink) {
             NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:string attributes:nil];
             NSRange linkRange = result.range; // for the word "link" in the string above
             
             
             
             NSDictionary *linkAttributes = @{ @"linkTag" : @(YES),
                                               NSForegroundColorAttributeName : [UIColor colorWithRed:0.05 green:0.4 blue:0.65 alpha:1.0],
                                               NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle) };
             [attributedString setAttributes:linkAttributes range:linkRange];
             
             // Assign attributedText to UILabel
             txtCell.bodyLabel.attributedText = attributedString;
             UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(txvTextTouched:)];
             [txtCell.bodyLabel addGestureRecognizer:tap];
         }
         NSLog(@"Match: %llu", result.resultType);
     }];
    
    
    txtCell.bubbleImage.image = [self.messageBubbleController messageBubbleForIndexPath:(indexPath)].image;
    
    NSDateFormatter *timeFormater = [[NSDateFormatter alloc] init];
    timeFormater.dateFormat = @"HH:mm";
    //FIXIT
    NSTimeInterval secondsInOneHours = 3 * 3600;
    NSDate *moscowDate = [message.date dateByAddingTimeInterval:secondsInOneHours];
    
    txtCell.timeLabel.text = [timeFormater stringFromDate:moscowDate];
    txtCell.nameLabel.text = message.user_data.name;
    
}


- (void) addNewMessage:(ChatMessageData *) message {
    
    [self.chatData.messages insertObject:message atIndex:0];
    [self addCellForNewMessage];
}

- (void) addCellForNewMessage {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self.tableView beginUpdates];
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationTop];
        
        [self.tableView endUpdates];
        
    });
    
}




- (void) openActionSheet {
    
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *TakePhoto = [UIAlertAction actionWithTitle:@"Take Photo" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        [self makePhoto];
        
    }];
    
    UIAlertAction *PhotoLibrary = [UIAlertAction actionWithTitle:@"Photo Library" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        [self addPhoto];
        
    }];
    
    UIAlertAction *CancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        
        NSLog(@"cancel action");
        
    }];
    
    [actionSheet addAction:TakePhoto];
    [actionSheet addAction:PhotoLibrary];
    [actionSheet addAction:CancelAction];
    
    [self presentViewController:actionSheet animated:YES completion:nil];
    
}

#pragma mark - Camera

- (void)makePhoto
{
    DBCameraViewController *camera = [[DBCameraViewController alloc] init];
    camera.delegate = self;
    camera.automaticallyAdjustsScrollViewInsets = NO;
    camera.tintColor = [UIColor whiteColor];
    camera.selectedTintColor = [UIColor colorWithRed:132.0/255.0 green:101.0/255.0 blue:255.0/255.0 alpha:1.0];
    camera.forceQuadCrop = YES;
    camera.useCameraSegue = YES;
    
    UINavigationController* navController = [[UINavigationController alloc] initWithRootViewController:camera];
    navController.navigationBarHidden = YES;
    
    [self presentViewController:navController animated:YES completion:nil];
}

- (void)addPhoto
{
    
    DBCameraLibraryViewController *picker = [[DBCameraLibraryViewController alloc] init];
    picker.delegate = self;
    picker.useCameraSegue = YES;
    
    UINavigationController* navController = [[UINavigationController alloc] initWithRootViewController:picker];
    navController.navigationBarHidden = YES;
    
    [self presentViewController:navController animated:YES completion:nil];
    
}



- (void) dismissCamera:(id)cameraViewController {
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

- (void)camera:(id)cameraViewController didFinishWithImage:(UIImage *)image withMetadata:(NSDictionary *)metadata {
    NSLog(@"DONE SELECTED");
    [self dismissViewControllerAnimated:YES completion:nil];
    [cameraViewController restoreFullScreenMode];
    
    [self sendMessageWithImage:image];
    
    
}

- (void) openImageFromURL:(NSString *) imageURL {
    
    NSMutableArray *photos = [[NSMutableArray alloc] init];
    MWPhoto *photo;
    BOOL displayActionButton = YES;
    BOOL displaySelectionButtons = NO;
    BOOL displayNavArrows = NO;
    BOOL enableGrid = YES;
    BOOL startOnGrid = NO;
    BOOL autoPlayOnAppear = NO;
    
    // Photos
    for (ChatMessageData *message in self.chatData.messages) {
        if (message.local_photo) {
            photo = [MWPhoto photoWithImage:message.local_photo];
            [photos addObject:photo];
        } else if (message.photo_url.length > 0) {
            [photos addObject:[MWPhoto photoWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", SERVER_URL, message.photo_url]]]];
        }
    }
    
    self.photos = photos;
    
    MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
    browser.displayActionButton = displayActionButton;
    browser.displayNavArrows = displayNavArrows;
    browser.displaySelectionButtons = displaySelectionButtons;
    browser.alwaysShowControls = displaySelectionButtons;
    browser.zoomPhotosToFill = YES;
    browser.enableGrid = enableGrid;
    browser.startOnGrid = startOnGrid;
    browser.enableSwipeToDismiss = NO;
    browser.autoPlayOnAppear = autoPlayOnAppear;
    [browser setCurrentPhotoIndex:0];
    
    // Reset selections
    if (displaySelectionButtons) {
        _selections = [NSMutableArray new];
        for (int i = 0; i < photos.count; i++) {
            [_selections addObject:[NSNumber numberWithBool:NO]];
        }
    }
    
    // Show
    if (_segmentedControl.selectedSegmentIndex == 0) {
        // Push
        [self.navigationController pushViewController:browser animated:YES];
    } else {
        // Modal
        UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:browser];
        nc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        [self presentViewController:nc animated:YES completion:nil];
    }
    
}

- (UIImage*) maskImage:(UIImage *)image withMask:(UIImage *)maskImage {
    
    CGImageRef maskRef = maskImage.CGImage;
    
    CGImageRef mask = CGImageMaskCreate(CGImageGetWidth(maskRef),
                                        CGImageGetHeight(maskRef),
                                        CGImageGetBitsPerComponent(maskRef),
                                        CGImageGetBitsPerPixel(maskRef),
                                        CGImageGetBytesPerRow(maskRef),
                                        CGImageGetDataProvider(maskRef), NULL, false);
    
    CGImageRef masked = CGImageCreateWithMask([image CGImage], mask);
    return [UIImage imageWithCGImage:masked];
    
}

-(void)txvTextTouched:(UITapGestureRecognizer *)recognizer
{
    PasteboardLabel *textView = (PasteboardLabel *)recognizer.view;
    CGPoint tapLocation = [recognizer locationInView:textView];
    
    // init text storage
    NSTextStorage *textStorage = [[NSTextStorage alloc] initWithAttributedString:textView.attributedText];
    NSLayoutManager *layoutManager = [[NSLayoutManager alloc] init];
    [textStorage addLayoutManager:layoutManager];
    
    // init text container
    NSTextContainer *textContainer = [[NSTextContainer alloc] initWithSize:CGSizeMake(textView.frame.size.width, textView.frame.size.height+100) ];
    textContainer.lineFragmentPadding  = 0;
    textContainer.maximumNumberOfLines = textView.numberOfLines;
    textContainer.lineBreakMode        = textView.lineBreakMode;
    
    [layoutManager addTextContainer:textContainer];
    
    NSUInteger characterIndex = [layoutManager characterIndexForPoint:tapLocation
                                                      inTextContainer:textContainer
                             fractionOfDistanceBetweenInsertionPoints:NULL];
    if (characterIndex < textStorage.length) {
        
        NSRange range0;
        id linkValue = [textStorage attribute:@"linkTag" atIndex:characterIndex effectiveRange:&range0];
        
        if (linkValue)
        {
            NSError *error = nil;
            NSDataDetector *detector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink
                                                                       error:&error];
            
            NSString *string = textView.text;
            [detector enumerateMatchesInString:string
                                       options:kNilOptions
                                         range:NSMakeRange(0, [string length])
                                    usingBlock:
             ^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
                 if (result.resultType == NSTextCheckingTypeLink) {
                     NSURL *url = result.URL;
                     if ([[UIApplication sharedApplication] canOpenURL:url]) {
                         [[UIApplication sharedApplication] openURL:url];
                     }
                     return;
                 }
                 NSLog(@"Match: %llu", result.resultType);
             }];
            
        }
    }
}

#pragma mark - MWPhotoBrowserDelegate

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    return _photos.count;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    if (index < _photos.count)
        return [_photos objectAtIndex:index];
    return nil;
}

- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser didDisplayPhotoAtIndex:(NSUInteger)index {
    NSLog(@"Did start viewing photo at index %lu", (unsigned long)index);
}

- (BOOL)photoBrowser:(MWPhotoBrowser *)photoBrowser isPhotoSelectedAtIndex:(NSUInteger)index {
    return [[_selections objectAtIndex:index] boolValue];
}

- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index selectedChanged:(BOOL)selected {
    [_selections replaceObjectAtIndex:index withObject:[NSNumber numberWithBool:selected]];
    NSLog(@"Photo at index %lu selected %@", (unsigned long)index, selected ? @"YES" : @"NO");
}

- (void)photoBrowserDidFinishModalPresentation:(MWPhotoBrowser *)photoBrowser {
    // If we subscribe to this method we must dismiss the view controller ourselves
    NSLog(@"Did finish modal presentation");
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (ChatMessageData *) messageAtIndexPath:(NSIndexPath *) indexPath {
    
    return [self.chatData.messages objectAtIndex:indexPath.row];
    
}

@end
