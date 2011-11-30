//
//  UIPageView.m
//  Platform
//
//  Created by Bobby Gill on 10/29/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import "UIPageView.h"
#import "Page.h"
#import "Photo.h"
#import "Caption.h"
#import "ImageManager.h"
#import "CallbackResult.h"
#import "ImageDownloadResponse.h"
#import "Macros.h"

#define kPAGEID     @"pageid"
@implementation UIPageView
@synthesize lbl_caption;
@synthesize lbl_title;
@synthesize lbl_captionby;
@synthesize lbl_photoby;
@synthesize img_photo;
@synthesize pageID;

- (CGRect) frameForImage {
    return CGRectMake(37, 90, 236, 158);
}
- (CGRect)frameforCaption {
    return CGRectMake(37, 263, 236, 21);
}
- (CGRect) frameForCaptionBy {
    return CGRectMake(37, 321, 236, 21);
}
- (CGRect)frameForPhotoBy {
    return CGRectMake(37, 92, 236, 21);
}
- (CGRect)frameForTitle {
    return CGRectMake(37, 30, 236, 21);
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        CGRect titleFrame = [self frameForTitle];
        CGRect photobyFrame = [self frameForPhotoBy];
        CGRect captionbyFrame = [self frameForCaptionBy];
        CGRect captionFrame = [self frameforCaption];
        CGRect imageFrame = [self frameForImage];
        
        self.lbl_title = [[UILabel alloc]initWithFrame:titleFrame];
        self.lbl_title.text = @"title";
        
        self.lbl_photoby = [[UILabel alloc]initWithFrame:photobyFrame];
        self.lbl_photoby.text = @"title";
        
        self.lbl_captionby = [[UILabel alloc]initWithFrame:captionbyFrame];
        self.lbl_captionby.text = @"captionby";
        
        self.lbl_caption = [[UILabel alloc]initWithFrame:captionFrame];
        self.lbl_caption.text = @"caption";
        
        self.img_photo = [[UIImageView alloc]initWithFrame:imageFrame];
        [self addSubview:self.lbl_caption];
        [self addSubview:self.lbl_captionby];
        [self addSubview:self.lbl_photoby];
        [self addSubview:self.lbl_title];
        [self addSubview:self.img_photo];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)dealloc
{
    [super dealloc];
    [self.lbl_title release];
    [self.lbl_photoby release];
    [self.lbl_captionby release];
    [self.lbl_caption release];
    [self.img_photo release];
}

#pragma mark - Instance Methods
- (void) renderPageWithID:(NSNumber *)pid {
    ResourceContext* resourceContext = [ResourceContext instance];
    Page* page = (Page*)[resourceContext resourceWithType:PAGE withID:pid];
    
    if (page != nil) {
        Photo* photo = [page photoWithHighestVotes];
        Caption* caption = [page captionWithHighestVotes];
        
        self.pageID = page.objectid;
        self.lbl_title.text = page.displayname;
        self.lbl_photoby.text = photo.creatorname;
        self.lbl_caption.text = caption.caption1;
        
        ImageManager* imageManager = [ImageManager instance];
        NSDictionary* userInfo = [NSDictionary dictionaryWithObject:page.objectid forKey:kPAGEID];
        
        if (photo.imageurl != nil &&
            ![photo.imageurl isEqualToString:@""]) {
            Callback* callback = [[Callback alloc]initWithTarget:self withSelector:@selector(onImageDownloadComplete:) withContext:userInfo];
            UIImage* image = [imageManager downloadImage:photo.imageurl withUserInfo:nil atCallback:callback];
            
            if (image != nil) {
                self.img_photo.image = image;
            }
        }
        
    }
}


#pragma mark - Async Callback handlers
- (void) onImageDownloadComplete:(CallbackResult*)result {
    NSString* activityName = @"UIPageView.onImageDownloadComplete:";
    NSDictionary* userInfo = result.context;
    NSNumber* pid = [userInfo valueForKey:kPAGEID];
    ImageDownloadResponse* response = (ImageDownloadResponse*)result.response;
    
    if ([response.didSucceed boolValue] == YES) {
        if ([pid isEqualToNumber:self.pageID]) {
            //we only draw the image if this view hasnt been repurposed for another Page
            LOG_IMAGE(1,@"%@settings UIImage object equal to downloaded response",activityName);
           
            [self.img_photo performSelectorOnMainThread:@selector(setImage:) withObject:response.image waitUntilDone:NO];
//            self.img_photo.image = (UIImage*)response.image;
            [self setNeedsDisplay];
        }
    }
    else {
        self.img_photo.backgroundColor = [UIColor blackColor];
        LOG_IMAGE(1,@"%@Image failed to download",activityName);
    }
    
}

@end
