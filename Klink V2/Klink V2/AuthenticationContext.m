//
//  AuthenticationContext.m
//  Test Project 2
//
//  Created by Bobby Gill on 6/16/11.
//  Copyright (c) 2011 Blue Label Solutions LLC. All rights reserved.
//

#import "AuthenticationContext.h"
#import "JSONKit.h"

@implementation AuthenticationContext
@synthesize userid = m_userid;
@synthesize expiryDate = m_expiryDate;
@synthesize token = m_token;
@synthesize facebookAccessToken = m_facebookAccessToken;
@synthesize facebookAccessTokenExpiryDate = m_facebookAccessTokenExpiryDate;
@synthesize facebookUserID = m_facebookUserID;
@synthesize twitterAccessToken = m_twitterAccessToken;
@synthesize twitterAccessTokenExpiryDate = m_twitterAccessTokenExpiryDate;
@synthesize twitterUserID = m_twitterUserID;
@synthesize wpPassword = m_wpPassword;
@synthesize wpUsername = m_wpUsername;
@synthesize wordpressURL = m_wordpressURL;
@synthesize twitterAccessTokenSecret = m_twitterAccessTokenSecret;

- (id) initFromDictionary:(NSDictionary*)jsonDictionary { 
    NSNumber* expiryDateSinceEpoch = [jsonDictionary valueForKey:an_EXPIRY_DATE];
    self.expiryDate = [NSDate dateWithTimeIntervalSince1970:[expiryDateSinceEpoch doubleValue]];
    self.token = [jsonDictionary valueForKey:an_TOKEN];
    self.userid = [jsonDictionary valueForKey:an_USERID];
    
    NSNumber* fb_expiryDateSinceEpoch = [jsonDictionary valueForKey:an_FACEBOOKTOKENEXPIRYDATE];
    
    if ([fb_expiryDateSinceEpoch doubleValue] != 0) {
        self.facebookAccessTokenExpiryDate = [NSDate dateWithTimeIntervalSince1970:[fb_expiryDateSinceEpoch doubleValue]];
    }
    else {
        self.facebookAccessTokenExpiryDate = [NSDate dateWithTimeIntervalSince1970:facebook_MAXDATE];;
    }
  
    self.facebookAccessToken = [jsonDictionary valueForKey:an_FACEBOOKACCESSTOKEN];
    self.facebookUserID = [jsonDictionary valueForKey:an_FACEBOOKUSERID];
    self.twitterUserID = [jsonDictionary valueForKey:an_TWITTERUSERID];
    self.twitterAccessToken = [jsonDictionary valueForKey:an_TWITTERACCESSTOKEN];
    self.twitterAccessTokenExpiryDate = [jsonDictionary valueForKey:an_TWITTERTOKENEXPIRYDATE];
    self.wpPassword = [jsonDictionary valueForKey:an_WORDPRESSPASSWORD];
    self.wpUsername = [jsonDictionary valueForKey:an_WORDPRESSUSERNAME];
    self.wordpressURL = [jsonDictionary valueForKey:an_WORDPRESSURL];
    self.twitterAccessTokenSecret = [jsonDictionary valueForKey:an_TWITTERACCESSTOKENSECRET];
    return self;
}

- (void) copyFrom:(AuthenticationContext*)newContext {
    self.expiryDate = newContext.expiryDate;
    self.token = newContext.token;
    self.userid = newContext.userid;
    self.facebookAccessTokenExpiryDate = newContext.facebookAccessTokenExpiryDate;
    self.facebookAccessToken = newContext.facebookAccessToken;
    self.facebookUserID = newContext.facebookUserID;
    self.twitterUserID = newContext.twitterUserID;
    self.twitterAccessTokenExpiryDate = newContext.twitterAccessTokenExpiryDate;
    self.twitterAccessToken = newContext.twitterAccessToken;
    self.wordpressURL = newContext.wordpressURL;
    self.wpUsername = newContext.wpUsername;
    self.wpPassword = newContext.wpPassword;
    self.twitterAccessTokenSecret = newContext.twitterAccessTokenSecret;
}

- (NSString*) toJSON {
    NSMutableDictionary* newDictionary = [[NSMutableDictionary alloc] init];
    NSTimeInterval interval =  [self.expiryDate timeIntervalSince1970];

    [newDictionary setValue:[NSNumber numberWithDouble:interval] forKey:an_EXPIRY_DATE];
    [newDictionary setValue:self.token forKey:an_TOKEN];
    [newDictionary setValue:self.userid forKey:an_USERID];
    [newDictionary setValue:self.facebookAccessToken forKey:an_FACEBOOKACCESSTOKEN];
    
    double dbl_facebookAccessTokenExpiry =[self.facebookAccessTokenExpiryDate timeIntervalSince1970];
    if (dbl_facebookAccessTokenExpiry == facebook_MAXDATE) {
        [newDictionary setValue:[NSNumber numberWithInt:0] forKey:an_FACEBOOKTOKENEXPIRYDATE];
    }
    else {
        [newDictionary setValue:self.facebookAccessTokenExpiryDate
          forKey:an_FACEBOOKTOKENEXPIRYDATE];
    }
   
    [newDictionary setValue:self.facebookUserID forKey:an_FACEBOOKUSERID];
    [newDictionary setValue:self.twitterAccessToken forKey:an_TWITTERACCESSTOKEN];
    //we dont use the twitter expirt date, so we put 0 in it as a stub
    [newDictionary setValue:[NSNumber numberWithInt:0] forKey:an_TWITTERTOKENEXPIRYDATE];
    [newDictionary setValue:self.twitterAccessTokenSecret forKey:an_TWITTERACCESSTOKENSECRET];
    [newDictionary setValue:self.twitterUserID forKey:an_TWITTERUSERID];
    [newDictionary setValue:self.wpPassword forKey:an_WORDPRESSPASSWORD];
    [newDictionary setValue:self.wpUsername forKey:an_WORDPRESSUSERNAME];
    [newDictionary setValue:self.wordpressURL forKey:an_WORDPRESSURL];
    NSError* error = nil;
    JKSerializeOptionFlags flags = JKSerializeOptionNone;
                                    
    NSString *retVal =[newDictionary JSONStringWithOptions:flags error:&error];
    [newDictionary release];
    return retVal;
}

- (BOOL) hasWordpress {
    BOOL retVal = NO;
    
    if (self.wpUsername != nil && self.wordpressURL != nil) {
        retVal = YES;
    }
    return retVal;
}

- (BOOL) hasFacebook {
    BOOL retVal = NO;
    
    if (self.facebookUserID != nil && self.facebookAccessToken != nil) {
        retVal = YES;
    }
    return retVal;
}

- (BOOL) hasTwitter {
    BOOL retVal = NO;
    
    if (self.twitterUserID != nil && ![self.twitterUserID isEqual:[NSNull null]]  
        && self.twitterAccessTokenSecret != nil && ![self.twitterAccessTokenSecret isEqual:[NSNull null]] 
        && self.twitterAccessToken != nil && ![self.twitterAccessToken isEqual:[NSNull null]]) {
        retVal = YES;
    }
    return retVal;
}

+ (NSString*) getTypeName {
    return tn_AUTHENTICATIONCONTEXT;
}



+ (id) newInstance {
    Klink_V2AppDelegate *appDelegate = (Klink_V2AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *appContext = appDelegate.managedObjectContext;
    NSEntityDescription *entity = [NSEntityDescription entityForName:tn_AUTHENTICATIONCONTEXT inManagedObjectContext:appContext];
    
    AuthenticationContext* authenticationContext = [[AuthenticationContext alloc] initWithEntity:entity insertIntoManagedObjectContext:nil];
    return authenticationContext;
}
@end
