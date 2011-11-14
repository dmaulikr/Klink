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

#define kScale 2

@implementation UICameraActionSheet
@synthesize viewController = m_viewController;

- (id) initWithViewController:(BaseViewController*)vc {
    
    self = [super initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Take Photo" otherButtonTitles:@"Choose Existing", nil];
    
    if (self) {
        self.viewController = vc;
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
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.mediaTypes = mediaTypes;
        picker.delegate = self;
        picker.allowsEditing = NO;
        picker.sourceType = sourceType;
        
        if (sourceType == UIImagePickerControllerSourceTypeCamera) {
            picker.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
        }
        
        [self.viewController presentModalViewController:picker animated:YES];
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



#pragma mark - UIActionSheet Delegate
- (void)actionSheet:(UIActionSheet *)actionSheet 
    didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex != [actionSheet cancelButtonIndex]) {
        if (buttonIndex == 0) {
            [self getMediaFromSource:UIImagePickerControllerSourceTypeCamera];
        } else {
            [self getMediaFromSource:UIImagePickerControllerSourceTypePhotoLibrary];
        }
    }
    else {
        [self.viewController onCancelButtonPressed:self];
    }
}

#pragma mark - UIImagePickerController delegate methods
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissModalViewControllerAnimated:YES];
}

#pragma mark - UINavigationControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    // Begin creation of the thumbnail and fullscreen photos
    UIImage* chosenImage = [info objectForKey:UIImagePickerControllerOriginalImage];

    
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
    ImageManager* imageManager = [ImageManager instance];
    UIImage* thumbnailImage = [imageManager shrinkImage:chosenImage toSize:newThumbnailSize];
    
    // Crop the new shrunken thumbnail image to the fit the target frame size
    CGSize thumbnailImageSize = thumbnailImage.size;
    thumbnailCropRect = CGRectMake((thumbnailImageSize.width - (kPictureWidth * kScale))/2, (thumbnailImageSize.height - (kPictureHeight * kScale))/2, kPictureWidth * kScale, kPictureHeight * kScale);
    CGImageRef croppedThumbnailImage = CGImageCreateWithImageInRect([thumbnailImage CGImage], thumbnailCropRect);
    thumbnailImage = [UIImage imageWithCGImage:croppedThumbnailImage];
    
    // Make fullscreen image
    UIImage* fullscreenImage = [imageManager shrinkImage:chosenImage toSize:newFullscreenSize];
    
    [self.viewController onPhotoTakenWithThumbnailImage:thumbnailImage withFullImage:fullscreenImage];
    
    CGImageRelease(croppedThumbnailImage);
    
    [picker dismissModalViewControllerAnimated:YES];
}

@end
