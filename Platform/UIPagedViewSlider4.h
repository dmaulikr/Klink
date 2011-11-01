//
//  UIPagedViewSlider4.h
//  Klink V2
//
//  Created by Bobby Gill on 9/22/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <QuartzCore/QuartzCore.h>
#import <Foundation/Foundation.h>


#define degreesToRadians(x) (M_PI * x / 180.0)


enum DIRECTION {
    NONE,
    RIGHT,
    LEFT,
    UP,
    DOWN,
    CRAZY,
};

@class UIPagedViewItem;
@class UIPagedViewSlider2;
@protocol UIPagedViewSlider2Delegate <NSObject>
@optional

- (void)    viewSlider:         (UIPagedViewSlider2*)   viewSlider  
           selectIndex:        (int)                   index;

- (UIView*) viewSlider:         (UIPagedViewSlider2*)   viewSlider 
     cellForRowAtIndex:  (int)                   index 
             withFrame:          (CGRect)                frame;


- (void)    viewSlider:          (UIPagedViewSlider2*)   viewSlider 
             isAtIndex:          (int)                   index 
    withCellsRemaining: (int)                   numberOfCellsToEnd;


- (void)    viewSlider:          (UIPagedViewSlider2*)   viewSlider
             configure:          (UIView*)               existingCell
         forRowAtIndex:          (int)                   index
             withFrame:          (CGRect)                frame;



- (int)     itemCountFor:        (UIPagedViewSlider2*)   viewSlider;




@end

@interface UIPagedViewSlider2 : UIView <UITableViewDelegate, UITableViewDataSource> {
  

    id<UIPagedViewSlider2Delegate> m_delegate;
    int                 m_itemWidth;
    int                 m_itemHeight;
    int                 m_itemSpacing;
    int                 m_index;
    UITableView*        m_tableView;
    NSString*           m_cellIdentifier;
    CGFloat             m_lastContentOffset;
    int                 m_scrollDirection;
}

@property (nonatomic,retain)    UITableView         *tableView;
@property int   cellWidth;
@property int   cellHeight;
@property int   cellSpacing;


@property (nonatomic,retain)    id<UIPagedViewSlider2Delegate>  delegate;


- (id)      initWithWidth:          (int)   width
               withHeight:          (int)   height
              withSpacing:          (int)   spacing
        useCellIdentifier:          (NSString*) identifier;

- (int)         getPageIndex;
- (void)        onNewItemInsertedAt:(int)index;
- (void)        goTo:               (int)index;
- (void)        goTo:               (int)index withAnimation:(BOOL)withAnimation;
- (void)        reset;
- (NSArray*)    getVisibleViews;

@end

