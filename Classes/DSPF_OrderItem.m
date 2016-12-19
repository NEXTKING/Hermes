//
//  DSPF_OrderItem.m
//  Hermes
//
//  Created by Lutz  Thalmann on 07.12.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "HermesAppDelegate.h"
#import "DSPF_OrderItem.h"
#import "DSPF_Order.h"
#import "DSPF_ItemTableViewCell.h"
#import "DSPF_ItemTableViewCell_biopartner.h"
#import "DSPF_ItemDetail.h"
#import "DSPF_Activity.h"
#import "DSPF_Error.h"

#import "ItemDescription.h"
#import "ItemCode.h"
#import "User.h"
#import "ArchiveOrderHead.h"
#import "ArchiveOrderLine.h"
#import "TemplateOrderHead.h"
#import "TemplateOrderLine.h"
#import "LocalizedDescription.h"

@implementation DSPF_OrderItem

@synthesize scanView;
@synthesize tableView;
@synthesize textView;
@synthesize artikelOrderItemLabel;
@synthesize preisOrderItemLabel;
@synthesize historieOrderItemLabel;
@synthesize pickerViewToolbar;
@synthesize pickerViewToolbarText;
@synthesize pickerViewToolbarTextField;
@synthesize pickerViewToolbarDone;
@synthesize pickerView;
@synthesize tmpItemQTY;
@synthesize itemDescriptionLabel;
@synthesize itemIDLabel;
@synthesize itemPriceLabel;
@synthesize itemOrderLineLabel;
@synthesize currentQTY;
@synthesize hasConfirmedQTYWarning;
@synthesize item;
@synthesize dataHeaderInfo;
@synthesize dataTask;
@synthesize currencyFormatter;
@synthesize hasTrademarkHolders;
@synthesize hasProductGroups;
@synthesize ctx;
@synthesize filteredListContent;
@synthesize searchResultsCover;
@synthesize pushedFromViewController;
@synthesize hasMinusSign;
@synthesize hasPlusSignColor;


#pragma mark - Initialization

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
        if (!self.searchDisplayController.searchBar.text ||
            self.searchDisplayController.searchBar.text.length == 0) {
            [filteredContent setEntity:[NSEntityDescription entityForName:@"Item" inManagedObjectContext:self.ctx]];
            [filteredContent setPredicate:[NSPredicate predicateWithValue:NO]];
            [filteredContent setSortDescriptors:[NSArray arrayWithObjects:
                                                 [NSSortDescriptor sortDescriptorWithKey:@"productGroup" ascending:YES],
                                                 [NSSortDescriptor sortDescriptorWithKey:@"itemID"       ascending:YES], nil]];
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
        [filteredContent setFetchBatchSize:12];
        NSString *sectionNameKeyPath = nil;
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

- (void)dismissItemDetail {
    [self.navigationController dismissModalViewControllerAnimated:YES];
}

- (void)tapToInfo {
    if (PFBrandingSupported(BrandingBiopartner, nil)) {
        if (self.item) {
            DSPF_ItemDetail *dspf_ItemDetail = [[DSPF_ItemDetail alloc] initWithNibName:@"DSPF_ItemDetail" bundle:nil];
            dspf_ItemDetail.title            = NSLocalizedString(@"TITLE__065", @"Artikel-Details");
            dspf_ItemDetail.item             = self.item;
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

- (void)setModeColor {
    if (self.hasMinusSign) {
        UIColor *hasMinusSignColor    = [[[UIColor alloc] initWithRed:232.0 / 255 green:31.0 / 255 blue:23.0 / 255 alpha: 0.9] autorelease];
        float h, s, b, a;
        if ([hasMinusSignColor getHue:&h saturation:&s brightness:&b alpha:&a])
            hasMinusSignColor         = [UIColor colorWithHue:h saturation:(s * 0.90) brightness:MIN(b * 1.5, 1.0) alpha:a];
        if (YES) {
            [self.navigationController.navigationBar setTintColor:hasMinusSignColor];
        } else {
            self.scanView.backgroundColor = hasMinusSignColor;
            self.textView.backgroundColor = hasMinusSignColor;
            self.view.backgroundColor     = hasMinusSignColor;
        }
    } else {
        if (YES) {
            [self.navigationController.navigationBar setTintColor:self.hasPlusSignColor];
        } else {
            self.scanView.backgroundColor = self.hasPlusSignColor;
            self.textView.backgroundColor = self.hasPlusSignColor;
            self.view.backgroundColor     = self.hasPlusSignColor;
        }
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"connectScanDevice" 
                                                        object:self 
                                                      userInfo:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(didReturnBarcode:) 
                                                 name:@"barcodeData" 
                                               object:nil];
	self.artikelOrderItemLabel.text =        NSLocalizedString(@"MESSAGE__023", @"Artikel:");
    if (PFBrandingSupported(BrandingBiopartner, nil)) { 
        self.preisOrderItemLabel.text =          @"EP:";
    } else {
        self.preisOrderItemLabel.text =          NSLocalizedString(@"MESSAGE__021", @"Preis:");
    }
    self.historieOrderItemLabel.text =       NSLocalizedString(@"MESSAGE__024", @"Historie:");
	if (!self.tableView && [self.view isKindOfClass:[UITableView class]]) {
        self.tableView = (UITableView *)(self.view);
    }
	self.view = self.textView;
    UITapGestureRecognizer *tapToInfo = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapToInfo)] autorelease];
    [tapToInfo setNumberOfTapsRequired :2];
    [tapToInfo setNumberOfTouchesRequired:1];
	[self.scanView		addGestureRecognizer:tapToInfo];
	[self.view addSubview:self.tableView];
	[self.view addSubview:self.scanView];
    [self.currentQTY setTitle:@"" forState:UIControlStateNormal];
    self.pickerViewToolbarTextField.textColor = [UIColor blackColor];
//  self.pickerViewToolbar.tintColor = [[[UIColor alloc] initWithRed:23.0 / 255 green:48.0 / 255 blue:72.0 / 255 alpha: 0.512] autorelease];
    self.pickerViewToolbar.tintColor = [[[UIColor alloc] initWithRed:93.0 / 255 green:100.0 / 255 blue:114.0 / 255 alpha: 0.512] autorelease];
    self.pickerViewToolbar.frame     = CGRectMake(self.pickerViewToolbar.frame.origin.x, 
                                                  self.pickerViewToolbar.frame.origin.y    - 9, 
                                                  self.pickerViewToolbar.frame.size.width, 
                                                  self.pickerViewToolbar.frame.size.height + 9);
    self.pickerViewToolbar.hidden    = YES;
    self.pickerView.hidden           = YES;
    self.pickerView.dataSource       = self;
    self.pickerView.delegate         = self;
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    if ([self.dataTask isEqualToString:@"INSERT"]) { 
        self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch
                                                                                                target:self
                                                                                                action:@selector(switchViews)] autorelease];
    }
    self.navigationController.toolbarHidden = YES;
    self.pushedFromViewController           = [self.navigationController.viewControllers objectAtIndex:
                                               (self.navigationController.viewControllers.count - 2)];
    self.itemDescriptionLabel.textColor = [[[UIColor alloc] initWithRed:23.0 / 255 green:48.0 / 255 blue:72.0 / 255 alpha: 0.8] autorelease];
    if (self.item) { 
        self.itemIDLabel.text           = self.item.itemID;
        self.itemDescriptionLabel.text  = [Item localDescriptionTextForItem:self.item];
        if (PFBrandingSupported(BrandingBiopartner, nil)) { 
            self.itemPriceLabel.text        = [NSString stringWithFormat:@"%@ %.2f", 
                                               self.currencyFormatter.currencyCode, [self.item.buyingPrice doubleValue]];
        } else { 
            self.itemPriceLabel.text        = [self.currencyFormatter stringFromNumber:self.item.price];            
        }
        ArchiveOrderLine *previousOrderLine = [ArchiveOrderLine previousOrderLineForItemID:self.item.itemID 
                                                                    inCtx:self.item.managedObjectContext];
        if (previousOrderLine) { 
            NSDecimalNumber *tmpItemQTYdecimal = [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%i", [previousOrderLine.itemQTY intValue]]];
            if ([self.item.orderUnitCode isEqualToString:@"KG"] ||
                [self.item.orderUnitCode isEqualToString:@"LT"]) { 
                tmpItemQTYdecimal = [tmpItemQTYdecimal decimalNumberByDividingBy:[NSDecimalNumber decimalNumberWithString:@"1000"]];
            }
            NSString *dateString = [DPHDateFormatter stringFromDate:previousOrderLine.archiveOrderHead.orderDate
                                                      withDateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterNoStyle locale:de_CH_Locale()];
            self.itemOrderLineLabel.text = [NSString stringWithFormat:@"%@   %5@ %@",
                                            dateString,
                                            tmpItemQTYdecimal, 
                                            self.item.orderUnitCode];
        } else {
            self.itemOrderLineLabel.text = nil;
        }
        if (!self.dataHeaderInfo || [self.dataHeaderInfo isKindOfClass:[ArchiveOrderHead class]]) { 
            if ([self.pushedFromViewController isKindOfClass:[DSPF_Order class]] &&
                [((DSPF_Order *)self.pushedFromViewController).dataHeaderInfo isKindOfClass:[TemplateOrderHead class]]) { 
                ((DSPF_Order *)self.pushedFromViewController).lastChangedLine = 
                [TemplateOrderLine templateLineForItemID:self.item.itemID 
                                              inTemplate:((TemplateOrderHead *)((DSPF_Order *)self.pushedFromViewController).dataHeaderInfo)];
            }
            self.tmpItemQTY = [ArchiveOrderLine currentOrderQTYForItem:self.item.itemID 
                                                inCtx:self.item.managedObjectContext];
        } else if ([self.dataHeaderInfo isKindOfClass:[TemplateOrderHead class]]) { 
            self.tmpItemQTY = [TemplateOrderLine currentTemplateQTYForItem:self.item.itemID 
                                                              templateHead:self.dataHeaderInfo
                                                    inCtx:self.item.managedObjectContext];
        } else {
            self.tmpItemQTY = 0;
        }
        NSDecimalNumber *tmpItemQTYdecimal = [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%i", self.tmpItemQTY]];
        if ([self.item.orderUnitCode isEqualToString:@"KG"] ||
            [self.item.orderUnitCode isEqualToString:@"LT"]) { 
            tmpItemQTYdecimal = [tmpItemQTYdecimal decimalNumberByDividingBy:[NSDecimalNumber decimalNumberWithString:@"1000"]];
        }
        [self.currentQTY setTitle:[NSString stringWithFormat:@"%@", tmpItemQTYdecimal] forState:UIControlStateNormal];
    }
    [self.itemDescriptionLabel setFont:[UIFont fontWithName:@"HelveticaNeue-CondensedBold" size:18]];
    // self.hasPlusSignColor = self.scanView.backgroundColor;
    self.hasPlusSignColor = self.navigationController.navigationBar.tintColor;
    if (!self.hasMinusSign) {
        self.hasMinusSign = (self.tmpItemQTY < 0);
    }
    if (self.hasMinusSign) {
        self.title = NSLocalizedString(@"Rücknahme", @"Rücknahme");
    } else {
        self.title = NSLocalizedString(@"Verkauf", @"Verkauf");
    }
    [self setModeColor];
    
    [AppStyle customizePickerView:self.pickerView];
    [AppStyle customizePickerViewToolbar:self.pickerViewToolbar];
}

- (void)switchViews { 
    if (self.scanView.window) { 
        self.pickerViewToolbar.hidden = YES;
        self.pickerView.hidden        = YES;
        [self toggleSearchBar];
    } 
    self.currentQTY.hidden = !self.item;
	[UIView beginAnimations:nil context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:0.618];
    if (self.scanView.window) {
		[self.scanView  removeFromSuperview];
		[self.tableView reloadData];
		[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:[self view] cache:NO];
    }else{ 
        [self.searchDisplayController.searchBar resignFirstResponder];
		[self.view addSubview:self.scanView];
		[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:[self view] cache:NO];
    }
	[UIView commitAnimations];
    if (self.scanView.window) { 
        [[NSNotificationCenter defaultCenter] postNotificationName:@"connectScanDevice" object:self userInfo:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(didReturnBarcode:) 
                                                     name:@"barcodeData" object:nil];
        self.navigationItem.rightBarButtonItem  = 
        [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch
                                                       target:self
                                                       action:@selector(switchViews)] autorelease];
        if ([[[UIDevice currentDevice] systemVersion] compare:@"7.0" options:NSNumericSearch] != NSOrderedAscending) {
            [self forceSetReadOnlyPropertyOfSearchDisplayController:nil];
        }
    } else {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"barcodeData" object:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"disconnectScanDevice" object:self userInfo:nil];
    }
}

- (IBAction)showPickerView { 
    if (self.item) { 
        [UIView transitionWithView:self.navigationController.view
                          duration:0.618
                           options:UIViewAnimationOptionTransitionCrossDissolve|UIViewAnimationOptionCurveEaseOut 
                        animations:^{
                            self.navigationItem.hidesBackButton    = YES;
                            self.navigationItem.rightBarButtonItem = nil; 
                        } 
                        completion:nil];
        if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"HermesApp_SYSVAL_RUN_withOrderQTYInput_MODE"] isEqualToString:@"PICKERVIEW"]) { 
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
            // show keyboard with type numberpad 
            // the basic inputAccView above the keyboard 
            UIView *inputAccView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 53.0)];
            [inputAccView setBackgroundColor:[UIColor clearColor]]; 
            // the upper left "space"
            UIImageView *leftSpace = [[[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] 
                                                                                                           pathForResource:@"NumberPadLightGray" 
                                                                                                           ofType:@"png"]]] autorelease];
            [leftSpace setFrame:CGRectMake(0.0, 2.0, 104.0, 51.0)];
            // the upper middle button
            UIButton *btnReset = [UIButton buttonWithType:UIButtonTypeCustom];
            [btnReset setFrame:CGRectMake(108.0, 2.0, 104.0, 51.0)];
            [btnReset setBackgroundColor:[UIColor clearColor]];
            [btnReset addTarget:self action:@selector(itemQTYReset) forControlEvents:UIControlEventTouchUpInside];
            // the upper right button
            UIButton *btnDone = [UIButton buttonWithType:UIButtonTypeCustom];
            [btnDone setFrame:CGRectMake(215.0, 2.0, 105.0, 51.0)];
            // the "done" button image from UIBarButtonSystemItem
            UIGraphicsBeginImageContext([[[self.pickerViewToolbarDone valueForKey:@"_view"] layer] bounds].size);
            [[[self.pickerViewToolbarDone valueForKey:@"_view"] layer] renderInContext:UIGraphicsGetCurrentContext()];
            UIImage *doneButtonImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            UIGraphicsBeginImageContext(btnDone.frame.size);
            [[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"NumberPadLightGray" ofType:@"png"]]
             drawInRect:CGRectIntegral(CGRectMake(0.0, 0.0, btnDone.frame.size.width, btnDone.frame.size.height))];
            [doneButtonImage drawAtPoint:CGPointMake(27.0, -3.0)
                               blendMode:kCGBlendModeNormal
                                   alpha:0.78];
            doneButtonImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            [btnDone setBackgroundImage:doneButtonImage forState:UIControlStateNormal];
            [btnDone addTarget:self action:@selector(itemQTYShouldReturn) forControlEvents:UIControlEventTouchUpInside];
            // the complete inputAccView above the keyboard 
            [inputAccView addSubview:btnReset];
            [inputAccView addSubview:leftSpace];
            [inputAccView addSubview:btnDone];
            // this looks better when inputAccView is overlaying the pickerViewToolbar
            [UIView transitionWithView:self.pickerViewToolbar 
                              duration:0.618
                               options:UIViewAnimationOptionTransitionCrossDissolve|UIViewAnimationOptionCurveEaseOut 
                            animations:^{
                                self.pickerViewToolbar.hidden = NO; 
                            } 
                            completion:nil]; 
            self.pickerViewToolbarTextField.inputAccessoryView = [inputAccView autorelease];
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
        if (self.hasMinusSign) {
            self.tmpItemQTY = 0 - [self.pickerViewToolbarTextField.text intValue];
        } else {
            self.tmpItemQTY = [self.pickerViewToolbarTextField.text intValue];
        }
        self.pickerViewToolbarTextField.text = nil;
    }
    NSNumber *userID = [NSNumber numberWithInt:[[NSUserDefaults currentUserID] intValue]];
    if (!self.dataHeaderInfo || [self.dataHeaderInfo isKindOfClass:[ArchiveOrderHead class]]) { 
        ArchiveOrderLine *currentItemOrderLine = [ArchiveOrderLine orderLineForOrderHead:[ArchiveOrderHead 
                                                                                          orderHeadWithClientData:userID
                                                                                           inCtx:self.item.managedObjectContext] 
                                                                              withItemID:self.item.itemID 
                                                                                 itemQTY:[NSNumber numberWithInteger:self.tmpItemQTY]
                                                                                  userID:userID 
                                                                            templateName:nil 
                                                                  inCtx:self.item.managedObjectContext];
        if (currentItemOrderLine && [currentItemOrderLine.itemQTY intValue] == 0) {
            [self.item.managedObjectContext deleteObject:currentItemOrderLine];
        } else {
            if ([self.pushedFromViewController isKindOfClass:[DSPF_Order class]] && 
                ![((DSPF_Order *)self.pushedFromViewController).dataHeaderInfo isKindOfClass:[TemplateOrderHead class]]) { 
                ((DSPF_Order *)self.pushedFromViewController).lastChangedLine = currentItemOrderLine;
            }
        }
    } else if ([self.dataHeaderInfo isKindOfClass:[TemplateOrderHead class]]) { 
        TemplateOrderLine *currentItemOrderLine = [TemplateOrderLine templateLineForTemplateHead:(TemplateOrderHead *)self.dataHeaderInfo 
                                                                              withItemID:self.item.itemID 
                                                                                 itemQTY:[NSNumber numberWithInteger:self.tmpItemQTY] 
                                                                                  userID:userID 
                                                                  inCtx:self.item.managedObjectContext];
        if (currentItemOrderLine && [currentItemOrderLine.itemQTY intValue] == 0) {
            [self.item.managedObjectContext deleteObject:currentItemOrderLine];
        } else {
            if ([self.pushedFromViewController isKindOfClass:[DSPF_Order class]]) { 
                ((DSPF_Order *)self.pushedFromViewController).lastChangedLine = currentItemOrderLine;
            }
        }
    }
    if (self.tmpItemQTY == 0) {
        [self.currentQTY setTitle:@"" forState:UIControlStateNormal];
    } else { 
        NSDecimalNumber *tmpItemQTYdecimal = [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%i", self.tmpItemQTY]];
        if ([self.item.orderUnitCode isEqualToString:@"KG"] ||
            [self.item.orderUnitCode isEqualToString:@"LT"]) { 
            tmpItemQTYdecimal = [tmpItemQTYdecimal decimalNumberByDividingBy:[NSDecimalNumber decimalNumberWithString:@"1000"]];
        }
        [self.currentQTY setTitle:[NSString stringWithFormat:@"%@", tmpItemQTYdecimal] forState:UIControlStateNormal];        
    }
    [self.item.managedObjectContext saveIfHasChanges];
    [self.pickerViewToolbarTextField removeTarget:self action:@selector(pickerViewToolbarTextField:) forControlEvents:UIControlEventEditingChanged];
    [self.pickerViewToolbarTextField resignFirstResponder];
    self.pickerViewToolbar.hidden          = YES;
    self.pickerView.hidden                 = YES;
    if (self.tmpItemQTY != 0) {
        NSDecimalNumber *tmpItemQTYdecimal = [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%i", abs(self.tmpItemQTY)]];
        if ([self.item.orderUnitCode isEqualToString:@"KG"] ||
            [self.item.orderUnitCode isEqualToString:@"LT"]) { 
            tmpItemQTYdecimal = [tmpItemQTYdecimal decimalNumberByDividingBy:[NSDecimalNumber decimalNumberWithString:@"1000"]];
        }
        if (self.item.orderUnitExtraChargeQTY && 
            [self.item.orderUnitExtraChargeQTY compare:[NSDecimalNumber zero]] != NSOrderedSame) { 
            if ([tmpItemQTYdecimal compare:self.item.orderUnitExtraChargeQTY] == NSOrderedAscending) { 
                [self showPickerView];
                [DSPF_Error messageTitle:NSLocalizedString(@"TITLE__077", @"Artikelmenge")
                             messageText:[NSString stringWithFormat:NSLocalizedString(@"ERROR_MESSAGE__012", 
                                                                                      @"Die Mindestmenge für diesen Artikel ist: %@!"), 
                                          self.item.orderUnitExtraChargeQTY] 
                                delegate:nil];
                return;
            } else if ([tmpItemQTYdecimal compare:self.item.orderUnitBoxQTY] == NSOrderedAscending &&
                       !self.hasConfirmedQTYWarning) { 
                [self showPickerView];
                [DSPF_Warning messageTitle:NSLocalizedString(@"TITLE__077", @"Artikelmenge") 
                               messageText:[NSString stringWithFormat:NSLocalizedString(@"ERROR_MESSAGE__013", 
                                                                                        @"Sie müssen Zuschlag zahlen, wenn Sie weniger als %@ bestellen!"), 
                                            self.item.orderUnitBoxQTY]
                                      item:@"confirmQTYWarning"
                                  delegate:self]; 
                return;
            } 
        } else { 
            if ([tmpItemQTYdecimal compare:self.item.orderUnitBoxQTY] == NSOrderedAscending) { 
                [self showPickerView];
                [DSPF_Error messageTitle:NSLocalizedString(@"TITLE__077", @"Artikelmenge") 
                             messageText:[NSString stringWithFormat:NSLocalizedString(@"ERROR_MESSAGE__012", 
                                                                                      @"Die Mindestmenge für diesen Artikel ist: %@!"), 
                                          self.item.orderUnitBoxQTY] 
                                delegate:nil];
                return;
            } 
        }
        if (self.item.orderUnitBoxQTY && 
            [[NSDecimalNumber zero] compare:self.item.orderUnitBoxQTY] != NSOrderedSame &&
            [tmpItemQTYdecimal      compare:self.item.orderUnitBoxQTY] == NSOrderedDescending && 
            [tmpItemQTYdecimal      compare:[self.item.orderUnitBoxQTY decimalNumberByMultiplyingBy:
                                             [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%i", 
                                                [[tmpItemQTYdecimal decimalNumberByDividingBy:self.item.orderUnitBoxQTY] intValue]]]]]
            != NSOrderedSame) { 
            // this might be o.k. if the layer quantity is chosen and differs from a multiple of the box quantity
            if (!self.item.orderUnitLayerQTY || [[NSDecimalNumber zero] compare:self.item.orderUnitLayerQTY] == NSOrderedSame || 
                [tmpItemQTYdecimal compare:self.item.orderUnitLayerQTY] == NSOrderedAscending || 
                (self.item.orderUnitLayerQTY && 
                [tmpItemQTYdecimal compare:[self.item.orderUnitLayerQTY decimalNumberByMultiplyingBy:
                                            [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%i", 
                                                [[tmpItemQTYdecimal decimalNumberByDividingBy:self.item.orderUnitLayerQTY] intValue]]]]]
                 != NSOrderedSame)) { 
                    // this might be o.k. if the pallet quantity is chosen and differs from a multiple of the box quantity
                    if (!self.item.orderUnitPalletQTY || [[NSDecimalNumber zero] compare:self.item.orderUnitPalletQTY] == NSOrderedSame || 
                        [tmpItemQTYdecimal compare:self.item.orderUnitPalletQTY] == NSOrderedAscending || 
                        (self.item.orderUnitPalletQTY && 
                        [tmpItemQTYdecimal compare:[self.item.orderUnitPalletQTY decimalNumberByMultiplyingBy:
                                                    [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%i", 
                                                        [[tmpItemQTYdecimal decimalNumberByDividingBy:self.item.orderUnitPalletQTY] intValue]]]]]
                         != NSOrderedSame)) { 
                            // this must be wrong because no possible quantity was chosen that were alowed to differ from a multiple of the box quantity
                            [self showPickerView];
                            [DSPF_Error messageTitle:NSLocalizedString(@"TITLE__077", @"Artikelmenge") 
                                         messageText:[NSString stringWithFormat:NSLocalizedString(@"ERROR_MESSAGE__014", 
                                                                                                  @"Die Bestelleinheit ist %@.\n\n"
                                                                                                   "Die aktuelle Menge von %@\nliegt zwischen %@ und %@ !"), 
                                                      self.item.orderUnitBoxQTY,
                                                      tmpItemQTYdecimal,
                                                      [self.item.orderUnitBoxQTY decimalNumberByMultiplyingBy:
                                                       [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%i", 
                                                        [[tmpItemQTYdecimal decimalNumberByDividingBy:self.item.orderUnitBoxQTY] intValue]]]],
                                                      [self.item.orderUnitBoxQTY decimalNumberByMultiplyingBy:
                                                       [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%i", 
                                                        [[tmpItemQTYdecimal decimalNumberByDividingBy:self.item.orderUnitBoxQTY] intValue] + 1]]]] 
                                            delegate:nil];
                            return;
                }
            }
        }
    }
    if ([self.dataTask isEqualToString:@"INSERT"]) { 
        self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch
                                                                                                target:self
                                                                                                action:@selector(switchViews)] autorelease];
        self.navigationItem.hidesBackButton    = NO;
    } else { 
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)pickerViewToolbarTextField:(id)sender {
    if (self.pickerViewToolbarTextField.text.length > 4) { 
        self.pickerViewToolbarTextField.text = [self.pickerViewToolbarTextField.text substringToIndex:4];
    }
}

- (void)checkItemData:(Item *)tmpItem withTarget:(NSString *)target { 
    if (tmpItem) { 
        self.currentQTY.hidden          = NO;
        self.item                       = tmpItem;
        self.itemIDLabel.text           = tmpItem.itemID;
        self.itemDescriptionLabel.text  = [Item localDescriptionTextForItem:tmpItem];
        if (PFBrandingSupported(BrandingBiopartner, nil)) { 
            self.itemPriceLabel.text        = [NSString stringWithFormat:@"%@ %.2f", 
                                               self.currencyFormatter.currencyCode, [self.item.buyingPrice doubleValue]];
        } else { 
            self.itemPriceLabel.text        = [self.currencyFormatter stringFromNumber:tmpItem.price];            
        }
        ArchiveOrderLine *previousOrderLine = [ArchiveOrderLine previousOrderLineForItemID:self.item.itemID 
                                                                    inCtx:self.item.managedObjectContext];
        if (previousOrderLine) { 
            NSDecimalNumber *tmpItemQTYdecimal = [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%i", [previousOrderLine.itemQTY intValue]]];
            if ([self.item.orderUnitCode isEqualToString:@"KG"] ||
                [self.item.orderUnitCode isEqualToString:@"LT"]) { 
                tmpItemQTYdecimal = [tmpItemQTYdecimal decimalNumberByDividingBy:[NSDecimalNumber decimalNumberWithString:@"1000"]];
            }
            NSString *dateString = [DPHDateFormatter stringFromDate:previousOrderLine.archiveOrderHead.orderDate
                                                      withDateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterNoStyle locale:de_CH_Locale()];
            self.itemOrderLineLabel.text = [NSString stringWithFormat:@"%@   %5@ %@", 
                                            dateString,
                                            tmpItemQTYdecimal, 
                                            self.item.orderUnitCode];
        } else {
            self.itemOrderLineLabel.text = nil;
        }
        if ([tmpItem.storeAssortmentBit boolValue]) { 
            if (!self.dataHeaderInfo || [self.dataHeaderInfo isKindOfClass:[ArchiveOrderHead class]]) { 
                self.tmpItemQTY          = [ArchiveOrderLine currentOrderQTYForItem:tmpItem.itemID inCtx:self.item.managedObjectContext];
            } else if ([self.dataHeaderInfo isKindOfClass:[TemplateOrderHead class]]) { 
                self.tmpItemQTY          = [TemplateOrderLine currentTemplateQTYForItem:tmpItem.itemID 
                                                                           templateHead:self.dataHeaderInfo inCtx:self.item.managedObjectContext];
            }
            if ([target isEqualToString:@"insertOrderLine"]) { 
                if (self.item.orderUnitBoxQTY && 
                    [self.item.orderUnitBoxQTY compare:[NSDecimalNumber zero]] != NSOrderedSame) { 
                    if ([self.item.orderUnitCode isEqualToString:@"KG"] ||
                        [self.item.orderUnitCode isEqualToString:@"LT"]) {
                        if (self.hasMinusSign) {
                            self.tmpItemQTY -= [[self.item.orderUnitBoxQTY decimalNumberByMultiplyingByPowerOf10:3] unsignedIntegerValue];
                        } else {
                            self.tmpItemQTY += [[self.item.orderUnitBoxQTY decimalNumberByMultiplyingByPowerOf10:3] unsignedIntegerValue];
                        }
                    } else {
                        if (self.hasMinusSign) {
                            self.tmpItemQTY -= [self.item.orderUnitBoxQTY unsignedIntegerValue];
                        } else {
                            self.tmpItemQTY += [self.item.orderUnitBoxQTY unsignedIntegerValue];
                        }
                    }
                } else { 
                    if ([self.item.orderUnitCode isEqualToString:@"KG"] ||
                        [self.item.orderUnitCode isEqualToString:@"LT"]) {
                        if (self.hasMinusSign) {
                            self.tmpItemQTY     -= 1000;
                        } else {
                            self.tmpItemQTY     += 1000;
                        }
                    } else {
                        if (self.hasMinusSign) {
                            self.tmpItemQTY     -= 1;
                        } else {
                            self.tmpItemQTY     += 1;
                        }
                    }
                }
            }
        } else {
            self.tmpItemQTY              = 0;
            [DSPF_Error messageTitle:tmpItem.itemID 
                         messageText:NSLocalizedString(@"ERROR_MESSAGE__003", @"ACHTUNG: Sortimentsfehler !\nDieser Artikel kann nicht\nbestellt werden.") 
                            delegate:nil];
        }
        self.hasConfirmedQTYWarning = NO;
        [self itemQTYShouldReturn];
    }
}

- (void)checkBarcodeData:(NSString *)scanInput { 
    Item *tmpItem = [ItemCode itemForCode:scanInput inCtx:self.ctx];
    if (tmpItem) {
        [self checkItemData:tmpItem withTarget:@"insertOrderLine"];
    } else {
        [DSPF_Error messageTitle:scanInput 
					 messageText:NSLocalizedString(@"ERROR_MESSAGE__004", @"ACHTUNG: Keine Artikel-Daten für diesen Barcode gefunden.") 
                        delegate:nil];
    }
} 

- (void)viewWillAppear:(BOOL)animated { 
    [super viewWillAppear:animated];
    self.currentQTY.hidden = !self.item;
    UITapGestureRecognizer *tapGestureRecognizer =
    [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(switchMode)] autorelease];
    [tapGestureRecognizer setNumberOfTapsRequired:2];
    [tapGestureRecognizer setNumberOfTouchesRequired:1];
    [self.navigationController.navigationBar addGestureRecognizer:tapGestureRecognizer];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.navigationController.toolbarHidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated { 
	if ([self.navigationController.viewControllers indexOfObject:self]==NSNotFound) {
		// back button was pressed.  
		// We know this is true because self is no longer in the navigation stack.
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"barcodeData" object:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"disconnectScanDevice" object:self userInfo:nil];
        if (self.searchResultsCover.window) {
            [self.searchResultsCover removeFromSuperview];
        }
        if (self.searchDisplayController.active) {
            self.searchDisplayController.searchBar.text = @"";
            [self.searchDisplayController.searchBar resignFirstResponder];
            [self.searchDisplayController setActive:NO animated:YES];
            [self forceSetReadOnlyPropertyOfSearchDisplayController:nil];
        }
        [self.navigationController.navigationBar setTintColor:self.hasPlusSignColor];
	}
    for (UIGestureRecognizer *gestureRecognizer in self.navigationController.navigationBar.gestureRecognizers) {
        [self.navigationController.navigationBar removeGestureRecognizer:gestureRecognizer];
    }
    [super viewWillDisappear:animated];
}

- (void)switchMode {
    self.hasMinusSign = !self.hasMinusSign;
    if (!self.searchDisplayController.active) {
        self.tmpItemQTY   = 0 - self.tmpItemQTY;
        if (self.item) {
            [self itemQTYShouldReturn];
        }
    }
    if (self.hasMinusSign) {
        self.title = NSLocalizedString(@"Rücknahme", @"Rücknahme");
    } else {
        self.title = NSLocalizedString(@"Verkauf", @"Verkauf");
    }
    [self setModeColor];
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

#pragma mark - Button actions

- (IBAction)scanDown {
    [[NSNotificationQueue defaultQueue] enqueueNotification:[NSNotification notificationWithName:@"startScan"
                                                                                          object:self
                                                                                        userInfo:nil]
                                               postingStyle:NSPostNow];
}

- (IBAction)scanUp {
    [[NSNotificationQueue defaultQueue] enqueueNotification:[NSNotification notificationWithName:@"stopScan"
                                                                                          object:self
                                                                                        userInfo:nil]
                                               postingStyle:NSPostNow];
}

- (void)didReturnBarcode:(NSNotification *)aNotification {
    NSString *barcodeData = [[aNotification userInfo] valueForKey:@"barcodeData"];
    if (barcodeData.length > 2 &&
        [@"*" characterAtIndex:0] == [barcodeData characterAtIndex:0] &&
        [@"*" characterAtIndex:0] == [barcodeData characterAtIndex:(barcodeData.length - 1)]) {
        barcodeData = [barcodeData substringWithRange:NSMakeRange(1, (barcodeData.length - 2))];
    }
    [self checkBarcodeData:barcodeData];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView {
    // Return the number of sections.
    if (aTableView == self.searchDisplayController.searchResultsTableView) {
        return self.filteredListContent.sections.count;
    }
	return 1;
}

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section {
    
    if (aTableView == self.searchDisplayController.searchResultsTableView) {
        return [[self.filteredListContent.sections objectAtIndex:section] numberOfObjects];
    }
	return 0;
}

- (CGFloat)tableView:(UITableView *)aTableView heightForHeaderInSection:(NSInteger)section { 
    if (!self.hasProductGroups) {
        return 0.0;
    }
    return 24.0;
}

- (UIView *)tableView:(UITableView *)aTableView viewForHeaderInSection:(NSInteger)aSection { 
    // create the parent view that will hold header Label
    UIView *customView = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
    customView.backgroundColor = [UIColor clearColor];
    if (aTableView == self.searchDisplayController.searchResultsTableView && self.hasProductGroups) { 
        // create the label object
        UILabel *headerLabel = [[[UILabel alloc] initWithFrame:
                                 CGRectMake(0.0, 
                                            0.0, 
                                            self.searchDisplayController.searchResultsTableView.frame.size.width, 
                                            22.0)] autorelease];
        headerLabel.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.88];
        headerLabel.opaque = YES;
        headerLabel.textColor = [UIColor whiteColor];
        headerLabel.font = [UIFont  fontWithName:@"HelveticaNeue-CondensedBlack" size:12];
        headerLabel.textAlignment = UITextAlignmentCenter;
        headerLabel.text = [LocalizedDescription textForKey:@"ItemProductGroup" 
                                                   withCode:[[[self.filteredListContent sections] objectAtIndex:aSection] name] 
                                     inCtx:self.ctx];
        if (!headerLabel.text || headerLabel.text.length == 0) {
            headerLabel.text = [[[self.filteredListContent sections] objectAtIndex:aSection] name];
            if (!headerLabel.text || headerLabel.text.length == 0) { 
                if ([[NSUserDefaults standardUserDefaults] boolForKey:@"HermesApp_SYSVAL_RUN_withBasketAnalysis"]) { 
                    headerLabel.text = NSLocalizedString(@"TITLE__079", @"Ohne Zuordnung");
                } else {
                    headerLabel.backgroundColor = [UIColor clearColor];
                }
            }
        }
        [customView setFrame: CGRectMake(0.0, 
                                         0.0, 
                                         headerLabel.frame.size.width, 
                                         headerLabel.frame.size.height)];
        [customView addSubview:headerLabel];
    }
    return customView; 
}

/*
- (NSString *)tableView:(UITableView *)aTableView titleForHeaderInSection:(NSInteger)aSection { 
    if (aTableView == self.searchDisplayController.searchResultsTableView) { 
        return [LocalizedDescription textForKey:@"ItemProductGroup" 
                            withCode:[[[self.filteredListContent sections] objectAtIndex:aSection] name] 
                         inCtx:self.ctx];
    }
    return nil;
}
*/

- (id )orderItemLinkAtIndexPath:(NSIndexPath *)indexPath forTableView:(UITableView *)aTableView { 
    // Return the object from this indexPath
    if (aTableView == self.searchDisplayController.searchResultsTableView) { 
        return [self.filteredListContent objectAtIndexPath:indexPath];            
    }
    return [self.filteredListContent objectAtIndexPath:indexPath]; 
}

- (void)accessoryButtonTapped:(id)sender event:(id)event { 
    NSString *target;
    if ([(UIButton *)sender imageForState:UIControlStateNormal] == [UIImage imageNamed:@"addButton_m.png"]) { 
        target = @"updateOrderLine";
    } else if ([(UIButton *)sender imageForState:UIControlStateNormal] == [UIImage imageNamed:@"addButton.png"]) { 
        target = @"insertOrderLine";
    } else {
        target = @"insertOrderLine";
    }
    NSIndexPath *indexPath = [self.searchDisplayController.searchResultsTableView 
                              indexPathForRowAtPoint:[[[event allTouches] anyObject] locationInView:
                                                      self.searchDisplayController.searchResultsTableView]];
    if (indexPath != nil) { 
        [self toggleSearchBar];
        id itemLink = [self orderItemLinkAtIndexPath:indexPath forTableView:self.searchDisplayController.searchResultsTableView];
        Item *itemObj = nil;
        if ([itemLink isKindOfClass:[Item class]]) {
            itemObj = itemLink;
        } else {
            itemObj = [(id<ItemHolder>)itemLink item];
        }
        [self checkItemData:itemObj withTarget:target];
    }
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    id cell = [aTableView dequeueReusableCellWithIdentifier:@"DSPF_ItemList"];
    
    if (cell == nil) {
        if (PFBrandingSupported(BrandingBiopartner, nil)) {
            cell = [[[DSPF_ItemTableViewCell_biopartner alloc]
                     initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"DSPF_ItemList"] autorelease];
        } else {
            cell = [[[DSPF_ItemTableViewCell alloc]
                     initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"DSPF_ItemList"] autorelease];
        }
    }
    
    // Configure the cell...
	((UITableViewCell *)cell).selectionStyle = UITableViewCellSelectionStyleNone;

    if (aTableView == self.searchDisplayController.searchResultsTableView) { 
        if (!self.dataHeaderInfo || [self.dataHeaderInfo isKindOfClass:[ArchiveOrderHead class]]) { 
            UIImage  *addButton = [UIImage imageNamed:@"addButton.png"];
            if (!((UITableViewCell *)cell).accessoryView) {
                UIButton *accessoryButton = [[[UIButton alloc] initWithFrame:CGRectMake(0, 0, addButton.size.width * 0.2, addButton.size.height * 0.2)] autorelease];
                [accessoryButton addTarget:self action:@selector(accessoryButtonTapped:event:) forControlEvents:UIControlEventTouchUpInside];
                ((UITableViewCell *)cell).accessoryView = accessoryButton;
            }
            [(UIButton *)((UITableViewCell *)cell).accessoryView setImage:addButton forState:UIControlStateNormal];
        } else if ([self.dataHeaderInfo isKindOfClass:[TemplateOrderHead class]]) { 
            if ([TemplateOrderLine currentTemplateQTYForItem:([(id<ItemHolder>)[self orderItemLinkAtIndexPath:indexPath 
                                                                                         forTableView:(UITableView *)aTableView] item]).itemID 
                                                templateHead:self.dataHeaderInfo 
                                      inCtx:self.ctx] == 0) { 
                if (!((UITableViewCell *)cell).accessoryView) {
                    UIButton *accessoryButton = [UIButton buttonWithType:UIButtonTypeContactAdd];    
                    [accessoryButton addTarget:self action:@selector(accessoryButtonTapped:event:) forControlEvents:UIControlEventTouchUpInside];
                    ((UITableViewCell *)cell).accessoryView = accessoryButton;
                }
            } else {
                ((UITableViewCell *)cell).accessoryView = nil;
                ((UITableViewCell *)cell).accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
            }
        } else { 
            if (!((UITableViewCell *)cell).accessoryView) {
                UIButton *accessoryButton = [UIButton buttonWithType:UIButtonTypeContactAdd];    
                [accessoryButton addTarget:self action:@selector(accessoryButtonTapped:event:) forControlEvents:UIControlEventTouchUpInside];
                ((UITableViewCell *)cell).accessoryView = accessoryButton;
            }
        }
    } else {
        //  cell.accessoryType  = UITableViewCellAccessoryDetailDisclosureButton;
        ((UITableViewCell *)cell).accessoryType = UITableViewCellAccessoryNone;
    }
    // [DSPF_ItemTableViewCell setItemLink] sets up all subviews ...
    ((DSPF_ItemTableViewCell *)cell).itemLink = [self orderItemLinkAtIndexPath:indexPath forTableView:(UITableView *)aTableView];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 66;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath { 
    if (PFBrandingSupported(BrandingBiopartner, nil)) { 
        Item *tmpItem;
        id itemLink = [self orderItemLinkAtIndexPath:indexPath forTableView:self.searchDisplayController.searchResultsTableView];
        if ([itemLink isKindOfClass:[Item class]]) { 
            tmpItem = (Item *)itemLink;
        } else {
            tmpItem = [(id<ItemHolder>)itemLink item];
        }
        if (tmpItem) { 
            DSPF_ItemDetail *dspf_ItemDetail = [[DSPF_ItemDetail alloc] initWithNibName:@"DSPF_ItemDetail" bundle:nil];
            dspf_ItemDetail.title            = NSLocalizedString(@"TITLE__065", @"Artikel-Details");
            dspf_ItemDetail.item             = tmpItem;
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
    [self toggleSearchBar];
    id itemLink = [self orderItemLinkAtIndexPath:indexPath forTableView:aTableView];
    if ([itemLink isKindOfClass:[Item class]]) { 
        [self checkItemData:(Item *)itemLink        withTarget:@"updateOrderLine"];            
    } else { 
        [self checkItemData:[(id<ItemHolder>)itemLink item] withTarget:@"updateOrderLine"];
    }
}


#pragma mark - UISearchDisplayController Delegate Methods

- (void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller { 
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

/*
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component { 
    return [NSString stringWithFormat:@"%i", row];
}
*/

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

#pragma mark - Memory management

- (void)viewDidUnload {
    [super viewDidUnload];
    
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
	[[NSUserDefaults standardUserDefaults] synchronize];
	self.tableView                           = nil;
	self.scanView                            = nil;
	self.textView                            = nil;
    self.pickerViewToolbarDone               = nil;
    self.pickerViewToolbarTextField          = nil;
    self.pickerViewToolbarText               = nil;
    self.pickerViewToolbar                   = nil;
    self.pickerView                          = nil;
    self.itemDescriptionLabel                = nil;
    self.itemIDLabel                         = nil;
    self.itemPriceLabel                      = nil;
    self.itemOrderLineLabel                  = nil;
    self.currentQTY                          = nil;
    self.artikelOrderItemLabel               = nil;
    self.preisOrderItemLabel                 = nil;
    self.historieOrderItemLabel              = nil;
}

- (void)dealloc {
    [pushedFromViewController            release];
    [searchResultsCover                  release];
    [filteredListContent                 release];
	[ctx                release];
    [currencyFormatter                   release];
    [itemDescriptionLabel                release];
    [itemIDLabel                         release];
    [itemPriceLabel                      release];
    [itemOrderLineLabel                  release];
    [item                                release];
    [currentQTY                          release];
    [dataTask                            release];
    [dataHeaderInfo                      release];
    [pickerView                          release];
    [pickerViewToolbarDone               release];
    [pickerViewToolbarTextField          release];
    [pickerViewToolbarText               release];
    [pickerViewToolbar                   release];
	[tableView                           release];
	[scanView                            release];
	[textView                            release];
    [artikelOrderItemLabel               release];
    [preisOrderItemLabel                 release];
    [historieOrderItemLabel              release];
    [hasPlusSignColor                    release];
    [super dealloc];
}

@end