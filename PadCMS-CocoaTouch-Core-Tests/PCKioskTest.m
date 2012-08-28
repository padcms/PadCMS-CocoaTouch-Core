//
//  PCKioskTest.m
//  PadCMS-CocoaTouch-Core
//
//  Created by Oleg Zhitnik on 16.08.12.
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
#import "PCTKioskSubviewsFactory.h"
#import "PCKioskViewController.h"
#import "PCKioskSubview.h"
#import "PCKioskBaseGalleryView.h"
#import "PCTKioskGalleryView.h"
#import "PCTKioskGalleryControlElement.h"
#import "PCLocalizationManager.h"

@interface ButtonTapTest : NSObject
@property (nonatomic, assign) UIButton *destinationButton;
@property (nonatomic, assign) SEL testSelector;
@end

@implementation ButtonTapTest
@synthesize destinationButton;
@synthesize testSelector;
@end

@interface PCKioskTest : GHAsyncTestCase <PCKioskDataSourceProtocol, PCKioskViewControllerDelegateProtocol>
{
    PCTKioskSubviewsFactory *kioskFactory;
    PCKioskViewController   *kioskViewController;
    SEL                      currentTestSelector;
}

- (void)sendTapEventToButton:(UIButton *) button withTestSelector:(SEL) testSelector;
- (void)sendTapEvent:(ButtonTapTest*)tapTest;
- (UIButton*)controlElementButtonWithTitle:(NSString*)title;
- (void)notifyWithCurrentSelector;
@end

@implementation PCKioskTest

- (void)setUp
{
    kioskFactory = [[PCTKioskSubviewsFactory alloc] init];
    
    kioskViewController = [[PCKioskViewController alloc] initWithKioskSubviewsFactory:kioskFactory
                                                                             andFrame:CGRectMake(0, 0, 768, 1024)
                                                                        andDataSource:self];
    kioskViewController.delegate = self;
    kioskViewController.view.backgroundColor = [UIColor clearColor];
}

- (void)tearDown
{
    [kioskViewController release];
    [kioskFactory release];
}

- (void)testKioskSubviewsSwitching
{
    NSInteger       initialSubviewTag = [kioskViewController currentSubviewTag];

    [kioskViewController switchToNextSubview];

    NSInteger       nextSubviewTag = [kioskViewController currentSubviewTag];

    GHAssertNotEquals(initialSubviewTag, nextSubviewTag, nil);
    
    [kioskViewController switchToSubviewWithTag:initialSubviewTag];
    
    NSInteger       currentSubviewTag = [kioskViewController currentSubviewTag];
    
    GHAssertEquals(initialSubviewTag, currentSubviewTag, nil);
}

- (void)testKioskDownloadDelegateTest
{
    NSString    *title = [PCLocalizationManager localizedStringForKey:@"KIOSK_BUTTON_TITLE_DOWNLOAD"
                                                                value:@"Download"];
    UIButton    *button = [self controlElementButtonWithTitle:title];
    
    GHAssertNotNil(button, [NSString stringWithFormat:@"Kiosk control element must contains %@ button", title]);
    
    [self prepare];
    [self sendTapEventToButton:button
              withTestSelector:@selector(testKioskDownloadDelegateTest)];

    [self waitForStatus:kGHUnitWaitStatusSuccess timeout:1.0];
}

- (void)testKioskCancelDelegateTest
{
    NSString    *title = [PCLocalizationManager localizedStringForKey:@"KIOSK_BUTTON_TITLE_CANCEL"
                                                                value:@"Cancel"];
    UIButton    *button = [self controlElementButtonWithTitle:title];
    
    GHAssertNotNil(button, [NSString stringWithFormat:@"Kiosk control element must contains %@ button", title]);
    
    [self prepare];
    [self sendTapEventToButton:button
              withTestSelector:@selector(testKioskCancelDelegateTest)];
    
    [self waitForStatus:kGHUnitWaitStatusSuccess timeout:1.0];
}

- (void)testKioskReadDelegateTest
{
    NSString    *title = [PCLocalizationManager localizedStringForKey:@"KIOSK_BUTTON_TITLE_READ"
                                                                value:@"Read"];
    UIButton    *button = [self controlElementButtonWithTitle:title];
    
    GHAssertNotNil(button, [NSString stringWithFormat:@"Kiosk control element must contains %@ button", title]);
    
    [self prepare];
    [self sendTapEventToButton:button
              withTestSelector:@selector(testKioskReadDelegateTest)];
    
    [self waitForStatus:kGHUnitWaitStatusSuccess timeout:1.0];
}

- (void)testKioskDeleteDelegateTest
{
    NSString    *title = [PCLocalizationManager localizedStringForKey:@"KIOSK_BUTTON_TITLE_DELETE"
                                                                value:@"Delete"];
    UIButton    *button = [self controlElementButtonWithTitle:title];
    
    GHAssertNotNil(button, [NSString stringWithFormat:@"Kiosk control element must contains %@ button", title]);
    
    [self prepare];
    [self sendTapEventToButton:button
              withTestSelector:@selector(testKioskDeleteDelegateTest)];
    
    [self waitForStatus:kGHUnitWaitStatusSuccess timeout:1.0];
}

- (UIButton*)controlElementButtonWithTitle:(NSString*)title
{
    NSArray     *subviews = [kioskViewController kioskSubviews];
    
    for (PCKioskSubview *cur in subviews)
    {
        if([cur isKindOfClass:[PCTKioskGalleryView class]])
        {
            PCTKioskGalleryView             *galleryView = (PCTKioskGalleryView*)cur;
            PCTKioskGalleryControlElement   *galleryControlElement = (PCTKioskGalleryControlElement*)galleryView.controlElement;
            
            for(UIView *curSubview in galleryControlElement.subviews)
            {
                if([curSubview isKindOfClass:[UIButton class]])
                {
                    UIButton        *button = (UIButton*)curSubview;
                    NSString        *title = [button titleForState:UIControlStateNormal];
                    
                    if([[title uppercaseString] isEqualToString:[title uppercaseString]])
                    {
                        return button;
                    }
                }
            }
        }
    }
    return nil;
}

- (void)sendTapEventToButton:(UIButton *) button withTestSelector:(SEL) testSelector
{
    ButtonTapTest       *test = [[[ButtonTapTest alloc] init] autorelease];
    
    test.destinationButton = button;
    test.testSelector = testSelector;
    
    [NSThread detachNewThreadSelector:@selector(sendTapEvent:)
                             toTarget:self
                           withObject:test];
}

- (void)notifyWithCurrentSelector
{
    [self notify:kGHUnitWaitStatusSuccess forSelector:currentTestSelector];
}

#pragma mark - threaded methods

- (void) sendTapEvent:(ButtonTapTest*)tapTest
{
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    
    currentTestSelector = tapTest.testSelector;
    [tapTest.destinationButton sendActionsForControlEvents:UIControlEventTouchUpInside];
    
    [pool release];
}

#pragma mark - PCKioskDataSourceProtocol

-(NSInteger) numberOfRevisions
{
    return 3;
}

-(NSString*) issueTitleWithIndex:(NSInteger) index
{
    if(index==0) return @"Issue1";
    if(index==1) return @"Issue2";
    if(index==2) return @"Issue3";
    return @"";
}

-(NSString*) revisionTitleWithIndex:(NSInteger) index
{
    if(index==0) return @"Revision1";
    if(index==1) return @"Revision2";
    if(index==2) return @"Revision3";
    return @"";
}

-(NSString*) revisionStateWithIndex:(NSInteger) index
{
    return @"";
}

-(BOOL) previewAvailableForRevisionWithIndex:(NSInteger) index
{
    return FALSE;
}

-(BOOL) isRevisionDownloadedWithIndex:(NSInteger) index
{
    return NO;
}

-(UIImage*) revisionCoverImageWithIndex:(NSInteger) index andDelegate:(id<PCKioskCoverImageProcessingProtocol>) delegate
{
    return nil;
}

-(BOOL) isRevisionPaidWithIndex:(NSInteger)index
{
    return FALSE;
}

-(NSString*) priceWithIndex:(NSInteger)index
{
    return @"";
}

-(NSString*) productIdentifierWithIndex:(NSInteger) index
{
    return nil;
}

#pragma mark - PCKioskViewControllerDelegateProtocol

- (void) downloadRevisionWithIndex:(NSInteger) index
{
    [self notifyWithCurrentSelector];
}

- (void) cancelDownloadingRevisionWithIndex:(NSInteger) index
{
    [self notifyWithCurrentSelector];
}

- (void) readRevisionWithIndex:(NSInteger) index
{
    [self notifyWithCurrentSelector];
}

- (void) deleteRevisionDataWithIndex:(NSInteger) index
{
    [self notifyWithCurrentSelector];
}

@end
