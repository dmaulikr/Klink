//
//  UILeaderboard3Up.m
//  Platform
//
//  Created by Jordan Gurrieri on 4/19/12.
//  Copyright (c) 2012 Blue Label Solutions LLC. All rights reserved.
//

#import "UILeaderboard3Up.h"
#import <QuartzCore/QuartzCore.h>
#import "LeaderboardEntry.h"
#import "AuthenticationManager.h"
#import "ImageManager.h"
#import "Callback.h"
#import "CallbackResult.h"
@implementation UILeaderboard3Up

@synthesize view    = m_view;

@synthesize lbl_position1   = m_lbl_position1;
@synthesize lbl_position2   = m_lbl_position2;
@synthesize lbl_position3   = m_lbl_position3;

@synthesize iv_profilePic1  = m_iv_profilePic1;
@synthesize iv_profilePic2  = m_iv_profilePic2;
@synthesize iv_profilePic3  = m_iv_profilePic3;

@synthesize lbl_username1   = m_lbl_username1;
@synthesize lbl_username2   = m_lbl_username2;
@synthesize lbl_username3   = m_lbl_username3;

@synthesize lbl_numPoints1  = m_lbl_numPoints1;
@synthesize lbl_numPoints2  = m_lbl_numPoints2;
@synthesize lbl_numPoints3  = m_lbl_numPoints3;

@synthesize iv_container    = m_iv_container;
@synthesize v_userHighlight = m_v_userHighlight;
@synthesize iv_arrow        = m_iv_arrow;

@synthesize entries         = m_entries;
@synthesize leaderboardID   = m_leaderboardID;
@synthesize userID          = m_userID;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        NSArray* topLevelObjs = nil;
        
        topLevelObjs = [[NSBundle mainBundle] loadNibNamed:@"UILeaderboard3Up" owner:self options:nil];
        if (topLevelObjs == nil)
        {
            NSLog(@"Error! Could not load UILeaderboard3Up file.\n");
        }
        
        self.v_userHighlight.layer.cornerRadius = 5;
        
        [self addSubview:self.view];
        
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
    self.lbl_position1 = nil;
    self.lbl_position2 = nil;
    self.lbl_position3 = nil;
    
    self.iv_profilePic1 = nil;
    self.iv_profilePic2 = nil;
    self.iv_profilePic3 = nil;
    
    self.lbl_username1 = nil;
    self.lbl_username2 = nil;
    self.lbl_username3 = nil;
    
    self.lbl_numPoints1 = nil;
    self.lbl_numPoints2 = nil;
    self.lbl_numPoints3 = nil;
    
    self.iv_container = nil;
    self.v_userHighlight = nil;
    self.iv_arrow = nil;
    
    self.entries = nil;
    
    [super dealloc];
    
}

#define kIMAGEVIEW  @"ImageView"

- (void) render {    
    LeaderboardEntry* entry;
    ImageManager* imageManager = [ImageManager instance];
    int count = [self.entries count];
    if (count > 0) 
    {
        entry = [self.entries objectAtIndex:0];
        if (entry != nil) {
            self.lbl_position1.text = [NSString stringWithFormat:@"# %@", [entry.position stringValue]];
            //self.iv_profilePic1
            self.lbl_username1.text = entry.username;
            self.lbl_numPoints1.text = [entry.points stringValue];
            
            //image handling code
            Callback* imageCallback = [Callback callbackForTarget:self selector:@selector(onImageDownloadComplete:) fireOnMainThread:YES];
            NSMutableDictionary* payload = [NSMutableDictionary dictionaryWithObject:self.iv_profilePic1 forKey:kIMAGEVIEW];
            [payload setValue:entry.imageurl forKey:IMAGEURL];
            imageCallback.context = payload;
            UIImage* image = [imageManager downloadImage:entry.imageurl withUserInfo:nil atCallback:imageCallback];
            
            if (image != nil) {
                self.iv_profilePic1.image = image;
            }
        }
        
        if (count > 1) 
        {
            entry = [self.entries objectAtIndex:1];
            if (entry != nil) 
            {
                self.lbl_position2.hidden = NO;
                self.lbl_username2.hidden = NO;
                self.lbl_numPoints2.hidden = NO;
                self.iv_profilePic2.hidden = NO;
                self.lbl_position2.text = [NSString stringWithFormat:@"# %@", [entry.position stringValue]];
                //self.iv_profilePic2
                self.lbl_username2.text = entry.username;
                self.lbl_numPoints2.text = [entry.points stringValue];
                
                //image handling code
                Callback* imageCallback = [Callback callbackForTarget:self selector:@selector(onImageDownloadComplete:) fireOnMainThread:YES];
                NSMutableDictionary* payload = [NSMutableDictionary dictionaryWithObject:self.iv_profilePic2 forKey:kIMAGEVIEW];
                [payload setValue:entry.imageurl forKey:IMAGEURL];
                imageCallback.context = payload;
                UIImage* image = [imageManager downloadImage:entry.imageurl withUserInfo:nil atCallback:imageCallback];
                
                if (image != nil) {
                    self.iv_profilePic2.image = image;
                }

            }
            
            if (count > 2)
            {
                entry = [self.entries objectAtIndex:2];
                if (entry != nil) 
                {
                    self.lbl_position3.hidden = NO;
                    self.lbl_username3.hidden = NO;
                    self.lbl_numPoints3.hidden = NO;
                    self.iv_profilePic3.hidden = NO;
                    
                    self.lbl_position3.text = [NSString stringWithFormat:@"# %@", [entry.position stringValue]];
                    
                    self.lbl_username3.text = entry.username;
                    self.lbl_numPoints3.text = [entry.points stringValue];
                    
                    //image handling code
                    Callback* imageCallback = [Callback callbackForTarget:self selector:@selector(onImageDownloadComplete:) fireOnMainThread:YES];
                    NSMutableDictionary* payload = [NSMutableDictionary dictionaryWithObject:self.iv_profilePic3 forKey:kIMAGEVIEW];
                    [payload setValue:entry.imageurl forKey:IMAGEURL];
                    imageCallback.context = payload;
                    UIImage* image = [imageManager downloadImage:entry.imageurl withUserInfo:nil atCallback:imageCallback];
                    
                    if (image != nil) {
                        self.iv_profilePic3.image = image;
                    }

                }
                
                self.iv_container.frame = CGRectMake(0, 0, 280, 109);
                self.view.frame = CGRectMake(0, 0, 280, 105);
            }
            else
            {
                //only two entries
                self.lbl_position3.hidden = YES;
                self.lbl_username3.hidden = YES;
                self.lbl_numPoints3.hidden = YES;
                self.iv_profilePic3.hidden = YES;
                
                self.iv_container.frame = CGRectMake(0, 0, 280, 77);
                self.view.frame = CGRectMake(0, 0, 280, 73);
            }
        }
        else {
            //only one entry
            self.lbl_position2.hidden = YES;
            self.lbl_username2.hidden = YES;
            self.lbl_numPoints2.hidden = YES;
            self.iv_profilePic2.hidden = YES;
            
            self.lbl_position3.hidden = YES;
            self.lbl_username3.hidden = YES;
            self.lbl_numPoints3.hidden = YES;
            self.iv_profilePic3.hidden = YES;
            
            self.iv_container.frame = CGRectMake(0, 0, 280, 44);
            self.view.frame = CGRectMake(0, 0, 280, 40);
            
        }
        
        if (count > 1) {
            // We need to move the userHighlight view to the appropriate spot
            LeaderboardEntry *entry;
            
            for (int i = 0; i < self.entries.count; i++) {
                
                entry = [self.entries objectAtIndex:i];
                
                // We search for the index of the user in user's entry, then set the appropriate highlights
                if ([entry.userid isEqualToNumber:self.userID]) {
                    CGRect frame;
                    
                    if (i == 0) {
                        frame = CGRectMake(3, 4, 274, 34);
                        
                        // Set text font color to white
                        self.lbl_position1.textColor = [UIColor whiteColor];
                        self.lbl_username1.textColor = [UIColor whiteColor];
                        self.lbl_numPoints1.textColor = [UIColor whiteColor];
                        
                        // Set text shadow of labels
                        [self.lbl_position1 setShadowColor:[UIColor blackColor]];
                        [self.lbl_username1 setShadowColor:[UIColor blackColor]];
                        [self.lbl_numPoints1 setShadowColor:[UIColor blackColor]];
                        [self.lbl_position1 setShadowOffset:CGSizeMake(0.0, -1.0)];
                        [self.lbl_username1 setShadowOffset:CGSizeMake(0.0, -1.0)];
                        [self.lbl_numPoints1 setShadowOffset:CGSizeMake(0.0, -1.0)];
                    }
                    else if (i == 1) {
                        frame = CGRectMake(3, 38, 274, 34);
                        
                        // Set text font color to white
                        self.lbl_position2.textColor = [UIColor whiteColor];
                        self.lbl_username2.textColor = [UIColor whiteColor];
                        self.lbl_numPoints2.textColor = [UIColor whiteColor];
                        
                        // Set text shadow of labels
                        [self.lbl_position2 setShadowColor:[UIColor blackColor]];
                        [self.lbl_username2 setShadowColor:[UIColor blackColor]];
                        [self.lbl_numPoints2 setShadowColor:[UIColor blackColor]];
                        [self.lbl_position2 setShadowOffset:CGSizeMake(0.0, -1.0)];
                        [self.lbl_username2 setShadowOffset:CGSizeMake(0.0, -1.0)];
                        [self.lbl_numPoints2 setShadowOffset:CGSizeMake(0.0, -1.0)];
                    }
                    else {
                        frame = CGRectMake(3, 71, 274, 34);
                        
                        // Set text font color to white
                        self.lbl_position3.textColor = [UIColor whiteColor];
                        self.lbl_username3.textColor = [UIColor whiteColor];
                        self.lbl_numPoints3.textColor = [UIColor whiteColor];
                        
                        // Set text shadow of labels
                        [self.lbl_position3 setShadowColor:[UIColor blackColor]];
                        [self.lbl_username3 setShadowColor:[UIColor blackColor]];
                        [self.lbl_numPoints3 setShadowColor:[UIColor blackColor]];
                        [self.lbl_position3 setShadowOffset:CGSizeMake(0.0, -1.0)];
                        [self.lbl_username3 setShadowOffset:CGSizeMake(0.0, -1.0)];
                        [self.lbl_numPoints3 setShadowOffset:CGSizeMake(0.0, -1.0)];
                    }
                    
                    self.v_userHighlight.frame = frame;
                    
                    break;
                }
            }
        }
        else {
            self.v_userHighlight.hidden = YES;
            
            CGRect frame = CGRectMake(self.iv_arrow.frame.origin.x, 8, self.iv_arrow.frame.size.width, self.iv_arrow.frame.size.height);
            self.iv_arrow.frame = frame;
        }
        
        [self setNeedsDisplay];
    }
}

- (void) renderLeaderboardWithEntries:(NSArray*)entries forLeaderboard:(NSNumber *)leaderboardID forUserWithID:(NSNumber *)userID
{
    self.entries = entries;
    self.leaderboardID = leaderboardID;
    self.userID = userID;
    
    [self render];
}

                              
#pragma mark - Image downlopad methods
- (void) onImageDownloadComplete: (CallbackResult*)result
{
    NSDictionary* context = result.context;
    UIImageView* imageView = [context valueForKey:kIMAGEVIEW];
    NSString* imageURL = [context valueForKey:IMAGEURL];
    ImageManager* imageManager = [ImageManager instance];
    UIImage* image = [imageManager downloadImage:imageURL withUserInfo:nil atCallback:nil];
    imageView.image = image;
    
}
@end
