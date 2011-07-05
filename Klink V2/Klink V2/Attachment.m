//
//  Attachment.m
//  Test Project 2
//
//  Created by Bobby Gill on 7/2/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import "Attachment.h"


@implementation Attachment
@synthesize  objectid;
@synthesize objecttype;
@synthesize attributename;
@synthesize filelocation;

+ (id) attachmentWith:(NSNumber*)objectid objectType:(NSString*)objecttype forAttribute:(NSString*)attributeName atFileLocation:(NSString*)filePath {
    
    Attachment* attachment = [[[Attachment alloc]init]autorelease];
    attachment.objectid=objectid;
    attachment.objecttype= objecttype;
    attachment.attributename = attributeName;
    attachment.filelocation = filePath;
    
    return attachment;
}
@end
