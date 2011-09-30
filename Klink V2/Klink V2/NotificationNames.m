//
//  NotificationNames.m
//  Test Project 2
//
//  Created by Bobby Gill on 6/19/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import "NotificationNames.h"


 NSString* const n_CAPTION_CREATE   = @"caption_create";
 NSString* const n_CAPTION_UPDATE   = @"caption_update";
 NSString* const n_PHOTO_CREATE     = @"photo_create";;
 NSString* const n_PHOTO_UPDATE     =@"photo_update";
 NSString* const n_USER_CREATE      = @"user_create";;
 NSString* const n_USER_UPDATE      =@"user_update";
 NSString* const n_USERSTATISTICS_CREATE = @"userstatistics_create";;
 NSString* const n_USERSTATISTICS_UPDATE=@"userstatistics_update";
 NSString* const n_IMAGEDOWNLOADED = @"image_downloaded";
 NSString* const n_USER_LOGGED_IN = @"user_logged_in";
 NSString* const n_USER_LOGGED_OUT=@"user_logged_out";
 NSString* const n_PHOTO_UPLOAD_START=@"photo_upload_start";
 NSString* const n_PHOTO_UPLOAD_COMPLETE=@"photo_upload_complete";


//called whenever a new feed object for a Caption vote event is created
NSString* const n_NEW_FEED_CAPTION_VOTE = @"feed_caption_vote_created"; 

//called whenever a new feed object for a Photo vote event is created
NSString* const n_NEW_FEED_PHOTO_VOTE = @"feed_photo_vote_created"; 

//called whenever a new feed object for a Caption event is created
NSString* const n_NEW_FEED_CAPTION = @"feed_caption_created";

//called whenver the news feed has been refreshed
NSString* const n_FEED_REFRESHED = @"feed_refreshed";

//callled whenever a feed item has been cleared/read by the user
NSString* const n_FEED_ITEM_CLEARED = @"feed_item_clear";