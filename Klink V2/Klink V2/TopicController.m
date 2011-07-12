//
//  TopicController.m
//  Test Project 2
//
//  Created by Bobby Gill on 6/23/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import "TopicController.h"


@implementation TopicController
@synthesize topic;
@synthesize tbl_thought;
@synthesize fetchedResultsController=__fetchedResultsController;
@synthesize managedObjectContext=__managedObjectContext;
@synthesize lbl_topicTitle;
@synthesize bottom_toolbar;
@synthesize btn_Picture;
@synthesize btn_Refresh;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil withTopic:(Photo*)existingTopic
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.topic = existingTopic;
               
        UIBarButtonItem* addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(onAddClick:)];
        self.navigationItem.rightBarButtonItem = addButton;
        
                
        
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
  
    
    if (self.topic != nil) {
        
        self.navigationItem.title = self.topic.descr;

        //set the title of the navigation controller
        NSArray *arr = [[NSBundle mainBundle] loadNibNamed:@"TitleView" owner:nil options:nil];
        TitleView *titleView = [arr objectAtIndex:0];        
        self.navigationItem.titleView = titleView;
        [self updateNavigationItemTitle];
        
        self.lbl_topicTitle.text = self.topic.descr;
        
       
      
        
    
    }
    
    self.btn_Refresh.target = self;
    self.btn_Refresh.action = @selector(onRefreshClick:);
    
    //add the camera button actions
    self.btn_Picture.target = self;
    self.btn_Picture.action = @selector(onPictureClick:);
    
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)updateNavigationItemTitle {
    TitleView *titleView = (TitleView*)self.navigationItem.titleView;
    if (titleView != nil) {
        titleView.titleLabel.text = self.topic.descr;
        titleView.subtitleLabel.text = [DateTimeHelper formatShortDate:self.topic.datecreated];
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
    return YES;
}

#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController
{
    if (__fetchedResultsController != nil)
    {
        return __fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    Klink_V2AppDelegate *appDelegate = (Klink_V2AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *appContext = appDelegate.managedObjectContext;         
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:CAPTION inManagedObjectContext:appContext];
    [fetchRequest setEntity:entity];
    
    [fetchRequest setFetchBatchSize:batchSize_CAPTION];
    
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat: @"%K=%@",an_PHOTOID, self.topic.objectid];    
    [fetchRequest setPredicate:predicate];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:an_DATECREATED ascending:NO];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
     
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:appContext sectionNameKeyPath:nil cacheName:nil];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
     
    [aFetchedResultsController release];
    [fetchRequest release];
    [sortDescriptor release];
    [sortDescriptors release];
   
	NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error])
    {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
    
    return __fetchedResultsController;
}   
#pragma mark - Fetched results controller delegate
- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tbl_thought beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch (type) {
        case NSFetchedResultsChangeInsert:
            [self.tbl_thought insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
    
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    UITableView *tableView = self.tbl_thought;
    
    switch(type)
    {
            
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tbl_thought endUpdates];
}


#pragma mark - UITableViewDelegate methods

// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger count = [[self.fetchedResultsController sections]count];
    return count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    NSInteger count = [sectionInfo numberOfObjects];
    return count;
}

- (NSString*) tableView:(UITableView*)tableView titleForHeaderInSection:(NSInteger)section {
    return [[[self.fetchedResultsController sections] objectAtIndex:section]name];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    Caption* thoughtObject = (Caption*)[self.fetchedResultsController objectAtIndexPath:indexPath];
    if ([thoughtObject isTextCaption]) {
          return 70;
    }
    else {
        return 209;
    }
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Caption *thoughtObject = (Caption*)[self.fetchedResultsController objectAtIndexPath:indexPath];       
    NSString* cellIdentifier = nil;
    
    if ([thoughtObject isTextCaption]) {
        cellIdentifier = cell_TEXTCAPTION;     
    }
    else {
        cellIdentifier = cell_IMAGECAPTION;
    }
    
    UITableViewCell *cell =[tableView dequeueReusableCellWithIdentifier:cellIdentifier]; 
    
    
    if (cell == nil) {
        if ([thoughtObject isTextCaption]) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier]autorelease];
        }
        else {            
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"PhotoNoteCell"
                                                         owner:self options:nil];
            cell = [nib objectAtIndex:0];
        }
    }
    
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}


- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{    
    Caption *thoughtObject = (Caption*)[self.fetchedResultsController objectAtIndexPath:indexPath];       
    
    if (![thoughtObject isTextCaption]) {
        ImageManager* imageManager = [ImageManager getInstance];
        NSMutableDictionary* userInfo = [NSMutableDictionary dictionaryWithObject:indexPath forKey:an_INDEXPATH];
        PhotoNoteCell* photoCell = (PhotoNoteCell*)cell;       
        
        UIImage* image = [imageManager downloadImage:thoughtObject.imageurl withUserInfo:userInfo atCallback:self];
        photoCell.lbl_Title.text = thoughtObject.title;
        photoCell.lbl_Subtitle.text = [DateTimeHelper formatDateForWebService:thoughtObject.datecreated];
        
        if (image != nil) {
            [photoCell.img_Image setImage:image];
        }
    }
    else {
        UIImage *image = [UIImage imageNamed:@"star.png"];
        cell.imageView.image = image;
        cell.textLabel.text = thoughtObject.title;
        cell.detailTextLabel.text =[DateTimeHelper formatDateForWebService:thoughtObject.datecreated];
        

    }
    
     
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
    
//        [self.tbl_thought deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
//        
        ServerManagedResource* resource = [self.fetchedResultsController objectAtIndexPath:indexPath];
        NSNumber *objectID = [NSNumber numberWithLongLong:[resource.objectid longLongValue]];
        NSString* objectType = [NSString stringWithString:resource.objecttype];
        [resource deleteFromDatabase];
        //delete the data from the database
       
        //now we need to delete it from the local data store
        WS_TransferManager* transferManager = [WS_TransferManager getInstance];
        [transferManager deleteObjectInCloud:objectID withObjectType:objectType];
    }
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // The table view should not be re-orderable.
    return NO;
}

#pragma mark - action event handlers

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Caption* thought = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [self onThoughtClick:thought];
}

- (void)onThoughtClick:(Caption*)thought {
    NSString *activityName = @"TopicController.onThoughtClick:";
    
    //determine if its is a picture or a note, and launch appropriate controller
    if ([thought isTextCaption]) {
        //text
        NoteController *noteController = [[NoteController alloc]initWithNibName:@"NoteController" bundle:nil withTopic:self.topic withThought:thought];
        
        
        NSString* message = [NSString stringWithFormat:@"Existing thought with id %@ clicked, launching note controller",thought.objectid];
        [BLLog v:activityName withMessage:message];
        
        [self.navigationController pushViewController:noteController animated:YES];
        [noteController release];
    }
    else {
        //image
        CameraViewController* cameraViewController = [[CameraViewController alloc] initWithNibName:@"CameraViewController" bundle:nil withTopic:self.topic withThought:thought];
        
        NSString* message = [NSString stringWithFormat:@"Existing thought with id %@ clicked, launching photo view controller",thought.objectid];
        [BLLog v:activityName withMessage:message];
        
        [self.navigationController pushViewController:cameraViewController animated:YES];
        [cameraViewController release];

    }
   
}

-(void)onPictureClick:(id)sender {
    CameraViewController *cameraController = [[CameraViewController alloc]initWithNibName:@"CameraViewController" bundle:nil withTopic:self.topic withThought:nil];
    
    [self.navigationController pushViewController:cameraController animated:YES];
    [cameraController release];
}

-(void)onAddClick:(id)sender{
   // create a new caption object and add it to the list
    NSString *activityName = @"TopicController.onThoughtClick:";
    NoteController *noteController = [[NoteController alloc]initWithNibName:@"NoteController" bundle:nil withTopic:self.topic withThought:nil];
    
    
    NSString* message = [NSString stringWithFormat:@"Add new thought clicked, launching note controller"];
    [BLLog v:activityName withMessage:message];
    
    [self.navigationController pushViewController:noteController animated:YES];
    [noteController release];
}

-(void)onSaveClick:(id)sender {
    
}

-(void)onRefreshClick:(id)sender {
    //need to go out and refresh this object, and download any missing thoughts
    WS_EnumerationManager* enumerationManager = [WS_EnumerationManager getInstance];
    QueryOptions* queryoptions = [QueryOptions queryForTopics];
    [enumerationManager enumerateObjectsWithIds:[NSArray arrayWithObject:self.topic.objectid] withQueryOptions:queryoptions onFinishNotify:nil];
}

#pragma mark - UITextField Action Responders

-(IBAction)textFieldReturn:(id)sender {
    
    [sender resignFirstResponder];
    
    
}

-(IBAction)backgroundTouched:(id)sender {
    
    [sender resignFirstResponder];
}

#pragma mark - UITextFieldDelegate Handlers
- (void)textFieldDidEndEditing:(UITextField *)textField {
    //need to update the data in the database and server
    if (textField == self.lbl_topicTitle) {
        if (![textField.text isEqual:self.topic.descr]) {
            self.topic.descr = textField.text;
            [self.topic commitChangesToDatabase:YES withPendingFlag:YES];
            [self updateNavigationItemTitle];
        }
        UIBarButtonItem* addButton = self.navigationItem.rightBarButtonItem;
        addButton.enabled = YES;
    }
}

-(void)textFieldDidBeginEditing:(UITextField *)textField {
    if (textField == self.lbl_topicTitle) {
        //need to hide the navigation items
        UIBarButtonItem* addButton = self.navigationItem.rightBarButtonItem;
        addButton.enabled = NO;
    }
}

#pragma mark - ImageDownloadProtocol Members
-(void)onImageDownload:(UIImage*)image withUserInfo:(NSDictionary*)userInfo {
    NSString* activityName = @"TopicController.onImageDownload:";
    NSIndexPath* indexPath = [userInfo valueForKey:an_INDEXPATH];
    [tbl_thought reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
//    
//    
//    
//    UITableViewCell* cell = [self.tbl_thought cellForRowAtIndexPath:[userInfo valueForKey:an_INDEXPATH]];
//     PhotoNoteCell* photoNoteCell = (PhotoNoteCell*)cell;
//    if (photoNoteCell != nil)
//    {
//       
//        [photoNoteCell.img_Image setImage:image];
//    }
//    else {
//        NSString* message = [NSString stringWithFormat:@"No suitable photo view cell found at returned indexpath"];
//        [BLLog e:activityName withMessage:message];
//    }
}





@end
