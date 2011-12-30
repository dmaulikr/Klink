//
//  UICustomAlertView.m
//  Platform
//
//  Created by Jordan Gurrieri on 12/30/11.
//  Copyright (c) 2011 Blue Label Solutions LLC. All rights reserved.
//

#import "UICustomAlertView.h"

@implementation UICustomAlertView
@synthesize onFinishSelector = m_onFinishSelector;
@synthesize targetObject = m_targetObject;
@synthesize withObject = m_withObject;


- (id)initWithTitle:(NSString *)title message:(NSString *)message delegate:(id /*<UIAlertViewDelegate>*/)delegate onFinishSelector:(SEL)sel onTargetObject:(id)targetObject withObject:(id)parameter cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ... {
    
    self = [super initWithTitle:title message:message delegate:delegate cancelButtonTitle:cancelButtonTitle otherButtonTitles:otherButtonTitles, nil];
    
    if (self) {
        self.onFinishSelector = sel;
        self.targetObject = targetObject;
        self.withObject = parameter;
    }
    return self;
}


@end
