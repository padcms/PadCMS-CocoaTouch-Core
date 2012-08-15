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

#import "OCMock.h"
#import "PCGridView.h"
#import "PCGridViewCell.h"
#import "PCGridViewIndex.h"
#import <GHUnitIOS/GHUnit.h>


@interface PCGridViewTest : GHTestCase
{
    PCGridView *_gridView;
    id _dataSourceMock;
    id _delegateMock;
    NSUInteger _cellInstanceCount;
}

@end

@implementation PCGridViewTest

- (void)setUp
{
    [super setUp];
    _gridView = [[PCGridView alloc] initWithFrame:CGRectMake(0, 0, 500, 500)];
    _dataSourceMock = [OCMockObject mockForProtocol:@protocol(PCGridViewDataSource)];
    _gridView.dataSource = _dataSourceMock;
    _delegateMock = [OCMockObject mockForProtocol:@protocol(PCGridViewDelegate)];
    _gridView.delegate = _delegateMock;
}

- (void)tearDown
{
    [super tearDown];
    [_gridView release];
}

- (void)testZeroColumns
{
    /*
     Contract: Grid view shouldn't load cells if gridViewNumberOfColumns: data source method returns 0.
     */
    
    NSUInteger numberOfColumns = 0;
    [[[_dataSourceMock stub] andReturnValue:OCMOCK_VALUE(numberOfColumns)] gridViewNumberOfColumns:OCMOCK_ANY];
    NSUInteger numberOfRows = 10;
    [[[_dataSourceMock stub] andReturnValue:OCMOCK_VALUE(numberOfRows)] gridViewNumberOfRows:OCMOCK_ANY];
    CGSize cellSize = CGSizeMake(100, 100);
    [[[_dataSourceMock stub] andReturnValue:OCMOCK_VALUE(cellSize)] gridViewCellSize:OCMOCK_ANY];
    
    [_gridView reloadData];
    GHAssertEquals([NSNumber numberWithInteger:[PCGridViewCell instanceCount]], [NSNumber numberWithInteger:0], nil);
}

- (void)testZeroRows
{
    /*
     Contract: Grid view shouldn't load cells if gridViewNumberOfRows: data source method returns 0.
     */
    
    NSUInteger numberOfColumns = 10;
    [[[_dataSourceMock stub] andReturnValue:OCMOCK_VALUE(numberOfColumns)] gridViewNumberOfColumns:OCMOCK_ANY];
    NSUInteger numberOfRows = 0;
    [[[_dataSourceMock stub] andReturnValue:OCMOCK_VALUE(numberOfRows)] gridViewNumberOfRows:OCMOCK_ANY];
    CGSize cellSize = CGSizeMake(100, 100);
    [[[_dataSourceMock stub] andReturnValue:OCMOCK_VALUE(cellSize)] gridViewCellSize:OCMOCK_ANY];
    
    [_gridView reloadData];
    GHAssertEquals([NSNumber numberWithInteger:[PCGridViewCell instanceCount]], [NSNumber numberWithInteger:0], nil);
}

- (void)testZeroCellSize
{
    /*
     Contract: Grid view shouldn't load cells if gridViewCellSize: data source method returns CGSizeZero.
     */
    
    NSUInteger numberOfColumns = 10;
    [[[_dataSourceMock stub] andReturnValue:OCMOCK_VALUE(numberOfColumns)] gridViewNumberOfColumns:OCMOCK_ANY];
    NSUInteger numberOfRows = 10;
    [[[_dataSourceMock stub] andReturnValue:OCMOCK_VALUE(numberOfRows)] gridViewNumberOfRows:OCMOCK_ANY];
    CGSize cellSize = CGSizeZero;
    [[[_dataSourceMock stub] andReturnValue:OCMOCK_VALUE(cellSize)] gridViewCellSize:OCMOCK_ANY];
    
    [_gridView reloadData];
    GHAssertEquals([NSNumber numberWithInteger:[PCGridViewCell instanceCount]], [NSNumber numberWithInteger:0], nil);
}

- (void)testDataSourceGridViewCellForIndexMethodInvoke
{
    /*
     Contract: Grid view should invoke data source gridView:cellForIndex: method if number of rows is not 0, number of columns is not 0, and cell size is not CGSizeZero.
     */
    
    NSUInteger numberOfColumns = 1;
    [[[_dataSourceMock stub] andReturnValue:OCMOCK_VALUE(numberOfColumns)] gridViewNumberOfColumns:OCMOCK_ANY];
    NSUInteger numberOfRows = 1;
    [[[_dataSourceMock stub] andReturnValue:OCMOCK_VALUE(numberOfRows)] gridViewNumberOfRows:OCMOCK_ANY];
    CGSize cellSize = CGSizeMake(100, 100);
    [[[_dataSourceMock stub] andReturnValue:OCMOCK_VALUE(cellSize)] gridViewCellSize:OCMOCK_ANY];
    PCGridViewCell *cell = [[[PCGridViewCell alloc] init] autorelease];
    [[[_dataSourceMock expect] andReturn:cell] gridView:OCMOCK_ANY cellForIndex:OCMOCK_ANY];

    [_gridView reloadData];
    
    [_dataSourceMock verify];
}

- (void)testCellsReusing
{
    /*
     Contract: Grid view should not create cells number more than it can layout in a visible area.
     */
    
    _gridView.bounds = CGRectMake(0, 0, 5, 5);
    NSUInteger numberOfColumns = 100;
    [[[_dataSourceMock stub] andReturnValue:OCMOCK_VALUE(numberOfColumns)] gridViewNumberOfColumns:OCMOCK_ANY];
    NSUInteger numberOfRows = 100;
    [[[_dataSourceMock stub] andReturnValue:OCMOCK_VALUE(numberOfRows)] gridViewNumberOfRows:OCMOCK_ANY];
    CGSize cellSize = CGSizeMake(1, 1);
    [[[_dataSourceMock stub] andReturnValue:OCMOCK_VALUE(cellSize)] gridViewCellSize:OCMOCK_ANY];
    
    
    [[[_dataSourceMock stub] andCall:@selector(gridView:cellForIndex:) onObject:self]
     gridView:OCMOCK_ANY cellForIndex:OCMOCK_ANY];
    
    _cellInstanceCount = 0;
    
    [_gridView reloadData];
    
    GHAssertTrue(_cellInstanceCount <= (_gridView.bounds.size.width + 1) * (_gridView.bounds.size.height + 1), nil);
}

- (PCGridViewCell *)gridView:(PCGridView *)gridView cellForIndex:(PCGridViewIndex *)index
{
    PCGridViewCell *cell = [_gridView dequeueReusableCell];

    if (cell == 0) {
        cell = [[[PCGridViewCell alloc] init] autorelease];
        ++_cellInstanceCount;
    }
    
    return cell;
}

- (void)testCellSelection
{
    /*
     Contract: gridView:didSelectCellAtIndex: grid view delegate method should be invoked when the cell of the grid view is selected.
     */

    // TODO: Need UI Automation here
    
    /*
    _gridView.bounds = CGRectMake(0, 0, 5, 5);
    NSUInteger numberOfColumns = 100;
    [[[_dataSourceMock stub] andReturnValue:OCMOCK_VALUE(numberOfColumns)] gridViewNumberOfColumns:OCMOCK_ANY];
    NSUInteger numberOfRows = 100;
    [[[_dataSourceMock stub] andReturnValue:OCMOCK_VALUE(numberOfRows)] gridViewNumberOfRows:OCMOCK_ANY];
    CGSize cellSize = CGSizeMake(1, 1);
    [[[_dataSourceMock stub] andReturnValue:OCMOCK_VALUE(cellSize)] gridViewCellSize:OCMOCK_ANY];
    
    
    [[[_dataSourceMock stub] andCall:@selector(gridView:cellForIndex:) onObject:self]
     gridView:OCMOCK_ANY cellForIndex:OCMOCK_ANY];
    */
}

@end
