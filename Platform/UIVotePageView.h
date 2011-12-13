//
//  UIVotePageView.h
//  Platform
//
//  Created by Jasjeet Gill on 12/12/11.
//  Copyright (c) 2011 Blue Label Solutions LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Page.h"
#import "Photo.h"
#import "Caption.h"
#import "Poll.h"
#import "CloudEnumerator.h"
@interface UIVotePageView : UIView <CloudEnumeratorDelegate> {
    UIImageView* m_image;
    UILabel* m_lbl_title;
    UILabel* m_lbl_caption;
    Page* m_page;
    Photo* m_photo;
    Caption* m_caption;
    Poll* m_poll;
    CloudEnumerator* m_enumerator;
    
}

@property (nonatomic,retain)  UIImageView* image;
@property (nonatomic,retain)  UILabel* lbl_title;
@property (nonatomic, retain) UILabel* lbl_caption;
@property (nonatomic,retain) Page* page;
@property (nonatomic,retain) Caption *caption;
@property (nonatomic,retain) Photo* photo;
@property (nonatomic,retain) Poll* poll;
@property (nonatomic,retain) CloudEnumerator* enumerator;
- (id) initWithFrame:(CGRect)frame withPhotoID:(NSNumber*)photoID forPoll:(NSNumber*)pollID;
- (void) renderWithPage:(NSNumber*)pageID forPoll:(NSNumber*)pollID;

@end
