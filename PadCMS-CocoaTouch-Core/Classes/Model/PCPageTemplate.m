//
//  PCTemplate.m
//  Pad CMS
//
//  Created by Rustam Mallakurbanov on 02.02.12.
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
                              connectors:(PCPageTemplateConnectorOptions)aConnectors
{
    return [[[PCPageTemplate alloc] initWithIdentifier:aIdentifier
                                                 title:aTitle
                                           description:@""
                                            connectors:aConnectors
                                         engineVersion:1] autorelease];
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
