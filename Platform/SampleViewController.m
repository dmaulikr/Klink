//
//  SampleViewController.m
//  Platform
//
//  Created by Bobby Gill on 10/7/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import "SampleViewController.h"
#import "User.h"
#import "Types.h"
#import "Resource.h"
#import "JSONKit.h"
#import "Query.h"
#import "ApplicationSettings.h"
#import "ApplicationSettingsManager.h"
#import "EnumerationResponse.h"

@implementation SampleViewController
@synthesize toJSONButton    =m_toJSONButton;
@synthesize fromJSONButton  =m_fromJSONButton;
@synthesize user            =m_user;
@synthesize textView        =m_textView;
@synthesize query           =m_query;
@synthesize enumerationContext = m_enumerationContext;
@synthesize enumerationResponse = m_enumerationResponse;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    ResourceContext* testResourceContext = self.resourceContext;
    NSManagedObjectContext* appContext = testResourceContext.managedObjectContext;
    
    ApplicationSettings* applicationSettings = [[ApplicationSettingsManager instance]settings];
    
    User* user = [Resource createInstanceOfType:USER withResourceContext:self.resourceContext];
    self.user = user;
    self.user.displayname = @"jagoo aiya";
    self.user.numberofvotes = [NSNumber numberWithInt:10];    
    
    User* user2 = [[Resource createInstanceOfType:USER withResourceContext:self.resourceContext]retain];
    user2.displayname = @"user 2";
    user2.numberofvotes = [NSNumber numberWithInt:20];    
    
    Query* query = [Query queryPhotosWithTheme:[NSNumber numberWithInt:10]];
    self.query = query;
    self.enumerationContext = [EnumerationContext contextForPhotosInTheme:[NSNumber numberWithInt:10]];
    
    self.enumerationResponse = [[EnumerationResponse alloc]init];
    self.enumerationResponse.primaryResults = [NSArray arrayWithObjects:user,user2, nil];
    self.enumerationResponse.secondaryResults = [NSArray arrayWithObject:user];
    
                               
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)toJSON:(id)sender {
    //convert the user object to JSON
    NSString* jsonString = [self.user toJSON];
   
    
    NSString* queryJson = [self.query toJSON];
    
    NSString* contextJson = [self.enumerationContext toJSON];
    
    NSString* enumerationResponseJson = [self.enumerationResponse toJSON];
    self.textView.text = enumerationResponseJson;
    
    
    
}

- (IBAction)fromJSON:(id)sender {
    NSString* jsonString = self.textView.text;
    NSDictionary* jsonDictionary = [jsonString objectFromJSONString];   
      
    EnumerationResponse* enumeratinResponse = [[EnumerationResponse alloc]initFromJSONDictionary:jsonDictionary];
    //Query* queryObj = [[Query alloc]initFromJSON:jsonString];
    //User* userObj = (User*)[Resource createInstanceOfTypeFromJSON:jsonDictionary];
    //EnumerationContext* enumerationContext = [[EnumerationContext alloc]initFromJSON:jsonString];
    NSString* test = @"test";
}

@end
