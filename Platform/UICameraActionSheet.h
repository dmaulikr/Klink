//
//  UICameraActionSheet.h
//  Platform
//
//  Created by Bobby Gill on 11/6/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol UICameraActionSheetDelegate <NSObject>

- (void) displayPicker:(UIImagePickerController*) picker;
- (void) onPhotoTakenWithThumbnailImage:(UIImage*)thumbnailImage 
                          withFullImage:(UIImage*)image;
- (void) onCancel;

@end

@interface UICameraActionSheet : UIActionSheet <UIActionSheetDelegate, UIImagePickerControllerDelegate,UINavigationControllerDelegate> {
    id<UICameraActionSheetDelegate>  m_delegate;
    
    BOOL m_allowsEditing;
    
    UIImagePickerController* m_picker;
    
}


@property (nonatomic,assign) id<UICameraActionSheetDelegate>    a_delegate;
@property (nonatomic,retain) UIImagePickerController*           picker;

@property (nonatomic)                 BOOL                      allowsEditing;

+ (UICameraActionSheet*) createCameraActionSheet;
+ (UICameraActionSheet*)createCameraActionSheetWithTitle:(NSString*)title allowsEditing:(BOOL)editing;

@end
