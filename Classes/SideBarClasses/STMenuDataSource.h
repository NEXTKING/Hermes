//
//  STMenuDataSource.h
//  dphHermes
//
//  Created by Denis Kurochkin on 05.11.15.
//
//

#import <Foundation/Foundation.h>

@interface STMenuDataSource : NSObject

@property (nonatomic, retain, readonly) NSArray* cells;
@property (nonatomic, retain, readonly) UIView* headerView;

@end
