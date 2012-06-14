//
//  PCSearchResultViewCell.m
//  Pad CMS
//
//  Created by Oleg Zhitnik on 06.03.12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import "PCSearchResultViewCell.h"

@implementation PCSearchResultViewCell
@synthesize issueTitleButton;
@synthesize pageTitleButton;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)dealloc {
    self.issueTitleButton = nil;
    self.pageTitleButton = nil;
    [super dealloc];
}

- (void) assignIssueTitle:(NSString*) issueTitle andPageTitle:(NSString*) pageTitle
{
    [issueTitleButton setTitle:issueTitle
                      forState:UIControlStateNormal];
    [pageTitleButton setTitle:pageTitle
                     forState:UIControlStateNormal];
}

@end
