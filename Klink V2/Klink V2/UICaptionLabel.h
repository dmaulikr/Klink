//
//  UICaptionLabel.h
//  Klink V2
//
//  Created by Bobby Gill on 8/6/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Caption.h"

@interface UICaptionLabel : UIView {
    Caption* m_caption;
}

@property (nonatomic,retain) IBOutlet UILabel* tv_caption;
@property (nonatomic,retain) IBOutlet UILabel* tv_metadata;

- (void) setCaption:(Caption*)caption;
@end
