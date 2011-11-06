//
//  UICameraActionSheet.h
//  Platform
//
//  Created by Bobby Gill on 11/6/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseViewController.h"

@interface UICameraActionSheet : UIActionSheet <UIActionSheetDelegate, UIImagePickerControllerDelegate,UINavigationControllerDelegate> {
    BaseViewController* m_viewController;
}

@property (nonatomic,retain) BaseViewController* viewController;

- (id) initWithViewController:(BaseViewController*)viewController;

@end
