//
//  UIRequestSummaryView.m
//  Platform
//
//  Created by Jasjeet Gill on 4/16/12.
//  Copyright (c) 2012 Blue Label Solutions LLC. All rights reserved.
//

#import "UIRequestSummaryView.h"
#import "Request.h"
#import "AttributeChange.h"
#import "AuthenticationManager.h"
#import "Attributes.h"
#import "ObjectChange.h"
#import "Achievement.h"

@implementation UIRequestSummaryView
@synthesize view = m_view;
@synthesize lbl_totalScore = m_lbl_totalScore;
@synthesize lbl_scoreIncrement = m_lbl_scoreIncrement;
@synthesize lbl_oldScore = m_lbl_oldScore;
@synthesize lbl_achievements = m_lbl_achievements;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code 
        NSArray* topLevelObjs = nil;
        
        topLevelObjs = [[NSBundle mainBundle] loadNibNamed:@"UIRequestSummaryView" owner:self options:nil];
        if (topLevelObjs == nil)
        {
            NSLog(@"Error! Could not load UIEditorialPageView nib file..\n");
        }
        
        [self addSubview:self.view];
        
    }
    return self;
}


- (void) renderCompletedRequests:(NSArray *)completedRequests
{
    //will take the array of Requests and compute the totals and display them
    int totalPointsEarned = 0;
    int newTotalPoints = 0;
    int oldScore = 0;
    int numberOfAchievements = 0;
    
    NSNumber* currentUserID = [[AuthenticationManager instance]m_LoggedInUserID];
    self.lbl_scoreIncrement.text = @"";
    self.lbl_totalScore.text = @"";
    self.lbl_oldScore.text = @"";
    
    
    //we only process the result from the first Request
    //since the only instances where it would be bulk is in a creation scenario and they are processed in a single http request
    if ([completedRequests count] > 0)
    {
        Request* request = [completedRequests objectAtIndex:0];
        NSArray* consequentialUpdatesInRequest = request.consequentialUpdates;
        NSArray* consequentialInsertionsInRequest = request.consequentialInserts;
        
        for(AttributeChange* attrChange in consequentialUpdatesInRequest)
        {
            //now we check to ensure the change relates to the currently logged on user
            if ([attrChange.targetobjectid isEqualToNumber:currentUserID])
            {
                //yes it relates to the current user
                //does it relate to the point attribute on u ser?
                if ([attrChange.attributename isEqualToString:NUMBEROFPOINTS])
                {
                    //yes it does, so we process this record
                    //we increment the total points earned
                    totalPointsEarned += [attrChange.delta intValue];
                    
                    //we check the total points, if its larger than the current highest toal point value
                    //then we will set the current highest total point value to it
                    int totalPointsInAttrChange = [ attrChange.newvalue intValue];
                    if (totalPointsInAttrChange > newTotalPoints)
                    {
                        newTotalPoints = totalPointsInAttrChange;
                    }
                    
                    //we do similarily for the old score
                    oldScore = [attrChange.oldvalue intValue];
                }
                
            }
        }
        
        for (ObjectChange* oc in consequentialInsertionsInRequest)
        {
            if ([oc.targetobjecttype isEqualToString:ACHIEVEMENT])
            {
                //it was an achievement that was created
                ResourceContext* resourceContext = [ResourceContext instance];
                Achievement* achievement = (Achievement*)[resourceContext resourceWithType:ACHIEVEMENT withID:oc.targetobjectid];
                if (achievement != nil)
                {
                    //check that the achievement was for you
                    if ([achievement.userid isEqualToNumber:currentUserID])
                    {
                        //yes it is, so let us increment our achievement count
                        numberOfAchievements++;
                    }
                }
            }
        }

    }

    
    //at this point we have the totalpointsearned and the new final point value
    self.lbl_scoreIncrement.text = [NSString stringWithFormat:@"%d",totalPointsEarned];
    self.lbl_totalScore.text = [NSString stringWithFormat:@"%d",newTotalPoints];
    self.lbl_oldScore.text = [NSString stringWithFormat:@"%d",oldScore];
    self.lbl_achievements.text = [NSString stringWithFormat:@"%d",numberOfAchievements];
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
