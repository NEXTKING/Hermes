//
//  DSPF_ItemTableViewCell_biopartner.m
//  Hermes
//
//  Created by iLutz on 07.12.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DSPF_ItemTableViewCell_biopartner.h"

#import "LocalizedDescription.h"
#import "ArchiveOrderLine.h"
#import "TemplateOrderLine.h"

#import "Item.h"
#import "ItemDescription.h"
#import "ItemCode.h"

@implementation DSPF_ItemTableViewCell_biopartner

@synthesize itemLink;
@synthesize dataLineQTYLabel;
@synthesize itemDescriptionLabel;
@synthesize itemTrademarkHolderLabel;
@synthesize itemPackageLabel;
@synthesize currentOrderQTYLabel;
@synthesize itemInfoLabel;
@synthesize itemIDLabel;
@synthesize itemPriceLabel;
@synthesize itemTask;
@synthesize currencyFormatter;


- (NSNumberFormatter *)currencyFormatter { 
    if (!currencyFormatter) {
        currencyFormatter = [[NSNumberFormatter alloc] init];
        [currencyFormatter  setNumberStyle:NSNumberFormatterCurrencyStyle]; 
        [currencyFormatter  setGeneratesDecimalNumbers:YES];
        [currencyFormatter  setFormatterBehavior:NSNumberFormatterBehavior10_4];
    }
    return currencyFormatter;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentView.backgroundColor = [[UIColor alloc] initWithRed:255.0 / 255 green:255.0 / 255 blue:255.0 / 255 alpha: 0.16];
        // Initialization code
//      imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
//      imageView.contentMode = UIViewContentModeScaleAspectFit;
//      [self.contentView addSubview:imageView];
        
        currentOrderQTYLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        currentOrderQTYLabel.backgroundColor = self.contentView.backgroundColor;
//      [currentOrderQTYLabel setFont:[UIFont fontWithName:@"Courier-Bold" size:14]];
        [currentOrderQTYLabel setTextAlignment:TextAlignmentRight];
        [currentOrderQTYLabel setFont:[UIFont systemFontOfSize:14.0]];
        [currentOrderQTYLabel setTextColor:[UIColor darkGrayColor]];
        [currentOrderQTYLabel setHighlightedTextColor:[UIColor whiteColor]];
        currentOrderQTYLabel.minimumFontSize = 7.0;
        currentOrderQTYLabel.lineBreakMode = UILineBreakModeTailTruncation;
        [self.contentView addSubview:currentOrderQTYLabel];
        
        itemInfoLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        itemInfoLabel.backgroundColor = self.contentView.backgroundColor;
        [itemInfoLabel setFont:[UIFont  fontWithName:@"HelveticaNeue" size:14]];
        [itemInfoLabel setTextColor:[UIColor darkGrayColor]];
        [itemInfoLabel setHighlightedTextColor:[UIColor whiteColor]];
        itemInfoLabel.minimumFontSize = 7.0;
        itemInfoLabel.lineBreakMode = UILineBreakModeTailTruncation;
        [self.contentView addSubview:itemInfoLabel];
        
        itemIDLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        itemIDLabel.backgroundColor = self.contentView.backgroundColor;
        [itemIDLabel setFont:[UIFont  fontWithName:@"HelveticaNeue-CondensedBold" size:12]];
        [itemIDLabel setTextColor:[UIColor darkGrayColor]];
        [itemIDLabel setHighlightedTextColor:[UIColor whiteColor]];
        itemIDLabel.minimumFontSize = 7.0;
        itemIDLabel.lineBreakMode = UILineBreakModeTailTruncation;
        [self.contentView addSubview:itemIDLabel];
        
        itemPriceLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        itemPriceLabel.backgroundColor = self.contentView.backgroundColor;
        [itemPriceLabel setFont:[UIFont systemFontOfSize:14.0]];
        [itemPriceLabel setTextColor:[UIColor darkGrayColor]];
        [itemPriceLabel setHighlightedTextColor:[UIColor whiteColor]];
        itemPriceLabel.minimumFontSize = 7.0;
        itemPriceLabel.lineBreakMode = UILineBreakModeTailTruncation;
        [self.contentView addSubview:itemPriceLabel];
        
        itemDescriptionLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        itemDescriptionLabel.backgroundColor = self.contentView.backgroundColor;
        [itemDescriptionLabel setFont:[UIFont  fontWithName:@"HelveticaNeue-CondensedBold" size:16]];
        [itemDescriptionLabel setTextColor:[[UIColor alloc] initWithRed:23.0 / 255 green:48.0 / 255 blue:72.0 / 255 alpha: 0.8]];
        [itemDescriptionLabel setHighlightedTextColor:[UIColor whiteColor]];
        itemDescriptionLabel.minimumFontSize = 12.0;
        itemDescriptionLabel.lineBreakMode = UILineBreakModeMiddleTruncation;
        [self.contentView addSubview:itemDescriptionLabel];
        
        itemTrademarkHolderLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        itemTrademarkHolderLabel.backgroundColor = self.contentView.backgroundColor;
        [itemTrademarkHolderLabel setFont:[UIFont  fontWithName:@"HelveticaNeue-CondensedBold" size:16]];
        [itemTrademarkHolderLabel setTextColor:[[UIColor alloc] initWithRed:23.0 / 255 green:48.0 / 255 blue:72.0 / 255 alpha: 0.8]];
        [itemTrademarkHolderLabel setHighlightedTextColor:[UIColor whiteColor]];
        itemTrademarkHolderLabel.minimumFontSize = 12.0;
        itemTrademarkHolderLabel.lineBreakMode = UILineBreakModeMiddleTruncation;
        [self.contentView addSubview:itemTrademarkHolderLabel];
        
        itemPackageLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        itemPackageLabel.backgroundColor = self.contentView.backgroundColor;
        [itemPackageLabel setFont:[UIFont  fontWithName:@"HelveticaNeue-CondensedBold" size:16]];
        [itemPackageLabel setTextColor:[[UIColor alloc] initWithRed:23.0 / 255 green:48.0 / 255 blue:72.0 / 255 alpha: 0.8]];
        [itemPackageLabel setHighlightedTextColor:[UIColor whiteColor]];
        itemPackageLabel.minimumFontSize = 12.0;
        itemPackageLabel.lineBreakMode = UILineBreakModeMiddleTruncation;
        [self.contentView addSubview:itemPackageLabel];
        
        dataLineQTYLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        dataLineQTYLabel.backgroundColor = self.contentView.backgroundColor;
        [dataLineQTYLabel setTextAlignment:TextAlignmentRight];
        [dataLineQTYLabel setFont:[UIFont  fontWithName:@"HelveticaNeue-CondensedBold" size:16]];
        [dataLineQTYLabel setTextColor:[UIColor blackColor]];
        [dataLineQTYLabel setHighlightedTextColor:[UIColor whiteColor]];
        dataLineQTYLabel.minimumFontSize = 8.0;
        dataLineQTYLabel.lineBreakMode = UILineBreakModeTailTruncation;
        [self.contentView addSubview:dataLineQTYLabel];
    }
    return self;
}

#pragma mark - Laying out subviews

#define TEXT_LEFT_MARGIN    6.0
#define TEXT_RIGHT_MARGIN  38.0

- (void)layoutSubviews {
    [super layoutSubviews];
//
// Line 1: dataLineQTY | itemDescription   
    [self.dataLineQTYLabel setFrame:
     CGRectMake(TEXT_LEFT_MARGIN,  
                3.0, 
                [@"1.234"   sizeWithFont:self.dataLineQTYLabel.font].width, 
                [@"anyText" sizeWithFont:self.dataLineQTYLabel.font].height)];
    [self.itemDescriptionLabel setFrame:
     CGRectMake(2 * TEXT_LEFT_MARGIN + [@"1.234" sizeWithFont:self.dataLineQTYLabel.font].width, 
                3.0, 
                self.frame.size.width 
                - [@"1.234" sizeWithFont:self.dataLineQTYLabel.font].width
                - 2 * TEXT_LEFT_MARGIN 
                - TEXT_RIGHT_MARGIN, 
                [@"anyText" sizeWithFont:self.itemDescriptionLabel.font].height)];
//
// Line 2: itemPrice
    [self.currentOrderQTYLabel setFrame:
     CGRectMake(0 , 
                2 * 3.0 
                + [@"anyText" sizeWithFont:self.dataLineQTYLabel.font].height, 
                [@"1.234"     sizeWithFont:self.dataLineQTYLabel.font].width + TEXT_LEFT_MARGIN, 
                [@"anyText"   sizeWithFont:self.currentOrderQTYLabel.font].height)]; 
    [self.itemPackageLabel setFrame:
     CGRectMake(self.frame.size.width
                - TEXT_RIGHT_MARGIN
                - [self.itemPackageLabel.text sizeWithFont:self.itemPackageLabel.font].width, 
                (2 * 3.0)
                + [@"anyText" sizeWithFont:self.itemDescriptionLabel.font].height, 
                [self.itemPackageLabel.text sizeWithFont:self.itemPackageLabel.font].width, 
                [@"anyText"                 sizeWithFont:self.itemPackageLabel.font].height)];
    [self.itemTrademarkHolderLabel setFrame:
     CGRectMake(self.itemDescriptionLabel.frame.origin.x,  
                (2 * 3.0)
                + [@"anyText" sizeWithFont:self.itemDescriptionLabel.font].height, 
                self.itemPackageLabel.frame.origin.x 
                - TEXT_LEFT_MARGIN 
                - self.itemDescriptionLabel.frame.origin.x, 
                [@"anyText"                 sizeWithFont:self.itemTrademarkHolderLabel.font].height)];
//
// Line 3: currentOrderQTY | itemInfo | itemID
    [self.itemInfoLabel setFrame:
     CGRectMake(self.itemDescriptionLabel.frame.origin.x, 
                3 * 3.0 
                + [@"anyText" sizeWithFont:self.itemDescriptionLabel.font].height 
                + [@"anyText" sizeWithFont:self.itemPriceLabel.font].height,
                self.frame.size.width 
                - self.itemDescriptionLabel.frame.origin.x, 
                [@"anyText" sizeWithFont:self.itemInfoLabel.font].height)];
    [self.itemIDLabel setFrame:
     CGRectMake(self.frame.size.width
                - TEXT_RIGHT_MARGIN 
                - [self.itemIDLabel.text sizeWithFont:self.itemIDLabel.font].width, 
                self.itemInfoLabel.frame.origin.y 
                + [@"anyText" sizeWithFont:self.itemInfoLabel.font].height 
                - [@"anyText" sizeWithFont:self.itemIDLabel.font].height, 
                TEXT_RIGHT_MARGIN 
                + [self.itemIDLabel.text sizeWithFont:self.itemIDLabel.font].width, 
                [@"anyText"              sizeWithFont:self.itemIDLabel.font].height)];
}

#pragma mark - Departure set accessor

- (void)setItemLink:(id )newItemLink {
    if (newItemLink != itemLink) {
        itemLink = newItemLink;
    }
    
    NSUInteger currentOrderQTY      = 0;
    BOOL       storeAssortmentBit   = NO; 
    if ([itemLink isKindOfClass:[Item class]]) {         
        self.itemDescriptionLabel.text  = [NSString stringWithFormat:@"%@", [Item localDescriptionTextForItem:(Item *)itemLink]];
        self.itemIDLabel.text           = [NSString stringWithFormat:@"     %@", ((Item *)itemLink).itemID];
        if (NO) {
            self.itemInfoLabel.text     = [NSString stringWithFormat:@"EAN: %@", [ItemCode salesUnitItemCodeForItemID:((Item *)itemLink).itemID
                                                                                                   inCtx:[itemLink ctx]]];
        } else {
            self.itemInfoLabel.text     = [NSString stringWithFormat:@"OG (z|1|2|3):  %@ | %@ | %@ | %@",
                                           [NSDecimalNumber decimalNumberWithString:
                                            [NSString stringWithFormat:@"0%@", ((Item *)itemLink).orderUnitExtraChargeQTY]],
                                           [NSDecimalNumber decimalNumberWithString:
                                            [NSString stringWithFormat:@"0%@", ((Item *)itemLink).orderUnitBoxQTY]],
                                           [NSDecimalNumber decimalNumberWithString:
                                            [NSString stringWithFormat:@"0%@", ((Item *)itemLink).orderUnitLayerQTY]],
                                           [NSDecimalNumber decimalNumberWithString:
                                            [NSString stringWithFormat:@"0%@", ((Item *)itemLink).orderUnitPalletQTY]]];
        }
        self.itemPriceLabel.text        = [self.currencyFormatter stringFromNumber:((Item *)itemLink).price];
        self.itemTrademarkHolderLabel.text  = [LocalizedDescription textForKey:@"ItemTrademarkHolder" 
                                                                      withCode:((Item *)itemLink).trademarkHolder 
                                                        inCtx:[itemLink ctx]];
        if (!self.itemTrademarkHolderLabel.text || self.itemTrademarkHolderLabel.text.length == 0) { 
            self.itemTrademarkHolderLabel.text = [LocalizedDescription textForKey:@"ItemCountryOfOrigin" 
                                                                         withCode:((Item *)itemLink).countryOfOriginCode 
                                                           inCtx:[itemLink ctx]];
        }
        self.itemPackageLabel.text          = [LocalizedDescription textForKey:@"ItemPackage" 
                                                                      withCode:((Item *)itemLink).itemPackageCode 
                                                        inCtx:[itemLink ctx]];
        currentOrderQTY                 = [ArchiveOrderLine currentOrderQTYForItem:((Item *)itemLink).itemID 
                                                            inCtx:[itemLink ctx]];
        storeAssortmentBit              = [((Item *)itemLink).storeAssortmentBit boolValue];
    } else if ([itemLink isKindOfClass:[ItemDescription class]]) { 
        self.itemDescriptionLabel.text  = [NSString stringWithFormat:@"%@", ((ItemDescription *)itemLink).text];
        self.itemIDLabel.text           = [NSString stringWithFormat:@"     %@", ((ItemDescription *)itemLink).item.itemID];
        if (NO) {
            self.itemInfoLabel.text     = [NSString stringWithFormat:@"EAN: %@", [ItemCode salesUnitItemCodeForItemID:((ItemDescription *)itemLink).item.itemID
                                                                                                   inCtx:[itemLink ctx]]];
        } else {
            self.itemInfoLabel.text     = [NSString stringWithFormat:@"OG (z|1|2|3):  %@ | %@ | %@ | %@",
                                           [NSDecimalNumber decimalNumberWithString:
                                            [NSString stringWithFormat:@"0%@", ((ItemDescription *)itemLink).item.orderUnitExtraChargeQTY]],
                                           [NSDecimalNumber decimalNumberWithString:
                                            [NSString stringWithFormat:@"0%@", ((ItemDescription *)itemLink).item.orderUnitBoxQTY]],
                                           [NSDecimalNumber decimalNumberWithString:
                                            [NSString stringWithFormat:@"0%@", ((ItemDescription *)itemLink).item.orderUnitLayerQTY]],
                                           [NSDecimalNumber decimalNumberWithString:
                                            [NSString stringWithFormat:@"0%@", ((ItemDescription *)itemLink).item.orderUnitPalletQTY]]];
        }
        self.itemPriceLabel.text        = [self.currencyFormatter stringFromNumber:((ItemDescription *)itemLink).item.price];
        self.itemTrademarkHolderLabel.text  = [LocalizedDescription textForKey:@"ItemTrademarkHolder" 
                                                                      withCode:((ItemDescription *)itemLink).item.trademarkHolder 
                                                        inCtx:[itemLink ctx]];
        if (!self.itemTrademarkHolderLabel.text || self.itemTrademarkHolderLabel.text.length == 0) { 
            self.itemTrademarkHolderLabel.text = [LocalizedDescription textForKey:@"ItemCountryOfOrigin" 
                                                                         withCode:((ItemDescription *)itemLink).item.countryOfOriginCode 
                                                           inCtx:[itemLink ctx]];
        }
        self.itemPackageLabel.text          = [LocalizedDescription textForKey:@"ItemPackage" 
                                                                      withCode:((ItemDescription *)itemLink).item.itemPackageCode 
                                                        inCtx:[itemLink ctx]];
        currentOrderQTY                 = [ArchiveOrderLine currentOrderQTYForItem:((ItemDescription *)itemLink).item.itemID 
                                                            inCtx:[itemLink ctx]];
        storeAssortmentBit              = [((ItemDescription *)itemLink).item.storeAssortmentBit boolValue];
    } else if ([itemLink isKindOfClass:[ItemCode class]]) { 
        self.itemDescriptionLabel.text  = [NSString stringWithFormat:@"%@", [Item localDescriptionTextForItem:((ItemCode *)itemLink).item]];
        self.itemIDLabel.text           = [NSString stringWithFormat:@"     %@", ((ItemCode *)itemLink).item.itemID];
        if (NO) {
            self.itemInfoLabel.text     = [NSString stringWithFormat:@"EAN: %@", ((ItemCode *)itemLink).code];
        } else {
            self.itemInfoLabel.text     = [NSString stringWithFormat:@"OG (z|1|2|3):  %@ | %@ | %@ | %@",
                                           [NSDecimalNumber decimalNumberWithString:
                                            [NSString stringWithFormat:@"0%@", ((ItemCode *)itemLink).item.orderUnitExtraChargeQTY]],
                                           [NSDecimalNumber decimalNumberWithString:
                                            [NSString stringWithFormat:@"0%@", ((ItemCode *)itemLink).item.orderUnitBoxQTY]],
                                           [NSDecimalNumber decimalNumberWithString:
                                            [NSString stringWithFormat:@"0%@", ((ItemCode *)itemLink).item.orderUnitLayerQTY]],
                                           [NSDecimalNumber decimalNumberWithString:
                                            [NSString stringWithFormat:@"0%@", ((ItemCode *)itemLink).item.orderUnitPalletQTY]]];
        }
        self.itemPriceLabel.text        = [self.currencyFormatter stringFromNumber:((ItemCode *)itemLink).item.price];
        self.itemTrademarkHolderLabel.text  = [LocalizedDescription textForKey:@"ItemTrademarkHolder" 
                                                                      withCode:((ItemCode *)itemLink).item.trademarkHolder 
                                                        inCtx:[itemLink ctx]];
        if (!self.itemTrademarkHolderLabel.text || self.itemTrademarkHolderLabel.text.length == 0) { 
            self.itemTrademarkHolderLabel.text = [LocalizedDescription textForKey:@"ItemCountryOfOrigin" 
                                                                         withCode:((ItemCode *)itemLink).item.countryOfOriginCode 
                                                           inCtx:[itemLink ctx]];
        }
        self.itemPackageLabel.text          = [LocalizedDescription textForKey:@"ItemPackage" 
                                                                      withCode:((ItemCode *)itemLink).item.itemPackageCode 
                                                        inCtx:[itemLink ctx]];
        currentOrderQTY                 = [ArchiveOrderLine currentOrderQTYForItem:((ItemCode *)itemLink).item.itemID 
                                                            inCtx:[itemLink ctx]];
        storeAssortmentBit              = [((ItemCode *)itemLink).item.storeAssortmentBit boolValue];
    }
    NSDecimalNumber *tmpItemQTYdecimal = [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%i", currentOrderQTY]];
    Item *item = nil;
    if ([itemLink isKindOfClass:[Item class]]) {
        item = ((Item *)itemLink);
    } else {
        item = [(id<ItemHolder>)itemLink item];
    }
    if ([item.orderUnitCode isEqualToString:@"KG"] ||
        [item.orderUnitCode isEqualToString:@"LT"]) {
        tmpItemQTYdecimal = [tmpItemQTYdecimal decimalNumberByDividingBy:[NSDecimalNumber decimalNumberWithString:@"1000"]];
    }
    self.dataLineQTYLabel.text          = [NSString stringWithFormat:@"%5@", tmpItemQTYdecimal];
    self.dataLineQTYLabel.textColor     = [UIColor blackColor];
    self.itemIDLabel.text        = [NSString stringWithFormat:@"   %@", [self.itemLink itemID]];
    if (!storeAssortmentBit) { 
        self.itemDescriptionLabel.textColor     = [[UIColor alloc] initWithRed:232.0 / 255 green:31.0 / 255 blue:23.0 / 255 alpha: 1.0];
        self.itemTrademarkHolderLabel.textColor = [[UIColor alloc] initWithRed:232.0 / 255 green:31.0 / 255 blue:23.0 / 255 alpha: 0.9];
        self.itemPackageLabel.textColor         = [[UIColor alloc] initWithRed:232.0 / 255 green:31.0 / 255 blue:23.0 / 255 alpha: 0.9];
        self.currentOrderQTYLabel.textColor     = [[UIColor alloc] initWithRed:255.0 / 255 green:128.0 / 255 blue:0.0 / 255 alpha: 0.8];
        self.itemInfoLabel.textColor            = [[UIColor alloc] initWithRed:255.0 / 255 green:128.0 / 255 blue:0.0 / 255 alpha: 0.8];
        self.itemIDLabel.textColor              = [[UIColor alloc] initWithRed:255.0 / 255 green:128.0 / 255 blue:0.0 / 255 alpha: 0.8];
        self.itemPriceLabel.textColor           = [[UIColor alloc] initWithRed:255.0 / 255 green:128.0 / 255 blue:0.0 / 255 alpha: 0.8];
    } else {
        self.itemDescriptionLabel.textColor     = [[UIColor alloc] initWithRed:0.0 / 255 green:0.0 / 255 blue:0.0 / 255 alpha: 0.90];
        self.itemTrademarkHolderLabel.textColor = [[UIColor alloc] initWithRed:0.0 / 255 green:0.0 / 255 blue:0.0 / 255 alpha: 0.70];
        self.itemPackageLabel.textColor         = [[UIColor alloc] initWithRed:0.0 / 255 green:0.0 / 255 blue:0.0 / 255 alpha: 0.70];
        self.currentOrderQTYLabel.textColor     = [UIColor darkGrayColor];
        self.itemInfoLabel.textColor            = [UIColor darkGrayColor];
        self.itemIDLabel.textColor              = [UIColor darkGrayColor];
        self.itemPriceLabel.textColor           = [UIColor darkGrayColor];
    }
    if (self.accessoryView && 
        [(UIButton *)self.accessoryView imageForState:UIControlStateNormal] == [UIImage imageNamed:@"addButton.png"] &&
        [[NSDecimalNumber zero] compare:[NSDecimalNumber decimalNumberWithString:self.dataLineQTYLabel.text]] != NSOrderedSame) { 
            [(UIButton *)self.accessoryView setImage:[UIImage imageNamed:@"addButton_m.png"] forState:UIControlStateNormal];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}


@end