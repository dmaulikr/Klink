//
//  UIEditorialPageView.h
//  Platform
//
//  Created by Jordan Gurrieri on 12/15/11.
//  Copyright (c) 2011 Blue Label Solutions LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIEditorialPageView : UIView {
    NSNumber*       m_pageID;
    NSNumber*       m_pollID;
    NSNumber*       m_pollState;
    NSNumber*       m_photoID;
    NSNumber*       m_captionID;
    
    UIView*         m_view;
    
    UILabel*        m_lbl_draftTitle;
    UIImageView*    m_iv_photo;
    UIImageView*    m_iv_photoFrame;
    UILabel*        m_lbl_downloading;
    UILabel*        m_lbl_caption;
    UILabel*        m_lbl_photoby;
    UILabel*        m_lbl_captionby;
    
    UIView*         m_v_publishedVotesView;
    UILabel*        m_lbl_numPublishedVotes;
    UIImageView*    m_iv_publishedStamp;
    UIImageView*    m_iv_votedStamp;
    UIButton*       m_btn_zoomOutPhoto;
    
}

@property (nonatomic, retain) NSNumber*                 pageID;
@property (nonatomic, retain) NSNumber*                 pollID;
@property (nonatomic, retain) NSNumber*                 pollState;
@property (nonatomic, retain) NSNumber*                 photoID;
@property (nonatomic, retain) NSNumber*                 captionID;

@property (nonatomic, retain) IBOutlet UIView*          view;

@property (nonatomic, retain) IBOutlet UILabel*         lbl_draftTitle;
@property (nonatomic, retain) IBOutlet UIImageView*     iv_photo;
@property (nonatomic, retain) IBOutlet UIImageView*     iv_photoFrame;
@property (nonatomic, retain) IBOutlet UILabel*         lbl_downloading;
@property (nonatomic, retain) IBOutlet UILabel*         lbl_caption;
@property (nonatomic, retain) IBOutlet UILabel*         lbl_photoby;
@property (nonatomic, retain) IBOutlet UILabel*         lbl_captionby;

@property (nonatomic, retain) IBOutlet UIView*          v_publishedVotesView;
@property (nonatomic, retain) IBOutlet UILabel*         lbl_numPublishedVotes;
@property (nonatomic, retain) IBOutlet UIImageView*     iv_publishedStamp;
@property (nonatomic, retain) IBOutlet UIImageView*     iv_votedStamp;
@property (nonatomic, retain) IBOutlet UIButton*        btn_zoomOutPhoto;

//- (void)renderWithPageID:(NSNumber*)pageID withPollState:(NSNumber*)pollState;
- (void)renderWithPageID:(NSNumber*)pageID withPollID:(NSNumber*)pollID;
- (IBAction) onZoomOutPhotoButtonPressed:(id)sender;

@end
