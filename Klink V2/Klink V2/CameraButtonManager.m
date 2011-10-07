//
//  CameraButtonManager.m
//  Klink V2
//
//  Created by Jordan Gurrieri on 9/3/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import "CameraButtonManager.h"
#import "User.h"
#import "Photo.h"
#import "ImageManager.h"
#import "NSStringGUIDCategory.h"
#import "LoginViewController.h"
#import <MobileCoreServices/UTCoreTypes.h>


#define kScale 2

#define kPictureWidth 120
#define kPictureHeight 120
#define kPictureWidth_landscape 120
#define kPictureHeight_landscape 120

#define kThumbnailPortraitWidth 120
#define kThumbnailPortraitHeight 160
#define kThumbnailLandscapeWidth 160
#define kThumbnailLandscapeHeight 120
#define kFullscreenPortraitWidth 320
#define kFullscreenPortraitHeight 480
#define kFullscreenLandscapeWidth 480
#define kFullscreenLandscapeHeight 320

@interface CameraButtonManager ()
static UIImage* shrinkImage(UIImage* original, CGSize size);
- (void)getMediaFromSource:(UIImagePickerControllerSourceType)sourceType ;
@end


@implementation CameraButtonManager

@synthesize viewController;


static CameraButtonManager* sharedManager;

#pragma mark - Initializers / Singleton Accessors
+ (CameraButtonManager*) getInstanceWithViewController:(id)callingViewController{
  
    @synchronized(self)
    {
        if (!sharedManager) {
            sharedManager = [[super allocWithZone:NULL]init];
        } 
       // [BLLog v:activityName withMessage:@"completed initialization"];
        sharedManager.viewController = callingViewController;
     
        return sharedManager;
    }
}

- (id) init {
    return self;
}

- (id) initWithTheme:(Theme*)currentTheme withViewController:(KlinkBaseViewController*)callingViewController {
    viewController = callingViewController;
    return self;
}


#pragma mark - Dealloc
- (void)dealloc
{
        [viewController release];
    [super dealloc];
}


#pragma mark -
#pragma mark CameraButton methods
- (void)cameraButtonPressed:(id)sender {
    AuthenticationManager* authenticationManager = [AuthenticationManager getInstance];
    AuthenticationContext* currentContext = [authenticationManager getAuthenticationContext];
    
    if (currentContext == nil) {
        LoginViewController* loginController = [[LoginViewController controllerForFacebookLogin:self onFinishPerform:@selector(cameraButtonPressed:)]retain];
        loginController.modalPresentationStyle = UIModalPresentationCurrentContext;
        
        [self.viewController presentModalViewController:loginController animated:YES];
        
    }
    else {
        UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                      initWithTitle:nil
                                      delegate:self
                                      cancelButtonTitle:@"Cancel"
                                      destructiveButtonTitle:@"Take Photo"
                                      otherButtonTitles:@"Choose Existing", nil];
        [actionSheet showInView:viewController.view];
        [actionSheet release];
    }
}


#pragma mark ActionSheet delegate methods
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex != [actionSheet cancelButtonIndex]) {
        if (buttonIndex == 0) {
            [self getMediaFromSource:UIImagePickerControllerSourceTypeCamera];
        } else {
            [self getMediaFromSource:UIImagePickerControllerSourceTypePhotoLibrary];
        }
    }
}


- (void)getMediaFromSource:(UIImagePickerControllerSourceType)sourceType {
    NSArray *mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:sourceType];
    if ([UIImagePickerController isSourceTypeAvailable:sourceType] && [mediaTypes count] > 0) {
        NSArray *mediaTypes = [NSArray arrayWithObject:(NSString *)kUTTypeImage];
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.mediaTypes = mediaTypes;
        picker.delegate = self;
        picker.allowsEditing = NO;
        picker.sourceType = sourceType;
        
        if (sourceType == UIImagePickerControllerSourceTypeCamera) {
            picker.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
        }
        
        [viewController presentModalViewController:picker animated:YES];
        [picker release];
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc] 
                              initWithTitle:@"Error accessing media" 
                              message:@"Device doesn't support that media source." 
                              delegate:nil 
                              cancelButtonTitle:@"Cancel"
                              otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
}


#pragma mark -
#pragma mark UIImagePickerController delegate methods
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissModalViewControllerAnimated:YES];
}

- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    // Begin creation of the thumbnail and fullscreen photos
    UIImage* chosenImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    //UIImage *chosenImage = [info objectForKey:UIImagePickerControllerEditedImage];    //can be used if we want a standard sized square-shaped cropped image
    
    CGSize chosenImageSize = chosenImage.size;
    CGSize newThumbnailSize;
    CGSize newFullscreenSize;
    CGRect thumbnailCropRect;
    
    if (chosenImageSize.height > chosenImageSize.width) {
        // Create UIImage frame for image in portrait - fill width
        newThumbnailSize = CGSizeMake(kThumbnailPortraitWidth, ((chosenImageSize.height*kThumbnailPortraitWidth)/chosenImageSize.width));
        newFullscreenSize = CGSizeMake(kFullscreenPortraitWidth, ((chosenImageSize.height*kFullscreenPortraitWidth)/chosenImageSize.width));
    }
    else if (chosenImageSize.height < chosenImageSize.width) {
        // Create UIImage frame for image in landscape - fill height
        newThumbnailSize = CGSizeMake(((chosenImageSize.width*kThumbnailLandscapeHeight)/chosenImageSize.height), kThumbnailLandscapeHeight);
        newFullscreenSize = CGSizeMake(((chosenImageSize.width*kFullscreenLandscapeHeight)/chosenImageSize.height), kFullscreenLandscapeHeight);
    }
    else {
        // Create UIImage frame for image in portrait but maximize image scaling to fill height for thumbnail and width for fullscreen
        newThumbnailSize = CGSizeMake(kThumbnailPortraitHeight, kThumbnailPortraitHeight);
        newFullscreenSize = CGSizeMake(kFullscreenPortraitWidth, kFullscreenPortraitWidth);
    }
    
    // Make thumbnail image
    UIImage* thumbnailImage = shrinkImage(chosenImage, newThumbnailSize);
    
    // Crop the new shrunken thumbnail image to the fit the target frame size
    CGSize thumbnailImageSize = thumbnailImage.size;
    thumbnailCropRect = CGRectMake((thumbnailImageSize.width - (kPictureWidth * kScale))/2, (thumbnailImageSize.height - (kPictureHeight * kScale))/2, kPictureWidth * kScale, kPictureHeight * kScale);
    CGImageRef croppedThumbnailImage = CGImageCreateWithImageInRect([thumbnailImage CGImage], thumbnailCropRect);
    thumbnailImage = [UIImage imageWithCGImage:croppedThumbnailImage];
    
    //CGSize croppedThumbnailImageSize = thumbnailImage.size;
    
    // Make fullscreen image
    UIImage* fullscreenImage = shrinkImage(chosenImage, newFullscreenSize);
    
    
    // Initialize the new Photo object
    Klink_V2AppDelegate *appDelegate = (Klink_V2AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *appContext = appDelegate.managedObjectContext;
    User* user = [User getUserForId:[[AuthenticationManager getInstance]getLoggedInUserID]];
    
    NSString* thumbnailPath = nil;
    NSString* fullscreenPath = nil;
    
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:PHOTO inManagedObjectContext:appContext];
    Photo* newPhoto = [[Photo alloc]initWithEntity:entityDescription insertIntoManagedObjectContext:appContext];
    [newPhoto init];
    newPhoto.themeid = self.viewController.currentTheme.objectid;
    newPhoto.creatorid = [[AuthenticationManager getInstance]getLoggedInUserID];
    newPhoto.creatorname = user.username;
    newPhoto.descr = [NSString stringWithFormat:@"By %@ on %@", user.username, [DateTimeHelper formatShortDate:[NSDate date]]];
    
    
    ImageManager* imageManager = [ImageManager getInstance];
    
    // Save thumbnail image
    NSString* thumbnailFileName = [NSString stringWithFormat:@"%@%@", [newPhoto.objectid stringValue], @"-tb"];
    thumbnailPath = [imageManager saveImage:thumbnailImage withFileName:thumbnailFileName];
    
    // Save fullscreen image
    NSString* fullscreenFileName = [NSString stringWithFormat:@"%@%@", [newPhoto.objectid stringValue], @"-fs"];
    fullscreenPath = [imageManager saveImage:fullscreenImage withFileName:fullscreenFileName];
    
    
    newPhoto.thumbnailurl = thumbnailPath;
    newPhoto.imageurl = fullscreenPath;   
    
    [newPhoto commitChangesToDatabase:NO withPendingFlag:YES];
    //now we need to upload this to the cloud. as they say in Redmond. to the cloud...
    UIProgressView* progressView = [[UIProgressView alloc]initWithProgressViewStyle:UIProgressViewStyleBar];
    viewController.navigationController.navigationItem.titleView = progressView;
    
    WS_TransferManager* transferManager = [WS_TransferManager getInstance];
    Attachment* thumbnailAttachment = [Attachment attachmentWith:newPhoto.objectid objectType:PHOTO forAttribute:an_THUMBNAILURL atFileLocation:newPhoto.thumbnailurl];
    Attachment* fullscreenAttachment = [Attachment attachmentWith:newPhoto.objectid objectType:PHOTO forAttribute:an_IMAGEURL atFileLocation:newPhoto.imageurl];
    NSArray* attachments = [NSArray arrayWithObjects:thumbnailAttachment,fullscreenAttachment, nil];
    
    //We register a notification receiver to listen in for the completion of the uploads
    NSString* notificationID = [NSString GetGUID];
    NSNotificationCenter* notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self selector:@selector(onPhotoWithAttachmentsUploadFinished:) name:notificationID object:nil];
    
    [transferManager createObjectsInCloud:[NSArray arrayWithObject:newPhoto.objectid] withObjectTypes:[NSArray arrayWithObject:PHOTO] withAttachments:attachments onFinishNotify:notificationID];
    
    
    //we notify any recipients of the starting of the photo upload
    NSDictionary* userInfo = [NSDictionary dictionaryWithObject:newPhoto.objectid forKey:an_OBJECTID];
    [notificationCenter postNotificationName:n_PHOTO_UPLOAD_START object:self userInfo:userInfo];
    
    //we also make the call on the held instance since the Notification may not receive a view controller
    //which has gone to sleep
    [self.viewController onPhotoUploadStart:newPhoto];
    
    CGImageRelease(croppedThumbnailImage);
    
    [picker dismissModalViewControllerAnimated:YES];
}


//This method will be called each time an object finished upload, as well as each time an attachment was uploaded
//Hence this is called on each successful upload, and is not batched or atomic across all uploaded objects
- (void) onPhotoWithAttachmentsUploadFinished:(NSNotification*)notification {
    NSString* activityName = @"ThemeBrowserViewController2.onPhotoWithAttachmentsUploadFinished:";
    
    NSDictionary* userInfo = [[notification userInfo]retain];
    
    if ([userInfo objectForKey:an_OBJECTTYPE]!= [NSNull null]) {
        NSString* objectType = [userInfo objectForKey:an_OBJECTTYPE];
        NSNumber* objectID = [userInfo objectForKey:an_OBJECTID];
        
        NSString* message = [NSString stringWithFormat:@"Object Type: %@ with Object ID: %@ completed upload",objectType,objectID];
        [BLLog v:activityName withMessage:message];
        
        //we need to mark the object as not being Pending if it is a Photo
        if ([objectType isEqualToString:PHOTO]) {
            Photo* photo = [DataLayer getObjectByType:PHOTO withId:objectID];
            photo.isPending = [NSNumber numberWithBool:NO];
            
            //we mark the object as being no longer pending.
            [photo commitChangesToDatabase:NO withPendingFlag:NO];
            
            //lets also call the view controller to identify that it is done
            NSDictionary* newUserInfo = [NSDictionary dictionaryWithObject:photo.objectid forKey:an_OBJECTID];
            NSNotificationCenter* notificationCenter = [NSNotificationCenter defaultCenter];
            [notificationCenter postNotificationName:n_PHOTO_UPLOAD_COMPLETE object:self userInfo:newUserInfo];
        }
        
        
    }
    
    
}


#pragma mark - Shrink Image functions
static inline double radians (double degrees) {
    return degrees * M_PI/180;
}

static UIImage *shrinkImage(UIImage *original, CGSize size) {
    
    //CGFloat scale = [UIScreen mainScreen].scale;
    CGFloat scale = kScale;
    
    CGFloat targetWidth = size.width * scale;
    CGFloat targetHeight = size.height * scale;
    CGImageRef imageRef = [original CGImage];
    
    CGBitmapInfo bitmapInfo = CGImageGetBitmapInfo(imageRef);
    CGColorSpaceRef colorSpaceInfo = CGColorSpaceCreateDeviceRGB();
    
    if (bitmapInfo == kCGImageAlphaNone) {
        bitmapInfo = kCGImageAlphaNoneSkipLast;
    }
    
    CGContextRef context;
    
    // For images taken in portrait mode (the right or left cases), we need to switch targetWidth and targetHeight when building the CG context
    //if (original.imageOrientation == UIImageOrientationUp || original.imageOrientation == UIImageOrientationDown) {
    //if (original.imageOrientation == UIImageOrientationLeft || original.imageOrientation == UIImageOrientationRight) {
    context = CGBitmapContextCreate(NULL, targetWidth, targetHeight, CGImageGetBitsPerComponent(imageRef), CGImageGetBytesPerRow(imageRef), colorSpaceInfo, bitmapInfo);
    //} else {
    //    context = CGBitmapContextCreate(NULL, targetHeight, targetWidth, CGImageGetBitsPerComponent(imageRef), CGImageGetBytesPerRow(imageRef), colorSpaceInfo, bitmapInfo);
    //}
    
    
    // We need to rotate the CG context before drawing the image.
    // In the right or left cases, we need to switch targetWidth and targetHeight, and also the origin point
    if (original.imageOrientation == UIImageOrientationLeft) {
        CGContextRotateCTM (context, radians(90));
        CGContextTranslateCTM (context, 0, -targetWidth);
    } else if (original.imageOrientation == UIImageOrientationRight) {
        CGContextRotateCTM (context, radians(-90));
        CGContextTranslateCTM (context, -targetHeight, 0);
    } else if (original.imageOrientation == UIImageOrientationUp) {
        // NOTHING
    } else if (original.imageOrientation == UIImageOrientationDown) {
        CGContextTranslateCTM (context, targetWidth, targetHeight);
        CGContextRotateCTM (context, radians(-180));
    }
    
    // For images to be presented in portrait mode (the right or left cases), we need to switch targetWidth and targetHeight when drawing the new image
    if (original.imageOrientation == UIImageOrientationUp || original.imageOrientation == UIImageOrientationDown) {
        //if (original.imageOrientation == UIImageOrientationLeft || original.imageOrientation == UIImageOrientationRight) {
        CGContextDrawImage(context, CGRectMake(0, 0, targetWidth, targetHeight), imageRef);
        
    } else {
        CGContextDrawImage(context, CGRectMake(0, 0, targetHeight, targetWidth), imageRef);
    }
    
    
    CGImageRef shrunken = CGBitmapContextCreateImage(context);
    
    //UIImage *shrunkenImage = [UIImage imageWithCGImage:shrunken scale:original.scale orientation:original.imageOrientation];
    UIImage* shrunkenImage = [UIImage imageWithCGImage:shrunken];
    
    //CGSize shrunkenImageSize = shrunkenImage.size;
    
    CGContextRelease(context);
    CGImageRelease(shrunken);
    
    return shrunkenImage;
}


@end
