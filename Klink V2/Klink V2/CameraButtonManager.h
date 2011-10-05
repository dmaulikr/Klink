//
//  CameraButtonManager.h
//  Klink V2
//
//  Created by Jordan Gurrieri on 9/3/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BLLog.h"
#import "Theme.h"
#import "KlinkBaseViewController.h"

@interface CameraButtonManager : NSObject <UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate> {
    KlinkBaseViewController* viewController;
}


@property (nonatomic, retain) KlinkBaseViewController* viewController;

+ (CameraButtonManager*) getInstanceWithViewController:(id)callingViewController; 
- (void)cameraButtonPressed:(id)sender;

- (id) init;
- (id) initWithTheme:(Theme*)currentTheme withViewController:(id)callingViewController;


@end
