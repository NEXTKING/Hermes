//
//  DPHUtilities.h
//  dphHermes
//
//  Created by Tomasz Kransyk on 04.05.15.
//
//

@protocol DPHSynchronizable <NSObject>
+ (NSManagedObject *) fromServerData:(NSDictionary *)serverData inCtx:(NSManagedObjectContext *)aCtx;
+ (NSString *) synchronizationDisplayName;
+ (NSString *) lastUpdatedNSDefaultsKey;
+ (void) willProcessDataFromServer:(NSArray *)serverData option:(NSString *) option inCtx:(NSManagedObjectContext *) ctx;
+ (void) didProcessDataFromServer:(NSArray *)serverData option:(NSString *) option inCtx:(NSManagedObjectContext *) ctx;
@end

enum {		/* What to do with long lines */
    LineBreakModeByWordWrapping = 0,     	/* Wrap at word boundaries, default */
    LineBreakModeByCharWrapping,		/* Wrap at character boundaries */
    LineBreakModeModeByClipping,		/* Simply clip */
    LineBreakModeByTruncatingHead,	/* Truncate at head of line: "...wxyz" */
    LineBreakModeByTruncatingTail,	/* Truncate at tail of line: "abcd..." */
    LineBreakModeByTruncatingMiddle	/* Truncate middle of line:  "ab...yz" */
};
typedef NSInteger LineBreakMode;


enum {
    TextAlignmentLeft      = 0,    // Visually left aligned
    TextAlignmentCenter    = 1,    // Visually centered
    TextAlignmentRight     = 2,    // Visually right aligned
    TextAlignmentJustified = 3,    // Fully-justified. The last line in a paragraph is natural-aligned.
    TextAlignmentNatural   = 4,    // Indicates the default alignment for script
};
typedef NSInteger TextAlignment;

extern NSPredicate * AndPredicates(NSPredicate *predicate, ...) NS_REQUIRES_NIL_TERMINATION;
extern NSPredicate * OrPredicates(NSPredicate *predicate, ...) NS_REQUIRES_NIL_TERMINATION;
extern NSPredicate * NotPredicate(NSPredicate *predicate);

extern NSString * currentLocaleCode(void);
extern id nilOrObject(id objectOrNSNull);
extern id objectOrNSNull(id objectOrNil);

@interface DPHUtilities : NSObject

+ (void) waitForAlertToShow:(CGFloat)waitingTime;

@end

@interface UITableView(Additions)
- (void) deselectSelectedRowAnimated:(BOOL) animated;
@end