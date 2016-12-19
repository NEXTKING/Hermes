//
//  DSPF_TransportInfo.m
//  Hermes
//
//  Created by Lutz on 28.02.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "HermesAppDelegate.h"
#import "DSPF_TransportInfo.h"
#import "Location.h"
#import "Transport.h"

@interface DSPF_TransportInfo()
@property (nonatomic, retain) NSManagedObjectContext *ctx;
@property (nonatomic, retain) NSArray			     *listGroups;
@end

@implementation DSPF_TransportInfo
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
												[[Transport withPredicate:[NSPredicate predicateWithFormat:@"trace_type_id.code = %@", @"LOAD"] inCtx:self.ctx]
												 valueForKeyPath:@"to_location_id"]] allObjects]]
				sortedArrayUsingDescriptors:sortDescriptors] retain]; 
    }
    return listGroups;
}


- (id)initWithStyle:(UITableViewStyle)style {
    if ((self = [super initWithStyle:style])) {
        self.title = NSLocalizedString(@"TITLE_062", @"Ladung");
    }
    return self;
}


#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.clearsSelectionOnViewWillAppear = NO;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.listGroups.count;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id value = [self.listGroups objectAtIndex:section];
    NSPredicate *predicate = [self predicateForItemsOfSectionObject:value];
	
    NSArray *sectionItems = [NSArray arrayWithArray:[Transport withPredicate:predicate inCtx:self.ctx]];
	if (!sectionItems) {
		return 0;
	}
	return [sectionItems count];
}

- (NSString *)tableView:(UITableView *)aTableView titleForHeaderInSection:(NSInteger)aSection {
    NSString *result = @" ";
    id location = [self.listGroups objectAtIndex:aSection];
    if (location != [NSNull null]) {
        result = [NSString stringWithFormat:@"%@: %@", [location valueForKey:@"city"], [location valueForKey:@"location_name"]];
    }
    return result;
}

- (NSPredicate *) predicateForItemsOfSectionObject:(id)sectionObject {
    NSPredicate *predicate = nil;
    if (sectionObject == [NSNull null]) {
        predicate = [NSPredicate predicateWithFormat:@"to_location_id.location_id = %@ && trace_type_id.code = %@", nil, TraceTypeStringLoad];
    } else if ([sectionObject isKindOfClass:Location.class]) {
        Location *location = sectionObject;
        predicate = [NSPredicate predicateWithFormat:@"to_location_id.location_id = %lld && trace_type_id.code = %@",
                     [location.location_id longLongValue], TraceTypeStringLoad];
    }
    return predicate;
}

- (Transport *)listItem:(NSIndexPath *)indexPath {
	NSArray	*sortDescriptors = [NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"transport_id" ascending:YES], nil];
    NSPredicate *predicate = [self predicateForItemsOfSectionObject:[self.listGroups objectAtIndex:indexPath.section]];
    
	NSArray *sectionItems = [NSArray arrayWithArray:[Transport transportsWithPredicate:predicate sortDescriptors:sortDescriptors inCtx:self.ctx]];
    return [sectionItems objectAtIndex:indexPath.row];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"DSPF_TransportInfo";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
    Transport *tmpTransport = [self listItem:indexPath];
    if (PFBrandingSupported(BrandingViollier, nil)) {
        if ([tmpTransport.code hasAnyPrefix:@[@"V001:", @"V007:"]]) {
            cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-CondensedBold" size:15];
            cell.textLabel.lineBreakMode = UILineBreakModeCharacterWrap;
            cell.textLabel.numberOfLines = 0;
        } else {
            cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-CondensedBold" size:17];
            cell.textLabel.lineBreakMode = UILineBreakModeMiddleTruncation;
            cell.textLabel.numberOfLines = 1;
        }
    }
    if (tmpTransport.occurrences && [tmpTransport.occurrences intValue] > 1) {
        cell.textLabel.text = [NSString stringWithFormat:@"%2i x %@", [tmpTransport.occurrences intValue], tmpTransport.code];
    } else if (PFBrandingSupported(BrandingCCC_Group, nil)) {
        NSString *code = tmpTransport.deliveryDocumentNumber;
        if (!code || code.length == 0) {
            code = tmpTransport.pickUpDocumentNumber;
        }
        if (!code || code.length == 0) {
            code = tmpTransport.code;
        }
        cell.textLabel.text = code;
    } else {
        cell.textLabel.text = tmpTransport.code;
    }
    cell.accessoryType  = UITableViewCellAccessoryNone;
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
}

#pragma mark Memory management


- (void)dealloc {
	[ctx release];
    [listGroups			  release];
    [super dealloc];
}


@end

