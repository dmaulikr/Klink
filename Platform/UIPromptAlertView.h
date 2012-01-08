//
//  UIPromptAlertView.h
//  Platform
//
//  Created by Jordan Gurrieri on 12/30/11.
//  Copyright (c) 2011 Blue Label Solutions LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIPromptAlertView : UIAlertView < UITextFieldDelegate > {
    UITextField*    m_textField;
    NSString*       m_enteredText;
    int             m_maxTextLength;
}

@property (nonatomic, retain) UITextField   *textField;
@property (nonatomic, retain) NSString      *enteredText;
@property (nonatomic)         int           maxTextLength;

- (id)initWithTitle:(NSString *)title message:(NSString *)message delegate:(id)delegate cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ...;

@end
