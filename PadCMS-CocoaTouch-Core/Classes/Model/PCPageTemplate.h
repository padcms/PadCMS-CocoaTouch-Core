//
//  PCTemplate.h
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
