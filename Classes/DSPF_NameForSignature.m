//
//  DSPF_NameForSignature.m
//  Test
//
//  Created by Lutz  Thalmann on 10.05.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "HermesAppDelegate.h"
#import "DSPF_NameForSignature.h"
#import "DSPF_SignatureForName.h"
#import "DSPF_Suspend.h"

#import "Location.h"
#import "Recipient.h"

@interface DSPF_NameForSignature ()
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
@end

@implementation DSPF_NameForSignature

@synthesize delegate;
@synthesize inputView;
@synthesize tableView;
@synthesize textInput;
@synthesize departure;
@synthesize currentTransportGroup;
@synthesize isPickup;
@synthesize isReturnablePackaging;
@synthesize ctx;
@synthesize fetchedResultsController =__fetchedResultsController;

#pragma mark - Initialization

- (NSManagedObjectContext *)ctx {
    if (!ctx) { 
		ctx = [[(HermesAppDelegate *)[[UIApplication sharedApplication] delegate] ctx] retain];
    }
    return ctx;
}

- (void)suspend {
	[DSPF_Suspend suspendWithDefaultsOnViewController:self]; 
}


- (void)confirmBackButton {
	[[DSPF_Confirm question:NSLocalizedString(@"MESSAGE_003", @"Unterschrift von Empfänger fehlt !") item:@"confirmBackButton" 
             buttonTitleYES:((UIViewController *)self.delegate).title 
              buttonTitleNO:NSLocalizedString(@"TITLE_004", @"Abbrechen") showInView:self.view] setDelegate:self];
}

- (void)toggleEditing {
    if (self.editing) {
        self.navigationItem.rightBarButtonItem.title = NSLocalizedString(@"TITLE_040", @"Bearbeiten");
    } else {
        self.navigationItem.rightBarButtonItem.title = NSLocalizedString(@"TITLE_041", @"Fertig");
    }
    [self setEditing:!self.editing animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if (self.isReturnablePackaging) {
        self.title = NSLocalizedString(@"TITLE_116", @"Mehrwegverpackungen");
    } else if (self.isPickup) {
        self.title = NSLocalizedString(@"TITLE_115", @"Absender");
    } else {
        self.title = NSLocalizedString(@"TITLE_042", @"Empfänger");
    }
    self.textInput.placeholder = NSLocalizedString(@"PLACEHOLDER_004", @"Neu hinzufügen");
    if (!self.tableView && [self.view isKindOfClass:[UITableView class]]) {
        self.tableView = (UITableView *)(self.view);
        self.tableView.backgroundColor = [[[UIColor alloc] initWithWhite:0.87 alpha:1.0] autorelease];
		UITapGestureRecognizer *tapToSuspend = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(suspend)] autorelease];
		[tapToSuspend	setNumberOfTapsRequired:2];
		[tapToSuspend	setNumberOfTouchesRequired:2];
		[self.tableView	addGestureRecognizer:tapToSuspend];
    }
	self.view = self.inputView;
    self.view.backgroundColor      = [[[UIColor alloc] initWithWhite:0.87 alpha:1.0] autorelease];
    self.textInput.delegate        = self;
    self.textInput.backgroundColor = [UIColor whiteColor];
    UITapGestureRecognizer *tapToSuspend_here = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(suspend)] autorelease];
	[tapToSuspend_here setNumberOfTapsRequired:2];
	[tapToSuspend_here setNumberOfTouchesRequired:2];
	[self.inputView	   addGestureRecognizer:tapToSuspend_here];
    if (self.isReturnablePackaging) {
        self.navigationItem.hidesBackButton = YES;
    } else {
        UIButton *backButton    = [UIButton buttonWithType:101];      // left-pointing shape!
        [backButton addTarget:self action:@selector(confirmBackButton) forControlEvents:UIControlEventTouchUpInside];
        [backButton setTitle:((UIViewController *)self.delegate).title forState:UIControlStateNormal];
        self.navigationItem.leftBarButtonItem  = [[[UIBarButtonItem alloc] initWithCustomView:backButton] autorelease];
    }
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    if ([sectionInfo numberOfObjects] == 0) {
        self.navigationItem.rightBarButtonItem = nil;
        [self setEditing:NO animated:NO];
    } else {
        self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"TITLE_040", @"Bearbeiten") 
                                                                                   style:UIBarButtonItemStyleBordered 
                                                                                  target:self 
                                                                                  action:@selector(toggleEditing)] autorelease];
        if (self.editing) {
            self.navigationItem.rightBarButtonItem.title = NSLocalizedString(@"TITLE_041", @"Fertig");
        }
    }
    return [sectionInfo numberOfObjects];
}

- (NSString *)tableView:(UITableView *)aTableView titleForHeaderInSection:(NSInteger)aSection {
    
	if(aSection == 0) {
		return NSLocalizedString(@"TITLE_043", @"Liste:");
	}
	return nil;
}

- (NSString *)tableView:(UITableView *)aTableView titleForFooterInSection:(NSInteger)aSection {
    
	if(aSection == 0) {
		return NSLocalizedString(@"MESSAGE_004", @"Zum Unterschreiben bitte hier\nden Namen der Person auswählen,\n die unterschreiben soll.\nFehlende Namen bitte erfassen.");
	}
	return nil;
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }

    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath { 
    return NO; 
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.ctx deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
        [self.ctx saveIfHasChanges];
    }   
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.ctx saveIfHasChanges];
    DSPF_SignatureForName *dspf_SignatureForName = [[[DSPF_SignatureForName alloc] initWithNibName:@"DSPF_SignatureForName" bundle:nil] autorelease];
    dspf_SignatureForName.nameForSignature       = ((Recipient *)[self.fetchedResultsController objectAtIndexPath:indexPath]).recipient_name;
    dspf_SignatureForName.departure              = self.departure;
    dspf_SignatureForName.currentTransportGroup  = self.currentTransportGroup;
    dspf_SignatureForName.isPickup               = self.isPickup;
    dspf_SignatureForName.isReturnablePackaging  = self.isReturnablePackaging;
    dspf_SignatureForName.delegate               = self.delegate;
	[self.navigationController pushViewController:dspf_SignatureForName animated:YES];
}

- (void) dspf_Confirm:(DSPF_Confirm *)sender didConfirmQuestion:(NSString *)question item:(NSObject *)item withButtonTitle:(NSString *)buttonTitle {
	if (![buttonTitle isEqualToString:NSLocalizedString(@"TITLE_004", @"Abbrechen")]) {
		if ([(NSString *)item isEqualToString:@"confirmBackButton"]) {
			[self.navigationController popToViewController:(UIViewController *)self.delegate animated:YES];
		}
	}
}



- (void)viewDidUnload {
    [super viewDidUnload];

    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
    self.tableView = nil;
	self.inputView = nil;
    self.textInput = nil;
}

- (void)dealloc {
    [__fetchedResultsController release];
    [ctx       release];
    [textInput                  release];
    [tableView                  release];
    [inputView                  release];
    [currentTransportGroup      release];
    [departure                  release];
    [super dealloc];
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    cell.textLabel.text = ((Recipient *)[self.fetchedResultsController objectAtIndexPath:indexPath]).recipient_name;
}

- (void)insertNewObject {
    // Create a new instance of the entity managed by the fetched results controller.
    Recipient  *newRecipient = [NSEntityDescription insertNewObjectForEntityForName:@"Recipient" inManagedObjectContext:self.ctx];
    // If appropriate, configure the new managed object.
    // Normally you should use accessor methods, but using KVC here avoids the need to add a custom class to the template.
    NSMutableDictionary *recipientData = [NSMutableDictionary dictionaryWithCapacity:2];
    [recipientData setValue:self.departure.location_id.location_id forKey:@"location_id"];
    [recipientData setValue:self.textInput.text                    forKey:@"recipient_name"];
    newRecipient.location_id    = [Location  locationWithRecipientData:recipientData inCtx:self.ctx];
    newRecipient.recipient_name = [recipientData valueForKey:@"recipient_name"];
    // Save the context.
    [self.ctx saveIfHasChanges];
}

#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController {
    if (__fetchedResultsController != nil) {
        return __fetchedResultsController;
    }    

    NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
    // Edit the entity name as appropriate.
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"Recipient" inManagedObjectContext:self.ctx]];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"location_id.location_id = %i", [self.departure.location_id.location_id intValue]]];    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];    
    // Edit the sort key as appropriate.    
    [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:[[[NSSortDescriptor alloc] initWithKey:@"recipient_name" ascending:YES] autorelease], nil]];
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    self.fetchedResultsController = [[[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest 
                                                                        managedObjectContext:self.ctx sectionNameKeyPath:nil cacheName:nil] autorelease];
    self.fetchedResultsController.delegate = self;

	NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error])
        {
	    /*
	     Replace this implementation with code to handle the error appropriately.

	     abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
	     */
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}    
    return __fetchedResultsController;
}    

#pragma mark - Fetched results controller delegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
        default:
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[self.tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
        case NSFetchedResultsChangeMove:
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView endUpdates];
}


#pragma mark - Text field delegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)aTextField {
	aTextField.text            = nil;
	aTextField.textColor       = [UIColor blackColor];
    aTextField.backgroundColor = [UIColor whiteColor];
	aTextField.font            = [UIFont fontWithName:@"Helvetica" size:18];
	return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)aTextField {
	if (aTextField.text && aTextField.text.length > 0) {
        self.textInput.text = aTextField.text;
        [self insertNewObject];
	}
    [self.textInput resignFirstResponder];
    self.textInput.text = nil;
    return YES;
}

@end
