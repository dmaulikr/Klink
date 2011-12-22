//
//  LeavesViewController.m
//  Leaves
//
//  Created by Tom Brow on 4/18/10.
//  Copyright Tom Brow 2010. All rights reserved.
//

#import "LeavesViewController.h"

@implementation LeavesViewController
@synthesize leavesView = m_leavesView;

/*- (id)init {
    if (self = [super init]) {
		self.leavesView = [[LeavesView alloc] initWithFrame:CGRectZero];
        self.leavesView.mode = UIInterfaceOrientationIsPortrait(self.interfaceOrientation) ? LeavesViewModeSinglePage : LeavesViewModeFacingPages;
    }
    return self;
}*/

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.leavesView = [[LeavesView alloc] initWithFrame:CGRectZero];
        self.leavesView.mode = UIInterfaceOrientationIsPortrait(self.interfaceOrientation) ? LeavesViewModeSinglePage : LeavesViewModeFacingPages;
    }
    return self;
}

- (void)dealloc {
	[self.leavesView release];
    [super dealloc];
}

#pragma mark -
#pragma mark LeavesViewDataSource methods

- (NSUInteger) numberOfPagesInLeavesView:(LeavesView*)leavesView {
	return 0;
}

- (void) renderPageAtIndex:(NSUInteger)index inContext:(CGContextRef)ctx {
	
}

#pragma mark -
#pragma mark  UIViewController methods

- (void)loadView {
	[super loadView];
	self.leavesView.frame = self.view.bounds;
	self.leavesView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
	[self.view addSubview:self.leavesView];
}

- (void) viewDidLoad {
	[super viewDidLoad];
	self.leavesView.dataSource = self;
	self.leavesView.delegate = self;
	[self.leavesView reloadData];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
}


#pragma mark -
#pragma mark Interface rotation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation 
{
    return YES;
}


- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if (UIInterfaceOrientationIsPortrait(toInterfaceOrientation)) {
        self.leavesView.mode = LeavesViewModeSinglePage;
    } else {
        self.leavesView.mode = LeavesViewModeFacingPages;
    }
}


@end