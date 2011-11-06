//
//  UIDraftView.h
//  Platform
//
//  Created by Jordan Gurrieri on 11/3/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface UIDraftView : UIView <UITableViewDelegate, UITableViewDataSource> {
    NSArray* m_listData;
   
    NSNumber* m_pageID;
    UITableView* m_tableView;
}

@property (nonatomic, retain) NSArray *listData;

@property (nonatomic,retain) NSNumber* pageID;
@property (nonatomic, retain) IBOutlet UITableView *tableView;

- (id)initWithFrame:(CGRect)frame withStyle:(UITableViewCellStyle)style;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil withFrame:(CGRect)frame;

@end
