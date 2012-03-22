//
//  UICameraActionSheet.m
//  Platform
//
//  Created by Bobby Gill on 11/6/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import "UICameraActionSheet.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import "ImageManager.h"
#import "Photo.h"
#import "ResourceContext.h"
#import "AuthenticationManager.h"
#import "User.h"
#import "Types.h"
#import "Attributes.h"
#import "Macros.h"

#define kThumbnailWidth 75
#define kThumbnailHeight 75

#define kThumbnailPortraitWidth 75
#define kThumbnailPortraitHeight 100
#define kThumbnailLandscapeWidth 100
#define kThumbnailLandscapeHeight 75
#define kFullscreenPortraitWidth 320
#define kFullscreenPortraitHeight 480
#define kFullscreenLandscapeWidth 480
#define kFullscreenLandscapeHeight 320

#define kScale 2

@implementation UICameraActionSheet
@synthesize a_delegate = m_delegate;
@synthesize allowsEditing = m_allowsEditing;
@synthesize picker = m_picker;

- (id) initWithTitle:(NSString *)title delegate:(id<UIActionSheetDelegate>)delegate cancelButtonTitle:(NSString *)cancelButtonTitle destructiveButtonTitle:(NSString *)destructiveButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ... {
    
    self = [super initWithTitle:title delegate:delegate cancelButtonTitle:cancelButtonTitle destructiveButtonTitle:destructiveButtonTitle otherButtonTitles:otherButtonTitles, nil];
    
    if (self) {
        
    }
    return self;
}


#pragma mark - Instance Methods
- (void)getMediaFromSource:(UIImagePickerControllerSourceType)sourceType 
{
    NSArray *mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:sourceType];
    
    if ([UIImagePickerController isSourceTypeAvailable:sourceType] && [mediaTypes count] > 0) 
    {
        NSArray *mediaTypes = [NSArray arrayWithObject:(NSString *)kUTTypeImage];
        //UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        self.picker = [[[UIImagePickerController alloc] init] autorelease];
        self.picker.mediaTypes = mediaTypes;
        self.picker.delegate = self;
        self.picker.allowsEditing = self.allowsEditing;
        self.picker.sourceType = sourceType;
        
        if (sourceType == UIImagePickerControllerSourceTypeCamera) {
            self.picker.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
            self.picker.cameraFlashMode = UIImagePickerControllerCameraFlashModeOff;
        }
        id<UICameraActionSheetDelegate> del = (id<UICameraActionSheetDelegate>)self.a_delegate;

        [del displayPicker:self.picker];
       
        //[picker release];
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



#pragma mark - UIActionSheet Delegate
- (void)actionSheet:(UIActionSheet *)actionSheet 
    didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex != [actionSheet cancelButtonIndex]) {
        // make sure the status bar is visible for the picker to control it
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
        
        if (buttonIndex == 0) {
            [self getMediaFromSource:UIImagePickerControllerSourceTypeCamera];
        } else {
            [self getMediaFromSource:UIImagePickerControllerSourceTypePhotoLibrary];
        }
    }
    else {
        id<UICameraActionSheetDelegate> del = (id<UICameraActionSheetDelegate>)self.a_delegate;
        [del onCancel];
    }
}

#pragma mark - UIImagePickerController delegate methods
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    self.picker = picker;
    [self.picker dismissModalViewControllerAnimated:YES];
}

#pragma mark - UINavigationControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    self.picker = picker;
    
    // Begin creation of the thumbnail and fullscreen photos
    UIImage* chosenImage;
    if (self.allowsEditing == YES) {
        chosenImage = [info objectForKey:UIImagePickerControllerEditedImage];
    }
    else {
        chosenImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    }
    
    CGFloat scale = kScale;
    
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
    
    ImageManager* imageManager = [ImageManager instance];
    
    // Make new fullscreen image if the original is larger than the size we want
    UIImage* fullscreenImage;
    if (chosenImageSize.width > newFullscreenSize.width*scale && chosenImageSize.height > newFullscreenSize.height*scale) {
        fullscreenImage = [imageManager shrinkImage:chosenImage toSize:newFullscreenSize];
    }
    else {
        fullscreenImage = chosenImage;
    }
    
    // Make thumbnail image if the original is larger than the size we want
    UIImage* thumbnailImage;
    if (chosenImageSize.width > newThumbnailSize.width*scale && chosenImageSize.height > newThumbnailSize.height*scale) {
        thumbnailImage = [imageManager shrinkImage:chosenImage toSize:newThumbnailSize];
    }
    else {
        thumbnailImage = chosenImage;
    }
    
    
    // Crop the new shrunken thumbnail image to the fit the target frame size
    CGSize thumbnailImageSize = thumbnailImage.size;
    thumbnailCropRect = CGRectMake((thumbnailImageSize.width - (kThumbnailWidth * kScale))/2, (thumbnailImageSize.height - (kThumbnailHeight * kScale))/2, kThumbnailWidth * kScale, kThumbnailHeight * kScale);
    CGImageRef croppedThumbnailImage = CGImageCreateWithImageInRect([thumbnailImage CGImage], thumbnailCropRect);
    thumbnailImage = [UIImage imageWithCGImage:croppedThumbnailImage];
    
    id<UICameraActionSheetDelegate> del = (id<UICameraActionSheetDelegate>)self.a_delegate;
    
    CGImageRelease(croppedThumbnailImage);
    
    [del onPhotoTakenWithThumbnailImage:thumbnailImage withFullImage:fullscreenImage];
    
    [self.picker dismissModalViewControllerAnimated:YES];
}

#pragma mark - Static Initializers
+ (UICameraActionSheet*)createCameraActionSheet {
    UICameraActionSheet* retVal = [[UICameraActionSheet alloc]initWithTitle:nil delegate:nil cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Take Photo" otherButtonTitles:@"Choose Existing", nil];
    retVal.delegate = retVal;
    retVal.allowsEditing = NO;
    [retVal autorelease];
    return retVal;
}

+ (UICameraActionSheet*)createCameraActionSheetWithTitle:(NSString*)title allowsEditing:(BOOL)editing {
    UICameraActionSheet* retVal = [[UICameraActionSheet alloc]initWithTitle:title delegate:nil cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Take Photo" otherButtonTitles:@"Choose Existing", nil];
    retVal.delegate = retVal;
    retVal.allowsEditing = editing;
    [retVal autorelease];
    return retVal;
}

@end
