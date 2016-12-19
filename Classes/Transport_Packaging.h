//
//  Transport_Packaging.h
//  Hermes
//
//  Created by iLutz on 05.09.13.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Transport;

@interface Transport_Packaging : NSManagedObject

+ (Transport_Packaging *)transportPackagingWithServerData:(NSDictionary *)serverData inCtx:(NSManagedObjectContext *)aCtx;
+ (NSArray *)transportPackagingsWithPredicate:(NSPredicate *)aPredicate sortDescriptors:(NSArray *)sortDescriptors inCtx:(NSManagedObjectContext *)aCtx;

@property (nonatomic, strong) NSString * code;
@property (nonatomic, strong) NSString * description_text;
@property (nonatomic, strong) NSNumber * transport_packaging_id;
@property (nonatomic, strong) NSNumber * isRelevantForTransportation;
@property (nonatomic, strong) NSNumber * footprint_x;
@property (nonatomic, strong) NSNumber * footprint_y;
@property (nonatomic, strong) NSNumber * footprint_z;
@property (nonatomic, strong) NSSet *transport_id;
@end

@interface Transport_Packaging (CoreDataGeneratedAccessors)

- (void)addTransport_idObject:(Transport *)value;
- (void)removeTransport_idObject:(Transport *)value;
- (void)addTransport_id:(NSSet *)values;
- (void)removeTransport_id:(NSSet *)values;
@end
