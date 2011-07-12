//
//  HomeScreenController.h
//  Klink V2
//
//  Created by Bobby Gill on 7/11/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface HomeScreenController : UIViewController {
    
}
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
- (IBAction)onButtonClicked:(id)sender;
@end
