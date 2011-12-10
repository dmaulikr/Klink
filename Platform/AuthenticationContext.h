//
//  AuthenticationContext.h
//  Test Project 2
//
//  Created by Bobby Gill on 6/16/11.
//  Copyright (c) 2011 Blue Label Solutions LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Resource.h"
#import "IJSONSerializable.h"

@interface AuthenticationContext : NSManagedObject <IJSONSerializable> {

@private
}
@property (nonatomic, retain) NSNumber * userid;
@property (nonatomic, retain) NSDate * expirydate;
@property (nonatomic, retain) NSData* authenticator;
@property (nonatomic, retain) NSNumber* hastwitter;
@property (nonatomic, retain) NSNumber* hasfacebook;
@property (nonatomic, retain) NSString* facebookaccesstoken;
@property (nonatomic, retain) NSNumber* facebookaccesstokenexpirydate;
@property (nonatomic, retain) NSString* facebookuserid;
//@property (nonatomic, retain) NSString* twitteraccesstoken;
//@property (nonatomic, retain) NSString* twitteruserid;
//@property (nonatomic, retain) NSString* twitteraccesstokensecret;
//@property (nonatomic, retain) NSString* wordpressurl;
//@property (nonatomic, retain) NSString* wpusername;
//@property (nonatomic, retain) NSString* wppassword;

- (NSString*) toJSON;
- (id) initFromJSONDictionary:(NSDictionary *)jsonDictionary;
- (BOOL) hasWordpress;
- (BOOL) hasFacebook;
- (BOOL) hasTwitter;

+ (id)          createInstanceOfAuthenticationContext;
+ (id)          createInstanceOfAuthenticationContextFromJSON:(NSDictionary*)jsonDictionary;

@end