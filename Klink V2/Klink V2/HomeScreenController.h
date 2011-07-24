//
//  HomeScreenController.h
//  Klink V2
//
//  Created by Bobby Gill on 7/11/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KlinkBaseViewController.h"

@interface HomeScreenController : KlinkBaseViewController {
    UIButton *button1;
    UIButton *button2;
    UIButton *button3;
}
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) IBOutlet UIButton *button1;
@property (nonatomic, retain) IBOutlet UIButton *button2;
@property (nonatomic, retain) IBOutlet UIButton *button3;
- (IBAction)onButtonClicked:(id)sender;
@end
