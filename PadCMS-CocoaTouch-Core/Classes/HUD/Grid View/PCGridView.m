//
//  PCGridView.m
//  PCGridView
//
//  Created by Maxim Perushin on 8/1/12
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

#import "PCGridView.h"

#import "PCGridViewCell.h"
#import "PCGridViewIndex.h"


@interface PCGridView ()
{
    NSUInteger _numberOfRows;
    NSUInteger _numberOfColumns;
    CGSize _cellSize;
    NSMutableSet *_reusableCells;
}

- (void)updateSubviews;
- (PCGridViewCell *)subviewForIndex:(PCGridViewIndex *)index;
- (void)enqueueReusableItemView:(PCGridViewCell *)itemView;
- (void)tapGesture:(UITapGestureRecognizer *)recognizer;
- (PCGridViewIndex *)indexAtPoint:(CGPoint)point;
- (void)didReceiveMemoryWarning:(NSNotification *)notification;

#pragma mark delegate
- (void)didSelectCellAtIndex:(PCGridViewIndex *)index;
#pragma mark data source
- (NSUInteger)numberOfRows;
- (NSUInteger)numberOfColumns;
- (CGSize)cellSize;
- (PCGridViewCell *)cellForIndex:(PCGridViewIndex *)index;

@end

@implementation PCGridView
@synthesize delegate;
@synthesize dataSource;

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_reusableCells release];
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self != nil) {
        _numberOfRows = 0;
        _numberOfColumns = 0;
        _cellSize = CGSizeZero;
        _reusableCells = [[NSMutableSet alloc] init];

        self.showsVerticalScrollIndicator = NO;
        self.showsHorizontalScrollIndicator = NO;
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] 
                                                        initWithTarget:self action:@selector(tapGesture:)];
        [self addGestureRecognizer:tapGestureRecognizer];
        [tapGestureRecognizer release];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveMemoryWarning:) 
                                                     name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
    }
    
    return self;
}

- (void)setContentOffset:(CGPoint)contentOffset
{
    [super setContentOffset:contentOffset];
    
    [self updateSubviews];
}

#pragma mark - private methods

- (void)updateSubviews
{
    if (_cellSize.width == 0 || _cellSize.height == 0 ||
        _numberOfColumns == 0 || _numberOfRows == 0) {
        return;
    }
    
    CGRect visibleRect = CGRectMake(self.contentOffset.x, 
                                    self.contentOffset.y, 
                                    self.bounds.size.width, 
                                    self.bounds.size.height); 
    
    NSMutableArray *subviews = [self.subviews mutableCopy];
    
    // Determine left, right, top and bottom visible rects.
    CGFloat leftf = visibleRect.origin.x / _cellSize.width;
    CGFloat rightf = (MIN(visibleRect.origin.x + self.bounds.size.width, self.contentSize.width - 1)) / _cellSize.width;
    CGFloat topf = visibleRect.origin.y / _cellSize.height;
    CGFloat bottomf = (MIN(visibleRect.origin.y + self.bounds.size.height, self.contentSize.height - 1)) / _cellSize.height;
    
    NSUInteger left = leftf >= 0 ? leftf : 0;
    NSUInteger right = rightf >= 0 ? rightf : 0;
    NSUInteger top = topf >= 0 ? topf : 0;
    NSUInteger bottom = bottomf >= 0 ? bottomf : 0;
    
    // Enumerate visible cells.
    for (NSUInteger column = left; column <= right; ++column) {
        for (NSUInteger row = top; row <= bottom ; ++row) {
            
            CGFloat x = column * _cellSize.width;
            CGFloat y = row * _cellSize.height;
            CGRect cellFrame = CGRectMake(x, y, _cellSize.width, _cellSize.height);
            
            PCGridViewIndex *index =[[[PCGridViewIndex alloc] init] autorelease];
            index.column = column;
            index.row = row;
            
            // Try to find already existing cell with corresponding index.
            PCGridViewCell *cell = [self subviewForIndex:index];
            if (cell == nil) {
                // Request to create a new cell. 
                cell = [self cellForIndex:index];
            }
            
            if (cell != nil) {
                // Set up cell params.
                cell.index = index;
                cell.frame = cellFrame;
                cell.hidden = NO;
                
                if (![self.subviews containsObject:cell]) {
                    [self addSubview:cell];
                }
                
                [subviews removeObject:cell];
            }
        }
    }
    // Mark all invisible cells as reusable. 
    for (PCGridViewCell *subview in subviews) {
        [self enqueueReusableItemView:(PCGridViewCell *)subview];
    }
    
    [subviews release];
}

- (PCGridViewCell *)subviewForIndex:(PCGridViewIndex *)index
{
    NSArray *cells = self.subviews;
    
    for (PCGridViewCell *cell in cells) {

        // Cells with nil index are reusable we should not check them.
        if (cell.index == nil) {
            continue;
        }
        
        if (cell.index != nil && cell.index.row == index.row && cell.index.column == index.column) {
            return cell;
        }
    
    }
    
    return nil;
}

- (void)enqueueReusableItemView:(PCGridViewCell *)itemView
{
    itemView.index = nil;
    itemView.hidden = YES;
    [_reusableCells addObject:itemView];
}

- (void)tapGesture:(UITapGestureRecognizer *)recognizer
{
    CGPoint location = [recognizer locationInView:self];
    
    NSArray *subviews = self.subviews;
    for (UIView *subview in subviews) {
        if (CGRectContainsPoint(subview.frame, location)) {
            UIColor *originalColor = subview.backgroundColor;
            
            [UIView animateWithDuration:0.3f 
                             animations:^{
                                 subview.backgroundColor = [UIColor whiteColor];
                             } completion:^(BOOL finished) {
                                 [UIView animateWithDuration:0.3f 
                                                  animations:^{
                                                      subview.backgroundColor = originalColor;
                                                  }];
                             }];
            
            PCGridViewIndex *index = [self indexAtPoint:location];
            
            if (index != nil) {
                [self didSelectCellAtIndex:index];
            }
            
            break;
        }
    }
}

- (PCGridViewIndex *)indexAtPoint:(CGPoint)point
{
    NSArray *subviews = self.subviews;
    for (PCGridViewCell *subview in subviews) {
        if (CGRectContainsPoint(subview.frame, point)) {
            if (subview.index != nil) {
                return subview.index;
            }
            
            return nil;
        }
    }
    
    return nil;
}

- (void)didReceiveMemoryWarning:(NSNotification *)notification
{
    for (PCGridViewCell *reusableCell in _reusableCells) {
        [reusableCell removeFromSuperview];
    }
    
    [_reusableCells removeAllObjects];
}

#pragma mark - public methods

- (void)reloadData
{
    NSArray *items = self.subviews;
    for (PCGridViewCell *item in items) {
        [self enqueueReusableItemView:item];
    }
    
    _numberOfRows = [self numberOfRows];
    _numberOfColumns = [self numberOfColumns];
    _cellSize = [self cellSize];
    
    self.contentSize = CGSizeMake(_numberOfColumns * _cellSize.width, 
                                  _numberOfRows * _cellSize.height);
    
    [self updateSubviews];
}

- (PCGridViewCell *)dequeueReusableCell
{
    if (_reusableCells.count == 0) {
        return nil;
    }
    
    PCGridViewCell *reusableView = [_reusableCells anyObject];
    [_reusableCells removeObject:reusableView];
    
    return reusableView;
}

#pragma mark - delegate

- (void)didSelectCellAtIndex:(PCGridViewIndex *)index
{
    if ([self.delegate respondsToSelector:@selector(gridView:didSelectCellAtIndex:)]) {
        [self.delegate gridView:self didSelectCellAtIndex:index];
    }
}

#pragma mark - data source

- (NSUInteger)numberOfRows
{
    if ([self.dataSource respondsToSelector:@selector(gridViewNumberOfRows:)]) {
        return [self.dataSource gridViewNumberOfRows:self];
    }
    
    return 0;
}

- (NSUInteger)numberOfColumns
{
    if ([self.dataSource respondsToSelector:@selector(gridViewNumberOfColumns:)]) {
        return [self.dataSource gridViewNumberOfColumns:self];
    }
    
    return 0;
}

- (CGSize)cellSize
{
    if ([self.dataSource respondsToSelector:@selector(gridViewCellSize:)]) {
        return [self.dataSource gridViewCellSize:self];
    }
    
    return CGSizeZero;
}

- (PCGridViewCell *)cellForIndex:(PCGridViewIndex *)index
{
    if ([self.dataSource respondsToSelector:@selector(gridView:cellForIndex:)]) {
        return [self.dataSource gridView:self cellForIndex:index];
    }
    
    return nil;
}

@end
