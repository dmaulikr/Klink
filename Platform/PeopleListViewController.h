//
//  PeopleListViewController.h
//  Platform
//
//  Created by Jordan Gurrieri on 3/20/12.
//  Copyright (c) 2012 Blue Label Solutions LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@interface PeopleListViewController : BaseViewController < UITableViewDelegate, UITableViewDataSource > {
    NSString* m_navBarTitle;
}

@property (nonatomic, retain) NSString* navBarTitle;

+ (PeopleListViewController*)createInstanceWithTitle:(NSString*)string;

@end
