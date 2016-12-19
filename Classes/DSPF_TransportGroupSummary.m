//
//  DSPF_TransportGroupSummary.m
//  Hermes
//
//  Created by Lutz on 09.02.15.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "HermesAppDelegate.h"
#import "DSPF_TransportGroupSummary.h"
#import "DSPF_TransportGroupSummaryCell.h"
#import "Location.h"
#import "Transport.h"

@implementation DSPF_TransportGroupSummary

@synthesize transportGroup;
@synthesize ctx;
@synthesize transportGroupSymmary;

#pragma mark - Initialization

- (NSManagedObjectContext *)ctx {
    if (!ctx) { 
		ctx = [[(HermesAppDelegate *)[[UIApplication sharedApplication] delegate] ctx] retain]; 
    }
    return ctx;
}

- (NSArray *)transportGroupSymmary {
    if (!transportGroupSymmary) {
		transportGroupSymmary = [[transportGroup transportSummaryWithSortDescriptors:[NSArray arrayWithObjects:
                                                [NSSortDescriptor sortDescriptorWithKey:@"temperatureZone" ascending:YES],
                                                [NSSortDescriptor sortDescriptorWithKey:@"totalQTY" ascending:NO], nil]]
                                 retain];
    }
    return transportGroupSymmary;
}


- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if ((self = [super initWithStyle:style])) {
        self.title = NSLocalizedString(@"TITLE__058", @"Informationen");
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
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
	return self.transportGroupSymmary.count;
}

- (NSDictionary *)listItem:(NSIndexPath *)indexPath {
    return [self.transportGroupSymmary objectAtIndex:indexPath.row];
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    id   cell  = (DSPF_TransportGroupSummaryCell *)[aTableView dequeueReusableCellWithIdentifier:@"DSPF_TransportGroupSummaryList"];
    if (!cell) {
        cell = [[[DSPF_TransportGroupSummaryCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"DSPF_TransportGroupSummaryList"] autorelease];
    }
    // Configure the cell...
    [cell setTransportGroup:self.transportGroup];
    // [DSPF_TransportGroupSummaryCell setTransportGroupSummary] sets up all subviews ...
    [cell setTransportGroupSummary:[self listItem:indexPath]];
    ((UITableViewCell *)cell).accessoryType  = UITableViewCellAccessoryNone;
    ((UITableViewCell *)cell).selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
}


#pragma mark - Memory management



- (void)dealloc {
	[ctx     release];
    [transportGroupSymmary    release];
    [transportGroup           release];
    [super dealloc];
}


@end

