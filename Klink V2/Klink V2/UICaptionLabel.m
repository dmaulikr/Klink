//
//  UICaptionLabel.m
//  Klink V2
//
//  Created by Bobby Gill on 8/6/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import "UICaptionLabel.h"

#define kBackgroundWidth_landscape 480
#define kBackgroundWidth 320
#define kBackgroundHeight 70

#define kCaptionLabelWidth_landscape 480
#define kCaptionLabelWidth 320
#define kCaptionHeight 40

#define kMetadataLabelWidth_landscape 480
#define kMetadataLabelWidth 320
#define kMetadataHeight 30

#define kPadding 5


@implementation UICaptionLabel
@synthesize tv_caption;
@synthesize tv_metadata;

#pragma mark - Frames
- (CGRect) frameForBackground {
    UIDeviceOrientation orientation = [[UIDevice currentDevice]orientation];
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        return CGRectMake(0, 0, kBackgroundWidth_landscape, kBackgroundHeight);
    }
    else {
        return CGRectMake(0, 0, kBackgroundWidth, kBackgroundHeight);
        
    }
}

- (CGRect) frameForCaptionLabel {
    UIDeviceOrientation orientation = [[UIDevice currentDevice]orientation];
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        return CGRectMake(kPadding, 0, kCaptionLabelWidth_landscape - 2*kPadding, kCaptionHeight);
    }
    else {
        return CGRectMake(kPadding, 0, kCaptionLabelWidth - 2*kPadding, kCaptionHeight);

    }
}

- (CGRect) frameForMetadataLabel:(CGRect)frame {
    UIDeviceOrientation orientation = [[UIDevice currentDevice]orientation];
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        return CGRectMake(kPadding, frame.size.height-kMetadataHeight, kMetadataLabelWidth_landscape - 2*kPadding, kMetadataHeight);
    }
    else {
        return CGRectMake(kPadding, frame.size.height-kMetadataHeight, kMetadataLabelWidth - 2*kPadding, kMetadataHeight);
        
    }
}


#pragma mark - Initializers

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.frame = frame;
        
        // set transparent backgrounds first
        UIView* v_captionBackground = nil;
        v_captionBackground = [[UIView alloc] initWithFrame:[self frameForBackground]];
        [v_captionBackground setBackgroundColor:[UIColor blackColor]];
        [v_captionBackground setAlpha:0.5];
        [v_captionBackground setOpaque:YES];
        [self addSubview:v_captionBackground];
        
        
        // now add non-transparent text
        self.tv_caption = [[UILabel alloc] initWithFrame:[self frameForCaptionLabel]];
        self.tv_metadata = [[UILabel alloc] initWithFrame:[self frameForMetadataLabel:frame]];
        
        self.tv_caption.backgroundColor = [UIColor clearColor];
        self.tv_caption.opaque = YES;
        self.tv_caption.alpha = textAlpha;
        self.tv_caption.font = [UIFont fontWithName:font_CAPTION size:fontsize_CAPTION];
        self.tv_caption.textColor = [UIColor whiteColor];
        self.tv_caption.lineBreakMode = UILineBreakModeWordWrap;
        self.tv_caption.numberOfLines = 2;
        self.tv_caption.textAlignment = UITextAlignmentCenter;
        
        self.tv_metadata.backgroundColor = [UIColor clearColor];
        self.tv_metadata.opaque = YES;
        self.tv_metadata.alpha = textAlpha;
        self.tv_metadata.font = [UIFont fontWithName:font_CAPTION size:fontsize_CAPTION];
        self.tv_metadata.textColor = [UIColor whiteColor];
        self.tv_metadata.textAlignment = UITextAlignmentCenter;
        
        
        [self addSubview:tv_caption];
        [self addSubview:tv_metadata];
       
    }
    return self;
}

-(id) initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
        NSArray* bundle =  [[NSBundle mainBundle] loadNibNamed:@"UICaptionLabel" owner:self options:nil];
        
        UIView* profileBar = [bundle objectAtIndex:0];
        [self addSubview:profileBar];
        
        
        
        
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
    [m_caption release];
    [self.tv_caption release];
    [self.tv_metadata release];
    [super dealloc];
}

//This is where the "by ChronicPoker 2 minutes ago" stirng is created
- (NSString*) getMetadataString {
    return [NSString stringWithFormat:@"By %@ on %@",m_caption.creatorname,[DateTimeHelper formatShortDate:[NSDate date]]];
}

- (void) setCaption:(Caption *)caption {
    if (m_caption != nil) {
        [m_caption release];
    }
    
    m_caption = [caption retain];
    self.tv_caption.text = [NSString stringWithFormat:@"\"%@\"",m_caption.caption1];
    self.tv_metadata.text =[self getMetadataString];
    
}
@end
