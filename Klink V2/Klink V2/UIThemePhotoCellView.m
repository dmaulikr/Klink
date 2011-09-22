//
//  UIThemePhotoCellView.m
//  Klink V2
//
//  Created by Bobby Gill on 9/21/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import "UIThemePhotoCellView.h"

#define kCaptionHeight 40
#define kCaptionPadding 10

@implementation UIThemePhotoCellView
@synthesize isHorizontalOrientation = m_isHorizontalOrientation;
@synthesize padding = m_padding;
@synthesize caption = m_caption;
@synthesize photo = m_photo;
@synthesize image = m_image;
@synthesize captionBackground = m_captionBackground;

- (id)initWithFrame:(CGRect)frame withPhoto:(Photo *)photo withCaption:(Caption *)caption withPadding:(int)padding
{
    self = [super initWithFrame:frame];
    if (self) {
        self.opaque = YES;
        self.backgroundColor = [UIColor whiteColor];
        self.photo = photo;
        self.caption = caption;
        //self.image = [[ImageManager getInstance] downloadImage:self.photo.thumbnailurl withUserInfo:nil atCallback:self];
        
        //initialize the caption background object
        CGRect frameForCaptionBackground = CGRectMake(self.padding, self.bounds.size.height-kCaptionHeight, self.bounds.size.width-(2*self.padding), kCaptionHeight);
        self.captionBackground = [[UIView alloc]initWithFrame:frameForCaptionBackground];

    }
    return self;
}

- (void) setPhoto:(Photo *)newPhoto withCaption:(Caption *)newCaption {
    self.photo = newPhoto;
    self.caption = newCaption;
    self.image = nil;
    //self.image = [[ImageManager getInstance] downloadImage:self.photo.imageurl withUserInfo:nil atCallback:self];
    [self setNeedsDisplay];
}

- (void) drawImage:(CGPoint)center {
    
    
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    //we need to draw a rectangle
    //draw the image
    if (self.photo != nil) {
        UIFont  *textFont = [UIFont fontWithName:font_CAPTION size:fontsize_CAPTION];
        
        CGRect contentRect = self.bounds;
        CGFloat boundsX = contentRect.origin.x;
        CGPoint point;
        
//        if (self.caption != nil) {
//            //initialize the caption background object
//            CGRect frameForCaptionBackground = CGRectMake(self.padding, self.bounds.size.height-kCaptionHeight, self.bounds.size.width-(2*self.padding), kCaptionHeight);
//            self.captionBackground.frame = frameForCaptionBackground;
//            
//            //draw the caption background
//            self.captionBackground.backgroundColor = [UIColor blackColor];
//            self.captionBackground.alpha = 0.5;
//            self.captionBackground.opaque = YES;
//            [self.captionBackground drawRect:self.captionBackground.bounds];
//            
//            //draw the caption text
//            int captionWidth = self.bounds.size.width - (2*self.padding) - (2*kCaptionPadding);
//            CGPoint captionOrigin = CGPointMake(self.padding+kCaptionPadding, self.bounds.size.height-kCaptionHeight+kCaptionPadding);
//            
//            
//            NSString* captionText = self.caption.caption1;
//            [captionText drawAtPoint:captionOrigin forWidth:captionWidth withFont:textFont fontSize:fontsize_CAPTION lineBreakMode:UILineBreakModeCharacterWrap baselineAdjustment:UIBaselineAdjustmentNone];
//        }
        
        NSDictionary* userInfo = [NSDictionary dictionaryWithObject:self.photo.objectid forKey:an_PHOTOID];
        
        if (self.image == nil) {
            self.image = [[ImageManager getInstance] downloadImage:self.photo.thumbnailurl withUserInfo:userInfo atCallback:self];
        }
        CGFloat imageY = self.padding;
        point = CGPointMake(boundsX,imageY);
        CGRect imageRect = CGRectMake(boundsX, imageY, self.bounds.size.width, self.bounds.size.height);
        [self.image drawInRect:imageRect];
    }
    
}


#pragma mark - ImageDownloadCallback handler
-(void)onImageDownload:(UIImage*)image withUserInfo:(NSDictionary*)userInfo {
    //need to draw the image
    if ([[userInfo objectForKey:an_PHOTOID]isEqualToNumber:self.photo.objectid]) {
        CGFloat imageY = self.padding;
        CGRect contentRect = self.bounds;
        CGFloat boundsX = contentRect.origin.x;
        CGPoint point = CGPointMake(boundsX,imageY);
        self.image = image;
        [self setNeedsDisplay];
    }
}


- (void)dealloc
{
    [super dealloc];
}

@end
