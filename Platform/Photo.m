//
//  Photo.m
//  Platform
//
//  Created by Bobby Gill on 10/19/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import "Photo.h"
#import "ImageManager.h"
#import "AuthenticationManager.h"
#import "User.h"
#import "ResourceContext.h"
#import "Resource.h"
#import "DateTimeHelper.h"

@implementation Photo
@dynamic descr;
@dynamic displayname;
@dynamic imageurl;
@dynamic thumbnailurl;
@dynamic numberofviews;
@dynamic numberofvotes;
@dynamic numberofcaptions;
@dynamic creatorid;
@dynamic creatorname;
@dynamic themeid;
@dynamic latitude;
@dynamic longitude;


- (void) refreshWith:(Resource*)newResource {
    //we override this method so that we can perform custom logic when
    //attachment attributes are overwritten, so that we move the appropriate 
    //photo 
    
    if ([newResource isKindOfClass:[Photo class]]) {
        Photo* newPhoto = (Photo*)newResource;
        NSString* currImageURL = self.imageurl;
        NSString* currThumbnailURL = self.thumbnailurl;
        ImageManager* imageManager = [ImageManager instance];
        
        if (currImageURL != nil) {
            if (![currImageURL isEqualToString:newPhoto.imageurl]) {
                //the url has changed, hence we assume that we are moving from a local
                //reference to a URL reference
                NSURL* newUrlPath = [NSURL URLWithString:newPhoto.imageurl];
                [imageManager imageMovedFrom:currImageURL toDestination:newUrlPath];
            }
        }
        
        
        if (currThumbnailURL != nil) {
            if (![currThumbnailURL isEqualToString:newPhoto.thumbnailurl]) {
                NSURL* newUrlPath = [NSURL URLWithString:newPhoto.thumbnailurl];
                [imageManager imageMovedFrom:currThumbnailURL toDestination:newUrlPath];
            }
        }
        
        
    }
    [super refreshWith:newResource];
}

- (Caption*)captionWithHighestVotes {
    //returns the caption object with the highest number of votes associated with this photo
    ResourceContext* resourceContext = [ResourceContext instance];
    Caption* topCaption = (Caption*)[resourceContext resourceWithType:CAPTION withValueEqual:[self.objectid stringValue] forAttribute:PHOTOID sortBy:NUMBEROFVOTES sortAscending:NO];
    return topCaption;
    
}

#pragma mark - Static Initializers
+ (Photo*) createPhotoInPage:(NSNumber *)pageid 
          withThumbnailImage:(UIImage *)thumbnailImage 
                   withImage:(UIImage *)image {
   
    AuthenticationManager* authenticationManager = [AuthenticationManager instance];
    ImageManager* imageManager = [ImageManager instance];
    
    ResourceContext* resourceContext = [ResourceContext instance];
    
    Photo* retVal = (Photo*)[Resource createInstanceOfType:PHOTO withResourceContext:resourceContext];
    
    User* user = (User*)[resourceContext resourceWithType:USER withID:authenticationManager.m_LoggedInUserID];
    
    retVal.creatorid = user.objectid;
    retVal.creatorname = user.displayname;
    retVal.descr = [NSString stringWithFormat:@"By %@ on %@", user.displayname, [DateTimeHelper formatShortDate:[NSDate date]]];
    retVal.themeid = pageid;
    
    // Save thumbnail image
    NSString* thumbnailFileName = [NSString stringWithFormat:@"%@%@", [retVal.objectid stringValue], @"-tb"];
    
    retVal.thumbnailurl = [imageManager saveImage:thumbnailImage withFileName:thumbnailFileName];
    
    // Save fullscreen image
    NSString* fullscreenFileName = [NSString stringWithFormat:@"%@%@", [retVal.objectid stringValue], @"-fs"];
    retVal.imageurl = [imageManager saveImage:image withFileName:fullscreenFileName];
    
    
    return retVal;
    
}

@end
