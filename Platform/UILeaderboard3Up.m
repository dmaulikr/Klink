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

@synthesize entries         = m_entries;

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
        
        //[self.view.layer setCornerRadius:10];
        //[self.view.layer setBorderWidth:1.0];
        //[self.view.layer setBorderColor:[[UIColor blackColor]CGColor]];
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
    [self.lbl_position1 dealloc];
    [self.lbl_position2 dealloc];
    [self.lbl_position3 dealloc];
    
    [self.iv_profilePic1 dealloc];
    [self.iv_profilePic2 dealloc];
    [self.iv_profilePic3 dealloc];
    
    [self.lbl_username1 dealloc];
    [self.lbl_username2 dealloc];
    [self.lbl_username3 dealloc];
    
    [self.lbl_numPoints1 dealloc];
    [self.lbl_numPoints2 dealloc];
    [self.lbl_numPoints3 dealloc];
    
    self.entries = nil;
    [self.entries dealloc];
    
    [super dealloc];
    
}

- (void) render {    
    LeaderboardEntry* entry;
    
    entry = [self.entries objectAtIndex:0];
    if (entry != nil) {
        self.lbl_position1.text = [entry.position stringValue];
        //self.iv_profilePic1
        self.lbl_username1.text = entry.username;
        self.lbl_numPoints1.text = [entry.points stringValue];
    }
    
    entry = [self.entries objectAtIndex:1];
    if (entry != nil) {
        self.lbl_position2.text = [entry.position stringValue];
        //self.iv_profilePic2
        self.lbl_username2.text = entry.username;
        self.lbl_numPoints2.text = [entry.points stringValue];
    }
    
    entry = [self.entries objectAtIndex:2];
    if (entry != nil) {
        self.lbl_position3.text = [entry.position stringValue];
        //self.iv_profilePic3
        self.lbl_username3.text = entry.username;
        self.lbl_numPoints3.text = [entry.points stringValue];
    }
    
    [self setNeedsDisplay];
}

- (void) renderLeaderboardWithEntries:(NSArray*)entries {
    //self.entries = entries;
    
    //[self render];
}

@end
