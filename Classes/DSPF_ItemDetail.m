//
//  DSPF_ItemDetail.m
//  StoreOnline
//
//  Created by Lutz  Thalmann on 21.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DSPF_ItemDetail.h"

#import "ItemCode.h"
#import "ArchiveOrderHead.h"
#import "ArchiveOrderLine.h"
#import "LocalizedDescription.h"

@implementation DSPF_ItemDetail

@synthesize item;
@synthesize itemDescriptionLabel;
@synthesize itemTrademarkHolderLabel;
@synthesize itemPackageLabel;
@synthesize itemQualityLabel;
@synthesize itemCategoryLabel;
@synthesize itemIDLabel;
@synthesize itemCodeLabel;
@synthesize itemPriceLabel;
@synthesize itemBuyingPriceLabel;
@synthesize itemOrderQTYLabel;
@synthesize itemOrderTotalCostLabel;
@synthesize itemArchiveOrderDateLabel;
@synthesize itemArchiveOrderQTYLabel;
@synthesize itemOrderUnitLabel;
@synthesize itemValueAddedTaxLabel;
@synthesize itemOG123ZLabel;
@synthesize bestBeforeDaysLabel;
@synthesize itemProductInformationLabel;
@synthesize itemPriceTextLabel;
@synthesize haltbarkeitLabel;
@synthesize tageLabel;
@synthesize mwstLabel;
@synthesize epLabel;
@synthesize vpLabel;
@synthesize currencyFormatter;
@synthesize percentageFormatter;

- (NSNumberFormatter *)currencyFormatter { 
    if (!currencyFormatter) {
        currencyFormatter = [[NSNumberFormatter alloc] init];
        [currencyFormatter  setNumberStyle:NSNumberFormatterCurrencyStyle]; 
        [currencyFormatter  setGeneratesDecimalNumbers:YES];
        [currencyFormatter  setFormatterBehavior:NSNumberFormatterBehavior10_4];
    }
    return currencyFormatter;
}

- (NSNumberFormatter *)percentageFormatter { 
    if (!percentageFormatter) {
        [percentageFormatter  setNumberStyle:NSNumberFormatterDecimalStyle]; 
        [percentageFormatter  setPositiveFormat:@"######0.00"];
        [percentageFormatter  setNegativePrefix:@" "];
        [percentageFormatter  setGeneratesDecimalNumbers:YES];
        [percentageFormatter  setAlwaysShowsDecimalSeparator:YES];
        [percentageFormatter  setDecimalSeparator:[percentageFormatter.locale objectForKey:NSLocaleDecimalSeparator]];
        [percentageFormatter  setGroupingSeparator:@""];
        [percentageFormatter  setFormatterBehavior:NSNumberFormatterBehavior10_4];
    }
    return percentageFormatter;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}



#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.haltbarkeitLabel.text          = NSLocalizedString(@"TITLE_072", @"Haltbarkeit");
    self.tageLabel.text                 = NSLocalizedString(@"TITLE_073", @"Tage");
    self.mwstLabel.text                 = NSLocalizedString(@"TITLE_074", @"Mwst");
    self.epLabel.text                   = NSLocalizedString(@"TITLE_075", @"EP");
    self.vpLabel.text                   = NSLocalizedString(@"TITLE_076", @"VP");
    self.itemDescriptionLabel.text     = [Item localDescriptionTextForItem:self.item];
    self.itemTrademarkHolderLabel.text = [LocalizedDescription textForKey:@"ItemTrademarkHolder" 
                                                                 withCode:self.item.trademarkHolder 
                                                   inCtx:self.item.managedObjectContext];
    self.itemPackageLabel.text         = [LocalizedDescription textForKey:@"ItemPackage" 
                                                                 withCode:self.item.itemPackageCode 
                                                   inCtx:self.item.managedObjectContext];
    self.itemQualityLabel.text         = [LocalizedDescription textForKey:@"ItemCountryOfOrigin" 
                                                                  withCode:self.item.countryOfOriginCode 
                                                    inCtx:self.item.managedObjectContext];
    if (self.itemQualityLabel.text && self.itemQualityLabel.text.length > 0) {
        self.itemQualityLabel.text     = [self.itemQualityLabel.text stringByAppendingString:@" "];
        self.itemQualityLabel.text     = [self.itemQualityLabel.text stringByAppendingString:
                                          [LocalizedDescription textForKey:@"ItemCertification" 
                                                                  withCode:self.item.itemCertificationCode 
                                                    inCtx:self.item.managedObjectContext]];
    } else {
        self.itemQualityLabel.text     = [LocalizedDescription textForKey:@"ItemCertification" 
                                                                  withCode:self.item.itemCertificationCode 
                                                    inCtx:self.item.managedObjectContext];
    }
    self.itemCategoryLabel.text        = [LocalizedDescription textForKey:@"ItemCategory" 
                                                                 withCode:self.item.itemCategoryCode 
                                                   inCtx:self.item.managedObjectContext];
    self.itemIDLabel.text              = self.item.itemID;
    self.itemCodeLabel.text            = [ItemCode salesUnitItemCodeForItemID:self.item.itemID 
                                                       inCtx:self.item.managedObjectContext];
    self.itemPriceLabel.text           = [self.currencyFormatter    stringFromNumber:self.item.price];
    self.itemValueAddedTaxLabel.text   = [self.percentageFormatter  stringFromNumber:self.item.valueAddedTax];
    self.itemValueAddedTaxLabel.text   = [self.item.valueAddedTax stringValue];
    //
    NSUInteger currentOrderQTY         = [ArchiveOrderLine currentOrderQTYForItem:self.item.itemID 
                                                           inCtx:self.item.managedObjectContext];
    if (currentOrderQTY != 0) { 
        self.itemOrderQTYLabel.text    = [NSString stringWithFormat:@"%5i", currentOrderQTY];
        if ([self.item.orderUnitCode isEqualToString:@"KG"] ||
            [self.item.orderUnitCode isEqualToString:@"LT"]) { 
            self.itemOrderQTYLabel.text = [[[NSDecimalNumber decimalNumberWithString:self.itemOrderQTYLabel.text] 
                                            decimalNumberByMultiplyingByPowerOf10:-3] stringValue];
        } 
        if (self.item.buyingPrice) {
            self.itemOrderTotalCostLabel.text = [NSString stringWithFormat:@"%@ %.2f", 
                                                 self.currencyFormatter.currencyCode, 
                                                 [[self.item.buyingPrice decimalNumberByMultiplyingBy:
                                                   [NSDecimalNumber decimalNumberWithString:self.itemOrderQTYLabel.text]] 
                                                  doubleValue]];
        } else {
            self.itemOrderTotalCostLabel.text = @"";
        }
    } else {
        self.itemOrderQTYLabel.text       = @"";
        self.itemOrderTotalCostLabel.text = @"";
    }

    ArchiveOrderLine *previousOrderLine = [ArchiveOrderLine previousOrderLineForItemID:self.item.itemID 
                                                                inCtx:self.item.managedObjectContext];
    if (previousOrderLine) {
        self.itemArchiveOrderDateLabel.text = [DPHDateFormatter stringFromDate:previousOrderLine.archiveOrderHead.orderDate
                                                                 withDateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterNoStyle locale:de_CH_Locale()];
        self.itemArchiveOrderQTYLabel.text  = [NSString stringWithFormat:@"%5i", [previousOrderLine.itemQTY intValue]];
        if ([self.item.orderUnitCode isEqualToString:@"KG"] ||
            [self.item.orderUnitCode isEqualToString:@"LT"]) { 
            self.itemArchiveOrderQTYLabel.text = [[[NSDecimalNumber decimalNumberWithString:self.itemArchiveOrderQTYLabel.text] 
                                                   decimalNumberByMultiplyingByPowerOf10:-3] stringValue];
        } 
        self.itemOrderUnitLabel.text        = self.item.orderUnitCode;
    } else {
        self.itemArchiveOrderDateLabel.text = @"";
        self.itemArchiveOrderQTYLabel.text  = @"";
        self.itemOrderUnitLabel.text        = @"";
    }
    self.itemBuyingPriceLabel.text     = [NSString stringWithFormat:@"%@ %.2f", 
                                          self.currencyFormatter.currencyCode, [self.item.buyingPrice doubleValue]];
    self.itemPriceTextLabel.text       = self.item.priceText;
    self.itemOG123ZLabel.text          = [NSString stringWithFormat:@" %@  |  %@  |  %@  |  %@ ", 
                                          [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"0%@", self.item.orderUnitExtraChargeQTY]],
                                          [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"0%@", self.item.orderUnitBoxQTY]],
                                          [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"0%@", self.item.orderUnitLayerQTY]],
                                          [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"0%@", self.item.orderUnitPalletQTY]]];
    if ([self.item.bestBeforeDays intValue] == 0) { 
        self.bestBeforeDaysLabel.text  = @"";
        self.tageLabel.hidden          = YES;
    } else {
        self.bestBeforeDaysLabel.text  = [NSString stringWithFormat:@"%3i", [self.item.bestBeforeDays intValue]];
        self.tageLabel.hidden          = NO;
    }
    self.itemProductInformationLabel.text = [Item localProductInformationTextForItem:self.item];
}

- (void)viewDidUnload {
    [super viewDidUnload];

    self.itemPriceTextLabel                  = nil;
    self.itemProductInformationLabel         = nil;
    self.bestBeforeDaysLabel                 = nil;
    self.itemOG123ZLabel                     = nil;
    self.itemValueAddedTaxLabel              = nil;
    self.itemOrderUnitLabel                  = nil;
    self.itemArchiveOrderQTYLabel            = nil;
    self.itemArchiveOrderDateLabel           = nil;
    self.itemOrderTotalCostLabel             = nil;
    self.itemOrderQTYLabel                   = nil;
    self.itemBuyingPriceLabel                = nil;
    self.itemPriceLabel                      = nil;
    self.itemCodeLabel                       = nil;
    self.itemIDLabel                         = nil;
    self.itemCategoryLabel                   = nil;
    self.itemQualityLabel                    = nil;
    self.itemPackageLabel                    = nil;
    self.haltbarkeitLabel                    = nil;
    self.tageLabel                           = nil;
    self.mwstLabel                           = nil;
    self.epLabel                             = nil;
    self.vpLabel                             = nil;
    self.itemTrademarkHolderLabel            = nil;
    self.itemDescriptionLabel                = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc { 
    [itemPriceTextLabel          release];
    [itemProductInformationLabel release];
    [haltbarkeitLabel            release];
    [tageLabel                   release];
    [mwstLabel                   release];
    [epLabel                     release];
    [vpLabel                     release];
    [bestBeforeDaysLabel         release];
    [itemOG123ZLabel             release];
    [itemValueAddedTaxLabel      release];
    [itemOrderUnitLabel          release];
    [itemArchiveOrderQTYLabel    release];
    [itemArchiveOrderDateLabel   release];
    [itemOrderTotalCostLabel     release];
    [itemOrderQTYLabel           release];
    [itemBuyingPriceLabel        release];
    [itemPriceLabel              release];
    [itemCodeLabel               release];
    [itemIDLabel                 release];
    [itemCategoryLabel           release];
    [itemQualityLabel            release];
    [itemPackageLabel            release];
    [itemTrademarkHolderLabel    release];
    [itemDescriptionLabel        release];
    [item                        release];
    [currencyFormatter           release];
    [percentageFormatter         release];
    [super dealloc];
}

@end
