//
//  TestSliderView.h
//  Klink V2
//
//  Created by Bobby Gill on 7/13/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface TestSliderView : UIView {
    UIView* v;
    UITextView* tv_DateCreated;
    UITextView* tv_DisplayName;
    UITextView* tv_Other;
}

@property (nonatomic,retain) IBOutlet UITextView* tv_DateCreated;
@property (nonatomic,retain) IBOutlet UITextView* tv_DisplayName;
@property (nonatomic,retain) IBOutlet UITextView* tv_Other;
@property (nonatomic,retain) IBOutlet UIView* v;
@end
