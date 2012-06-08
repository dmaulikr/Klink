//
//  EnumerationContext.m
//  Test Project 2
//
//  Created by Bobby Gill on 6/15/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import "EnumerationContext.h"
#import "Attributes.h"
#import "ApplicationSettings.h"
#import "ApplicationSettingsManager.h"
#import "Types.h"

@implementation EnumerationContext
@synthesize pageSize                = m_pageSize;
@synthesize pageNumber              = m_pageNumber;
@synthesize numberOfResultsReturned = m_numberOfResultsReturned;
@synthesize isDone                  = m_isDone;
@synthesize maximumNumberOfResults  = m_maximumNumberOfResults;

- (id) initFromJSONDictionary:(NSDictionary*)jsonDictionary {
    self.pageSize                   = [jsonDictionary valueForKey:PAGESIZE];
    self.pageNumber                 = [jsonDictionary valueForKey:PAGENUMBER];
    self.numberOfResultsReturned    = [jsonDictionary valueForKey:NUMBEROFRESULTSRETURNED];
    self.isDone                     = [jsonDictionary valueForKey:ISDONE];
    self.maximumNumberOfResults     = [jsonDictionary valueForKey:MAXIMUMNUMBEROFRESULTS];
    
    return self;
}

- (id) initFromJSON:(NSString *)json {
    NSDictionary* jsonDictionary = [json objectFromJSONString];
    return [self initFromJSONDictionary:jsonDictionary];
}

- (id) init {
    ApplicationSettings* settingsObject = [[ApplicationSettingsManager instance] settings];
    self = [super init];
    
    if (self) {
        self.pageSize                   = settingsObject.pagesize;
        self.isDone                     = [NSNumber numberWithBool:NO];
        self.pageNumber                 = [NSNumber numberWithInt:0];
        self.numberOfResultsReturned    = [NSNumber numberWithInt:0];
    }
    return self;
}

- (void)dealloc {
       [super dealloc];
}

- (NSString*) toJSON {
    

    NSMutableDictionary* newDictionary = [[NSMutableDictionary alloc] init];
    [newDictionary setValue:self.pageSize forKey:PAGESIZE];
    [newDictionary setValue:self.pageNumber forKey:PAGENUMBER];
    [newDictionary setValue:self.numberOfResultsReturned forKey:NUMBEROFRESULTSRETURNED];
    [newDictionary setValue:self.maximumNumberOfResults forKey:MAXIMUMNUMBEROFRESULTS];   
    [newDictionary setValue:self.isDone forKey:ISDONE];
    
    NSString *retVal =[newDictionary JSONString];
    [newDictionary release];
    return retVal;
}

#pragma mark - Static constructors for known scenarios
+ (EnumerationContext*) contextForFeeds:(NSNumber *)userid {
    ApplicationSettings* settingsObject = [[ApplicationSettingsManager instance] settings];
    EnumerationContext* enumerationContext = [[[EnumerationContext alloc]init] autorelease];
    enumerationContext.pageSize =settingsObject.pagesize;
    enumerationContext.maximumNumberOfResults = settingsObject.feed_maxnumtodownload;
    
    return enumerationContext;

}

+ (EnumerationContext*)contextForAchievements:(NSNumber *)userid
{
    ApplicationSettings* settingsObject = [[ApplicationSettingsManager instance] settings];
    EnumerationContext* enumerationContext = [[[EnumerationContext alloc]init] autorelease];
    enumerationContext.pageSize = settingsObject.pagesize;
    enumerationContext.maximumNumberOfResults = settingsObject.pagesize;
    return enumerationContext;
}


+ (EnumerationContext*) contextForLeaderboard
{
    ApplicationSettings* settingsObject = [[ApplicationSettingsManager instance] settings];
    EnumerationContext* enumerationContext = [[[EnumerationContext alloc]init] autorelease];
    //enumerationContext.pageSize = settingsObject.pagesize;
    //enumerationContext.maximumNumberOfResults = settingsObject.pagesize;
    enumerationContext.pageSize = [NSNumber numberWithInt:10];
    enumerationContext.maximumNumberOfResults = [NSNumber numberWithInt:10];
    return enumerationContext;
}

+ (EnumerationContext*) contextForDrafts {
    ApplicationSettings* settingsObject = [[ApplicationSettingsManager instance] settings];
    EnumerationContext* enumerationContext = [[[EnumerationContext alloc]init] autorelease];
    enumerationContext.pageSize = settingsObject.pagesize;
    enumerationContext.maximumNumberOfResults = settingsObject.page_maxnumtodownload;    
    return enumerationContext;

}


+ (EnumerationContext*) contextForPhotosInTheme:(NSNumber*)themeid {
    ApplicationSettings* settingsObject = [[ApplicationSettingsManager instance] settings];
    EnumerationContext* enumerationContext = [[[EnumerationContext alloc]init] autorelease];
    enumerationContext.pageSize =settingsObject.pagesize;
    enumerationContext.maximumNumberOfResults =  settingsObject.photo_maxnumtodownload;
    enumerationContext.pageNumber = [NSNumber numberWithInt:0];
    
    return enumerationContext;
}

//Returns an enumeration context to pull down the next theme if we run out in the main theme browser view controller
+ (EnumerationContext*) contextForPages {
    ApplicationSettings* settingsObject = [[ApplicationSettingsManager instance] settings];
    EnumerationContext* enumerationContext = [[[EnumerationContext alloc]init] autorelease];
    enumerationContext.pageSize = settingsObject.pagesize;
    enumerationContext.maximumNumberOfResults = settingsObject.page_maxnumtodownload;    
    return enumerationContext;
}

+ (EnumerationContext*)contextForUser:(NSNumber *)userid {
    EnumerationContext* enumerationContext = [[[EnumerationContext alloc]init] autorelease];
    enumerationContext.pageSize = [NSNumber numberWithInt:1];
    enumerationContext.maximumNumberOfResults = [NSNumber numberWithInt:1];
    return enumerationContext;

}

+ (EnumerationContext*) contextForObjectIDs:(NSArray*)objectIDs 
                                  withTypes:(NSArray*)objectTypes 
{
    EnumerationContext* enumerationContext = [[[EnumerationContext alloc]init] autorelease];
    enumerationContext.pageSize = [NSNumber numberWithInt:[objectIDs count]];
    enumerationContext.maximumNumberOfResults = [NSNumber numberWithInt:[objectIDs count]];
    return enumerationContext;
}


+ (EnumerationContext*) contextForCaptions:(NSNumber *)photoid {
    ApplicationSettings* settingsObject = [[ApplicationSettingsManager instance] settings];
    EnumerationContext* enumerationContext = [[[EnumerationContext alloc]init]autorelease];
    enumerationContext.pageSize = settingsObject.pagesize;
    enumerationContext.maximumNumberOfResults = settingsObject.caption_maxnumtodownload;
    
    
    //TODO: hook up new query generation code
//    NSArray* captions = [DataLayer getObjectsByType:CAPTION withValueEqual:[photoid stringValue] forAttribute:an_PHOTOID sortBy:an_NUMBEROFVOTES sortAscending:NO];
//    
//    int count = [captions count];
//    enumerationContext.pageNumber = [NSNumber numberWithInt:(count / [enumerationContext.pageSize intValue])];
    
    enumerationContext.pageNumber = [NSNumber numberWithInt:0];
    return enumerationContext;
    
}

+ (EnumerationContext*)contextForApplicationSettings:(NSNumber *)userid 
{
    ApplicationSettings* settingsObject = [[ApplicationSettingsManager instance] settings];
    EnumerationContext* enumerationContext = [[[EnumerationContext alloc]init] autorelease];
    enumerationContext.pageSize = settingsObject.pagesize;
    enumerationContext.maximumNumberOfResults = [NSNumber numberWithInt:1];   
    return enumerationContext;
}

+ (EnumerationContext*) contextForFollowers:(NSNumber *)userid 
{
    ApplicationSettings* settingsObject = [[ApplicationSettingsManager instance] settings];
    EnumerationContext* enumerationContext = [[[EnumerationContext alloc]init] autorelease];
    enumerationContext.pageSize = settingsObject.pagesize;
    enumerationContext.maximumNumberOfResults = settingsObject.follow_maxnumtodownload;    
    return enumerationContext;

}

+ (EnumerationContext*) contextForFollowing:(NSNumber *)userid
{
    ApplicationSettings* settingsObject = [[ApplicationSettingsManager instance] settings];
    EnumerationContext* enumerationContext = [[[EnumerationContext alloc]init] autorelease];
    enumerationContext.pageSize = settingsObject.pagesize;
    enumerationContext.maximumNumberOfResults = settingsObject.follow_maxnumtodownload;    
    return enumerationContext;

}

@end
