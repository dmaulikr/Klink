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

@synthesize entries         = m_entries;
@synthesize leaderboardID   = m_leaderboardID;

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
    
    self.entries = nil;
    
    [super dealloc];
    
}

- (void) render {    
    LeaderboardEntry* entry;
    int count = [self.entries count];
    if (count > 0) 
    {
        entry = [self.entries objectAtIndex:0];
        if (entry != nil) {
            self.lbl_position1.text = [NSString stringWithFormat:@"# %@", [entry.position stringValue]];
            //self.iv_profilePic1
            self.lbl_username1.text = entry.username;
            self.lbl_numPoints1.text = [entry.points stringValue];
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
                }
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
            self.iv_profilePic2.hidden = YES;
            
            self.iv_container.frame = CGRectMake(0, 0, 280, 40);
            self.view.frame = CGRectMake(0, 0, 280, 37);
            
        }
        
        // We need to move the userHighlight view to the appropriate spot
        LeaderboardEntry *entry;
        AuthenticationManager* authenticationManager = [AuthenticationManager instance];
        for (int i = 0; i < self.entries.count; i++) {
            
            entry = [self.entries objectAtIndex:i];
            
            // We search for the index of the logged in user's entry, then take the entry before and after that index
            if ([entry.userid isEqualToNumber:authenticationManager.m_LoggedInUserID]) {
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
        
        [self setNeedsDisplay];
    }
}

- (void) renderLeaderboardWithEntries:(NSArray*)entries forLeaderboard:(NSNumber *)leaderboardID 
{
    self.entries = entries;
    self.leaderboardID = leaderboardID;
    
    [self render];
}

@end
