//
//  PCKioskDataSourceProtocol.h
//  Pad CMS
//
//  Created by Oleg Zhitnik on 23.04.12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PCKioskCoverImageProcessingProtocol.h"

@protocol PCKioskDataSourceProtocol <NSObject>

-(NSInteger) numberOfRevisions;

-(NSString*) issueTitleWithIndex:(NSInteger) index;
-(NSString*) revisionTitleWithIndex:(NSInteger) index;
-(NSString*) revisionStateWithIndex:(NSInteger) index;
-(BOOL) isRevisionDownloadedWithIndex:(NSInteger) index;
-(UIImage*) revisionCoverImageWithIndex:(NSInteger) index andDelegate:(id<PCKioskCoverImageProcessingProtocol>) delegate;
-(BOOL) isRevisionPaidWithIndex:(NSInteger)index;
-(NSString*) priceWithIndex:(NSInteger)index;
-(NSString*) productIdentifierWithIndex:(NSInteger) index;

@end
