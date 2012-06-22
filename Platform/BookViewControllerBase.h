//
//  BookViewControllerBase.h
//  Platform
//
//  Created by Jordan Gurrieri on 12/22/11.
//  Copyright (c) 2011 Blue Label Solutions LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import "BaseViewController.h"
#import "CloudEnumerator.h"
#import "MBProgressHUD.h"
#import "BookTableOfContentsViewController.h"
#import "IntroViewController.h"

@interface BookViewControllerBase : BaseViewController < NSFetchedResultsControllerDelegate, UIProgressHUDViewDelegate, CloudEnumeratorDelegate, BookTableOfContentsViewControllerDelegate, IntroViewControllerDelegate > {
    
    NSNumber*           m_pageID; //represents the ID of the page which the view controller is currently displaying
    NSNumber*           m_userID; //represents the ID of the user if we are tring to build a book just of a specific user's published pages
    NSNumber*           m_topVotedPhotoID;
    NSNumber*           m_topVotedCaptionID;
    CloudEnumerator*    m_pageCloudEnumerator;
    CloudEnumerator*    m_captionCloudEnumerator;
    
    UIImageView*        m_iv_background;
    UIImageView*        m_iv_bookCover;
    
    BOOL                m_shouldOpenBookCover;
    BOOL                m_shouldCloseBookCover;
    BOOL                m_shouldOpenToTitlePage;
    BOOL                m_shouldOpenToSpecificPage;
    BOOL                m_shouldOpenToLastPage;
    BOOL                m_shouldAnimatePageTurn;
    
    int                 m_tempLastViewedPage;
    
}

@property (nonatomic,retain) NSNumber*                      pageID;
@property (nonatomic,retain) NSNumber*                      userID;
@property (nonatomic,retain) NSNumber*                      topVotedPhotoID;
@property (nonatomic,retain) NSNumber*                      topVotedCaptionID;
@property (nonatomic,retain) NSFetchedResultsController*    frc_published_pages;
@property (nonatomic,retain) CloudEnumerator*               pageCloudEnumerator;
@property (nonatomic,retain) CloudEnumerator*               captionCloudEnumerator;

@property (nonatomic,retain) IBOutlet UIImageView*          iv_background;
@property (nonatomic,retain) IBOutlet UIImageView*          iv_bookCover;

@property (nonatomic)                 BOOL                  shouldOpenBookCover;
@property (nonatomic)                 BOOL                  shouldCloseBookCover;
@property (nonatomic)                 BOOL                  shouldOpenToTitlePage;
@property (nonatomic)                 BOOL                  shouldOpenToSpecificPage;
@property (nonatomic)                 BOOL                  shouldOpenToLastPage;
@property (nonatomic)                 BOOL                  shouldAnimatePageTurn;

@property (nonatomic)                 int                   tempLastViewedPage;



- (void)savePageIndex:(int)index;
- (int)getLastViewedPageIndex;
- (int) indexOfPageWithID:(NSNumber*)pageid;
- (void) onEnumerateComplete:(CloudEnumerator*)enumerator 
                 withResults:(NSArray *)results 
                withUserInfo:(NSDictionary *)userInfo;
- (void) evaluateAndEnumeratePagesFromCloud:(int)pagesRemaining;

- (void) showNotificationViewController;

- (void)openBook;
- (void)closeBook;
- (void)renderPage;

// Home Page Delegate Methods
- (IBAction) onReadButtonClicked:(id)sender;
- (IBAction) onProductionLogButtonClicked:(id)sender;
- (IBAction) onWritersLogButtonClicked:(id)sender;
- (IBAction) onUserWritersLogButtonClicked:(id)sender;
- (IBAction) onLinkButtonClicked:(id)sender;
- (IBAction)onHomeInfoButtonPressed:(id)sender;

// Book Page Delegate Methods
- (IBAction) onHomeButtonPressed:(id)sender;
- (IBAction) onFacebookButtonPressed:(id)sender;
- (IBAction) onTwitterButtonPressed:(id)sender;
- (IBAction) onTableOfContentsButtonPressed:(id)sender;
- (IBAction) onZoomOutPhotoButtonPressed:(id)sender;
- (IBAction)onPageInfoButtonPressed:(id)sender;

+ (BookViewControllerBase*) createInstance;
+ (BookViewControllerBase*) createInstanceWithPageID:(NSNumber*)pageID;
+ (BookViewControllerBase*) createInstanceWithUserID:(NSNumber*)userID;
+ (BookViewControllerBase*) createInstanceWithPageID:(NSNumber*)pageID withUserID:(NSNumber*)userID;

@end
