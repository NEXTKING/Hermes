//
//  DSPF_ShippingInfo.m
//  Hermes
//
//  Created by Lutz on 09.11.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "HermesAppDelegate.h"
#import "DSPF_ShippingInfo.h"
#import "Location.h"
#import "Transport.h"

@implementation DSPF_ShippingInfo

@synthesize ctx;
@synthesize listGroups;

#pragma mark - Initialization

- (NSManagedObjectContext *)ctx {
    if (!ctx) { 
		ctx = [[(HermesAppDelegate *)[[UIApplication sharedApplication] delegate] ctx] retain]; 
    }
    return ctx;
}

- (NSArray *)listGroups {
    if (!listGroups) {
		NSArray	 *sortDescriptors = [NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"city"			ascending:YES],
															  [NSSortDescriptor sortDescriptorWithKey:@"location_name"	ascending:YES],
															  [NSSortDescriptor sortDescriptorWithKey:@"location_id"	ascending:YES],
															   nil];
		listGroups = [[[NSArray arrayWithArray:[[NSSet setWithArray:
												[[Transport transportsWithPredicate:[NSPredicate predicateWithFormat:
                                                    @"tour_id.tour_id = %i && (item_id = nil OR item_id.itemCategoryCode = \"2\") && "
                                                     "trace_type_id = nil OR trace_type_id.code != %@ && !(trace_type_id.trace_type_id >= 80)",
                                                     [[NSUserDefaults currentTourId] intValue], @"LOAD"] 
																	sortDescriptors:nil inCtx:self.ctx] 
												 valueForKeyPath:@"to_location_id"]] allObjects]]
                       sortedArrayUsingDescriptors:sortDescriptors] retain]; 
    }
    return listGroups;
}


- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if ((self = [super initWithStyle:style])) {
        self.title = NSLocalizedString(@"TITLE_022", @"Versand");
    }
    return self;
}


#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Uncomment the following line to preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear = NO;
	// Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return self.listGroups.count;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
	NSArray *sectionItems = [NSArray arrayWithArray:
                             [Transport transportsWithPredicate:[NSPredicate predicateWithFormat:
                                @"tour_id.tour_id = %i && (item_id = nil OR item_id.itemCategoryCode = \"2\") && "
                                 "to_location_id.location_id = %lld && (trace_type_id = nil OR trace_type_id.code != %@ && !(trace_type_id.trace_type_id >= 80))",
                                 [[NSUserDefaults currentTourId] intValue],
                                 [((Location *)[self.listGroups objectAtIndex:section]).location_id longLongValue], @"LOAD"] 
                                                sortDescriptors:nil inCtx:self.ctx]];
	if (!sectionItems) {
		return 0;
	}
	return [sectionItems count];
}

- (NSString *)tableView:(UITableView *)aTableView titleForHeaderInSection:(NSInteger)aSection {	
	return [NSString stringWithFormat:@"%@: %@", [[self.listGroups objectAtIndex:aSection] valueForKey:@"city"],
												 [[self.listGroups objectAtIndex:aSection] valueForKey:@"location_name"]];
}

- (Transport *)listItem:(NSIndexPath *)indexPath {
	NSArray	*sortDescriptors = [NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"transport_id" ascending:YES], nil];
	NSArray *sectionItems = [NSArray arrayWithArray:
                             [Transport transportsWithPredicate:[NSPredicate predicateWithFormat:
                                @"tour_id.tour_id = %i && (item_id = nil OR item_id.itemCategoryCode = \"2\") && "
                                 "to_location_id.location_id = %lld && (trace_type_id = nil OR trace_type_id.code != %@ && !(trace_type_id.trace_type_id >= 80))",
                                 [[NSUserDefaults currentTourId] intValue],
                                 [((Location *)[self.listGroups objectAtIndex:indexPath.section]).location_id longLongValue], @"LOAD"] 
                                                sortDescriptors:sortDescriptors inCtx:self.ctx]];
    return [sectionItems objectAtIndex:indexPath.row];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"DSPF_ShippingInfo";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        if (PFBrandingSupported(BrandingBiopartner, nil)) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
        } else {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        }
    }
    
    // Configure the cell...
    Transport *tmpTransport = [self listItem:indexPath];
    if (PFBrandingSupported(BrandingCCC_Group, nil)) {
        NSString *code = tmpTransport.pickUpDocumentNumber;
        if (!code || code.length == 0) {
            code = tmpTransport.deliveryDocumentNumber;
        }
        if (!code || code.length == 0) {
            code = tmpTransport.code;
        }
        cell.textLabel.text = code;
    } else {
        cell.textLabel.text = tmpTransport.code;
    }
    if (PFBrandingSupported(BrandingViollier, nil)) {
        if ([cell.textLabel.text hasAnyPrefix:@[@"V001:", @"V007:"]]) {
            cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-CondensedBold" size:15];
            cell.textLabel.lineBreakMode = UILineBreakModeCharacterWrap;
            cell.textLabel.numberOfLines = 0;
        } else {
            cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-CondensedBold" size:17];
            cell.textLabel.lineBreakMode = UILineBreakModeCharacterWrap;
            cell.textLabel.numberOfLines = 0;
        }
    }
    if (PFBrandingSupported(BrandingBiopartner, nil)) {
        cell.detailTextLabel.text = tmpTransport.stagingArea;
    }
    cell.accessoryType  = UITableViewCellAccessoryNone;
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
}


#pragma mark - Memory management


- (void)dealloc {
	[ctx release];
    [listGroups			  release];
    [super dealloc];
}


@end

