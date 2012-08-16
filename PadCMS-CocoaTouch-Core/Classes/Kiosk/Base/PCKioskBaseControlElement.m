//
//  PCKioskBaseControlElement.m
//  Pad CMS
//
//  Created by Oleg Zhitnik on 11.05.12.
//  Copyright (c) PadCMS (http://www.padcms.net)
//
//
//  This software is governed by the CeCILL-C  license under French law and
//  abiding by the rules of distribution of free software.  You can  use,
//  modify and/ or redistribute the software under the terms of the CeCILL-C
//  license as circulated by CEA, CNRS and INRIA at the following URL
//  "http://www.cecill.info".
//  
//  As a counterpart to the access to the source code and  rights to copy,
//  modify and redistribute granted by the license, users are provided only
//  with a limited warranty  and the software's author,  the holder of the
//  economic rights,  and the successive licensors  have only  limited
//  liability.
//  
//  In this respect, the user's attention is drawn to the risks associated
//  with loading,  using,  modifying and/or developing or reproducing the
//  software by the user in light of its specific status of free software,
//  that may mean  that it is complicated to manipulate,  and  that  also
//  therefore means  that it is reserved for developers  and  experienced
//  professionals having in-depth computer knowledge. Users are therefore
//  encouraged to load and test the software's suitability as regards their
//  requirements in conditions enabling the security of their systems and/or
//  data to be ensured and,  more generally, to use and operate it in the
//  same conditions as regards security.
//  
//  The fact that you are presently reading this means that you have had
//  knowledge of the CeCILL-C license and that you accept its terms.
//

#import "PCKioskBaseControlElement.h"
#import "PCKioskShelfSettings.h"
#import "PCLocalizationManager.h"

@interface PCKioskBaseControlElement ()
- (void)assignCoverImage:(UIImage*) coverImage;
@end

@implementation PCKioskBaseControlElement

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}

- (void)dealloc
{
    if(revisionCoverView)[revisionCoverView release];
    
    [issueTitleLabel release];
    [revisionTitleLabel release];
    [revisionStateLabel release];
    
    [downloadButton release];
    [previewButton release];
    [readButton release];
    [cancelButton release];
    [deleteButton release];
    
    [downloadingProgressView release];
    [downloadingInfoLabel release];
    
    [super dealloc];
}

- (void) load
{
    [super load];
    
    [self setUserInteractionEnabled:YES];
    self.backgroundColor = [UIColor clearColor];
    [self setClipsToBounds:YES];
    
    [self initCover];
    [self initLabels];
    [self initButtons];
    [self assignButtonsHandlers];
    [self initDownloadingProgressComponents];
    [self adjustElements];
    [self update];
}

#pragma mark - Init

- (void) initCover
{
    revisionCoverView = [[UIImageView alloc] initWithFrame:CGRectMake(KIOSK_SHELF_CELL_COVER_MARGIN_LEFT, (self.bounds.size.height-KIOSK_SHELF_CELL_COVER_HEIGHT)/2, KIOSK_SHELF_CELL_COVER_WIDTH, KIOSK_SHELF_CELL_COVER_HEIGHT)];
    [self addSubview:revisionCoverView];
}

- (void) initLabels
{
    // Issue title label
    issueTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(KIOSK_SHELF_CELL_ELEMENTS_LEFT_MARGIN, KIOSK_SHELF_CELL_ISSUE_TITLE_TOP_MARGIN, self.bounds.size.width - (KIOSK_SHELF_CELL_COVER_MARGIN_LEFT + KIOSK_SHELF_CELL_COVER_WIDTH), KIOSK_SHELF_CELL_ISSUE_TITLE_HEIGHT)];
    issueTitleLabel.textColor = [UIColor whiteColor];
    issueTitleLabel.backgroundColor = [UIColor clearColor];
    issueTitleLabel.textAlignment = UITextAlignmentLeft;
    issueTitleLabel.font = [UIFont fontWithName:@"Verdana" size:15];
    issueTitleLabel.minimumFontSize = 13;
    [self addSubview:issueTitleLabel];
    
    // Revision title label
    revisionTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(KIOSK_SHELF_CELL_ELEMENTS_LEFT_MARGIN, KIOSK_SHELF_CELL_REVISION_TITLE_TOP_MARGIN, self.bounds.size.width - (KIOSK_SHELF_CELL_COVER_MARGIN_LEFT + KIOSK_SHELF_CELL_COVER_WIDTH), KIOSK_SHELF_CELL_REVISION_TITLE_HEIGHT)];
    revisionTitleLabel.textColor = UIColorFromRGB(0x339fc3);
    revisionTitleLabel.backgroundColor = [UIColor clearColor];
    revisionTitleLabel.textAlignment = UITextAlignmentLeft;
    revisionTitleLabel.font = [UIFont fontWithName:@"Verdana" size:17];
    revisionTitleLabel.minimumFontSize = 15;
    [self addSubview:revisionTitleLabel];
    
    // Revision state label
    revisionStateLabel = [[UILabel alloc] initWithFrame:CGRectMake(KIOSK_SHELF_CELL_ELEMENTS_LEFT_MARGIN, KIOSK_SHELF_CELL_REVISION_STATE_TOP_MARGIN, self.bounds.size.width - (KIOSK_SHELF_CELL_COVER_MARGIN_LEFT + KIOSK_SHELF_CELL_COVER_WIDTH), KIOSK_SHELF_CELL_REVISION_STATE_HEIGHT)];
    revisionStateLabel.textColor = UIColorFromRGB(0x339fc3);
    revisionStateLabel.backgroundColor = [UIColor clearColor];
    revisionStateLabel.textAlignment = UITextAlignmentLeft;
    revisionStateLabel.font = [UIFont fontWithName:@"Verdana" size:17];
    revisionStateLabel.minimumFontSize = 15;
    [self addSubview:revisionStateLabel];
}

- (void) initButtons
{
    downloadButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[downloadButton setBackgroundImage:[[UIImage imageNamed:@"kiosk_button_download.png"] stretchableImageWithLeftCapWidth:16 topCapHeight:16] forState:UIControlStateNormal];
	[downloadButton setTitle:[PCLocalizationManager localizedStringForKey:@"KIOSK_BUTTON_TITLE_DOWNLOAD"
                                                                    value:@"Download"]
                    forState:UIControlStateNormal];
	[downloadButton titleLabel].font = [UIFont fontWithName:@"Verdana" size:15];
	[downloadButton titleLabel].backgroundColor = [UIColor clearColor];
	[downloadButton titleLabel].textAlignment = UITextAlignmentCenter;
	[downloadButton titleLabel].textColor = [UIColor whiteColor];	
	[downloadButton sizeToFit];
    downloadButton.hidden = YES;
    downloadButton.exclusiveTouch = YES;
	[self addSubview:downloadButton];
	
    previewButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[previewButton setBackgroundImage:[[UIImage imageNamed:@"kiosk_button_preview.png"] stretchableImageWithLeftCapWidth:16 topCapHeight:16] forState:UIControlStateNormal];
	[previewButton setTitle:@"Preview" forState:UIControlStateNormal];
	[previewButton titleLabel].font = [UIFont fontWithName:@"Verdana" size:15];
	[previewButton titleLabel].backgroundColor = [UIColor clearColor];
	[previewButton titleLabel].textAlignment = UITextAlignmentCenter;
	[previewButton titleLabel].textColor = [UIColor whiteColor];	
	[previewButton sizeToFit];
    previewButton.hidden = YES;
    previewButton.exclusiveTouch = YES;
	[self addSubview:previewButton];
	
	readButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[readButton setBackgroundImage:[[UIImage imageNamed:@"kiosk_button_read.png"] stretchableImageWithLeftCapWidth:16 topCapHeight:16] forState:UIControlStateNormal];
	[readButton setTitle:[PCLocalizationManager localizedStringForKey:@"KIOSK_BUTTON_TITLE_READ"
                                                                value:@"Read"]
                forState:UIControlStateNormal];
	[readButton titleLabel].font = [UIFont fontWithName:@"Verdana" size:15];
	[readButton titleLabel].backgroundColor = [UIColor clearColor];
	[readButton titleLabel].textAlignment = UITextAlignmentCenter;
	[readButton titleLabel].textColor = [UIColor whiteColor];
	[readButton sizeToFit];
    readButton.hidden = YES;
    readButton.exclusiveTouch = YES;
	[self addSubview:readButton];	
	
	cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[cancelButton setBackgroundImage:[[UIImage imageNamed:@"kiosk_button_cancel.png"] stretchableImageWithLeftCapWidth:16 topCapHeight:16] forState:UIControlStateNormal];
	[cancelButton setTitle:[PCLocalizationManager localizedStringForKey:@"KIOSK_BUTTON_TITLE_CANCEL"
                                                                  value:@"Cancel"]
                  forState:UIControlStateNormal];
	[cancelButton titleLabel].font = [UIFont fontWithName:@"Verdana" size:14];
	[cancelButton titleLabel].backgroundColor = [UIColor clearColor];
	[cancelButton titleLabel].textAlignment = UITextAlignmentCenter;
	[cancelButton titleLabel].textColor = [UIColor whiteColor];	
	[cancelButton sizeToFit];
    cancelButton.hidden = YES;
    cancelButton.exclusiveTouch = YES;
	[self addSubview:cancelButton];
	
	deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[deleteButton setBackgroundImage:[[UIImage imageNamed:@"kiosk_button_delete.png"] stretchableImageWithLeftCapWidth:16 topCapHeight:16] forState:UIControlStateNormal];
	[deleteButton setTitle:[PCLocalizationManager localizedStringForKey:@"KIOSK_BUTTON_TITLE_DELETE"
                                                                  value:@"Delete"]
                  forState:UIControlStateNormal];
	[deleteButton titleLabel].font = [UIFont fontWithName:@"Verdana" size:15];
	[deleteButton titleLabel].backgroundColor = [UIColor clearColor];
	[deleteButton titleLabel].textAlignment = UITextAlignmentCenter;
	[deleteButton titleLabel].textColor = [UIColor whiteColor];
	[deleteButton sizeToFit];
    deleteButton.hidden = YES;
    deleteButton.exclusiveTouch = YES;
	[self addSubview:deleteButton];		

    downloadButton.frame = CGRectMake(KIOSK_SHELF_CELL_ELEMENTS_LEFT_MARGIN, KIOSK_SHELF_CELL_FIRST_BUTTON_TOP_MARGIN, KIOSK_SHELF_CELL_BUTTONS_WIDTH, KIOSK_SHELF_CELL_BUTTONS_HEIGHT);
    previewButton.frame = CGRectMake(KIOSK_SHELF_CELL_ELEMENTS_LEFT_MARGIN,
                                     KIOSK_SHELF_CELL_FIRST_BUTTON_TOP_MARGIN + KIOSK_SHELF_CELL_BUTTONS_HEIGHT, 
                                     KIOSK_SHELF_CELL_BUTTONS_WIDTH, 
                                     KIOSK_SHELF_CELL_BUTTONS_HEIGHT);
    cancelButton.frame = downloadButton.frame;
    readButton.frame = CGRectMake(KIOSK_SHELF_CELL_ELEMENTS_LEFT_MARGIN, KIOSK_SHELF_CELL_FIRST_BUTTON_TOP_MARGIN, KIOSK_SHELF_CELL_BUTTONS_WIDTH, KIOSK_SHELF_CELL_BUTTONS_HEIGHT);
    deleteButton.frame = CGRectMake(KIOSK_SHELF_CELL_ELEMENTS_LEFT_MARGIN, KIOSK_SHELF_CELL_THIRD_BUTTON_TOP_MARGIN, KIOSK_SHELF_CELL_BUTTONS_WIDTH, KIOSK_SHELF_CELL_BUTTONS_HEIGHT);
    previewButton.frame = deleteButton.frame;
}

- (void) adjustElements
{
    BOOL previewAvailable = [self previewAvailableForRevisionWithIndex:self.revisionIndex];
    
    if ([self.dataSource isRevisionDownloadedWithIndex:self.revisionIndex]) {
        
        downloadButton.hidden = YES;
        previewButton.hidden = YES;
        cancelButton.hidden = YES;
        readButton.hidden = NO;
        deleteButton.hidden = NO;
        
        downloadingInfoLabel.hidden = YES;
        downloadingProgressView.hidden = YES;
        
    } else {

        if (self.downloadInProgress) {
            
            downloadButton.hidden = YES;
            previewButton.hidden = YES;
            cancelButton.hidden = NO;
            readButton.hidden = YES;
            deleteButton.hidden = YES;
            
            downloadingInfoLabel.hidden = NO;
            downloadingProgressView.hidden = NO;
            
        } else {
            
            downloadButton.hidden = NO;
            previewButton.hidden = previewAvailable ? NO : YES;
            cancelButton.hidden = YES;
            readButton.hidden = YES;
            deleteButton.hidden = YES;
            
            downloadingInfoLabel.hidden = YES;
            downloadingProgressView.hidden = YES;
        }
        
    }
}

- (BOOL)previewAvailableForRevisionWithIndex:(NSUInteger)index
{
    if ([self.dataSource respondsToSelector:@selector(previewAvailableForRevisionWithIndex:)]) {
        return [self.dataSource previewAvailableForRevisionWithIndex:index];
    }
    
    return NO;
}

- (void) assignButtonsHandlers
{
    [downloadButton addTarget:self
                       action:@selector(downloadButtonTapped)
             forControlEvents:UIControlEventTouchUpInside];
    
    [previewButton addTarget:self
                      action:@selector(previewButtonTapped)
            forControlEvents:UIControlEventTouchUpInside];
    
    [cancelButton addTarget:self
                     action:@selector(cancelButtonTapped)
           forControlEvents:UIControlEventTouchUpInside];
    
    [readButton addTarget:self
                   action:@selector(readButtonTapped)
         forControlEvents:UIControlEventTouchUpInside];

    [deleteButton addTarget:self
                     action:@selector(deleteButtonTapped)
           forControlEvents:UIControlEventTouchUpInside];
}

- (void) initDownloadingProgressComponents
{
    
    // Progress view init
    downloadingProgressView = [[PDColoredProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
	[downloadingProgressView setTintColor: [UIColor colorWithRed:43.0/255.0
                                                           green:134.0/255.0
                                                            blue:225.0/255.0
                                                           alpha:1]];
    downloadingProgressView.hidden = YES;
    downloadingProgressView.frame = CGRectMake(KIOSK_SHELF_CELL_ELEMENTS_LEFT_MARGIN, KIOSK_SHELF_CELL_SECOND_BUTTON_TOP_MARGIN, KIOSK_SHELF_CELL_BUTTONS_WIDTH, 7);
	[self addSubview:downloadingProgressView];
    
    // Download info label
	downloadingInfoLabel = [[UILabel alloc] init];
	downloadingInfoLabel.font = [UIFont fontWithName:@"Verdana" size:15];
	downloadingInfoLabel.backgroundColor = [UIColor clearColor];
	downloadingInfoLabel.textAlignment = UITextAlignmentCenter;
	downloadingInfoLabel.textColor = [UIColor whiteColor];
    downloadingInfoLabel.hidden = YES;
    downloadingInfoLabel.frame = CGRectMake(KIOSK_SHELF_CELL_ELEMENTS_LEFT_MARGIN, KIOSK_SHELF_CELL_THIRD_BUTTON_TOP_MARGIN, KIOSK_SHELF_CELL_BUTTONS_WIDTH, KIOSK_SHELF_CELL_REVISION_TITLE_HEIGHT);
	[self addSubview:downloadingInfoLabel];
}

#pragma mark - Override

- (void) update
{
    if(revisionCoverView)
    {
        UIImage         *coverImage = [self.dataSource revisionCoverImageWithIndex:self.revisionIndex andDelegate:self];
        
        [self assignCoverImage:coverImage];
    }
    issueTitleLabel.text = [self.dataSource issueTitleWithIndex:self.revisionIndex];
    revisionTitleLabel.text = [self.dataSource revisionTitleWithIndex:self.revisionIndex];
    revisionStateLabel.text = [self.dataSource revisionStateWithIndex:self.revisionIndex];
    [self adjustElements];
}

#pragma mark - Buttons actions

- (void) downloadButtonTapped
{
    if ([self.delegate respondsToSelector:@selector(downloadButtonTappedWithRevisionIndex:)]) {
        [self.delegate downloadButtonTappedWithRevisionIndex:self.revisionIndex];
    }
}

- (void) previewButtonTapped
{
    if ([self.delegate respondsToSelector:@selector(previewButtonTappedWithRevisionIndex:)]) {
        [self.delegate previewButtonTappedWithRevisionIndex:self.revisionIndex];
    }
}

- (void) cancelButtonTapped
{
    if ([self.delegate respondsToSelector:@selector(cancelButtonTappedWithRevisionIndex:)]) {
        [self.delegate cancelButtonTappedWithRevisionIndex:self.revisionIndex];
    }
}

- (void) readButtonTapped
{
    if ([self.delegate respondsToSelector:@selector(readButtonTappedWithRevisionIndex:)]) {
        [self.delegate readButtonTappedWithRevisionIndex:self.revisionIndex];
    }
}

- (void) deleteButtonTapped
{
    if ([self.delegate respondsToSelector:@selector(deleteButtonTappedWithRevisionIndex:)]) {
        [self.delegate deleteButtonTappedWithRevisionIndex:self.revisionIndex];
    }
}

#pragma mark - Download flow

- (void) downloadStarted
{
    [super downloadStarted];
    [self adjustElements];
}

- (void) downloadProgressUpdatedWithProgress:(float)progress andRemainingTime:(NSString *)time
{
    downloadingProgressView.progress = progress;
    
    if(time)
    {
        downloadingInfoLabel.text = [NSString stringWithFormat:@"%3.0f %% %@",progress*100, time];
    } else {
        downloadingInfoLabel.text = [NSString stringWithFormat:@"%3.0f %%", progress*100];
    }
}

- (void) downloadFinished
{
    [super downloadFinished];
    downloadingInfoLabel.text = @"";
    downloadingProgressView.progress = 0.0f;
    [self adjustElements];
}

- (void) downloadFailed
{
    [super downloadFailed];
    downloadingInfoLabel.text = @"";
    downloadingProgressView.progress = 0.0f;
    [self adjustElements];
}

- (void) downloadCanceled;
{
    [super downloadCanceled];
    downloadingProgressView.progress = 0.0f;
    [self adjustElements];
}

#pragma mark - PCKioskCoverImageProcessingProtocol

-(void) updateCoverImage:(UIImage*) coverImage
{
    [self assignCoverImage:coverImage];
}

-(void) downloadingCoverImageFailed
{
}

- (void)assignCoverImage:(UIImage*) coverImage
{
    if(revisionCoverView)
    {
        if(coverImage)
        {
            revisionCoverView.backgroundColor = [UIColor whiteColor];
            
            // Horizontal cover
            if(coverImage.size.width > coverImage.size.height)
            {
                CGFloat scale = ((float)(KIOSK_SHELF_CELL_COVER_WIDTH)) / coverImage.size.width;
                CGSize newSize = CGSizeMake(coverImage.size.width * scale, coverImage.size.height * scale);
                [revisionCoverView setFrame:CGRectMake(revisionCoverView.frame.origin.x,
                                                       (KIOSK_SHELF_ROW_HEIGHT-newSize.height)/2,
                                                       newSize.width,
                                                       newSize.height)];
            }
        }
        revisionCoverView.image = coverImage;
    }
}

@end
