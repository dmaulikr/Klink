//
//  UIProfileBar2.m
//  Klink V2
//
//  Created by Jordan Gurrieri on 10/3/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import "UIProfileBar2.h"
#import "CameraButtonManager.h"


@implementation UIProfileBar2

@synthesize lbl_votes;
@synthesize lbl_userName;
@synthesize lbl_captions;
@synthesize img_profilePic;
@synthesize btn_cameraButton;
@synthesize viewController = m_viewController;

/*- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}*/

- (id) initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
        NSArray* bundle =  [[NSBundle mainBundle] loadNibNamed:@"UIProfileBar2" owner:self options:nil];
        
        UIView* profileBar2 = [bundle objectAtIndex:0];
        
        // Add custom backgound image to the view
        //UIColor *background = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"background-toolbar-black.png"]];
        //profileBar2.backgroundColor = background;
        //[background release];
        
        [self addSubview:profileBar2];
        //self.userInteractionEnabled = YES;
    }
    return self;
}

- (void)dealloc
{
    [lbl_userName release];
    [lbl_votes release];
    [lbl_captions release];
    [img_profilePic release];
    [btn_cameraButton release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.lbl_userName = nil;
    self.lbl_votes = nil;
    self.lbl_captions = nil;
    self.img_profilePic = nil;
    self.btn_cameraButton = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Button Handlers

- (IBAction) onCameraButtonPressed:(id)sender {
    CameraButtonManager* cameraButtonManager = [CameraButtonManager getInstanceWithViewController:self.viewController];
    [cameraButtonManager cameraButtonPressed:self];
}

@end
