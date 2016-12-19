//
//  Recipient.h
//  Hermes
//
//  Created by Lutz  Thalmann on 10.05.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Location;

@interface Recipient : NSManagedObject {
}

@property (nonatomic, strong) NSString * recipient_name;
@property (nonatomic, strong) Location * location_id;

@end
