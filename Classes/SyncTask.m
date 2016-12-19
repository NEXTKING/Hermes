//
//  SyncTask.m
//  dphHermes
//
//  Created by Tomasz Krasnyk on 09.10.15.
//
//

#import "SyncTask.h"

NSString * const SyncTaskActivityMessageKey = @"SyncTaskActivityMessageKey";


@interface SyncTask()
@property (nonatomic, strong) NSURL *targetURL;
@property (nonatomic, strong) NSDictionary *transferData;
@property (nonatomic, strong) NSManagedObjectID *managedObjectId;
@property (nonatomic, strong) NSDictionary *userInfo;
@end

@implementation SyncTask
@synthesize targetURL;
@synthesize transferData;
@synthesize managedObjectId;
@synthesize userInfo;

- (instancetype) initWithURL:(NSURL *) url dataToTransfer:(NSDictionary *) dataToTransfer managedObjectId:(NSManagedObjectID *) aManagedObjectId {
    return [self initWithURL:url dataToTransfer:dataToTransfer managedObjectId:aManagedObjectId userInfo:nil];
}

- (instancetype) initWithURL:(NSURL *) url dataToTransfer:(NSDictionary *) dataToTransfer managedObjectId:(NSManagedObjectID *) aManagedObjectId userInfo:(NSDictionary *) aUserInfo {
    if ((self = [super init])) {
        self.targetURL = url;
        self.transferData = dataToTransfer;
        self.managedObjectId = aManagedObjectId;
        self.userInfo = aUserInfo;
    }
    return self;
}

- (BOOL)isEqual:(id)object {
    if (self == object) return YES;
    if (![self isMemberOfClass:[object class]]) return NO;
    SyncTask *st = (SyncTask *) object;
    BOOL urlSame = [[[st targetURL] absoluteString] isEqualToString:[[self targetURL] absoluteString]];
    BOOL dictSame = (st.transferData == nil && self.transferData == nil) || [[st transferData] isEqualToDictionary:self.transferData];
    BOOL valueSame = (st.managedObjectId == nil && self.managedObjectId == nil) || ([st.managedObjectId isEqual:self.managedObjectId]);
    return valueSame && dictSame && urlSame;
}

- (NSUInteger) hash {
    return [[NSString stringWithFormat:@"%@%@%@", [targetURL absoluteString], [transferData description], managedObjectId] hash];
}

- (NSString *) description {
    return [NSString stringWithFormat:@"[URL=%@][Data=%@][userInfo=%@]", self.targetURL, self.transferData, self.userInfo];
}

@end