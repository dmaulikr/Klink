//
//  ApplicationSettings.h
//  Test Project 2
//
//  Created by Bobby Gill on 6/16/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

//extern NSString* const stng_BASEURL;
extern NSString* const default_BASEURL;
//extern NSString* const fieldName_NOTIFICATION_SOURCE_OBJECT;


extern int const maxsize_PHOTODOWNLOAD;
extern int const maxsize_THEMEDOWNLOAD;
extern int const maxsize_CAPTIONDOWNLOAD;
extern int const maxsize_FEEDDOWNLOAD;
extern int const maxsize_FOLLOWDOWNLOAD;

extern int const pagesize;
extern int const size_NUMLINKEDOBJECTSTOTRETURN;
extern int const timeout_HTTP;
extern int const page_size_LINKEDOBJECTS;
extern NSString* const twitter_CONSUMERKEY;
extern NSString* const twitter_CONSUMERSECRET;
extern int const page_DRAFTEXPIRES_SECONDS;

////governs how often a cloud enumerator can execute an enum against the service (in seconds)
extern int const threshold_CAPTION_ENUMERATION_TIME_GAP;
//extern long const threshold_PHOTO_ENUMERATION_TIME_GAP;
extern int const threshold_PAGE_ENUMERATION_TIME_GAP;
extern int const threshold_FEED_ENUMERATION_TIME_GAP;
extern int const threshold_FOLLOW_ENUMERATION_TIME_GAP;

extern int const progress_MAXSECONDSTODISPLAY;
extern int const progress_WHEELSPINTIME;
extern int const default_POLL_EXPIRY_IN_SECONDS;
extern int const default_POLL_NUM_PAGES;
extern int const EDITOR_MINIMUM;
extern int const delete_expired_objects;
