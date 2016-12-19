//
//  DSPF_SwitcherView.m
//  dphHermes
//
//  Created by Denis Kurochkin on 09.11.15.
//
//

#import "DSPF_SwitcherView.h"
#import "AppStyle.h"

@interface SwitcherStateObject : NSObject
@property (nonatomic,copy) NSString* title;
@property (nonatomic,retain) NSDictionary* options;
@end
@implementation SwitcherStateObject
- (void) dealloc
{
    [_title release];
    [_options release];
    [super dealloc];
}
@end

@interface DSPF_SwitcherView()
{
}

@property (retain, nonatomic) IBOutlet UILabel *titleLabel;
@property (retain, nonatomic) NSMutableArray *statesArray;

@end

@implementation DSPF_SwitcherView

@synthesize delegate = _delegate;
@synthesize numberOfStates = _numberOfStates;

- (id) init
{
    self = [super init];
    if (self)
    {
        [self internalInit];
        _currentState = 0;
    }
    
    return self;
}

- (void) internalInit
{
    self.statesArray = [NSMutableArray array];
    [_prevButton addTarget:self action:@selector(switchPrev:) forControlEvents:UIControlEventTouchUpInside];
    [_nextButton addTarget:self action:@selector(switchNext:) forControlEvents:UIControlEventTouchUpInside];
    _titleLabel.text = @"";
    _prevButton.hidden = YES;
    _nextButton.hidden = YES;
    _titleLabel.textColor = [UIColor appMainFontColor];
    
}

- (void) awakeFromNib
{
    [self internalInit];
}

#pragma mark - Internal Implementation

- (void) switchNext:(id)sender
{
    _currentState++;
    [self switchToState:_currentState];
}

- (void) switchPrev:(id)sender
{
    _currentState--;
    [self switchToState:_currentState];
}

- (void) switchToState:(NSInteger) state
{
    if (_statesArray.count <= state)
        return;
    
    SwitcherStateObject *currentObject = _statesArray[state];
    _titleLabel.text = currentObject.title;
    [self refreshButtonsVisibility];
    
    if (!_delegate || ![_delegate respondsToSelector:@selector(switcherView:didSwitchToStateWithOptions:)])
        return;
    
    [_delegate switcherView:self didSwitchToStateWithOptions:currentObject.options];
    
}

- (void) refreshButtonsVisibility
{
    _prevButton.hidden = (_currentState == 0);
    _nextButton.hidden = (_currentState == (_statesArray.count-1));
}

- (NSInteger) numberOfStates
{
    return _statesArray.count;
}

#pragma mark - Interface Methods

- (void) addStateWithTitle:(NSString *)title options:(NSDictionary *)options
{
    if (_statesArray.count == 0)
        _titleLabel.text = title;
    
    SwitcherStateObject *state = [[SwitcherStateObject new] autorelease];
    state.title = title;
    state.options = options;
    [_statesArray addObject:state];
    
    [self refreshButtonsVisibility];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)dealloc {
    [_titleLabel release];
    [_prevButton release];
    [_nextButton release];
    [_statesArray release];
    [super dealloc];
}
@end
