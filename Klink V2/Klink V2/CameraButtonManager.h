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

@interface CameraButtonManager : NSObject <UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate> {
    Theme* theme;
    UIViewController* viewController;
}

@property (nonatomic, retain) Theme* theme;
@property (nonatomic, retain) UIViewController* viewController;

+ (CameraButtonManager*) getInstanceWithViewController:(id)callingViewController withTheme:(Theme*)currentTheme;

- (id) init;
- (id) initWithTheme:(Theme*)currentTheme withViewController:(id)callingViewController;


@end
