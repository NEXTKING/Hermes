//
//  DSPF_SignatureForName.h
//  Hermes
//
//  Created by Lutz  Thalmann on 10.05.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DSPF_Confirm.h"

#import "Departure.h"
#import "Transport_Group.h"

@protocol DSPF_SignatureForNameDelegate;

@interface DSPF_SignatureForName : UIViewController <UITableViewDelegate, UITableViewDataSource, DSPF_ConfirmDelegate> {
	id			 <DSPF_SignatureForNameDelegate>   delegate;
                NSString	              *nameForSignature;
    IBOutlet    UIImageView               *signatureImage;
    IBOutlet    UIImageView               *signatureLogo;
    IBOutlet    UITableView               *tableView;
    IBOutlet    UIView                    *signatureLock;
    IBOutlet    UILabel                   *infoText;
    IBOutlet    UIToolbar                 *toolbar;
                Departure                 *departure;
                Transport_Group           *currentTransportGroup;
                BOOL                       isPickup;
                BOOL                       isReturnablePackaging;
                UIImage                    *confirmedSignature;

@private
	CGPoint                  lastPoint;
	BOOL                     isDrawing;
    NSManagedObjectContext  *ctx;
    NSArray                 *transportCodes;
    UIImage                 *tableViewImage;
}

@property (assign)	          id <DSPF_SignatureForNameDelegate>   delegate;
@property (nonatomic, retain)           NSString                *nameForSignature;
@property (nonatomic, retain) IBOutlet  UIImageView             *signatureImage;
@property (nonatomic, retain) IBOutlet  UIImageView             *signatureLogo;
@property (nonatomic, retain) IBOutlet  UITableView             *tableView;
@property (nonatomic, retain) IBOutlet  UIView                  *signatureLock;
@property (nonatomic, retain) IBOutlet  UILabel                 *infoText;
@property (nonatomic, retain) IBOutlet  UIToolbar               *toolbar;
@property (nonatomic, retain)           Departure               *departure;
@property (nonatomic, retain)		    Transport_Group         *currentTransportGroup;
@property (nonatomic)                   BOOL                     isPickup;
@property (nonatomic)                   BOOL                     isReturnablePackaging;

@property (nonatomic)                   CGPoint                  lastPoint;
@property (nonatomic)                   BOOL                     isDrawing;
@property (nonatomic, retain)           NSManagedObjectContext  *ctx;
@property (nonatomic, retain)           NSArray					*transportCodes;
@property (nonatomic, retain)           UIImage					*tableViewImage;
@property (nonatomic, retain)           UIImage					*confirmedSignature;


- (IBAction)confirm;
- (IBAction)clear;

@end

@protocol DSPF_SignatureForNameDelegate
- (void)  dspf_SignatureForName:(DSPF_SignatureForName *)sender didReturnSignature:(UIImage *)aSignature forName:(NSString *)aName;
@end