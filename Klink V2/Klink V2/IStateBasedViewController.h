//
//  IStateBasedViewController.h
//  Test Project 2
//
//  Created by Bobby Gill on 6/16/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol IStateBasedViewController <NSObject> 
    - (void)refreshViewFromDataLayer;
    - (BOOL)canShowViewToUser;


@end
