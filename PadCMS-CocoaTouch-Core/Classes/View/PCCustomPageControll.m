//
//  PCCustomPageControll.m
//  Pad CMS
//
//  Created by Rustam Mallakurbanov on 08.02.12.
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

#import "PCCustomPageControll.h"

@implementation PCCustomPageControll

@dynamic numberOfPages;
@dynamic currentPage;
@dynamic dotSize;
@dynamic distance;

-(void)dealloc
{
    [buttons release];
    [images release];
    [super dealloc];
}

-(id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        images = [[NSMutableDictionary alloc] init];
        buttons = [[NSMutableArray alloc] init];
        numberOfPages = 0;
        currentPage = 0;
        dotSize = CGSizeZero;
        distance = 0;
    }
    return self;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    NSUInteger count = [buttons count];
    if (count==0)
        return;
    CGRect selfRect = self.frame;
    CGFloat pagesSize = count*self.dotSize.width+(count-1)*self.distance;
    CGFloat dx = (selfRect.size.width - pagesSize)/2;
    CGFloat dy = (selfRect.size.height - self.dotSize.height)/2;
    for (unsigned i=0;i<[buttons count];i++)
    {
        UIButton* button = [buttons objectAtIndex:i];
        CGRect buttonFrame = CGRectMake(dx, dy, self.dotSize.width, self.dotSize.height);  
        button.frame = CGRectMake(dx, dy, self.dotSize.width, self.dotSize.height); 
        button.center = CGPointMake(CGRectGetMidX(buttonFrame), CGRectGetMidY(buttonFrame));
        dx+=self.dotSize.width+self.distance;
    }
}


-(CGFloat)distance
{
    return distance;
}

-(void)setDistance:(CGFloat)aDistance
{
    distance = aDistance;
    [self layoutSubviews];
}

-(CGSize)dotSize
{
   return dotSize;
}

-(void)setDotSize:(CGSize)aDotSize
{
    dotSize = aDotSize;   
    
    if (self.distance == 0)
        self.distance = aDotSize.height;
    [self layoutSubviews];
}

-(void)setNumberOfPages:(NSInteger)aNumberOfPages
{
    numberOfPages = aNumberOfPages;
    for (UIButton* button in buttons)
        [button removeFromSuperview];
    [buttons removeAllObjects];
    for (unsigned i = 0; i < aNumberOfPages; ++i)
    {
        UIButton*  button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button addTarget:self action:@selector(pageChange:) forControlEvents:UIControlEventTouchUpInside];
        for (NSNumber* key in [images allKeys])
            [button setImage:[images objectForKey:key] forState:(UIControlState)[key intValue]];
        button.bounds = CGRectMake(0, 0, self.dotSize.width, self.dotSize.height);//self.dotSize;
        [self addSubview:button];
        
        [buttons addObject:button];
    }
    [self layoutSubviews];
    [self setNeedsDisplay];
    
}

- (NSInteger) numberOfPages
{
    return numberOfPages;
}

-(void)setCurrentPage:(NSInteger)aCurrentPage
{
    currentPage = aCurrentPage;
    for (unsigned i = 0; i < [buttons count]; ++i)
    {
        UIButton* button = [buttons objectAtIndex:i];
        if (i == aCurrentPage)
            [button setSelected:YES];
        else
            [button setSelected:NO];
    }
}

- (NSInteger) currentPage
{
    return currentPage;
}

- (void)setImage:(UIImage *)image forState:(UIControlState)state
{
    [images setObject:image forKey:[NSNumber numberWithInt:state]];
    for (UIButton* button in buttons)
        [button setImage:image forState:state];
    if (CGSizeEqualToSize(dotSize, CGSizeZero))
    {
        self.dotSize = [image size];
    }

}

-(void)pageChange:(id)sender
{
    NSInteger index = [buttons indexOfObject:sender];
    if (index != NSNotFound && index != currentPage)
    {
        self.currentPage = index;
        [self sendActionsForControlEvents:UIControlEventValueChanged];
    }
}

@end
