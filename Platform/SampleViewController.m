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
#import "Photo.h"
#import "ImageManager.h"
#import "CloudEnumerator.h"
#import "FeedManager.h"
#import "Page.h"
#import "AuthenticationContext.h"
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
@synthesize createPhotoButton    =m_createPhotoButton;
@synthesize createPhotoStatus   =m_createPhotoStatus;
@synthesize objectID    = m_objectID;
@synthesize attributeName   =m_attributeName;
@synthesize attributeValue  =m_attributeValue;
@synthesize commitChangesButton =m_commitChangesButton;
@synthesize objectType  =m_objectType;


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
    ResourceContext* testResourceContext = [ResourceContext instance];
  
    
    
       
        
                               
    
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

- (IBAction)createUser:(id)sender {
    ResourceContext* resourceContext = [ResourceContext instance];
    
    AuthenticationContext* context = [self.authenticationManager contextForLoggedInUser];
    Photo* photo = [Resource createInstanceOfType:PHOTO withResourceContext:resourceContext];
    photo.descr = @"test photo";
    photo.imageurl = @"testiomageurl";
    photo.thumbnailurl = @"testthumbnailurl";
    photo.numberofvotes = [NSNumber numberWithInt:0];
    photo.creatorid = context.userid;
    photo.themeid = [NSNumber numberWithLongLong:634535212720410463];
    //insert
    [resourceContext insert:photo];
    
    [resourceContext save:YES onFinishCallback:nil];
}

- (void) test_create2objectsatonce {
    ResourceContext* resourceContext = [ResourceContext instance];
   
    
    NSURL* url = [NSURL URLWithString:@"http://www.oscial.com/wp-content/uploads/2011/10/Gadaffi-fist-pump.jpg"];

    NSData* data = [NSData dataWithContentsOfURL:url]   ; 
    UIImage* image = [UIImage imageWithData:data];
    NSNumber* file = [NSNumber numberWithLongLong:[[NSDate date]timeIntervalSince1970]];
    NSString* fileName = [NSString stringWithFormat:@"%@.jpg",file];
    
    ImageManager* imageManager = [ImageManager instance];
    NSString* fullPath = [imageManager saveImage:image withFileName:fileName];
    AuthenticationContext* context = [self.authenticationManager contextForLoggedInUser];
    
    //photo 1
    Photo* photo = [Resource createInstanceOfType:PHOTO withResourceContext:resourceContext];
    photo.descr = @"test photo";
    photo.imageurl = @"testiomageurl";
    photo.thumbnailurl = fullPath;
    photo.numberofvotes = [NSNumber numberWithInt:0];
    photo.creatorid = context.userid;
    photo.themeid = [NSNumber numberWithLongLong:634535212720410463];

    //photo 2

    Photo* photo2 = [Resource createInstanceOfType:PHOTO withResourceContext:resourceContext];
    photo2.descr = @"test photo 2";
    photo2.imageurl = @"testiomageurl";
    photo2.thumbnailurl = fullPath;
    photo2.numberofvotes = [NSNumber numberWithInt:0];
    photo2.creatorid = context.userid;
    photo2.themeid = [NSNumber numberWithLongLong:634535212720410463];
    
    [resourceContext save:YES onFinishCallback:nil];
    
}

- (void) test_imageDownload {
    ImageManager* imageManager = [ImageManager instance];
    ResourceContext* resourceContext = [ResourceContext instance];
    
    //NSArray* photos = [resourceContext resourcesWithType:PHOTO withValueEqual:nil forAttribute:nil sortBy:nil sortAscending:NO];
    NSArray* photos = [resourceContext resourcesWithType:PHOTO withValueEqual:nil forAttribute:nil sortBy:nil];
    
    for (Photo* photo in photos) {
        if (photo.imageurl != nil) {
            [imageManager downloadImage:photo.imageurl withUserInfo:nil atCallback:nil];
        }
    }
}

- (void) test_enumeratePhotosForTheme:(NSNumber*)themeid {
    CloudEnumerator* photoEnumerator = [CloudEnumerator enumeratorForPhotos:themeid];
    [photoEnumerator enumerateUntilEnd];
}

- (void) test_enumeratePhotosForAllThemes {
    ResourceContext* resourceContext = [ResourceContext instance];

    //NSArray* themes = [resourceContext resourcesWithType:PAGE withValueEqual:nil forAttribute:nil sortBy:nil sortAscending:NO];    
    NSArray* themes = [resourceContext resourcesWithType:PAGE withValueEqual:nil forAttribute:nil sortBy:nil];
    Page* firstPage = [themes objectAtIndex:0];
    
    [self test_enumeratePhotosForTheme:firstPage.objectid];
    
    //at this point we should have launched all download requests
}

- (IBAction) test_enumerateObjects {
        ResourceContext* resourceContext = [ResourceContext instance];
        NSNumber* themeid = [NSNumber numberWithLongLong:634535212720410463];
        
              
           
        
        CloudEnumerator* enumeratorForPhotos = [CloudEnumerator enumeratorForPhotos:themeid];
        [enumeratorForPhotos enumerateUntilEnd];
}

- (IBAction) test_enumerateObjects2 {
        ResourceContext* resourceContext = [ResourceContext instance];
        NSNumber* themeid = [NSNumber numberWithLongLong:634534350173075578];
    
    
    
    
        CloudEnumerator* enumeratorForPhotos = [CloudEnumerator enumeratorForPhotos:themeid];
        [enumeratorForPhotos enumerateUntilEnd];    
}

- (IBAction) test_enumerateFeed {
    FeedManager* feedManager = [FeedManager instance];
    [feedManager refreshFeed];
}

- (IBAction) test_enumeratePages {
    CloudEnumerator* pageEnumerator = [CloudEnumerator enumeratorForPages];
    [pageEnumerator enumerateUntilEnd];
}

- (IBAction) test_enumerateCaptions {
    CloudEnumerator* enumeratorForPhotos = [CloudEnumerator enumeratorForCaptions:[NSNumber numberWithInt:1313483158]];
    [enumeratorForPhotos enumerateUntilEnd];
    
}

- (void) test_createAndUploadPhoto {
   
        
        ImageManager* imageManager= [ImageManager instance];
        NSURL* url = [NSURL URLWithString:@"http://www.oscial.com/wp-content/uploads/2011/10/Gadaffi-fist-pump.jpg"];
        
        NSData* data = [NSData dataWithContentsOfURL:url]   ; 
        UIImage* image = [UIImage imageWithData:data];
        NSNumber* file = [NSNumber numberWithLongLong:[[NSDate date]timeIntervalSince1970]];
        NSString* fileName = [NSString stringWithFormat:@"%@.jpg",file];
        
        NSString* fullPath = [imageManager saveImage:image withFileName:fileName];
        AuthenticationContext* context = [self.authenticationManager contextForLoggedInUser];
        
        ResourceContext* resourceContext = [ResourceContext instance];
        Photo* photo = [Resource createInstanceOfType:PHOTO withResourceContext:resourceContext];
        photo.descr = @"test photo";
        photo.imageurl = fullPath;
        photo.thumbnailurl = fullPath;
        photo.numberofvotes = [NSNumber numberWithInt:0];
        photo.creatorid = context.userid;
        photo.themeid = [NSNumber numberWithLongLong:634535212720410463];
        
    
    [resourceContext save:YES onFinishCallback:nil];

}



- (IBAction) commitChanges:(id)sender {
    [self test_enumeratePages];
//    ResourceContext* resourceContext = [ResourceContext instance];
//    NSNumber* themeid = [NSNumber numberWithLongLong:634535212720410463];
//    
//          
//       
//    
//    CloudEnumerator* enumeratorForPhotos = [CloudEnumerator enumeratorForPhotos:themeid];
//    [enumeratorForPhotos enumerateUntilEnd];
    
//    
//    NSString* attributeName = @"thumbnailurl";
//    NSString* attributeValue = self.attributeValue.text;
//    NSString* objectid = @"122604833";
//    NSString* objecttype = @"user";
//    
//    
//    ImageManager* imageManager= [ImageManager getInstance];
//    NSURL* url = [NSURL URLWithString:@"http://www.oscial.com/wp-content/uploads/2011/10/Gadaffi-fist-pump.jpg"];
//    
//    NSData* data = [NSData dataWithContentsOfURL:url]   ; 
//    UIImage* image = [UIImage imageWithData:data];
//    NSNumber* file = [NSNumber numberWithLongLong:[[NSDate date]timeIntervalSince1970]];
//    NSString* fileName = [NSString stringWithFormat:@"%@.jpg",file];
//    
//    NSString* fullPath = [imageManager saveImage:image withFileName:fileName];
//    AuthenticationContext* context = [self.authenticationManager contextForLoggedInUser];
//    
//    Photo* photo = [Resource createInstanceOfType:PHOTO withResourceContext:resourceContext];
//    photo.descr = @"test photo";
//    photo.imageurl = @"testiomageurl";
//    photo.thumbnailurl = fullPath;
//    photo.numberofvotes = [NSNumber numberWithInt:0];
//    photo.creatorid = context.userid;
//    photo.themeid = [NSNumber numberWithLongLong:634535212720410463];
//    
//    
//    
//    
//    Resource* resource = [resourceContext resourceWithType:objecttype   withID:objectid];
//    
//    
//    
//    SEL selector = NSSelectorFromString(attributeName);
//    [resource setValue:fullPath forKey:attributeName];
//    
//   [resourceContext save:YES onFinishCallback:nil];
    
    
    
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}
@end
