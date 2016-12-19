//
//  DSPF_OrderTableViewCell.m
//  Hermes
//
//  Created by iLutz on 07.12.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "HermesAppDelegate.h"
#import "DSPF_OrderTableViewCell.h"

#import "ArchiveOrderLine.h"
#import "TemplateOrderLine.h"

#import "Item.h"
#import "ItemDescription.h"
#import "ItemCode.h"

@implementation DSPF_OrderTableViewCell

@synthesize dataLine;
@synthesize dataLineQTYLabel;
@synthesize itemDescriptionLabel;
@synthesize currentOrderQTYLabel;
@synthesize currentOrderCHKLabel;
@synthesize itemInfoLabel;
@synthesize itemIDLabel;
@synthesize itemPriceLabel;
@synthesize orderTask;
@synthesize currencyFormatter;
@synthesize ctx;


#pragma mark - Initialization

- (NSManagedObjectContext *)ctx {
    if (!ctx) { 
		ctx = [(HermesAppDelegate *)[[UIApplication sharedApplication] delegate] ctx];
    }
    return ctx;
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

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentView.backgroundColor = [UIColor clearColor];
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
        
        currentOrderCHKLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        currentOrderCHKLabel.backgroundColor = self.contentView.backgroundColor;
        [currentOrderCHKLabel setTextAlignment:TextAlignmentRight];
        [currentOrderCHKLabel setFont:[UIFont systemFontOfSize:14.0]];
        [currentOrderCHKLabel setTextColor:[UIColor darkGrayColor]];
        [currentOrderCHKLabel setHighlightedTextColor:[UIColor whiteColor]];
        currentOrderCHKLabel.minimumFontSize = 7.0;
        currentOrderCHKLabel.lineBreakMode = UILineBreakModeTailTruncation;
        [self.contentView addSubview:currentOrderCHKLabel];
        
        itemInfoLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        itemInfoLabel.backgroundColor = self.contentView.backgroundColor;
        [itemInfoLabel setFont:[UIFont systemFontOfSize:14.0]];
        [itemInfoLabel setTextColor:[UIColor darkGrayColor]];
        [itemInfoLabel setHighlightedTextColor:[UIColor whiteColor]];
        itemInfoLabel.minimumFontSize = 7.0;
        itemInfoLabel.lineBreakMode = UILineBreakModeTailTruncation;
        [self.contentView addSubview:itemInfoLabel];
        
        itemIDLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        itemIDLabel.backgroundColor = self.contentView.backgroundColor;
        [itemIDLabel setFont:[UIFont  fontWithName:@"Helvetica-Bold" size:12]];
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
        [itemDescriptionLabel setFont:[UIFont  fontWithName:@"Helvetica-Bold" size:16]];
        [itemDescriptionLabel setTextColor:[[UIColor alloc] initWithRed:23.0 / 255 green:48.0 / 255 blue:72.0 / 255 alpha: 0.8]];
        [itemDescriptionLabel setHighlightedTextColor:[UIColor whiteColor]];
        itemDescriptionLabel.minimumFontSize = 8.0;
        itemDescriptionLabel.lineBreakMode = UILineBreakModeTailTruncation;
        [self.contentView addSubview:itemDescriptionLabel];
        
        dataLineQTYLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        dataLineQTYLabel.backgroundColor = self.contentView.backgroundColor;
        [dataLineQTYLabel setTextAlignment:TextAlignmentRight];
        [dataLineQTYLabel setFont:[UIFont  fontWithName:@"Helvetica-Bold" size:16]];
        [dataLineQTYLabel setTextColor:[UIColor blackColor]];
        [dataLineQTYLabel setHighlightedTextColor:[UIColor whiteColor]];
        dataLineQTYLabel.minimumFontSize = 8.0;
        dataLineQTYLabel.lineBreakMode = UILineBreakModeTailTruncation;
        [self.contentView addSubview:dataLineQTYLabel];
    }
    return self;
}

#pragma mark - Laying out subviews

#define TEXT_LEFT_MARGIN    8.0
#define TEXT_RIGHT_MARGIN  34.0

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
    [self.itemPriceLabel setFrame:
     CGRectMake(self.itemDescriptionLabel.frame.origin.x,  
                (2 * 3.0)
                + [@"anyText" sizeWithFont:self.itemDescriptionLabel.font].height, 
                [self.itemPriceLabel.text sizeWithFont:self.itemPriceLabel.font].width, 
                [@"anyText"               sizeWithFont:self.itemPriceLabel.font].height)]; 
//
// Line 3: currentOrderQTY | itemInfo | itemID
    [self.currentOrderCHKLabel setFrame:
     CGRectMake(0 , 
                3 * 3.0 
                + [@"anyText" sizeWithFont:self.dataLineQTYLabel.font].height 
                + [@"anyText" sizeWithFont:self.currentOrderQTYLabel.font].height, 
                [self.currentOrderCHKLabel.text sizeWithFont:self.currentOrderCHKLabel.font].width, 
//              [@"1.234"     sizeWithFont:self.dataLineQTYLabel.font].width + TEXT_LEFT_MARGIN,
                [@"anyText"   sizeWithFont:self.currentOrderCHKLabel.font].height)];
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

- (void)setDataLine:(id )newDataLine {
    if (newDataLine != dataLine) {
        dataLine = newDataLine;
    }
    self.dataLineQTYLabel.text     = @"";
    self.itemDescriptionLabel.text = @"";
    self.currentOrderQTYLabel.text = @"";
    self.currentOrderCHKLabel.text = @"";
    self.itemInfoLabel.text        = @"";
    self.itemIDLabel.text          = @"";
    self.itemPriceLabel.text       = @"";
    Item *item = nil;
    if ([self.dataLine conformsToProtocol:@protocol(ItemHolder)]) {
        item = [(id<ItemHolder>)self.dataLine item];
    }
    if ([self.dataLine isKindOfClass:[TemplateOrderLine class]]) {
        self.itemIDLabel.text    = [NSString stringWithFormat:@"   %@", item.itemID];
        NSUInteger  tmpItemQTY   = [ArchiveOrderLine currentOrderQTYForItem:item.itemID 
                                                     inCtx:[self.dataLine ctx]]; 
        if (tmpItemQTY == 0) {
            self.currentOrderCHKLabel.text = @"🅾";
        } else if ([[self.dataLine itemQTY] unsignedIntValue] == tmpItemQTY && 
                   [[self.dataLine itemQTY] unsignedIntValue] != 0) {
            self.currentOrderCHKLabel.text = @"🆗";
        } else if ([[self.dataLine itemQTY] unsignedIntValue] > tmpItemQTY &&
                   [[self.dataLine itemQTY] unsignedIntValue] != 0) {
            self.currentOrderCHKLabel.text = @"⬇";
        } else if ([[self.dataLine itemQTY] unsignedIntValue] < tmpItemQTY &&
                   [[self.dataLine itemQTY] unsignedIntValue] != 0) {
            self.currentOrderCHKLabel.text = @"⬆";
        } else {
            self.currentOrderCHKLabel.text = @"";
        } 
        if ([[self.dataLine itemQTY] unsignedIntValue] == 0) {
            self.currentOrderQTYLabel.text = @"";
        } else { 
            NSDecimalNumber *tmpItemQTYdecimal = [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%i", [[self.dataLine itemQTY] intValue]]];
            if ([item.orderUnitCode isEqualToString:@"KG"] ||
                [item.orderUnitCode isEqualToString:@"LT"]) { 
                tmpItemQTYdecimal = [tmpItemQTYdecimal decimalNumberByDividingBy:[NSDecimalNumber decimalNumberWithString:@"1000"]];
            }
            self.currentOrderQTYLabel.text = [NSString stringWithFormat:@"%5@", tmpItemQTYdecimal];
        }
        NSDecimalNumber *tmpItemQTYdecimal = [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%i", tmpItemQTY]];
        if ([item.orderUnitCode isEqualToString:@"KG"] ||
            [item.orderUnitCode isEqualToString:@"LT"]) { 
            tmpItemQTYdecimal = [tmpItemQTYdecimal decimalNumberByDividingBy:[NSDecimalNumber decimalNumberWithString:@"1000"]];
        }
        self.dataLineQTYLabel.text     = [NSString stringWithFormat:@"%5@", tmpItemQTYdecimal];
    } else if ([self.dataLine isKindOfClass:[ArchiveOrderLine class]]) {
        self.itemIDLabel.text          = [NSString stringWithFormat:@"   %@", item.itemID];
        NSDecimalNumber *tmpItemQTYdecimal = [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%i", [[self.dataLine itemQTY] intValue]]];
        if ([item.orderUnitCode isEqualToString:@"KG"] ||
            [item.orderUnitCode isEqualToString:@"LT"]) { 
            tmpItemQTYdecimal = [tmpItemQTYdecimal decimalNumberByDividingBy:[NSDecimalNumber decimalNumberWithString:@"1000"]];
        }
        self.dataLineQTYLabel.text     = [NSString stringWithFormat:@"%5@", tmpItemQTYdecimal]; 
        self.currentOrderCHKLabel.text = @"";
        self.currentOrderQTYLabel.text = @"";
    } else if ([self.dataLine isKindOfClass:[Item class]]) {
        self.itemIDLabel.text          = [NSString stringWithFormat:@"   %@", item.itemID];
        NSDecimalNumber *tmpItemQTYdecimal = [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%i", 
                                                [ArchiveOrderLine currentOrderQTYForItem:item.itemID inCtx:[item managedObjectContext]]]];
        if ([item.orderUnitCode isEqualToString:@"KG"] ||
            [item.orderUnitCode isEqualToString:@"LT"]) { 
            tmpItemQTYdecimal = [tmpItemQTYdecimal decimalNumberByDividingBy:[NSDecimalNumber decimalNumberWithString:@"1000"]];
        }
        self.dataLineQTYLabel.text     = [NSString stringWithFormat:@"%5@", tmpItemQTYdecimal]; 
        self.currentOrderCHKLabel.text = @"";
        self.currentOrderQTYLabel.text = @"";
    } else { 
        if ([self.dataLine valueForKey:@"itemid"]) { 
            self.itemIDLabel.text      = [NSString stringWithFormat:@"%@", [self.dataLine valueForKey:@"itemid"]];
            item = [Item itemWithItemID:[self.dataLine valueForKey:@"itemid"] inCtx:self.ctx];
        } else { 
            self.itemIDLabel.text      = @"???";
            item = nil;
        }
        self.dataLineQTYLabel.text     = [NSString stringWithFormat:@"%@", [self.dataLine valueForKey:@"qty"]]; 
        self.currentOrderCHKLabel.text = @"";
        self.currentOrderQTYLabel.text = @"";
    }
    if (item) { 
        self.itemDescriptionLabel.text  = [NSString stringWithFormat:@"%@", [Item localDescriptionTextForItem:item]];
        self.itemInfoLabel.text         = [NSString stringWithFormat:@"EAN: %@", [ItemCode salesUnitItemCodeForItemID:item.itemID inCtx:item.managedObjectContext]];
        if (item.price) { 
            self.itemPriceLabel.text = [NSString stringWithFormat:@"%@", 
                                        [self.currencyFormatter stringFromNumber:item.price]];
        } else { 
            self.itemPriceLabel.text = @"";
        }
        if (![item.storeAssortmentBit boolValue]) { 
            self.dataLineQTYLabel.textColor     = [[UIColor alloc] initWithRed:232.0 / 255 green:31.0 / 255 blue:23.0 / 255 alpha: 1.0];
            self.itemDescriptionLabel.textColor = [[UIColor alloc] initWithRed:232.0 / 255 green:31.0 / 255 blue:23.0 / 255 alpha: 0.9];
            self.currentOrderQTYLabel.textColor = [[UIColor alloc] initWithRed:255.0 / 255 green:128.0 / 255 blue:0.0 / 255 alpha: 0.8];
            self.itemInfoLabel.textColor        = [[UIColor alloc] initWithRed:255.0 / 255 green:128.0 / 255 blue:0.0 / 255 alpha: 0.8];
            self.itemIDLabel.textColor          = [[UIColor alloc] initWithRed:255.0 / 255 green:128.0 / 255 blue:0.0 / 255 alpha: 0.8];
            self.itemPriceLabel.textColor       = [[UIColor alloc] initWithRed:255.0 / 255 green:128.0 / 255 blue:0.0 / 255 alpha: 0.8];
        } else {
            self.dataLineQTYLabel.textColor     = [UIColor blackColor];
            self.itemDescriptionLabel.textColor = [[UIColor alloc] initWithRed:23.0 / 255 green:48.0 / 255 blue:72.0 / 255 alpha: 0.8];
            self.currentOrderQTYLabel.textColor = [UIColor darkGrayColor];
            self.itemInfoLabel.textColor        = [UIColor darkGrayColor];
            self.itemIDLabel.textColor          = [UIColor darkGrayColor];
            self.itemPriceLabel.textColor       = [UIColor darkGrayColor];
        }
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