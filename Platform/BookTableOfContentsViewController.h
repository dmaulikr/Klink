//
//  BookTableOfContentsViewController.h
//  Platform
//
//  Created by Jordan Gurrieri on 1/27/12.
//  Copyright (c) 2012 Blue Label Solutions LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"


@class BookTableOfContentsViewController;

@protocol BookTableOfContentsViewControllerDelegate

@optional


@end

@interface BookTableOfContentsViewController : BaseViewController < NSFetchedResultsControllerDelegate, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate > {
    
    id<BookTableOfContentsViewControllerDelegate> m_delegate;
    
    NSDictionary*           m_allPages;
    NSNumber*               m_userID; //represents the ID of the user if we are tring to build a book just of a specific user's published pages
    NSMutableDictionary*    m_pagesSearch;
    NSMutableArray*         m_months;
    NSMutableArray*         m_monthsDeepCopy;
    
    UITableView*            m_tbl_tOCTableView;
    UIButton*               m_btn_tableOfContentsButton;
    
    UISearchBar*            m_sb_searchBar;
    UIButton*               m_btn_backgroundButton;
}

@property (assign) id<BookTableOfContentsViewControllerDelegate>    delegate;

@property (nonatomic,retain) NSFetchedResultsController*    frc_published_pages;

@property (nonatomic,retain) NSDictionary*                  allPages;
@property (nonatomic,retain) NSNumber*                      userID;
@property (nonatomic,retain) NSMutableDictionary*           pagesSearch;
@property (nonatomic,retain) NSMutableArray*                months;
@property (nonatomic,retain) NSMutableArray*                monthsDeepCopy;

@property (nonatomic,retain) IBOutlet UITableView*          tbl_tOCTableView;
@property (nonatomic,retain) IBOutlet UIButton*             btn_tableOfContentsButton;

@property (nonatomic,retain) IBOutlet UISearchBar*          sb_searchBar;
@property (nonatomic,retain) IBOutlet UIButton*             btn_backgroundButton;

- (IBAction) onTOCButtonPressed:(id)sender;
- (IBAction) onBackgroundButtonPressed:(id)sender;

- (void)resetSearch;
- (void)handleSearchForTerm:(NSString *)searchTerm;

+ (BookTableOfContentsViewController*)createInstance;
+ (BookTableOfContentsViewController*)createInstanceWithUserID:(NSNumber*)userID;

@end
