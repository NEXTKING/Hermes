//
//  DSPF_SelectItem.m
//  Hermes
//
//  Created by Lutz  Thalmann on 05.01.12.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "HermesAppDelegate.h"
#import "DSPF_SelectItem.h"
#import "DSPF_Error.h"

#import "Item.h"
#import "User.h"

@implementation DSPF_SelectItem


@synthesize barcode;
@synthesize currently;
@synthesize itemIDLabel;
@synthesize itemIDCountLabel;
@synthesize ctx;
@synthesize itemCodes;
@synthesize pickerView;
@synthesize currentSelection;
@synthesize currentUsersGroupProfiles;
@synthesize delegate;
@synthesize pickerViewToolbar;


- (NSArray *)itemCodes {
    if (!itemCodes) { 
		itemCodes = [[ItemCode itemCodesWithPredicate:[NSPredicate predicateWithFormat:@"code = %@",
                                                       self.barcode]
                                      sortDescriptors:[NSArray arrayWithObjects:
                                                       [NSSortDescriptor sortDescriptorWithKey:@"itemID" ascending:YES],
                                                       nil]
                               inCtx:self.ctx] retain];
    }
    return itemCodes;
}

- (NSSet *)currentUsersGroupProfiles {
    if (!currentUsersGroupProfiles) {
        currentUsersGroupProfiles = [[NSSet alloc] initWithArray:[[User userID:[NSNumber numberWithInt:[[NSUserDefaults currentUserID] intValue]]
                                  forInventoryLine:nil
                            inCtx:self.ctx].functions componentsSeparatedByString:@", "]];
    }
    return currentUsersGroupProfiles;
}

- (void)confirmBackButton {
	[[DSPF_Confirm question:nil item:@"confirmBackButton"
             buttonTitleYES:((UIViewController *)[self.navigationController.viewControllers objectAtIndex:(self.navigationController.viewControllers.count - 2)]).title
              buttonTitleNO:NSLocalizedString(@"TITLE_018", nil)
                 showInView:self.view] setDelegate:self];
}

// The designated initializer.  
// Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
		self.title          = NSLocalizedString(@"TITLE_097", @"Artikelauswahl");
        self.ctx = [(HermesAppDelegate *)[[UIApplication sharedApplication] delegate] ctx];
    }
    return self;
}

- (ItemCode *)itemCodeForRow:(NSInteger)row forComponent:(NSInteger)component {
    // Return the selected item.
	ItemCode *itemCode = nil;
	itemCode = [self.itemCodes objectAtIndex:row];
	return itemCode;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    self.currently.text = NSLocalizedString(@"MESSAGE_061", @"Barcode:");
    if (self.itemCodes && self.itemCodes.count != 0) { 
        self.currentSelection = [self.itemCodes lastObject];
        self.itemIDLabel.text      = self.currentSelection.code;
        self.itemIDCountLabel.text = [NSString stringWithFormat:@"%i %@", self.itemCodes.count, NSLocalizedString(@"MESSAGE_060", @"Treffer")];
        NSInteger tmpIDX = [self.itemCodes indexOfObject:self.currentSelection];
        if (tmpIDX ==  NSNotFound) {
            [self.pickerView selectRow:0 inComponent:0 animated:NO];
            self.currentSelection = [self itemCodeForRow:0 forComponent:0];
        } else {
            [self.pickerView selectRow:tmpIDX inComponent:0 animated:NO];
            self.currentSelection = [self itemCodeForRow:tmpIDX forComponent:0];
        }
    }
    self.navigationController.toolbarHidden = YES;
    UIButton *backButton = [UIButton buttonWithType:101];      // left-pointing shape!
	[backButton addTarget:self action:@selector(confirmBackButton) forControlEvents:UIControlEventTouchUpInside];
	[backButton setTitle:((UIViewController *)[self.navigationController.viewControllers objectAtIndex:(self.navigationController.viewControllers.count - 2)]).title
                forState:UIControlStateNormal];
	self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:backButton] autorelease];
    
    [AppStyle customizePickerView:self.pickerView];
    [AppStyle customizePickerViewToolbar:self.pickerViewToolbar];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
	return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
	return self.itemCodes.count;
}

- (UIView *)pickerView:(UIPickerView *)aPickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
	UILabel *label = (id)view;
	if (!label || ([label class] != [UILabel class])) {
		label = [[[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, [aPickerView rowSizeForComponent:component].width, [aPickerView rowSizeForComponent:component].height)] autorelease];
	}
    [AppStyle customizePickerViewLabel:label];
	label.text = [NSString stringWithFormat:@"  %05i %@", 
                                            [[self itemCodeForRow:row forComponent:component].itemID intValue],
                                            [Item localDescriptionTextForItem:
                                             [self itemCodeForRow:row forComponent:component].item]];
	label.font = [UIFont fontWithName:@"Helvetica-Bold" size:16];
	return label;
}

- (void)pickerView:(UIPickerView *)aPickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
	self.currentSelection = [self itemCodeForRow:row forComponent:component];
}

- (IBAction)didConfirmStore {
    [self.navigationController popViewControllerAnimated:YES];
    [self.delegate dspf_SelectItemDelegate:self didSelect:self.currentSelection.item forBarcode:self.barcode];
}

#pragma mark - Permission delegate

- (void) dspf_Confirm:(DSPF_Confirm *)sender didConfirmQuestion:(NSString *)question item:(NSObject *)aItem withButtonTitle:(NSString *)buttonTitle {
	if (![buttonTitle isEqualToString:NSLocalizedString(@"TITLE_018", @"Abbrechen")]) {
        if ([(NSString *)aItem isEqualToString:@"confirmBackButton"]) {
			[self.navigationController popViewControllerAnimated:YES];
		}
	}
}

- (void)viewDidUnload {
    [super viewDidUnload];

	self.pickerView         = nil;
    self.itemIDCountLabel   = nil;
    self.itemIDLabel        = nil;
    self.pickerViewToolbar  = nil;
}


- (void)dealloc {
    [pickerViewToolbar         release];
    [currentUsersGroupProfiles release];
	[currentSelection          release];
	[ctx      release];
	[itemCodes                 release];
	[pickerView                release];
    [itemIDCountLabel          release];
    [itemIDLabel               release];
    [currently                 release];
    [barcode                   release];
    [super dealloc];
}


@end
