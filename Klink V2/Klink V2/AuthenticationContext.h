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

@interface AuthenticationContext : NSManagedObject <IWireSerializable>{
@private
}
@property (nonatomic, retain) NSNumber * userid;
@property (nonatomic, retain) NSDate * expiryDate;
@property (nonatomic, retain) NSString * token;

//- (id) initWithEntity:(NSEntityDescription *)entity insertIntoManagedObjectContext:(NSManagedObjectContext *)context;
- (void) copyFrom:(AuthenticationContext*)newContext;
+ (id)newInstance;
@end
