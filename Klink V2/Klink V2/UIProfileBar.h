//
//  UIProfileBar.h
//  Klink V2
//
//  Created by Bobby Gill on 7/16/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface UIProfileBar : UIView {
    UILabel* lbl_votes;
    UILabel* lbl_rank;
    UILabel* lbl_captions;
}

@property (nonatomic, retain)  UILabel* lbl_votes;
@property (nonatomic, retain)  UILabel* lbl_rank;
@property (nonatomic, retain)  UILabel* lbl_captions;

@end
