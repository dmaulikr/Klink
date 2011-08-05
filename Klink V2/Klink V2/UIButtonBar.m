//
//  UIButtonBar.m
//  Klink V2
//
//  Created by Bobby Gill on 8/5/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import "UIButtonBar.h"
#import "Photo.h"
#import "Caption.h"
#import "TypeNames.h"
#import "AttributeNames.h"
@implementation UIButtonBar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
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

- (void) onNavigateTo:(NSNumber*)photoid withCaption:(NSNumber*)captionid {
    Photo* photo = [DataLayer getObjectByType:PHOTO withId:photoid];
    Caption* caption = [DataLayer getObjectByType:CAPTION withId:captionid];
    
    
}

@end
