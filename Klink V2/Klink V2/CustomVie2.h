//
//  CustomVie2.h
//  Klink V2
//
//  Created by Bobby Gill on 7/6/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface CustomVie2 : UIView {
    UILabel* label;
    UIView* view;
    
}

- (id) initWithCoder:(NSCoder *)aDecoder;
- (id) init;
- (void) setIndexNumber:(NSString*)index;
@property (nonatomic,retain) IBOutlet UILabel* label;
@property (nonatomic, retain) IBOutlet UIView* view;

@end
