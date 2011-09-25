//
//  EnumerationContext.m
//  Test Project 2
//
//  Created by Bobby Gill on 6/15/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import "EnumerationContext.h"
#import "DataLayer.h"
#import "Theme.h";
#import "Photo.h"
@implementation EnumerationContext
@synthesize pageSize;
@synthesize pageNumber;
@synthesize numberOfResultsReturned;
@synthesize isDone;
@synthesize maximumNumberOfResults;

- (id) initFromDictionary:(NSDictionary*)jsonDictionary {
    NSString* activityName = @"EnumerationContext.initFromDictionary:";
    self.pageSize = [jsonDictionary objectForKey:an_PAGESIZE];
    self.pageNumber = [jsonDictionary objectForKey:an_PAGENUMBER];
    self.numberOfResultsReturned = [jsonDictionary objectForKey:an_NUMBEROFRESULTSRETURNED];
    self.isDone = [jsonDictionary objectForKey:an_ISDONE];
    self.maximumNumberOfResults = [jsonDictionary objectForKey:an_MAXIMUMNUMBEROFRESULTS];
    
    
    NSString* message = [[NSString alloc]initWithFormat:@"Created with: pageSize=%@, pageNumber=%@, numberOfResultsReturned=%@, isDone=%@", pageSize,pageNumber,numberOfResultsReturned,isDone];
    
    //[BLLog v:activityName withMessage:message];
    [message release];
    
    return self;
}

- (id) init {

    self.pageSize = [NSNumber numberWithInt:pageSize_PHOTO];
    self.isDone = [NSNumber numberWithBool:NO];
    self.pageNumber = [NSNumber numberWithInt:0];
    self.numberOfResultsReturned = [NSNumber numberWithInt:0];
    return self;
}

- (void)dealloc {
       [super dealloc];
}

- (NSString*) toJSON {
    NSMutableDictionary* newDictionary = [[NSMutableDictionary alloc] init];
    [newDictionary setValue:self.pageSize forKey:an_PAGESIZE];
    [newDictionary setValue:self.pageNumber forKey:an_PAGENUMBER];
    [newDictionary setValue:self.numberOfResultsReturned forKey:an_NUMBEROFRESULTSRETURNED];
    [newDictionary setValue:self.maximumNumberOfResults forKey:an_MAXIMUMNUMBEROFRESULTS];
   
    [newDictionary setValue:self.isDone forKey:an_ISDONE];
    
    NSString *retVal =[newDictionary JSONString];
    [newDictionary release];
    return retVal;
}

#pragma mark - Static constructors for known scenarios
+ (EnumerationContext*) contextForPhotosInTheme:(NSNumber*)themeid {
    EnumerationContext* enumerationContext = [[[EnumerationContext alloc]init] autorelease];
    enumerationContext.pageSize =[NSNumber numberWithInt:pageSize_PHOTOSINTHEME];
    enumerationContext.maximumNumberOfResults = [NSNumber numberWithInt:maxsize_PHOTODOWNLOAD];
    
    //TODO: we can intelligently guess the page we will need here in order to not make any repetitive calls
    NSArray* photosInTheme = [DataLayer getObjectsByType:PHOTO withValueEqual:[themeid stringValue]  forAttribute:an_THEMEID];
    int count = [photosInTheme count];
    
    enumerationContext.pageNumber =[NSNumber numberWithInt:(count / [enumerationContext.pageSize intValue])];
    
    return enumerationContext;
}

//Returns an enumeration context to pull down the next theme if we run out in the main theme browser view controller
+ (EnumerationContext*) contextForThemes {
    EnumerationContext* enumerationContext = [[[EnumerationContext alloc]init] autorelease];
    enumerationContext.pageSize =[NSNumber numberWithInt:pageSize_THEME];
    enumerationContext.maximumNumberOfResults = [NSNumber numberWithInt:maxsize_THEMEDOWNLOAD];
    
    //TODO: we can intelligently guess the page we will need here in order to not make any repetitive calls
//    NSArray* themes = [DataLayer getObjectsByType:tn_THEME sortBy:an_DATECREATED sortAscending:NO];
//    int count = [themes count];
//    
//    enumerationContext.pageNumber =[NSNumber numberWithInt:(count / [enumerationContext.pageSize intValue])];
    
    return enumerationContext;
}

+ (EnumerationContext*) contextForCaptions:(NSNumber *)photoid {
    EnumerationContext* enumerationContext = [[[EnumerationContext alloc]init]autorelease];
    enumerationContext.pageSize = [NSNumber numberWithInt:pageSize_CAPTION];
    enumerationContext.maximumNumberOfResults = [NSNumber numberWithInt:maxsize_CAPTIONDOWNLOAD];
    
    NSArray* captions = [DataLayer getObjectsByType:CAPTION withValueEqual:[photoid stringValue] forAttribute:an_PHOTOID sortBy:an_NUMBEROFVOTES sortAscending:NO];
    
    int count = [captions count];
    enumerationContext.pageNumber = [NSNumber numberWithInt:(count / [enumerationContext.pageSize intValue])];
    return enumerationContext;
    
}

@end
