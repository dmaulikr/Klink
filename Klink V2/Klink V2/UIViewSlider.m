//
//  UIViewSlider.m
//  Klink V2
//
//  Created by Bobby Gill on 7/8/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//


#import <QuartzCore/QuartzCore.h>
#import "UIViewSlider.h"

#define kNumPicturesToLoad 5;

@implementation UIViewSlider
@synthesize sv_scrollView;
@synthesize m_itemWidth;
@synthesize m_itemHeight;
@synthesize m_viewList;
@synthesize m_itemSpacing;
@synthesize m_numItemsToLoadOnScroll;
@synthesize m_fetchedResultsController;
@synthesize delegate;


#pragma mark - Initializers
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.sv_scrollView = [[UIScrollView alloc]initWithFrame:frame];
        
        
        sv_scrollView.layer.borderColor = [UIColor redColor].CGColor;
        sv_scrollView.layer.borderWidth = 3.0f;
        sv_scrollView.delegate = self;
        
        [self addSubview:sv_scrollView];
        self.frame = frame;
    }
    return self;
}

- (id) initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {

        CGRect rect = CGRectMake(0, 0, 320, 100);
        sv_scrollView = [[UIScrollView alloc]initWithFrame:rect];
        sv_scrollView.layer.borderColor = [UIColor redColor].CGColor;
        sv_scrollView.layer.borderWidth = 3.0f;
        sv_scrollView.delegate = self;

        [self addSubview:sv_scrollView];
        
    }
    return self;
}

- (id) init {
//    if ((self = [super init])) {
//       self.m_numItemsToLoadOnScroll = kNumPicturesToLoad;  
//    }
    
    self.m_numItemsToLoadOnScroll = kNumPicturesToLoad;
    return self;
}

- (id) viewAt:(int)index {
    return [m_viewList objectAtIndex:index];
}

- (id) initWithFrame:(CGRect)frame Length:(int)length itemWidth:(int)itemWidth itemHeight:(int)itemHeight itemSpacing:(int)itemSpacing {
    
    self = [self initWithFrame:frame];
    self.m_itemHeight = itemHeight;
    self.m_itemWidth = itemWidth;
    self.m_itemSpacing = itemSpacing;

    //Need to take number of items and set the content size appropriately
    [self setInitialCapacity:length];
    
    return self;
}

- (void) hasNumberOfElements:(int)length itemWidth:(int)itemWidth itemHeight:(int)itemHeight itemSpacing:(int)itemSpacing {
    
    
    self.m_itemHeight = itemHeight;
    self.m_itemWidth = itemWidth;
    self.m_itemSpacing = itemSpacing;
    self.m_numItemsToLoadOnScroll = kNumPicturesToLoad;
    //Need to take number of items and set the content size appropriately
    [self setInitialCapacity:length];
    
    int endIndex = 0;
    
    if (length < self.m_numItemsToLoadOnScroll) {
        endIndex = length;
    }
    else  {
        endIndex = self.m_numItemsToLoadOnScroll;
    }
    
    for (int i = 0; i < endIndex; i++) {
        UIView* v = (UIView*)[self.delegate viewSlider:self cellForRowAtIndex:i];
        [m_viewList replaceObjectAtIndex:i withObject:v];
        [sv_scrollView addSubview:v];
    }
}


- (void) setInitialCapacity:(int)capacity {
    //need to initialize the view list array with empty values for this capacity
    m_viewList = [[NSMutableArray alloc]init];
    for (int i = 0; i < capacity; i++) {
        [m_viewList insertObject:[NSNull null] atIndex:i];
    }
    float contentWidth = [self getContentWidth];
    
    //set the scroll views maximum content width
    CGSize size = CGSizeMake(contentWidth, self.m_itemHeight);
    [sv_scrollView setContentSize:size];
    
    
    
}

- (float) getContentWidth {
    //how many items are there
    int numItems = [m_viewList count];
    //calculate complete width of this view
    float contentWidth = numItems * (m_itemWidth + m_itemSpacing);
    return contentWidth;
}

- (void) datasetItemAddedAt:(int)index {
    [m_viewList insertObject:[NSNull null] atIndex:[m_viewList count]];
    //need to adjust the content size to reflect the increased width
    CGSize existingSize = [sv_scrollView contentSize];
    int width = existingSize.width;
    
    width += self.m_itemWidth+self.m_itemSpacing;
    CGSize newSize = CGSizeMake(width,existingSize.height);
    [sv_scrollView setContentSize:newSize];    
    
    [self datasetHasChangedAt:index];
}

-  (void) datasetHasChangedAt:(int)index; {

    //calculate current scroll position
    int currentIndex = [self currentScrollIndex];
  
    int endIndex = currentIndex + self.m_numItemsToLoadOnScroll;
    if (endIndex > [self.m_viewList count]) {
        endIndex = [self.m_viewList count];
    }
    
    int startIndex = currentIndex - self.m_numItemsToLoadOnScroll;
    if (startIndex < 0 ) {
        startIndex = 0;
    }
    //if the index is between the start and end we should re draw the scroll view
    if (index >= startIndex && index < endIndex) {
        [self render];
        [sv_scrollView setNeedsDisplay];
    }
}

- (int) currentScrollIndex {
    CGPoint position =  sv_scrollView.contentOffset;
    int index = position.x / (m_itemWidth + m_itemSpacing);
    return index;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

#pragma mark - UI Scroll View Delegate


- (void) render  {
   CGPoint position =  self.sv_scrollView.contentOffset;
    int index = position.x / (m_itemWidth + m_itemSpacing);
    NSLog(@"Scroll Stopped at Index %@",[NSNumber numberWithInt:index]);
    
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
            //if the slot is already filled with a view, remove it
            UIView* v = [m_viewList objectAtIndex:i];
            [v removeFromSuperview];            
            [m_viewList replaceObjectAtIndex:i withObject:[NSNull null]];
        }
        
        
        //get the view to render the current cell from delegate
        UIView* cellView = [self.delegate viewSlider:self cellForRowAtIndex:i];
        
        //now we need to add it to the slider and scroll view
        [m_viewList replaceObjectAtIndex:i withObject:cellView];
        [sv_scrollView addSubview:cellView];
        
               
    }
    
    //now we need to manage our memory
    //so we clear out any image views in the scroll view that are past the constant buffer amount
    
    for (int i = 0; i < startIndex; i++) {
        if ([m_viewList objectAtIndex:i]!=[NSNull null]) {
            UIView* v = [m_viewList objectAtIndex:i];
            [v removeFromSuperview];
            [m_viewList replaceObjectAtIndex:i withObject:[NSNull null]];
        }
        
    }
    for (int i = endIndex; i < [m_viewList count] ; i++) {
        if ([m_viewList objectAtIndex:i] != [NSNull null]) {
            UIView* v = [m_viewList objectAtIndex:i];
            [v removeFromSuperview];
            [m_viewList replaceObjectAtIndex:i withObject:[NSNull null]];
        }
    }

}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self render];
}

//
//- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
//    
//    
//    [self render];
//
//    
//}

- (void)dealloc
{
    [m_viewList release];
    [sv_scrollView release];
    [super dealloc];
}

@end
