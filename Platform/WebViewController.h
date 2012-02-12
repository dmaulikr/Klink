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
    NSURL*    m_baseURL;
    
}

@property (nonatomic, retain) IBOutlet UIWebView*   wv_webView;

@property (nonatomic, retain) NSString*   navBarTitle;
@property (nonatomic, retain) NSString*   htmlString;
@property (nonatomic, retain) NSURL*      baseURL;

// Static Initializers
+ (WebViewController*)createInstance;
+ (WebViewController*)createInstanceWithTitle:(NSString*)title;
+ (WebViewController*)createInstanceWithTitle:(NSString*)title withHTMLString:(NSString*)htmlString withBaseURL:(NSURL*)baseURL;

@end
