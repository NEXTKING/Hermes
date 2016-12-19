//
//  DSPF_SelectStore.m
//  Hermes
//
//  Created by Lutz  Thalmann on 05.01.12.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "HermesAppDelegate.h"
#import "DSPF_SelectStore.h"
#import "DSPF_Synchronisation.h"

#import "ArchiveOrderHead.h"
#import "TemplateOrderHead.h"
#import "User.h"
#import "Item.h"
#import "ItemCode.h"
#import "ItemDescription.h"

@implementation DSPF_SelectStore


@synthesize currently;
@synthesize storeIDLabel;
@synthesize storeNameLabel;
@synthesize storeLocaleCodeLabel;
@synthesize ctx;
@synthesize stores;
@synthesize pickerView;
@synthesize currentSelection;
@synthesize pickerViewToolbar;


- (NSArray *)stores {
    if (!stores) {
		NSArray *sortDescriptors = [NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"store_id" 
                                                                                           ascending:YES], nil];
		stores = [[Store storesWithPredicate:nil sortDescriptors:sortDescriptors inCtx:self.ctx] retain];
    }
    return stores;
}

// The designated initializer.  
// Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
        self.title          = NSLocalizedString(@"TITLE_013", @"Filialzuordnung");
        self.currently.text = NSLocalizedString(@"MESSAGE_025", nil);
        self.ctx = [(HermesAppDelegate *)[[UIApplication sharedApplication] delegate] ctx];
    }
    return self;
}

- (Store *)storeForRow:(NSInteger)row forComponent:(NSInteger)component {
    // Return the selected item.
	Store *store = nil;
	store = [self.stores objectAtIndex:row];
	return store;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    if (self.stores && self.stores.count != 0) { 
        self.currentSelection = [[Store storesWithPredicate:[NSPredicate predicateWithFormat:@"store_id = %i", 
                                                             [[[NSUserDefaults standardUserDefaults] valueForKey:@"currentStoreID"] intValue]]
                                            sortDescriptors:nil
                                     inCtx:self.ctx] lastObject];
        self.storeIDLabel.text         = [[NSUserDefaults standardUserDefaults] valueForKey:@"currentStoreID"];
        self.storeNameLabel.text       = self.currentSelection.storeName;
        self.storeLocaleCodeLabel.text = self.currentSelection.localeCode;
        NSInteger tmpIDX = [self.stores indexOfObject:self.currentSelection];
        if (tmpIDX ==  NSNotFound) {
            [self.pickerView selectRow:0 inComponent:0 animated:NO];
            self.currentSelection = [self storeForRow:0 forComponent:0];
        } else {
            [self.pickerView selectRow:tmpIDX inComponent:0 animated:NO];
            self.currentSelection = [self storeForRow:tmpIDX forComponent:0];
        }
    }
    
    [AppStyle customizePickerView:self.pickerView];
    [AppStyle customizePickerViewToolbar:self.pickerViewToolbar];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
	return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
	return self.stores.count;
}

- (UIView *)pickerView:(UIPickerView *)aPickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
	UILabel *label = (id)view;
	if (!label || ([label class] != [UILabel class])) {
		label = [[[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, [aPickerView rowSizeForComponent:component].width, [aPickerView rowSizeForComponent:component].height)] autorelease];
	}
    [AppStyle customizePickerViewLabel:label];
	label.text = [NSString stringWithFormat:@"%05i %@", 
                                            [[self storeForRow:row forComponent:component].store_id intValue], 
                                            [self storeForRow:row forComponent:component].storeName];
	label.font = [UIFont fontWithName:@"Helvetica-Bold" size:20];
	return label;
}

- (void)pickerView:(UIPickerView *)aPickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
	self.currentSelection = [self storeForRow:row forComponent:component];
}

- (IBAction)didConfirmStore { 
    if (self.stores && self.stores.count != 0) { 
        [[NSUserDefaults standardUserDefaults] setValue:[NSString stringWithFormat:@"%05i", 
                                                         [self.currentSelection.store_id intValue]] forKey:@"currentStoreID"];
        [[NSUserDefaults standardUserDefaults] setValue:nil forKey:@"downloadCacheControl"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        DSPF_Activity *showActivity = [DSPF_Activity messageTitle:NSLocalizedString(@"MESSAGE_062", @"Bereinigung") 
                                                      messageText:@"Bitte warten Sie bis die vorhandenen Daten gelöscht wurden." 
                                                cancelButtonTitle:nil 
                                                         delegate:nil];
        [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
        [DPHUtilities waitForAlertToShow:0.1f];
        for (TemplateOrderHead *tmpTemplateHead in 
             [NSArray arrayWithArray:[TemplateOrderHead templateHeadsWithPredicate:[NSPredicate predicateWithFormat:@"isUserDomain = NO"]
                                                                   sortDescriptors:nil 
                                                            inCtx:self.ctx]]) { 
            [self.ctx deleteObject:tmpTemplateHead];
        } 
        if ([self.currentSelection.store_id intValue] != [self.storeIDLabel.text intValue]) { 
            for (TemplateOrderHead *tmpTemplateHead in 
                 [NSArray arrayWithArray:[TemplateOrderHead templateHeadsWithPredicate:[NSPredicate predicateWithFormat:@"isUserDomain = YES"]
                                                                       sortDescriptors:nil 
                                                                inCtx:self.ctx]]) { 
                [self.ctx deleteObject:tmpTemplateHead];
            } 
            for (ArchiveOrderHead *tmpOrderHead in 
                 [NSArray arrayWithArray:[ArchiveOrderHead orderHeadsWithPredicate:nil 
                                                                   sortDescriptors:nil 
                                                            inCtx:self.ctx]]) {
                [self.ctx deleteObject:tmpOrderHead];
            }
            if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"HermesApp_Branding"] isEqualToString:@"Heinemann"]) {
                for (ItemCode *tmpItemCode in [NSArray arrayWithArray:
                                               [ItemCode itemCodesWithPredicate:nil
                                                                sortDescriptors:nil
                                                         inCtx:self.ctx]]) {
                    [self.ctx deleteObject:tmpItemCode];
                }
                for (ItemDescription *tmpItemDescription in [NSArray arrayWithArray:
                                                             [ItemDescription itemDescriptionsWithPredicate:nil
                                                                                            sortDescriptors:nil
                                                                                     inCtx:self.ctx]]) {
                    [self.ctx deleteObject:tmpItemDescription];
                }
                for (Item *tmpItem in [NSArray arrayWithArray:
                                       [Item itemsWithPredicate:nil
                                                sortDescriptors:nil
                                         inCtx:self.ctx]]) {
                    [self.ctx deleteObject:tmpItem];
                }
            }
        }
        [self.ctx saveIfHasChanges];
        [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
        [showActivity closeActivityInfo];
        [[[[DSPF_Synchronisation alloc] init] autorelease] performSelector:@selector(syncALL)];
    }
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)viewDidUnload {
    [super viewDidUnload];

	self.pickerView					  = nil;
    self.storeLocaleCodeLabel         = nil;
    self.storeNameLabel				  = nil;
    self.storeIDLabel                 = nil;
    self.pickerViewToolbar            = nil;
}


- (void)dealloc {
    [pickerViewToolbar      release];
	[currentSelection		release];
	[ctx   release];
	[stores					release];
	[pickerView             release];
    [storeLocaleCodeLabel   release];
    [storeNameLabel         release];
    [storeIDLabel           release];
    [super dealloc];
}


@end
