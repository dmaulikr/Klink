//
//  UIDraftView.h
//  Platform
//
//  Created by Jordan Gurrieri on 11/3/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface UIDraftView : UIView <UITableViewDelegate, UITableViewDataSource> {
    NSArray *listData;
}

@property (nonatomic, retain) NSArray *listData;

@end
