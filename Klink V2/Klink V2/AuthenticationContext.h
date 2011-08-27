//
//  AuthenticationContext.h
//  Test Project 2
//
//  Created by Bobby Gill on 6/16/11.
//  Copyright (c) 2011 Blue Label Solutions LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "IWireSerializable.h"
#import "AttributeNames.h"
#import "TypeNames.h"
#import "Klink_V2AppDelegate.h"
#import "DateTimeHelper.h"

@interface AuthenticationContext : NSObject <IWireSerializable>{
    NSNumber* m_userid;
    NSDate* m_expiryDate;
    NSString* m_token;
    NSString* m_facebookAccessToken;
    NSString* m_facebookUserID;
    NSDate* m_facebookAccessTokenExpiryDate;
    NSString* m_twitterAccessToken;
    NSDate* m_twitterAccessTokenExpiryDate;
    NSString* m_twitterUserID;
    NSString* m_wordpressURL;
    NSString* m_wpUsername;
    NSString* m_wpPassword;
@private
}
@property (nonatomic, retain) NSNumber * userid;
@property (nonatomic, retain) NSDate * expiryDate;
@property (nonatomic, retain) NSString * token;
@property (nonatomic, retain) NSString* facebookAccessToken;
@property (nonatomic, retain) NSDate* facebookAccessTokenExpiryDate;
@property (nonatomic, retain) NSString* facebookUserID;
@property (nonatomic, retain) NSString* twitterAccessToken;
@property (nonatomic, retain) NSDate* twitterAccessTokenExpiryDate;
@property (nonatomic, retain) NSString* twitterUserID;
@property (nonatomic, retain) NSString* wordpressURL;
@property (nonatomic, retain) NSString* wpUsername;
@property (nonatomic, retain) NSString* wpPassword;


//- (id) initWithEntity:(NSEntityDescription *)entity insertIntoManagedObjectContext:(NSManagedObjectContext *)context;
- (void) copyFrom:(AuthenticationContext*)newContext;
- (BOOL) hasWordpress;
- (BOOL) hasFacebook;
+ (id)newInstance;
@end
