//
//  UIPhotoCaptionScrollView.h
//  Klink V2
//
//  Created by Bobby Gill on 8/4/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UIZoomingScrollView.h"
#import "UIPagedViewSlider2.h"
#import "CloudEnumerator.h"

@class Caption;
@class Photo;

@interface UIPhotoCaptionScrollView : UIZoomingScrollView <UIPagedViewSlider2Delegate, CloudEnumeratorDelegate, NSFetchedResultsControllerDelegate> {
    Photo*              m_photo;
    UIPagedViewSlider2* m_captionScrollView;
    UIButton*           m_voteButton;
    CloudEnumerator*    m_captionCloudEnumerator;
    UIButton*           m_shareButton;
}

- (id) initWithFrame:(CGRect)frame withPhoto:(Photo *)photo;
- (id) resetWithFrame:(CGRect)frame withPhoto:(Photo*)photo; 
- (void) setVisibleCaption:(NSNumber*)objectid;

- (void)    onVoteUpButtonPressed:(id)sender;
- (void)    onShareButtonPressed:(id)sender;
- (void)    disableVotingButton;
- (void)    enableVotingButton;
- (void)    showShareButton;
- (void)    hideShareButton;
- (void)    hideVotingButton;
- (void)    showVotingButton;
- (void)    showHideVotingSharingButtons;


@property (nonatomic,retain) Photo*                         photo;
@property (nonatomic,retain) UIPagedViewSlider2*            captionScrollView;
@property (nonatomic,retain) NSFetchedResultsController*    frc_captions;
@property (nonatomic,retain) NSManagedObjectContext*        managedObjectContext;
@property (nonatomic,retain) CloudEnumerator*               captionCloudEnumerator;
@property (nonatomic,retain) UIButton*                      shareButton;
@property (nonatomic,retain) UIButton*                      voteButton;
@property (nonatomic,retain) UIView*                        photoCreditsBackground;
@property (nonatomic,retain) UILabel*                       photoCreditsLabel;
@property (nonatomic,retain) UILabel*                       photoVotesLabel;


@end
