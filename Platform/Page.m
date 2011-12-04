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

#pragma mark - Instance Methods
- (NSArray*) hashtagList {
    NSArray* retVal = [self.hashtags componentsSeparatedByString:kDELIMETER];
    return retVal;
}

- (Caption*)captionWithHighestVotes {
    //returns the caption objecyt associated with the photo for this page with the highest number of votes
    ResourceContext* resourceContext = [ResourceContext instance];
    Photo* topPhoto = [self photoWithHighestVotes];
    Caption* topCaption = (Caption*)[resourceContext resourceWithType:CAPTION withValueEqual:[topPhoto.objectid stringValue] forAttribute:PHOTOID sortBy:NUMBEROFVOTES sortAscending:NO];
    return topCaption;

}

-(Photo*)photoWithHighestVotes {
    ResourceContext* resourceContext = [ResourceContext instance];
    Photo* photo = (Photo*)[resourceContext resourceWithType:PHOTO withValueEqual:[self.objectid stringValue] forAttribute:THEMEID sortBy:NUMBEROFVOTES sortAscending:NO];
    return photo;
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
