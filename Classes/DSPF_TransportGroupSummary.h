//
//  DSPF_TransportGroupSummary.h
//  Hermes
//
//  Created by Lutz on 09.02.15.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Transport_Group.h"

@interface DSPF_TransportGroupSummary : UITableViewController {

    Transport_Group        *transportGroup;
@private
	NSManagedObjectContext *ctx;
    NSArray				   *transportGroupSymmary;    
}

@property (nonatomic, retain) Transport_Group        *transportGroup;

@property (nonatomic, retain) NSManagedObjectContext *ctx;
@property (nonatomic, retain) NSArray			     *transportGroupSymmary;

@end