//
//  UIPagedViewSlider4.m
//  Klink V2
//
//  Created by Bobby Gill on 9/22/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import "UIPagedViewSlider4.h"

@implementation UIPagedViewSlider2
@synthesize tableView =m_tableView;
@synthesize delegate = m_delegate;
@synthesize cellWidth;
@synthesize cellHeight;
@synthesize cellSpacing;

#define kSTARTTIME          @"starttime"
#define kTIMEDURATION       @"timeduration"
#define kSTARTINGINDEX      @"startingindex"
#define kDESTINATIONINDEX   @"destinationindex"
- (int) getPageIndex {

    return m_index;
}


- (void)commonInit {
    //we need to create a table with the dimensions reversed because we are going to transform that bitch
    CGRect tableFrame = CGRectMake(0, 0, self.frame.size.height, self.frame.size.width);        
    self.tableView = [[UITableView alloc]initWithFrame:tableFrame style:UITableViewStylePlain];
    self.tableView.pagingEnabled = NO;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [UIColor clearColor];
    
    m_index = 0;
    
    //transformation to flip the table view on its side
    //self.tableView.layer.anchorPoint = CGPointMake(0, 0);
    [self.tableView setAnchorPoint:CGPointMake(0,0)];
    CGAffineTransform rotateTable = CGAffineTransformMakeRotation(degreesToRadians(-90));
    int y = self.tableView.frame.size.width;
    self.tableView.transform = CGAffineTransformTranslate(rotateTable, -y, 0);
    m_lastContentOffset = 0;
    [self addSubview:self.tableView];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        [self commonInit];        
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}


- (id)      initWithWidth:          (int)   width
               withHeight:          (int)   height
              withSpacing:          (int)   spacing
        useCellIdentifier:   (NSString *)   identifier{
    
    if (self) {
        m_itemWidth = width;
        m_itemHeight= height;
        m_itemSpacing = spacing;
        m_cellIdentifier = identifier;
        [self.tableView reloadData];
    }
    return self;
}

- (int)  indexForContentOffset:(CGPoint)point useFloor:(BOOL)useFloor{
    int index = 0;
    if (useFloor) {
        index = floor(point.y/ (m_itemWidth + m_itemSpacing));
    }
    else {
        index = ceil(point.y / (m_itemWidth + m_itemSpacing));
    }
    return index;
}

- (CGPoint) contentOffsetForIndex:(int)index {
    CGPoint retVal = CGPointMake(0, index*(m_itemSpacing+m_itemWidth));
    return retVal;
}

#pragma mark - UIScrollViewDelegate
- (void) scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (decelerate) {
        //check the direction
        //find the nearest index
        //set the motion to that
//        int nextIndex = 0;
//        if (m_scrollDirection == RIGHT) {
//            
//            nextIndex = [self indexForContentOffset:scrollView.contentOffset useFloor:NO];
//            int itemCount = [self.delegate itemCountFor:self];
//            
//            if (nextIndex >= itemCount) {
//                nextIndex--;
//            }
//            
//        }
//        else if (m_scrollDirection == LEFT) {
//            nextIndex = [self indexForContentOffset:scrollView.contentOffset useFloor:YES];
//            
//            if (nextIndex == 0) {
//                nextIndex++;
//            }
//        }
//        
//        
//        //we set the scroll view to animate itself to that nextIndex location
//        CGPoint currentOffset = scrollView.contentOffset;
//        CGPoint targetOffset = [self contentOffsetForIndex:nextIndex];
//        CGRect rectWindow = CGRectMake(targetOffset.x,targetOffset.y,m_itemHeight,(m_itemWidth+m_itemSpacing));
//        [scrollView scrollRectToVisible:rectWindow animated:YES];

    }
}

//this method will ensure the scrollview continues to scroll towards
//the edge of the nearest index
-(void) scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
    }
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    int count = [self.delegate itemCountFor:self];
    int newIndex = [self indexForContentOffset:scrollView.contentOffset useFloor:YES];
    
    if (newIndex < 0) newIndex =0 ;
    
    if (newIndex > count - 1) newIndex = count - 1;
    int oldIndex = m_index;
    m_index = newIndex;
    
    if (m_index != oldIndex) {
        [self.delegate viewSlider:self isAtIndex:m_index withCellsRemaining:count-m_index];
    }
    
    //we now record the direction we have detected the scroll view to be moving
    if (m_lastContentOffset < scrollView.contentOffset.y)
        m_scrollDirection = RIGHT;
    else if (m_lastContentOffset > scrollView.contentOffset.y) 
        m_scrollDirection = LEFT;
    
    m_lastContentOffset = scrollView.contentOffset.y;
    
}
    
    


#pragma mark - UITableViewDelegate
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.delegate viewSlider:self selectIndex:indexPath.row];
}



- (void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {

    
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //return the cell width is at the height of the row as the table view is stored in memory as a 
    //vertical table view that is transformed. hence, the row height is in essence the horizontal scroll
    //viewer's cell width
    return m_itemWidth;
}


#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    int count = [self.delegate itemCountFor:self];
    return count;
}




- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell* cell = (UITableViewCell*)[self.tableView dequeueReusableCellWithIdentifier:m_cellIdentifier];
    
    //this frame is passed to the delegate to attach subviews with
    CGRect frame = CGRectMake(0, 0, m_itemWidth, m_itemHeight);
    
    if (cell == nil) {
        cell = [[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:m_cellIdentifier]autorelease];
        UIView* childView = [self.delegate viewSlider:self cellForRowAtIndex:indexPath.row withFrame:frame];
        [cell.contentView addSubview:childView];

    }
    else {
        UIView* childView = [cell.contentView.subviews objectAtIndex:0];
        [childView removeFromSuperview];
      
        childView = [self.delegate viewSlider:self cellForRowAtIndex:indexPath.row withFrame:frame];
        [cell.contentView addSubview:childView];

    }
    
    
    //We apply a transformation to attach the cell to the table rotated forward 90 degrees, such that when
    //the entire table is rotated backwards by 90 degrees, the cells are correctly oriented
    CGAffineTransform rotateCell = CGAffineTransformMakeRotation(M_PI_2);
    cell.transform = rotateCell;
    
    
    return cell;
}

- (void)        onNewItemInsertedAt:(int)index {
    NSIndexPath* indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    
    [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    
}



- (CGPoint) contentOffsetForPageAtIndex:    (NSUInteger)    index {
    return CGPointMake(0, (m_itemWidth+m_itemSpacing)*index);
     
}

- (void) goTo:(int)index {
    [self goTo:index withAnimation:NO];
}


- (void) goTo:(int)index withAnimation:(BOOL)withAnimation {
    
    if (!withAnimation) {
        //move scroll head position
        int count = [self.delegate itemCountFor:self];
        if (index < count && index > 0) {
            self.tableView.contentOffset = [self contentOffsetForPageAtIndex:index];
          
            m_index = index;
        }
        
    }
    else {
        NSNumber* destinationIndex = [NSNumber numberWithInt:index];
        NSNumber* startingIndex = [NSNumber numberWithInt:m_index];
        
        NSDate* startTime = [NSDate date];
        
        NSNumber* duration =[NSNumber numberWithDouble:10.2];
        
        NSMutableDictionary* userInfo = [NSMutableDictionary dictionaryWithObject:startTime forKey:kSTARTTIME];
        [userInfo setObject:duration forKey:kTIMEDURATION];
        [userInfo setObject:destinationIndex forKey:kDESTINATIONINDEX];
        [userInfo setObject:startingIndex forKey:kSTARTINGINDEX];
        

        
        
    }
}
- (void)        reset {
    [self.tableView reloadData];
}

- (NSArray*)    getVisibleViews {
    NSMutableArray* retVal = [[[NSMutableArray alloc]init ]autorelease];
    
    NSArray* visibleCells = [self.tableView visibleCells];
    for (int i = 0; i < [visibleCells count];i++) {
        UITableViewCell* cell = [visibleCells objectAtIndex:i];
        UIView* contentView = [[cell.contentView subviews]objectAtIndex:0];
        [retVal insertObject:contentView atIndex:i];
    }
    
    return retVal;
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

@end
