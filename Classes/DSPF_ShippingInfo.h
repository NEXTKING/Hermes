//
//  DSPF_ShippingInfo.h
//  Hermes
//
//  Created by Lutz on 09.11.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DSPF_ShippingInfo : UITableViewController {

@private
	NSManagedObjectContext *ctx;
    NSArray				   *listGroups;    
}

@property (nonatomic, retain) NSManagedObjectContext *ctx;
@property (nonatomic, retain) NSArray			     *listGroups;

@end