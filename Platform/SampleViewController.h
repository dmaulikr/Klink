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
#import "EnumerationContext.h"

@class User;
@class EnumerationResponse;
@interface SampleViewController : BaseViewController {
    UIButton*   m_toJSONButton;
    UIButton*   m_fromJSONButton;
    UITextView* m_textView;
    UIButton*   m_loginButton;
    UIButton*   m_logoutButton;
    User*       m_user;
    Query*      m_query;
    EnumerationContext* m_enumerationContext;
    EnumerationResponse* m_enumerationResponse;
}

@property (nonatomic,retain) IBOutlet UIButton*     toJSONButton;
@property (nonatomic,retain) IBOutlet UIButton*     fromJSONButton;
@property (nonatomic,retain) IBOutlet UITextView*    textView;
@property (nonatomic,retain)          User*         user;
@property (nonatomic,retain)          Query*        query;
@property (nonatomic,retain)          EnumerationContext*    enumerationContext;
@property (nonatomic,retain)          EnumerationResponse*   enumerationResponse;
@property (nonatomic,retain) IBOutlet UIButton*     loginButton;
@property (nonatomic,retain) IBOutlet UIButton*     logoutButton;

- (IBAction)toJSON  :(id)sender;
- (IBAction)fromJSON:(id)sender;
- (IBAction)login:(id)sender;
- (IBAction)logout:(id)sender;
@end
