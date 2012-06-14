//
//  PCKioskBaseShelfView.m
//  Pad CMS
//
//  Created by Oleg Zhitnik on 26.04.12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import "PCKioskBaseShelfView.h"
#import "PCKioskShelfSettings.h"

@interface PCKioskBaseShelfView ()
- (void) disableAllCellsExceptCellWithIndex:(NSInteger) index;
- (void) enableAllCellsExceptCellWithIndex:(NSInteger) index;
- (PCKioskAbstractControlElement*) cellWithRevisionIndex:(NSInteger) index;
- (void) createCells;
- (void) removeCells;
@end

@implementation PCKioskBaseShelfView

+ (NSInteger) subviewTag
{
    return 1000;
}

- (PCKioskAbstractControlElement*) newCellWithFrame:(CGRect) frame;
{
    return [[PCKioskAbstractControlElement alloc] initWithFrame:frame];
}

- (void) createView
{
    [super createView];
    
    self.backgroundColor = UIColorFromRGB(0x303030);
    
    mainScrollView = [[UIScrollView alloc] initWithFrame:self.frame];
    mainScrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    mainScrollView.autoresizesSubviews = YES;
    mainScrollView.userInteractionEnabled = YES;
    mainScrollView.showsHorizontalScrollIndicator = NO;
    mainScrollView.showsVerticalScrollIndicator = YES;
    mainScrollView.alwaysBounceVertical = NO;
    
    [self addSubview:mainScrollView];
    
    [self createCells];
}

- (void) createCells
{
    NSInteger       numberOfRevisions = [self.dataSource numberOfRevisions];
    mainScrollView.contentSize = CGSizeMake(self.frame.size.width, ceil((((CGFloat)numberOfRevisions) / 2))*(KIOSK_SHELF_ROW_HEIGHT + KIOSK_SHELF_ROW_MARGIN_TOP));

    cells = [[NSMutableArray alloc] initWithCapacity:numberOfRevisions];
    
    CGFloat         middle = self.bounds.size.width / 2.0f;
    
    for(int i=0; i<numberOfRevisions; i++)
    {
        CGRect                   cellFrame;
        
        if(i % 2 == 0)
        {
            cellFrame.origin.x = KIOSK_SHELF_COLUMN_MARGIN_LEFT;
        } else {
            cellFrame.origin.x = middle + KIOSK_SHELF_COLUMN_MARGIN_LEFT;
        }
        cellFrame.origin.y = ((i / 2) * (KIOSK_SHELF_ROW_HEIGHT + KIOSK_SHELF_ROW_MARGIN_TOP)) + KIOSK_SHELF_ROW_MARGIN_TOP;
        cellFrame.size.width = middle - KIOSK_SHELF_COLUMN_MARGIN_LEFT;
        cellFrame.size.height = KIOSK_SHELF_ROW_HEIGHT;
        
        PCKioskAbstractControlElement        *newCell = [self newCellWithFrame:cellFrame];
        
        newCell.autoresizesSubviews = YES;
        if(i % 2 == 0)
        {
            newCell.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
        } else {
            newCell.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin;
        }
        
        newCell.revisionIndex = i;
        newCell.dataSource = self.dataSource;
        newCell.delegate = self;
        
        [mainScrollView addSubview:newCell];
        
        [newCell load];
        
        [cells addObject:newCell];
    }
}

- (void) removeCells
{
    if(cells)
    {
        for(PCKioskAbstractControlElement *cell in cells)
        {
            [cell removeFromSuperview];
        }
        [cells release];
        cells = nil;
    }
}

- (void)layoutSubviews
{
    CGFloat         contentHeight = mainScrollView.contentSize.height;
    
    mainScrollView.contentSize = CGSizeMake(self.bounds.size.width, contentHeight);
}

- (void) reloadRevisions
{
    [self removeCells];
    [self createCells];
}

- (void)dealloc
{
    [cells release];
    [super dealloc];
}

- (void) updateRevisionWithIndex:(NSInteger)index
{
    PCKioskAbstractControlElement    *cell = [self cellWithRevisionIndex:index];
    
    if(cell)
    {
        [cell update];
    }
}

#pragma mark PCKioskSubviewDelegateProtocol

- (void) downloadButtonTappedWithRevisionIndex:(NSInteger) index
{
    [self.delegate downloadButtonTappedWithRevisionIndex:index];
}

- (void) readButtonTappedWithRevisionIndex:(NSInteger) index
{
    [self.delegate readButtonTappedWithRevisionIndex:index];
}

- (void) cancelButtonTappedWithRevisionIndex:(NSInteger) index
{
    [self.delegate cancelButtonTappedWithRevisionIndex:index];
}

- (void) deleteButtonTappedWithRevisionIndex:(NSInteger) index
{
    [self.delegate deleteButtonTappedWithRevisionIndex:index];
}

- (void) updateButtonTappedWithRevisionIndex:(NSInteger) index
{
    [self.delegate updateButtonTappedWithRevisionIndex:index];
}

- (void) purchaseButtonTappedWithRevisionIndex:(NSInteger) index
{
    [self.delegate purchaseButtonTappedWithRevisionIndex:index];
}

#pragma mark - Download Progress

- (void) downloadStartedWithRevisionIndex:(NSInteger)index
{
    [super downloadStartedWithRevisionIndex:index];
    
    PCKioskAbstractControlElement    *cell = [self cellWithRevisionIndex:index];
    
    if(cell)
    {
        [cell downloadStarted];
        [self disableAllCellsExceptCellWithIndex:index];
    }
}

- (void) downloadProgressUpdatedWithRevisionIndex:(NSInteger)index andProgress:(float)progress andRemainingTime:(NSString *)time
{
    [super downloadProgressUpdatedWithRevisionIndex:index
                                        andProgress:progress
                                   andRemainingTime:time];
    
    PCKioskAbstractControlElement    *cell = [self cellWithRevisionIndex:index];
    
    if(cell)
    {
        [cell downloadProgressUpdatedWithProgress:progress andRemainingTime:time];
    }
}

- (void) downloadFinishedWithRevisionIndex:(NSInteger)index
{
    [super downloadFinishedWithRevisionIndex:index];
    
    PCKioskAbstractControlElement    *cell = [self cellWithRevisionIndex:index];
    
    if(cell)
    {
        [self enableAllCellsExceptCellWithIndex:index];
        [cell downloadFinished];
    }
}

- (void) downloadFailedWithRevisionIndex:(NSInteger)index
{
    [super downloadFailedWithRevisionIndex:index];
    
    PCKioskAbstractControlElement    *cell = [self cellWithRevisionIndex:index];
    
    if(cell)
    {
        [self enableAllCellsExceptCellWithIndex:index];
        [cell downloadFailed];
    }
}

- (void) downloadCanceledWithRevisionIndex:(NSInteger)index
{
    [super downloadCanceledWithRevisionIndex:index];
    
    PCKioskAbstractControlElement    *cell = [self cellWithRevisionIndex:index];
    
    if(cell)
    {
        [self enableAllCellsExceptCellWithIndex:index];
        [cell downloadCanceled];
    }
}

#pragma mark Private

- (void) disableAllCellsExceptCellWithIndex:(NSInteger) index
{
    if([cells count]==1) return;
    
    [UIView beginAnimations:@"disable_cells" context:nil];
    [UIView setAnimationDuration:0.5];

    for(PCKioskAbstractControlElement *cell in cells)
    {
        if(cell.revisionIndex!=index)
        {
            cell.userInteractionEnabled = NO;
            cell.alpha = 0.4;
        }
    }
    
    [UIView commitAnimations];
}

- (void) enableAllCellsExceptCellWithIndex:(NSInteger) index
{
    if([cells count]==1) return;
    
    [UIView beginAnimations:@"enable_cells" context:nil];
    [UIView setAnimationDuration:0.5];
    
    for(PCKioskAbstractControlElement *cell in cells)
    {
        if(cell.revisionIndex!=index)
        {
            cell.userInteractionEnabled = YES;
            cell.alpha = 1;
        }
    }
    
    [UIView commitAnimations];
}

- (PCKioskAbstractControlElement*) cellWithRevisionIndex:(NSInteger) index
{
    for(PCKioskAbstractControlElement *cell in cells)
    {
        if(cell.revisionIndex==index)
        {
            return cell;
        }
    }
    return nil;
}

@end
