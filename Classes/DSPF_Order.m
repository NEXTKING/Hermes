//
//  DSPF_Order.m
//  Hermes
//
//  Created by Lutz on 07.12.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "HermesAppDelegate.h"
#import "DSPF_Order.h"
#import "DSPF_OrderTableViewCell.h"
#import "DSPF_OrderTableViewCell_biopartner.h"
#import "DSPF_OrderItem.h"
#import "DSPF_ItemDetail.h"
#import "DSPF_Activity.h"
#import "DSPF_Error.h"
#import "DSPF_Suspend.h"
#import "DSPF_Load.h"
#import "DSPF_Unload.h"
#import "DSPF_Customer.h"

#import "ArchiveOrderHead.h"
#import "ArchiveOrderLine.h"
#import "TemplateOrderHead.h"
#import "TemplateOrderLine.h"
#import "Item.h"
#import "User.h"
#import "LocalizedDescription.h"
#import "Location.h"
#import "Store.h"

#import "DTDevices.h"

@implementation DSPF_Order

@synthesize subTitle;
@synthesize tableView;
@synthesize dataTask;
@synthesize dataHeaderInfo;
@synthesize runsAsTakingBack;

@synthesize toolbarHiddenBackup;
@synthesize wasSkippedOnce;
@synthesize wasPrintedOnce;
@synthesize numberBadgeView;
@synthesize analysisPicker;
@synthesize datePicker;
@synthesize datePickerView;
@synthesize shoppingCartPicker;
@synthesize shoppingCartPickerView;
@synthesize shoppingCartPickerRow;
@synthesize modifyTemplateLine;
@synthesize moveTemplateLine;
@synthesize hasTrademarkHolders;
@synthesize hasProductGroups;
@synthesize lastChangedLine;
@synthesize ctx;
@synthesize	orderLinesAtWork;
@synthesize filteredListContent;
@synthesize searchResultsCover;

#pragma mark - Initialization

- (id) init {     
    self = [super init];
    if (self != nil) { 
        self.ctx = [[[NSManagedObjectContext alloc] init] autorelease];
        [self.ctx setPersistentStoreCoordinator:
         [(HermesAppDelegate *)[[UIApplication sharedApplication] delegate] persistentStoreCoordinator]];
        [self.ctx setUndoManager:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mergeContext:) 
                                                     name:NSManagedObjectContextDidSaveNotification object:nil];
    }
    return self;
}

- (void)mergeContext:(NSNotification *)aNotification { 
    if (aNotification.object != self.ctx) {        
        [self.ctx mergeChangesFromContextDidSaveNotification:aNotification]; 
    } 
}

- (NSFetchedResultsController *)orderLinesAtWork {
    if (!orderLinesAtWork) {
        NSError *error = nil;
        NSString *sectionNameKeyPath           = nil;
        NSFetchRequest *selectOrderLinesAtWork = [[[NSFetchRequest alloc] init] autorelease];
        if (self.subTitle) {
            [selectOrderLinesAtWork setEntity:[NSEntityDescription entityForName:@"ArchiveOrderLine" inManagedObjectContext:self.ctx]];
            [selectOrderLinesAtWork setPredicate:[NSPredicate predicateWithFormat:@"archiveOrderHead.orderState = 00"]];
            sectionNameKeyPath = nil;
        } else if (!self.dataHeaderInfo) {
            [selectOrderLinesAtWork setEntity:[NSEntityDescription entityForName:@"ArchiveOrderLine" inManagedObjectContext:self.ctx]];
            [selectOrderLinesAtWork setPredicate:[NSPredicate predicateWithFormat:@"archiveOrderHead.orderState = 00"]];
            sectionNameKeyPath = @"templateName";
        } else if ([self.dataHeaderInfo isKindOfClass:[ArchiveOrderHead class]]) { 
            [selectOrderLinesAtWork setEntity:[NSEntityDescription entityForName:@"ArchiveOrderLine" inManagedObjectContext:self.ctx]];
            [selectOrderLinesAtWork setPredicate:[NSPredicate predicateWithFormat:@"archiveOrderHead.order_id = %ld",
                                                                                    [[self.dataHeaderInfo order_id] longValue]]];
            sectionNameKeyPath = @"templateName";
        } else if ([self.dataHeaderInfo isKindOfClass:[TemplateOrderHead class]]) { 
            [selectOrderLinesAtWork setEntity:[NSEntityDescription entityForName:@"TemplateOrderLine" inManagedObjectContext:self.ctx]];
            [selectOrderLinesAtWork setPredicate:[NSPredicate predicateWithFormat:@"templateOrderHead.template_id = %ld && item != nil",
                                                                                    [[self.dataHeaderInfo template_id] longValue]]];
            if (self.hasProductGroups) { 
                sectionNameKeyPath = @"item.productGroup";            
            }
        }
        [selectOrderLinesAtWork setFetchBatchSize:12];
        if (sectionNameKeyPath) { 
            if ([self.dataHeaderInfo isKindOfClass:[TemplateOrderHead class]]) { 
                [selectOrderLinesAtWork setSortDescriptors:[NSArray arrayWithObjects:
                                                            [NSSortDescriptor sortDescriptorWithKey:sectionNameKeyPath     ascending:YES],
                                                            [NSSortDescriptor sortDescriptorWithKey:@"item.productGroup"   ascending:YES],
                                                            [NSSortDescriptor sortDescriptorWithKey:@"sortValue"           ascending:YES],
                                                            [NSSortDescriptor sortDescriptorWithKey:@"itemInserted"        ascending:NO], 
                                                            nil]];                
            } else { 
                [selectOrderLinesAtWork setSortDescriptors:[NSArray arrayWithObjects: 
                                                            [NSSortDescriptor sortDescriptorWithKey:sectionNameKeyPath         ascending:YES],
                                                            [NSSortDescriptor sortDescriptorWithKey:@"item.storeAssortmentBit" ascending:YES], 
                                                            [NSSortDescriptor sortDescriptorWithKey:@"item.productGroup"       ascending:YES],
                                                            [NSSortDescriptor sortDescriptorWithKey:@"itemInserted"            ascending:NO], 
                                                            nil]];
            } 
        } else {
            if (self.subTitle) {
                [selectOrderLinesAtWork setSortDescriptors:[NSArray arrayWithObjects:
                                                            [NSSortDescriptor sortDescriptorWithKey:@"itemInserted"            ascending:NO],
                                                            nil]];
            } else if ([self.dataHeaderInfo isKindOfClass:[TemplateOrderHead class]]) {
                [selectOrderLinesAtWork setSortDescriptors:[NSArray arrayWithObjects:
                                                            [NSSortDescriptor sortDescriptorWithKey:@"item.productGroup"   ascending:YES],
                                                            [NSSortDescriptor sortDescriptorWithKey:@"sortValue"           ascending:YES],
                                                            [NSSortDescriptor sortDescriptorWithKey:@"itemInserted"        ascending:NO], 
                                                            nil]];                
            } else { 
                [selectOrderLinesAtWork setSortDescriptors:[NSArray arrayWithObjects: 
                                                            [NSSortDescriptor sortDescriptorWithKey:@"item.storeAssortmentBit" ascending:YES], 
                                                            [NSSortDescriptor sortDescriptorWithKey:@"item.productGroup"       ascending:YES],
                                                            [NSSortDescriptor sortDescriptorWithKey:@"itemInserted"            ascending:NO], 
                                                            nil]];
            }
        }   
        orderLinesAtWork = [[NSFetchedResultsController alloc] initWithFetchRequest:selectOrderLinesAtWork 
                                                               managedObjectContext:self.ctx
                                                                 sectionNameKeyPath:sectionNameKeyPath 
                                                                          cacheName:nil];
        orderLinesAtWork.delegate = self; 
        if (![orderLinesAtWork performFetch:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
    return orderLinesAtWork;
}

- (NSFetchedResultsController *)filteredListContent {
    if (!filteredListContent) { 
        NSError *error = nil;
        NSString *sectionNameKeyPath    = nil;
        NSFetchRequest *filteredContent = [[[NSFetchRequest alloc] init] autorelease];
        if (self.subTitle) {
            [filteredContent setEntity:[NSEntityDescription entityForName:@"ArchiveOrderLine" inManagedObjectContext:self.ctx]];
            [filteredContent setPredicate:[NSPredicate predicateWithFormat:@"YES = NO && archiveOrderHead.orderState = 00"]];
            sectionNameKeyPath = nil;
        } else if (!self.dataHeaderInfo) {
            [filteredContent setEntity:[NSEntityDescription entityForName:@"ArchiveOrderLine" inManagedObjectContext:self.ctx]];
            [filteredContent setPredicate:[NSPredicate predicateWithFormat:@"YES = NO && archiveOrderHead.orderState = 00"]];
            sectionNameKeyPath = @"templateName";
        } else if ([self.dataHeaderInfo isKindOfClass:[ArchiveOrderHead class]]) { 
            [filteredContent setEntity:[NSEntityDescription entityForName:@"ArchiveOrderLine" inManagedObjectContext:self.ctx]];
            [filteredContent setPredicate:[NSPredicate predicateWithFormat:@"YES = NO && archiveOrderHead.order_id = %ld", 
                                                                             [[self.dataHeaderInfo order_id] longValue]]];
            sectionNameKeyPath = @"templateName";
        } else if ([self.dataHeaderInfo isKindOfClass:[TemplateOrderHead class]]) { 
            [filteredContent setEntity:[NSEntityDescription entityForName:@"TemplateOrderLine" inManagedObjectContext:self.ctx]];
            [filteredContent setPredicate:[NSPredicate predicateWithFormat:@"YES = NO && templateOrderHead.template_id = %ld && item != nil",
                                                                             [[self.dataHeaderInfo template_id] longValue]]];
            sectionNameKeyPath = @"item.productGroup";
        }
        [filteredContent setFetchBatchSize:12];
        if (sectionNameKeyPath) { 
            if ([self.dataHeaderInfo isKindOfClass:[TemplateOrderHead class]]) { 
                [filteredContent setSortDescriptors:[NSArray arrayWithObjects:
                                                     [NSSortDescriptor sortDescriptorWithKey:sectionNameKeyPath         ascending:YES],
                                                     [NSSortDescriptor sortDescriptorWithKey:@"item.productGroup"       ascending:YES],
                                                     [NSSortDescriptor sortDescriptorWithKey:@"sortValue"               ascending:YES],
                                                     [NSSortDescriptor sortDescriptorWithKey:@"itemInserted"            ascending:NO],
                                                     nil]];                
            } else { 
                [filteredContent setSortDescriptors:[NSArray arrayWithObjects: 
                                                     [NSSortDescriptor sortDescriptorWithKey:sectionNameKeyPath         ascending:YES],
                                                     [NSSortDescriptor sortDescriptorWithKey:@"item.storeAssortmentBit" ascending:YES], 
                                                     [NSSortDescriptor sortDescriptorWithKey:@"item.productGroup"       ascending:YES],
                                                     [NSSortDescriptor sortDescriptorWithKey:@"itemInserted"            ascending:NO], 
                                                     nil]];
            } 
        } else {
            if (self.subTitle) {
                [filteredContent setSortDescriptors:[NSArray arrayWithObjects:
                                                     [NSSortDescriptor sortDescriptorWithKey:@"itemInserted"            ascending:NO],
                                                     nil]];
            } else if ([self.dataHeaderInfo isKindOfClass:[TemplateOrderHead class]]) {
                [filteredContent setSortDescriptors:[NSArray arrayWithObjects:
                                                     [NSSortDescriptor sortDescriptorWithKey:@"item.productGroup"       ascending:YES],
                                                     [NSSortDescriptor sortDescriptorWithKey:@"sortValue"               ascending:YES],
                                                     [NSSortDescriptor sortDescriptorWithKey:@"itemInserted"            ascending:NO],
                                                     nil]];                
            } else { 
                [filteredContent setSortDescriptors:[NSArray arrayWithObjects: 
                                                     [NSSortDescriptor sortDescriptorWithKey:@"item.storeAssortmentBit" ascending:YES], 
                                                     [NSSortDescriptor sortDescriptorWithKey:@"item.productGroup"       ascending:YES],
                                                     [NSSortDescriptor sortDescriptorWithKey:@"itemInserted"            ascending:NO], 
                                                     nil]];
            }
        }
        filteredListContent = [[NSFetchedResultsController alloc] initWithFetchRequest:filteredContent 
                                                                  managedObjectContext:self.ctx
                                                                    sectionNameKeyPath:sectionNameKeyPath 
                                                                             cacheName:nil];
        filteredListContent.delegate = self; 
        if (![filteredListContent performFetch:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
    return filteredListContent;
}

- (MKNumberBadgeView *)numberBadgeView { 
    if (!numberBadgeView) { 
        numberBadgeView = [[MKNumberBadgeView alloc] initWithFrame:CGRectMake(self.navigationController.toolbar.bounds.origin.x + 38, 
                                                                              self.navigationController.toolbar.bounds.origin.y -  8, 
                                                                              32, 28)];
        if ([self.dataHeaderInfo isKindOfClass:[TemplateOrderHead class]]) { 
            numberBadgeView.fillColor = [UIColor appStyleOrderTemplateBadgeColor];
            numberBadgeView.textColor = [UIColor appStyleOrderTemplateBadgeTextColor];
        } else {
            numberBadgeView.fillColor = [UIColor appStyleOrderBadgeColor];
            numberBadgeView.textColor = [UIColor appStyleOrderBadgeTextColor];
        }
    }
    return numberBadgeView;
}

- (UIActionSheet *)analysisPicker { 
    if (!analysisPicker) { 
        analysisPicker = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"TITLE__070", @"Verkaufsförderung")
                                                     delegate:self
                                            cancelButtonTitle:NSLocalizedString(@"TITLE__018", @"Abbrechen")
                                       destructiveButtonTitle:nil
                                            otherButtonTitles:NSLocalizedString(@"TITLE__066", @"Hitliste"),
                                                              NSLocalizedString(@"TITLE__067", @"Trendsetter"),
                                                              NSLocalizedString(@"TITLE__069", @"Warenkorbanalyse"), nil];
        analysisPicker.actionSheetStyle = UIActionSheetStyleAutomatic;
    }
    return analysisPicker;
}

- (UIDatePicker *)datePicker { 
    if (!datePicker) { 
        datePicker = [[UIDatePicker alloc] initWithFrame: CGRectMake(0, 
                                                                     0 + 269 - 216, 
                                                                     datePickerView.frame.size.width, 
                                                                     216)];
        // show dates without time
        datePicker.datePickerMode = UIDatePickerModeDate;        
    }
    return datePicker;
}

- (UIView *)datePickerView { 
    // DatePicker.height     = 216
    // Toolbar.height        =  53
    // datePickerView.height = 269
    if (!datePickerView) { 
        datePickerView = [[UIView alloc] initWithFrame:
                          CGRectMake(0, 
                                     0 + self.view.bounds.size.height - self.navigationController.toolbar.bounds.size.height - 269, 
                                     self.view.bounds.size.width, 
                                     269)]; 
        [datePickerView  addSubview:self.datePicker]; 
        UIButton *doneButton = [[[UIButton alloc] initWithFrame:CGRectMake(0, 0, 275, 41)] autorelease];
        doneButton.titleLabel.font   = [UIFont fontWithName:@"Helvetica-Bold" size:18];
        [doneButton setBackgroundImage:[UIImage imageNamed:@"b_128x128_r_n.png"] forState:UIControlStateNormal];
        [doneButton setBackgroundImage:[UIImage imageNamed:@"b_128x128_r_h.png"] forState:UIControlStateSelected];
        [doneButton setTitle:NSLocalizedString(@"TITLE__078", @"Liefertermin festlegen") forState:UIControlStateNormal];
        [doneButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [doneButton addTarget:self action:@selector(dateSelected)  forControlEvents:UIControlEventTouchUpInside];
        
        UIToolbar *datePickerToolbar = [[[UIToolbar alloc] initWithFrame: CGRectMake(0, 
                                                                                     0, 
                                                                                     datePickerView.frame.size.width, 
                                                                                     53)] autorelease];
        datePickerToolbar.barStyle   = self.navigationController.toolbar.barStyle;
        datePickerToolbar.tintColor  = self.navigationController.toolbar.tintColor;
        datePickerToolbar.alpha      = self.navigationController.toolbar.alpha;
        datePickerToolbar.items      = [NSArray arrayWithObjects:
                                        [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                      target:nil 
                                                                                      action:nil] autorelease],
                                        [[[UIBarButtonItem alloc] initWithCustomView:doneButton]  autorelease],
                                        [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                       target:nil 
                                                                                       action:nil] autorelease],
                                        nil];
        [datePickerView addSubview:datePickerToolbar];
    }
    return datePickerView;
}

- (UIPickerView *)shoppingCartPicker { 
    if (!shoppingCartPicker) { 
        shoppingCartPicker = [[UIPickerView alloc] initWithFrame: CGRectMake(0, 
                                                                             0 + 269 - 216, 
                                                                             shoppingCartPickerView.frame.size.width, 
                                                                             216)];
        shoppingCartPicker.showsSelectionIndicator = YES;
        shoppingCartPicker.delegate                = self;
    }
    return shoppingCartPicker;
}

- (UIView *)shoppingCartPickerView { 
    // DatePicker.height     = 216
    // Toolbar.height        =  53
    // datePickerView.height = 269
    if (!shoppingCartPickerView) { 
        shoppingCartPickerView = [[UIView alloc] initWithFrame:
                                  CGRectMake(0, 
                                             0 + self.view.bounds.size.height - self.navigationController.toolbar.bounds.size.height - 269, 
                                             self.view.bounds.size.width, 
                                             269)];
        [shoppingCartPickerView  addSubview:self.shoppingCartPicker]; 
        UIButton *doneButton = [[[UIButton alloc] initWithFrame:CGRectMake(0, 0, 275, 41)] autorelease];
        doneButton.titleLabel.font   = [UIFont fontWithName:@"Helvetica-Bold" size:18];
        [doneButton setBackgroundImage:[UIImage imageNamed:@"b_128x128_gr_n.png"] forState:UIControlStateNormal];
        [doneButton setBackgroundImage:[UIImage imageNamed:@"b_128x128_gr_h.png"] forState:UIControlStateSelected]; 
        [doneButton setTitle:@"Warenkorb festlegen" forState:UIControlStateNormal];
        [doneButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [doneButton addTarget:self action:@selector(sendOrder) forControlEvents:UIControlEventTouchUpInside];
        
        UIToolbar *shoppingCartPickerToolbar = [[[UIToolbar alloc] initWithFrame: CGRectMake(0, 
                                                                                             0, 
                                                                                             shoppingCartPickerView.frame.size.width, 
                                                                                             53)] autorelease];
        shoppingCartPickerToolbar.barStyle   = self.navigationController.toolbar.barStyle;
        shoppingCartPickerToolbar.tintColor  = self.navigationController.toolbar.tintColor;
        shoppingCartPickerToolbar.alpha      = self.navigationController.toolbar.alpha;
        shoppingCartPickerToolbar.items      = [NSArray arrayWithObjects:
                                                [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                               target:nil 
                                                                                               action:nil] autorelease],
                                                [[[UIBarButtonItem alloc] initWithCustomView:doneButton]  autorelease],
                                                [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                               target:nil 
                                                                                               action:nil] autorelease],
                                                nil];
        [shoppingCartPickerView addSubview:shoppingCartPickerToolbar];
    }
    return shoppingCartPickerView;
}

- (BOOL)hasTrademarkHolders { 
    NSError        *error      = nil;
    NSFetchRequest *query      = [[NSFetchRequest alloc] init];
    query.entity               = [NSEntityDescription entityForName:@"LocalizedDescription" inManagedObjectContext:self.ctx];
    query.predicate            = [NSPredicate predicateWithFormat:@"key = %@", @"ItemTrademarkHolder"];
    [query setIncludesSubentities: NO];
    NSUInteger count = [self.ctx countForFetchRequest:query error:&error];
    [query release];
    if(count != NSNotFound && count > 0) {
        return YES;
    }
    return NO;
}

- (BOOL)hasProductGroups {
    if (!self.subTitle) {
        NSError        *error      = nil;
        NSFetchRequest *query      = [[NSFetchRequest alloc] init];
        query.entity               = [NSEntityDescription entityForName:@"LocalizedDescription" inManagedObjectContext:self.ctx];
        query.predicate            = [NSPredicate predicateWithFormat:@"key = %@", @"ItemProductGroup"];
        [query setIncludesSubentities: NO];
        NSUInteger count = [self.ctx countForFetchRequest:query error:&error];
        [query release];
        if(count != NSNotFound && count > 0) {
            return YES;
        }
    }
    return NO;
}

- (UIView *)searchResultsCover { 
    if (!searchResultsCover) { 
        searchResultsCover = [UIView new];
        searchResultsCover.backgroundColor = [UIColor blackColor];
        searchResultsCover.alpha = 0.8;
    }
    return searchResultsCover;
}

#pragma mark - View lifecycle

- (void)switchAccessoryType { 
    if (!self.modifyTemplateLine) {
        self.modifyTemplateLine     = YES;
        self.tableView.editing      = NO;
    } else {
        if (!self.moveTemplateLine) { 
            self.moveTemplateLine   = YES;
            self.tableView.editing  = YES;
        } else {
            self.modifyTemplateLine = NO;
            self.moveTemplateLine   = NO;
            self.tableView.editing  = NO;
        }
    }
	[self.tableView reloadData];
}

- (void)printOrder {
    DSPF_Activity  *showActivity   = [[DSPF_Activity messageTitle:NSLocalizedString(@"Belegdruck", @"Belegdruck")
                                                      messageText:NSLocalizedString(@"MESSAGE__004", @"Bitte warten.") delegate:self] retain];
    [DPHUtilities waitForAlertToShow:0.236f];
    ArchiveOrderHead  *tmpOrderHead = [ArchiveOrderHead currentOrderHeadInCtx:self.ctx];
    NSManagedObjectID *tmpOrderHeadID = [tmpOrderHead objectID];
    NSMutableArray *tmpItemIDs = [NSMutableArray array];
    for (ArchiveOrderLine *tmpOrderLine in [NSArray arrayWithArray:[self.orderLinesAtWork fetchedObjects]]) {
        [tmpItemIDs addObject:[tmpOrderLine objectID]];
    }
    id parameter = ^(DTDevices *prn) {
        NSManagedObjectContext *tmpContext = [[(HermesAppDelegate *)[[UIApplication sharedApplication] delegate] ctx] retain];
        NSError  *error;
        /* Header */
        ArchiveOrderHead *prnOrderHead = (ArchiveOrderHead *)[tmpContext existingObjectWithID:tmpOrderHeadID error:nil];
        if ([prnOrderHead.store_id intValue] < 0) {
            Location *prnLocation = [Location withID:[NSNumber numberWithInt:(0 - [prnOrderHead.store_id intValue])]
                                  inCtx:tmpContext];
            [prn prnFeedPaper:5 error:&error];
            [prn prnPrintText:[NSString stringWithFormat:@"{=F1}{=L}Kunden-Nr.: %@", prnLocation.code] error:&error];
            [prn prnFeedPaper:1 error:&error];
            [prn prnPrintText:[NSString stringWithFormat:@"{=F1}{=L}%@", prnLocation.location_name] error:&error];
            [prn prnFeedPaper:1 error:&error];
            [prn prnPrintText:[NSString stringWithFormat:@"{=F1}{=L}%@", prnLocation.street] error:&error];
            [prn prnFeedPaper:1 error:&error];
            [prn prnPrintText:[NSString stringWithFormat:@"{=F1}{=L}%@ %@", prnLocation.zip, prnLocation.city] error:&error];
        } else {
            NSString *prnStoreID;
            /* First check for a payable account (Kreditor) */
            Store *prnStore = [Store storeID:[NSNumber numberWithInt:0 - [prnOrderHead.store_id intValue]] inCtx:tmpContext];
            if (!prnStore) {
                /* Alternatively check for a receivable account (Debitor)*/
                prnStore = [Store storeID:prnOrderHead.store_id inCtx:tmpContext];
                prnStoreID = [NSString stringWithFormat:@"R:%06i", [prnOrderHead.store_id intValue]];
            } else {
                prnStoreID = [NSString stringWithFormat:@"P:%06i", [prnOrderHead.store_id intValue]];
            }
            [prn prnFeedPaper:5 error:&error];
            [prn prnPrintText:[NSString stringWithFormat:@"{=F1}{=L}Kunden-Nr.: %@", prnStoreID] error:&error];
            [prn prnFeedPaper:1 error:&error];
            [prn prnPrintText:[NSString stringWithFormat:@"{=F1}{=L}%@", prnStore.storeName] error:&error];
            [prn prnFeedPaper:1 error:&error];
            [prn prnPrintText:[NSString stringWithFormat:@"{=F1}{=L}%@", prnStore.street] error:&error];
            [prn prnFeedPaper:1 error:&error];
            [prn prnPrintText:[NSString stringWithFormat:@"{=F1}{=L}%@", prnStore.city] error:&error];
        }
        //
        [prn prnFeedPaper:20 error:&error];
        [prn prnPrintText:@"{=F1}{=L}{+B}{+U}Gebinde-Nr.{=R}Anzahl{-U}{-B}" error:&error];
        for (NSManagedObjectID *tmpItemID in tmpItemIDs) {
            ArchiveOrderLine *tmpItem = (ArchiveOrderLine *)[tmpContext existingObjectWithID:tmpItemID error:nil];
            if (tmpItem) {
                /* Lines */
                [prn prnFeedPaper:1 error:&error];
                [prn prnPrintText:[NSString stringWithFormat:@"{=F1}{=L}%@ {=R}%i", tmpItem.itemID, [tmpItem.itemQTY intValue]] error:&error];
                [prn prnFeedPaper:1 error:&error];
                [prn prnPrintText:[NSString stringWithFormat:@"{=F1}{=L}%@",
                                   [NSString stringWithFormat:@"%@", [Item localDescriptionTextForItem:tmpItem.item]]] error:&error];
            }
        }
        [tmpContext release];
        /* Footer */
        [prn prnFeedPaper:20 error:&error];
        [prn prnPrintText:[NSString stringWithFormat:@"{=F0}{=R}%@ %@",
                           prnOrderHead.user.firstName,
                           prnOrderHead.user.lastName]
                    error:&error];
        [prn prnFeedPaper:3 error:&error];
        // --
        // [prn loadLogo:[UIImage imageNamed:@"biopartner_print_logo.png"] align:ALIGN_CENTER error:&error];
        // [prn printLogo:LOGO_DWDH error:&error];
        [prn prnPrintImage:[UIImage imageNamed:@"biopartner_print_logo.png"] align:ALIGN_RIGHT error:&error];
        // --
        [prn prnFeedPaper:3 error:&error];
        [prn prnPrintText:[NSString stringWithFormat:@"{=F0}{+B}{=L}%@ %@ {=R}Bio Partner Schweiz AG{-B}",
                           [NSDateFormatter localizedStringFromDate:[NSDate date]
                                                          dateStyle:NSDateFormatterMediumStyle
                                                          timeStyle:NSDateFormatterNoStyle],
                           [NSDateFormatter localizedStringFromDate:[NSDate date]
                                                          dateStyle:NSDateFormatterNoStyle
                                                          timeStyle:NSDateFormatterShortStyle]]
                    error:&error];
        [prn prnFeedPaper:10 error:&error];
        /* Tear-off */
        [prn prnFeedPaper:0 error:&error];
        [prn prnFlushCache:&error];
        [prn prnWaitPrintJob:50 error:&error];
    };
    [[NSNotificationCenter defaultCenter] postNotificationName:@"print" object:self userInfo:parameter];
    self.wasPrintedOnce = YES; /* YES explicitly does not meen "without errors" */
    [showActivity closeActivityInfo];
    [showActivity release];
}

- (void)sendOrder {
    if (!self.datePickerView.window &&
        [[[NSUserDefaults standardUserDefaults] valueForKey:@"HermesApp_SYSVAL_RUN_withOrderDateInput_MODE"] isEqualToString:@"PICKERVIEW"]) {
        [self.navigationController setToolbarHidden:YES];
        if (self.shoppingCartPickerView.window) {
            [self.shoppingCartPickerView removeFromSuperview];
            [self.tableView setFrame:CGRectMake(self.tableView.frame.origin.x,
                                                self.tableView.frame.origin.y,
                                                self.tableView.frame.size.width,
                                                self.tableView.frame.size.height + self.shoppingCartPickerView.frame.size.height)];
        }
        TemplateOrderHead *selectedTemplateAtWork;
        if (self.orderLinesAtWork.sections.count == 1) {
            selectedTemplateAtWork = [TemplateOrderHead
                                      templateHeadFromName:
                                      ((ArchiveOrderLine *)[[self.orderLinesAtWork fetchedObjects]
                                                            lastObject]).templateName
                                      inCtx:self.ctx];
        } else {
            selectedTemplateAtWork = [TemplateOrderHead
                                      templateHeadFromName:
                                      ((ArchiveOrderLine *)[[[[self.orderLinesAtWork sections] objectAtIndex:self.shoppingCartPickerRow] objects]
                                                            lastObject]).templateName
                                      inCtx:self.ctx];
        }
        if (selectedTemplateAtWork                      &&
            selectedTemplateAtWork.templateDeliveryFrom &&
            selectedTemplateAtWork.templateDeliveryUntil ) {
            if ([selectedTemplateAtWork.templateDeliveryUntil compare:[NSDate date]] == NSOrderedAscending) {
                [self.datePicker setDate:
                 [selectedTemplateAtWork.templateDeliveryFrom laterDate:[NSDate date]]];
                self.datePicker.enabled = NO;
            } else {
                [self.datePicker setDate:
                 [selectedTemplateAtWork.templateDeliveryFrom laterDate:[NSDate date]]];
                [self.datePicker setMinimumDate:
                 [selectedTemplateAtWork.templateDeliveryFrom laterDate:[NSDate date]]];
                [self.datePicker setMaximumDate:selectedTemplateAtWork.templateDeliveryUntil];
            }
        } else {
            // 86400   = (24*60*60)    seconds per day
            // show tomorrow
            [self.datePicker setDate:[[NSDate date] dateByAddingTimeInterval:86400]];
            // min  today
            [self.datePicker setMinimumDate:[NSDate date]];
            // 2592000 = (24*60*60*30) seconds per month
            // max next month
            [self.datePicker setMaximumDate:[[NSDate date] dateByAddingTimeInterval:2592000]];
        }
        [self.view addSubview:self.datePickerView];
        [self.tableView setFrame:CGRectMake(self.tableView.frame.origin.x,
                                            self.tableView.frame.origin.y,
                                            self.tableView.frame.size.width,
                                            self.tableView.frame.size.height - self.datePickerView.frame.size.height)];
        if (self.orderLinesAtWork.sections.count > 1) {
            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:self.shoppingCartPickerRow]
                                  atScrollPosition:UITableViewScrollPositionTop animated:YES];
        }
    } else {
        if (self.shoppingCartPickerView.window) {
            [self.shoppingCartPickerView removeFromSuperview];
            [self.tableView setFrame:CGRectMake(self.tableView.frame.origin.x,
                                                self.tableView.frame.origin.y,
                                                self.tableView.frame.size.width,
                                                self.tableView.frame.size.height + self.shoppingCartPickerView.frame.size.height)];
        }
        if (self.datePickerView.window) {
            [self.datePickerView removeFromSuperview];
            [self.tableView setFrame:CGRectMake(self.tableView.frame.origin.x,
                                                self.tableView.frame.origin.y,
                                                self.tableView.frame.size.width,
                                                self.tableView.frame.size.height + self.datePickerView.frame.size.height)];
        }
        ArchiveOrderHead *tmpArchiveOrderHead;
        if (self.orderLinesAtWork.sections.count == 1) {
            tmpArchiveOrderHead = [ArchiveOrderHead currentOrderHeadInCtx:self.ctx];
        } else {
            NSArray *selectedOrderLinesAtWork = [NSArray arrayWithArray:[[[self.orderLinesAtWork sections] objectAtIndex:self.shoppingCartPickerRow] objects]];
            tmpArchiveOrderHead = [ArchiveOrderHead subsetOrderHeadForOrderHead:
                                   [ArchiveOrderHead currentOrderHeadInCtx:self.ctx]
                                                                 withOrderLines:selectedOrderLinesAtWork];
        }
        tmpArchiveOrderHead.orderState = [NSNumber numberWithInt:40];
        if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"HermesApp_SYSVAL_RUN_withOrderDateInput_MODE"] isEqualToString:@"PICKERVIEW"]) {
            tmpArchiveOrderHead.deliveryDate = self.datePicker.date;
        } else {
            // 86400 = (24*60*60) seconds per day
            tmpArchiveOrderHead.deliveryDate = [[NSDate date] dateByAddingTimeInterval:86400];
        }
        [self.ctx refreshObject:tmpArchiveOrderHead mergeChanges:YES];
        [self.ctx saveIfHasChanges];
        if (!PFCurrentModeIsDemo()) {
            [SVR_SyncDataManager triggerSendingRentalAndRestitutionDataWithUserInfo:nil];
        }
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)dateSelected { 
    [self sendOrder];
}

- (void)selectShoppingCart { 
    if (self.orderLinesAtWork.sections.count == 1) {
        [self sendOrder];
    } else { 
        [self.view addSubview:self.shoppingCartPickerView];
        [self.tableView setFrame:CGRectMake(self.tableView.frame.origin.x,
                                            self.tableView.frame.origin.y,
                                            self.tableView.frame.size.width,
                                            self.tableView.frame.size.height - self.shoppingCartPickerView.frame.size.height)];
        if (self.orderLinesAtWork.sections.count > 1) {
            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:self.shoppingCartPickerRow] 
                                  atScrollPosition:UITableViewScrollPositionTop animated:YES];
        }
    }
}

- (void)toggleSearchBar { 
    if (!self.searchDisplayController.active) { 
        [self.searchDisplayController setActive:YES animated:YES];
        [self.searchDisplayController.searchBar becomeFirstResponder];
    } else { 
        [self.searchDisplayController.searchBar resignFirstResponder];
        [self.searchDisplayController setActive:NO animated:YES];
    }
}

- (void)switchToOrderItem {	
    DSPF_OrderItem *dspf_OrderItem = [[[DSPF_OrderItem alloc] initWithNibName:@"DSPF_OrderItem" bundle:nil] autorelease];
    dspf_OrderItem.dataHeaderInfo = self.dataHeaderInfo;
    dspf_OrderItem.dataTask       = @"INSERT";
    dspf_OrderItem.title          = NSLocalizedString(@"TITLE__020", @"Erfassen");
    dspf_OrderItem.hasMinusSign   = self.runsAsTakingBack;
    if (self.searchDisplayController.active) { 
        [self.searchDisplayController.searchBar resignFirstResponder];
        [self.searchDisplayController setActive:NO animated:YES];
        self.tableView.tableHeaderView = nil;
    }
    // prepare "normal" mode for returning from the pushed dspf_OrderItem
    self.modifyTemplateLine = NO;
    self.moveTemplateLine   = NO;
    self.tableView.editing  = NO;
    self.navigationController.toolbarHidden = YES; // ... needed for the datePickerView in viewWillDisapear
    [self.navigationController pushViewController:dspf_OrderItem animated:YES];
}

- (void)viewDidLoad {
	[super viewDidLoad];
    if ([[self.navigationController.viewControllers objectAtIndex:(self.navigationController.viewControllers.count - 2)]
         isKindOfClass:[DSPF_Load class]] ||
        [[self.navigationController.viewControllers objectAtIndex:(self.navigationController.viewControllers.count - 2)]
         isKindOfClass:[DSPF_Unload class]] ||
        [[self.navigationController.viewControllers objectAtIndex:(self.navigationController.viewControllers.count - 2)]
         isKindOfClass:[DSPF_Customer class]]) {
            self.subTitle = NSLocalizedString(@"Leergut", @"Leergut");
    }
    self.toolbarHiddenBackup = self.navigationController.toolbarHidden;
    DSPF_Activity  *showActivity;
    if (self.dataHeaderInfo && [self.dataHeaderInfo isKindOfClass:[TemplateOrderHead class]]) { 
        showActivity = [[DSPF_Activity messageTitle:NSLocalizedString(@"TITLE__021", @"Vorlage wird geladen") 
                                        messageText:NSLocalizedString(@"MESSAGE__004", @"Bitte warten.") delegate:self] retain];
    } else {
        showActivity = [[DSPF_Activity messageTitle:[NSString stringWithFormat:NSLocalizedString(@"TITLE__022", @"%@ wird geladen"), 
                                                                               self.title] 
                                        messageText:NSLocalizedString(@"MESSAGE__004", @"Bitte warten.") delegate:self] retain];
    }
    [DPHUtilities waitForAlertToShow:0.236f];
    if ([self.dataTask isEqualToString:@"WRKACTANZ"]) { 
        NSError *error = nil;
        if (![self.orderLinesAtWork performFetch:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
	if (!self.tableView && [self.view isKindOfClass:[UITableView class]]) {
        self.tableView = (UITableView *)(self.view);
        self.tableView.backgroundColor = [[[UIColor alloc] initWithWhite:0.96 alpha:1.0] autorelease];
        UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 44)];
        [searchBar sizeToFit];
        if (self.hasTrademarkHolders) {
            [searchBar setScopeButtonTitles:[NSArray arrayWithObjects:NSLocalizedString(@"ABBREVIATIONS_03_001", @"EAN"),
                                             NSLocalizedString(@"ABBREVIATIONS_03_002", @"Art.Nr."),
                                             NSLocalizedString(@"ABBREVIATIONS_03_003", @"Art.Text"),
                                             NSLocalizedString(@"ABBREVIATIONS_03_004", @"Marke"), nil]];
        } else {
            [searchBar setScopeButtonTitles:[NSArray arrayWithObjects:NSLocalizedString(@"ABBREVIATIONS_03_001", @"EAN"),
                                             NSLocalizedString(@"ABBREVIATIONS_03_002", @"Art.Nr."),
                                             NSLocalizedString(@"ABBREVIATIONS_03_003", @"Art.Text"), nil]]; 
        }
        [searchBar setSelectedScopeButtonIndex:2];
        [searchBar setShowsScopeBar:YES];
        searchBar.tintColor    = [[[UIColor alloc] initWithRed:23.0 / 255 green:48.0 / 255 blue:72.0 / 255 alpha: 0.64] autorelease];
        searchBar.alpha        = 0.8;
        searchBar.keyboardType = UIKeyboardTypeDefault;
        searchBar.delegate = self;
        UISearchDisplayController *searchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:[searchBar autorelease] contentsController:self];
        searchDisplayController.delegate = self;
        searchDisplayController.searchResultsDataSource = self;
        searchDisplayController.searchResultsDelegate   = self;
        // The above assigns self.searchDisplayController, but without retaining.
        // Force the read-only property to be set and retained.
        [self forceSetReadOnlyPropertyOfSearchDisplayController:[searchDisplayController autorelease]];
    }
	self.view			  = [[[UIView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame] autorelease];
    self.tableView.frame  = self.view.bounds;
    [self.view addSubview:self.tableView]; 

    // Uncomment the following line to preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear = NO;
    [showActivity closeActivityInfo];
    [showActivity release];
    // Force instantiation for the following subviews to ensure correct size calculation
    self.datePickerView         = self.datePickerView;
    self.shoppingCartPickerView = self.shoppingCartPickerView;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSInteger orderLinesAtWorkFetchedObjectsCount = self.orderLinesAtWork.fetchedObjects.count;
    self.navigationController.toolbarHidden = NO;
    if ([self.dataTask isEqualToString:@"WRKACTANZ"]) { 
        if (orderLinesAtWorkFetchedObjectsCount == 0) { 
            UILabel *noResults = [[UILabel alloc] initWithFrame:CGRectMake(0, 44, 
                                                                           self.view.bounds.size.width,
                                                                           216)];
            noResults.text = NSLocalizedString(@"TITLE__063", @"KeineTreffer\n\nfür den aktuellen Warenkorb\n\ngefunden.");
            noResults.textAlignment   = UITextAlignmentCenter;
            noResults.textColor       = [UIColor dspfStatusReadyFillColor];
            noResults.numberOfLines   = 7;
            noResults.font            = [UIFont fontWithName:@"Helvetica-Bold" size:18];
            noResults.lineBreakMode   = UILineBreakModeWordWrap;
            noResults.backgroundColor = [UIColor clearColor];
            [self.view addSubview:[noResults autorelease]];
        }
    }
    if ((![self.dataHeaderInfo isKindOfClass:[TemplateOrderHead class]] 
         ||
        ([self.dataHeaderInfo isKindOfClass:[TemplateOrderHead class]] && [[self.dataHeaderInfo isUserDomain] boolValue])) 
         && 
        [self.dataTask isEqualToString:@"WRKACTDTA"] &&
        !self.wasSkippedOnce && orderLinesAtWorkFetchedObjectsCount == 0) { 
        self.wasSkippedOnce = YES;
        self.navigationItem.hidesBackButton = YES;
    } else {
        self.navigationItem.hidesBackButton = NO;
        if ([self.dataTask isEqualToString:@"WRKACTDTA"]) { 
            self.navigationItem.rightBarButtonItem = 
            [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd 
                                                           target:self 
                                                           action:@selector(switchToOrderItem)] autorelease];
            if (!self.dataHeaderInfo || [self.dataHeaderInfo isKindOfClass:[ArchiveOrderHead class]]) { 
                if ([[NSUserDefaults standardUserDefaults] boolForKey:@"HermesApp_SYSVAL_RUN_withBasketAnalysis"]) { 
                    self.toolbarItems = [NSArray arrayWithObjects:
                                         [[[UIBarButtonItem alloc] initWithImage:
                                           [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"delivery" ofType:@"png"]]
                                                                           style:UIBarButtonItemStylePlain
                                                                          target:self
                                                                          action:@selector(confirmDelivery)] autorelease],
                                         [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                        target:self
                                                                                        action:nil] autorelease],
                                         [[[UIBarButtonItem alloc] initWithImage:
                                           [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"trend" ofType:@"png"]]
                                                                           style:UIBarButtonItemStylePlain
                                                                          target:self
                                                                          action:@selector(analyzeOrder)] autorelease],
                                         [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                        target:self
                                                                                        action:nil] autorelease],
                                         [[[UIBarButtonItem alloc] initWithImage:
                                           [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"magnifyingglass" ofType:@"png"]]
                                                                           style:UIBarButtonItemStylePlain
                                                                          target:self
                                                                          action:@selector(toggleSearchBar)] autorelease],
                                         [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                        target:self
                                                                                        action:nil] autorelease],
                                         [[[UIBarButtonItem alloc] initWithImage:
                                           [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"trash" ofType:@"png"]]
                                                                           style:UIBarButtonItemStylePlain
                                                                          target:self
                                                                          action:@selector(confirmDelete)] autorelease],
                                         nil];
                } else {
                    self.toolbarItems = [NSArray arrayWithObjects:
                                         [[[UIBarButtonItem alloc] initWithImage:
                                           [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"delivery" ofType:@"png"]]
                                                                           style:UIBarButtonItemStylePlain
                                                                          target:self
                                                                          action:@selector(confirmDelivery)] autorelease],
                                         [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                        target:self
                                                                                        action:nil] autorelease],
                                         [[[UIBarButtonItem alloc] initWithImage:
                                           [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"magnifyingglass" ofType:@"png"]]
                                                                           style:UIBarButtonItemStylePlain
                                                                          target:self
                                                                          action:@selector(toggleSearchBar)] autorelease],
                                         [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                        target:self
                                                                                        action:nil] autorelease],
                                         [[[UIBarButtonItem alloc] initWithImage:
                                           [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"trash" ofType:@"png"]]
                                                                           style:UIBarButtonItemStylePlain
                                                                          target:self
                                                                          action:@selector(confirmDelete)] autorelease],
                                         nil];
                }
                if (orderLinesAtWorkFetchedObjectsCount != 0) {
                    self.numberBadgeView.value = orderLinesAtWorkFetchedObjectsCount;
                    [self.navigationController.toolbar addSubview:self.numberBadgeView];
                    if (PFBrandingSupported(BrandingBiopartner, nil)) {
                        self.navigationItem.hidesBackButton = YES;
                    }
                }
                self.tableView.separatorColor = [UIColor appStyleOrderColor];
            } else if ([self.dataHeaderInfo isKindOfClass:[TemplateOrderHead class]]) { 
                if ([[self.dataHeaderInfo isUserDomain] boolValue]) { 
                    UITapGestureRecognizer *tapGestureRecognizer = 
                    [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(switchAccessoryType)] autorelease];
                    [tapGestureRecognizer setNumberOfTapsRequired:2];
                    [tapGestureRecognizer setNumberOfTouchesRequired:1];
                    [self.navigationController.navigationBar addGestureRecognizer:tapGestureRecognizer];
                    self.toolbarItems = [NSArray arrayWithObjects: 
                                         [[[UIBarButtonItem alloc] initWithImage:
                                           [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"shoppingcart" ofType:@"png"]]
                                                                           style:UIBarButtonItemStylePlain
                                                                          target:self
                                                                          action:@selector(confirmOrderTemplateItems)] autorelease],
                                         [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                        target:self
                                                                                        action:nil] autorelease],
                                         [[[UIBarButtonItem alloc] initWithImage:
                                           [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"preferences" ofType:@"png"]]
                                                                           style:UIBarButtonItemStylePlain
                                                                          target:self
                                                                          action:@selector(switchAccessoryType)] autorelease],
                                         [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                        target:self
                                                                                        action:nil] autorelease],
                                         [[[UIBarButtonItem alloc] initWithImage:
                                           [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"magnifyingglass" ofType:@"png"]]
                                                                           style:UIBarButtonItemStylePlain
                                                                          target:self
                                                                          action:@selector(toggleSearchBar)] autorelease],
                                         [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                        target:self
                                                                                        action:nil] autorelease],
                                         [[[UIBarButtonItem alloc] initWithImage:
                                           [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"trash_empty" ofType:@"png"]]
                                                                           style:UIBarButtonItemStylePlain
                                                                          target:self
                                                                          action:@selector(confirmDelete)] autorelease],
                                         nil];
                    if (orderLinesAtWorkFetchedObjectsCount != 0) {
                        self.numberBadgeView.value = orderLinesAtWorkFetchedObjectsCount;
                        [self.navigationController.toolbar addSubview:self.numberBadgeView];
                    }
                    self.tableView.separatorColor = 
                    [[[UIColor alloc] initWithRed:250.0 / 255 green:250.0 / 255 blue:250.0 / 255 alpha:1.0] autorelease];
                } else { 
                    self.navigationItem.rightBarButtonItem = nil;
                    self.toolbarItems = [NSArray arrayWithObjects: 
                                         [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                        target:self
                                                                                        action:nil] autorelease],
                                         [[[UIBarButtonItem alloc] initWithImage:
                                           [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"magnifyingglass" ofType:@"png"]]
                                                                           style:UIBarButtonItemStylePlain
                                                                          target:self
                                                                          action:@selector(toggleSearchBar)] autorelease],
                                         [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                        target:self
                                                                                        action:nil] autorelease],
                                         nil];  
                }
            }
        } else { 
            if (![self.dataTask isEqualToString:@"WRKACTANZ"]) {
                self.toolbarItems = [NSArray arrayWithObjects:
                                     [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                    target:self
                                                                                    action:nil] autorelease],
                                     [[[UIBarButtonItem alloc] initWithImage:
                                       [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"magnifyingglass" ofType:@"png"]]
                                                                       style:UIBarButtonItemStylePlain
                                                                      target:self
                                                                      action:@selector(toggleSearchBar)] autorelease],
                                     [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                    target:self
                                                                                    action:nil] autorelease],
                                     nil];
            } else {
                self.toolbarItems = [NSArray array];
            }
        }
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (self.subTitle) {
        NSString *tmpTitle = self.title;
        self.title         = self.subTitle;
        self.subTitle      = tmpTitle;
    }
    if (self.navigationItem.hidesBackButton &&
        ![self.numberBadgeView.superview isEqual:self.navigationController.toolbar]) {
        [self switchToOrderItem];
    } else {
        [self.tableView reloadData];
        if (![self.dataTask isEqualToString:@"WRKACTANZ"] && 
            self.lastChangedLine) { 
            [self.tableView scrollToRowAtIndexPath:[self.orderLinesAtWork indexPathForObject:self.lastChangedLine] 
                                  atScrollPosition:UITableViewScrollPositionTop 
                                          animated:YES];
            //  For "WRKACTANZ" -> [self.orderLinesAtWork.fetchRequest.entityName isEqualToString:@"Item"]
            //  In this case the "else" scrolls to the top of the tableView
        } else {
        //  if (![self.dataHeaderInfo isKindOfClass:[TemplateOrderHead class]]) {
            [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
        }
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    if (self.subTitle) {
        NSString *tmpTitle = self.title;
        self.title         = self.subTitle;
        self.subTitle      = tmpTitle;
    }
    self.wasPrintedOnce = NO;
    if ([self.numberBadgeView.superview isEqual:self.navigationController.toolbar]) {
        [self.numberBadgeView removeFromSuperview];        
    }
    if (self.shoppingCartPickerView.window) {
        [self.shoppingCartPickerView removeFromSuperview];
        [self.tableView setFrame:CGRectMake(self.tableView.frame.origin.x,
                                            self.tableView.frame.origin.y,
                                            self.tableView.frame.size.width,
                                            self.tableView.frame.size.height + self.shoppingCartPickerView.frame.size.height)];
    }
    if (self.datePickerView.window) {
        [self.datePickerView removeFromSuperview];
        [self.tableView setFrame:CGRectMake(self.tableView.frame.origin.x,
                                            self.tableView.frame.origin.y,
                                            self.tableView.frame.size.width,
                                            self.tableView.frame.size.height + self.datePickerView.frame.size.height)];
    }
    for (UIGestureRecognizer *gestureRecognizer in self.navigationController.navigationBar.gestureRecognizers) {
        [self.navigationController.navigationBar removeGestureRecognizer:gestureRecognizer];
    }
    if ([self.navigationController.viewControllers indexOfObject:self] == NSNotFound) {
		// back button was pressed.  
		// We know this is true because self is no longer in the navigation stack.
        if (self.searchResultsCover.window) {
            [self.searchResultsCover removeFromSuperview];
        }
        if (self.searchDisplayController.active) { 
            [self.searchDisplayController.searchBar resignFirstResponder];
            [self.searchDisplayController setActive:NO animated:YES];
        }
        if (self.toolbarHiddenBackup) {
            [self.navigationController setToolbarHidden:YES animated:YES];
        }
	}
    [super viewWillDisappear:animated];
}

- (ArchiveOrderLine *)orderLine:(NSIndexPath *)indexPath { 
    // Return the object from this indexPath
	return (ArchiveOrderLine *)[self.orderLinesAtWork objectAtIndexPath:indexPath];
}

- (void)didSelectDataLine:(id)aDataLine withTarget:(NSString *)target {
    DSPF_OrderItem *dspf_OrderItem = [[DSPF_OrderItem alloc] initWithNibName:@"DSPF_OrderItem" bundle:nil];
    Item *item = nil;
    if ([aDataLine conformsToProtocol:@protocol(ItemHolder)]) {
        item = [(id<ItemHolder>)aDataLine item];
    }
    if ([target isEqualToString:@"updateDataLine"]) { 
        dspf_OrderItem.dataHeaderInfo = self.dataHeaderInfo;
        dspf_OrderItem.dataTask       = @"UPDATE";
        dspf_OrderItem.item           = item;
        dspf_OrderItem.title          = NSLocalizedString(@"TITLE__046", @"Ändern");
    } else {
        NSNumber *userID  = [NSNumber numberWithInt:[[NSUserDefaults currentUserID] intValue]];
        NSNumber *itemQTY = [NSNumber numberWithUnsignedInteger:[ArchiveOrderLine currentOrderQTYForItem:item.itemID
                                                                                  inCtx:self.ctx]];
        if ([target isEqualToString:@"insertOrderLine"]) { 
            if ([self.dataHeaderInfo isKindOfClass:[TemplateOrderHead class]]) {
                itemQTY = [NSNumber numberWithUnsignedInteger:[TemplateOrderLine currentTemplateQTYForItem:item.itemID
                                                                                              templateHead:self.dataHeaderInfo
                                                                                    inCtx:self.ctx]];
            } 
            if (![self.dataHeaderInfo isKindOfClass:[TemplateOrderHead class]] || [itemQTY unsignedIntegerValue] == 0) {
                if (item.orderUnitBoxQTY &&
                    [item.orderUnitBoxQTY compare:[NSDecimalNumber zero]] != NSOrderedSame) {
                    if ([item.orderUnitCode isEqualToString:@"KG"] ||
                        [item.orderUnitCode isEqualToString:@"LT"]) {
                        itemQTY = [NSNumber numberWithUnsignedInteger:
                                   [[item.orderUnitBoxQTY decimalNumberByMultiplyingByPowerOf10:3] unsignedIntegerValue]
                                   + [itemQTY unsignedIntegerValue]];
                    } else {
                        itemQTY = [NSNumber numberWithUnsignedInteger:
                                   [item.orderUnitBoxQTY unsignedIntegerValue]
                                   + [itemQTY unsignedIntegerValue]];
                    }
                } else { 
                    if ([item.orderUnitCode isEqualToString:@"KG"] ||
                        [item.orderUnitCode isEqualToString:@"LT"]) {
                        itemQTY     = [NSNumber numberWithUnsignedInteger:1000 
                                       + [itemQTY unsignedIntegerValue]];
                    } else { 
                        itemQTY     = [NSNumber numberWithUnsignedInteger:1 
                                       + [itemQTY unsignedIntegerValue]];
                    }
                }
            }
        }
        NSString *templateName = nil;
        if ([self.dataHeaderInfo isKindOfClass:[TemplateOrderHead class]] &&
            [self.dataHeaderInfo templateValidFrom] &&
            [self.dataHeaderInfo templateValidUntil]) { 
            templateName = [self.dataHeaderInfo templateName];
        }
        [self.ctx refreshObject:
         [ArchiveOrderLine orderLineForOrderHead:[ArchiveOrderHead orderHeadWithClientData:userID inCtx:self.ctx] 
                                      withItemID:item.itemID
                                         itemQTY:itemQTY 
                                          userID:userID 
                                    templateName:templateName
                          inCtx:self.ctx]
                                    mergeChanges:YES];
        [self.ctx saveIfHasChanges];
        dspf_OrderItem.dataHeaderInfo = nil;
        dspf_OrderItem.dataTask       = @"UPDATE";
        dspf_OrderItem.item           = item;
        dspf_OrderItem.title          = NSLocalizedString(@"TITLE__056", @"Warenkorb");
    }
    if (self.searchDisplayController.active) { 
        [self.searchDisplayController.searchBar resignFirstResponder];
        [self.searchDisplayController setActive:NO animated:YES];
        self.tableView.tableHeaderView = nil;
    }
    [self.navigationController pushViewController:[dspf_OrderItem autorelease] animated:YES];
}

- (void)confirmDelete {
    self.navigationController.toolbarHidden = YES;
    [[DSPF_Confirm question:[NSString stringWithFormat:NSLocalizedString(@"TITLE__062", @"%@: %i Artikel\n"), self.title, self.orderLinesAtWork.fetchedObjects.count]
                       item:@"confirmDelete" 
             buttonTitleYES:NSLocalizedString(@"TITLE__023", @"Löschen") 
              buttonTitleNO:NSLocalizedString(@"TITLE__018", @"Abbrechen") 
                 showInView:self.view] setDelegate:self]; 
}

- (void)confirmDelivery { 
    if (self.orderLinesAtWork.fetchedObjects.count > 0) { 
        self.navigationController.toolbarHidden = YES;
        if (self.orderLinesAtWork.sections.count == 1) {
            if (PFBrandingSupported(BrandingBiopartner, nil)) {
                if (wasPrintedOnce)
                    [[DSPF_Confirm question:[NSString stringWithFormat:NSLocalizedString(@"TITLE__062", @"%@: %i Artikel\n"), self.title, self.orderLinesAtWork.fetchedObjects.count]
                                       item:@"confirmDelivery"
                              buttonTitleOK:NSLocalizedString(@"TITLE__098", @"Drucken")
                             buttonTitleYES:NSLocalizedString(@"TITLE__024", @"Senden")
                              buttonTitleNO:NSLocalizedString(@"TITLE__018", @"Abbrechen")
                                 showInView:self.view] setDelegate:self];
                else
                    [[DSPF_Confirm question:[NSString stringWithFormat:NSLocalizedString(@"TITLE__062", @"%@: %i Artikel\n"), self.title, self.orderLinesAtWork.fetchedObjects.count]
                                       item:@"confirmDelivery"
                              buttonTitleOK:NSLocalizedString(@"TITLE__098", @"Drucken")
                             buttonTitleYES:nil
                              buttonTitleNO:NSLocalizedString(@"TITLE__018", @"Abbrechen")
                                 showInView:self.view] setDelegate:self];
            } else {
                [[DSPF_Confirm question:[NSString stringWithFormat:NSLocalizedString(@"TITLE__062", @"%@: %i Artikel\n"), self.title, self.orderLinesAtWork.fetchedObjects.count]
                                   item:@"confirmDelivery"
                         buttonTitleYES:NSLocalizedString(@"TITLE__024", @"Senden")
                          buttonTitleNO:NSLocalizedString(@"TITLE__018", @"Abbrechen")
                             showInView:self.view] setDelegate:self];
            }
        } else {
            [self.view addSubview:self.shoppingCartPickerView];
            [self.tableView setFrame:CGRectMake(self.tableView.frame.origin.x,
                                                self.tableView.frame.origin.y,
                                                self.tableView.frame.size.width,
                                                self.tableView.frame.size.height - self.shoppingCartPickerView.frame.size.height)];
            if (self.orderLinesAtWork.sections.count > 1) {
                [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:self.shoppingCartPickerRow] 
                                      atScrollPosition:UITableViewScrollPositionTop animated:YES];
            }
        }
    }
}

- (void)confirmOrderTemplateItems { 
    self.navigationController.toolbarHidden = YES;
    if (![TemplateOrderHead templateHeadWithName:[self.dataHeaderInfo templateName] hasCurrentOrderInCtx:self.ctx]) {
        [[DSPF_Confirm question:[NSString stringWithFormat:NSLocalizedString(@"TITLE__062", @"%@: %i Artikel\n"), self.title, self.orderLinesAtWork.fetchedObjects.count] 
                           item:@"confirmOrderTemplateItems" 
                  buttonTitleYES:NSLocalizedString(@"TITLE__048", @"Bestellen") 
                  buttonTitleNO:NSLocalizedString(@"TITLE__018", @"Abbrechen") 
                     showInView:self.view] setDelegate:self];
    } else {
        [[DSPF_Confirm question:[NSString stringWithFormat:NSLocalizedString(@"TITLE__062", @"%@: %i Artikel\n%@"), self.title, self.orderLinesAtWork.fetchedObjects.count, 
                                 NSLocalizedString(@"ERROR_MESSAGE__011", @"Einige Artikel sind bereits im Warenkorb !")] 
                           item:@"confirmOrderTemplateItems" 
                  buttonTitleOK:NSLocalizedString(@"TITLE__052", @"Ergänzen")
                 buttonTitleYES:NSLocalizedString(@"TITLE__047", @"Ersetzen")
                  buttonTitleNO:NSLocalizedString(@"TITLE__018", @"Abbrechen") 
                     showInView:self.view] setDelegate:self];
    }
}

- (void)analyzeOrder { 
    [self.analysisPicker showInView:self.navigationController.toolbar];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView {
    // Return the number of sections.
    if (self.subTitle) {
        return 1;
    }
    if (aTableView == self.searchDisplayController.searchResultsTableView) {
        return self.filteredListContent.sections.count;
    } 
    self.numberBadgeView.value = self.orderLinesAtWork.fetchedObjects.count;
    if ([self.numberBadgeView.superview isEqual:self.navigationController.toolbar] && self.numberBadgeView.value == 0) { 
        [self.numberBadgeView removeFromSuperview];
        if (PFBrandingSupported(BrandingBiopartner, nil)) {
            self.navigationItem.hidesBackButton = NO;
        }
    }
    return self.orderLinesAtWork.sections.count;
}


- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section {
    
    if (self.subTitle) {
        if (aTableView == self.searchDisplayController.searchResultsTableView) {
            return self.filteredListContent.fetchedObjects.count;
        }
        return self.orderLinesAtWork.fetchedObjects.count;
    }
    if (aTableView == self.searchDisplayController.searchResultsTableView) {
        return [[self.filteredListContent.sections objectAtIndex:section] numberOfObjects];
    }
    return [[self.orderLinesAtWork.sections objectAtIndex:section] numberOfObjects];
}

- (CGFloat)tableView:(UITableView *)aTableView heightForHeaderInSection:(NSInteger)section {
    if (!self.subTitle &&
        [self numberOfSectionsInTableView:aTableView] == 1 &&
        ((![self.dataHeaderInfo isKindOfClass:[TemplateOrderHead class]] 
          &&
          ![self.dataTask isEqualToString:@"WRKACTANZ"]) 
         || !self.hasProductGroups)) {
        return 0.0;
    }
    return 24.0;
}

- (UIView *)tableView:(UITableView *)aTableView viewForHeaderInSection:(NSInteger)aSection { 
    UIView *customView = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
    customView.backgroundColor = [UIColor clearColor]; 
    if (!self.subTitle &&
        [self numberOfSectionsInTableView:aTableView] == 1 &&
        ((![self.dataHeaderInfo isKindOfClass:[TemplateOrderHead class]] 
          &&
          ![self.dataTask isEqualToString:@"WRKACTANZ"]) 
         || !self.hasProductGroups)) {
        return customView;
    }
    UILabel *headerLabel = [[[UILabel alloc] initWithFrame:
                             CGRectMake(0.0, 
                                        0.0, 
                                        aTableView.frame.size.width, 
                                        24.0)] autorelease];
    headerLabel.opaque = YES;
    headerLabel.textAlignment = UITextAlignmentCenter;
    if (self.subTitle) {
        headerLabel.backgroundColor = self.searchDisplayController.searchBar.tintColor;
        // headerLabel.backgroundColor = [UIColor darkGrayColor];
        headerLabel.textColor = [UIColor whiteColor];
        headerLabel.text = self.subTitle;
    } else {
        id <NSFetchedResultsSectionInfo> sectionInfo;
        if (aTableView == self.searchDisplayController.searchResultsTableView) {
            sectionInfo = [[self.filteredListContent sections] objectAtIndex:aSection];
            headerLabel.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.88];
            headerLabel.textColor = [UIColor whiteColor];
        } else {
            sectionInfo = [[self.orderLinesAtWork    sections] objectAtIndex:aSection];
            headerLabel.backgroundColor = self.searchDisplayController.searchBar.tintColor;
            headerLabel.textColor = [UIColor whiteColor];
        }
        if ([self.dataHeaderInfo isKindOfClass:[TemplateOrderHead class]] ||
            [self.dataTask isEqualToString:@"WRKACTANZ"]) {
            headerLabel.font = [UIFont  fontWithName:@"HelveticaNeue-CondensedBlack" size:16];
            headerLabel.text = [LocalizedDescription textForKey:@"ItemProductGroup"
                                                       withCode:[sectionInfo name]
                                         inCtx:self.ctx];
            if (!headerLabel.text || headerLabel.text.length == 0) {
                headerLabel.text = [sectionInfo name];
                if (!headerLabel.text || headerLabel.text.length == 0) {
                    headerLabel.text = NSLocalizedString(@"TITLE__079", @"Ohne Zuordnung");
                }
            }
        } else {
            headerLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:18];
            headerLabel.text = [LocalizedDescription textForKey:@"PriceListDescription"
                                                       withCode:[sectionInfo name]
                                         inCtx:self.ctx];
            if (!headerLabel.text) {
                headerLabel.text = [sectionInfo name];
                if (!headerLabel.text || headerLabel.text.length == 0 ||
                    [headerLabel.text isEqualToString:@"*NONE-©"]) {
                    headerLabel.text = @"Freie Bestellung";
                }
            }
        }
    }
    [customView setFrame: CGRectMake(0.0,
                                     0.0, 
                                     headerLabel.frame.size.width, 
                                     headerLabel.frame.size.height)];
    [customView addSubview:headerLabel];
    return customView; 
}

- (id )dataLineAtIndexPath:(NSIndexPath *)indexPath forTableView:(UITableView *)aTableView { 
    // Return the object from this indexPath
    if (aTableView == self.searchDisplayController.searchResultsTableView) {
        return [self.filteredListContent objectAtIndexPath:indexPath];
    }
	return [self.orderLinesAtWork objectAtIndexPath:indexPath];
}

- (void)accessoryButtonTapped:(id)sender event:(id)event { 
    NSString *target;
    if (([self.dataHeaderInfo isKindOfClass:[TemplateOrderHead class]]
         || [self.dataTask isEqualToString:@"WRKACTANZ"]) &&
        [(UIButton *)sender imageForState:UIControlStateNormal] == [UIImage imageNamed:@"addButton.png"]) { 
        target = @"insertOrderLine";
    } else if ([self.dataHeaderInfo isKindOfClass:[TemplateOrderHead class]] &&
               [(UIButton *)sender imageForState:UIControlStateNormal] == [UIImage imageNamed:@"addButton_m.png"]) { 
        target = @"updateOrderLine";
    } else {
        target = @"updateDataLine";
    }
    if (self.searchDisplayController.searchResultsTableView.window) { 
        NSIndexPath *indexPath = [self.searchDisplayController.searchResultsTableView 
                                  indexPathForRowAtPoint:[[[event allTouches] anyObject] locationInView:
                                                          self.searchDisplayController.searchResultsTableView]];
        if (indexPath != nil) {
            [self didSelectDataLine:[self dataLineAtIndexPath:indexPath forTableView:self.searchDisplayController.searchResultsTableView] 
                         withTarget:target];
        }
    } else {
        NSIndexPath *indexPath = [self.tableView 
                                  indexPathForRowAtPoint:[[[event allTouches] anyObject] locationInView:self.tableView]];
        if (indexPath != nil) {
            [self didSelectDataLine:[self dataLineAtIndexPath:indexPath forTableView:self.tableView] 
                         withTarget:target];
        } 
    }
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    id   cell  = [aTableView dequeueReusableCellWithIdentifier:@"DSPF_OrderList"];        
    if (!cell) { 
        if (PFBrandingSupported(BrandingBiopartner, nil)) { 
            cell = [[[DSPF_OrderTableViewCell_biopartner alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"DSPF_OrderList"] autorelease]; 
        } else {
            cell = [[[DSPF_OrderTableViewCell alloc]            initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"DSPF_OrderList"] autorelease];
        }
    }
    // Configure the cell...
    ((UITableViewCell *)cell).selectionStyle = UITableViewCellSelectionStyleNone;
    if ([self.dataTask isEqualToString:@"WRKACTDTA"] ||
        [self.dataTask isEqualToString:@"WRKACTANZ"]) { 
        if ([self.dataHeaderInfo isKindOfClass:[TemplateOrderHead class]] && self.modifyTemplateLine) {
            ((UITableViewCell *)cell).accessoryView  = nil;
            if (!self.moveTemplateLine) { 
                ((UITableViewCell *)cell).accessoryType       = UITableViewCellAccessoryDetailDisclosureButton;
                ((UITableViewCell *)cell).showsReorderControl = NO;
            } else { 
                ((UITableViewCell *)cell).accessoryType       = UITableViewCellAccessoryNone;
                ((UITableViewCell *)cell).showsReorderControl = YES;
            }
        } else { 
            UIImage  *addButton = [UIImage imageNamed:@"addButton.png"];
            if (!((UITableViewCell *)cell).accessoryView) {
                UIButton *accessoryButton = [[[UIButton alloc] initWithFrame:CGRectMake(0, 0, addButton.size.width * 0.2, addButton.size.height * 0.2)] autorelease];
                [accessoryButton addTarget:self action:@selector(accessoryButtonTapped:event:) forControlEvents:UIControlEventTouchUpInside];
                ((UITableViewCell *)cell).accessoryView = accessoryButton;
            }
            [(UIButton *)((UITableViewCell *)cell).accessoryView setImage:addButton forState:UIControlStateNormal];
        }
    } else {
        ((UITableViewCell *)cell).accessoryType  = UITableViewCellAccessoryNone;
    }
    
    // [DSPF_OrderTableViewCell setDataLine] sets up all subviews ... 
    [cell setOrderTask:self.dataTask];
    [cell setDataLine:[self dataLineAtIndexPath:indexPath forTableView:(UITableView *)aTableView]];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 66;
}

#pragma mark - Table view delegate

/*
 * For negative quantities the "red" accessoryView option ist better than the "red" backgroundcolor option
 *
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([[NSDecimalNumber decimalNumberWithString:((DSPF_OrderTableViewCell *)cell).dataLineQTYLabel.text]
         compare:[NSDecimalNumber zero]] == NSOrderedAscending) {
        UIColor *hasMinusSignColor    = [[[UIColor alloc] initWithRed:232.0 / 255 green:31.0 / 255 blue:23.0 / 255 alpha: 0.9] autorelease];
        float h, s, b, a;
        if ([hasMinusSignColor getHue:&h saturation:&s brightness:&b alpha:&a])
            hasMinusSignColor         = [UIColor colorWithHue:h saturation:(s * 0.75) brightness:MIN(b * 1.5, 1.0) alpha:a];
        cell.backgroundColor = hasMinusSignColor;
    }
}
*/

- (void)dismissItemDetail {
    [self.navigationController dismissModalViewControllerAnimated:YES];
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
    //
    if (NO) {
        id<ItemHolder> itemHolder = [self dataLineAtIndexPath:indexPath forTableView:aTableView];
        Item *item = [itemHolder item];
        if (item) { 
            DSPF_ItemDetail *dspf_ItemDetail = [[DSPF_ItemDetail alloc] initWithNibName:@"DSPF_ItemDetail" bundle:nil];
            dspf_ItemDetail.title            = NSLocalizedString(@"TITLE__065", @"Artikel-Details");
            dspf_ItemDetail.item             = item;
            dspf_ItemDetail.navigationItem.rightBarButtonItem = 
            [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self 
                                                           action:@selector(dismissItemDetail)] autorelease];
            UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[dspf_ItemDetail autorelease]];
            navigationController.navigationBar.barStyle  = self.navigationController.navigationBar.barStyle;
            navigationController.toolbar.tintColor       = self.navigationController.toolbar.tintColor;
            navigationController.toolbar.alpha           = self.navigationController.toolbar.alpha;
            [self.navigationController presentModalViewController:[navigationController autorelease] animated:YES];
        }
    }
}

- (void)tableView:(UITableView *)aTableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath { 
    [self didSelectDataLine:[self dataLineAtIndexPath:indexPath forTableView:aTableView] withTarget:@"updateDataLine"];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath { 
    if ([self.dataHeaderInfo isKindOfClass:[TemplateOrderHead class]] && [[self.dataHeaderInfo isUserDomain] boolValue] && 
        [self.dataTask isEqualToString:@"WRKACTDTA"] && self.modifyTemplateLine && !self.moveTemplateLine ) {
        return UITableViewCellEditingStyleDelete;
    } else if (![self.dataHeaderInfo isKindOfClass:[TemplateOrderHead class]] &&
               [self.dataTask isEqualToString:@"WRKACTDTA"]) { 
        return UITableViewCellEditingStyleDelete;
    } 
    return UITableViewCellEditingStyleNone;
}

- (BOOL)tableView:(UITableView *)aTableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    if (aTableView != self.searchDisplayController.searchResultsTableView &&
        [self.dataHeaderInfo isKindOfClass:[TemplateOrderHead class]] && 
        [[self.dataHeaderInfo isUserDomain] boolValue] && self.modifyTemplateLine && self.moveTemplateLine) { 
        return YES;
    }
    return NO;
}

- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath { 
    if (sourceIndexPath.section == proposedDestinationIndexPath.section) { 
        return proposedDestinationIndexPath;
    }
    return sourceIndexPath;
}

- (void)tableView:(UITableView *)aTableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath { 
    if (fromIndexPath.section == toIndexPath.section) { 
        NSMutableArray    *selectedArray  = [NSMutableArray arrayWithArray:[self.orderLinesAtWork fetchedObjects]];
        TemplateOrderLine *selectedObject = (TemplateOrderLine *)[self.orderLinesAtWork objectAtIndexPath:fromIndexPath];
        [selectedArray removeObjectAtIndex:fromIndexPath.row];
        [selectedArray insertObject:selectedObject atIndex:toIndexPath.row];
        for (NSInteger i = 0; i < selectedArray.count; i++) { 
            ((TemplateOrderLine *)[selectedArray objectAtIndex:i]).sortValue = [NSString stringWithFormat:@"%04i", i];
        }
        [self.ctx saveIfHasChanges];
        [aTableView reloadData];
    }
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath { 
    return NO; 
}

- (void)tableView:(UITableView *)aTableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.ctx deleteObject:[self dataLineAtIndexPath:indexPath forTableView:aTableView]];
        [self.ctx saveIfHasChanges];
    }
}


#pragma mark - Content Filtering

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSInteger )scope { 
    NSError *error = nil;
    if (!self.dataHeaderInfo) { 
        switch (scope) { 
            case 0:
                [self.filteredListContent.fetchRequest setPredicate:[NSPredicate predicateWithFormat:
                                                                     @"archiveOrderHead.orderState = 00 && "
                                                                      "any item.itemCode.code BEGINSWITH %@", 
                                                                     [NSString stringWithString:searchText]]];
                break;
            case 1:
                [self.filteredListContent.fetchRequest setPredicate:[NSPredicate predicateWithFormat:
                                                                     @"archiveOrderHead.orderState = 00 && "
                                                                       "item.itemID BEGINSWITH %@", 
                                                                     [NSString stringWithString:searchText]]];
                break;
            case 2:
                [self.filteredListContent.fetchRequest setPredicate:[NSPredicate predicateWithFormat:
                                                                     @"archiveOrderHead.orderState = 00 && "
                                                                      "any item.itemDescription.text CONTAINS[cd] %@", 
                                                                     [NSString stringWithString:searchText]]];
                break;
            case 3:
                {
                    NSArray  *trademarkholders = nil;
                    NSError  *error		       = nil;
                    NSFetchRequest *subQuery   = [[NSFetchRequest alloc] init];
                    subQuery.entity            = [NSEntityDescription entityForName:@"LocalizedDescription" inManagedObjectContext:self.ctx];
                    subQuery.predicate         = [NSPredicate predicateWithFormat:@"key = %@ && text CONTAINS[cd] %@",
                                                  @"ItemTrademarkHolder", [NSString stringWithString:searchText]];
                    [subQuery setPropertiesToFetch:[NSArray arrayWithObject:@"code"]];
                    trademarkholders           = [[self.ctx executeFetchRequest:subQuery error:&error] valueForKeyPath:@"code"];
                    [subQuery release];
                    
                    [self.filteredListContent.fetchRequest setPredicate:[NSPredicate predicateWithFormat:
                                                                         @"archiveOrderHead.orderState = 00 && "
                                                                          "item.trademarkHolder IN %@ ", trademarkholders]];
                }
                break;
        }
    } else if ([self.dataHeaderInfo isKindOfClass:[ArchiveOrderHead class]]) {
        switch (scope) { 
            case 0:
                [self.filteredListContent.fetchRequest setPredicate:[NSPredicate predicateWithFormat:
                                                                     @"archiveOrderHead.order_id = %ld && "
                                                                      "any item.itemCode.code BEGINSWITH %@",
                                                                     [[self.dataHeaderInfo order_id] longValue],
                                                                     [NSString stringWithString:searchText]]];
                break;
            case 1:
                [self.filteredListContent.fetchRequest setPredicate:[NSPredicate predicateWithFormat:
                                                                     @"archiveOrderHead.order_id = %ld && "
                                                                      "item.itemID BEGINSWITH %@", 
                                                                     [[self.dataHeaderInfo order_id] longValue],
                                                                     [NSString stringWithString:searchText]]];
                break;
            case 2:
                [self.filteredListContent.fetchRequest setPredicate:[NSPredicate predicateWithFormat:
                                                                     @"archiveOrderHead.order_id = %ld && "
                                                                      "any item.itemDescription.text CONTAINS[cd] %@",
                                                                     [[self.dataHeaderInfo order_id] longValue],
                                                                     [NSString stringWithString:searchText]]];
                break;
            case 3:
            {
                NSArray  *trademarkholders = nil;
                NSError  *error		       = nil;
                NSFetchRequest *subQuery   = [[NSFetchRequest alloc] init];
                subQuery.entity            = [NSEntityDescription entityForName:@"LocalizedDescription" inManagedObjectContext:self.ctx];
                subQuery.predicate         = [NSPredicate predicateWithFormat:@"key = %@ && text CONTAINS[cd] %@",
                                              @"ItemTrademarkHolder", [NSString stringWithString:searchText]];
                [subQuery setPropertiesToFetch:[NSArray arrayWithObject:@"code"]];
                trademarkholders           = [[self.ctx executeFetchRequest:subQuery error:&error] valueForKeyPath:@"code"];
                [subQuery release];
                
                [self.filteredListContent.fetchRequest setPredicate:[NSPredicate predicateWithFormat:
                                                                     @"archiveOrderHead.order_id = %ld && "
                                                                      "item.trademarkHolder IN %@ ", 
                                                                     [[self.dataHeaderInfo order_id] longValue], 
                                                                     trademarkholders]];
            }
                break;
        }
    } else if ([self.dataHeaderInfo isKindOfClass:[TemplateOrderHead class]]) {
        switch (scope) { 
            case 0:
                [self.filteredListContent.fetchRequest setPredicate:[NSPredicate predicateWithFormat:
                                                                     @"templateOrderHead.template_id = %ld && "
                                                                     "any item.itemCode.code BEGINSWITH %@",
                                                                     [[self.dataHeaderInfo template_id] longValue],
                                                                     [NSString stringWithString:searchText]]];
                break;
            case 1:
                [self.filteredListContent.fetchRequest setPredicate:[NSPredicate predicateWithFormat:
                                                                     @"templateOrderHead.template_id = %ld && "
                                                                     "item.itemID BEGINSWITH %@", 
                                                                     [[self.dataHeaderInfo template_id] longValue],
                                                                     [NSString stringWithString:searchText]]];
                break;
            case 2:
                [self.filteredListContent.fetchRequest setPredicate:[NSPredicate predicateWithFormat:
                                                                     @"templateOrderHead.template_id = %ld && "
                                                                     "any item.itemDescription.text CONTAINS[cd] %@",
                                                                     [[self.dataHeaderInfo template_id] longValue],
                                                                     [NSString stringWithString:searchText]]];
                break;
            case 3:
            {
                NSArray  *trademarkholders = nil;
                NSError  *error		       = nil;
                NSFetchRequest *subQuery   = [[NSFetchRequest alloc] init];
                subQuery.entity            = [NSEntityDescription entityForName:@"LocalizedDescription" inManagedObjectContext:self.ctx];
                subQuery.predicate         = [NSPredicate predicateWithFormat:@"key = %@ && text CONTAINS[cd] %@",
                                              @"ItemTrademarkHolder", [NSString stringWithString:searchText]];
                [subQuery setPropertiesToFetch:[NSArray arrayWithObject:@"code"]];
                trademarkholders           = [[self.ctx executeFetchRequest:subQuery error:&error] valueForKeyPath:@"code"];
                [subQuery release];
                
                [self.filteredListContent.fetchRequest setPredicate:[NSPredicate predicateWithFormat:
                                                                     @"templateOrderHead.template_id = %ld && "
                                                                      "item.trademarkHolder IN %@ ", 
                                                                     [[self.dataHeaderInfo template_id] longValue], 
                                                                     trademarkholders]];
            }
                break;
        }
    }
    if (![self.filteredListContent performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    } 
}

#pragma mark - UISearchDisplayController Delegate Methods

- (void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller { 
    self.navigationController.toolbarHidden = YES;
    self.tableView.tableHeaderView = controller.searchBar;
    self.searchResultsCover.frame = CGRectMake(self.tableView.frame.origin.x, 
                                               self.tableView.frame.origin.y 
                                               + controller.searchBar.frame.size.height 
                                               + self.navigationController.navigationBar.frame.size.height, 
                                               self.tableView.frame.size.width, 
                                               self.tableView.frame.size.height 
                                               - controller.searchBar.bounds.size.height 
                                               - self.navigationController.navigationBar.frame.size.height);
    self.searchResultsCover.hidden = YES; 
    [self.tableView addSubview:self.searchResultsCover];
}

- (void)searchDisplayControllerDidBeginSearch:(UISearchDisplayController *)controller { 
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller { 
    if (self.searchResultsCover.window) {
        [self.searchResultsCover removeFromSuperview];
    }
    self.tableView.tableHeaderView = nil;
    self.navigationController.toolbarHidden = NO;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString { 
    if (!searchString || searchString.length == 0) { 
        [self.searchResultsCover           setHidden:YES];
        return YES; // Return YES to cause the search result table view to be reloaded.
    } else if (controller.searchBar.selectedScopeButtonIndex < 2) { 
        [self filterContentForSearchText:searchString scope:controller.searchBar.selectedScopeButtonIndex];
        [controller.searchResultsTableView setHidden:NO];
        [self.searchResultsCover           setHidden:YES];
        return YES; // Return YES to cause the search result table view to be reloaded.
    }
    [controller.searchResultsTableView setHidden:YES];
    [self.searchResultsCover           setHidden:(searchString.length == 0)];
    return NO;    
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption { 
    controller.searchBar.text = @"";
    [controller.searchResultsTableView setHidden:NO];
    [self.searchResultsCover           setHidden:YES];
//  [self filterContentForSearchText:[controller.searchBar text] scope:searchOption]; 
    return YES; // Return YES to cause the search result table view to be reloaded.
}

- (void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope {
    [searchBar resignFirstResponder];
    if (selectedScope < 2) {
        searchBar.keyboardType = UIKeyboardTypeNumberPad;
    } else {
        searchBar.keyboardType = UIKeyboardTypeDefault;
    }
    [searchBar becomeFirstResponder];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    if (searchBar.selectedScopeButtonIndex >= 2) {
        [self filterContentForSearchText:searchBar.text scope:searchBar.selectedScopeButtonIndex];
        [self.searchDisplayController.searchResultsTableView setHidden:NO];
        [self.searchResultsCover                             setHidden:YES];
        [self.searchDisplayController.searchResultsTableView reloadData];
    }
}

#pragma mark - Fetched results controller delegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller { 
    if (controller == self.filteredListContent) {
        [self.searchDisplayController.searchResultsTableView beginUpdates];
    } else {
        [self.tableView beginUpdates];
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    if (controller == self.filteredListContent) {
        switch(type) {
            case NSFetchedResultsChangeInsert:
                [self.searchDisplayController.searchResultsTableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
                break;
            case NSFetchedResultsChangeDelete:
                [self.searchDisplayController.searchResultsTableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
                break;
            default:
                break;
        }
    } else { 
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
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
    if (controller == self.filteredListContent) { 
        switch(type) {
            case NSFetchedResultsChangeInsert:
                [self.searchDisplayController.searchResultsTableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
                break;
            case NSFetchedResultsChangeDelete:
                [self.searchDisplayController.searchResultsTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
                break;
            case NSFetchedResultsChangeUpdate:
                [self.searchDisplayController.searchResultsTableView cellForRowAtIndexPath:indexPath];
                break;
            case NSFetchedResultsChangeMove:
                [self.searchDisplayController.searchResultsTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
                [self.searchDisplayController.searchResultsTableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]withRowAnimation:UITableViewRowAnimationFade];
                break;
        }
    } else { 
        switch(type) {
            case NSFetchedResultsChangeInsert:
                [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
                break;
            case NSFetchedResultsChangeDelete:
                [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
                break;
            case NSFetchedResultsChangeUpdate:
                [self.tableView cellForRowAtIndexPath:indexPath];
                break;
            case NSFetchedResultsChangeMove:
                [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
                [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]withRowAnimation:UITableViewRowAnimationFade];
                break;
        }
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller { 
    if (controller == self.filteredListContent) { 
        [self.searchDisplayController.searchResultsTableView endUpdates];
        [self.searchDisplayController.searchResultsTableView reloadData];
    } else {
        [self.tableView endUpdates];
        [self.tableView reloadData];
        [self.ctx saveIfHasChanges];
    }
} 

- (void)actionSheet:(UIActionSheet *)aActionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex { 
    if ([[aActionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:NSLocalizedString(@"TITLE__066", @"Hitliste")]) { 
        DSPF_Order *dspf_Order = [[[DSPF_Order alloc] init] autorelease];
        dspf_Order.title       = [aActionSheet buttonTitleAtIndex:buttonIndex];
        dspf_Order.dataTask    = @"WRKACTANZ";
        NSFetchRequest *selectOrderLinesAtWork = [[[NSFetchRequest alloc] init] autorelease];
        [selectOrderLinesAtWork setEntity:[NSEntityDescription entityForName:@"Item" inManagedObjectContext:self.ctx]];
        [selectOrderLinesAtWork setPredicate:[NSPredicate predicateWithFormat:@"productGroup IN %@ "
                                              "&& (0 == SUBQUERY(archiveOrderLine, $a, $a.archiveOrderHead.orderState == 0).@count)"
                                              "&& hitlist.positionNumber > 0  && hitlist.positionNumber < 4 ", 
                                              [NSSet setWithArray:[
                                                [ArchiveOrderLine currentOrderLinesInCtx:dspf_Order.ctx] valueForKeyPath:@"item.productGroup"]
                                               ]]];
        [selectOrderLinesAtWork setSortDescriptors:[NSArray arrayWithObjects: 
                                                    [NSSortDescriptor sortDescriptorWithKey:@"productGroup"    ascending:YES],
                                                    [NSSortDescriptor sortDescriptorWithKey:@"trademarkHolder" ascending:YES], 
                                                    [NSSortDescriptor sortDescriptorWithKey:@"itemID"          ascending:YES],
                                                     nil]];
        dspf_Order.orderLinesAtWork = [[[NSFetchedResultsController alloc] initWithFetchRequest:selectOrderLinesAtWork 
                                                                           managedObjectContext:dspf_Order.ctx
                                                                             sectionNameKeyPath:@"productGroup" 
                                                                                      cacheName:nil] autorelease];
        dspf_Order.orderLinesAtWork.delegate = dspf_Order;  
        [self.navigationController pushViewController:dspf_Order animated:YES];        
    } else if ([[aActionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:NSLocalizedString(@"TITLE__067", @"Trendsetter")]) { 
        DSPF_Order *dspf_Order = [[[DSPF_Order alloc] init] autorelease];
        dspf_Order.title       = [aActionSheet buttonTitleAtIndex:buttonIndex];
        dspf_Order.dataTask    = @"WRKACTANZ";
        NSFetchRequest *selectOrderLinesAtWork = [[[NSFetchRequest alloc] init] autorelease];
        [selectOrderLinesAtWork setEntity:[NSEntityDescription entityForName:@"Item" inManagedObjectContext:self.ctx]];
        [selectOrderLinesAtWork setPredicate:[NSPredicate predicateWithFormat:
                                            @"    (0 == SUBQUERY(archiveOrderLine, $a, $a.archiveOrderHead.orderState == 0).@count)"
                                              "&& newcomerBit = YES ", 
                                              [NSSet setWithArray:[
                                                [ArchiveOrderLine currentOrderLinesInCtx:dspf_Order.ctx]
                                                                   valueForKeyPath:@"item.productGroup"]
                                               ]]];
        [selectOrderLinesAtWork setSortDescriptors:[NSArray arrayWithObjects: 
                                                    [NSSortDescriptor sortDescriptorWithKey:@"productGroup"    ascending:YES],
                                                    [NSSortDescriptor sortDescriptorWithKey:@"trademarkHolder" ascending:YES], 
                                                    [NSSortDescriptor sortDescriptorWithKey:@"itemID"          ascending:YES],
                                                    nil]];
        dspf_Order.orderLinesAtWork = [[[NSFetchedResultsController alloc] initWithFetchRequest:selectOrderLinesAtWork 
                                                                           managedObjectContext:dspf_Order.ctx
                                                                             sectionNameKeyPath:@"productGroup" 
                                                                                      cacheName:nil] autorelease];
        dspf_Order.orderLinesAtWork.delegate = dspf_Order;  
        [self.navigationController pushViewController:dspf_Order animated:YES];         
    } else if ([[aActionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:NSLocalizedString(@"TITLE__069", @"Warenkorbanalyse")]) { 
        DSPF_Order *dspf_Order = [[[DSPF_Order alloc] init] autorelease];
        dspf_Order.title       = [aActionSheet buttonTitleAtIndex:buttonIndex];
        dspf_Order.dataTask    = @"WRKACTANZ";
        NSFetchRequest *selectOrderLinesAtWork = [[[NSFetchRequest alloc] init] autorelease];
        [selectOrderLinesAtWork setEntity:[NSEntityDescription entityForName:@"Item" inManagedObjectContext:self.ctx]];
        [selectOrderLinesAtWork setPredicate:[NSPredicate predicateWithFormat:
                                             @"    (0 == SUBQUERY(archiveOrderLine, $a, $a.archiveOrderHead.orderState == 0).@count)"
                                              "&& ((0 != SUBQUERY(basketAnalysis.analyzedItem.archiveOrderLine, "
                                                                                  "$b1, $b1.archiveOrderHead.orderState == 0).@count)"
                                              "||  (0 != SUBQUERY(basketAnalyzedItem.item.archiveOrderLine, "
                                                                                  "$b2, $b2.archiveOrderHead.orderState == 0).@count))"]];
        [selectOrderLinesAtWork setSortDescriptors:[NSArray arrayWithObjects: 
                                                    [NSSortDescriptor sortDescriptorWithKey:@"productGroup"    ascending:YES],
                                                    [NSSortDescriptor sortDescriptorWithKey:@"trademarkHolder" ascending:YES], 
                                                    [NSSortDescriptor sortDescriptorWithKey:@"itemID"          ascending:YES],
                                                    nil]];
        dspf_Order.orderLinesAtWork = [[[NSFetchedResultsController alloc] initWithFetchRequest:selectOrderLinesAtWork 
                                                                           managedObjectContext:dspf_Order.ctx
                                                                             sectionNameKeyPath:@"productGroup" 
                                                                                      cacheName:nil] autorelease];
        dspf_Order.orderLinesAtWork.delegate = dspf_Order;  
        [self.navigationController pushViewController:dspf_Order animated:YES];         
    }
}

- (void) dspf_Confirm:(DSPF_Confirm *)sender didConfirmQuestion:(NSString *)question item:(NSObject *)item withButtonTitle:(NSString *)buttonTitle {
    self.navigationController.toolbarHidden = NO;
	if (![buttonTitle isEqualToString:NSLocalizedString(@"TITLE__018", @"Abbrechen")]) {
		if ([(NSString *)item isEqualToString:@"confirmDelete"]) { 
            if ([self.dataHeaderInfo isKindOfClass:[TemplateOrderHead class]]) { 
                // TemplateOrderHead can only be removed in DSPF_OrderTemplate and is allowed to exist without any TemplateOrderLine 
                for (TemplateOrderLine *tmpOrderLine in [NSArray arrayWithArray:[self.orderLinesAtWork fetchedObjects]]) { 
                    [self.ctx deleteObject:tmpOrderLine];
                }
            } else { 
                // OrderLines are deleted over relation rule "delete cascade"
                ArchiveOrderHead *tmpOrderHead = [ArchiveOrderHead currentOrderHeadInCtx:self.ctx];
                if (tmpOrderHead) {
                    [self.ctx deleteObject:tmpOrderHead];
                }
            }
            [self.ctx saveIfHasChanges];
            if (PFBrandingSupported(BrandingBiopartner, nil)) {
                [self.navigationController popViewControllerAnimated:YES];
            } else {
                [self.tableView reloadData];
            }
		} else if ([(NSString *)item isEqualToString:@"confirmOrderTemplateItems"]) {
            NSNumber *userID = [NSNumber numberWithInt:[[NSUserDefaults currentUserID] intValue]];
            for (TemplateOrderLine *tmpOrderLine in [NSArray arrayWithArray:[self.orderLinesAtWork fetchedObjects]]) { 
                if (![buttonTitle isEqualToString:NSLocalizedString(@"TITLE__052", @"Ergänzen")] || 
                    [ArchiveOrderLine currentOrderQTYForItem:tmpOrderLine.itemID inCtx:tmpOrderLine.managedObjectContext] == 0) {
                    NSString *templateName = nil;
                    if ([self.dataHeaderInfo isKindOfClass:[TemplateOrderHead class]] &&
                        [self.dataHeaderInfo templateValidFrom] &&
                        [self.dataHeaderInfo templateValidUntil]) { 
                        templateName = [self.dataHeaderInfo templateName];
                    }
                    [[[ArchiveOrderLine orderLineForOrderHead:[ArchiveOrderHead orderHeadWithClientData:userID inCtx:self.ctx] 
                                                   withItemID:tmpOrderLine.itemID 
                                                      itemQTY:[NSNumber numberWithUnsignedInteger:[tmpOrderLine.itemQTY unsignedIntValue]] 
                                                       userID:userID 
                                                 templateName:templateName 
                                       inCtx:self.ctx] retain] release];
                }
            }
            [self.ctx saveIfHasChanges];
            [self.tableView reloadData];
        } else if ([(NSString *)item isEqualToString:@"confirmDelivery"]) {
            if ([buttonTitle isEqualToString:NSLocalizedString(@"TITLE__024", @"Senden")])
                [self sendOrder];
            else if ([buttonTitle isEqualToString:NSLocalizedString(@"TITLE__098", @"Drucken")])
                [self printOrder];
		}
	}
}

#pragma mark - Picker view delegate

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
	return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
	return self.orderLinesAtWork.sections.count;
}

/*
 - (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
 
 }
*/

- (UIView *)pickerView:(UIPickerView *)aPickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
	UILabel *label = (id)view;
	if (!label || ([label class] != [UILabel class])) {
		label = [[[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, [aPickerView rowSizeForComponent:component].width, [aPickerView rowSizeForComponent:component].height)] autorelease];
        label.backgroundColor = [UIColor clearColor];
	}
    id <NSFetchedResultsSectionInfo> sectionInfo;
    sectionInfo = [[self.orderLinesAtWork sections] objectAtIndex:row];
    label.text = [LocalizedDescription textForKey:@"PriceListDescription"
                                         withCode:[sectionInfo name]
                           inCtx:self.ctx];
    if (!label.text) {
        label.text = [sectionInfo name];
        if (!label.text || label.text.length == 0 || [label.text isEqualToString:@"*NONE-©"]) {
            label.text = NSLocalizedString(@"TITLE__064", @"Freie Bestellung");
        }
    }
    label.text = [NSString stringWithFormat:@"   %@", label.text];
	label.font = [UIFont fontWithName:@"Helvetica-Bold" size:20];
	return label;
}

- (void)pickerView:(UIPickerView *)aPickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
	self.shoppingCartPickerRow = row;
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:self.shoppingCartPickerRow]
                          atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

#pragma mark - Memory management



- (void)viewDidUnload {
    [super viewDidUnload];

}

- (void)dealloc { 
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSManagedObjectContextDidSaveNotification object:nil];
    [searchResultsCover         release];
	[ctx       release];
    [lastChangedLine            release];
    [filteredListContent        release];
    [orderLinesAtWork           release];
    [datePickerView             release];
    [datePicker                 release];
    [analysisPicker             release];
    [shoppingCartPickerView     release];
    [shoppingCartPicker         release];
    [numberBadgeView            release];
    [dataHeaderInfo             release];
    [dataTask                   release];
	[tableView                  release];
    [subTitle                   release];
    [super dealloc];
}


@end