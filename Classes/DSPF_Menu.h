//
//  DSPF_Menu.h
//  Hermes
//
//  Created by Lutz on 04.12.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DSPF_Confirm.h"
#import "Truck.h"
#import "Tour.h"

extern NSString * const MenuUserKey;

@interface DSPF_Menu : UITableViewController <DSPF_ConfirmDelegate, UIAlertViewDelegate, UIViewControllerJumpThrough> {
	Truck				   *currentTruck;
	BOOL				    menuForDriver;
    
@private
    NSMutableDictionary    *menuItems;
    NSMutableArray         *menuGroups;
	Tour				   *currentTour;    
}
@property (nonatomic, retain) Truck					 *currentTruck;
@property (nonatomic)		  BOOL					  menuForDriver;

@property (nonatomic, retain) NSMutableDictionary	 *menuItems;
@property (nonatomic, retain) NSMutableArray         *menuGroups;
@property (nonatomic, retain) Tour					 *currentTour;

- (instancetype) initWithParameters:(NSDictionary *) parameters;

@end