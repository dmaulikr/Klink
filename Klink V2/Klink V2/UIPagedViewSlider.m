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
@synthesize slider                  =m_slider;
@synthesize viewList                =m_viewList;
@synthesize itemWidth               =m_itemWidth;
@synthesize itemHeight              =m_itemHeight;
@synthesize itemSpacing             =m_itemSpacing;
@synthesize lastScrollPosition      =m_lastScrollPosition;
@synthesize numItemsToLoadOnScroll  =m_numItemsToLoadOnScroll;
@synthesize delegate                =m_delegate;
@synthesize isHorizontalOrientation =m_isHorizontalOrientation;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.slider = [[UIKlinkScrollView alloc]initWithFrame:frame];
        
        self.numItemsToLoadOnScroll = kNumPicturesToLoad;
        self.viewList = [[NSMutableArray alloc]init];
    }
    return self;
}

- (id) initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
        int width = CGRectGetWidth(self.frame);
        int height = CGRectGetHeight(self.frame);
        
        CGRect sliderFrame = CGRectMake(0, 0, width, height);
        self.slider = [[UIKlinkScrollView alloc]initWithFrame:sliderFrame];
        self.slider.delegate = self;
        self.isHorizontalOrientation = YES;
        self.slider.pagingEnabled = YES;
        self.slider.bounces = YES;
        self.slider.scrollEnabled = YES;
        self.slider.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.slider.autoresizesSubviews = YES;
        self.slider.layer.borderColor = [UIColor redColor].CGColor;
        self.slider.layer.borderWidth = 4.4f;
        self.numItemsToLoadOnScroll = kNumPicturesToLoad;
        self.viewList = [[NSMutableArray alloc]init];
        [self addSubview:self.slider];
        
    }
    return self;
}

- (id) initWith:(int)itemWidth itemHeight:(int)itemHeight itemSpacing:(int)itemSpacing{
    self.itemHeight = itemHeight;
    self.itemWidth = itemWidth;
    self.itemSpacing = itemSpacing;
    self.numItemsToLoadOnScroll = kNumPicturesToLoad;
    return self;
}

- (id) initWith:(BOOL)isHorizontalOrientation itemWidth:(int)itemWidth itemHeight:(int)itemHeight itemSpacing:(int)itemSpacing {
    self.isHorizontalOrientation = isHorizontalOrientation;
    [self initWith:itemWidth itemHeight:itemHeight itemSpacing:itemSpacing];
    return self;
}


- (CGSize) getContentSize {
    int numberOfItems = [self.viewList count];
    
    if (self.isHorizontalOrientation) {
        float width = (self.itemWidth + self.itemSpacing)*numberOfItems;
        float height = self.itemHeight;
        
        CGSize retVal = CGSizeMake(width, height);
        return retVal;
    }
    else {
        float width = (self.itemWidth);
        float height = (self.itemHeight+self.itemSpacing) * numberOfItems;
        
        CGSize retVal = CGSizeMake(width,height);
        return retVal;
    }
}

- (void) resetSliderWithItems:(NSArray*)items {
    //Reset the slider and view array to be empty
    [[self.slider subviews] makeObjectsPerformSelector: @selector(removeFromSuperview)];
    self.slider.contentOffset = CGPointMake(0, 0);
    [self.viewList removeAllObjects];
    
    //enumerate through passed items and add to the view array and slider
    for (int i = 0; i < [items count];i++) {
        UIView* cellView = [self.delegate viewSlider:self cellForRowAtIndex:i sliderIsHorizontal:self.isHorizontalOrientation];
        
        [self.viewList insertObject:cellView atIndex:i];
        [self.slider addSubview:cellView];
    }        
    self.slider.contentSize = [self getContentSize];
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
    UIView* cellView = [self.delegate viewSlider:self cellForRowAtIndex:index sliderIsHorizontal:self.isHorizontalOrientation];    
    [self.viewList insertObject:cellView atIndex:index];        
    self.slider.contentSize = [self getContentSize];
    [self.slider addSubview:cellView];    
}

- (void) item:(id)object atIndex:(int)index movedTo:(int)newIndex {
    [self.viewList replaceObjectAtIndex:index withObject:[NSNull null]];
    UIView* cellView = [self.delegate viewSlider:self cellForRowAtIndex:newIndex sliderIsHorizontal:self.isHorizontalOrientation];
    UIView* oldCell = [self.viewList objectAtIndex:index];
    [oldCell removeFromSuperview];

    if (newIndex > [self.viewList count]-1) {
        //insert new item in the viewlist
       
        [self.viewList insertObject:cellView atIndex:newIndex];
        self.slider.contentSize = [self getContentSize];
        [self.slider addSubview:cellView];
               
    }
    else {
        [self.viewList replaceObjectAtIndex:newIndex withObject:cellView];
        [self.slider addSubview:cellView];
    }
}



- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGPoint position =  self.slider.contentOffset;
    int index = 0;
    if (self.isHorizontalOrientation) {
         index = position.x / (self.itemWidth + self.itemSpacing);
    }
    else {
         index = position.y / (self.itemHeight + self.itemSpacing);
    }
    
    if (index != self.lastScrollPosition) {
        int numberOfCellsRemaining = ([self.viewList count]-1) - index;        
        [self.delegate viewSlider:self isAtIndex:index withCellsRemaining:numberOfCellsRemaining];
        self.lastScrollPosition = index;
        
    }

}
#pragma mark - Scroll Accessors/Settors
- (void)setContentOffsetTo:(int)index {
    
    if (self.isHorizontalOrientation) {
        int xCoordinate = (self.itemWidth+self.itemSpacing)*index;
        CGPoint offset = CGPointMake(xCoordinate, 0);
        self.slider.contentOffset = offset;
    }
    else {
        int yCoordinate = (self.itemHeight + self.itemSpacing)*index;
        CGPoint offset = CGPointMake(0,yCoordinate);
        self.slider.contentOffset = offset;
    }
}
- (int)getContentOffsetIndex {
    int index = 0;
    if (self.isHorizontalOrientation) {
        index = self.slider.contentOffset.x/(self.itemSpacing+self.itemWidth);
    }
    else {
        index = self.slider.contentOffset.y/(self.itemSpacing + self.itemHeight);
    }
    return index;
}
        
#pragma mark - Scroll tap handler
- (void) touchesEnded: (NSSet *) touches withEvent: (UIEvent *) event 
{
    
    // Process the single tap here
    if ([touches count]==1) {                
        UITouch* touch = [[touches allObjects]objectAtIndex:0];
        CGPoint touchLocation = [touch locationInView:self.slider];
        int index = 0;
        if (self.isHorizontalOrientation) {
            int x = touchLocation.x;
            index = (x)/(self.itemSpacing+self.itemWidth);
        }
        else {
            int y = touchLocation.y;
            index = (y)/(self.itemSpacing+self.itemHeight);
        }
        [self.delegate viewSlider:self selectIndex:index];
    }
      
    
}
@end
