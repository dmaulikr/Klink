//
//  NoteViewCell.h
//  Test Project 2
//
//  Created by Bobby Gill on 6/23/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface NoteViewCell : UITableViewCell
{
    UILabel* lbl_Title;
    UITextView* lbl_thought;
}

@property (nonatomic,retain) IBOutlet UILabel* lbl_Title;
@property (nonatomic,retain) IBOutlet UITextView* lbl_thought;

@end
