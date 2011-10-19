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
@synthesize loginButton     =m_loginButton;
@synthesize logoutButton    =m_logoutButton;

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
  
    
    ApplicationSettings* applicationSettings = [[ApplicationSettingsManager instance]settings];
    
       
        
                               
    
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if ([self.authenticationManager isUserAuthenticated]) {
        self.loginButton.hidden = YES;
        self.logoutButton.hidden = NO;
    }
    else {
        self.loginButton.hidden = NO;
        self.logoutButton.hidden = YES;
    }
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

- (IBAction)login:(id)sender {
    if (![self.authenticationManager isUserAuthenticated]) {
        //perform authentication
        [self.authenticationManager authenticate];
    }
}

- (IBAction)logout:(id)sender {
    [self.authenticationManager logoff];
}

@end
