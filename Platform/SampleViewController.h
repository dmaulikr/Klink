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
@interface SampleViewController : BaseViewController <UITextFieldDelegate> {
    UIButton*   m_toJSONButton;
    UIButton*   m_fromJSONButton;
    UITextView* m_textView;
    UIButton*   m_loginButton;
    UIButton*   m_logoutButton;
    User*       m_user;
    Query*      m_query;
    EnumerationContext* m_enumerationContext;
    EnumerationResponse* m_enumerationResponse;
    UILabel* m_createPhotoStatus;
    UIButton*   m_createPhotoButton;
    
    UITextField*    m_objectID;
    UITextField*    m_attributeName;
    UITextField*    m_attributeValue;
    UITextField*    m_objectType;
    UIButton*       m_commitChangesButton;
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
@property (nonatomic,retain) IBOutlet UIButton*     createPhotoButton;
@property (nonatomic,retain) IBOutlet UILabel*   createPhotoStatus;


@property (nonatomic,retain) IBOutlet UITextField*  objectID;
@property (nonatomic,retain) IBOutlet UITextField*  attributeName;
@property (nonatomic,retain) IBOutlet UITextField*  attributeValue;
@property (nonatomic,retain) IBOutlet UIButton*     commitChangesButton;
@property (nonatomic,retain) IBOutlet UITextField*  objectType;
- (IBAction)toJSON  :(id)sender;
- (IBAction)fromJSON:(id)sender;
- (IBAction)login:(id)sender;
- (IBAction)logout:(id)sender;
- (IBAction)createUser:(id)sender;
@end
