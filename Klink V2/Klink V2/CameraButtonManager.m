//
//  CameraButtonManager.m
//  Klink V2
//
//  Created by Jordan Gurrieri on 9/3/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import "CameraButtonManager.h"

@implementation CameraButtonManager

static  CameraButtonManager* sharedManager;  

#pragma mark - Initializers / Singleton Accessors
+ (CameraButtonManager*) getInstance {
    //NSString* activityName = @"CameraButtonManager.getInstance:";
    @synchronized(self)
    {
        if (!sharedManager) {
            sharedManager = [[super allocWithZone:NULL]init];
        } 
        //[BLLog v:activityName withMessage:@"completed initialization"];
        return sharedManager;
    }
}


@end
