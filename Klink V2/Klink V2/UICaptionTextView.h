//
//  UICaptionTextView.h
//  Klink V2
//
//  Created by Bobby Gill on 8/7/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
@class UICaptionTextView;
@protocol UICaptionTextViewDelegate <NSObject>
@optional

- (void)    captionTextView:    (UIView*)    captionTextView
            finishedWithString:(NSString*)             caption;
@end

@interface UICaptionTextView : UIView <UITextViewDelegate, UITextFieldDelegate> {
    id<UICaptionTextViewDelegate> m_delegate;
}

- (void) setText:(NSString*)text;
- (NSString*) getText;
- (void) cancel;
@property (nonatomic,retain) UITextField* tv_text;
@property (nonatomic,retain) UILabel* lbl_charsremaining;
@property (nonatomic,retain) IBOutlet id<UICaptionTextViewDelegate> delegate;

@end
