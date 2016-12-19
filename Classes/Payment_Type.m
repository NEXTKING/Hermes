//
//  Payment_Type.m
//  Hermes
//
//  Created by Lutz  Thalmann on 12.05.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Payment_Type.h"
#import "Transport.h"


@implementation Payment_Type
@dynamic code;
@dynamic description_text;
@dynamic payment_type_id;
@dynamic transport_id;

- (void)addTransport_idObject:(Transport *)value {    
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"transport_id" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"transport_id"] addObject:value];
    [self didChangeValueForKey:@"transport_id" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
}

- (void)removeTransport_idObject:(Transport *)value {
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"transport_id" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"transport_id"] removeObject:value];
    [self didChangeValueForKey:@"transport_id" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
}

- (void)addTransport_id:(NSSet *)value {    
    [self willChangeValueForKey:@"transport_id" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"transport_id"] unionSet:value];
    [self didChangeValueForKey:@"transport_id" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
}

- (void)removeTransport_id:(NSSet *)value {
    [self willChangeValueForKey:@"transport_id" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"transport_id"] minusSet:value];
    [self didChangeValueForKey:@"transport_id" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
}


@end
