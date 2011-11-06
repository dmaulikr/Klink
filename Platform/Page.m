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
@dynamic numberofpublishvotes;
@dynamic finishedcaptionid;

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




@end
