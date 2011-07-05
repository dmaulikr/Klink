//
//  CustomCell.h
//  Test Project 2
//
//  Created by Bobby Gill on 6/20/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface CustomCell : UITableViewCell {
    UILabel* topicNameLabel;
    UILabel* streamLabel;
   
}

@property (nonatomic,retain) IBOutlet UILabel* topicNameLabel;
@property (nonatomic,retain) IBOutlet UILabel* streamLabel;

@end
