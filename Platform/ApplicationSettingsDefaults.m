//
//  ApplicationSettings.m
//  Test Project 2
//
//  Created by Bobby Gill on 6/16/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import "ApplicationSettingsDefaults.h"


//this URL is to connect to BOBBY's development environment
//NSString* const default_BASEURL = @"http://108.6.2.14/bonobo/rest";

//this URL is to connect to BOBBY's development environment from his internal network
//NSString* const default_BASEURL = @"http://192.168.1.102/bonobo/rest";

//this URL is to connect to JORDAN's development environment over the internet
//NSString* const default_BASEURL = @"http://216.243.43.184/bonobo/rest";

//this URL is to connect to JORDAN's development environment from his internal network
//NSString* const default_BASEURL = @"http://192.168.1.4/bonobo/rest";

//this URL is to connect to the PRODUCTION environment in the cloud
NSString* const default_BASEURL = @"http://oscial.com/bonobo/rest";

int const maxsize_PHOTODOWNLOAD=1000;
int const maxsize_THEMEDOWNLOAD=100;
int const maxsize_CAPTIONDOWNLOAD = 1000;
int const maxsize_FEEDDOWNLOAD = 50;
int const pagesize = 10;
int const size_NUMLINKEDOBJECTSTOTRETURN=5;
int const timeout_HTTP = 60;
int const threshold_FEED_ENUMERATION_TIME_GAP=60;
int const threshold_CAPTION_ENUMERATION_TIME_GAP=60;
int const threshold_PAGE_ENUMERATION_TIME_GAP=60;
int const page_size_LINKEDOBJECTS = 5;
int const page_DRAFTEXPIRES_SECONDS = 86400;
NSString* const twitter_CONSUMERKEY=@"oy2bDqBeASOP7fXXwqOAQ";
NSString* const twitter_CONSUMERSECRET=@"E3Rl4smkXxB6C4UZxqxK7CyXsiab1pkgIc8UIBHgQ";
