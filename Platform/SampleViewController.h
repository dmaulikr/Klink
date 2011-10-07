//
//  SampleViewController.h
//  Platform
//
//  Created by Bobby Gill on 10/7/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "BaseViewController.h"
@class User;
@interface SampleViewController : BaseViewController {
    UIButton*   m_toJSONButton;
    UIButton*   m_fromJSONButton;
    UITextView* m_textView;
    User*       m_user;
}

@property (nonatomic,retain) IBOutlet UIButton*     toJSONButton;
@property (nonatomic,retain) IBOutlet UIButton*     fromJSONButton;
@property (nonatomic,retain) IBOutlet UITextView*    textView;
@property (nonatomic,retain)          User*         user;

- (IBAction)toJSON  :(id)sender;
- (IBAction)fromJSON:(id)sender;
@end
