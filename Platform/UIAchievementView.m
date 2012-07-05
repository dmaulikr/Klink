//
//  UIMallardView.m
//  Platform
//
//  Created by Jordan Gurrieri on 6/11/12.
//  Copyright (c) 2012 Blue Label Solutions LLC. All rights reserved.
//

#import "UIAchievementView.h"
#import <QuartzCore/QuartzCore.h>
#import "Achievement.h"
#import "ImageManager.h"
#import "ImageDownloadResponse.h"
#import "CallbackResult.h"

#define kIMAGEVIEW @"imageview"

@implementation UIAchievementView
@synthesize achievementID   = m_achievementID;
@synthesize view            = m_view;
@synthesize v_background    = m_v_background;
@synthesize iv_achievement  = m_iv_achievement;
@synthesize lbl_title       = m_lbl_title;
@synthesize lbl_description = m_lbl_description;
@synthesize btn_close       = m_btn_close;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        NSArray* topLevelObjs = nil;
        topLevelObjs = [[NSBundle mainBundle] loadNibNamed:@"UIAchievementView" owner:self options:nil];
        
        if (topLevelObjs == nil) {
            NSLog(@"Error, could not load UIAchievementView");
        }
        
        [self addSubview:self.view];
        
        // Add rounded corners to the view background
        self.v_background.layer.cornerRadius = 8;
        
    }
    return self;
}

- (void)dealloc
{
    self.view = nil;
    self.iv_achievement = nil;
    self.lbl_title = nil;
    self.lbl_description = nil;
    self.btn_close = nil;
    
    [super dealloc];
}

- (void) render {
    ResourceContext* resourceContext = [ResourceContext instance];
    Achievement* achievement = (Achievement *)[resourceContext resourceWithType:ACHIEVEMENT withID:self.achievementID];
    
    if (achievement != nil) {
        // Get and set the achievment image
        ImageManager* imageManager = [ImageManager instance];
        NSMutableDictionary* userInfo = [[NSMutableDictionary alloc]init];
        [userInfo setValue:achievement.objectid forKey:OBJECTID]; 
        [userInfo setValue:self.iv_achievement forKey:kIMAGEVIEW]; 
        Callback* imageCallback = [Callback callbackForTarget:self selector:@selector(onAchievementImageDownloaded:) fireOnMainThread:YES];
        imageCallback.context = userInfo;
        
        UIImage* image = [imageManager downloadImage:achievement.imageurl withUserInfo:nil atCallback:imageCallback];
        
        if (image != nil) 
        {
            //we found the image in the local cache
            self.iv_achievement.image = image;
        }
        else {
            // show the placeholder image
            self.iv_achievement.image = [UIImage imageNamed:@"mallard-original-disabled.png"];
        }
        
        self.lbl_title.text = achievement.title;
        self.lbl_description.text = achievement.descr;
        
        [userInfo release];
    }
    
    [self setNeedsDisplay];
}

- (void) renderAchievementsWithID:(NSNumber*)achievementID {
    // Reset properties
    self.achievementID = nil;
    self.iv_achievement.image = [UIImage imageNamed:@"mallard-original-disabled.png"];
    self.lbl_title.text = nil;
    self.lbl_description.text = nil;
    
    self.achievementID = achievementID;
    [self render];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (IBAction) onCloseButtonPressed:(id)sender {
    // Animate the hiding of the view
    [UIView animateWithDuration:0.3
                     animations:^{self.alpha = 0.0;}
                     completion:^(BOOL finished){[self removeFromSuperview];}];
    
}

#pragma mark - ImageManager call back
- (void) onAchievementImageDownloaded:(CallbackResult*)callbackResult
{
    //the image for the achievement has been downloaded
    NSDictionary* userInfo = callbackResult.context;
    NSNumber* objectID = [userInfo valueForKey:OBJECTID];
    UIImageView* iv_achievement = (UIImageView *)[userInfo valueForKey:kIMAGEVIEW];
    
    ResourceContext* resourceContext = [ResourceContext instance];
    
    if (objectID != nil) {
        Achievement* achievementObject = (Achievement*)[resourceContext resourceWithType:ACHIEVEMENT withID:objectID];
        if (achievementObject != nil)
        {
            ImageManager* imageManager = [ImageManager instance];
            UIImage* image = [imageManager downloadImage:achievementObject.imageurl withUserInfo:nil atCallback:nil];
            iv_achievement.image = image;
            
            [self.view setNeedsDisplay];
        }
    }
}

@end
