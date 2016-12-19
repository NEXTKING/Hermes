//
//  JSONResponseSerializerWithData.h
//  ModelAlliance
//
//  Created by Imac on 29.09.15.
//  Copyright © 2015 Mac. All rights reserved.
//

#import "AFURLResponseSerialization.h"

/// NSError userInfo key that will contain response data
static NSString * const JSONResponseSerializerWithDataKey = @"JSONResponseSerializerWithDataKey";

@interface JSONResponseSerializerWithData : AFJSONResponseSerializer

@end
