//
//  UIProfileBar.m
//  Klink V2
//
//  Created by Bobby Gill on 7/16/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import "UIProfileBar.h"
#import "NotificationNames.h"

@implementation UIProfileBar
@synthesize lbl_rank;
@synthesize lbl_votes;
@synthesize lbl_captions;

- (id) initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
        NSArray* bundle =  [[NSBundle mainBundle] loadNibNamed:@"UIProfileBar" owner:self options:nil];
        
        UIView* profileBar = [bundle objectAtIndex:0];
        [self addSubview:profileBar];
                
        
        //register for global events
        NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
        [notificationCenter addObserver:self selector:@selector(onUserLoggedIn:) name:n_USER_LOGGED_IN object:nil];
        [notificationCenter addObserver:self selector:@selector(onUserLoggedOut:) name:n_USER_LOGGED_OUT object:nil];
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
}

#pragma mark - System Event Handlers
-(void)onUserLoggedIn:(NSNotification*)notification {
    
}

-(void)onUserLoggedOut:(NSNotification*)notification {
    
}

@end
