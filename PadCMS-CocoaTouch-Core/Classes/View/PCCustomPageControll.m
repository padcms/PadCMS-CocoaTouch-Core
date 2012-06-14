//
//  PCCustomPageControll.m
//  Pad CMS
//
//  Created by Rustam Mallakurbanov on 08.02.12.
//  Copyright (c) 2012 Adyax. All rights reserved.
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
