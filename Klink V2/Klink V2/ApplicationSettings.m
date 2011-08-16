//
//  ApplicationSettings.m
//  Test Project 2
//
//  Created by Bobby Gill on 6/16/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import "ApplicationSettings.h"


NSString* const stng_BASEURL = @"baseurl";
NSString* const fieldName_NOTIFICATION_SOURCE_OBJECT=@"notificationsource";
//NSString* const default_BASEURL = @"http://192.168.1.102/KlinkService";
NSString* const default_BASEURL = @"http://108.6.2.14/KlinkService";
NSString* const cacheName_ROOTVIEWCONTROLLER=@"RootViewController";
int const pageSize_PHOTO=10;
int const pageSize_PHOTOSINTHEME = 10;
int const pageSize_THEME = 5;
int const pageSize_THEMELINKEDOBJECTS = 5;
int const pageSize_CAPTION = 10;

int const maxsize_PHOTODOWNLOAD=1000;
int const maxsize_THEMEDOWNLOAD=100;
int const maxsize_CAPTIONDOWNLOAD = 1000;
int const batchSize_CAPTION=20;
int const batchSize_THEME=20;
int const size_NUMLINKEDOBJECTSTOTRETURN=5;
NSString* const cell_TEXTCAPTION =@"textCaptionCell";
NSString* const cell_IMAGECAPTION=@"imageCaptionCell";

int const timeout_ENUMERATION = 30;

//theme browsing view controller settings
int const threshold_LOADMOREPHOTOS = 10;
int const threshold_LOADMORETHEMES = 5;
int const threshold_LOADMORECAPTIONS = 10;

int const opcode_QUERYEQUALITY=1;

NSString* const facebook_APPID=@"168077769927457";
NSString* const sn_KEYCHAINSERVICENAME=@"Aardvark";


// text strings transparency
float const textAlpha = 0.9;

// caption text settings
int const maxlength_CAPTION = 30;
NSString* const font_CAPTION = @"Marker Felt";
int const fontsize_CAPTION = 16;

// theme title text settings
int const maxlength_THEME = 15;
NSString* const font_THEME = @"Marker Felt";
int const fontsize_THEME = 36;

// description text settings
int const maxlength_DESCRIPTION = 150;
NSString* const font_DESCRIPTION = @"Marker Felt";
int const fontsize_DESCRIPTION = 16;

