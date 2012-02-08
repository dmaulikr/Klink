//
//  WebViewController.h
//  Platform
//
//  Created by Jordan Gurrieri on 2/7/12.
//  Copyright (c) 2012 Blue Label Solutions LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WebViewController : UIViewController {
    UIWebView* m_wv_webView;
    
    NSString* m_navBarTitle;
    NSString* m_htmlString;
    
}

@property (nonatomic, retain) IBOutlet UIWebView*   wv_webView;

@property (nonatomic, retain) NSString*   navBarTitle;
@property (nonatomic, retain) NSString*   htmlString;

+ (WebViewController*)createInstance;
+ (WebViewController*)createInstanceWithTitle:(NSString*)title;
+ (WebViewController*)createInstanceWithHTMLString:(NSString*)htmlString withTitle:(NSString*)title;

@end
