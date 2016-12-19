//
//  SyncTask.h
//  dphHermes
//
//  Created by Tomasz Krasnyk on 09.10.15.
//
//

#import <Foundation/Foundation.h>

extern NSString * const SyncTaskActivityMessageKey;

@interface SyncTask : NSObject {
    
}
@property (nonatomic, strong, readonly) NSURL *targetURL;
@property (nonatomic, strong, readonly) NSDictionary *transferData;
@property (nonatomic, strong, readonly) NSManagedObjectID *managedObjectId;
@property (nonatomic, strong, readonly) NSDictionary *userInfo;

- (instancetype) initWithURL:(NSURL *) url dataToTransfer:(NSDictionary *) dataToTransfer managedObjectId:(NSManagedObjectID *) aManagedObjectId;
- (instancetype) initWithURL:(NSURL *) url dataToTransfer:(NSDictionary *) dataToTransfer managedObjectId:(NSManagedObjectID *) aManagedObjectId userInfo:(NSDictionary *) aUserInfo;
@end