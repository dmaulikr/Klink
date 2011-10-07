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

@implementation SampleViewController
@synthesize toJSONButton    =m_toJSONButton;
@synthesize fromJSONButton  =m_fromJSONButton;
@synthesize user            =m_user;
@synthesize textView        =m_textView;

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
    
    self.user = [Resource createInstanceOfType:USER withManagedContext:self.managedObjectContext];
    self.user.displayname = @"jagoo aiya";
    self.user.numberofvotes = [NSNumber numberWithInt:10];
    
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
    NSString* jsonString = [self.user JSONString];
    self.textView.text = jsonString;
    
    
    
}

- (IBAction)fromJSON:(id)sender {
    
}

@end
