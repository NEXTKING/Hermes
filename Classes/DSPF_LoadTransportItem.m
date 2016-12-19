//
//  DSPF_LoadTransportItem.m
//  Hermes
//
//  Created by Lutz  Thalmann on 07.12.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "HermesAppDelegate.h"
#import "DSPF_LoadTransportItem.h"
#import "DSPF_NameForSignature.h"
#import "DSPF_Activity.h"
#import "DSPF_Error.h"
#import "UILIBViewSwitcher.h"

#import "ItemDescription.h"
#import "ItemCode.h"
#import "Transport.h"
#import "User.h"
#import "LocalizedDescription.h"

@implementation DSPF_LoadTransportItem

@synthesize scanView;
@synthesize tableView;
@synthesize didItOnce;
@synthesize toolbarHiddenBackup;
@synthesize pickerViewToolbar;
@synthesize pickerViewToolbarText;
@synthesize pickerViewToolbarTextField;
@synthesize pickerViewToolbarDone;
@synthesize pickerView;
@synthesize tmpItemQTY;
@synthesize tmpItemQTYs;
@synthesize departure;
@synthesize tourTask;
@synthesize itemDescriptionLabel;
@synthesize locationName;
@synthesize streetAddress;
@synthesize zipCode;
@synthesize city;
@synthesize item;
@synthesize itemIndexPath;
@synthesize currentTransportGroupTask;
@synthesize navigationBarColor;
@synthesize hasConfirmedQTYWarning;
@synthesize currencyFormatter;
@synthesize hasTrademarkHolders;
@synthesize hasProductGroups;
@synthesize ctx;
@synthesize filteredListContent;
@synthesize searchResultsCover;


#pragma mark - Initialization

- (NSMutableDictionary *)tmpItemQTYs {
	if (!tmpItemQTYs) {
		tmpItemQTYs = [[NSMutableDictionary alloc] initWithCapacity:8];
	}
	return tmpItemQTYs;
}

- (NSNumberFormatter *)currencyFormatter {
    if (!currencyFormatter) {
        currencyFormatter = [[NSNumberFormatter alloc] init];
        [currencyFormatter  setNumberStyle:NSNumberFormatterCurrencyStyle];
        [currencyFormatter  setGeneratesDecimalNumbers:YES];
        [currencyFormatter  setFormatterBehavior:NSNumberFormatterBehavior10_4];
    }
    return currencyFormatter;
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
    return NO;
}

- (NSManagedObjectContext *)ctx {
    if (!ctx) {
		ctx = [[(HermesAppDelegate *)[[UIApplication sharedApplication] delegate] ctx] retain];
    }
    return ctx;
}

- (NSFetchedResultsController *)filteredListContent {
    if (!filteredListContent) {
        NSError *error = nil;
        NSFetchRequest *filteredContent = [[[NSFetchRequest alloc] init] autorelease];
        if (!self.searchDisplayController.searchBar.text || self.searchDisplayController.searchBar.text.length == 0) {
            [filteredContent setEntity:[NSEntityDescription entityForName:@"Item" inManagedObjectContext:self.ctx]];
            [filteredContent setPredicate:[DSPF_LoadTransportItem predicateForShownTransportItems]];
            [filteredContent setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"bestBeforeDays" ascending:NO],
                                                  [NSSortDescriptor sortDescriptorWithKey:@"itemID" ascending:YES],
                                                  [NSSortDescriptor sortDescriptorWithKey:@"productGroup" ascending:YES]]];
        } else {
            switch (self.searchDisplayController.searchBar.selectedScopeButtonIndex) {
                case 0:
                    [filteredContent setEntity:[NSEntityDescription entityForName:@"ItemCode" inManagedObjectContext:self.ctx]];
                    // [self.filteredListContent.fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"code BEGINSWITH[cd] %@", searchText]];
                    // [self.filteredListContent.fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"code BETWEEN %@", (NSArray *) ]];
                    // BETWEEN operations are aggregate operations, and aggregate operations are not supported by Core Data !!!
                    [filteredContent setPredicate:
                     [NSPredicate predicateWithFormat:@"code >= %@ AND code <= %@ && item.storeAssortmentBit = YES",
                      [NSExpression expressionForConstantValue:self.searchDisplayController.searchBar.text],
                      [NSExpression expressionForConstantValue:[self.searchDisplayController.searchBar.text stringByAppendingString:[NSString stringWithUTF8String:"\uffff"]]]
                      ]
                     ];
                    //          [self.filteredListContent.fetchRequest setRelationshipKeyPathsForPrefetching:[NSArray arrayWithObject:@"item"]];
                    [filteredContent setSortDescriptors:[NSArray arrayWithObjects:
                                                         [NSSortDescriptor sortDescriptorWithKey:@"item.productGroup" ascending:YES],
                                                         [NSSortDescriptor sortDescriptorWithKey:@"code"              ascending:YES],
                                                         [NSSortDescriptor sortDescriptorWithKey:@"itemID"            ascending:YES], nil]];
                    break;
                case 1:
                    [filteredContent setEntity:[NSEntityDescription entityForName:@"Item" inManagedObjectContext:self.ctx]];
                    // [self.filteredListContent.fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"itemID BEGINSWITH[cd] %@", searchText]];
                    // [self.filteredListContent.fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"itemID BETWEEN %@", (NSArray *) ]];
                    // BETWEEN operations are aggregate operations, and aggregate operations are not supported by Core Data !!!
                    [filteredContent setPredicate:
                     [NSPredicate predicateWithFormat:@"itemID >= %@ AND itemID <= %@ && storeAssortmentBit = YES",
                      [NSExpression expressionForConstantValue:self.searchDisplayController.searchBar.text],
                      [NSExpression expressionForConstantValue:[self.searchDisplayController.searchBar.text stringByAppendingString:[NSString stringWithUTF8String:"\uffff"]]]
                      ]
                     ];
                    //          [self.filteredListContent.fetchRequest setRelationshipKeyPathsForPrefetching:[NSArray array]];
                    [filteredContent setSortDescriptors:[NSArray arrayWithObjects:
                                                         [NSSortDescriptor sortDescriptorWithKey:@"productGroup" ascending:YES],
                                                         [NSSortDescriptor sortDescriptorWithKey:@"itemID"       ascending:YES], nil]];
                    break;
                case 2:
                    [filteredContent setEntity:[NSEntityDescription entityForName:@"ItemDescription" inManagedObjectContext:self.ctx]];
                    [filteredContent setPredicate:
                     [NSPredicate predicateWithFormat:@"text CONTAINS[cd] %@ && item.storeAssortmentBit = YES",
                      [NSString stringWithString:self.searchDisplayController.searchBar.text]]];
                    //          [self.filteredListContent.fetchRequest setRelationshipKeyPathsForPrefetching:[NSArray arrayWithObject:@"item"]];
                    [filteredContent setSortDescriptors:[NSArray arrayWithObjects:
                                                         [NSSortDescriptor sortDescriptorWithKey:@"item.productGroup" ascending:YES],
                                                         [NSSortDescriptor sortDescriptorWithKey:@"text"              ascending:YES],
                                                         [NSSortDescriptor sortDescriptorWithKey:@"itemID"            ascending:YES], nil]];
                    break;
                case 3:
                {
                    NSArray  *trademarkholders = nil;
                    NSError  *error		       = nil;
                    NSFetchRequest *subQuery   = [[NSFetchRequest alloc] init];
                    subQuery.entity            = [NSEntityDescription entityForName:@"LocalizedDescription" inManagedObjectContext:self.ctx];
                    subQuery.predicate         = [NSPredicate predicateWithFormat:@"key = %@ && text CONTAINS[cd] %@",
                                                  @"ItemTrademarkHolder", [NSString stringWithString:self.searchDisplayController.searchBar.text]];
                    [subQuery setPropertiesToFetch:[NSArray arrayWithObject:@"code"]];
                    trademarkholders           = [[self.ctx executeFetchRequest:subQuery error:&error] valueForKeyPath:@"code"];
                    [subQuery release];
                    
                    [filteredContent setEntity:[NSEntityDescription entityForName:@"Item" inManagedObjectContext:self.ctx]];
                    [filteredContent setPredicate:
                     [NSPredicate predicateWithFormat:@"trademarkHolder IN %@ && storeAssortmentBit = YES", trademarkholders]
                     ];
                    //          [self.filteredListContent.fetchRequest setRelationshipKeyPathsForPrefetching:[NSArray array]];
                    [filteredContent setSortDescriptors:[NSArray arrayWithObjects:
                                                         [NSSortDescriptor sortDescriptorWithKey:@"productGroup"    ascending:YES],
                                                         [NSSortDescriptor sortDescriptorWithKey:@"trademarkHolder" ascending:YES],
                                                         [NSSortDescriptor sortDescriptorWithKey:@"itemID"          ascending:YES], nil]];
                }
                    break;
            }
        }
        [filteredContent setFetchBatchSize:5];
        NSString *sectionNameKeyPath = @"bestBeforeDays";
        if (self.hasProductGroups) {
            sectionNameKeyPath = @"item.productGroup";
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

- (UIView *)searchResultsCover {
    if (!searchResultsCover) {
        searchResultsCover = [UIView new];
        searchResultsCover.backgroundColor = [UIColor blackColor];
        searchResultsCover.alpha = 0.8;
    }
    return searchResultsCover;
}


#pragma mark - View lifecycle

- (void)toggleSearchBar {
    if (!self.searchDisplayController) {
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
        [searchBar setShowsScopeBar:YES];
        searchBar.tintColor    = [[[UIColor alloc] initWithRed:23.0 / 255 green:48.0 / 255 blue:72.0 / 255 alpha: 0.64] autorelease];
        searchBar.alpha        = 0.8;
        searchBar.keyboardType = UIKeyboardTypeNumberPad;
        searchBar.delegate = self;
        UISearchDisplayController *searchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:[searchBar autorelease] contentsController:self];
        searchDisplayController.delegate = self;
        searchDisplayController.searchResultsDataSource = self;
        searchDisplayController.searchResultsDelegate   = self;
        // The above assigns self.searchDisplayController, but without retaining.
        // Force the read-only property to be set and retained.
        [self forceSetReadOnlyPropertyOfSearchDisplayController:[searchDisplayController autorelease]];
        [self.searchDisplayController setActive:YES animated:YES];
        [self.searchDisplayController.searchBar becomeFirstResponder];
    } else if (!self.searchDisplayController.active) {
        [self.searchDisplayController setActive:YES animated:YES];
        [self.searchDisplayController.searchBar becomeFirstResponder];
    } else {
        [self.searchDisplayController.searchBar resignFirstResponder];
        [self.searchDisplayController setActive:NO animated:YES];
        if ([[[UIDevice currentDevice] systemVersion] compare:@"7.0" options:NSNumericSearch] != NSOrderedAscending) {
            [self forceSetReadOnlyPropertyOfSearchDisplayController:nil];
        }
    }
}

- (UILIBViewSwitcher *) switcher {
    return (UILIBViewSwitcher *) self.view;
}

- (void)prepareTransportItems {
    for (Item *tmpItem in [Item itemsWithPredicate:[NSPredicate predicateWithFormat:@"itemCategoryCode = \"1\""]
                                   sortDescriptors:nil inCtx:self.ctx]) {
        tmpItem.bestBeforeDays = [NSNumber numberWithInt:0]; // 0 = group as "not used at this tourstop"
    }
    [self.ctx saveIfHasChanges];
    for (Transport *tmpTransport in [[self.departure.transport_target_id filteredSetUsingPredicate:
                                      [NSPredicate predicateWithFormat:@"item_id.itemCategoryCode = \"1\""]] allObjects]) {
        NSString *tmpKey = [NSString stringWithFormat:@"%@(+)", tmpTransport.item_id.objectID.URIRepresentation];
        [self.tmpItemQTYs setValue:[NSNumber numberWithInt:([[self.tmpItemQTYs valueForKey:tmpKey] intValue]
                                                            + [tmpTransport.itemQTY intValue])]
                            forKey:tmpKey];
        tmpTransport.item_id.bestBeforeDays = [NSNumber numberWithInt:1]; // 1 = group as "used at this tourstop"
    }
    [self.ctx saveIfHasChanges];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self prepareTransportItems];
    
    self.title = NSLocalizedString(@"TITLE_116", @"Mehrwegverpackungen");
    self.navigationBarColor = self.navigationController.navigationBar.tintColor;
    UIColor *textColor = [UIColor blackColor];
    self.pickerViewToolbarTextField.textColor = textColor;
    UIGestureRecognizer *tapGestureRecogniser = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(itemQTYReset)];
    [self.pickerViewToolbarTextField addGestureRecognizer:tapGestureRecogniser];
    [tapGestureRecogniser release];

    self.pickerViewToolbar.hidden    = YES;
    self.pickerView.hidden           = YES;
    self.pickerView.dataSource       = self;
    self.pickerView.delegate         = self;
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.itemDescriptionLabel.textColor = [[[UIColor alloc] initWithRed:23.0 / 255 green:48.0 / 255 blue:72.0 / 255 alpha: 0.8] autorelease];
    [self.itemDescriptionLabel setFont:[UIFont fontWithName:@"HelveticaNeue-CondensedBold" size:18]];
    
    if ([[self.filteredListContent.sections objectAtIndex:0] numberOfObjects] > 0) {
        self.navigationItem.hidesBackButton   = YES;
    }
    
    [[self switcher] switchToView:self.tableView withTransitionType:kCATransitionReveal andSubtype:nil];
    [AppStyle customizePickerView:self.pickerView];
}

- (void)switchViews {
    if ([self.scanView superview] != nil) {
        self.pickerViewToolbar.hidden = YES;
        self.pickerView.hidden        = YES;
    }
    
    UIView *viewToShow = self.scanView;
    if ([self.scanView superview] != nil) {
        [self.tableView reloadData];
        viewToShow = self.tableView;
        [viewToShow setNeedsDisplay];
        [self.navigationController setToolbarHidden:NO animated:YES];
    } else {
        [self.searchDisplayController.searchBar resignFirstResponder];
        [self.navigationController setToolbarHidden:YES];
    }
    
    [[self switcher] switchViewFadeAnimationToView:viewToShow];

    
    if ([self.scanView superview] != nil) {
        self.navigationItem.rightBarButtonItem  =
        [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch
                                                       target:self
                                                       action:@selector(switchViews)] autorelease];
        if ([[[UIDevice currentDevice] systemVersion] compare:@"7.0" options:NSNumericSearch] != NSOrderedAscending) {
            [self forceSetReadOnlyPropertyOfSearchDisplayController:nil];
        }
        if (self.itemIndexPath.row % 2 == 1) {
            self.navigationController.navigationBar.tintColor =
            [[[UIColor alloc] initWithRed:232.0 / 255 green:31.0 / 255 blue:23.0 / 255 alpha: 0.9] autorelease];
        } else {
            self.navigationController.navigationBar.tintColor = self.navigationBarColor;
        }
    } else {
        self.navigationController.navigationBar.tintColor = self.navigationBarColor;
        if (self.tmpItemQTY != 0) {
            [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
        }
    }
}

- (IBAction)showPickerView {
    if (self.item) {
        self.navigationItem.hidesBackButton    = YES;
        self.navigationItem.rightBarButtonItem = nil;
        if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"HermesApp_SYSVAL_RUN_withTransportItemQTYInput_MODE"] isEqualToString:@"PICKERVIEW"]) {
            [self.pickerView reloadAllComponents];
            self.pickerViewToolbar.hidden = NO;
            self.pickerView.hidden        = NO;
            if (self.pickerView.numberOfComponents == 7) {
                [self.pickerView selectRow:((self.tmpItemQTY % 1000000) / 100000) + 500 inComponent:0 animated:YES];
                [self.pickerView selectRow:((self.tmpItemQTY %  100000) /  10000) + 500 inComponent:1 animated:YES];
                [self.pickerView selectRow:((self.tmpItemQTY %   10000) /   1000) + 500 inComponent:2 animated:YES];
                [self.pickerView selectRow:0                                            inComponent:3 animated:NO];
                [self.pickerView selectRow:((self.tmpItemQTY %    1000) /    100) + 500 inComponent:4 animated:YES];
                [self.pickerView selectRow:((self.tmpItemQTY %     100) /     10) + 500 inComponent:5 animated:YES];
                [self.pickerView selectRow: (self.tmpItemQTY %      10)           + 500 inComponent:6 animated:YES];
            } else {
                [self.pickerView selectRow:((self.tmpItemQTY %   10000) /   1000) + 500 inComponent:0 animated:YES];
                [self.pickerView selectRow:((self.tmpItemQTY %    1000) /    100) + 500 inComponent:1 animated:YES];
                [self.pickerView selectRow:((self.tmpItemQTY %     100) /     10) + 500 inComponent:2 animated:YES];
                [self.pickerView selectRow: (self.tmpItemQTY %      10)           + 500 inComponent:3 animated:YES];
            }
            self.pickerViewToolbarTextField.text        = nil;
            self.pickerViewToolbarTextField.placeholder = nil;
        } else {
            // this looks better when inputAccView is overlaying the pickerViewToolbar
            self.pickerViewToolbar.hidden = NO;
            self.pickerViewToolbarTextField.text               = nil;
            self.pickerViewToolbarTextField.placeholder        = [NSString stringWithFormat:@"%i", self.tmpItemQTY];
            [self.pickerViewToolbarTextField addTarget:self action:@selector(pickerViewToolbarTextField:) forControlEvents:UIControlEventEditingChanged];
            [self.pickerViewToolbarTextField becomeFirstResponder];
        }
    }
}

- (IBAction)itemQTYReset {
    self.pickerViewToolbarTextField.placeholder = [NSString stringWithFormat:@"%i", self.tmpItemQTY];
    self.pickerViewToolbarTextField.text = nil;
}

- (IBAction)itemQTYShouldReturn {
    if (self.pickerView.hidden && self.pickerViewToolbarTextField.text.length > 0) {
        self.tmpItemQTY = [self.pickerViewToolbarTextField.text intValue];
        self.pickerViewToolbarTextField.text = nil;
    }
    if (self.tmpItemQTY != 0) {
        if (self.itemIndexPath.row % 2 == 1) {
            self.tmpItemQTY = 0 - self.tmpItemQTY;
            [self.tmpItemQTYs setValue:[NSNumber numberWithInt:self.tmpItemQTY] forKey:[NSString stringWithFormat:@"%@(-)",
                                                                                        self.item.objectID.URIRepresentation]];
        } else {
            [self.tmpItemQTYs setValue:[NSNumber numberWithInt:self.tmpItemQTY] forKey:[NSString stringWithFormat:@"%@(+)",
                                                                                        self.item.objectID.URIRepresentation]];
        }
    } else {
        if (self.itemIndexPath.row % 2 == 1) {
            [self.tmpItemQTYs setValue:nil forKey:[NSString stringWithFormat:@"%@(-)",
                                                   self.item.objectID.URIRepresentation]];
        } else {
            [self.tmpItemQTYs setValue:nil forKey:[NSString stringWithFormat:@"%@(+)",
                                                   self.item.objectID.URIRepresentation]];
        }
    }
    if ([[self.tmpItemQTYs valueForKey:[NSString stringWithFormat:@"%@(-)",
                                        self.item.objectID.URIRepresentation]] integerValue] == 0
         &&
        [[self.tmpItemQTYs valueForKey:[NSString stringWithFormat:@"%@(+)",
                                        self.item.objectID.URIRepresentation]] integerValue] == 0) {
        self.item.bestBeforeDays = [NSNumber numberWithInt:0]; // 0 = group as "not used at this tourstop"
    } else {
        self.item.bestBeforeDays = [NSNumber numberWithInt:1]; // 1 = group as "used at this tourstop"
    }
    [self.ctx saveIfHasChanges];
    [self.pickerViewToolbarTextField removeTarget:self action:@selector(pickerViewToolbarTextField:) forControlEvents:UIControlEventEditingChanged];
    [self.pickerViewToolbarTextField resignFirstResponder];
    self.pickerViewToolbar.hidden          = YES;
    self.pickerView.hidden                 = YES;
    [self switchViews];
}

- (void)pickerViewToolbarTextField:(id)sender {
    if (self.pickerViewToolbarTextField.text.length > 4) {
        self.pickerViewToolbarTextField.text = [self.pickerViewToolbarTextField.text substringToIndex:4];
    }
}

- (void)checkItemData:(Item *)tmpItem {
    if (tmpItem) {
        self.item                       = tmpItem;
        self.itemDescriptionLabel.text  = [Item localDescriptionTextForItem:tmpItem];
        if (self.itemIndexPath.row % 2 == 1) {
            self.tmpItemQTY = [[self.tmpItemQTYs valueForKey:[NSString stringWithFormat:@"%@(-)", self.item.objectID.URIRepresentation]] intValue];
        } else {
            self.tmpItemQTY = [[self.tmpItemQTYs valueForKey:[NSString stringWithFormat:@"%@(+)", self.item.objectID.URIRepresentation]] intValue];
        }
        self.hasConfirmedQTYWarning = NO;
    }
}

- (void)checkBarcodeData:(NSString *)scanInput {
    /*
    Item *tmpItem = [ItemCode itemForCode:scanInput inCtx:self.ctx];
    if (tmpItem) {
        [self checkItemData:tmpItem];
    } else {
        [DSPF_Error messageTitle:scanInput
					 messageText:NSLocalizedString(@"ERROR_MESSAGE__004", @"ACHTUNG: Keine Artikel-Daten für diesen Barcode gefunden.")
                        delegate:nil];
    }
    */
}

- (void)storeTransportItemData {
    NSArray *tmpTransportItems = [self.filteredListContent fetchedObjects];
    if (tmpTransportItems.count > 0) {
        self.currentTransportGroupTask = [NSString stringWithFormat:@"RP-RCPT:%@-%@",
                                          self.departure.departure_id, [[[[NSDateFormatter localizedStringFromDate:[NSDate date]
                                                                                                         dateStyle:NSDateFormatterLongStyle
                                                                                                         timeStyle:NSDateFormatterLongStyle]
                                                                        stringByReplacingOccurrencesOfString:@" " withString:@""]
                                                                        stringByReplacingOccurrencesOfString:@"." withString:@""]
                                                                        stringByReplacingOccurrencesOfString:@":" withString:@""]];
        for (Item *tmpItem in tmpTransportItems) {
            NSNumber *tmpItemQTY_put = [self.tmpItemQTYs valueForKey:[NSString stringWithFormat:@"%@(+)", tmpItem.objectID.URIRepresentation]];
            if ([tmpItemQTY_put intValue] != 0) {
                NSString *code = [NSString stringWithFormat:@"RP-PUT:%@;%@", self.departure.departure_id, tmpItem.itemID];
                NSMutableDictionary *currentTransport = [Transport dictionaryWithCode:code traceType:TraceTypeValueUnload
                                                                        fromDeparture:self.departure toLocation:self.departure.location_id];
                
                [currentTransport setValue:self.currentTransportGroupTask                                        forKey:@"task"];
                [currentTransport setObject:tmpItem.itemID                                                       forKey:@"itemID"];
                [currentTransport setObject:tmpItemQTY_put                                                       forKey:@"quantity"];
                [currentTransport setObject:[NSNumber numberWithBool:YES]                                        forKey:@"isPallet"];
                [Transport transportWithDictionaryData:currentTransport inCtx:self.ctx];
            }
            NSNumber *tmpItemQTY_get = [self.tmpItemQTYs valueForKey:[NSString stringWithFormat:@"%@(-)", tmpItem.objectID.URIRepresentation]];
            if ([tmpItemQTY_get intValue] != 0) {
                NSString *code = [NSString stringWithFormat:@"RP-GET:%@;%@", self.departure.departure_id, tmpItem.itemID];
                NSMutableDictionary *currentTransport = [Transport dictionaryWithCode:code traceType:TraceTypeValueLoad
                                                                        fromDeparture:self.departure toLocation:self.departure.location_id];
                
                [currentTransport setValue:self.currentTransportGroupTask                                        forKey:@"task"];
                [currentTransport setObject:tmpItem.itemID                                                       forKey:@"itemID"];
                [currentTransport setObject:tmpItemQTY_get                                                       forKey:@"quantity"];
                [currentTransport setObject:[NSNumber numberWithBool:YES]                                        forKey:@"isPallet"];
                [Transport transportWithDictionaryData:currentTransport inCtx:self.ctx];
            }
        }
        for (Transport *tmpTransport in [[self.departure.transport_target_id filteredSetUsingPredicate:
                                          [NSPredicate predicateWithFormat:@"item_id.itemCategoryCode = \"1\""]] allObjects]) {
            [self.ctx deleteObject:tmpTransport];
        }
        [self.ctx saveIfHasChanges];
        if (PFBrandingSupported(BrandingCCC_Group, nil)) {
            DSPF_NameForSignature *dspf_NameForSignature = [[[DSPF_NameForSignature alloc] initWithNibName:@"DSPF_NameForSignature" bundle:nil] autorelease];
            dspf_NameForSignature.departure = self.departure;
            dspf_NameForSignature.currentTransportGroup = [Transport_Group transport_GroupWithTask:self.currentTransportGroupTask
                                                                            inCtx:self.ctx];
            dspf_NameForSignature.isReturnablePackaging = YES;
            dspf_NameForSignature.delegate              = self;
            [self.navigationController pushViewController:dspf_NameForSignature animated:YES];
        } else {
            [SVR_SyncDataManager triggerSendingTraceLogDataOnlyWithUserInfo:nil];
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (!self.didItOnce) {
        self.toolbarHiddenBackup = self.navigationController.toolbarHidden;
        self.didItOnce = YES;
    }
    self.navigationController.toolbarHidden = NO;
    self.toolbarItems = [NSArray arrayWithObjects:
                         [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                        target:self
                                                                        action:nil] autorelease],
                         [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash
                                                                        target:self
                                                                        action:@selector(confirmDelete)] autorelease],
                         [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                        target:self
                                                                        action:nil] autorelease],
//                       [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch
//                                                          target:self
//                                                          action:@selector(toggleSearchBar)] autorelease],
                         [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                        target:self
                                                                        action:nil] autorelease],
                         [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemOrganize
                                                                        target:self
                                                                        action:@selector(confirmTransportItems)] autorelease],
                         [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                        target:self
                                                                        action:nil] autorelease],
                         nil];
    
    [AppStyle customizeToolbar:self.navigationController.toolbar];
    
    for (UIBarButtonItem *b in self.toolbarItems) {
        if (b.action) b.style = UIBarButtonItemStyleBordered;
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.locationName.text = self.departure.location_id.location_name;
    self.streetAddress.text = self.departure.location_id.street;
    self.zipCode.text = self.departure.location_id.zip;
    self.city.text = self.departure.location_id.city;
}

- (void)viewWillDisappear:(BOOL)animated {
	if ([self.navigationController.viewControllers indexOfObject:self]==NSNotFound) {
		// back button was pressed.
		// We know this is true because self is no longer in the navigation stack.
        if (self.searchResultsCover.window) {
            [self.searchResultsCover removeFromSuperview];
        }
        if (self.searchDisplayController.active) {
            self.searchDisplayController.searchBar.text = @"";
            [self.searchDisplayController.searchBar resignFirstResponder];
            [self.searchDisplayController setActive:NO animated:YES];
            [self forceSetReadOnlyPropertyOfSearchDisplayController:nil];
        }
	}
    if (self.toolbarHiddenBackup) {
        [self.navigationController setToolbarHidden:YES animated:YES];
    }
    for (UIGestureRecognizer *gestureRecognizer in self.navigationController.navigationBar.gestureRecognizers) {
        [self.navigationController.navigationBar removeGestureRecognizer:gestureRecognizer];
    }
    [super viewWillDisappear:animated];
}

- (void)confirmDelete {
    self.navigationController.toolbarHidden = YES;
    [[DSPF_Confirm question:[NSString stringWithFormat:NSLocalizedString(@"TITLE__062", @"%@: %i Artikel\n"), self.title, self.tmpItemQTYs.allKeys.count]
                       item:@"confirmDelete"
             buttonTitleYES:NSLocalizedString(@"TITLE__023", @"Löschen")
              buttonTitleNO:NSLocalizedString(@"TITLE__018", @"Abbrechen")
                 showInView:self.view] setDelegate:self];
}

- (void)confirmTransportItems {
    self.navigationController.toolbarHidden = YES;
    [[DSPF_Confirm question:[NSString stringWithFormat:NSLocalizedString(@"TITLE__062", @"%@: %i Artikel\n"), self.title, self.tmpItemQTYs.allKeys.count]
                       item:@"confirmTransportItems"
             buttonTitleYES:NSLocalizedString(@"TITLE_010", @"Abschliessen")
              buttonTitleNO:NSLocalizedString(@"TITLE__018", @"Abbrechen")
                 showInView:self.view] setDelegate:self];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView {
    // Return the number of sections.
    if (aTableView == self.searchDisplayController.searchResultsTableView) {
        return self.filteredListContent.sections.count;
    }
    return self.filteredListContent.sections.count;
	// return 1;
}

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section {
    
    if (aTableView == self.searchDisplayController.searchResultsTableView) {
        return ([[self.filteredListContent.sections objectAtIndex:section] numberOfObjects] * 2);
    }
    return ([[self.filteredListContent.sections objectAtIndex:section] numberOfObjects] * 2);
	// return 0;
}

- (CGFloat)tableView:(UITableView *)aTableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0)
        return 48.0;
    return 11.0;
}

- (UIView *)tableView:(UITableView *)aTableView viewForHeaderInSection:(NSInteger)aSection {
    UIView *customView = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
    customView.backgroundColor = [UIColor clearColor];
    CGFloat heightForHeaderInSection = 11.0;
    if (aSection == 0)
        heightForHeaderInSection = 48.0;
    UILabel *headerLabel = [[[UILabel alloc] initWithFrame:
                             CGRectMake(0.0,
                                        0.0,
                                        aTableView.frame.size.width,
                                        heightForHeaderInSection)] autorelease];
    headerLabel.opaque = YES;
    headerLabel.textAlignment = UITextAlignmentCenter;
    headerLabel.backgroundColor = self.navigationController.navigationBar.backgroundColor;
    headerLabel.alpha = self.navigationController.navigationBar.alpha;
    if (PFBrandingSupported(BrandingCCC_Group, BrandingViollier, BrandingBiopartner, nil)) {
        headerLabel.font  = [UIFont fontWithName:@"HelveticaNeue-CondensedBold" size:16];
    } else {
        headerLabel.font  = [UIFont fontWithName:@"Helvetica-Bold" size:16];
    }
    headerLabel.textColor = [UIColor whiteColor];
    if (aSection == 0)
        headerLabel.text = self.departure.location_id.location_name;
    else
        headerLabel.text = @"";
    headerLabel.numberOfLines = 2;
    headerLabel.lineBreakMode = UILineBreakModeWordWrap;
    [customView setFrame: CGRectMake(0.0,
                                     0.0,
                                     headerLabel.frame.size.width,
                                     headerLabel.frame.size.height)];
    [customView addSubview:headerLabel];
    return customView;
}

- (id )itemLinkAtIndexPath:(NSIndexPath *)indexPath forTableView:(UITableView *)aTableView {
    // Return the object from this indexPath
    indexPath = [NSIndexPath indexPathForRow:(indexPath.row / 2) inSection:indexPath.section];
    if (aTableView == self.searchDisplayController.searchResultsTableView) {
        return [self.filteredListContent objectAtIndexPath:indexPath];
    }
    return [self.filteredListContent objectAtIndexPath:indexPath];
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    id cell = [aTableView dequeueReusableCellWithIdentifier:@"DSPF_TransportItemList"];
    if (cell == nil) {
            cell = [[[UITableViewCell alloc]
                     initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"DSPF_TransportItemList"] autorelease];
    }
    // Configure the cell...
    Item *cellItem = [self itemLinkAtIndexPath:indexPath forTableView:(UITableView *)aTableView];
    ((UITableViewCell *)cell).textLabel.text = [NSString stringWithFormat:@"%@\n(%@)", cellItem.itemID,
                                                [[Item localDescriptionTextForItem:cellItem]
                                                 stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
    NSNumber *cellItemQTY = nil;
    if (indexPath.row % 2 == 1) {
        cellItemQTY = [self.tmpItemQTYs valueForKey:[NSString stringWithFormat:@"%@(-)", cellItem.objectID.URIRepresentation]];
    } else {
        cellItemQTY = [self.tmpItemQTYs valueForKey:[NSString stringWithFormat:@"%@(+)", cellItem.objectID.URIRepresentation]];
    }
    if (cellItemQTY) {
        ((UITableViewCell *)cell).detailTextLabel.text = [NSString stringWithFormat:@"%i", [cellItemQTY intValue]];
    } else {
        ((UITableViewCell *)cell).detailTextLabel.text = @"";
    }
    CGRect bounds = CGRectMake(0.0, 0.0, 57, 57);
    UIGraphicsBeginImageContext(bounds.size);
    if (indexPath.row % 2 == 1) {
        UIImage *noImage = nil;
        [noImage drawInRect:bounds];
    } else {
        [[UIImage imageWithContentsOfFile:[NSHomeDirectory()stringByAppendingPathComponent:
                                           [NSString stringWithFormat:@"Library/ItemImages/%@.png", cellItem.itemID]]] drawInRect:bounds];
    }
    UIImage *tmpThumbnail = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    ((UITableViewCell *)cell).imageView.image = tmpThumbnail;
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.textLabel.numberOfLines = 2;
    cell.textLabel.lineBreakMode = UILineBreakModeWordWrap;
    cell.textLabel.font = [((UITableViewCell *)cell).textLabel.font fontWithSize:15];
    if (indexPath.row % 2 == 1) {
        cell.textLabel.textColor = [[[UIColor alloc] initWithRed:232.0 / 255 green:31.0 / 255 blue:23.0 / 255 alpha: 0.9] autorelease];
    } else {
        cell.textLabel.textColor = [UIColor blackColor];
    }
    NSString *ellipsis = [NSString stringWithFormat:@"%C", (unichar)0x2026];
    while ([cell.textLabel.text sizeWithFont:cell.textLabel.font].width > cell.frame.size.width * 0.618)
    {
        cell.textLabel.text = [cell.textLabel.text stringByReplacingOccurrencesOfString:ellipsis withString:[NSString string]];
        int middle = ([cell.textLabel.text length] / 2) + 1;
        if (middle == 1) break;
        cell.textLabel.text = [[[cell.textLabel.text substringToIndex:middle] stringByAppendingString:ellipsis]
                               stringByAppendingString:[cell.textLabel.text substringFromIndex:middle + 1]];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 55;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // [self toggleSearchBar];
    self.item = (Item *)[self itemLinkAtIndexPath:indexPath forTableView:aTableView];
    self.itemIndexPath = indexPath;
    [self switchViews];
    [self checkItemData:self.item];
    [self showPickerView];
}


#pragma mark - UISearchDisplayController Delegate Methods

- (void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller {
    self.navigationController.toolbarHidden = YES;
    self.navigationItem.rightBarButtonItem  = nil;
    self.tableView.tableHeaderView = controller.searchBar;
    [self.filteredListContent.fetchRequest setPredicate:[NSPredicate predicateWithValue:NO]];
    NSError *error = nil;
    if (![self.filteredListContent performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
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
    if (controller.searchBar.selectedScopeButtonIndex < 2) {
        self.filteredListContent.delegate = nil;
        self.filteredListContent = nil;
        dispatch_async(dispatch_get_main_queue(), ^{
            [controller.searchResultsTableView setContentOffset:CGPointZero animated:NO];
        });
        return YES;
    }
    return NO;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption {
    self.filteredListContent.delegate = nil;
    self.filteredListContent = nil;
    dispatch_async(dispatch_get_main_queue(), ^{
        [controller.searchResultsTableView setContentOffset:CGPointZero animated:NO];
    });
    return YES; // Return YES to cause the search result table view to be reloaded.
}

- (void)searchDisplayController:(UISearchDisplayController *)controller willUnloadSearchResultsTableView:(UITableView *)tableView {
    // search is done so get rid of the search filteredListContent and reclaim memory
    self.filteredListContent.delegate = nil;
    self.filteredListContent = nil;
}

- (void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller {
    [self switchViews];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if (searchBar.selectedScopeButtonIndex >= 2 && searchText.length > 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!self.searchResultsCover.window) {
                self.searchResultsCover.frame = CGRectMake(self.tableView.frame.origin.x,
                                                           self.tableView.frame.origin.y
                                                           + self.searchDisplayController.searchBar.frame.size.height,
                                                           self.tableView.frame.size.width,
                                                           self.tableView.frame.size.height
                                                           - self.searchDisplayController.searchBar.bounds.size.height);
                self.searchResultsCover.hidden = NO;
                [self.tableView addSubview:self.searchResultsCover];
                [self.searchDisplayController.searchResultsTableView setHidden:YES];
            } else {
                if ([[[UIDevice currentDevice] systemVersion] compare:@"7.0" options:NSNumericSearch] != NSOrderedAscending) {
                    [self.searchDisplayController.searchResultsTableView setHidden:YES];
                }
            }
        });
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.searchResultsCover.window) {
                if ([[[UIDevice currentDevice] systemVersion] compare:@"7.0" options:NSNumericSearch] != NSOrderedAscending &&
                    searchBar.selectedScopeButtonIndex >= 2 && searchText.length == 0) {
                    [self.searchDisplayController.searchResultsTableView setHidden:YES];
                }  else {
                    [self.searchResultsCover removeFromSuperview];
                }
            }
            if ([[[UIDevice currentDevice] systemVersion] compare:@"7.0" options:NSNumericSearch] == NSOrderedAscending) {
                [self.searchDisplayController.searchResultsTableView setHidden:NO];
            }
        });
    }
}

- (void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.searchResultsCover.window) {
            if ([[[UIDevice currentDevice] systemVersion] compare:@"7.0" options:NSNumericSearch] != NSOrderedAscending) {
                [self.searchDisplayController.searchResultsTableView setHidden:YES];
            }  else {
                [self.searchResultsCover removeFromSuperview];
            }
        }
    });
    searchBar.text = @"";
    [searchBar resignFirstResponder];
    if (selectedScope < 2) {
        searchBar.keyboardType = UIKeyboardTypeNumberPad;
    } else {
        searchBar.keyboardType = UIKeyboardTypeDefault;
    }
    [searchBar becomeFirstResponder];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    if (searchBar.selectedScopeButtonIndex >= 2 && searchBar.text.length > 0) {
        self.filteredListContent.delegate = nil;
        self.filteredListContent = nil;
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.searchResultsCover.window) {
                [self.searchResultsCover removeFromSuperview];
            }
            [self.searchDisplayController.searchResultsTableView setHidden:NO];
            [self.searchDisplayController.searchResultsTableView reloadData];
            [self.searchDisplayController.searchResultsTableView setContentOffset:CGPointZero animated:NO];
        });
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)aSearchBar {
    aSearchBar.text = @"";
}


#pragma mark - - Fetched results controller delegate

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
    } else {
        [self.tableView endUpdates];
    }
}

#pragma mark - PickerView

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    if ([self.item.orderUnitCode isEqualToString:@"KG"] ||
        [self.item.orderUnitCode isEqualToString:@"LT"]) {
        return 7;
    }
    return 4;
}

- (void)pickerView:(UIPickerView *)aPickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if (aPickerView.numberOfComponents == 7) {
        self.tmpItemQTY = ([self.pickerView selectedRowInComponent:0] % 10) * 100000
        + ([self.pickerView selectedRowInComponent:1] % 10) *  10000
        + ([self.pickerView selectedRowInComponent:2] % 10) *   1000
        //                         [self.pickerView selectedRowInComponent:3] = ","
        + ([self.pickerView selectedRowInComponent:4] % 10) *    100
        + ([self.pickerView selectedRowInComponent:5] % 10) *     10
        + ([self.pickerView selectedRowInComponent:6] % 10);
    } else {
        self.tmpItemQTY = ([self.pickerView selectedRowInComponent:0] % 10) *   1000
        + ([self.pickerView selectedRowInComponent:1] % 10) *    100
        + ([self.pickerView selectedRowInComponent:2] % 10) *     10
        + ([self.pickerView selectedRowInComponent:3] % 10);
    }
}

- (NSInteger)pickerView:(UIPickerView *)aPickerView numberOfRowsInComponent:(NSInteger)component {
    if (aPickerView.numberOfComponents == 7 && component == 3) {
        return 1;
    }
    return 1000;
    //    return NSIntegerMax;
}

- (UIView *)pickerView:(UIPickerView *)aPickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
	UILabel *label = (id)view;
    if (!label || ([label class] != [UILabel class])) {
        label = [[[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, [aPickerView rowSizeForComponent:component].width, [aPickerView rowSizeForComponent:component].height)] autorelease];
    }
    [AppStyle customizePickerViewLabel:label];
    
    if (aPickerView.numberOfComponents == 7) {
        if (component  == 3) {
            label.text = [NSString stringWithFormat:@"%@", [[NSLocale currentLocale] objectForKey:NSLocaleDecimalSeparator]];
        } else {
            label.text = [NSString stringWithFormat:@"%d", row % 10]; //[NSString stringWithFormat:@"%i", row];
        }
        label.font = [UIFont fontWithName:@"Helvetica-Bold" size:24];
    } else {
        label.text = [NSString stringWithFormat:@"%d", row % 10]; //[NSString stringWithFormat:@"%i", row];
        label.font = [UIFont fontWithName:@"Helvetica-Bold" size:28];
    }
    label.textAlignment   = UITextAlignmentCenter;
	return label;
}

#pragma mark - DSPF_Warning delegate

- (void) dspf_Warning:(DSPF_Warning *)sender didConfirmMessageTitle:(NSString *)messageTitle item:(id )anItem withButtonTitle:(NSString *)buttonTitle buttonIndex:(NSInteger) buttonIndex {
	if ([[sender alertView] cancelButtonIndex] != buttonIndex) {
		if ([(NSString *)anItem isEqualToString:@"confirmQTYWarning"]) {
            self.hasConfirmedQTYWarning = YES;
		}
	}
}

#pragma mark - DSPF_Confirm delegate

- (void) dspf_Confirm:(DSPF_Confirm *)sender didConfirmQuestion:(NSString *)question item:(NSObject *)aItem withButtonTitle:(NSString *)buttonTitle {
    self.navigationController.toolbarHidden = NO;
	if (![buttonTitle isEqualToString:NSLocalizedString(@"TITLE__018", @"Abbrechen")]) {
		if ([(NSString *)aItem isEqualToString:@"confirmDelete"]) {
            [self.tmpItemQTYs removeAllObjects];
            [self prepareTransportItems];
            [self.tableView reloadData];
		} else if ([(NSString *)aItem isEqualToString:@"confirmTransportItems"]) {
            if ([buttonTitle isEqualToString:NSLocalizedString(@"TITLE_010", @"Abschliessen")])
                [self storeTransportItemData];
		}
	}
}

#pragma mark - Signature drawing delegate

- (void) dspf_SignatureForName:(DSPF_SignatureForName *)sender didReturnSignature:(UIImage *)aSignature forName:(NSString *)aName {
    DSPF_Activity *showActivity = [[DSPF_Activity messageTitle:NSLocalizedString(@"TITLE_032", @"Unterschrift speichern") messageText:NSLocalizedString(@"MESSAGE_002", @"Bitte warten.") delegate:self] retain];
    [DPHUtilities waitForAlertToShow:0.236f];
    // Pfad bzw. Daten und Namen fürs Speichern vorbereiten
    //  NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSData   *screenShot_PNG;
    //  NSString *screenShot_PNG_name;
    // UIImage als PNG konvertieren und im Dokumentenverzeichnis speichern
    screenShot_PNG      = UIImagePNGRepresentation(aSignature);
    //  screenShot_PNG_name = [NSString stringWithFormat:@"%@.png", @"ScreenShot"];
    //  [screenShot_PNG writeToFile:[documentsDirectory stringByAppendingPathComponent:screenShot_PNG_name] atomically:YES];
    // DELIVERYSIGNATURE
    NSString *code = [NSDateFormatter localizedStringFromDate:[NSDate date] dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterLongStyle];
    NSMutableDictionary *currentTransport = [Transport dictionaryWithCode:code traceType:TraceTypeValueDeliverySignature
                                                            fromDeparture:self.departure toLocation:self.departure.location_id];
    [currentTransport setValue:self.currentTransportGroupTask                                            forKey:@"task"];
    [currentTransport setValue:screenShot_PNG                                                            forKey:@"receipt_data"];
    [currentTransport setValue:aName                                                                     forKey:@"receipt_text"];
    [Transport transportWithDictionaryData:currentTransport inCtx:self.ctx];
    [self.ctx saveIfHasChanges];
    [showActivity closeActivityInfo];
    [showActivity release];
    [SVR_SyncDataManager triggerSendingTraceLogDataOnlyWithUserInfo:nil];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Memory management

- (void)viewDidUnload {
    [super viewDidUnload];
    
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
	[[NSUserDefaults standardUserDefaults] synchronize];
	self.tableView                         = nil;
	self.scanView                          = nil;
    self.pickerViewToolbarDone             = nil;
    self.pickerViewToolbarTextField        = nil;
    self.pickerViewToolbarText             = nil;
    self.pickerViewToolbar                 = nil;
    self.pickerView                        = nil;
    self.itemDescriptionLabel              = nil;
    self.city                              = nil;
    self.zipCode                           = nil;
    self.streetAddress                     = nil;
    self.locationName                      = nil;
}

- (void)dealloc {
    [searchResultsCover                  release];
    [filteredListContent                 release];
	[ctx                release];
    [currencyFormatter                   release];
    [itemDescriptionLabel                release];
    [navigationBarColor                  release];
    [currentTransportGroupTask           release];
    [itemIndexPath                       release];
    [item                                release];
    [city                                release];
    [zipCode                             release];
    [streetAddress                       release];
    [locationName                        release];
    [tourTask                            release];
    [departure                           release];
    [tmpItemQTYs                         release];
    [pickerView                          release];
    [pickerViewToolbarDone               release];
    [pickerViewToolbarTextField          release];
    [pickerViewToolbarText               release];
    [pickerViewToolbar                   release];
	[tableView                           release];
	[scanView                            release];
    [super dealloc];
}

#pragma mark - 

+ (NSPredicate *) predicateForShownTransportItems {
    return [NSPredicate predicateWithFormat:@"itemCategoryCode == \"1\""];
}

@end