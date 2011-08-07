//
//  UICaptionTextView.m
//  Klink V2
//
//  Created by Bobby Gill on 8/7/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import "UICaptionTextView.h"
#import "ApplicationSettings.h"


#define kTextViewHeight 70
#define kCharLblHeight 30
#define kCharVertPadding 10
#define kCharLeftPadding 10
#define kCharRightPadding 20
@implementation UICaptionTextView
@synthesize tv_text;
@synthesize lbl_charsremaining;
@synthesize delegate = m_delegate;

- (CGRect) frameForTextView : (CGRect)frame {
    return CGRectMake(0, 0, frame.size.width, kTextViewHeight);
}

- (CGRect) frameForCharsRemaining: (CGRect)frame{
    return CGRectMake(kCharLeftPadding, (frame.size.height-kCharLblHeight), frame.size.width-kCharRightPadding, (kCharLblHeight-kCharVertPadding));
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.opaque = NO;
        CGRect textFieldFrame = [self frameForTextView:frame];
        self.tv_text = [[UITextField alloc]initWithFrame:[self frameForTextView:frame]];
        self.tv_text.returnKeyType = UIReturnKeyDone;
        self.tv_text.delegate = self;
        self.tv_text.borderStyle = UITextBorderStyleRoundedRect;
        self.tv_text.font = [UIFont fontWithName:@"Marker Felt" size:16];
        self.tv_text.backgroundColor = [UIColor clearColor];
        self.tv_text.opaque = NO;
        
        
        self.lbl_charsremaining = [[UILabel alloc]initWithFrame:[self frameForCharsRemaining:textFieldFrame]];
        
        self.tv_text.textColor = [UIColor blackColor];
        self.tv_text.backgroundColor = [UIColor clearColor];
        
        self.lbl_charsremaining.text = [NSString stringWithFormat:@"%d characters remaining",maxlength_CAPTION];
        self.lbl_charsremaining.textColor = [UIColor grayColor];
        self.lbl_charsremaining.opaque = NO;
        
        
        [self.tv_text addSubview:self.lbl_charsremaining];
        [self addSubview:self.tv_text];
    }
    return self;
}

- (BOOL)resignFirstResponder {
   
      return  [self.tv_text resignFirstResponder];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self != nil) {
        self = [self initWithFrame:self.frame];
    }
    return self;
}

- (void) setText:(NSString *)text {
    self.tv_text.text = text;
}

- (void) cancel {
    id<UICaptionTextViewDelegate> del = self.delegate;
    self.delegate = nil;
    [self.tv_text resignFirstResponder];
    self.delegate = del;
}

- (NSString*) getText {
    return self.tv_text.text;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)dealloc
{
    [super dealloc];
}

#pragma mark - UITextViewDelegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    //need to calculate length of text with replacement text
    NSString* proposedString = [NSString stringWithFormat:@"%@%@",textView.text,text];
        
    if([text isEqualToString:@"\n"]) {
        [self.tv_text resignFirstResponder];
        [self.delegate captionTextView:self finishedWithString:self.tv_text.text];
//        self.tv_captionBox.hidden = YES;
//        [textView resignFirstResponder];
//        [self onSubmitButtonPressed:nil];
        return NO;
    }
    else {
        if ([proposedString length] > maxlength_CAPTION) {
            return NO;
        }
        else {
            int newLength = [proposedString length];
            self.lbl_charsremaining.text = [NSString stringWithFormat:@"%d characters remaining",(maxlength_CAPTION-newLength)];
            return YES;
        }

    }
    
    return YES;
    
}


#pragma mark - UITextFieldDelegate

- (BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)text {
    NSString* proposedString = [NSString stringWithFormat:@"%@%@",textField.text,text];
    
    if([text isEqualToString:@"\n"]) {
        [self.tv_text resignFirstResponder];
        [self.delegate captionTextView:self finishedWithString:self.tv_text.text];

        return NO;
    }
    else {
        if ([proposedString length] > maxlength_CAPTION) {
            return NO;
        }
        else {
            int newLength = [proposedString length];
            self.lbl_charsremaining.text = [NSString stringWithFormat:@"%d characters remaining",(maxlength_CAPTION-newLength)];
            return YES;
        }
        
    }
    
    return YES;
}

- (void) textFieldDidEndEditing:(UITextField *)textField {
     [self.delegate captionTextView:self finishedWithString:self.tv_text.text];
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.tv_text resignFirstResponder];
    return YES;
}

@end
