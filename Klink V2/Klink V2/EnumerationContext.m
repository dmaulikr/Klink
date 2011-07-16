//
//  EnumerationContext.m
//  Test Project 2
//
//  Created by Bobby Gill on 6/15/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import "EnumerationContext.h"


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
    
    [BLLog v:activityName withMessage:message];
    [message release];
    
    return self;
}

- (id) init {
//    self.isDone = [[NSNumber alloc]initWithInt:0];
//    self.pageSize = [[NSNumber alloc]initWithInt:0];
//    self.pageNumber = [[NSNumber alloc]initWithInt:0];
//    self.numberOfResultsReturned = [[NSNumber alloc]initWithInt:0];
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
+ (EnumerationContext*) contextForPhotosInTheme:(Theme*)theme {
    EnumerationContext* enumerationContext = [[[EnumerationContext alloc]init] autorelease];
    enumerationContext.pageSize =[NSNumber numberWithInt:1];
    enumerationContext.maximumNumberOfResults = [NSNumber numberWithInt:maxsize_PHOTODOWNLOAD];
    
    //TODO: we can intelligently guess the page we will need here in order to not make any repetitive calls
    
    return enumerationContext;
}
@end
