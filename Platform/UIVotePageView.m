//
//  UIVotePageView.m
//  Platform
//
//  Created by Jasjeet Gill on 12/12/11.
//  Copyright (c) 2011 Blue Label Solutions LLC. All rights reserved.
//

#import "UIVotePageView.h"
#import "ImageManager.h"
#import "CallbackResult.h"
#import "ImageDownloadResponse.h"
#import "Macros.h"

@implementation UIVotePageView
@synthesize  page = m_page;
@synthesize  image = m_image;
@synthesize lbl_title = m_lbl_title;
@synthesize lbl_caption = m_lbl_caption;
@synthesize photo = m_photo;
@synthesize caption = m_caption;
@synthesize enumerator = m_enumerator;
@synthesize poll = m_poll;
#define kPHOTO_HEIGHT 100
#define kPADDING    10
#define kPHOTOID    @"photoid"
#define kPOLLID     @"pollid"
#define kPAGEID     @"pageid"

- (void) renderWithPage:(NSNumber*)pageID forPoll:(NSNumber *)pollID {
    ResourceContext* resourceContext = [ResourceContext instance];
    self.page = nil;
    self.photo = nil;
    self.caption = nil;
    
    self.page = (Page*)[resourceContext resourceWithType:PAGE withID:pageID];
    self.caption = (Caption*)[resourceContext resourceWithType:CAPTION withID:self.page.finishedcaptionid];
    self.photo = (Photo*)[resourceContext resourceWithType:PHOTO withID:self.page.finishedphotoid];
    self.poll = (Poll*)[resourceContext resourceWithType:POLL withID:pollID];
    
    if (self.photo != nil && self.caption != nil) {
        //we have all the data objects we need to render the page
        
        self.lbl_title.text = self.page.displayname;
        self.lbl_caption.text = self.caption.caption1;
        
        ImageManager* imageManager = [ImageManager instance];
        NSDictionary* userInfo = [NSDictionary dictionaryWithObject:self.photo.objectid forKey:kPHOTOID];
        Callback* callback = [[Callback alloc]initWithTarget:self withSelector:@selector(onImageDownloaded:) withContext:userInfo];
        
        UIImage* img = [imageManager downloadImage:self.photo.imageurl withUserInfo:userInfo atCallback:callback];
        
        if (img != nil) {
            self.image.image = img;
        }
        
        //we need to check if the user has voted already for this poll, in this case
        //we need to visually indicate the vote status
        //TODO:put a check mark or some shit here
        
        [callback release];
    }
    else {
        //in this case we are missing the objects from the local store
        //we perform a query against the service to return those objects
        NSArray* objectIDs = [NSArray arrayWithObjects:self.page.finishedphotoid,self.page.finishedcaptionid, nil];
        NSArray* objectTypes = [NSArray arrayWithObjects:PHOTO,CAPTION, nil];
        self.enumerator = [CloudEnumerator enumeratorForIDs:objectIDs withTypes:objectTypes];
        self.enumerator.delegate = self;
        
        NSMutableDictionary* userInfo = [NSMutableDictionary dictionaryWithObject:self.page.objectid forKey:kPAGEID];
        [userInfo setValue:self.poll.objectid forKey:kPOLLID];
        [self.enumerator enumerateUntilEnd:userInfo];
        
    }
    
}
- (id)initWithFrame:(CGRect)frame withPhotoID:(NSNumber *)pageID forPoll:(NSNumber*)pollID
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        CGRect frameForTitle = CGRectMake(0,0, self.frame.size.width-kPADDING,20);
        UILabel* l = [[UILabel alloc]initWithFrame:frameForTitle];
        self.lbl_title = l;
        [l release];
        
        CGRect frameForPicture = CGRectMake(0, 30, self.frame.size.width-kPADDING, kPHOTO_HEIGHT);
        UIImageView* iv = [[UIImageView alloc]initWithFrame:frameForPicture];
        self.image = iv;
        [iv release];
        
        CGRect frameForCaption = CGRectMake(0, kPHOTO_HEIGHT+40, self.frame.size.width-kPADDING, 20);
        UILabel* c = [[UILabel alloc]initWithFrame:frameForCaption];
        self.lbl_caption = c;
        [c release];
        
        [self addSubview:self.lbl_title];
        [self addSubview:self.image];
        [self addSubview:self.lbl_caption];
        

        [self renderWithPage:pageID forPoll:pollID];

    }
    return self;
}

- (void) onImageDownloaded:(CallbackResult*)result {
    NSDictionary* context = result.context;
    NSNumber* photoID = [context valueForKey:kPHOTOID];
    
    if ([photoID isEqualToNumber:self.photo.objectid]) {
        ImageDownloadResponse* response = (ImageDownloadResponse*)result.response;
        self.image.image = response.image;
    }
}

#pragma mark - CloudEnumeratorDelegate
- (void) onEnumerateComplete:(NSDictionary *)userInfo {
    NSString* activityName = @"UIVotePageView.onEnumerateComplete:";
    //when we return we should have all the objects we need, so let us render again
    
    //we check to make sure we dont overwrite anything, by first verifying that the
    //page does not have a photo or caption set
    NSNumber* pageID = [userInfo valueForKey:kPAGEID];
    NSNumber* pollID = [userInfo valueForKey:kPOLLID];
    if (pageID != nil && pollID != nil && self.page != nil) {
        if ([pageID isEqualToNumber:self.page.objectid]) {
            //view has not been repurposed, re-evaluating caption and photo results
            LOG_UIVOTEPAGEVIEW(0, @"%@Photo and Caption completed downloading, re-executing render",activityName);
            [self renderWithPage:pageID forPoll:pollID];
        }
    }
    else {
        LOG_UIVOTEPAGEVIEW(1,@"%@Photo/Caption enumeration returned however userInfo does not contain Page reference",activityName);
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
