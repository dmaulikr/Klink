//
//  UICaptionView.m
//  Platform
//
//  Created by Jordan Gurrieri on 11/18/11.
//  Copyright (c) 2011 Blue Label Solutions LLC. All rights reserved.
//

#import "UICaptionView.h"
#import "Caption.h"
#import "Types.h"
#import "DateTimeHelper.h"

@implementation UICaptionView
@synthesize captionID = m_captionID;
@synthesize view = m_view;
@synthesize v_background = m_v_background;
@synthesize lbl_caption = m_lbl_caption;
@synthesize lbl_metaData = m_lbl_metaData;
@synthesize lbl_numVotes = m_lbl_numVotes;
@synthesize iv_voteIcon = m_iv_voteIcon;


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        NSArray* topLevelObjs = nil;
        
        topLevelObjs = [[NSBundle mainBundle] loadNibNamed:@"UICaptionView" owner:self options:nil];
        if (topLevelObjs == nil)
        {
            NSLog(@"Error! Could not load UICaptionView file.\n");
        }
        
        [self addSubview:self.view];
        
    }
    return self;
}

//This is where the "by JordanG 2 minutes ago" string is created
- (NSString*) getMetadataStringForCaption:(Caption*)caption {
    NSDate* now = [NSDate date];
    NSTimeInterval intervalSinceCreated = [now timeIntervalSinceDate:[DateTimeHelper parseWebServiceDateDouble:caption.datecreated]];
    NSString* timeSinceCreated = nil;
    if (intervalSinceCreated < 1 ) {
        timeSinceCreated = @"a moment";
    }
    else {
        timeSinceCreated = [DateTimeHelper formatTimeInterval:intervalSinceCreated];
    }
    
    return [NSString stringWithFormat:@"By %@, %@ ago",caption.creatorname,timeSinceCreated];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void) render {
    ResourceContext* resourceContext = [ResourceContext instance];
    
    Caption* caption = (Caption*)[resourceContext resourceWithType:CAPTION withID:self.captionID];
    
    if (caption != nil) {
        self.lbl_caption.text = [NSString stringWithFormat:@"\"%@\"", caption.caption1];
        self.lbl_metaData.text = [self getMetadataStringForCaption:caption];
        self.lbl_numVotes.text = [caption.numberofvotes stringValue];
    }
    
    [self.lbl_caption setFont:[UIFont fontWithName:@"TravelingTypewriter" size:17]];
    [self.lbl_metaData setFont:[UIFont fontWithName:@"TravelingTypewriter" size:13]];
    [self.lbl_numVotes setFont:[UIFont fontWithName:@"TravelingTypewriter" size:13]];
    
    if ([caption.hasvoted boolValue]) {
        // show highlighted version of thumb icon
        self.iv_voteIcon.highlighted = YES;
    }
    else {
        self.iv_voteIcon.highlighted = NO;
    }
    
    [self setNeedsDisplay];
}

- (void) renderCaptionWithID:(NSNumber*)captionID {
    self.captionID = captionID;
    
    [self render];
}


@end
