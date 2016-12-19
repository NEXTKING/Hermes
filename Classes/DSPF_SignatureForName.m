//
//  DSPF_SignatureForName.m
//  Hermes
//
//  Created by Lutz  Thalmann on 10.05.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "HermesAppDelegate.h"
#import "DSPF_SignatureForName.h"

#import "Location.h"
#import "Transport.h"
#import "Item.h"

@implementation DSPF_SignatureForName

@synthesize nameForSignature;
@synthesize signatureImage;
@synthesize signatureLogo;
@synthesize tableView;
@synthesize signatureLock;
@synthesize infoText;
@synthesize toolbar;
@synthesize departure;
@synthesize currentTransportGroup;
@synthesize isPickup;
@synthesize isReturnablePackaging;
@synthesize lastPoint;
@synthesize isDrawing;
@synthesize ctx;
@synthesize	transportCodes;
@synthesize tableViewImage;
@synthesize confirmedSignature;
@synthesize delegate;


#pragma mark - Initialization

- (NSManagedObjectContext *)ctx {
    if (!ctx) { 
		ctx = [[(HermesAppDelegate *)[[UIApplication sharedApplication] delegate] ctx] retain]; 
    }
    return ctx;
}

- (void)confirmBackButton {
	[[DSPF_Confirm question:NSLocalizedString(@"MESSAGE_005", @"Keine Unterschrift gespeichert !") item:@"confirmBackButton" 
             buttonTitleYES:((UIViewController *)[self.navigationController.viewControllers objectAtIndex:(self.navigationController.viewControllers.count - 2)]).title  
              buttonTitleNO:NSLocalizedString(@"TITLE_004", @"Abbrechen") showInView:self.view] setDelegate:self];
}

- (void)prepareTransportCodes {
    NSString *traceTypeCodeValue = TraceTypeStringUnload;
    if (self.isPickup) traceTypeCodeValue = TraceTypeStringLoad;
    NSDate *minTraceTime = [[NSDate date] dateByAddingTimeInterval:-3600*8];
    
    NSPredicate *finalPredicate = nil;
    NSPredicate *noTraceLogOrEarlyTracelog = OrPredicates([Transport withoutTracelogEntries], [Transport havingTraceLogEntriesOlderThan:minTraceTime], nil);
    NSPredicate *traceTypeCode = [Transport withTraceLogCodes:@[traceTypeCodeValue]];
    NSPredicate *itemNilOrCategory2 = OrPredicates([Transport withItemsCategoryCodes:@[@2]], [Transport withoutItem], nil);
    
    NSArray *sortDescriptors = nil;
    NSPredicate *transportGroupId = [NSPredicate predicateWithValue:YES];
    if (self.currentTransportGroup || (PFTourTypeSupported(@"1X1", nil) && self.isReturnablePackaging)) {
        transportGroupId = [Transport withTransportGroup:self.currentTransportGroup];
    } else if (self.departure.transport_group_id.transport_group_id) {
        transportGroupId = [Transport withTransportGroup:self.departure.transport_group_id];
    } else {
        Transport_Group *localTg = [Transport_Group transportGroupForItem:self.departure ctx:self.ctx createWhenNotExisting:NO];
        if (localTg != nil) {
            transportGroupId = [Transport withTransportGroup:localTg];
        }
    }
    
    if (PFTourTypeSupported(@"1X1", nil)) {
        NSPredicate *withFromDepartureId = [Transport withFromDeparture:self.departure];
        if (self.isReturnablePackaging) {
            sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"item_id.itemID" ascending:YES],
                                [NSSortDescriptor sortDescriptorWithKey:@"itemQTY"        ascending:NO]];
            finalPredicate = AndPredicates(withFromDepartureId, transportGroupId, nil);
        } else {
            finalPredicate = AndPredicates(withFromDepartureId, transportGroupId, itemNilOrCategory2, traceTypeCode, noTraceLogOrEarlyTracelog, nil);
        }
    } else {
        NSPredicate *withFromDepartureLocationId = [Transport withFromDepartureLocation:self.departure.location_id];
        finalPredicate = AndPredicates(withFromDepartureLocationId, transportGroupId, itemNilOrCategory2, traceTypeCode, nil);
    }
    if (PFBrandingSupported(BrandingOerlikon, nil)) {
        self.transportCodes = [[NSSet setWithArray:[self.transportCodes valueForKeyPath:@"transport_group_id"]] allObjects];
    } else {
        self.transportCodes = [Transport transportsWithPredicate:finalPredicate sortDescriptors:sortDescriptors inCtx:self.ctx];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.title                  = self.nameForSignature;
    UIImage  *tmpLogo           = nil;
    if (self.departure.transport_group_id.contractee_code) {
        tmpLogo = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:
                    [NSString stringWithFormat:@"%@_logo", self.departure.transport_group_id.contractee_code] ofType:@"png"]];
    }
    if (tmpLogo == nil) {
        tmpLogo = PFBrandingLogo();
    }
    /* equalize all brandings (0.75) and scale to fit the image width into the frame */
    self.signatureLogo.image    = [UIImage imageWithCGImage:[tmpLogo CGImage] scale:0.75 * (tmpLogo.size.width / self.signatureLogo.frame.size.width) 
                                                orientation:UIImageOrientationUp]; 
    self.infoText.font          = [UIFont  fontWithName:@"Helvetica-Bold" size:20];
    self.infoText.text          = NSLocalizedString(@"MESSAGE_006", @"Bitte\n\nhier\n\nunterschreiben.");
	self.isDrawing			    = NO;
    self.signatureLock.hidden   = YES;
    UIButton *backButton = [UIButton buttonWithType:101];      // left-pointing shape!
	[backButton addTarget:self action:@selector(confirmBackButton) forControlEvents:UIControlEventTouchUpInside];
	[backButton setTitle:((UIViewController *)[self.navigationController.viewControllers objectAtIndex:(self.navigationController.viewControllers.count - 2)]).title 
                forState:UIControlStateNormal];
	self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:backButton] autorelease];
    self.toolbar.hidden = NO;
    self.toolbar.alpha  = 1.0;
    
    [self prepareTransportCodes];
    
    [self.tableView reloadData];
    // Screenshot von der aktuellen Anzeige erstellen und als UIImage anzeigen
    UIGraphicsBeginImageContext(self.signatureImage.bounds.size);
    [self.tableView.layer renderInContext:UIGraphicsGetCurrentContext()];
    self.tableViewImage = [[UIGraphicsGetImageFromCurrentImageContext() copy] autorelease];
    UIGraphicsEndImageContext();
    self.signatureImage.image = self.tableViewImage;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    [AppStyle customizeToolbar:self.toolbar];
}

- (void) viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    if (self.signatureImage.image && confirmedSignature != nil) {
        [self.delegate dspf_SignatureForName:self didReturnSignature:confirmedSignature forName:self.nameForSignature];
    }
}

- (IBAction)confirm {
    if (self.signatureImage.image) {
        self.toolbar.hidden = YES;
        // Screenshot von der aktuellen Anzeige erstellen und als UIImage speichern
        UIGraphicsBeginImageContext(self.navigationController.view.bounds.size);
        [self.navigationController.view.layer renderInContext:UIGraphicsGetCurrentContext()];
        self.confirmedSignature = [[UIGraphicsGetImageFromCurrentImageContext() copy] autorelease];
        UIGraphicsEndImageContext();
        
        [self.navigationController popToViewController:(UIViewController *)self.delegate animated:YES];
        // delegate is called when view did disappear
    } else {
        self.infoText.hidden = NO;
    }
}

- (IBAction)clear { 
	self.signatureImage.image = self.tableViewImage;
    self.infoText.hidden = NO;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    self.infoText.hidden = YES;
    self.isDrawing       = NO;	
    lastPoint            = [[touches anyObject] locationInView:self.signatureImage]; 
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	// touchesBegan + touchesMoved ->  a line
    self.isDrawing       = YES;    
    CGPoint currentPoint = [[touches anyObject] locationInView:self.signatureImage];    
    UIGraphicsBeginImageContext(self.signatureImage.bounds.size);
    [self.signatureImage.image drawInRect:CGRectMake(self.signatureImage.bounds.origin.x, 
                                                     self.signatureImage.bounds.origin.y, 
                                                     self.signatureImage.bounds.size.width, 
                                                     self.signatureImage.bounds.size.height)];
    CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
    CGContextSetLineWidth(UIGraphicsGetCurrentContext(), 2.0);
	CGContextSetStrokeColorWithColor(UIGraphicsGetCurrentContext(), [UIColor blackColor].CGColor);
    CGContextBeginPath(UIGraphicsGetCurrentContext());
    CGContextMoveToPoint(UIGraphicsGetCurrentContext(), lastPoint.x, lastPoint.y);
    CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), currentPoint.x, currentPoint.y);
    CGContextStrokePath(UIGraphicsGetCurrentContext());
    self.signatureImage.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();    
    lastPoint = currentPoint;	
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	// touchesBegan + touchesEnded ->  a dot
    if(!self.isDrawing) {
        UIGraphicsBeginImageContext(self.signatureImage.bounds.size);
        [self.signatureImage.image drawInRect:CGRectMake(self.signatureImage.bounds.origin.x, 
                                                         self.signatureImage.bounds.origin.y, 
                                                         self.signatureImage.bounds.size.width, 
                                                         self.signatureImage.bounds.size.height)];
        CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
        CGContextSetLineWidth(UIGraphicsGetCurrentContext(), 2.0);
		CGContextSetStrokeColorWithColor(UIGraphicsGetCurrentContext(), [UIColor blackColor].CGColor);
        CGContextMoveToPoint(UIGraphicsGetCurrentContext(), lastPoint.x, lastPoint.y);
        CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), lastPoint.x, lastPoint.y);
        CGContextStrokePath(UIGraphicsGetCurrentContext());
        CGContextFlush(UIGraphicsGetCurrentContext());
        self.signatureImage.image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
}

- (void) dspf_Confirm:(DSPF_Confirm *)sender didConfirmQuestion:(NSString *)question item:(NSObject *)item withButtonTitle:(NSString *)buttonTitle {
	if (![buttonTitle isEqualToString:NSLocalizedString(@"TITLE_004", @"Abbrechen")]) {
		if ([(NSString *)item isEqualToString:@"confirmBackButton"]) {
			[self.navigationController popViewControllerAnimated:YES];
		}
	}
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [self.transportCodes count];
}

- (NSString *)tableView:(UITableView *)aTableView titleForHeaderInSection:(NSInteger)aSection {
    NSString *title = nil;
    
	if(aSection == 0) {
        if (self.isReturnablePackaging) {
            title = @"Leergutquittung für:";
        } else if (self.isPickup) {
            if (PFBrandingSupported(BrandingOerlikon, nil)) {
                title = [NSString stringWithFormat:@"Abholbestätigung für\nfolgende %i Lieferscheine:", [self.transportCodes count]];
                if ([self.transportCodes count] == 1) {
                    title = @"Abholbestätigung für\nfolgenden Lieferschein:";
                }
            } else {
                title = [NSString stringWithFormat: NSLocalizedString(@"MESSAGE_047", @"Abholbestätigung für\nfolgende %i Pakete:"), [self.transportCodes count]];
                if ([self.transportCodes count] == 1) {
                    title = NSLocalizedString(@"MESSAGE_046", @"Abholbestätigung für\nfolgendes Paket:");
                }
            }
        } else {
            if (PFBrandingSupported(BrandingOerlikon, nil)) {
                title = [NSString stringWithFormat:@"Empfangsbestätigung für\nfolgende %i Lieferscheine:", [self.transportCodes count]];
                if ([self.transportCodes count] == 1) {
                    title = @"Empfangsbestätigung für\nfolgenden Lieferschein:";
                }
            } else {
                title = [NSString stringWithFormat: NSLocalizedString(@"MESSAGE_008", @"Empfangsbestätigung für\nfolgende %i Pakete:"), [self.transportCodes count]];
                if ([self.transportCodes count] == 1) {
                    title = NSLocalizedString(@"MESSAGE_007", @"Empfangsbestätigung für\nfolgendes Paket:");
                }
            }
        }
	}
	return title;
}

- (NSString *)transportCode:(NSIndexPath *)indexPath {
    if (PFBrandingSupported(BrandingOerlikon, nil)) {
        return [[self.transportCodes objectAtIndex:indexPath.row] valueForKey:@"task"];
    } else if (PFBrandingSupported(BrandingCCC_Group, nil)) {
        NSString *code = nil;
        Transport *tmpTransport = [self.transportCodes objectAtIndex:indexPath.row];
        if (self.isReturnablePackaging) {
            code = [NSString stringWithFormat:@"%3i %@",
                    [tmpTransport.itemQTY intValue], [Item localDescriptionTextForItem:tmpTransport.item_id]];
        } else if (self.isPickup) {
            code = tmpTransport.pickUpDocumentNumber;
        } else {
            code = tmpTransport.deliveryDocumentNumber;
        }
        if (!code || code.length == 0) {
            code = tmpTransport.code;
        }
        return code;
    }
    return [[self.transportCodes objectAtIndex:indexPath.row] valueForKey:@"code"];
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
    cell.backgroundColor             = [UIColor clearColor];
    cell.contentView.backgroundColor = [UIColor clearColor];
    cell.textLabel.backgroundColor   = [UIColor clearColor];
	cell.textLabel.text              = [self transportCode:indexPath];
	cell.textLabel.textAlignment     = UITextAlignmentLeft;
    cell.textLabel.font              = [UIFont fontWithName:@"Helvetica" size:14];
	cell.selectionStyle              = UITableViewCellSelectionStyleNone;
    
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
}


#pragma mark - Memory management

- (void)viewDidUnload {
    [super viewDidUnload];

    self.infoText                = nil;
    self.toolbar                 = nil;
    self.signatureLock           = nil;
    self.tableView               = nil;
    self.signatureLogo           = nil;
	self.signatureImage          = nil;
}


- (void)dealloc {
    [ctx	release];
    [tableViewImage         release];
	[transportCodes			release];
    [infoText               release];
    [toolbar                release];
    [signatureLock          release];
    [tableView              release];
    [signatureLogo          release];
	[signatureImage         release];
    [nameForSignature       release];
    [currentTransportGroup  release];
    [departure              release];
    [super dealloc];
}


@end
