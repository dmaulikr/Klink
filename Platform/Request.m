//
//  Request.m
//  Platform
//
//  Created by Bobby Gill on 10/10/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import "Request.h"
#import "Types.h"

@implementation Request
@synthesize onFailCallback      = m_onFailCallback;
@synthesize onSuccessCallback   = m_onSuccessCallback;
@synthesize userInfo            = m_userInfo;
@synthesize changedAttributesList   = __changedAttributesList;
@dynamic targetresourceid;
@dynamic operationcode;
@dynamic statuscode;
@dynamic url;
@dynamic changedattributes;
@dynamic targetresourcetype;

#define kDelimeter @","

#pragma mark - Properties
- (NSArray*) changedAttributesList {
    if (__changedAttributesList != nil) {
        return __changedAttributesList;
    }
    
    __changedAttributesList = [self.changedattributes componentsSeparatedByString:kDelimeter];
    return __changedAttributesList;
}

#pragma initializers
- (id) initWithEntity:(NSEntityDescription*)entity insertIntoResourceContext:(ResourceContext*)resourceContext {
    self = [super initWithEntity:entity insertIntoManagedObjectContext:resourceContext.managedObjectContext];
    if (self) {
        self.statuscode = [NSNumber numberWithInt:kPENDING];

    }
    return self;
}
- (id) initFor:(NSNumber *)objectid 
 withOperation:(int)opcode 
  withUserInfo:(NSDictionary *)userInfo 
     onSuccess:(Callback *)onSuccessCallback 
     onFailure:(Callback *)onFailureCallback {
   
    self = [super init];
    if (self) {
        //initialize the request to be pending
        self.statuscode = [NSNumber numberWithInt:kPENDING];
        self.targetresourceid = objectid;
        self.operationcode = [NSNumber numberWithInt:opcode];
        self.onFailCallback = onFailureCallback;
        self.onSuccessCallback = onSuccessCallback;
        self.userInfo = userInfo;
    }
    return self;
}

+ (id) createInstanceOfRequest {
    ResourceContext* resourceContext = [ResourceContext instance];
    NSEntityDescription* entity = [NSEntityDescription entityForName:REQUEST inManagedObjectContext:resourceContext.managedObjectContext];
    Request* retVal = [[Request alloc]initWithEntity:entity insertIntoResourceContext:nil];
    [retVal autorelease];
    return retVal;
}
@end
