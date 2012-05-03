//
//  LeaderboardViewController.m
//  Platform
//
//  Created by Jasjeet Gill on 4/24/12.
//  Copyright (c) 2012 Blue Label Solutions LLC. All rights reserved.
//

#import "LeaderboardViewController.h"
#import "Leaderboard.h"
#import "LeaderboardEntry.h"
#import "UILeaderboardTableViewCell.h"
#import "LeaderboardTypes.h"
#import "LeaderboardRelativeTo.h"
#import "AuthenticationManager.h"

@implementation LeaderboardViewController
@synthesize leaderboardID   = m_leaderboardID;
@synthesize leaderboard     = m_leaderboard;
@synthesize userID          = m_userID;
@synthesize tbl_leaderboard = m_tbl_leaderboard;
@synthesize sc_relativeTo   = m_sc_relativeTo;
@synthesize sc_type         = m_sc_type;
@synthesize allLeaderboardCloudEnumerator = m_allLeaderboardCloudEnumerator;
@synthesize friendsLeaderboardCloudEnumerator = m_friendsLeaderboardCloudEnumerator;



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"page_pattern.png"]];
        self.tbl_leaderboard.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"page_pattern.png"]];
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


- (void) render
{
    //[self.tbl_leaderboard reloadData];
    
    // Reload the tableview with animation
    [self.tbl_leaderboard reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationTop];

}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;

    // Set Navigation bar title style with typewriter font
    CGSize labelSize = [@"Leaderboard" sizeWithFont:[UIFont fontWithName:@"AmericanTypewriter-Bold" size:20.0]];
    UILabel* titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, labelSize.width, 44)];
    titleLabel.text = @"Leaderboard";
    titleLabel.font = [UIFont fontWithName:@"AmericanTypewriter-Bold" size:20.0];
    titleLabel.textAlignment = UITextAlignmentCenter;
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.adjustsFontSizeToFitWidth = YES;
    // emboss so that the label looks OK
    [titleLabel setShadowColor:[UIColor blackColor]];
    [titleLabel setShadowOffset:CGSizeMake(0.0, -1.0)];
    self.navigationItem.titleView = titleLabel;
    [titleLabel release];

}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    self.tbl_leaderboard = nil;
    self.sc_relativeTo = nil;
    self.sc_type = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // We need to indicate selected states on the segmented controls
    // based on the current entry values
    
    if ([self.leaderboard.relativeto intValue] == kPEOPLEIKNOW)
    {
        [self.sc_relativeTo setSelectedSegmentIndex:0];
    }
    else 
    {
        [self.sc_relativeTo setSelectedSegmentIndex:1];
    }
    
    if ([self.leaderboard.type intValue] == kWEEKLY)
    {
        [self.sc_type setSelectedSegmentIndex:0];
    }
    else
    {
        [self.sc_type setSelectedSegmentIndex:1];
    }
    
    // Enumerate leaderboards of All Time type
    [self enumerateLeaderboardOfType:kALLTIME relativeTo:kPEOPLEIKNOW];
    [self enumerateLeaderboardOfType:kALLTIME relativeTo:kALL];
    
    [self render];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    //we add one to insert a title row for switching controls
    int count = [self.leaderboard.entries count];
    //return count + 1;
    return count;
}

/*#define kSegmentControlHeight 21
#define kSegmentControlWidth 200
#define kSegmentControlVMargin 5
#define kSegmentControlX 50
#define kCellHeight 50
#define kCellWidth 320

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int index = [indexPath row];
    if (index == 0)
    {
        return (kSegmentControlHeight*2)+ (kSegmentControlVMargin*3);
    }
    else
    {
        return kCellHeight;
    }
}*/

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier;
    int index = [indexPath row];
    UILeaderboardTableViewCell *cell = nil;
    
    
    /*if (index == 0)
    {
        CGRect frameForSC = CGRectMake(kSegmentControlX, kSegmentControlVMargin, kSegmentControlWidth, kSegmentControlHeight);
        CGRect frameForSC2 = CGRectMake(kSegmentControlX, kSegmentControlVMargin*2+kSegmentControlHeight, kSegmentControlWidth, kSegmentControlHeight);
        
        CellIdentifier = @"TitleCell1";
        //here we create a basic row for some controls to manage the leaderboard
        UITableViewCell* tableViewCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (tableViewCell == nil)
        {
            tableViewCell = [[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier]autorelease];
            
            
           // NSArray* segmentStings = [NSArray arrayWithObjects:@"My Friends",@"Everyone",nil];
            UISegmentedControl* sc_relativeTo = [[UISegmentedControl alloc]initWithFrame:frameForSC];
            [sc_relativeTo insertSegmentWithTitle:@"My Friends" atIndex:0 animated:NO];
            [sc_relativeTo insertSegmentWithTitle:@"Everyone" atIndex:1 animated:NO];
            [sc_relativeTo addTarget:self action:@selector(onRelativeSelectionChanged:) forControlEvents:UIControlEventValueChanged];
            [tableViewCell addSubview:sc_relativeTo];
            [sc_relativeTo release];
            
            UISegmentedControl* sc_type = [[UISegmentedControl alloc]initWithFrame:frameForSC2];
            [sc_type insertSegmentWithTitle:@"This Week" atIndex:0 animated:NO];
            [sc_type insertSegmentWithTitle:@"All Time" atIndex:1 animated:NO];
            [sc_type addTarget:self action:@selector(onTypeSelectionChanged:) forControlEvents:UIControlEventValueChanged];
            
            [tableViewCell addSubview:sc_type];
            [sc_type release];

            //we need to indicate selected states based on the current entry values
            if ([self.leaderboard.relativeto intValue] == kALL)
            {
                [sc_relativeTo setSelectedSegmentIndex:1];
            }
            else 
            {
                [sc_relativeTo setSelectedSegmentIndex:0];
            }
            
            if ([self.leaderboard.type intValue] == kPEOPLEIKNOW)
            {
                [sc_type setSelectedSegmentIndex:0];
            }
            else
            {
                [sc_type setSelectedSegmentIndex:1];
            }
                                      
        }
        
        //lets add a toggle button to it 
        return tableViewCell;
    
    }
    else if (index < [self.leaderboard.entries count]+1)
    {*/ 
        CellIdentifier = @"Cell";
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[[UILeaderboardTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        }
        
        //grab the leaderboard entry in question
        //LeaderboardEntry* entry = [self.leaderboard.entries objectAtIndex:(index-1)];
        LeaderboardEntry* entry = [self.leaderboard.entries objectAtIndex:index];
        [cell renderWithEntry:entry];
    //}
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/



#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */
}

#pragma mark - Enumerations
- (void) enumerateLeaderboardOfType:(LeaderboardTypes)type relativeTo:(LeaderboardRelativeTo)relativeTo
{
    self.allLeaderboardCloudEnumerator = [CloudEnumerator enumeratorForLeaderboard:self.userID ofType:type relativeTo:relativeTo];
    self.allLeaderboardCloudEnumerator.delegate = self;
    
    [self.allLeaderboardCloudEnumerator enumerateUntilEnd:nil];
    
    self.friendsLeaderboardCloudEnumerator = [CloudEnumerator enumeratorForLeaderboard:self.userID ofType:type relativeTo:relativeTo];
    self.friendsLeaderboardCloudEnumerator.delegate = self;
    
    [self.friendsLeaderboardCloudEnumerator enumerateUntilEnd:nil];
}

#pragma mark - CloudEnumeratorDelegate
- (void) onEnumerateComplete:(CloudEnumerator*)enumerator 
                 withResults:(NSArray *)results 
                withUserInfo:(NSDictionary *)userInfo
{
    ResourceContext* resourceContext = [ResourceContext instance];
    
    if (enumerator == self.allLeaderboardCloudEnumerator) {
        // Get the leaderboad object from the resource context
        NSSortDescriptor* sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:DATECREATED ascending:NO];
        NSArray* valuesArray = [NSArray arrayWithObjects:[self.userID stringValue], [NSString stringWithFormat:@"%d",kALL], nil];
        NSArray* attributesArray = [NSArray arrayWithObjects:USERID, RELATIVETO, nil];
        NSArray* sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
        
        //self.leaderboard = (Leaderboard*)[resourceContext resourceWithType:LEADERBOARD withValuesEqual:valuesArray forAttributes:attributesArray sortBy:sortDescriptors];
        
        [self render];
    }
    else if (enumerator == self.friendsLeaderboardCloudEnumerator) {
        // Get the leaderboad object from the resource context
        NSSortDescriptor* sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:DATECREATED ascending:NO];
        NSArray* valuesArray = [NSArray arrayWithObjects:[self.userID stringValue], [NSString stringWithFormat:@"%d",kPEOPLEIKNOW], nil];
        NSArray* attributesArray = [NSArray arrayWithObjects:USERID, RELATIVETO, nil];
        NSArray* sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
        
        //self.leaderboard = (Leaderboard*)[resourceContext resourceWithType:LEADERBOARD withValuesEqual:valuesArray forAttributes:attributesArray sortBy:sortDescriptors];
        
        [self render];
    }
}

#pragma mark - Event handlers
- (IBAction)onRelativeSelectionChanged:(id)sender {
    //the user has selected a different relative to leaderboard
    UISegmentedControl* segmentControl = (UISegmentedControl*)sender;
    
    int selectedIndex = segmentControl.selectedSegmentIndex;
    LeaderboardRelativeTo relativeTo;
    
    
    if (selectedIndex == 0)
    {
        relativeTo = kPEOPLEIKNOW;
    }
    else
    {
        relativeTo = kALL;
    }
    
    LeaderboardTypes type = [self.leaderboard.type intValue];
    
    //lets get the leaderboard
    Leaderboard* newLeaderboard = [Leaderboard leaderboardForUserID:self.userID withType:type andRelativeTo:relativeTo];
    if (newLeaderboard != nil)
    {
        self.leaderboard = newLeaderboard;
        self.leaderboardID = newLeaderboard.objectid;
        [self render];
    }
    else
    {
        //we need to enumerate it from the web service
        [self enumerateLeaderboardOfType:type relativeTo:relativeTo];
    }
    
}

- (IBAction)onTypeSelectionChanged:(id)sender {
    //the user has selected a different relative to leaderboard
    UISegmentedControl* segmentControl = (UISegmentedControl*)sender;
    
    int selectedIndex = segmentControl.selectedSegmentIndex;
    LeaderboardTypes type;
    
    if (selectedIndex == 0)
    {
        type = kWEEKLY;
    }
    else
    {
        type = kALLTIME;
    }
    
    LeaderboardRelativeTo relativeTo = [self.leaderboard.relativeto intValue];
    
    //lets get the leaderboard
    Leaderboard* newLeaderboard = [Leaderboard leaderboardForUserID:self.userID withType:type andRelativeTo:relativeTo];
    if (newLeaderboard != nil)
    {
        self.leaderboard = newLeaderboard;
        self.leaderboardID = newLeaderboard.objectid;
        [self render];
    }
    else
    {
        //we need to enumerate it from the web service
        [self enumerateLeaderboardOfType:type relativeTo:relativeTo];
    }
    
}

#pragma mark - Static initializers
+ (LeaderboardViewController*) createInstanceFor:(NSNumber *)leaderboardID
{
    LeaderboardViewController* lvc  = [[LeaderboardViewController alloc]initWithNibName:@"LeaderboardViewController" bundle:nil];
    lvc.leaderboardID = leaderboardID;
    
    ResourceContext* resourceContext = [ResourceContext instance];
    lvc.leaderboard = (Leaderboard*)[resourceContext resourceWithType:LEADERBOARD withID:leaderboardID];
    
    AuthenticationContext* context = [[AuthenticationManager instance]contextForLoggedInUser];
    if (context != nil)
    {
        lvc.userID = context.userid;
    }
    else {
        lvc.userID = nil;
    }
    [lvc autorelease];
    return lvc;
    
}

+ (LeaderboardViewController*) createInstanceFor:(NSNumber *)leaderboardID forUserID:(NSNumber*)userID
{
    LeaderboardViewController* lvc  = [[LeaderboardViewController alloc]initWithNibName:@"LeaderboardViewController" bundle:nil];
    lvc.leaderboardID = leaderboardID;
    
    ResourceContext* resourceContext = [ResourceContext instance];
    lvc.leaderboard = (Leaderboard*)[resourceContext resourceWithType:LEADERBOARD withID:leaderboardID];
    lvc.userID = userID;
        [lvc autorelease];
    return lvc;
    
}

@end
