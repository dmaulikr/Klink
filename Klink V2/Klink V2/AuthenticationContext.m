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
@dynamic expiryDate;
@dynamic token;
@dynamic userid;

- (id) initFromDictionary:(NSDictionary*)jsonDictionary {    
    self.expiryDate =  [DateTimeHelper parseWebServiceDateDouble:[jsonDictionary valueForKey:an_EXPIRY_DATE]];
    self.token = [jsonDictionary valueForKey:an_TOKEN];
    self.userid = [jsonDictionary valueForKey:an_USERID];
    return self;
}

- (void) copyFrom:(AuthenticationContext*)newContext {
    self.expiryDate = newContext.expiryDate;
    self.token = newContext.token;
    self.userid = newContext.userid;
}

- (NSString*) toJSON {
    NSMutableDictionary* newDictionary = [[NSMutableDictionary alloc] init];
    NSTimeInterval interval =  [self.expiryDate timeIntervalSince1970];

    [newDictionary setObject:[NSNumber numberWithDouble:interval] forKey:an_EXPIRY_DATE];
    [newDictionary setObject:self.token forKey:an_TOKEN];
    [newDictionary setObject:self.userid forKey:an_USERID];
    
    NSError* error = nil;
    JKSerializeOptionFlags flags = JKSerializeOptionNone;
                                    
    NSString *retVal =[newDictionary JSONStringWithOptions:flags error:&error];
    [newDictionary release];
    return retVal;
}

+ (NSString*) getTypeName {
    return tn_AUTHENTICATIONCONTEXT;
}


//- (id) initWithEntity:(NSEntityDescription *)entity insertIntoManagedObjectContext:(NSManagedObjectContext *)context {
//    self = [super initWithEntity:entity insertIntoManagedObjectContext:context];
//    
//    if (self != nil) {
//        self.expiryDate = [[NSDate alloc] init];
//        self.token = [[NSString alloc] init];
//        self.userid = [[NSNumber alloc] initWithInt:0];
//
//    }
//    return self;
//}

+ (id) newInstance {
    Klink_V2AppDelegate *appDelegate = (Klink_V2AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *appContext = appDelegate.managedObjectContext;
    NSEntityDescription *entity = [NSEntityDescription entityForName:tn_AUTHENTICATIONCONTEXT inManagedObjectContext:appContext];
    
    AuthenticationContext* authenticationContext = [[AuthenticationContext alloc] initWithEntity:entity insertIntoManagedObjectContext:nil];
    return authenticationContext;
}
@end
