//
//  UIProductionLogTableViewCell.m
//  Platform
//
//  Created by Jordan Gurrieri on 11/17/11.
//  Copyright (c) 2011 Blue Label Solutions LLC. All rights reserved.
//

#import "UIProductionLogTableViewCell.h"
#import "Page.h"
#import "Photo.h"
#import "ImageManager.h"
#import "ImageDownloadResponse.h"
#import "CallbackResult.h"
#import "Types.h"
#import "Macros.h"

#define kPAGEID @"pageid"
#define kPHOTOID    @"photoid"
@implementation UIProductionLogTableViewCell
@synthesize pageID = m_pageID;
@synthesize productionLogTableViewCell = m_productionLogTableViewCell;
@synthesize iv_photo = m_iv_photo;
@synthesize lbl_draftTitle = m_lbl_draftTitle;
@synthesize lbl_deadline = m_lbl_deadline;
@synthesize lbl_numPhotos = m_lbl_numPhotos;
@synthesize lbl_numCaptions = m_lbl_numCaptions;
@synthesize frc_photo = m_frc_photo;
@synthesize topVotedPhotoID = m_topVotedPhotoID;

#pragma mark - Instance Methods
//- (NSFetchedResultsController*) new_frc_photo {
//    NSString* activityName = @"UIProductionLogTableViewCell.new_frc_photo:";
//    
//    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
//    ResourceContext* resourceContext = [ResourceContext instance];
//    
//    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:PHOTO inManagedObjectContext:resourceContext.managedObjectContext];
//    
//    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"%K=%d",THEMEID, self.pageID];
//    NSSortDescriptor* sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:NUMBEROFVOTES ascending:NO];
//    
//    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
//    [fetchRequest setPredicate:predicate];
//    [fetchRequest setEntity:entityDescription];
//    [fetchRequest setFetchBatchSize:20];
//    
//    NSFetchedResultsController* controller = [[NSFetchedResultsController alloc]initWithFetchRequest:fetchRequest managedObjectContext:resourceContext.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
//    
//    controller.delegate = self;
//       
//    
//    NSError* error = nil;
//    [controller performFetch:&error];
//  	if (error != nil)
//    {
//        LOG_UIPRODUCTIONLOGTABLEVIEWCELL(1, @"%@Could not create instance of NSFetchedResultsController due to %@",activityName,[error userInfo]);
//    }
//    
//  
//    [fetchRequest release];
//    
//    return controller;
//    
//}

- (void) dealloc {
    [self.frc_photo release];
}

- (void) renderPhoto:(Photo*)photo {
    
    ImageManager* imageManager = [ImageManager instance];
    NSMutableDictionary* userInfo = [NSMutableDictionary dictionaryWithObject:self.pageID forKey:kPAGEID];
    
    //add the photo id to the context
    [userInfo setValue:photo.objectid forKey:kPHOTOID];
    if (photo.thumbnailurl != nil && 
        ![photo.thumbnailurl isEqualToString:@""]) 
    {
        Callback* callback = [[Callback alloc]initWithTarget:self withSelector:@selector(onImageDownloadComplete:) withContext:userInfo];
        UIImage* image = [imageManager downloadImage:photo.thumbnailurl withUserInfo:nil atCallback:callback];
        
        if (image != nil) {
            self.iv_photo.contentMode = UIViewContentModeScaleAspectFit;
            self.iv_photo.image = image;
        }
    }
    [self setNeedsDisplay];
}
- (void) render {
    ResourceContext* resourceContext = [ResourceContext instance];
    
    Page* draft = (Page*)[resourceContext resourceWithType:PAGE withID:self.pageID];
    
    if (draft != nil) {
        self.lbl_draftTitle.text = draft.displayname;
        self.lbl_numPhotos.text = [draft.numberofphotos stringValue];
        self.lbl_numCaptions.text = [draft.numberofcaptions stringValue];
        self.iv_photo.image = nil;
        
        Photo* topPhoto = [draft photoWithHighestVotes];
        self.topVotedPhotoID = topPhoto.objectid;
        [self renderPhoto:topPhoto];
    
    }
    [self setNeedsDisplay];
}

- (void) renderDraftWithID:(NSNumber*)pageID {
    self.pageID = pageID;
    
    //if we change the page id, we need to nil the fetched results controller
//    [self.frc_photo release];
//    self.frc_photo = [self new_frc_photo];
    
    //we also need to nil the topVotedPhotoID
    self.topVotedPhotoID = nil;
    [self render];
}


#pragma mark - Initialization
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        NSArray* topLevelObjs = nil;
        
        topLevelObjs = [[NSBundle mainBundle] loadNibNamed:@"UIProductionLogTableViewCell" owner:self options:nil];
        self.topVotedPhotoID = nil;
        if (topLevelObjs == nil)
        {
            NSLog(@"Error! Could not load UIProductionLogTableViewCell file.\n");
        }
        
        [self.contentView addSubview:self.productionLogTableViewCell];
        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - NSFetchedResultsControllerDelegate

#pragma mark - Async callbacks
- (void)onImageDownloadComplete:(CallbackResult*)result {
    NSString* activityName = @"UIProductionLogTableViewCell.onImageDownloadComplete:";
    NSDictionary* userInfo = result.context;
    NSNumber* draftID = [userInfo valueForKey:kPAGEID];
    NSNumber* photoID = [userInfo valueForKey:kPHOTOID];
    
    ImageDownloadResponse* response = (ImageDownloadResponse*)result.response;
    
    if ([response.didSucceed boolValue] == YES) {
        if ([draftID isEqualToNumber:self.pageID] &&
            [photoID isEqualToNumber:self.topVotedPhotoID]) {
            
            //we only draw the image if this view hasnt been repurposed for another draft
            LOG_IMAGE(1,@"%@settings UIImage object equal to downloaded response",activityName);
            [self.iv_photo performSelectorOnMainThread:@selector(setImage:) withObject:response.image waitUntilDone:NO];
            self.iv_photo.contentMode = UIViewContentModeScaleAspectFit;
            [self setNeedsDisplay];
        }
    }
    else {
        self.iv_photo.backgroundColor = [UIColor redColor];
        LOG_IMAGE(1,@"%@Image failed to download",activityName);
    }
    
}

#pragma mark - Statics
+ (NSString*) cellIdentifier {
    return @"productionlogcell";
}


@end
