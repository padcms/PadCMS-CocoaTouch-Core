//
//  PCCrossword.m
//  Pad CMS
//
//  Created by Igor Getmanenko on 27.08.12.
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

#import "PCCrossword.h"

#define PCCrosswordHorizontalWordOrientation @"horizontal"
#define PCCrosswordVerticalWordOrientation   @"vertical"

@implementation PCCrossword

@synthesize crosswordID = _crosswordID;
@synthesize title = _title;
@synthesize width = _width;
@synthesize height = _height;
@synthesize cells = _cells;
@synthesize questions = _questions;

- (id)init
{
    self = [super init];
    if (self)
    {
        _cells = [[NSMutableArray alloc] init];
        _questions = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)dealloc
{
    [_title release], _title = nil;
    [_cells release], _cells = nil;
    [_questions release], _questions = nil;
    
    [super dealloc];
}

- (void)createCrosswordGrid
{
    for (PCCrosswordQuestion *question in _questions)
    {
        NSInteger currentPoint = question.startingSellID;
        
        for (int i=0; i<question.length; i++)
        {
            if (![self cellForIndex:currentPoint])
            {
                PCCrosswordCell *cell = [[PCCrosswordCell alloc] init];
                cell.cellID = currentPoint;
                cell.cellRightAnswerContent = [question.answer substringWithRange:NSMakeRange(i, 1)];
                [_cells addObject:cell];
                [cell release];
            }
            if ([question.direction isEqualToString:PCCrosswordHorizontalWordOrientation])
                currentPoint++;
            else
                currentPoint+=_width;
        }
    }
}

- (PCCrosswordCell*)cellForIndex:(NSInteger)index
{
    if (index < 0 || index >= _width * _height)
        return nil;
    
    for (PCCrosswordCell *cell in _cells)
    {
        if (cell.cellID == index)
            return cell;
    }
    return nil;
}

- (CGPoint)positionOfCellForIndex:(NSInteger)index
{
    NSInteger yPosition = index / _height;
    NSInteger xPosition = index % _height;
    return CGPointMake(xPosition, yPosition);
}

- (NSString *)description
{
    return [NSString stringWithFormat:
            @"PCCrossword: %@\r"
            "identifier: %d\r"
            "title: %@\r"
            "width: %d\r"
            "height: %d\r"
            "cells: %@\r"
            "questions: %@\r",
            [super description],
            _crosswordID,
            _title,
            _width,
            _height,
            _cells,
            _questions];
}

@end
