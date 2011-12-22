//
//  LeavesViewController.h
//  Leaves
//
//  Created by Tom Brow on 4/18/10.
//  Copyright Tom Brow 2010. All rights reserved.
//
//  Edits by Jordan Gurrieri on 12/22/11.
//  Copyright (c) 2011 Blue Label Solutions LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LeavesView.h"
#import "BookViewControllerBase.h"

@interface LeavesViewController : BookViewControllerBase <LeavesViewDataSource, LeavesViewDelegate> {
	LeavesView * m_leavesView;
}

@property (nonatomic, retain) LeavesView * leavesView;

@end

