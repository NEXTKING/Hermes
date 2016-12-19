//
//  DSPF_Deadhead.m
//  Hermes
//
//  Created by Lutz  Thalmann on 17.12.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "HermesAppDelegate.h"
#import "DSPF_Deadhead.h"

#import "Location.h"
#import "Transport_Group.h"
#import "Transport.h"
#import "DSPF_Finish.h"

NSString * const DeadHeadParameterCurrentDeparture = @"DeadHeadParameterCurrentDeparture";

@implementation DSPF_Deadhead

@synthesize pickerViewToolbar;
@synthesize departureLabel;
@synthesize departureTime;
@synthesize departureExtension;
@synthesize currentLocationStreetAddress;
@synthesize currentLocationZipCode;
@synthesize currentLocationCity;
@synthesize ctx;
@synthesize traceTypes;
@synthesize pickerView;
@synthesize currentSelection;
@synthesize currentDeparture;
@synthesize pickerViewDetailMode;

- (instancetype)init {
    return [self initWithParameters:nil];
}

- (instancetype)initWithParameters:(NSDictionary *) parameters {
    self = [super initWithNibName:NSStringFromClass([self class]) bundle:nil];
    if (self) {
        
        id obj = nilOrObject([parameters objectForKey:DeadHeadParameterCurrentDeparture]);
        if ([obj isKindOfClass:[NSArray class]])
            self.currentDepartures = obj;
        else
            self.currentDeparture = obj;
        
        //self.currentDeparture = nilOrObject([parameters objectForKey:DeadHeadParameterCurrentDeparture]);
        self.title = NSLocalizedString(@"TITLE_050", @"Leerfahrt");
    }
    return self;
}

- (NSManagedObjectContext *)ctx {
    if (!ctx) { 
		ctx = [[(HermesAppDelegate *)[[UIApplication sharedApplication] delegate] ctx] retain]; 
    }
    return ctx;
}

- (NSArray *)traceTypes {
    if (!traceTypes) {
        NSPredicate *predicate = [Trace_Type predicateForTraceTypesForDeadEnd];
        traceTypes = [[Trace_Type trace_TypesWithPredicate:predicate sortDescriptors:[Trace_Type defaultSortDescriptors] inCtx:self.ctx] retain];
    }
    return traceTypes;
}

- (Trace_Type *)traceTypeForRow:(NSInteger)row forComponent:(NSInteger)component {;
	return [self.traceTypes objectAtIndex:row];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.departureExtension.text = @"🕙";
    [self.pickerView selectRow:0 inComponent:0 animated:NO];
	self.currentSelection = [self traceTypeForRow:0 forComponent:0];
    if (PFBrandingSupported(BrandingViollier, nil)) {
        self.currentLocationStreetAddress.frame = CGRectMake(self.currentLocationStreetAddress.frame.origin.x,
                                                             self.currentLocationStreetAddress.frame.origin.y,
                                                             self.currentLocationStreetAddress.frame.size.width,
                                                             self.currentLocationCity.frame.origin.y - self.currentLocationStreetAddress.frame.origin.y +
                                                             self.currentLocationCity.frame.size.height);
        self.currentLocationStreetAddress.numberOfLines = 3;
        self.currentLocationStreetAddress.lineBreakMode = UILineBreakModeWordWrap;
        [self.currentLocationStreetAddress setFont:[UIFont  fontWithName:@"HelveticaNeue-CondensedBold" size:17]];
        self.currentLocationStreetAddress.minimumFontSize = 8.0;
        self.currentLocationStreetAddress.textAlignment   = UITextAlignmentCenter;
        self.currentLocationCity.frame         = CGRectZero;
        self.currentLocationZipCode.frame      = CGRectZero;
    }
    if (PFBrandingSupported(BrandingViollier, nil)) {
        self.currentLocationStreetAddress.text = self.currentDeparture.location_id.location_name;
        self.currentLocationStreetAddress.text = self.currentDeparture.location_id.location_name;
    } else {
        self.currentLocationCity.text          = self.currentDeparture.location_id.city;
        self.currentLocationZipCode.text       = self.currentDeparture.location_id.zip;
        self.currentLocationStreetAddress.text = self.currentDeparture.location_id.street;
    }
    if (PFTourTypeSupported(@"1X1", nil) && PFBrandingSupported(BrandingOerlikon, nil) &&
             self.currentDeparture.location_id.code && self.currentDeparture.location_id.code.length > 0) {
        self.departureLabel.text       = [NSString stringWithFormat:@"%@", self.currentDeparture.location_id.location_name];
        self.departureLabel.numberOfLines = 2;
        self.departureLabel.lineBreakMode = UILineBreakModeWordWrap;
        self.departureLabel.font = [UIFont fontWithName:self.departureLabel.font.familyName size:15];
        self.departureTime.frame       = CGRectMake(self.departureLabel.frame.origin.x,
                                                    self.departureLabel.frame.origin.y,
                                                    self.departureExtension.frame.origin.x
                                                    + self.departureExtension.frame.size.width
                                                    - self.departureLabel.frame.origin.x,
                                                    self.departureLabel.frame.size.height);
        self.departureTime.hidden      = YES;
        self.departureExtension.hidden = YES;
    } else if (self.currentDeparture.departure) {
        self.departureLabel.text = NSLocalizedString(@"MESSAGE_026", @"Abfahrt:");
        self.departureTime.text  = [NSDateFormatter localizedStringFromDate:
                                    self.currentDeparture.departure dateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterShortStyle];
    } else if (self.currentDeparture.arrival) {
        self.departureLabel.text = NSLocalizedString(@"MESSAGE_026", @"Abfahrt:");
        self.departureTime.text  = [NSDateFormatter localizedStringFromDate:
                                    self.currentDeparture.arrival dateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterShortStyle];
    } else if (self.currentDeparture.location_id.location_code)  { 
        self.departureLabel.text       = self.currentDeparture.location_id.location_code;
        self.departureTime.hidden      = YES;
        self.departureExtension.hidden = YES;
    } else if (self.currentDeparture.transport_group_id.task)  { 
        self.departureLabel.text       = self.currentDeparture.transport_group_id.task;
        self.departureTime.hidden      = YES;
        self.departureExtension.hidden = YES;
    } else if (PFTourTypeSupported(@"1X1", nil) &&
               self.currentDeparture.location_id.code && self.currentDeparture.location_id.code.length > 0) {
        self.departureLabel.text       = [NSString stringWithFormat:@"%@", self.currentDeparture.location_id.location_name];
        self.departureLabel.numberOfLines = 2;
        self.departureLabel.lineBreakMode = UILineBreakModeWordWrap;
        self.departureLabel.font = [UIFont fontWithName:self.departureLabel.font.familyName size:15];
        self.departureTime.frame       = CGRectMake(self.departureLabel.frame.origin.x,
                                                    self.departureLabel.frame.origin.y,
                                                    self.departureExtension.frame.origin.x
                                                    + self.departureExtension.frame.size.width
                                                    - self.departureLabel.frame.origin.x,
                                                    self.departureLabel.frame.size.height);
        self.departureTime.hidden      = YES;
        self.departureExtension.hidden = YES;
    } else {
        self.departureLabel.text       = [NSString stringWithFormat:@"%@", self.currentDeparture.departure_id];
        self.departureTime.hidden      = YES;
        self.departureExtension.hidden = YES;
    }
    
    [AppStyle customizePickerView:self.pickerView];
    [AppStyle customizePickerViewToolbar:self.pickerViewToolbar];
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
	label.text = [NSString stringWithFormat:@"  %@", NSLocalizedString([[self traceTypeForRow:row forComponent:component] localizedDescriptionText], nil)];
    if (PFBrandingSupported(BrandingOerlikon, nil)) {
        label.font = [UIFont fontWithName:@"Helvetica-Bold" size:18];
    }
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

- (IBAction)didConfirmDeadhead {
    if (PFBrandingSupported(BrandingOerlikon, nil)) {
        if (!self.pickerViewDetailMode &&
            [[Trace_Type trace_TypesWithPredicate:[NSPredicate predicateWithFormat:@"trace_type_id = %i",
                                                   ((([self.currentSelection.trace_type_id integerValue] - 90) * 10) + 101)]
                                  sortDescriptors:nil inCtx:self.ctx] lastObject]) {
            UIButton *backButton = [UIButton buttonWithType:101];  // left-pointing shape!
            [backButton addTarget:self action:@selector(dismissPickerViewDetailMode) forControlEvents:UIControlEventTouchUpInside];
            [backButton setTitle:NSLocalizedString([self.currentSelection localizedDescriptionText], nil) forState:UIControlStateNormal];
            self.pickerViewDetailMode = YES;
            self.traceTypes = [Trace_Type trace_TypesWithPredicate:[NSPredicate predicateWithFormat:@"trace_type_id BETWEEN {%i, %i}",
                                                                    ((([self.currentSelection.trace_type_id integerValue] - 90) * 10) + 101),
                                                                    ((([self.currentSelection.trace_type_id integerValue] - 90) * 10) + 109)]
                                                   sortDescriptors:[Trace_Type defaultSortDescriptors] inCtx:self.ctx];
            [self.pickerView reloadAllComponents];
            [self.pickerViewToolbar setItems:[[NSArray arrayWithObject:[[[UIBarButtonItem alloc] initWithCustomView:backButton] autorelease]]
                                              arrayByAddingObjectsFromArray:self.pickerViewToolbar.items]
                                    animated:YES];
            [self.pickerView selectRow:0 inComponent:0 animated:YES];
            self.currentSelection = [self traceTypeForRow:0 forComponent:0];
            return;
        }
    }
   
    if (PFBrandingSupported(BrandingTechnopark, nil))
    {
        if (!_currentDepartures)
            [self createMessageForDeparture:self.currentDeparture];
        else
        {
            for (Departure* departure in _currentDepartures) {
                [self createMessageForDeparture:departure];
            }
            
            if (_delegate && [_delegate respondsToSelector:@selector(deadheadDidConfirm)])
                [_delegate deadheadDidConfirm];
        }
    }
    else
        [self createMessageForDeparture:self.currentDeparture];
    
    [CATransaction begin];
    [CATransaction setCompletionBlock:^{
        // handle completion here
        if (_delegate && [_delegate respondsToSelector:@selector(deadheadDidDismiss)])
            [_delegate deadheadDidDismiss];
    }];
    
    [self.navigationController popViewControllerAnimated:YES];
    
    [CATransaction commit];
}

- (void) createMessageForDeparture:(Departure*) departure
{
    NSString *code = [NSDateFormatter localizedStringFromDate:[NSDate date] dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterLongStyle];
    NSMutableDictionary *currentTransport = [Transport dictionaryWithCode:code traceType:[self.currentSelection.trace_type_id integerValue]
                                                            fromDeparture:departure toLocation:departure.location_id];
    if (departure.transport_group_id) 
        [currentTransport setValue:departure.transport_group_id.task                                       forKey:@"task"];
    
    [Transport transportWithDictionaryData:currentTransport inCtx:self.ctx];
    if ([departure.currentTourStatus intValue] < 50) {
        departure.currentTourStatus = [NSNumber numberWithInt:45];
    }
    if (PFBrandingSupported(BrandingTechnopark, nil))
        departure.canceled = @YES;
    [self.ctx saveIfHasChanges];

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
    [currentDeparture			  release];
	[currentSelection			  release];
    [departureExtension           release];
    [departureTime                release];
	[departureLabel               release];
	[currentLocationStreetAddress release];
	[currentLocationZipCode       release];
	[currentLocationCity		  release];
	[ctx		  release];
	[traceTypes					  release];
	[pickerView					  release];
    [pickerViewToolbar            release];
    [_currentDepartures           release];
    [super dealloc];
}


@end
