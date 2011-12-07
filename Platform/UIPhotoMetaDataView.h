//
//  UIPhotoMetaDataView.h
//  Platform
//
//  Created by Jordan Gurrieri on 12/4/11.
//  Copyright (c) 2011 Blue Label Solutions LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIPhotoMetaDataView : UIView {
    NSNumber* m_photoID;
    NSNumber* m_captionID;
    
    UIView* m_view;
    UIView* m_v_background;
    UILabel* m_lbl_metaData;
    UILabel* m_lbl_numVotes;
    UIImageView* m_iv_voteIcon;
}

@property (nonatomic, retain) NSNumber* photoID;
@property (nonatomic, retain) NSNumber* captionID;

@property (nonatomic, retain) IBOutlet UIView* view;
@property (nonatomic, retain) IBOutlet UIView* v_background;
@property (nonatomic, retain) IBOutlet UILabel* lbl_metaData;
@property (nonatomic, retain) IBOutlet UILabel* lbl_numVotes;
@property (nonatomic, retain) IBOutlet UIImageView* iv_voteIcon;

- (void) renderMetaDataWithID:(NSNumber*)photoID withCaptionID:(NSNumber*)captionID;
- (void) render;

@end
