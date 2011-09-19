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
//NSString* const default_BASEURL = @"http://www.oscial.com/service";
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
int const threshold_LOADMOREPHOTOS = 4;
int const threshold_LOADMORETHEMES = 2;
int const threshold_LOADMORECAPTIONS = 2;

int const opcode_QUERYEQUALITY=1;

NSString* const facebook_APPID=@"168077769927457";
double const facebook_MAXDATE=64092211200;
NSString* const sn_KEYCHAINSERVICENAME=@"Aardvark";


// text strings transparency
float const textAlpha = 1;

// caption text settings
int const maxlength_CAPTION = 150;
NSString* const font_CAPTION = @"Helvetica";
int const fontsize_CAPTION = 16;

// photo credits text settings
int const maxlength_PHOTOCREDITS = 50;
NSString* const font_PHOTOCREDITS = @"Helvetica";
int const fontsize_PHOTOCREDITS = 14;

// theme title text settings
int const maxlength_THEME = 15;
NSString* const font_THEME = @"Helvetica";
int const fontsize_THEME = 36;

// description text settings
int const maxlength_DESCRIPTION = 150;
NSString* const font_DESCRIPTION = @"Helvetica";
int const fontsize_DESCRIPTION = 16;

NSString* const delimeter_HASHTAGS = @",";
NSString* const category_WORDPRESS = @"aardvark";
int const default_width_WORDPRESSIMAGE = 593;
int const default_height_WORDPRESSIMAGE = 261;
int const max_height_WORDPRESSIMAGE = 600;
int const max_width_WORDPRESSIMAGE=600;

long const threshold_CAPTION_ENUMERATION_TIME_GAP = 60;
long const threshold_PHOTO_ENUMERATION_TIME_GAP = 60;
long const threshold_THEME_ENUMERATION_TIME_GAP = 60;