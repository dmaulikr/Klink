//
//  UIPointsProgressBar.m
//  Platform
//
//  Created by Jordan Gurrieri on 5/18/12.
//  Copyright (c) 2012 Blue Label Solutions LLC. All rights reserved.
//

#import "UIPointsProgressBar.h"
#import "ApplicationSettingsManager.h"

@implementation UIPointsProgressBar

@synthesize user                    = m_user;
@synthesize userID                  = m_userID;

@synthesize view                    = m_view;

@synthesize lbl_editorMinimumLabel  = m_lbl_editorMinimumLabel;
@synthesize lbl_userBestLabel       = m_lbl_userBestLabel;
@synthesize lbl_numPoints           = m_lbl_numPoints;

@synthesize v_nextAchievementContainer  = m_v_nextAchievementContainer;
@synthesize lbl_numNextAchievement  = m_lbl_numNextAchievement;
@synthesize lbl_nextAchievement     = m_lbl_nextAchievement;

@synthesize iv_progressBarContainer = m_iv_progressBarContainer;
@synthesize iv_progressPoints       = m_iv_progressPoints;
@synthesize iv_pointsBanner         = m_iv_pointsBanner;
@synthesize iv_editorMinimumLine    = m_iv_editorMinimumLine;
@synthesize iv_userBestLine         = m_iv_userBestLine;

//#define kPROGRESSBARCONTAINERBUFFER_EDITORMINIMUM 1.2
//#define kPROGRESSBARCONTAINERBUFFER_USERBEST 1.1
#define kPROGRESSBARCONTAINERXORIGINOFFSET 21.0
#define kPROGRESSBARCONTAINERINSETRIGHT 4.0

/*#define kPROGRESSBARCONTAINERBUFFER_EDITORMINIMUM 1.1
#define kPROGRESSBARCONTAINERBUFFER_USERBEST 1.0
#define kPROGRESSBARCONTAINERINSETPOINTSLABEL 40.0*/

#define kPROGRESSBARCONTAINERBUFFER_EDITORMINIMUM 1.1
#define kPROGRESSBARCONTAINERBUFFER_USERBEST 1.0
#define kPROGRESSBARCONTAINERINSETPOINTSLABEL 2.0

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        NSArray* topLevelObjs = nil;
        
        topLevelObjs = [[NSBundle mainBundle] loadNibNamed:@"UIPointsProgressBar" owner:self options:nil];
        if (topLevelObjs == nil)
        {
            NSLog(@"Error! Could not load UIPointsProgressBar file.\n");
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
    self.lbl_editorMinimumLabel = nil;
    self.lbl_userBestLabel = nil;
    self.lbl_numPoints = nil;
    
    self.v_nextAchievementContainer = nil;
    self.lbl_numNextAchievement = nil;
    self.lbl_nextAchievement = nil;
    
    self.iv_progressBarContainer = nil;
    self.iv_progressPoints = nil;
    self.iv_pointsBanner = nil;
    self.iv_editorMinimumLine = nil;
    self.iv_userBestLine = nil;
    
    [super dealloc];
    
}

- (void)drawProgressBar {
    int numCoinsTotal = [self.user.numberofpoints intValue];
    
    int previousAchievement = [self.user.prevachievementthreshold intValue];
    int nextAchievment = [self.user.achievementthreshold intValue];
    
    if ((numCoinsTotal > previousAchievement) && (nextAchievment > previousAchievement)) {
        numCoinsTotal = numCoinsTotal - previousAchievement;
        nextAchievment = nextAchievment - previousAchievement;
    }
    
    
    float progressBarContainerWidth = self.iv_progressBarContainer.frame.size.width - kPROGRESSBARCONTAINERINSETPOINTSLABEL;
    float editorMinimumLineMidPoint = (float)self.iv_editorMinimumLine.frame.size.width / (float)2;
    float editorMinimumLabelMidPoint = (float)self.lbl_editorMinimumLabel.frame.size.width / (float)2;
    //float userBestLineMidPoint = (float)self.iv_userBestLine.frame.size.width / (float)2;
    //float userBestLabelMidPoint = (float)self.lbl_userBestLabel.frame.size.width / (float)2;
    
    
    ApplicationSettings* settings = [[ApplicationSettingsManager instance] settings];
    int editorMinimum = [settings.editor_minimum intValue];
    int numberofcoinslw = [self.user.numberofpointssw intValue];
    editorMinimum = editorMinimum + numberofcoinslw;
    
    //int userBest = [self.user.maxweeklyparticipation intValue];
    
    // determine which value will set the scale (max value) for the progress bar
    //float progressBarMaxValue = MAX(MAX((float)userBest, (float)editorMinimum), (float)coinsEarned);
    float progressBarMaxValue = MAX((float)nextAchievment, (float)editorMinimum);
    //float progressBarMaxValue = 2;  // used for testing
    
    /*if (progressBarMaxValue == (float)userBest) {
        // extend the max value of the progress bar to leave an appropriate whitespace buffer in the container 
        progressBarMaxValue = (float)progressBarMaxValue * (float)kPROGRESSBARCONTAINERBUFFER_USERBEST;
    }
    else if (progressBarMaxValue == (float)editorMinimum) {
        // extend the max value of the progress bar to leave an appropriate whitespace buffer in the container 
        progressBarMaxValue = (float)progressBarMaxValue * (float)kPROGRESSBARCONTAINERBUFFER_EDITORMINIMUM;
    }
    else {
        // extend the max value of the progress bar to leave an appropriate whitespace buffer in the container for the points label
    }*/
    
    float scaleEditorMinimum = 0.0f;
    //float scaleUserBest = 0.0f;
    if ((float)progressBarMaxValue != 0.0) {
        scaleEditorMinimum = (float)editorMinimum / (float)progressBarMaxValue;
        //scaleUserBest = (float)userBest / (float)progressBarMaxValue;
    }
    
    // move the editor threshold line
    float editorMinimumLineXOrigin = MAX(kPROGRESSBARCONTAINERXORIGINOFFSET, kPROGRESSBARCONTAINERXORIGINOFFSET + (scaleEditorMinimum * progressBarContainerWidth) - editorMinimumLineMidPoint);
    self.iv_editorMinimumLine.frame = CGRectMake(editorMinimumLineXOrigin, self.iv_editorMinimumLine.frame.origin.y, self.iv_editorMinimumLine.frame.size.width, self.iv_editorMinimumLine.frame.size.height);
    float editorMinimumWidth = (float)self.iv_editorMinimumLine.frame.origin.x + (float)editorMinimumLineMidPoint - (float)kPROGRESSBARCONTAINERXORIGINOFFSET;
    
    // move the editor threshold label
    float editorMinimumLabelXOrigin = MAX(kPROGRESSBARCONTAINERXORIGINOFFSET, kPROGRESSBARCONTAINERXORIGINOFFSET + editorMinimumWidth - editorMinimumLabelMidPoint);
    if (editorMinimumLabelXOrigin > 230) {
        // Make sure the label does not go off the screen
        editorMinimumLabelXOrigin = 230;
    }
    self.lbl_editorMinimumLabel.frame = CGRectMake(editorMinimumLabelXOrigin, self.lbl_editorMinimumLabel.frame.origin.y, self.lbl_editorMinimumLabel.frame.size.width, self.lbl_editorMinimumLabel.frame.size.height);
    
    /*// move the user best threshold line
    float userBestLineXOrigin = MAX(kPROGRESSBARCONTAINERXORIGINOFFSET, kPROGRESSBARCONTAINERXORIGINOFFSET + (scaleUserBest * progressBarContainerWidth) - userBestLineMidPoint);
    self.iv_userBestLine.frame = CGRectMake(userBestLineXOrigin, self.iv_userBestLine.frame.origin.y, self.iv_userBestLine.frame.size.width, self.iv_userBestLine.frame.size.height);
    float userBestWidth = (float)self.iv_userBestLine.frame.origin.x + (float)userBestLineMidPoint - (float)kPROGRESSBARCONTAINERXORIGINOFFSET;
    
    // move the user best threshold label
    float userBestLabelXOrigin = 0.0f;
    if ([self.user.maxweeklyparticipation intValue] == 0) {
        userBestLabelXOrigin = MIN(kPROGRESSBARCONTAINERXORIGINOFFSET, kPROGRESSBARCONTAINERXORIGINOFFSET + userBestWidth - userBestLabelMidPoint);
    }
    else {
        userBestLabelXOrigin = MAX(kPROGRESSBARCONTAINERXORIGINOFFSET, kPROGRESSBARCONTAINERXORIGINOFFSET + userBestWidth - userBestLabelMidPoint);
    }
    self.lbl_userBestLabel.frame = CGRectMake(userBestLabelXOrigin, self.lbl_userBestLabel.frame.origin.y, self.lbl_userBestLabel.frame.size.width, self.lbl_userBestLabel.frame.size.height);*/
    
    
    // now draw the progress bar of the total coins count
    float progressPoints = 0.0f;
    if ((float)progressBarMaxValue != 0.0) {
        progressPoints = ((float)numCoinsTotal) / (float)progressBarMaxValue;
    }
    //progressPoints = (float)20 / (float)progressBarMaxValue;
    self.iv_progressPoints.frame = CGRectMake(kPROGRESSBARCONTAINERXORIGINOFFSET, self.iv_progressPoints.frame.origin.y,(progressPoints * progressBarContainerWidth), self.iv_progressPoints.frame.size.height);
    [self.iv_progressPoints setHidden:NO];
    
    
    [self setNeedsDisplay];
    
}

- (void) renderProgressBarForUserWithID:(NSNumber *)userID
{
    self.lbl_numNextAchievement.text = @" ";
    self.lbl_numPoints.text = @" ";
    
    ResourceContext* resourceContext = [ResourceContext instance];
    self.userID = userID;
    self.user = (User*)[resourceContext resourceWithType:USER withID:self.userID];
    
    self.lbl_numPoints.text = [self.user.numberofpoints stringValue];
    //self.lbl_numPoints.text = @"100000";    // used for testing
    
    // Move the points banner to fully wrap the number of points label
    UIFont* pointsFont = [UIFont fontWithName:@"AmericanTypewriter-Bold" size:16];
    CGSize pointsSize = [self.lbl_numPoints.text sizeWithFont:pointsFont constrainedToSize:CGSizeMake(80, 20) lineBreakMode:UILineBreakModeTailTruncation];
    self.iv_pointsBanner.frame = CGRectMake(-2, self.iv_pointsBanner.frame.origin.y, self.lbl_numPoints.frame.origin.x + pointsSize.width + 15, self.iv_pointsBanner.frame.size.height);
    
    NSString* nextAchievement = [self.user.achievementthreshold stringValue];
    self.lbl_numNextAchievement.text = nextAchievement;
    //self.lbl_numNextAchievement.text = @"100000";    // used for testing
    
    // Move the achievement description label next to the achievement number label
    UIFont* achievementFont = [UIFont fontWithName:@"AmericanTypewriter" size:14];
    CGSize achievementsSize = [self.lbl_numNextAchievement.text sizeWithFont:achievementFont constrainedToSize:CGSizeMake(55, 20) lineBreakMode:UILineBreakModeTailTruncation];
    //self.lbl_nextAchievement.center = CGPointMake(243 - achievementsSize.width, self.lbl_nextAchievement.center.y);
    self.v_nextAchievementContainer.center = CGPointMake(250 - achievementsSize.width, self.v_nextAchievementContainer.center.y);
    
    //self.lbl_userBestLabel.text = [NSString stringWithFormat:@"Best: %d", [self.user.maxweeklyparticipation intValue]];
    
    [self drawProgressBar];
}

@end
