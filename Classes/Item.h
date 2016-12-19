//
//  Item.h
//  dphHermes
//
//  Created by iLutz on 01.07.14.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

extern NSString * const ItemCategoryReturnablePackages;
extern NSString * const ItemCategoryTransportGoods;
extern NSString * const ItemCategoryTransportServices;

@class Item;
@class ItemCode;
@class ItemDescription;
@class ItemProductInformation;
@class Promotion;
@class Hitlist;
@class BasketAnalysis;
@class ArchiveOrderLine;
@class TemplateOrderLine;
@class InventoryLine;
@class Transport;

@protocol ItemHolder <NSObject>
@property (nonatomic, retain) Item *item;
@end

@interface Item : NSManagedObject<ItemHolder>

+ (Item    *)itemWithServerData:(NSDictionary *)serverData inCtx:(NSManagedObjectContext *)aCtx;
+ (Item    *)itemPriceWithServerData:(NSDictionary *)serverData inCtx:(NSManagedObjectContext *)aCtx;
+ (Item    *)itemAssortmentWithServerData:(NSDictionary *)serverData inCtx:(NSManagedObjectContext *)aCtx;
+ (NSArray *)itemsWithPredicate:(NSPredicate  *)aPredicate sortDescriptors:(NSArray *)sortDescriptors inCtx:(NSManagedObjectContext *)aCtx;
+ (Item    *)itemWithItemID:(NSString *)itemID inCtx:(NSManagedObjectContext *)aCtx;
+ (Item    *)managedObjectWithItemID:(NSString *)itemID inCtx:(NSManagedObjectContext *)aCtx;
+ (NSString *)localDescriptionTextForItem:(Item *)aItem;
+ (NSString *)localProductInformationTextForItem:(Item *)aItem;

@property (nonatomic, strong) NSNumber * bestBeforeDays;
@property (nonatomic, strong) NSDecimalNumber * buyingPrice;
@property (nonatomic, strong) NSString * countryOfOriginCode;
@property (nonatomic, strong) NSString * itemCategoryCode;
@property (nonatomic, strong) NSString * itemCertificationCode;
@property (nonatomic, strong) NSString * itemID;
@property (nonatomic, strong) NSString * itemPackageCode;
@property (nonatomic, strong) NSNumber * newcomerBit;
@property (nonatomic, strong) NSDecimalNumber * orderUnitBoxQTY;
@property (nonatomic, strong) NSString * orderUnitCode;
@property (nonatomic, strong) NSDecimalNumber * orderUnitExtraChargeQTY;
@property (nonatomic, strong) NSDecimalNumber * orderUnitLayerQTY;
@property (nonatomic, strong) NSDecimalNumber * orderUnitPalletQTY;
@property (nonatomic, strong) NSDecimalNumber * price;
@property (nonatomic, strong) NSString * priceText;
@property (nonatomic, strong) NSString * productGroup;
@property (nonatomic, strong) NSString * salesUnitCode;
@property (nonatomic, strong) NSNumber * salesUnitsPerOrderUnit;
@property (nonatomic, strong) NSNumber * storeAssortmentBit;
@property (nonatomic, strong) NSString * storeAssortmentCode;
@property (nonatomic, strong) NSString * trademarkHolder;
@property (nonatomic, strong) NSDecimalNumber * valueAddedTax;
@property (nonatomic, strong) NSNumber * isItemIDScannable;
@property (nonatomic, strong) NSDecimalNumber * paymentOnPickup;
@property (nonatomic, strong) NSDecimalNumber * paymentOnDelivery;
@property (nonatomic, strong) NSDecimalNumber * grossWeight;
@property (nonatomic, strong) NSDecimalNumber * netWeight;
@property (nonatomic, strong) NSString * temperatureZone;
@property (nonatomic, strong) NSNumber * temperatureLimit;
@property (nonatomic, strong) NSSet *archiveOrderLine;
@property (nonatomic, strong) BasketAnalysis *basketAnalysis;
@property (nonatomic, strong) BasketAnalysis *basketAnalyzedItem;
@property (nonatomic, strong) Hitlist *hitlist;
@property (nonatomic, strong) NSSet *inventoryLine;
@property (nonatomic, strong) Item *item;
@property (nonatomic, strong) NSSet *itemCode;
@property (nonatomic, strong) NSSet *itemDescription;
@property (nonatomic, strong) NSSet *itemProductInformation;
@property (nonatomic, strong) Promotion *promotion;
@property (nonatomic, strong) NSSet *templateOrderLine;
@property (nonatomic, strong) NSSet *transport;
@end

@interface Item (CoreDataGeneratedAccessors)

- (void)addArchiveOrderLineObject:(ArchiveOrderLine *)value;
- (void)removeArchiveOrderLineObject:(ArchiveOrderLine *)value;
- (void)addArchiveOrderLine:(NSSet *)values;
- (void)removeArchiveOrderLine:(NSSet *)values;

- (void)addInventoryLineObject:(InventoryLine *)value;
- (void)removeInventoryLineObject:(InventoryLine *)value;
- (void)addInventoryLine:(NSSet *)values;
- (void)removeInventoryLine:(NSSet *)values;

- (void)addItemCodeObject:(ItemCode *)value;
- (void)removeItemCodeObject:(ItemCode *)value;
- (void)addItemCode:(NSSet *)values;
- (void)removeItemCode:(NSSet *)values;

- (void)addItemDescriptionObject:(ItemDescription *)value;
- (void)removeItemDescriptionObject:(ItemDescription *)value;
- (void)addItemDescription:(NSSet *)values;
- (void)removeItemDescription:(NSSet *)values;

- (void)addItemProductInformationObject:(ItemProductInformation *)value;
- (void)removeItemProductInformationObject:(ItemProductInformation *)value;
- (void)addItemProductInformation:(NSSet *)values;
- (void)removeItemProductInformation:(NSSet *)values;

- (void)addTemplateOrderLineObject:(TemplateOrderLine *)value;
- (void)removeTemplateOrderLineObject:(TemplateOrderLine *)value;
- (void)addTemplateOrderLine:(NSSet *)values;
- (void)removeTemplateOrderLine:(NSSet *)values;

- (void)addTransportObject:(Transport *)value;
- (void)removeTransportObject:(Transport *)value;
- (void)addTransport:(NSSet *)values;
- (void)removeTransport:(NSSet *)values;

@end
