//
//  PCSQLLiteModelBuilder.m
//  Pad CMS
//
//  Created by Rustam Mallakurbanov on 15.02.12.
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

#import "PCSQLLiteModelBuilder.h"
#import "PCPathHelper.h"
#import "FMDatabase.h"
#import "PCSQLiteKeys.h"
#import "PCPageElementManager.h"
#import "PCPageActiveZone.h"
#import "UIColor+HexString.h"
#import "PCRevision.h"
#import "PCLocalizationManager.h"

@interface PCSQLLiteModelBuilder(ForwardDeclaration)

+ (void)addPagesFromSQLiteBaseWithPath:(NSString*)path toMagazine:(PCIssue*)magazine;
+ (PCPageElement*)buildPageElement:(FMResultSet*)element withDataBase:(FMDatabase*)dataBase;

@end

@implementation PCSQLLiteModelBuilder

+ (void)addPagesFromSQLiteBaseWithPath:(NSString*)path toRevision:(PCRevision*)revision
{
    FMDatabase* base = [[FMDatabase alloc] initWithPath:path];
    [base open];
    [base setShouldCacheStatements:YES];
    NSString* pagesQuery = [NSString stringWithFormat:@"select * from %@",PCSQLitePageTableName];
	NSMutableArray* wrongPages = [NSMutableArray array];
    FMResultSet* pages = [base executeQuery:pagesQuery];
    
    while ([pages next]) 
    {
        PCPage* page = [[PCPage alloc] init];
        page.identifier = [pages intForColumn:PCSQLiteIDColumnName];
        page.machineName = [pages stringForColumn:PCSQLiteMachineNameColumnName];
		NSString* bgColorHexString = [pages stringForColumn:PCSQLitePageBackgroundColor];
		page.backgroundColor = bgColorHexString?[UIColor colorWithHexString:bgColorHexString]:[UIColor whiteColor];
        NSInteger templateID = [pages intForColumn:PCSQLiteTemplateColumnName];
        page.pageTemplate = [[PCPageTemplatesPool templatesPool] templateForId:templateID];
        
        page.title = [pages stringForColumn:PCSQLiteTitleColumnName];
        page.horisontalPageIdentifier = [pages intForColumn:PCSQLiteHorisontalPageIDColumnName];
        
        NSString* pageImpositionQuery = [NSString stringWithFormat:@"select * from %@ where %@=?",PCSQLitePageImpositionTableName,PCSQLitePageIDColumnName];
        FMResultSet* pageImposition = [base executeQuery:pageImpositionQuery,[NSNumber numberWithInt:page.identifier]];
        
        while ([pageImposition next])
        {
            NSInteger pageID = [pageImposition intForColumn:PCSQLiteIsLinkedToColumnName];
            NSString* positionType = [pageImposition stringForColumn:PCSQLitePositionTypeColumnName];
            PCPageTemplateConnectorOptions option = -1;
            
            if ([positionType isEqualToString:PCSQLitePositionRightTypeValue])
                option = PCTemplateRightConnector;
            
            if ([positionType isEqualToString:PCSQLitePositionLeftTypeValue])
                option = PCTemplateLeftConnector;
            
            if ([positionType isEqualToString:PCSQLitePositionTopTypeValue])
                option = PCTemplateTopConnector;
            
            if ([positionType isEqualToString:PCSQLitePositionBottomTypeValue])
                option = PCTemplateBottomConnector;
            
			[page.links setObject:[NSNumber numberWithInt:pageID] forKey:[NSNumber numberWithInt:option]];
        }
		
		if (page.pageTemplate == nil)
		{
			
			[wrongPages addObject:page];
			continue;
		}
        
        NSString* elementsQuery = [NSString stringWithFormat:@"select * from %@ where %@=?",PCSQLiteElementTableName,PCSQLitePageIDColumnName];
        FMResultSet* elements = [base executeQuery:elementsQuery,[NSNumber numberWithInt:page.identifier]];
        while ([elements next])
        {
            PCPageElement* element = [self buildPageElement:elements withDataBase:base];
			if (element != nil){
				[page.elements addObject:element];
				element.page = page;
				if (![element.fieldTypeName isEqualToString:PCPageElementTypeHtml] &&
					![element.fieldTypeName isEqualToString:PCPageElementTypeHtml5] &&
					![element.fieldTypeName isEqualToString:PCPageElementType3D] &&
					![element.fieldTypeName isEqualToString:PCPageElementTypeSound] &&
					![element.fieldTypeName isEqualToString:PCPageElementTypeVideo])
				{
					element.isCropped = YES;
					element.resource = [[element.resource stringByDeletingPathExtension] stringByAppendingPathExtension:@"zip"];
				}
				/*	if ((element.page.pageTemplate.identifier == PCBasicArticlePageTemplate) && ([element.fieldTypeName isEqualToString:PCPageElementTypeBody])) 
				 {
				 element.resource = [[element.resource stringByDeletingPathExtension] stringByAppendingPathExtension:@"zip"];
				 }*/
				
			}
        }
		
        [revision.pages addObject:page];
        page.revision = revision;
/*        for (PCPageElement* element in page.elements)
		{
			[element calculateSize];
		}*/
        [page release];
    }
	
	
	for (PCPage* page in wrongPages) {
		[revision.pages enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
			PCPage* p = (PCPage*)obj;
			NSArray* keys = [p.links allKeysForObject:[NSNumber numberWithInt:page.identifier]];
			for (NSNumber* key in keys) {
				NSNumber* newPageIdToLink = [page.links objectForKey:key];
				if (newPageIdToLink)
				{
					[p.links setObject:newPageIdToLink forKey:key];
				}
				else {
					[p.links removeObjectForKey:key];
				}
			}
		}];
		
	}
	
	
	//Creating backward links
	
	for (PCPage* page in revision.pages) {
		
        NSNumber *pageIdentifier = [NSNumber numberWithInt:page.identifier];
		
        // horizontal connections
        NSNumber *leftConnector = [NSNumber numberWithInt:PCTemplateLeftConnector];
        NSNumber *rightConnector = [NSNumber numberWithInt:PCTemplateRightConnector];
		
        PCPage *leftPage = [revision pageForLink:[page.links objectForKey:leftConnector]];
        if (leftPage != nil) {
            [leftPage.links setObject:pageIdentifier forKey:rightConnector];
        }
		
        PCPage *rightPage = [revision pageForLink:[page.links objectForKey:rightConnector]];
        if (rightPage != nil) {
            [rightPage.links setObject:pageIdentifier forKey:leftConnector];
        }
		
        // vertical connections
        NSNumber *topConnector = [NSNumber numberWithInt:PCTemplateTopConnector];
        NSNumber *bottomConnector = [NSNumber numberWithInt:PCTemplateBottomConnector];
        
        PCPage *topPage = [revision pageForLink:[page.links objectForKey:topConnector]];
        if (topPage != nil) {
            [topPage.links setObject:pageIdentifier forKey:bottomConnector];
        }
		
        PCPage *bottomPage = [revision pageForLink:[page.links objectForKey:bottomConnector]];
        if (bottomPage != nil) {
            [bottomPage.links setObject:pageIdentifier forKey:topConnector];
        }
		
		
	}
	
	//creating horizontal links for column pages
	for (PCPage* page in revision.pages) 
	{
		NSNumber *leftConnector = [NSNumber numberWithInt:PCTemplateLeftConnector];
        NSNumber *rightConnector = [NSNumber numberWithInt:PCTemplateRightConnector];
		NSNumber *topConnector = [NSNumber numberWithInt:PCTemplateTopConnector];
		PCPage *leftPage = [revision pageForLink:[page.links objectForKey:leftConnector]];
       
        PCPage *rightPage = [revision pageForLink:[page.links objectForKey:rightConnector]];
		
		
        
		if (!rightPage && !leftPage)
		{
			PCPage *topPage = page;
			do {
				
				topPage = [revision pageForLink:[topPage.links objectForKey:topConnector]];

				PCPage *leftPage = [revision pageForLink:[topPage.links objectForKey:leftConnector]];
				if (leftPage != nil) {
					[page.links setObject: [NSNumber numberWithInt:leftPage.identifier] forKey:leftConnector];
				}
				
				PCPage *rightPage = [revision pageForLink:[topPage.links objectForKey:rightConnector]];
				
				if (rightPage != nil) {
					[page.links setObject: [NSNumber numberWithInt:rightPage.identifier] forKey:rightConnector];
				}
			} while (leftPage || rightPage);
		}
	}
	
	
	
    
    NSString* horisontalPagesQuery = [NSString stringWithFormat:@"select * from %@",PCSQLitePageHorisontalTableName];
    FMResultSet* horisontalPages = [base executeQuery:horisontalPagesQuery];
    
    [revision.horizontalToc removeAllObjects];
    
    while ([horisontalPages next]) 
    {
        NSInteger horisontalPageId = [horisontalPages intForColumn:PCSQLiteIDColumnName];
        NSString* resources = [horisontalPages stringForColumn:PCSQLiteResourceColumnName];
        [revision.horizontalPages setObject:resources forKey:[NSNumber numberWithInt:horisontalPageId]];
		
		PCPage* horizontalPage = [[PCPage alloc] init];
        horizontalPage.identifier = horisontalPageId;
		
        horizontalPage.pageTemplate = [[PCPageTemplatesPool templatesPool] templateForId:PCSimplePageTemplate];
        
        horizontalPage.title = [pages stringForColumn:PCSQLiteHorizontalTitleColumnName];
        horizontalPage.horisontalPageIdentifier = [pages intForColumn:PCSQLiteHorisontalPageIDColumnName];
		horizontalPage.isHorizontal = YES;
		horizontalPage.revision = revision;
		PCPageElement* element = [[PCPageElement alloc] init];
		element.fieldTypeName = @"body";
#warning need element identifier in db
		element.identifier = NSIntegerMax - horisontalPageId;
		element.weight = 0;
		NSMutableDictionary* elementDatas = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"1024",@"width",@"768",@"height",resources,@"resource", nil];
		[element pushElementData:elementDatas];
		[element setDataRects:[NSMutableDictionary dictionary]];
		element.page = horizontalPage;
		[horizontalPage.elements addObject:element];
		PCPage* previousPage = [revision.newHorizontalPages lastObject];
		if (previousPage)
		{
			[previousPage.links setObject:[NSNumber numberWithInt:horisontalPageId] forKey:[NSNumber numberWithInt:PCTemplateRightConnector]];
			[horizontalPage.links setObject:[NSNumber numberWithInt:previousPage.identifier] forKey:[NSNumber numberWithInt:PCTemplateLeftConnector]];
		}
		
		[revision.newHorizontalPages addObject:horizontalPage];
#define OLD_HORIZONTAL_PAGE_STYLE_SUPPORT		
#ifdef OLD_HORIZONTAL_PAGE_STYLE_SUPPORT
#warning old code support is enabled
		PCHorizontalPage* horPage = [[PCHorizontalPage alloc] init];
        horPage.identifier = [NSNumber numberWithInt:horisontalPageId];
		[revision.horisontalPagesObjects setObject:horPage forKey:[NSNumber numberWithInt:horisontalPageId]];
		[horPage release];
#endif
		
		
        NSString *horisontalTocItemPath = [resources stringByReplacingOccurrencesOfString:@"1024-768" withString:@"204-153"];
        [revision.horisontalTocItems setObject:horisontalTocItemPath forKey:[NSNumber numberWithInt:horisontalPageId]];
        
        PCTocItem *tocItem = [[[PCTocItem alloc] init] autorelease];
        tocItem.firstPageIdentifier = horizontalPage.identifier;
        tocItem.thumbStripe = [@"horisontal_toc_items" stringByAppendingPathComponent:horisontalTocItemPath];
        [revision.horizontalToc addObject:tocItem];
        
        [horizontalPage release];
    }
	
	
	
    
    NSString* menusQuery = [NSString stringWithFormat:@"select * from %@",PCSQLiteMenuTableName];
    FMResultSet* menus = [base executeQuery:menusQuery];
    
    [revision.toc removeAllObjects];
    
    while ([menus next]) 
    {
        NSString *title = [menus stringForColumn:PCSQLiteTitleColumnName];
        NSString *description = [menus stringForColumn:PCSQLiteDescriptionColumnName];
        NSString *colorString = [menus stringForColumn:PCSQLiteColorColumnName];
        NSString *thumbStripe = [menus stringForColumn:PCSQLiteThumbStripeColumnName];
        NSString *thumbSummary = [menus stringForColumn:PCSQLiteThumbSummaryColumnName];
        NSString *firstPageIdentifierString = [menus stringForColumn:PCSQLiteFirstpageIDColumnName];
        
        if (thumbStripe == nil ||
            [thumbStripe isEqualToString:@""] ||
            firstPageIdentifierString == nil ||
            [firstPageIdentifierString isEqualToString:@""]) {
            continue;
        }
        
        PCTocItem *tocItem = [[[PCTocItem alloc] init] autorelease];
        tocItem.title = title;
        tocItem.tocItemDescription = description;
        
        if (colorString != nil && ![colorString isEqualToString:@""]) {
            tocItem.color = [PCDataHelper colorFromString:colorString];
        }
        
        tocItem.thumbStripe = thumbStripe;
        tocItem.thumbSummary = thumbSummary;
        tocItem.firstPageIdentifier = firstPageIdentifierString.integerValue;

        PCPage* page = [revision pageWithId:tocItem.firstPageIdentifier];
        if (page != nil && tocItem.color != nil) {
            page.color = tocItem.color;
        }
        
        [revision.toc addObject:tocItem];
    }
    
    [revision updateColumns]; 
    [base release];
	
	if ([wrongPages lastObject])
	{
		NSString* message = [PCLocalizationManager localizedStringForKey:@"MSG_PAGE_WITH_NOT_IMPLEMENTED_TEMPLATE_IN_REVISION"
                                                                   value:@"Your application can't display all the pages of this magazine because it has not been updated. Please update it"];
		
		dispatch_async(dispatch_get_main_queue(), ^{
			UIAlertView* alert = [[UIAlertView alloc] initWithTitle:[PCLocalizationManager localizedStringForKey:@"TITLE_WARNING"
                                                                                                           value:@"Warning!"]
                                                            message:message
                                                           delegate:nil
                                                  cancelButtonTitle:[PCLocalizationManager localizedStringForKey:@"BUTTON_TITLE_OK"
                                                                                                           value:@"OK"]
                                                  otherButtonTitles:nil];
			[alert show];
			[alert release];
		});
		
	}
}

+(PCPageElement*)buildPageElement:(FMResultSet*)elementData withDataBase:(FMDatabase*)dataBase
{
    NSString* fieldTypeName = [elementData stringForColumn:PCSQLiteElementTypeNameColumnName];
    NSInteger elementID = [elementData intForColumn:PCSQLiteIDColumnName];
	
    PCPageElement* pageElement = nil;
    NSMutableDictionary* elementDatas = [[NSMutableDictionary alloc] init];
    NSString* elementDataQuery = [NSString stringWithFormat:@"select * from %@ where %@=?",PCSQLiteElementDataTableName,PCSQLiteElementIDColumnName];
    NSMutableDictionary* elementDataRects = [[NSMutableDictionary alloc] init];
    
    NSMutableArray* elementActiveZones = [[NSMutableArray alloc] init];
    
    FMResultSet* data = [dataBase executeQuery:elementDataQuery,[NSNumber numberWithInt:elementID]];
	
    while ([data next]) 
    {
        NSString* value = [data stringForColumn:PCSQLiteValueColumnName];
        NSString* type = [data stringForColumn:PCSQLiteTypeColumnName];
		
        [elementDatas setObject:value forKey:type];
        int position_id = [data intForColumn:PCSQLitePositionIDColumnName];
        
        PCPageActiveZone *activeZone = nil;
        
        if([type isEqualToString:PCSQLiteElementActiveZoneAttributeName])
        {
            activeZone = [[PCPageActiveZone alloc] init];
            activeZone.URL = value;
        }
        
        if (position_id > 0)
        {
            NSString* positionDataQuery = [NSString stringWithFormat:@"select * from %@ where %@=?",PCSQLiteElementDataPositionTableName,PCSQLiteIDColumnName];
            [dataBase setLogsErrors:YES];
            FMResultSet* positionData = [dataBase executeQuery:positionDataQuery,[NSNumber numberWithInt:position_id]];
            while ([positionData next])
            {
                CGPoint startpoint = CGPointZero;
                CGPoint endPoint   = CGPointZero;
                
                startpoint.x =  [positionData doubleForColumn:PCSQLiteStartXColumnName];
                startpoint.y =  [positionData doubleForColumn:PCSQLiteStartYColumnName];
                endPoint.x   =  [positionData doubleForColumn:PCSQLiteEndXColumnName];
                endPoint.y   =  [positionData doubleForColumn:PCSQLiteEndYColumnName];
                CGRect elementRect = CGRectMake(MIN(startpoint.x,endPoint.x),
                                                MIN(startpoint.y,endPoint.y),
                                                MAX(startpoint.x,endPoint.x)-MIN(startpoint.x,endPoint.x),
                                                MAX(startpoint.y,endPoint.y)-MIN(startpoint.y,endPoint.y)); 
                if (elementRect.origin.y<0)
                {
                    elementRect.size.height+=2*elementRect.origin.y;
                    elementRect.origin.y=0;
                }
                if (elementRect.origin.x<0)
                {
                    elementRect.size.width+=2*elementRect.origin.x;
                    elementRect.origin.x=0;
                }
                [elementDataRects setObject:NSStringFromCGRect(elementRect) forKey:value];
                
                if([type isEqualToString:PCSQLiteElementActiveZoneAttributeName])
                    activeZone.rect = elementRect;
            }
        }
        
        if(activeZone != nil)
        {
            [elementActiveZones addObject:activeZone];
        }
    }
    
	
    Class pageElementClass = [[PCPageElementManager sharedManager] elementClassForElementType:fieldTypeName];
    pageElement = [[pageElementClass alloc] init];
    
    if (pageElement != nil)
    {
        pageElement.fieldTypeName = fieldTypeName;
        pageElement.identifier = elementID;
        pageElement.contentText = [elementData stringForColumn:PCSQLiteContentTextColumnName];
        if ([elementData intForColumn:PCSQLiteWeightColumnName])
            pageElement.weight = [elementData intForColumn:PCSQLiteWeightColumnName];
    }
    
    [pageElement pushElementData:elementDatas];
    [pageElement setDataRects:elementDataRects];
    [pageElement.activeZones addObjectsFromArray:elementActiveZones];
	[elementDatas release];
    [elementDataRects release];
    [elementActiveZones release];
    return [pageElement autorelease];
}

@end
