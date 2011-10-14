//
//  ApplicationSettings.h
//  Platform
//
//  Created by Bobby Gill on 10/10/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
@class Resouce;
@interface ApplicationSettings : Resource {
    
}

//Generic settings
@property (nonatomic, retain) NSString* base_url;

//Generic enumeration settings
@property (nonatomic,retain) NSNumber* pagesize;
@property (nonatomic,retain) NSNumber* numberoflinkedobjectstoreturn;

//Feed settings
@property (nonatomic,retain) NSNumber* feed_maxnumtodownload;

//Photo settings
@property (nonatomic,retain) NSNumber* photo_maxnumtodownload;

//Theme settings
@property (nonatomic,retain) NSNumber* theme_maxnumtodownload;

//Caption settings
@property (nonatomic,retain) NSNumber* caption_maxnumtodownload;

@end
