//
//  UIResourceLinkButton.m
//  Platform
//
//  Created by Jasjeet Gill on 12/31/11.
//  Copyright (c) 2011 Blue Label Solutions LLC. All rights reserved.
//

#import "UIResourceLinkButton.h"

@implementation UIResourceLinkButton
@synthesize resourceLinkButton = m_resourceLinkButton;
@synthesize objectID = m_objectID;
@synthesize objectName = m_objectName;

- (id) init {
    self = [super init];
    if (self) {
//        [self addTarget:self action:@selector(onClick:) forControlEvents:UIControlEventTouchUpInside];
//        // Initialization code
//        NSArray* topLevelObjs = nil;
//        
//        topLevelObjs = [[NSBundle mainBundle] loadNibNamed:@"UIResourceLinkButton" owner:self options:nil];
//        if (topLevelObjs == nil)
//        {
//            NSLog(@"Error! Could not load UIResourceLinkButton file.\n");
//        }
//        [self setAutoresizingMask:2];
//        [self addSubview:self.resourceLinkButton];
    }
    return self;
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
//        [self addTarget:self action:@selector(onClick:) forControlEvents:UIControlEventTouchUpInside];
        // Initialization code
//        NSArray* topLevelObjs = nil;
//        
//        topLevelObjs = [[NSBundle mainBundle] loadNibNamed:@"UIResourceLinkButton" owner:self options:nil];
//        if (topLevelObjs == nil)
//        {
//            NSLog(@"Error! Could not load UIResourceLinkButton file.\n");
//        }
//        [self setAutoresizingMask:2];
//
//        [self addSubview:self.resourceLinkButton];
    }
    return self;
}

- (void) onClick:(id)sender 
{
    //when this is clicked we need to launch the ProfileView
}

- (void) render {
    [self setTitle:self.objectName forState:UIControlStateNormal];
}

- (void) renderWithObjectID:(NSNumber*)objectID withName:(NSString*)name {
    self.objectID = objectID;
    self.objectName = name;
    [self render];
}
@end
