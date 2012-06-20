//
//  UIDraftTableViewCell.h
//  Platform
//
//  Created by Jordan Gurrieri on 11/4/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CloudEnumerator.h"
#import "UIResourceLinkButton.h"

@protocol UIDraftTableViewCellDelegate

@required
- (void) onCaptionButtonPressedForPhotoWithID:(NSNumber *)photoID;
- (void) onVoteButtonPressedForCaptionWithID:(NSNumber *)captionID;
@end

@interface UIDraftTableViewCell : UITableViewCell {
    id<UIDraftTableViewCellDelegate> m_delegate;
    
    NSNumber*       m_photoID;
    NSNumber*       m_captionID;
    
    UITableViewCell* m_draftTableViewCell;
    NSString*       m_cellType;
    
    UIImageView*                m_iv_photo;
    UIImageView*                m_iv_photoFrame;
    UILabel*                    m_lbl_downloading;
    UIResourceLinkButton*       m_btn_writtenBy;
    UIResourceLinkButton*       m_btn_illustratedBy;
    UILabel*                    m_lbl_caption;
    UILabel*                    m_lbl_photoby;
    UILabel*                    m_lbl_captionby;
    UILabel*                    m_lbl_numVotes;
    UIImageView*                m_iv_unreadCaptionBadge;
    UIButton*                   m_btn_vote;
    UIButton*                   m_btn_caption;
    
    UIImageView*                m_iv_ribbon;
    UILabel*                    m_lbl_place;
    
}

@property (assign) id<UIDraftTableViewCellDelegate> delegate;

@property (nonatomic, retain) NSNumber* photoID;
@property (nonatomic, retain) NSNumber* captionID;

@property (nonatomic, retain) IBOutlet UITableViewCell* draftTableViewCell;
@property (nonatomic, retain) NSString*                 cellType;
@property (nonatomic, retain) IBOutlet UIResourceLinkButton*        btn_writtenBy;
@property (nonatomic, retain) IBOutlet UIResourceLinkButton*        btn_illustratedBy;
@property (nonatomic, retain) IBOutlet UIImageView*     iv_photo;
@property (nonatomic, retain) IBOutlet UIImageView*     iv_photoFrame;
@property (nonatomic, retain) IBOutlet UILabel*         lbl_downloading;
@property (nonatomic, retain) IBOutlet UILabel*         lbl_caption;
@property (nonatomic, retain) IBOutlet UILabel*         lbl_photoby;
@property (nonatomic, retain) IBOutlet UILabel*         lbl_captionby;
@property (nonatomic, retain) IBOutlet UILabel*         lbl_numVotes;
@property (nonatomic, retain) IBOutlet UIImageView*     iv_unreadCaptionBadge;
@property (nonatomic, retain) IBOutlet UIButton*        btn_vote;
@property (nonatomic, retain) IBOutlet UIButton*        btn_caption;

@property (nonatomic, retain) IBOutlet UIImageView*     iv_ribbon;
@property (nonatomic, retain) IBOutlet UILabel*         lbl_place;


- (void) renderWithCaptionID:(NSNumber*)captionid;
- (void) renderWithPhotoID:(NSNumber*)photoID;
- (IBAction) onCaptionButtonPressed:(id)sender;
- (IBAction) onVoteButtonPressed:(id)sender;
//- (IBAction) onWrittenByClicked:(id)sender;
//- (IBAction) onIllustratedByClicked:(id)sender;
+ (NSString*) cellIdentifierTop;
+ (NSString*) cellIdentifierLeft;
+ (NSString*) cellIdentifierRight;

@end
