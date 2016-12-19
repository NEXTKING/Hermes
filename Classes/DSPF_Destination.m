//
//  DSPF_Destination.m
//  Hermes
//
//  Created by Lutz  Thalmann on 17.12.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "HermesAppDelegate.h"
#import "DSPF_Destination.h"

#import "Departure.h"
#import "Location_Group.h"

@implementation DSPF_Destination

@synthesize currentTC;
@synthesize doneButton;
@synthesize destinationGroup1;
@synthesize destinationGroup2;
@synthesize segmentedControl;
@synthesize transportCodeLabel;
@synthesize pickerView;
@synthesize currentSelection;
@synthesize delegate;
@synthesize pickerViewToolbar;


- (NSArray *)destinationGroup1 {
    if (!destinationGroup1) {
        NSArray *sortDescriptors = [self.class departureSortDescriptors];
        NSPredicate *predicate = [Departure forDestinationList:1];
        
        destinationGroup1 = [[Departure distinctLocationsFromDeparturesWithPredicate:predicate sortDescriptors:sortDescriptors inCtx:ctx()] retain];
        
    }
    return destinationGroup1;
}

- (NSArray *)destinationGroup2 {
    if (!destinationGroup2) {
        NSArray *sortDescriptors = [self.class departureSortDescriptors];
        NSPredicate *predicate = [Departure forDestinationList:2];
         
        destinationGroup2 = [[Departure distinctLocationsFromDeparturesWithPredicate:predicate sortDescriptors:sortDescriptors inCtx:ctx()] retain];
    }
    return destinationGroup2;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
		self.title = NSLocalizedString(@"TITLE_036", @"Zieladresse");
    }
    return self;
}

- (Location *)tourDestinationForRow:(NSInteger)row forComponent:(NSInteger)component {
    self.doneButton.enabled = NO;
	if (self.segmentedControl.selectedSegmentIndex == 0) { 
        if (self.destinationGroup1.count > 0) {
            self.doneButton.enabled = YES;
            return [self.destinationGroup1 objectAtIndex:row]; 
        } 
        return nil;
	}
    if (self.destinationGroup2.count > 0) {
        self.doneButton.enabled = YES;
        return [self.destinationGroup2 objectAtIndex:row]; 
    } 
    return nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if (self.destinationGroup1.count == 0 && self.destinationGroup2.count > 0) {
        self.segmentedControl.selectedSegmentIndex = 1;
    }
	[self.pickerView selectRow:0 inComponent:0 animated:NO];
	self.currentSelection = [self tourDestinationForRow:0 forComponent:0];
	self.currentTC.text   = [NSUserDefaults currentTC];
    self.transportCodeLabel.text = NSLocalizedString(@"PLACEHOLDER_003", @"transportcode");
    
    NSString *segment0title = NSLocalizedString(@"Lager", @"Lager");
    NSString *segment1title = NSLocalizedString(@"TITLE_097", @"Orte");
    if (PFTourTypeSupported(@"0X0", nil)) {
        segment0title = NSLocalizedString(@"TITLE_098", @"Werke");
    }
    if (PFBrandingSupported(BrandingUnilabs, nil)) {
        segment0title = NSLocalizedString(@"TITLE_131", @"Platforms");
        segment1title = NSLocalizedString(@"TITLE_132", @"Labs");
    }
    [self.segmentedControl setTitle:segment0title forSegmentAtIndex:0];
    [self.segmentedControl setTitle:segment1title forSegmentAtIndex:1];
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(dismiss)];
    self.navigationItem.leftBarButtonItem = item;
    [item release];
    
    [AppStyle customizePickerView:self.pickerView];
    [AppStyle customizePickerViewToolbar:self.pickerViewToolbar];
}

- (void) dismiss {
    [self.delegate dspf_Destination:self didSelectLocation:nil userInfo:nil];
}
 
- (IBAction)destinationShouldReturn {
    [self.delegate dspf_Destination:self didSelectLocation:self.currentSelection userInfo:nil];
}

- (void)viewDidUnload {
    [super viewDidUnload];

    self.doneButton         = nil;
	self.currentTC          = nil;
    self.transportCodeLabel = nil;
	self.segmentedControl   = nil;
	self.pickerView         = nil;
    self.pickerViewToolbar  = nil;
}


- (void)dealloc {
    [pickerViewToolbar    release];
	[currentSelection	  release];
    [doneButton           release];
	[currentTC			  release];
	[destinationGroup1	  release];
	[destinationGroup2	  release];
    [transportCodeLabel   release];
	[segmentedControl	  release];
	[pickerView			  release];
    [super dealloc];
}

#pragma mark - PickerView

- (IBAction)changePickerView {
    [self.pickerView reloadComponent:0];
    [self.pickerView selectRow:0 inComponent:0 animated:NO];
    self.currentSelection = [self tourDestinationForRow:0 forComponent:0];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (self.segmentedControl.selectedSegmentIndex == 0) {
        return self.destinationGroup1.count;
    }
    return self.destinationGroup2.count;
}


- (UIView *)pickerView:(UIPickerView *)aPickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    UILabel *label = (id)view;
    if (!label || ([label class] != [UILabel class])) {
        label = [[[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, [aPickerView rowSizeForComponent:component].width, [aPickerView rowSizeForComponent:component].height)] autorelease];
        label.backgroundColor = [UIColor clearColor];
    }
    [AppStyle customizePickerViewLabel:label];
    
    if (self.segmentedControl.selectedSegmentIndex == 0) {
        label.text = [self tourDestinationForRow:row forComponent:component].location_name;
    }else {
        label.text = [NSString stringWithFormat:@"   %@, %@ (%@)",
                      [[self tourDestinationForRow:row forComponent:component].city stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]],
                      [[self tourDestinationForRow:row forComponent:component].street stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]],
                      [[self tourDestinationForRow:row forComponent:component].location_name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
        label.font = [UIFont fontWithName:@"Helvetica-Bold" size:12];
    }
    return label;
}

- (void)pickerView:(UIPickerView *)aPickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    self.currentSelection = [self tourDestinationForRow:row forComponent:component];
}

#pragma mark - Sorting

+ (NSArray *) departureSortDescriptors {
    NSArray *sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"location_name"    ascending:YES],
                                 [NSSortDescriptor sortDescriptorWithKey:@"zip" ascending:YES],
                                 [NSSortDescriptor sortDescriptorWithKey:@"street" ascending:YES]];
    return sortDescriptors;
}

@end
