//
//  PCSQLiteKeys.h
//  Pad CMS
//
//  Created by Rustam Mallakurbanov on 17.02.12.
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
#import "PCMacros.h"

PADCMS_EXTERN NSString* PCSQLitePageTableName;
PADCMS_EXTERN NSString* PCSQLitePageImpositionTableName;
PADCMS_EXTERN NSString* PCSQLitePageBackgroundColor;
PADCMS_EXTERN NSString* PCSQLiteElementTableName;
PADCMS_EXTERN NSString* PCSQLiteElementDataTableName;
PADCMS_EXTERN NSString* PCSQLiteElementDataPositionTableName;
PADCMS_EXTERN NSString* PCSQLiteMenuTableName;
PADCMS_EXTERN NSString* PCSQLitePageHorisontalTableName;
PADCMS_EXTERN NSString* PCSQLiteCrosswordsTableName;
PADCMS_EXTERN NSString* PCSQLiteCrosswordsContentTableName;

PADCMS_EXTERN NSString* PCSQLiteIDColumnName;
PADCMS_EXTERN NSString* PCSQLiteTitleColumnName;
PADCMS_EXTERN NSString* PCSQLiteHorizontalTitleColumnName;
PADCMS_EXTERN NSString* PCSQLiteHorisontalPageIDColumnName;
PADCMS_EXTERN NSString* PCSQLiteTemplateColumnName;
PADCMS_EXTERN NSString* PCSQLiteMachineNameColumnName;
PADCMS_EXTERN NSString* PCSQLitePageIDColumnName;
PADCMS_EXTERN NSString* PCSQLiteIsLinkedToColumnName;
PADCMS_EXTERN NSString* PCSQLitePositionTypeColumnName;
PADCMS_EXTERN NSString* PCSQLiteElementTypeNameColumnName;
PADCMS_EXTERN NSString* PCSQLiteWeightColumnName;
PADCMS_EXTERN NSString* PCSQLiteContentTextColumnName;
PADCMS_EXTERN NSString* PCSQLiteElementIDColumnName;
PADCMS_EXTERN NSString* PCSQLiteTypeColumnName;
PADCMS_EXTERN NSString* PCSQLiteValueColumnName;
PADCMS_EXTERN NSString* PCSQLitePositionIDColumnName;
PADCMS_EXTERN NSString* PCSQLiteElementZoom;
PADCMS_EXTERN NSString* PCSQLiteStartXColumnName;
PADCMS_EXTERN NSString* PCSQLiteStartYColumnName;
PADCMS_EXTERN NSString* PCSQLiteEndXColumnName;
PADCMS_EXTERN NSString* PCSQLiteEndYColumnName;
PADCMS_EXTERN NSString* PCSQLiteFirstpageIDColumnName;
PADCMS_EXTERN NSString* PCSQLiteDescriptionColumnName;
PADCMS_EXTERN NSString* PCSQLiteThumbStripeColumnName;
PADCMS_EXTERN NSString* PCSQLiteThumbSummaryColumnName;
PADCMS_EXTERN NSString* PCSQLiteColorColumnName;
PADCMS_EXTERN NSString* PCSQLiteNameColumnName;
PADCMS_EXTERN NSString* PCSQLiteResourceColumnName;
PADCMS_EXTERN NSString* PCSQLiteCrosswordWidthColumnName;
PADCMS_EXTERN NSString* PCSQLiteCrosswordHeightColumnName;
PADCMS_EXTERN NSString* PCSQLiteCrosswordIDColumnName;
PADCMS_EXTERN NSString* PCSQLiteAnswerColumnName;
PADCMS_EXTERN NSString* PCSQLiteQuestionColumnName;
PADCMS_EXTERN NSString* PCSQLiteLengthColumnName;
PADCMS_EXTERN NSString* PCSQLiteDirectionColumnName;
PADCMS_EXTERN NSString* PCSQLiteStartFromColumnName;

PADCMS_EXTERN NSString* PCSQLitePositionLeftTypeValue;
PADCMS_EXTERN NSString* PCSQLitePositionRightTypeValue;
PADCMS_EXTERN NSString* PCSQLitePositionTopTypeValue;
PADCMS_EXTERN NSString* PCSQLitePositionBottomTypeValue;

PADCMS_EXTERN NSString* PCSQLiteElementResourceAttributeName;
PADCMS_EXTERN NSString* PCSQLiteElementHtml5BodyAttributeName;
PADCMS_EXTERN NSString* PCSQLiteElementHtml5PositionAttributeName;
PADCMS_EXTERN NSString* PCSQLiteElementTwitterAccountAttributeName;
PADCMS_EXTERN NSString* PCSQLiteElementTwitterTweetNumberAttributeName;
PADCMS_EXTERN NSString* PCSQLiteElementAttributeName;
PADCMS_EXTERN NSString* PCSQLiteElementDestinationAttributeName;
PADCMS_EXTERN NSString* PCSQLiteElementAdvertDurationAttributeName;
PADCMS_EXTERN NSString* PCSQLiteElementTopAreaAttributeName;
PADCMS_EXTERN NSString* PCSQLiteElementThumbnailSelectedAttributeName;
PADCMS_EXTERN NSString* PCSQLiteElementThumbnailAttributeName;
PADCMS_EXTERN NSString* PCSQLiteElementVideoAttributeName;
PADCMS_EXTERN NSString* PCSQLiteElementPostCodeAttributeName;
PADCMS_EXTERN NSString* PCSQLiteElementGoogleLinkToMapAttributeName;
PADCMS_EXTERN NSString* PCSQLiteElementRSSLinkAttributeName;
PADCMS_EXTERN NSString* PCSQLiteElementRSSLinkNumberAttributeName;
PADCMS_EXTERN NSString* PCSQLiteElementFacebookNameAttributeName;
PADCMS_EXTERN NSString* PCSQLiteElementHtmlURLAttributeName;
PADCMS_EXTERN NSString* PCSQLiteElementTemplateTypeAttributeName;
PADCMS_EXTERN NSString* PCSQLiteElementTopAttributeName;
PADCMS_EXTERN NSString* PCSQLiteElementStreamAttributeName;
PADCMS_EXTERN NSString* PCSQLiteElementShowTopLayerAttributeName;
PADCMS_EXTERN NSString* PCSQLiteElementHasPhotoGalleryLinkAttributeName;
PADCMS_EXTERN NSString* PCSQLiteElementShowGalleryOnRotateAttributeName;
PADCMS_EXTERN NSString* PCSQLiteElementHeightAttributeName;
PADCMS_EXTERN NSString* PCSQLiteElementWidthAttributeName;
PADCMS_EXTERN NSString* PCSQLiteElementActiveZoneAttributeName;
PADCMS_EXTERN NSString* PCSQLiteElementGalleryIDName;
PADCMS_EXTERN NSString* PCSQLiteElementZoomAttributeName;

PADCMS_EXTERN NSString* PCSQLiteTemplateTouchType;
PADCMS_EXTERN NSString* PCSQLiteTemplateRotationType;


