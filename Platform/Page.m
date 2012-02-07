//
//  Page.m
//  Platform
//
//  Created by Bobby Gill on 10/26/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import "Page.h"
#import "Caption.h"
#import "Photo.h"
#import "ImageManager.h"
#import "User.h"
#import "AuthenticationManager.h"
#import "ApplicationSettings.h"
#import "ApplicationSettingsManager.h"
#import "DateTimeHelper.h"
#import "PageState.h"
#define kDELIMETER  @","

@implementation Page
@dynamic hashtags;
@dynamic displayname;
@dynamic descr;
@dynamic datedraftexpires;
@dynamic imageurl;
@dynamic thumbnailurl;
@dynamic creatorid;
@dynamic creatorname;
@dynamic state;
@dynamic datepublished;
@dynamic numberofphotos;
@dynamic numberofcaptions;
@dynamic numberofpublishvotes;
@dynamic finishedcaptionid;
@dynamic finishedphotoid;
@dynamic numberofflags;


#pragma mark - Instance Methods
- (NSArray*) hashtagList {
    NSArray* retVal = [self.hashtags componentsSeparatedByString:kDELIMETER];
    return retVal;
}

- (Caption*)captionWithHighestVotes {
    //returns the caption objecyt associated with the photo for this page with the highest number of votes
    Caption* retVal = nil;
    ResourceContext* resourceContext = [ResourceContext instance];
    NSSortDescriptor* sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:NUMBEROFVOTES ascending:NO];
    NSSortDescriptor* sortDescriptor2 = [NSSortDescriptor sortDescriptorWithKey:DATECREATED ascending:YES];
    
    if ([self.state intValue] == kPUBLISHED) 
    {
        retVal = (Caption*)[resourceContext resourceWithType:CAPTION withID:self.finishedcaptionid];
    }
    else 
    {
        NSArray* captions = [resourceContext resourcesWithType:CAPTION withValueEqual:[self.objectid stringValue] forAttribute:PAGEID sortBy:[NSArray arrayWithObjects:sortDescriptor,sortDescriptor2,nil]];
        
        if ([captions count] > 0) 
        {
            retVal = [captions objectAtIndex:0];
        }
    }
    return retVal;

}

-(Photo*)photoWithHighestVotes {
    ResourceContext* resourceContext = [ResourceContext instance];
    Caption* captionWithHighestVotes = [self captionWithHighestVotes];
    Photo* photo = (Photo*)[resourceContext resourceWithType:PHOTO withID:captionWithHighestVotes.photoid];
    
    return photo;
}

//returns the number of unread Captions in the store
- (int) numberOfUnreadCaptions {
    ResourceContext* resourceContext = [ResourceContext instance];
    NSArray* valuesArray = [NSArray arrayWithObjects:[self.objectid stringValue], [NSNumber numberWithBool:NO], nil];
    NSArray* attributesArray = [NSArray arrayWithObjects:PAGEID, HASSEEN, nil];
    
    NSArray* unreadCaptions = [resourceContext resourcesWithType:CAPTION withValuesEqual:valuesArray forAttributes:attributesArray sortBy:nil];
    
    return [unreadCaptions count];
}

//returns the number of drafts in the store
+ (int) numberOfDrafts {
    ResourceContext* resourceContext = [ResourceContext instance];
    NSArray* draftObjects = [resourceContext resourcesWithType:PAGE withValueEqual:[NSString stringWithFormat:@"%d",kDRAFT] forAttribute:STATE sortBy:nil];
    
    return [draftObjects count];
}

//static initializer
+ (Page*)createNewDraftPage{
   
    ResourceContext* resourceContext = [ResourceContext instance];
    AuthenticationManager* authenticationManager = [AuthenticationManager instance];
 
    Page* retVal = (Page*) [Resource createInstanceOfType:PAGE withResourceContext:resourceContext];
    
    if ([authenticationManager isUserAuthenticated]) {
        User* user = (User*)[resourceContext resourceWithType:USER withID:authenticationManager.m_LoggedInUserID];
        retVal.creatorid = user.objectid;
        retVal.creatorname = user.displayname;
        retVal.state = [NSNumber numberWithInt:kDRAFT];
        
        //we need to calculate the proper date for expiry
        ApplicationSettings* settings = [[ApplicationSettingsManager instance] settings];
        //we get the duration of new pages
        double currentDateInSeconds =  [DateTimeHelper convertDateToDouble:[NSDate date]];
        //add the expiry date default
        retVal.datedraftexpires =[NSNumber numberWithDouble:(currentDateInSeconds + [settings.page_draftexpiry_seconds doubleValue])];
        
    }
   
    
    return retVal;
}

@end
