//
//  Payment_Type.h
//  Hermes
//
//  Created by Lutz  Thalmann on 12.05.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>

@class Transport;

@interface Payment_Type : NSManagedObject {
}

@property (nonatomic, strong) NSString * code;
@property (nonatomic, strong) NSString * description_text;
@property (nonatomic, strong) NSNumber * payment_type_id;
@property (nonatomic, strong) NSSet* transport_id;

@end
