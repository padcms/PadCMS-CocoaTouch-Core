//
//  PCTemplate.h
//  Pad CMS
//
//  Created by Rustam Mallakurbanov on 02.02.12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import <Foundation/Foundation.h>

enum
{
    PCTemplateConnectorsNone        = 0,    ///< The page hasn't any connectors. In theory page should have at least one connector
    PCTemplateRightConnector        = 1<<0, ///< Right Page Connector
    PCTemplateLeftConnector         = 1<<1, ///< Left Page Connector
    PCTemplateTopConnector          = 1<<2, ///< Top Page Connector
    PCTemplateBottomConnector       = 1<<3, ///< Bottom Page Connector
    PCTemplateHorizontalConnectors  = PCTemplateRightConnector|PCTemplateLeftConnector, ///< Horizontal Page Connectors
    PCTemplateAllConnectors         = PCTemplateRightConnector|PCTemplateLeftConnector|PCTemplateTopConnector|PCTemplateBottomConnector, ///< All Page Connectors
};
typedef NSUInteger PCPageTemplateConnectorOptions; ///< Defines which connectors can template have

/**
 @class PCPageTemplate
 @brief This class is a part of page template model. All templates are located in templates pool.
 */

@interface PCPageTemplate : NSObject
{
    NSInteger identifier;
    NSString* title;
    NSString* description;
    PCPageTemplateConnectorOptions connectors;
    NSInteger engineVersion;
}

/**
@brief Create template.
@param aIdentifier - template identifier
@param aTitle - template title
@param aDescription - template description
@param aConnectors - copnector options
@param aEngineVersion - version of engine  
*/
+(PCPageTemplate*)templateWithIdentifier:(NSInteger) aIdentifier
                  title:(NSString*) aTitle
            description:(NSString*) aDescription
             connectors:(PCPageTemplateConnectorOptions)aConnectors
          engineVersion:(NSInteger) aEngineVersion;

/**
 @brief Create template.
 @param aIdentifier - template identifier
 @param aTitle - template title
 @param aDescription - template description
 @param aConnectors - copnector options
 @param aEngineVersion - version of engine   
 */
-(PCPageTemplate*)initWithIdentifier:(NSInteger) aIdentifier
                  title:(NSString*) aTitle
            description:(NSString*) aDescription
             connectors:(PCPageTemplateConnectorOptions)aConnectors
          engineVersion:(NSInteger) aEngineVersion;

/**
 @brief Template identifier
 */
@property (nonatomic,readonly) NSInteger identifier;

/**
 @brief Template title
 */
@property (nonatomic,readonly) NSString* title;

/**
 @brief Template description
 */
@property (nonatomic,readonly) NSString* description;

/**
 @brief Template engine version
 */
@property (nonatomic,readonly) NSInteger engineVersion;

/**
 @brief Defines which connectors can template have
 */
@property (nonatomic,readonly) PCPageTemplateConnectorOptions connectors;

/**
 @brief Defines if the page of such template can have right connector
 */
-(BOOL) hasRightConnector;

/**
 @brief Defines if the page of such template can have left connector
 */
-(BOOL) hasLeftConnector;

/**
 @brief Defines if the page of such template can have top connector
 */
-(BOOL) hasTopConnector;

/**
 @brief Defines if the page of such template can have bottom connector
 */
-(BOOL) hasBottomConnector;

@end
