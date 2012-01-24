//
//  UIResourceLinkButton.h
//  Platform
//
//  Created by Jasjeet Gill on 12/31/11.
//  Copyright (c) 2011 Blue Label Solutions LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIResourceLinkButton : UIButton
{
    UIResourceLinkButton* m_resourceLinkButton;
    NSNumber*   m_objectID;
    NSString*   m_objectName;
}

@property (nonatomic,retain) IBOutlet UIResourceLinkButton* resourceLinkButton;
@property (nonatomic,retain) NSNumber* objectID;
@property (nonatomic,retain) NSString* objectName;

- (void) renderWithObjectID:(NSNumber*)objectID withName:(NSString*)name;
- (void)setFont:(UIFont *)font;

@end
