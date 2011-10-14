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

@interface AuthenticationContext : Resource {

@private
}
@property (nonatomic, retain) NSNumber * userid;
@property (nonatomic, retain) NSDate * expirydate;
@property (nonatomic, retain) NSString * token;
@property (nonatomic, retain) NSString* facebookaccesstoken;
@property (nonatomic, retain) NSDate* facebookaccesstokenexpirydate;
@property (nonatomic, retain) NSString* facebookuserid;
@property (nonatomic, retain) NSString* twitteraccesstoken;
@property (nonatomic, retain) NSString* twitteruserid;
@property (nonatomic, retain) NSString* wordpressurl;
@property (nonatomic, retain) NSString* wpusername;
@property (nonatomic, retain) NSString* wppassword;

//- (NSString*) toJSON;
- (BOOL) hasWordpress;
- (BOOL) hasFacebook;
@end
