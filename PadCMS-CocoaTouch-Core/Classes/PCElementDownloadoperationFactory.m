//
//  PCElementDownloadoperationFactory.m
//  Pad CMS
//
//  Created by admin on 02.03.12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import "PCElementDownloadOperationFactory.h"
#import "PCElementDownloadOperation.h"
#import "PCElementMiniArticleDownloadOperation.h"
#import "PCPageElement.h"
#import "PCPageElementMiniArticle.h"

#import "PCPageElementHtml5.h"
#import "PCElementHTML5DownloadOperation.h"
#import "PCElementHTML5RssNewsDownloadOperation.h"
#import "PCElementHTML5TwitterJSONDownloadOperation.h"

@implementation PCElementDownloadOperationFactory

+(PCElementDownloadOperationFactory*)factory
{
    static PCElementDownloadOperationFactory* factory = nil;
    if (factory == nil)
    {
        factory = [[PCElementDownloadOperationFactory alloc] init];
    }
    return factory;
}

-(PCElementDownloadOperation*)operationForElement:(PCPageElement*)element toHomeDirectory:(NSString*)homeDirectory
{
    if ([element.fieldTypeName isEqualToString:PCPageElementTypeAdvert]||
        [element.fieldTypeName isEqualToString:PCPageElementTypeBackground]||
        [element.fieldTypeName isEqualToString:PCPageElementTypeBody]||
        [element.fieldTypeName isEqualToString:PCPageElementTypeSound]||
        [element.fieldTypeName isEqualToString:PCPageElementTypePopup]||
        [element.fieldTypeName isEqualToString:PCPageElementTypeGallery]||
        [element.fieldTypeName isEqualToString:PCPageElementTypeOverlay]||
        [element.fieldTypeName isEqualToString:PCPageElementTypeHtml]||        
        [element.fieldTypeName isEqualToString:PCPageElementTypeVideo]||
        [element.fieldTypeName isEqualToString:PCPageElementTypeScrollingPane]||
        [element.fieldTypeName isEqualToString:PCPageElementTypeSlide]) { 
        
        NSString* filePath = [homeDirectory stringByAppendingPathComponent:element.resource];
        if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
            return nil;
        }
        PCElementDownloadOperation* operation = [[PCElementDownloadOperation alloc] initWithElement:element];
        operation.filePath = filePath;
        return [operation autorelease];
        
    } else if([element.fieldTypeName isEqualToString:PCPageElementTypeMiniArticle]||
              [element.fieldTypeName isEqualToString:PCPageElementTypeDragAndDrop]
              ) {
        PCPageElementMiniArticle* miniArticleElement = (PCPageElementMiniArticle*)element;
        NSString* filePath = [homeDirectory stringByAppendingPathComponent:element.resource];
        if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
            filePath = [homeDirectory stringByAppendingPathComponent:miniArticleElement.thumbnail];
            if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
                if (miniArticleElement.thumbnailSelected) {
                    filePath = [homeDirectory stringByAppendingPathComponent:miniArticleElement.thumbnailSelected];
                    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
                        return nil;
                    }
                }
                return nil;
            }
        }
        PCElementMiniArticleDownloadOperation* operation = [[PCElementMiniArticleDownloadOperation alloc] initWithElement:element];
        operation.filePath = [homeDirectory stringByAppendingPathComponent:element.resource];        
        operation.thumbnailFilePath = [homeDirectory stringByAppendingPathComponent:miniArticleElement.thumbnail];
        operation.thumbnailSelectedFilePath = [homeDirectory stringByAppendingPathComponent:miniArticleElement.thumbnailSelected];
        return [operation autorelease];
        
    } else if([element.fieldTypeName isEqualToString:PCPageElementTypeHtml5]){
        
        PCPageElementHtml5* html5Element = (PCPageElementHtml5*)element;
        if ([html5Element.html5Body isEqualToString:PCPageElementHtml5BodyCodeType]) {
            
            NSString* zipFile = [homeDirectory stringByAppendingPathComponent:html5Element.resource];
            NSString* html5Dir = [zipFile stringByDeletingPathExtension];
            if (![[NSFileManager defaultManager] fileExistsAtPath:zipFile])
            {
                if (![[NSFileManager defaultManager] fileExistsAtPath:html5Dir])
                {
                    PCElementHTML5DownloadOperation* operation = [[PCElementHTML5DownloadOperation alloc] initWithElement:html5Element];
                    operation.filePath = [homeDirectory stringByAppendingPathComponent:html5Element.resource]; 
                    return [operation autorelease];
                }
            }
            
        } else if ([html5Element.html5Body isEqualToString:PCPageElementHtml5BodyRSSFeedType]) {
            
            PCElementHTML5RssNewsDownloadOperation* operation = [[PCElementHTML5RssNewsDownloadOperation alloc] initWithElement:html5Element];
            
            operation.filePath = [homeDirectory stringByAppendingPathComponent:[html5Element rssNewsXmlFilePath]];
            
            return [operation autorelease];
            
        } else if ([html5Element.html5Body isEqualToString:PCPageElementHtml5BodyTwitterType]) {
            
            PCElementHTML5TwitterJSONDownloadOperation* operation = [[PCElementHTML5TwitterJSONDownloadOperation alloc] initWithElement:html5Element];
            
            operation.filePath = [homeDirectory stringByAppendingPathComponent:[html5Element twitterJSONFilePath]];
            
            return [operation autorelease];
        }
        
        return nil;
        
        
    }
    return nil;
}

@end
