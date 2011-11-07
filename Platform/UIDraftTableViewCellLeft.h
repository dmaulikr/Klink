//
//  UIDraftTableViewCellLeft.h
//  Platform
//
//  Created by Jordan Gurrieri on 11/4/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface UIDraftTableViewCellLeft : UITableViewCell {
    NSNumber*       m_photoID;
    NSNumber*       m_captionID;
    
    UIImageView*    m_img_photo;
    UILabel*        m_lbl_caption;
    UILabel*        m_lbl_numVotes;
    UILabel*        m_lbl_numCaptions;
}

@property (nonatomic, retain) NSNumber* photoID;
@property (nonatomic, retain) NSNumber* captionID;

@property (nonatomic, retain) IBOutlet UIImageView* img_photo;
@property (nonatomic, retain) IBOutlet UILabel* lbl_caption;
@property (nonatomic, retain) IBOutlet UILabel* lbl_numVotes;
@property (nonatomic, retain) IBOutlet UILabel* lbl_numCaptions;

- (id)initWithPhotoID:(NSNumber*)photoID withCaptionID:(NSNumber*)captionID withStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;
- (void) renderWithPhotoID:(NSNumber*)photoID withCaptionID:(NSNumber*)captionID;

+ (NSString*) cellIdentifier;

@end
