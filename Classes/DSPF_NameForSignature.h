//
//  DSPF_NameForSignature.h
//  Test
//
//  Created by Lutz  Thalmann on 10.05.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "DSPF_SignatureForName.h"
#import "DSPF_Confirm.h"

#import "Departure.h"
#import "Transport_Group.h"

@interface DSPF_NameForSignature : UITableViewController <NSFetchedResultsControllerDelegate, 
                                                          UITextFieldDelegate, 
                                                          DSPF_ConfirmDelegate> {
    	id  <DSPF_SignatureForNameDelegate> delegate;
        IBOutlet    UIView				   *inputView;
        IBOutlet    UITableView            *tableView;
        IBOutlet    UITextField	           *textInput;
                    Departure              *departure;
                    Transport_Group        *currentTransportGroup;
                    BOOL                    isPickup;
                    BOOL                    isReturnablePackaging;
}

@property (assign)	          id <DSPF_SignatureForNameDelegate>   delegate;
@property (nonatomic, retain) IBOutlet  UIView                    *inputView;
@property (nonatomic, retain) IBOutlet  UITableView				  *tableView;
@property (nonatomic, retain) IBOutlet  UITextField               *textInput;
@property (nonatomic, retain)           Departure                 *departure;
@property (nonatomic, retain)		    Transport_Group           *currentTransportGroup;
@property (nonatomic)                   BOOL                       isPickup;
@property (nonatomic)                   BOOL                       isReturnablePackaging;
@property (nonatomic, retain) NSManagedObjectContext              *ctx;
@property (nonatomic, retain) NSFetchedResultsController          *fetchedResultsController;

@end