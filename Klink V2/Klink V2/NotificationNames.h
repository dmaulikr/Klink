//
//  NotificationNames.h
//  Test Project 2
//
//  Created by Bobby Gill on 6/19/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import <Foundation/Foundation.h>


extern NSString* const n_CAPTION_CREATE;
extern NSString* const n_CAPTION_UPDATE;
extern NSString* const n_PHOTO_CREATE;
extern NSString* const n_PHOTO_UPDATE;
extern NSString* const n_USER_CREATE;
extern NSString* const n_USER_UPDATE;
extern NSString* const n_USERSTATISTICS_CREATE;
extern NSString* const n_USERSTATISTICS_UPDATE;
extern NSString* const n_IMAGEDOWNLOADED;

extern NSString* const n_USER_LOGGED_IN;
extern NSString* const n_USER_LOGGED_OUT;
extern NSString* const n_PHOTO_UPLOAD_START;
extern NSString* const n_PHOTO_UPLOAD_COMPLETE;

//called whenever a new feed object for a Caption vote event is created
extern NSString* const n_NEW_FEED_CAPTION_VOTE; 

//called whenever a new feed object for a Photo vote event is created
extern NSString* const n_NEW_FEED_PHOTO_VOTE; 

//called whenever a new caption object is created
extern NSString* const n_NEW_FEED_CAPTION;

//called whenever the news feed has been refreshed
extern NSString* const n_FEED_REFRESHED;

//called whenever a feed item has been read
extern NSString* const n_FEED_ITEM_CLEARED;