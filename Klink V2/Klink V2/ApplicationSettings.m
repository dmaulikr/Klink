//
//  ApplicationSettings.m
//  Test Project 2
//
//  Created by Bobby Gill on 6/16/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import "ApplicationSettings.h"

NSString* const stng_LASTLOGGEDINUSERID = @"lastloggedinuserid";
NSString* const stng_BASEURL = @"baseurl";
NSString* const fieldName_NOTIFICATION_SOURCE_OBJECT=@"notificationsource";
//NSString* const default_BASEURL = @"http://192.168.1.102/KlinkService";
NSString* const default_BASEURL = @"http://108.6.2.14/KlinkService";
NSString* const cacheName_ROOTVIEWCONTROLLER=@"RootViewController";
int const pageSize_PHOTO=10;
int const maxsize_PHOTODOWNLOAD=1000;
int const batchSize_CAPTION=20;
int const batchSize_THEME=20;
int const size_NUMLINKEDOBJECTSTOTRETURN=5;
NSString* const cell_TEXTCAPTION =@"textCaptionCell";
NSString* const cell_IMAGECAPTION=@"imageCaptionCell";

int const timeout_ENUMERATION = 30;

//theme browsing view controller settings
int const threshold_LOADMOREPHOTOS = 10;

int const opcode_QUERYEQUALITY=1;