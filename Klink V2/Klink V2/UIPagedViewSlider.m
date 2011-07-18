//
//  UIPagedViewSlider.m
//  Klink V2
//
//  Created by Bobby Gill on 7/14/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import "UIPagedViewSlider.h"
#import <QuartzCore/QuartzCore.h>

#define kNumPicturesToLoad 3;
@implementation UIPagedViewSlider
@synthesize sv_slider;
@synthesize m_viewList;
@synthesize m_itemWidth;
@synthesize m_itemHeight;
@synthesize m_itemSpacing;
@synthesize m_lastScrollPosition;
@synthesize m_numItemsToLoadOnScroll;
@synthesize delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        sv_slider = [[UIScrollView alloc]initWithFrame:frame];
        
        self.m_numItemsToLoadOnScroll = kNumPicturesToLoad;
        self.m_viewList = [[NSMutableArray alloc]init];
    }
    return self;
}

- (id) initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
        int width = CGRectGetWidth(self.frame);
        int height = CGRectGetHeight(self.frame);
        
        CGRect sliderFrame = CGRectMake(0, 0, width, height);
        sv_slider = [[UIScrollView alloc]initWithFrame:sliderFrame];
        sv_slider.delegate = self;
        sv_slider.pagingEnabled = YES;
        sv_slider.bounces = YES;
        sv_slider.scrollEnabled = YES;
        sv_slider.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        sv_slider.autoresizesSubviews = YES;
        sv_slider.layer.borderColor = [UIColor redColor].CGColor;
        sv_slider.layer.borderWidth = 4.4f;
        self.m_numItemsToLoadOnScroll = kNumPicturesToLoad;
        self.m_viewList = [[NSMutableArray alloc]init];
        [self addSubview:sv_slider];
        
    }
    return self;
}

- (id) initWith:(int)itemWidth itemHeight:(int)itemHeight itemSpacing:(int)itemSpacing{
    self.m_itemHeight = itemHeight;
    self.m_itemWidth = itemWidth;
    self.m_itemSpacing = itemSpacing;
    self.m_numItemsToLoadOnScroll = kNumPicturesToLoad;
    return self;
}



- (CGSize) getContentSize {
    int numberOfItems = [m_viewList count];
    
    float width = (self.m_itemWidth + self.m_itemSpacing)*numberOfItems;
    float height = self.m_itemHeight;
    
    CGSize retVal = CGSizeMake(width, height);
    return retVal;
}

- (void) resetSliderWithItems:(NSArray*)items {
    //Reset the slider and view array to be empty
    [[self.sv_slider subviews] makeObjectsPerformSelector: @selector(removeFromSuperview)];
    self.sv_slider.contentOffset = CGPointMake(0, 0);
    [m_viewList removeAllObjects];
    
    //enumerate through passed items and add to the view array and slider
    for (int i = 0; i < [items count];i++) {
        UIView* cellView = [self.delegate viewSlider:self cellForRowAtIndex:i];
        
        [m_viewList insertObject:cellView atIndex:i];
        [self.sv_slider addSubview:cellView];
    }        
    self.sv_slider.contentSize = [self getContentSize];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)dealloc
{
    [super dealloc];
}




- (void) item:(id)object insertedAt:(int)index {    
    UIView* cellView = [self.delegate viewSlider:self cellForRowAtIndex:index];    
    [m_viewList insertObject:cellView atIndex:index];        
    sv_slider.contentSize = [self getContentSize];
    [sv_slider addSubview:cellView];    
}

- (void) item:(id)object atIndex:(int)index movedTo:(int)newIndex {
    [m_viewList replaceObjectAtIndex:index withObject:[NSNull null]];
    UIView* cellView = [self.delegate viewSlider:self cellForRowAtIndex:newIndex];
    UIView* oldCell = [m_viewList objectAtIndex:index];
    [oldCell removeFromSuperview];

    if (newIndex > [m_viewList count]-1) {
        //insert new item in the viewlist
       
        [m_viewList insertObject:cellView atIndex:newIndex];
        sv_slider.contentSize = [self getContentSize];
        [sv_slider addSubview:cellView];
               
    }
    else {
        [m_viewList replaceObjectAtIndex:newIndex withObject:cellView];
        [sv_slider addSubview:cellView];
    }
}



- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGPoint position =  self.sv_slider.contentOffset;
    int index = position.x / (m_itemWidth + m_itemSpacing);
    if (index != self.m_lastScrollPosition) {
        int numberOfCellsRemaining = ([self.m_viewList count]-1) - index;        
        [self.delegate viewSlider:self isAtIndex:index withCellsRemaining:numberOfCellsRemaining];
        self.m_lastScrollPosition = index;

    
    }

}
#pragma mark - Scroll Accessors/Settors
- (void)setContentOffsetTo:(int)index {
    int xCoordinate = (self.m_itemWidth+self.m_itemSpacing)*index;
    CGPoint offset = CGPointMake(xCoordinate, 0);
    self.sv_slider.contentOffset = offset;
}
- (int)getContentOffsetIndex {

    
    int index = self.sv_slider.contentOffset.x/(self.m_itemSpacing+self.m_itemWidth);
    
    return index;
}
        

@end
