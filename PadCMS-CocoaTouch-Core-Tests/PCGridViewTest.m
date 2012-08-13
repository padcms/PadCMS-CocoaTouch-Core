//
//  PCGridViewTest.m
//  PadCMS-CocoaTouch-Core
//
//  Created by Maxim Pervushin on 8/3/12.
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

#import <GHUnitIOS/GHUnit.h>

#import "PCGridView.h"
#import "PCGridViewIndex.h"
#import "PCGridViewCell.h"

// Test data source
@interface PCGridViewTestDataSource : NSObject <PCGridViewDataSource>

@property (assign, nonatomic) NSUInteger numberOfColumnns;
@property (assign, nonatomic) NSUInteger numberOfRows;
@property (assign, nonatomic) CGSize cellSize;

@end

@implementation PCGridViewTestDataSource
@synthesize numberOfColumnns;
@synthesize numberOfRows;
@synthesize cellSize;

- (id)init
{
    self = [super init];
    if (self != nil) {
        numberOfColumnns = 0;
        numberOfRows = 0;
        cellSize = CGSizeZero;
    }
    return self;
}

- (NSUInteger)gridViewNumberOfRows:(PCGridView *)gridView
{
    return self.numberOfRows;
}

- (NSUInteger)gridViewNumberOfColumns:(PCGridView *)gridView
{
    return self.numberOfColumnns;
}

- (CGSize)gridViewCellSize:(PCGridView *)gridView
{
    return self.cellSize;
}

- (PCGridViewCell *)gridView:(PCGridView *)gridView cellForIndex:(PCGridViewIndex *)index
{
    PCGridViewCell *cell = [gridView dequeueReusableCell];
    
    if (cell == nil) {
        cell = [[[PCGridViewCell alloc] init] autorelease];
    }
    
    return cell;
}

@end


// Delegate

@interface PCGridViewTestDelegate : NSObject <PCGridViewDelegate>

@property (retain, nonatomic) PCGridViewIndex *lastSelectedIndex;

@end

@implementation PCGridViewTestDelegate
@synthesize lastSelectedIndex;

- (void)gridView:(PCGridView *)gridView didSelectCellAtIndex:(PCGridViewIndex *)index
{
    self.lastSelectedIndex = index;
}

@end


// Tests

@interface PCGridViewTest : GHTestCase
{
    PCGridView *_gridView;
    PCGridViewTestDataSource *_dataSource;
    PCGridViewTestDelegate *_delegate;
}

@end

@implementation PCGridViewTest

- (void)setUp
{
    [super setUp];
    _gridView = [[PCGridView alloc] initWithFrame:CGRectMake(0, 0, 500, 500)];
    _dataSource = [[PCGridViewTestDataSource alloc] init];
    _gridView.dataSource = _dataSource;
    _delegate = [[PCGridViewTestDelegate alloc] init];
    _gridView.delegate = _delegate;
}

- (void)tearDown
{
    [super tearDown];
    [_gridView release];
    [_dataSource release];
    [_delegate release];
}

- (void)testColumnsAndRowscount
{
    _dataSource.numberOfColumnns = 0;
    _dataSource.numberOfRows = 0;
    [_gridView reloadData];
    
    GHAssertEquals([NSNumber numberWithInteger:[PCGridViewCell instanceCount]], [NSNumber numberWithInteger:0], @"");

    _dataSource.numberOfColumnns = 3;
    _dataSource.numberOfRows = 4;
    _dataSource.cellSize = CGSizeMake(100, 100);
    [_gridView reloadData];
    
    GHAssertEquals([PCGridViewCell instanceCount], _dataSource.numberOfColumnns * _dataSource.numberOfRows, @"");
}

- (void)testLayout
{
    _dataSource.numberOfColumnns = 7;
    _dataSource.numberOfRows = 10;
    _dataSource.cellSize = CGSizeMake(100, 100);
    [_gridView reloadData];
    
    GHAssertEquals(_gridView.contentSize, CGSizeMake(_dataSource.cellSize.width * _dataSource.numberOfColumnns, _dataSource.cellSize.height * _dataSource.numberOfRows), @"");
}

- (void)testActiveCellsCount
{
    _dataSource.numberOfColumnns = 100;
    _dataSource.numberOfRows = 100;
    _dataSource.cellSize = CGSizeMake(100, 100);
    _gridView.bounds = CGRectMake(0, 0, 200, 200);
    [_gridView reloadData];
    
    NSUInteger activeCellsCount = 0;
    
    NSArray *subviews = _gridView.subviews;
    for (UIView *subview in subviews) {
        if (!subview.hidden) {
            ++activeCellsCount;
        }
    }
    
    NSUInteger maximalCellsCount = (_gridView.bounds.size.width / _dataSource.cellSize.width + 1) * (_gridView.bounds.size.height / _dataSource.cellSize.height + 1);

    GHAssertGreaterThanOrEqual(maximalCellsCount, activeCellsCount, @"");
    
    [_gridView scrollRectToVisible:CGRectMake(_dataSource.cellSize.width / 2, _dataSource.cellSize.height / 2, _gridView.bounds.size.width, _gridView.bounds.size.height) animated:NO];

    GHAssertGreaterThanOrEqual(maximalCellsCount, activeCellsCount, @"");
}

- (void)testSelect
{
    _dataSource.numberOfColumnns = 100;
    _dataSource.numberOfRows = 100;
    _dataSource.cellSize = CGSizeMake(100, 100);
    _gridView.bounds = CGRectMake(0, 0, 200, 200);
    [_gridView reloadData];
    
    NSUInteger activeCellsCount = 0;
    
    NSArray *subviews = _gridView.subviews;
    for (UIView *subview in subviews) {
        if (!subview.hidden) {
//            [subview touchesBegan:<#(NSSet *)#> withEvent:<#(UIEvent *)#>];
//            GH
        }
    }
    
}

@end
