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
        sv_slider.layer.backgroundColor = [UIColor redColor].CGColor;
        sv_slider.layer.borderWidth = 4.0f;
        self.m_numItemsToLoadOnScroll = kNumPicturesToLoad;
        self.m_viewList = [[NSMutableArray alloc]init];
    }
    return self;
}

- (id) initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
        
        CGRect rect = CGRectMake(0, 0, 320, 100);
        sv_slider = [[UIScrollView alloc]initWithFrame:rect];
        sv_slider.layer.borderColor = [UIColor redColor].CGColor;
        sv_slider.layer.borderWidth = 3.0f;
        sv_slider.delegate = self;
        sv_slider.pagingEnabled = YES;
        sv_slider.bounces = YES;
        sv_slider.scrollEnabled = YES;
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

- (void) set:(NSArray*)items {
    for (int i = 0; i < [items count];i++) {
        UIView* cellView = [self.delegate viewSlider:nil cellForRowAtIndex:i];
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
    UIView* cellView = [self.delegate viewSlider:nil cellForRowAtIndex:index];    
    [m_viewList insertObject:cellView atIndex:index];        
    sv_slider.contentSize = [self getContentSize];
    [sv_slider addSubview:cellView];    
}

- (void) item:(id)object atIndex:(int)index movedTo:(int)newIndex {
    [m_viewList replaceObjectAtIndex:index withObject:[NSNull null]];
    UIView* cellView = [self.delegate viewSlider:nil cellForRowAtIndex:newIndex];
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



- (void) render  {
    CGPoint position =  self.sv_slider.contentOffset;
    int index = position.x / (m_itemWidth + m_itemSpacing);
    //    NSLog(@"Scroll Stopped at Index %@",[NSNumber numberWithInt:index]);
    
    if (index != self.m_lastScrollPosition) {
        //we notify the delegate that the scroll position has changed, and pass the number of items remaining
        int numberOfCellsRemaining = ([self.m_viewList count]-1) - index;        
        [self.delegate viewSlider:nil isAtIndex:index withCellsRemaining:numberOfCellsRemaining];
        self.m_lastScrollPosition = index;
        
        
        int numberOfSlots = [m_viewList count];
        int startIndex = index - m_numItemsToLoadOnScroll;
        int endIndex = index + m_numItemsToLoadOnScroll;
        
        
        if (endIndex > numberOfSlots) {
            endIndex =numberOfSlots;
        }
        
        if (startIndex < 0) {
            startIndex = 0;
        }
        
        for (int i = startIndex; i<endIndex; i++) {
            if ([m_viewList objectAtIndex:i] != [NSNull null]) {
                UIView* previousView = [m_viewList objectAtIndex:i];
                [previousView removeFromSuperview];
            }
            UIView* scrollViewCell = [[sv_slider subviews]objectAtIndex:i];
            
            UIView* cellView = [self.delegate viewSlider:nil cellForRowAtIndex:i];
            //put this into the list and remove
            [scrollViewCell addSubview:cellView];
            
            [m_viewList replaceObjectAtIndex:i withObject:cellView];
        }
        
    
    }
    
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGPoint position =  self.sv_slider.contentOffset;
    int index = position.x / (m_itemWidth + m_itemSpacing);
    if (index != self.m_lastScrollPosition) {
        int numberOfCellsRemaining = ([self.m_viewList count]-1) - index;        
        [self.delegate viewSlider:nil isAtIndex:index withCellsRemaining:numberOfCellsRemaining];
        self.m_lastScrollPosition = index;

    
    }

}
        

@end
