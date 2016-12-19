//
//  DSPF_SelectTruck.m
//  Hermes
//
//  Created by Lutz  Thalmann on 23.10.11.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "HermesAppDelegate.h"
#import "DSPF_SelectTruck.h"
#import "DSPF_SelectTour.h"
#import "User.h"
#import "DSPF_Menu.h"

@interface DSPF_SelectTruck()
@property (nonatomic, retain) NSArray					*trucks;
@property (nonatomic, retain) Truck                     *currentSelection;
@end


@implementation DSPF_SelectTruck
@synthesize usrprf;
@synthesize neueTourLabel;
@synthesize benutzerLabel;
@synthesize truckButton;
@synthesize trucks;
@synthesize pickerView;
@synthesize pickerViewToolbar;
@synthesize currentSelection;
@synthesize jumpThroughOption;
@synthesize navigationController;

- (void) jumpThrough
{
    if (self.trucks.count > 0)
    {
        [self didChooseTruck:[self.trucks firstObject]];
    }
    else
    {
        [DSPF_Warning messageTitle:@"Внимание!" messageText:@"В данный момент для Вас нет доступных маршрутов" item:nil delegate:nil];
    }
}

- (NSArray *)trucks {
    if (!trucks) {
        
        if (PFBrandingSupported(BrandingTechnopark, nil))
        {
            trucks = [[Truck withPredicate:[NSPredicate predicateWithFormat:@"device_udid = %@", PFDeviceId()] inCtx:ctx()] retain];
        }
        else
		trucks = [[Truck withPredicate:[DSPF_SelectTruck predicateForShownTrucks]
                       sortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"code" ascending:YES]] inCtx:ctx()] retain];
    }
    return trucks;
}

+ (NSPredicate *) predicateForShownTrucks {
    return [NSPredicate predicateWithFormat:@"truck_type_id.isTrailer = nil OR truck_type_id.isTrailer = NO"];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
		self.title = NSLocalizedString(@"TITLE_005", @"Fahrzeug");
        if (PFBrandingSupported(BrandingTechnopark, nil) )
            jumpThroughOption = @"Drive";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSInteger preselectedRow = [self preselectedRow];
	[self.pickerView selectRow:preselectedRow inComponent:0 animated:NO];
	self.currentSelection = [self truckForRow:preselectedRow forComponent:0];
    User *tmpUser = [User userWithUserID:[NSUserDefaults currentUserID] inCtx:ctx()];
    
    self.usrprf.text = [tmpUser firstAndLastName];
    if (self.usrprf.text.length == 0) {
        self.usrprf.text	 = tmpUser.username;
    }
    
    self.neueTourLabel.text = NSLocalizedString(@"MESSAGE_018", @"neue Tour");
    self.benutzerLabel.text = NSLocalizedString(@"MESSAGE_029", @"Benutzer");
    
    [self.truckButton setTitle:NSLocalizedString(@"TITLE_005", @"Fahrzeug") forState:UIControlStateNormal];
    self.truckButton.alpha = 0.0f;
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"barcode_white.png"]
                                                  style:UIBarButtonItemStyleBordered target:self action:@selector(switchViews)] autorelease];
    if (PFBrandingSupported(BrandingCCC_Group, nil)) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self switchViews];
        });
    }
    
    [AppStyle customizePickerView:self.pickerView];
    [AppStyle customizePickerViewToolbar:self.pickerViewToolbar];
}

- (void)switchViews {
    CGFloat truckAlpha = 0.0f;
    BOOL pickerViewHidden = NO;
    NSString *barButtonImageName = @"barcode_white.png";
    UIViewAnimationOptions pickerViewFlip = UIViewAnimationOptionCurveEaseOut;
    UIViewAnimationOptions toolbarFlip = UIViewAnimationOptionCurveEaseOut;
    if (self.pickerView.hidden) {
        pickerViewFlip = pickerViewFlip | UIViewAnimationOptionTransitionFlipFromBottom;
        toolbarFlip = toolbarFlip | UIViewAnimationOptionTransitionFlipFromTop;
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"barcodeData" object:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"disconnectScanDevice" object:self userInfo:nil];
    } else {
        truckAlpha = 1.0f;
        pickerViewHidden = YES;
        barButtonImageName = @"keyboard.png";
        pickerViewFlip = pickerViewFlip | UIViewAnimationOptionTransitionFlipFromTop;
        toolbarFlip = toolbarFlip | UIViewAnimationOptionTransitionFlipFromBottom;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"connectScanDevice" object:self userInfo:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"barcodeData" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReturnBarcode:) name:@"barcodeData" object:nil];
    }
    
    [UIView transitionWithView:self.pickerView duration:0.618 options:pickerViewFlip animations:^{
        self.truckButton.alpha = truckAlpha;
    } completion:nil];
    
    [UIView transitionWithView:self.pickerView duration:0.618 options:pickerViewFlip animations:^{
        [self.pickerView setHidden:pickerViewHidden];
    } completion:nil];
    
    [UIView transitionWithView:self.pickerViewToolbar duration:0.618 options:toolbarFlip animations:^{
        [self.pickerViewToolbar setHidden:pickerViewHidden];
    } completion:^(BOOL finished){
        self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:barButtonImageName]
                                                                                   style:UIBarButtonItemStyleBordered
                                                                                  target:self action:@selector(switchViews)] autorelease];
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.pickerView.hidden) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"connectScanDevice" object:self userInfo:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self   name:@"barcodeData" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReturnBarcode:) name:@"barcodeData" object:nil];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    if ([self.navigationController.viewControllers indexOfObject:self]==NSNotFound) {
        // back button was pressed.
		// We know this is true because self is no longer in the navigation stack.
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"barcodeData" object:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"disconnectScanDevice" object:self userInfo:nil];
    }
    [super viewWillDisappear:animated];
}

+ (BOOL) shouldBeDisplayed {
    return [NSUserDefaults isRunningWithTourAdjustment] || PFTourTypeSupported(@"0X0", nil) || PFBrandingSupported(BrandingUnilabs, BrandingNONE,BrandingTechnopark, nil);
}

#pragma mark - Button actions

- (IBAction)scanDown:(UIButton *)aButton {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"startScan" object:self userInfo:nil];
}

- (IBAction)scanUp:(UIButton *)aButton {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"stopScan" object:self userInfo:nil];
}

- (void)didReturnBarcode:(NSNotification *)aNotification {
    NSString *barcode = [[aNotification userInfo] valueForKey:@"barcodeData"];
    NSArray  *tmpTrucks = [Truck withPredicate:[Truck withCode:barcode] inCtx:ctx()];
    if (tmpTrucks.count == 1) {
        [self didChooseTruck:((Truck *)[tmpTrucks lastObject])];
    }
}

- (IBAction)didConfirmTruck {
    [self didChooseTruck:self.currentSelection];
}

- (void) didChooseTruck:(Truck *) truck {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"barcodeData" object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"disconnectScanDevice" object:self userInfo:nil];
    [NSUserDefaults setCurrentTruckId:truck.truck_id];
    UIViewController *controllerToShow = nil;
    if ([DSPF_SelectTour shouldBeDisplayed]) {
        controllerToShow = [[DSPF_SelectTour alloc] init];
    } else {
        controllerToShow = [[[DSPF_Menu alloc] initWithParameters:nil] autorelease];
    }
    [self.navigationController pushViewController:controllerToShow animated:YES];
}

#pragma mark - PickerView delegate

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return self.trucks.count;
}

- (UIView *)pickerView:(UIPickerView *)aPickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    UILabel *label = (id)view;
    if (!label || ([label class] != [UILabel class])) {
        label = [[[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, [aPickerView rowSizeForComponent:component].width, [aPickerView rowSizeForComponent:component].height)] autorelease];
    }
    label.text = [NSString stringWithFormat:@"  %@",[self truckForRow:row forComponent:component].code];
    [AppStyle customizePickerViewLabel:label];
    return label;
}

- (void)pickerView:(UIPickerView *)aPickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    self.currentSelection = [self truckForRow:row forComponent:component];
}

- (Truck *)truckForRow:(NSInteger)row forComponent:(NSInteger)component {
    Truck *truck = nil;
    truck = [self.trucks objectAtIndex:row];
    return truck;
}

- (NSInteger) preselectedRow {
    NSPredicate *predicateForAssignedTruck = [NSManagedObject predicateForObjectsWithValue:PFDeviceId() forProperty:TruckAttributeDeviceUdid];
    Truck *preselectedTruck = [[self.trucks filteredArrayUsingPredicate:predicateForAssignedTruck] lastObject];
    NSInteger rowToReturn = 0;
    NSUInteger truckIndex = [self.trucks indexOfObject:preselectedTruck];
    if (truckIndex != NSNotFound) {
        rowToReturn = truckIndex;
    }
    return rowToReturn;
}

#pragma mark -

- (void)viewDidUnload {
    [super viewDidUnload];

	self.pickerView					  = nil;
    self.pickerViewToolbar            = nil;
    self.usrprf                       = nil;
    self.neueTourLabel                = nil;
    self.benutzerLabel                = nil;
    self.truckButton                  = nil;
}

- (void)dealloc {
	[currentSelection		release];
	[trucks					release];
    [pickerViewToolbar      release];
	[pickerView             release];
    [truckButton            release];
    [benutzerLabel          release];
    [neueTourLabel          release];
    [usrprf					release];
    [jumpThroughOption release];
    [super dealloc];
}


@end
