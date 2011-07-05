//
//  PhotoNoteCell.h
//  Test Project 2
//
//  Created by Bobby Gill on 7/1/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface PhotoNoteCell : UITableViewCell {
    UIImageView *img_Image;
    UILabel* lbl_Title;
    UILabel* lbl_Subtitle;
}
- (id)initWithIdentifier:(NSString*)identifier;
@property (nonatomic,retain) IBOutlet UIImageView *img_Image;
@property (nonatomic,retain) IBOutlet UILabel *lbl_Title;
@property (nonatomic,retain) IBOutlet UILabel *lbl_Subtitle;
@end
