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

- (id) initFromDictionary:(NSDictionary*)jsonDictionary { 
    NSNumber* expiryDateSinceEpoch = [jsonDictionary valueForKey:an_EXPIRY_DATE];
    self.expiryDate = [NSDate dateWithTimeIntervalSince1970:[expiryDateSinceEpoch doubleValue]];
    self.token = [jsonDictionary valueForKey:an_TOKEN];
    self.userid = [jsonDictionary valueForKey:an_USERID];
    self.facebookAccessTokenExpiryDate = [jsonDictionary valueForKey:an_FACEBOOKTOKENEXPIRYDATE];
    self.facebookAccessToken = [jsonDictionary valueForKey:an_FACEBOOKACCESSTOKEN];
    self.facebookUserID = [jsonDictionary valueForKey:an_FACEBOOKUSERID];
    self.twitterUserID = [jsonDictionary valueForKey:an_TWITTERUSERID];
    self.twitterAccessToken = [jsonDictionary valueForKey:an_TWITTERACCESSTOKEN];
    self.twitterAccessTokenExpiryDate = [jsonDictionary valueForKey:an_TWITTERTOKENEXPIRYDATE];
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
}

- (NSString*) toJSON {
    NSMutableDictionary* newDictionary = [[NSMutableDictionary alloc] init];
    NSTimeInterval interval =  [self.expiryDate timeIntervalSince1970];

    [newDictionary setValue:[NSNumber numberWithDouble:interval] forKey:an_EXPIRY_DATE];
    [newDictionary setValue:self.token forKey:an_TOKEN];
    [newDictionary setValue:self.userid forKey:an_USERID];
    [newDictionary setValue:self.facebookAccessToken forKey:an_FACEBOOKACCESSTOKEN];
    [newDictionary setValue:self.facebookAccessTokenExpiryDate forKey:an_FACEBOOKTOKENEXPIRYDATE];
    [newDictionary setValue:self.facebookUserID forKey:an_FACEBOOKUSERID];
    [newDictionary setValue:self.twitterAccessToken forKey:an_TWITTERACCESSTOKEN];
    [newDictionary setValue:self.twitterAccessTokenExpiryDate forKey:an_TWITTERTOKENEXPIRYDATE];
    [newDictionary setValue:self.twitterUserID forKey:an_TWITTERUSERID];
    NSError* error = nil;
    JKSerializeOptionFlags flags = JKSerializeOptionNone;
                                    
    NSString *retVal =[newDictionary JSONStringWithOptions:flags error:&error];
    [newDictionary release];
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
