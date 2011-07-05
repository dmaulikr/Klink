//
//  TitleView.h
//  Test Project 2
//
//  Created by Bobby Gill on 6/29/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface TitleView : UIView {
    UILabel *titleLabel;
    UILabel *subtitleLabel;
    UIActivityIndicatorView *progressIndicator;
}

@property (nonatomic,retain) IBOutlet UILabel* titleLabel;
@property (nonatomic,retain) IBOutlet UILabel* subtitleLabel;
@property (nonatomic,retain) IBOutlet UIActivityIndicatorView* progressIndicator;

@end
