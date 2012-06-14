//
//  PCSearchViewController.h
//  Pad CMS
//
//  Created by Oleg Zhitnik on 05.03.12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PCSearchTaskDelegate.h"
#import "PCApplication.h"

@class PCRevision;
@class PCSearchTask;
@class PCSearchViewController;

@protocol PCSearchViewControllerDelegate <NSObject>

- (void)showRevisionWithIdentifier:(NSInteger) revisionIdentifier andPageIndex:(NSInteger) pageIndex;

@optional

- (void)dismissPCSearchViewController:(PCSearchViewController *)currentPCSearchViewController;

@end

/**
 @class PCSearchViewController
 @brief Searching View Controller 
 */
@interface PCSearchViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, 
PCSearchTaskDelegate>
{
    BOOL searchFinished;
}

@property (retain, nonatomic) NSString *searchKeyphrase;
@property (retain, nonatomic) PCRevision *revision;
@property (retain, nonatomic) PCSearchTask *searchTask;

@property (retain, nonatomic) IBOutlet UILabel *titleLabel;
@property (retain, nonatomic) IBOutlet UITableView *searchResultsTableView;
@property (retain, nonatomic) IBOutlet UIActivityIndicatorView *searchingActivityIndicator;
@property (assign, nonatomic) IBOutlet PCApplication *application;
@property (assign, nonatomic) IBOutlet id<PCSearchViewControllerDelegate> delegate;

- (IBAction)cancelClick:(id)sender;

@end
