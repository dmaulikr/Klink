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
    
    UITableViewCell* m_draftTableViewCellLeft;
    
    UIImageView*    m_iv_photo;
    UILabel*        m_lbl_caption;
    UILabel*        m_lbl_numVotes;
    UILabel*        m_lbl_numCaptions;
}

@property (nonatomic, retain) NSNumber* photoID;
@property (nonatomic, retain) NSNumber* captionID;

@property (nonatomic, retain) IBOutlet UITableViewCell* draftTableViewCellLeft;

@property (nonatomic, retain) IBOutlet UIImageView* iv_photo;
@property (nonatomic, retain) IBOutlet UILabel* lbl_caption;
@property (nonatomic, retain) IBOutlet UILabel* lbl_numVotes;
@property (nonatomic, retain) IBOutlet UILabel* lbl_numCaptions;

- (void) renderWithPhotoID:(NSNumber*)photoID;

+ (NSString*) cellIdentifier;

@end
