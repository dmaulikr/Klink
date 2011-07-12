//
//  Caption.h
//  Test Project 2
//
//  Created by Bobby Gill on 6/15/11.
//  Copyright (c) 2011 Blue Label Solutions LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "ServerManagedResource.h"
#import "TypeNames.h"

@interface Caption : ServerManagedResource  <IWireSerializable>{
@private
}
@property (nonatomic, retain) NSNumber * creatorid;
@property (nonatomic, retain) NSString* creatorname;
@property (nonatomic, retain) NSString * caption1;
@property (nonatomic, retain) NSString* title;
@property (nonatomic, retain) NSNumber * numberOfVotes;
@property (nonatomic, retain) NSNumber* photoid;
@property (nonatomic, retain) NSString* imageurl;
@property (nonatomic, retain) NSString* thumbnailurl;
+ (NSString*)getNewCaptionTitle;
+(NSString*)getNewCaptionNote;
- (BOOL) isTextCaption;
@end
