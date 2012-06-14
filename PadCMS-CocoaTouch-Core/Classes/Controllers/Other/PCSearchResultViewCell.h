//
//  PCSearchResultViewCell.h
//  Pad CMS
//
//  Created by Oleg Zhitnik on 06.03.12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PCSearchResultViewCell : UITableViewCell
{
}
@property (retain, nonatomic) IBOutlet UIButton *issueTitleButton;
@property (retain, nonatomic) IBOutlet UIButton *pageTitleButton;

- (void) assignIssueTitle:(NSString*) issueTitle andPageTitle:(NSString*) pageTitle;
@end
