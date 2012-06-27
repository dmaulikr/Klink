//
//  UIScoreChangeView.m
//  Platform
//
//  Created by Jasjeet Gill on 5/31/12.
//  Copyright (c) 2012 Blue Label Solutions LLC. All rights reserved.
//

#import "UIScoreChangeView.h"


#import "AuthenticationManager.h"
#import "UIScoreChangeTableViewCell.h"
#import "ScoreJustification.h"

#define kSCORECHANGECELLHEIGHT 78
#define kCELLIDENTIFIER @"ScoreChangeCell"

@implementation UIScoreChangeView
@synthesize view                            = m_view;
@synthesize tbl_scoreChanges                = m_tbl_scoreChanges;
@synthesize lbl_topMessage                  = m_lbl_topMessage;
@synthesize lbl_totalScoreChange            = m_lbl_totalScoreChange;
@synthesize iv_coin                         = iv_coin;
@synthesize otherPeoplesScoreJustifications = m_otherPeopleScoreJustifications;

@synthesize completedRequest                = m_completedRequest;
@synthesize scoreChangeInRequest            = m_scoreChangeInRequest;
@synthesize scoreJustifications             = m_scoreJustifications;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        NSArray* topLevelObjs = nil;
        topLevelObjs = [[NSBundle mainBundle] loadNibNamed:@"UIScoreChangeView" owner:self options:nil];
        
        if (topLevelObjs == nil) {
            NSLog(@"Error, could not load UIScoreChangeView");
        }
        
        [self addSubview:self.view];
    }
    return self;
}

- (void)dealloc
{
    self.view = nil;
    self.tbl_scoreChanges = nil;
    self.lbl_topMessage = nil;
    self.lbl_totalScoreChange = nil;
    self.iv_coin = nil;
    
    [super dealloc];
}


- (void) renderCompletedRequest:(Request *)request
{
    //display in the table the completed requests
    self.completedRequest = request;
    
    NSNumber* currentUserID = [[AuthenticationManager instance]m_LoggedInUserID];
        
    int totalPointsEarned = 0;
    
    //we need to iterate through the completed requests and create a list of attribute score changes
    
        NSArray* consequentialUpdatesInRequest = request.consequentialUpdates;
        
        for (AttributeChange* ac in consequentialUpdatesInRequest)
        {
            if ([ac.targetobjectid isEqualToNumber:currentUserID])
            {
                //change corresponds to current logged in user
                if ([ac.attributename isEqualToString:NUMBEROFPOINTS])
                {
                    //change is in the points value
                    //we add it to the score changes array
                    
                    self.scoreChangeInRequest = ac;
                    break;
                }
            }
        }
        
    self.scoreJustifications = self.scoreChangeInRequest.scorejustifications;
        
    totalPointsEarned += [self.scoreChangeInRequest.delta intValue];
    
    //if the user earned no points we need to adjust the text and such
    if (totalPointsEarned == 0) {
        //no points earned
        self.lbl_topMessage.text = @"Nice try, but you didn't earn any coins.";
        self.iv_coin.hidden = YES;
    }
    else {
        self.lbl_topMessage.text = @"Nice work!\nYou earned some coins:";
        self.iv_coin.hidden = NO;
    }
    
    //now lets set the total score label
    NSString* scoreChange = [NSString stringWithFormat:@"+%d", totalPointsEarned];
    self.lbl_totalScoreChange.text = scoreChange;
    
    // Move the coin icon next to the score label
    UIFont* font = [UIFont fontWithName:@"AmericanTypewriter-Bold" size:20];
    CGSize size = [scoreChange sizeWithFont:font constrainedToSize:CGSizeMake(68, 20) lineBreakMode:UILineBreakModeTailTruncation];
    self.iv_coin.center = CGPointMake(285 - size.width, self.iv_coin.center.y);
       
    
    //now we need to grab all the justifications for other users
    consequentialUpdatesInRequest = request.consequentialUpdates;
    NSMutableArray* otherPeoplesScoreChanges = [[NSMutableArray alloc]init];
    
    for (AttributeChange* ac in consequentialUpdatesInRequest)
    {
        if (![ac.targetobjectid isEqualToNumber:currentUserID])
        {
            //change corresponds to current logged in user
            if ([ac.attributename isEqualToString:NUMBEROFPOINTS])
            {
                //change is in the points value
                //we add it to the score changes array
                [otherPeoplesScoreChanges addObject:ac];
            }
        }
    }

    //now we have all the other people's score changes
    self.otherPeoplesScoreJustifications = [UIScoreChangeView reformatOtherPeoplesScoreJustifications:otherPeoplesScoreChanges];
    [otherPeoplesScoreChanges release];
    [self.tbl_scoreChanges reloadData];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/


#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int index = [indexPath row];
    int count = [self.scoreJustifications count];
    
    
    ScoreJustification* sj = nil;
    if (index < count) {
        sj = [self.scoreJustifications objectAtIndex:index];

    }
    else
    {
        sj = [self.otherPeoplesScoreJustifications objectAtIndex:(index - count)];
    }
    
    NSString* text = sj.justification;
    UIFont* font = [UIFont fontWithName:@"American Typewriter" size:13];
    CGSize size = [text sizeWithFont:font constrainedToSize:CGSizeMake(228,10000) lineBreakMode:UILineBreakModeWordWrap];
    return size.height;
}

#pragma mark - UITableDataSourceDelegate
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return ([self.scoreJustifications count] +
            [self.otherPeoplesScoreJustifications count]);
}

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int count = [self.scoreJustifications count];
    int otherPeoplesCount = [self.otherPeoplesScoreJustifications count];
    int index = [indexPath row];
    
    ScoreJustification* sj = nil;
    
    if (index < (count + otherPeoplesCount)) {
        
        if (index < count) 
        {
            sj = [self.scoreJustifications objectAtIndex:index];
        }
        else {
            //its other person's score change
            sj = [self.otherPeoplesScoreJustifications objectAtIndex:(index - count)];
        }
        
        UIScoreChangeTableViewCell* cell = [self.tbl_scoreChanges dequeueReusableCellWithIdentifier:kCELLIDENTIFIER];
        if (cell == nil) 
        {
            cell = [[[UIScoreChangeTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCELLIDENTIFIER]autorelease];
            
        }
        
        [cell renderScoreChange:sj];
        return cell;
    }
    else {
        return nil;
    }
   
       
    
}

//returns a list of score justification objects that have been modified so that they display
//the desired other people's score formats
+ (NSArray*) reformatOtherPeoplesScoreJustifications:(NSArray*)otherPeoplesScoreChanges
{
    NSMutableArray* retVal = [[[NSMutableArray alloc]init]autorelease];
    for (AttributeChange* ac in otherPeoplesScoreChanges) {
        NSArray* scoreJustifications = ac.scorejustifications;
        
        //we iterate through each 
        for (ScoreJustification* sj in scoreJustifications)
        {
            //we create a new justification string by concatenating the amount with the string
            //and then we 0 out the score 
            
            //is it more than 1 point
            NSString* coinString = @"coin";
            if ([sj.points intValue] > 1) 
            {
                coinString = @"coins";
                
            }
            
            NSString* modifiedDescription = [NSString stringWithFormat:@"%@ %@ %@",sj.justification,sj.points,coinString];
            sj.justification = modifiedDescription;
            sj.points = 0;
            [retVal addObject:sj];
        }
    }
    
    return retVal;
}

@end
