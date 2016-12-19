//
//  DSPF_SegmentedControl_technopark.m
//  dphHermes
//
//  Created by Denis Kurochkin on 17.11.15.
//
//

#import "DSPF_SegmentedControl_technopark.h"

@interface DSPF_SegmentedControl_technopark ()
{
    NSMutableDictionary *selectedImages;
    NSInteger savedSelectedIndex;
    
}

@property (nonatomic, retain) UIImage* savedSelectedImage;

@end

@implementation DSPF_SegmentedControl_technopark

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (id) init
{
    self = [super init];
    if (self)
    {
        [self internalInit];
    }
    
    return self;
}

- (id) initWithItems:(NSArray *)items
{
    self = [super initWithItems:items];
    if (self)
    {
        [self internalInit];
    }
    
    return self;
}

- (void) internalInit
{
    selectedImages = [NSMutableDictionary new];
    savedSelectedIndex = -1;
    [self addTarget:self action:@selector(selectedInternalAction) forControlEvents:UIControlEventValueChanged];
}

- (void) setSelectedImage:(UIImage *)image forSegment:(NSUInteger)segment
{
    [selectedImages setObject:image forKey:[NSString stringWithFormat:@"%d", segment]];
}



- (void) setSelectedSegmentIndex:(NSInteger)selectedSegmentIndex
{
    [super setSelectedSegmentIndex:selectedSegmentIndex];
    [self exchangeSelectedImageForSegment:selectedSegmentIndex];
    
}

- (void) exchangeSelectedImageForSegment:(NSInteger)selectedSegmentIndex
{
    if (selectedSegmentIndex == savedSelectedIndex)
        return;
    
    if (_savedSelectedImage && savedSelectedIndex>-1)
        [self setImage:_savedSelectedImage forSegmentAtIndex:savedSelectedIndex];
    
    UIImage *selectedImage = [selectedImages objectForKey:[NSString stringWithFormat:@"%d", selectedSegmentIndex]];
    
    if (selectedImage)
    {
        self.savedSelectedImage = [self imageForSegmentAtIndex:selectedSegmentIndex];
        [self setImage:selectedImage forSegmentAtIndex:selectedSegmentIndex];
    }
    else
        self.savedSelectedImage = nil;
    
    savedSelectedIndex = selectedSegmentIndex;
}

- (void) selectedInternalAction
{
    [self exchangeSelectedImageForSegment:self.selectedSegmentIndex];
}

- (void) dealloc
{
    [super dealloc];
    [selectedImages release];
    [_savedSelectedImage release];
}

@end
