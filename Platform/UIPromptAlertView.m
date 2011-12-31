//
//  UIPromptAlertView.m
//  Platform
//
//  Created by Jordan Gurrieri on 12/30/11.
//  Copyright (c) 2011 Blue Label Solutions LLC. All rights reserved.
//

#import "UIPromptAlertView.h"

@implementation UIPromptAlertView
@synthesize textField = m_textField;
@synthesize enteredText = m_enteredText;


- (id)initWithTitle:(NSString *)title message:(NSString *)message delegate:(id)delegate cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ... {
    
    if (self = [super initWithTitle:title message:message delegate:delegate cancelButtonTitle:cancelButtonTitle otherButtonTitles:otherButtonTitles, nil])
    {
        UITextField* theTextField = [[UITextField alloc] initWithFrame:CGRectMake(12.0, 48, 260.0, 31.0)]; 
        [theTextField setBackgroundColor:[UIColor whiteColor]];
        [theTextField setBorderStyle:UITextBorderStyleRoundedRect];
        [theTextField setTextAlignment:UITextAlignmentCenter];
        [theTextField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
        [theTextField setMinimumFontSize:10.0];
        [theTextField setAdjustsFontSizeToFitWidth:YES];
        [theTextField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
        [theTextField setAutocorrectionType:UITextAutocorrectionTypeNo];
        [theTextField setClearButtonMode:UITextFieldViewModeWhileEditing];
        [theTextField setKeyboardAppearance:UIKeyboardAppearanceAlert];
        [theTextField setReturnKeyType:UIReturnKeyDone];
        [theTextField setDelegate:self];
        
        [self addSubview:theTextField];
        self.textField = theTextField;
        [theTextField release];
        
        //CGAffineTransform translate = CGAffineTransformMakeTranslation(0.0, 130.0); 
        //[self setTransform:translate];
    }
    return self;
}

- (void)show
{
    [self.textField becomeFirstResponder];
    [super show];
}

- (NSString *)enteredText
{
    return self.textField.text;
}

- (void)dealloc
{
    self.textField = nil;
    [super dealloc];
}

#pragma mark - UITextview and TextField Delegate Methods
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    // username textfield editing has ended
    
    if ([textField.text isEqualToString:@""]) {
        [self.textField setText:@"blank"];
    }
    else {
        NSString* trimmedUsername = [self.textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        [self.textField setText:trimmedUsername];
    }
}

// Used to prevent spaces in the username
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)text {    
    
    if([text isEqualToString:@" "]) {
        // no spaces allowed
        return NO;
    }
    else {
        return YES;
    }
}

// Handles keyboard Return button pressed while editing the username textfield to dismiss the keyboard
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

@end
