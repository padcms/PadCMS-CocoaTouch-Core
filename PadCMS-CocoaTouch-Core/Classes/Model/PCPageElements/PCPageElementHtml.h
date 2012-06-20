//
//  PCPageElementHtml.h
//  Pad CMS
//
//  Created by Rustam Mallakurbanov on 03.02.12.
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

#import "PCPageElement.h"

typedef enum _PCPageElementHtmlType
{
    PCPageElementHtmlUnknowType     = 0, ///< Unknow Type 
    PCPageElementHtmlTouchType      = 1, ///< Displays HTML page when user touches the display
    PCPageElementHtmlRotationType   = 2 ///< Displays HTML page when user rotate device
} PCPageElementHtmlType; ///< Displays HTML Type

/**
 @class PCPageElementHtml
 @brief Represents Html element of the page.
 */

@interface PCPageElementHtml : PCPageElement
{
    NSString* htmlUrl;
    PCPageElementHtmlType templateType;
}

@property (nonatomic,retain) NSString* htmlUrl; ///< page's URL
@property (nonatomic,assign) PCPageElementHtmlType templateType; ///< Displays HTML page when user rotate device (if templateType = PCPageElementHtmlRotationType) or user touches the display (if templateType = PCPageElementHtmlTouchType )

@end
