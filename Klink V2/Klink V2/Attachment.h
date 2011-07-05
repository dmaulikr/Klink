//
//  Attachment.h
//  Test Project 2
//
//  Created by Bobby Gill on 7/2/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Attachment : NSObject {
    NSNumber* objectid;
    NSString* objecttype;
    NSString* attributename;
    NSString* filelocation;
}

@property (nonatomic,retain) NSNumber* objectid;
@property (nonatomic, retain) NSString* objecttype;
@property (nonatomic, retain) NSString* attributename;
@property (nonatomic, retain) NSString* filelocation;

+ (id) attachmentWith:(NSNumber*)objectid objectType:(NSString*)objecttype forAttribute:(NSString*)attributeName atFileLocation:(NSString*)filePath;
@end
