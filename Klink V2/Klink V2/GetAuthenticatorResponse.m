//
//  GetAuthenticatorResponse.m
//  Klink V2
//
//  Created by Bobby Gill on 7/22/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import "GetAuthenticatorResponse.h"


@implementation GetAuthenticatorResponse
@synthesize authenticationcontext;
@synthesize user;
- (id) initFromDictionary:(NSDictionary*)jsonDictionary {
    self = [super initFromDictionary:jsonDictionary]; 
    
    if (self != nil) {
        NSDictionary* authenticationContextDictionary = [jsonDictionary objectForKey:an_AUTHENTICATIONCONTEXT];
        self.authenticationcontext = [[AuthenticationContext alloc] initFromDictionary:authenticationContextDictionary];
        
        Klink_V2AppDelegate *appDelegate = (Klink_V2AppDelegate *)[[UIApplication sharedApplication] delegate];
        NSManagedObjectContext *appContext = appDelegate.managedObjectContext;    
        
        NSEntityDescription* entityDescription = [NSEntityDescription entityForName:USER inManagedObjectContext:appContext];
        self.user = [[User alloc]initWithEntity:entityDescription insertIntoManagedObjectContext:nil];       
        [self.user initFromDictionary:[jsonDictionary objectForKey:an_USER]];
    }
    return self;
}

- (void) dealloc {
    [self.authenticationcontext release];
    [self.user release];
    [super dealloc];
}
@end
