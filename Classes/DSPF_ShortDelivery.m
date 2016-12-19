//
//  DSPF_ShortDelivery.m
//  Hermes
//
//  Created by Lutz  Thalmann on 21.12.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "HermesAppDelegate.h"
#import "DSPF_ShortDelivery.h"
#import "DSPF_Activity.h"

#import "Location.h"
#import "Transport.h"

@implementation DSPF_ShortDelivery

@synthesize pickerViewToolbar;
@synthesize departureLabel;
@synthesize departureTime;
@synthesize departureExtension;
@synthesize currentLocationStreetAddress;
@synthesize currentLocationZipCode;
@synthesize currentLocationCity;
@synthesize ctx;
@synthesize traceTypes;
@synthesize traceTypeDescription;
@synthesize pickerView;
@synthesize currentSelection;
@synthesize currentDeparture;
@synthesize currentTransportGroup;
@synthesize pickerViewDetailMode;
@synthesize isShortPickup;


- (NSManagedObjectContext *)ctx {
    if (!ctx) { 
		ctx = [[(HermesAppDelegate *)[[UIApplication sharedApplication] delegate] ctx] retain]; 
    }
    return ctx;
}

- (NSArray *)traceTypes {
    if (!traceTypes) {
        NSArray *sortDescriptors = [Trace_Type defaultSortDescriptors];
        if (isShortPickup) {
            traceTypes = [[Trace_Type trace_TypesWithPredicate:[NSPredicate predicateWithFormat:@"trace_type_id BETWEEN {131, 139}"]
                                               sortDescriptors:sortDescriptors inCtx:self.ctx] retain];
        } else {
            if (PFBrandingSupported(BrandingCCC_Group, nil)) {
                traceTypes = [[Trace_Type trace_TypesWithPredicate:[NSPredicate predicateWithFormat:@"trace_type_id IN {91, 92, 94, 97}"]
                                                   sortDescriptors:sortDescriptors inCtx:self.ctx] retain];

            }
            else if (PFBrandingSupported(BrandingTechnopark, nil))
                traceTypes = [[Trace_Type trace_TypesWithPredicate:[NSPredicate predicateWithFormat:@"trace_type_id BETWEEN {92, 95}"]
                                                   sortDescriptors:sortDescriptors inCtx:self.ctx] retain];
            else {
                traceTypes = [[Trace_Type trace_TypesWithPredicate:[NSPredicate predicateWithFormat:@"trace_type_id BETWEEN {93, 95}"]
                                                   sortDescriptors:sortDescriptors inCtx:self.ctx] retain];
            }
        }
    }
    return traceTypes;
}


// The designated initializer.  
// Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
}

- (Trace_Type *)traceTypeForRow:(NSInteger)row forComponent:(NSInteger)component {;
	return [self.traceTypes objectAtIndex:row];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.departureExtension.text = @"🕙";
    
	[self.pickerView selectRow:0 inComponent:0 animated:NO];
	self.currentSelection				   = [self traceTypeForRow:0 forComponent:0];
	self.currentLocationCity.text          = self.currentDeparture.location_id.city;
	self.currentLocationZipCode.text       = self.currentDeparture.location_id.zip;
	self.currentLocationStreetAddress.text = self.currentDeparture.location_id.street;
    if (self.currentDeparture.departure) {
        self.departureTime.text     = [NSDateFormatter localizedStringFromDate:self.currentDeparture.departure 
                                                                     dateStyle:NSDateFormatterNoStyle 
                                                                     timeStyle:NSDateFormatterShortStyle];
    } else if (self.currentDeparture.arrival) {
        self.departureTime.text     = [NSDateFormatter localizedStringFromDate:self.currentDeparture.arrival 
                                                                     dateStyle:NSDateFormatterNoStyle 
                                                                     timeStyle:NSDateFormatterShortStyle];
    } else if (self.currentDeparture.location_id.location_code)  { 
        self.departureLabel.text       = self.currentDeparture.location_id.location_code;
        self.departureTime.hidden      = YES;
        self.departureExtension.hidden = YES;
    } else if (self.currentDeparture.transport_group_id.task)  { 
        self.departureLabel.text       = self.currentDeparture.transport_group_id.task;
        self.departureTime.hidden      = YES;
        self.departureExtension.hidden = YES;
    } else {
        self.departureLabel.text       = [NSString stringWithFormat:@"%@", self.currentDeparture.departure_id];
        self.departureTime.hidden      = YES;
        self.departureExtension.hidden = YES;
    }
    
    [AppStyle customizePickerView:self.pickerView];
    [AppStyle customizePickerViewToolbar:self.pickerViewToolbar];
    
    if (PFBrandingSupported(BrandingTechnopark, nil))
    {
        self.currentTransportGroup = self.currentDeparture.transport_group_id;
        self.departureLabel.text = NSLocalizedString(@"MESSAGE_026", @"Abfahrt:");
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.isShortPickup) {
        self.title = NSLocalizedString(@"TITLE_123", @"Teilabholung");
    } else {
        self.title = NSLocalizedString(@"TITLE_051", @"Teillieferung");
    }
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
	return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
	return self.traceTypes.count;
}

- (UIView *)pickerView:(UIPickerView *)aPickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
	UILabel *label = (id)view;
	if (!label || ([label class] != [UILabel class])) {
		label = [[[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, [aPickerView rowSizeForComponent:component].width, [aPickerView rowSizeForComponent:component].height)] autorelease];
	}
    [AppStyle customizePickerViewLabel:label];
	label.text = [NSString stringWithFormat:@"  %@", NSLocalizedString([self traceTypeForRow:row forComponent:component].description_text, nil)];
	return label;
}

- (void)pickerView:(UIPickerView *)aPickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
	self.currentSelection = [self traceTypeForRow:row forComponent:component];
}

- (void)dismissPickerViewDetailMode {
    self.pickerViewDetailMode = NO;
    self.traceTypes = nil;
    [self.pickerView reloadAllComponents];
    if (self.pickerViewToolbar.items.count > 2) {
        NSRange buttonRange = {.location = 1, .length = self.pickerViewToolbar.items.count - 1};
        [self.pickerViewToolbar setItems:[self.pickerViewToolbar.items subarrayWithRange:buttonRange] animated:YES];
    }
    [self.pickerView selectRow:0 inComponent:0 animated:YES];
	self.currentSelection = [self traceTypeForRow:0 forComponent:0];
}

- (IBAction)didConfirmShortDelivery {
    NSDictionary *imagePickerParameters = nil;
    if (PFBrandingSupported(BrandingCCC_Group, nil)) {
        imagePickerParameters = @{ImagePickerDescriptionTextFieldVisible : @YES,
                                  ImagePickerDescriptionTextRequired : @YES };
        if (!self.pickerViewDetailMode) {
            self.traceTypeDescription = NSLocalizedString(self.currentSelection.description_text, nil);
        } else {
            self.traceTypeDescription = [NSString stringWithFormat:@"%@ %@", self.traceTypeDescription,
                                         NSLocalizedString(self.currentSelection.description_text, nil)];
        }
        if (!self.pickerViewDetailMode &&
            [self.currentSelection.trace_type_id integerValue] != 97 &&
            [[Trace_Type trace_TypesWithPredicate:[NSPredicate predicateWithFormat:@"trace_type_id = %i",
                                                   ((([self.currentSelection.trace_type_id integerValue] - 90) * 10) + 101)]
                                  sortDescriptors:nil inCtx:self.ctx] lastObject]) {
            UIButton *backButton = [UIButton buttonWithType:101];  // left-pointing shape!
            [backButton addTarget:self action:@selector(dismissPickerViewDetailMode) forControlEvents:UIControlEventTouchUpInside];
            [backButton setTitle:NSLocalizedString(self.currentSelection.description_text, nil) forState:UIControlStateNormal];
            self.pickerViewDetailMode = YES;
            self.traceTypes = [Trace_Type trace_TypesWithPredicate:[NSPredicate predicateWithFormat:@"trace_type_id BETWEEN {%i, %i} && "
                                                                    "NOT (trace_type_id IN %@)",
                                                                    ((([self.currentSelection.trace_type_id integerValue] - 90) * 10) + 101),
                                                                    ((([self.currentSelection.trace_type_id integerValue] - 90) * 10) + 109),
                                                                    [NSArray arrayWithObjects:[NSNumber numberWithInt:142], nil]]
                                                   sortDescriptors:[NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:
                                                                                              @"trace_type_id" ascending:YES], nil]
                                            inCtx:self.ctx];
            [self.pickerView reloadAllComponents];
            [self.pickerViewToolbar setItems:[[NSArray arrayWithObject:[[[UIBarButtonItem alloc] initWithCustomView:backButton] autorelease]]
                                              arrayByAddingObjectsFromArray:self.pickerViewToolbar.items]
                                    animated:YES];
            [self.pickerView selectRow:0 inComponent:0 animated:YES];
            self.currentSelection = [self traceTypeForRow:0 forComponent:0];
            return;
        }
        NSMutableString *text = [[[NSMutableString alloc] init] autorelease];
        if (self.traceTypeDescription) {
            [text appendFormat:@"⚠ %@", self.traceTypeDescription];
            if (self.currentTransportGroup.info_text) {
                [text appendFormat:@"\nℹ️ %@", self.currentTransportGroup.info_text];
            }
        } else if (self.currentTransportGroup.info_text) {
            [text appendFormat:@"⚠ %@", self.currentTransportGroup.info_text];
        }
        
        self.currentTransportGroup.info_text = text;
    }
    NSString *code = [NSDateFormatter localizedStringFromDate:[NSDate date] dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterLongStyle];
    NSMutableDictionary *currentTransport = [Transport dictionaryWithCode:code traceType:[self.currentSelection.trace_type_id integerValue]
                                                            fromDeparture:self.currentDeparture toLocation:self.currentDeparture.location_id];
    if (self.currentTransportGroup) {
        [currentTransport setValue:self.currentTransportGroup.task                                       forKey:@"task"];
    }
	[Transport transportWithDictionaryData:currentTransport inCtx:self.ctx];
	[self.ctx saveIfHasChanges];
    id dspf_TourLocation = [self.navigationController.viewControllers objectAtIndex:(self.navigationController.viewControllers.count - 2)];
    if ([dspf_TourLocation isKindOfClass:[DSPF_TourLocation class]] &&
        [@[@111, @112, @119, @131, @132, @141, @149] containsObject:self.currentSelection.trace_type_id])
    {
            dispatch_async(dispatch_get_main_queue(), ^{
                [dspf_TourLocation performSelectorOnMainThread:@selector(getImageForProofOfDelivery:) withObject:imagePickerParameters waitUntilDone:NO];
            });
    }
    
    
    
    [CATransaction begin];
    [CATransaction setCompletionBlock:^{
        // handle completion here
        if (_delegate && [_delegate respondsToSelector:@selector(deadheadDidDismiss)])
            [_delegate deadheadDidDismiss];
    }];
    
    [self.navigationController popViewControllerAnimated:YES];
    
    [CATransaction commit];
}

- (void)viewDidUnload {
    [super viewDidUnload];

    self.pickerView					  = nil;
    self.pickerViewToolbar            = nil;
    self.departureLabel               = nil;
    self.departureTime                = nil;
	self.departureExtension           = nil;
	self.currentLocationStreetAddress = nil;
	self.currentLocationZipCode       = nil;
	self.currentLocationCity		  = nil;
}


- (void)dealloc {
    [currentTransportGroup        release];
    [currentDeparture			  release];
	[currentSelection			  release];
    [departureExtension           release];
    [departureTime                release];
	[departureLabel               release];
	[currentLocationStreetAddress release];
	[currentLocationZipCode       release];
	[currentLocationCity		  release];
	[ctx		  release];
    [traceTypeDescription         release];
	[traceTypes					  release];
	[pickerView					  release];
    [pickerViewToolbar            release];
    [super dealloc];
}


@end
