//
//  Caption.h
//  Platform
//
//  Created by Bobby Gill on 10/27/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Resource.h"

@interface Caption : Resource {
    
}
@property (nonatomic, retain) NSNumber * numberofflags;
@property (nonatomic,retain) NSString* caption1;
@property (nonatomic,retain) NSNumber* creatorid;
@property (nonatomic,retain) NSString* creatorname;
@property (nonatomic,retain) NSNumber* numberofvotes;
@property (nonatomic,retain) NSNumber* photoid;
@property (nonatomic,retain) NSNumber* hasvoted;
@property (nonatomic,retain) NSNumber* pageid;
@property (nonatomic,retain) NSNumber* hasseen;

//static initializers
+ (Caption*) createCaptionForPhoto:(NSNumber*)photoid withCaption:(NSString*)caption;
@end
