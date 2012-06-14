//
//  PCTemplate.m
//  Pad CMS
//
//  Created by Rustam Mallakurbanov on 02.02.12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import "PCPageTemplate.h"

@implementation PCPageTemplate

@synthesize identifier;
@synthesize title;
@synthesize description;
@synthesize connectors;
@synthesize engineVersion;

-(void)dealloc
{
    [title release];
    [description release];
    [super dealloc];
}

+(PCPageTemplate*)templateWithIdentifier:(NSInteger) aIdentifier
                               title:(NSString*) aTitle
                         description:(NSString*) aDescription
                          connectors:(PCPageTemplateConnectorOptions)aConnectors
                       engineVersion:(NSInteger) aEngineVersion;
{
    return [[[PCPageTemplate alloc] initWithIdentifier:aIdentifier 
                                             title:aTitle 
                                       description:aDescription 
                                        connectors:aConnectors
                                     engineVersion:aEngineVersion] autorelease]; 
}

-(PCPageTemplate*)initWithIdentifier:(NSInteger) aIdentifier
                           title:(NSString*) aTitle
                     description:(NSString*) aDescription
                      connectors:(PCPageTemplateConnectorOptions)aConnectors
                   engineVersion:(NSInteger) aEngineVersion;
{
    if (self = [super init])
    {
        identifier = aIdentifier;
        title = [aTitle retain];
        description = [aDescription retain];
        connectors = aConnectors;
        engineVersion = aEngineVersion;
    }
    return self;
}

-(BOOL) hasRightConnector
{
    return connectors & PCTemplateRightConnector;
}

-(BOOL) hasLeftConnector
{
    return connectors & PCTemplateLeftConnector;
}

-(BOOL) hasTopConnector
{
    return connectors & PCTemplateTopConnector;
}

-(BOOL) hasBottomConnector
{
    return connectors & PCTemplateBottomConnector;
}

- (NSString *)description
{
    return [NSString stringWithFormat:
            @"%@\n"
            "identifier:%d\n"
            "title:%@\n"
            "description:%@\n"
            "connectors:%d\n"
            "engineVersion:%d", 
            [super description], 
            identifier,
            title,
            description,
            connectors,
            engineVersion];
}

@end
