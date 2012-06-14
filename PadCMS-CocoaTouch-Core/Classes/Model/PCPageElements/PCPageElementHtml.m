//
//  PCPageElementHtml.m
//  Pad CMS
//
//  Created by Rustam Mallakurbanov on 03.02.12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import "PCPageElementHtml.h"

@implementation PCPageElementHtml

@synthesize htmlUrl;
@synthesize templateType;

- (void)dealloc
{
    [htmlUrl release];
    htmlUrl = nil;
    [super dealloc];
}

- (id)init
{
    if (self = [super init])
    {
        templateType = PCPageElementHtmlUnknowType;
        htmlUrl = nil;
    }
    return self;
}

- (void)pushElementData:(NSDictionary*)data
{
    [super pushElementData:data];
    NSString* tepmplateType = [data objectForKey:PCSQLiteElementTemplateTypeAttributeName];
   
    if ([tepmplateType isEqualToString:PCSQLiteTemplateTouchType]) 
        self.templateType = PCPageElementHtmlTouchType;
    
    if ([tepmplateType isEqualToString:PCSQLiteTemplateRotationType])
        self.templateType = PCPageElementHtmlRotationType;

    self.htmlUrl = [data objectForKey:PCSQLiteElementHtmlURLAttributeName];    
}

@end
