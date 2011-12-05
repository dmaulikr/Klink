//
//  UIPhotoMetaDataView.m
//  Platform
//
//  Created by Jordan Gurrieri on 12/4/11.
//  Copyright (c) 2011 Blue Label Solutions LLC. All rights reserved.
//

#import "UIPhotoMetaDataView.h"
#import "Photo.h"
#import "DateTimeHelper.h"

@implementation UIPhotoMetaDataView
@synthesize photoID = m_photoID;
@synthesize view = m_view;
@synthesize v_background = m_v_background;
@synthesize lbl_metaData = m_lbl_metaData;
@synthesize lbl_numVotes = m_lbl_numVotes;


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        NSArray* topLevelObjs = nil;
        
        topLevelObjs = [[NSBundle mainBundle] loadNibNamed:@"UIPhotoMetaDataView" owner:self options:nil];
        if (topLevelObjs == nil)
        {
            NSLog(@"Error! Could not load UIPhotoMetaDataView file.\n");
        }
        
        [self addSubview:self.view];
    }
    return self;
}


//This is where the "by JordanG 2 minutes ago" string is created
- (NSString*) getMetadataStringForPhoto:(Photo*)photo {
    NSDate* now = [NSDate date];
    NSTimeInterval intervalSinceCreated = [now timeIntervalSinceDate:[DateTimeHelper parseWebServiceDateDouble:photo.datecreated]];
    NSString* timeSinceCreated = [[NSString alloc] init];
    if (intervalSinceCreated < 1 ) {
        timeSinceCreated = @"a moment";
    }
    else {
        timeSinceCreated = [DateTimeHelper formatTimeInterval:intervalSinceCreated];
    }
    
    return [NSString stringWithFormat:@"By %@, %@ ago",photo.creatorname,timeSinceCreated];
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
    
    Photo* photo = (Photo*)[resourceContext resourceWithType:PHOTO withID:self.photoID];
    
    if (photo != nil) {
        self.lbl_metaData.text = [self getMetadataStringForPhoto:photo];
        self.lbl_numVotes.text = [photo.numberofvotes stringValue];
    }
    [self setNeedsDisplay];
}

- (void) renderMetaDataWithID:(NSNumber*)photoID {
    self.photoID = photoID;
    
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

@end
