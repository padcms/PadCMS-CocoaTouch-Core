//
//  PCInteractiveBulletWithFlash.m
//  Pad CMS
//
//  Created by Rustam Mallakurbanov on 22.03.12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import "PCInteractiveBulletWithFlash.h"
#import "PCFlashButton.h"
#import "PCStyler.h"
#import "PCDefaultStyleElements.h"

@implementation PCInteractiveBulletWithFlash

@synthesize buttonsView;

-(void)viewDidLoad
{
    [super viewDidLoad];
    isShow = NO;
    int count = 0;
    self.buttonsView = [[[UIView alloc] initWithFrame:[mainScrollView bounds]] autorelease];
    
    PCPageElement* element = [self.page firstElementForType:PCPageElementTypeBackground];
    for (PCPageActiveZone* pdfActiveZone in element.activeZones)
    {
        if ([pdfActiveZone.URL hasPrefix:PCPDFActiveZoneActionButton])
        {
            NSUInteger index = 0;
            index = [[pdfActiveZone.URL lastPathComponent] intValue];
            
            PCFlashButton* bulletButton = [PCFlashButton buttonWithType:UIButtonTypeCustom];
            [bulletButton setTag:index];
            [bulletButton addTarget:self action:@selector(pressFlashButtonAction:) forControlEvents:UIControlEventTouchUpInside];
            [[PCStyler defaultStyler] stylizeElement:bulletButton withStyleName:PCFlashButtonKey withOptions:nil];

            CGRect rect = pdfActiveZone.rect;
            if (!CGRectEqualToRect(rect, CGRectZero))
            {
                CGSize pageSize = [self.columnViewController pageSizeForViewController:self];
                float scale = pageSize.width/element.size.width;
                rect.size.width *= scale;
                rect.size.height *= scale;
                rect.origin.x *= scale;
                rect.origin.y *= scale;
                rect.origin.y = element.size.height*scale - rect.origin.y - rect.size.height;
            }
            
            [bulletButton setFrame:rect];
            [buttonsView addSubview:bulletButton];
            count++;
        }
    }
    
    if (self.bodyViewController)
    {
        PCPageElement* bodyElement = [self.page firstElementForType:PCPageElementTypeBody];
        for (PCPageActiveZone* pdfActiveZone in bodyElement.activeZones)
        {
            if ([pdfActiveZone.URL hasPrefix:PCPDFActiveZoneExtra])
            {

                extraButton = [[PCFlashButton buttonWithType:UIButtonTypeCustom] retain];
                [extraButton addTarget:self action:@selector(hideBody:) forControlEvents:UIControlEventTouchUpInside];
                [[PCStyler defaultStyler] stylizeElement:extraButton withStyleName:PCFlashButtonKey withOptions:nil];
                
                
                CGRect rect = pdfActiveZone.rect;
                if (!CGRectEqualToRect(rect, CGRectZero))
                {
                    CGSize pageSize = [self.columnViewController pageSizeForViewController:self];
                    float scale = pageSize.width/element.size.width;
                    rect.size.width *= scale;
                    rect.size.height *= scale;
                    rect.origin.x *= scale;
                    rect.origin.y *= scale;
                    rect.origin.y = element.size.height*scale - rect.origin.y - rect.size.height;
                }
                
                [extraButton setFrame:rect];
                [self.mainScrollView addSubview:extraButton];
            }
        }
    }
    
    if (count>0)
        [self.mainScrollView addSubview:buttonsView];
    else
        self.buttonsView = nil;

}

-(void)pressFlashButtonAction:(id)sender
{
    NSLog(@"1[sender tag]=%d",[sender tag]);
    
    [self showArticleAtIndex:[sender tag]-1];
    
    if (self.buttonsView)
        [self.mainScrollView bringSubviewToFront:self.buttonsView]; 
    
    //hide pressed button
    UIButton* currentButton = sender;
    currentButton.hidden = YES;
    for (UIButton* button in self.buttonsView.subviews)
    {
        if (button!=currentButton)
            button.hidden = NO;
    }
}

- (void) loadFullView
{
    [super loadFullView];
    if (self.buttonsView&&isShow)
    {
        self.buttonsView.hidden = NO;
        self.backgroundViewController.view.hidden = NO;
        [self.mainScrollView bringSubviewToFront:self.buttonsView]; 
    }
    else
    {
        self.buttonsView.hidden = YES;
        self.backgroundViewController.view.hidden = YES;
        [self.mainScrollView bringSubviewToFront:self.bodyViewController.view];
        if (extraButton)
            [self.mainScrollView bringSubviewToFront:extraButton];
    }
}

-(void)hideBody:(id)sender
{
    isShow = YES;
    self.buttonsView.hidden = NO;
    self.backgroundViewController.view.hidden = NO;
    [self.bodyViewController.view removeFromSuperview];
    [extraButton removeFromSuperview];
}

@end
