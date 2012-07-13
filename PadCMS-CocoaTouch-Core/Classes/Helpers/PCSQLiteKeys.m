//
//  PCSQLiteKeys.m
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

#import "PCSQLiteKeys.h"

 NSString* PCSQLitePageTableName                                = @"page";
 NSString* PCSQLitePageImpositionTableName                      = @"page_imposition";
 NSString* PCSQLiteElementTableName                             = @"element";
 NSString* PCSQLiteElementDataTableName                         = @"element_data";
 NSString* PCSQLiteElementDataPositionTableName                 = @"element_data_position";
 NSString* PCSQLiteMenuTableName                                = @"menu";
 NSString* PCSQLitePageHorisontalTableName                      = @"page_horisontal";

 NSString* PCSQLiteIDColumnName                                 = @"id";
 NSString* PCSQLiteTitleColumnName                              = @"title";
 NSString* PCSQLiteHorisontalPageIDColumnName                   = @"horisontal_page_id";
 NSString* PCSQLiteTemplateColumnName                           = @"template";
 NSString* PCSQLiteMachineNameColumnName                        = @"machine_name";
 NSString* PCSQLitePageIDColumnName                             = @"page_id";
 NSString* PCSQLiteIsLinkedToColumnName                         = @"is_linked_to";
 NSString* PCSQLitePositionTypeColumnName                       = @"position_type";
 NSString* PCSQLiteElementTypeNameColumnName                    = @"element_type_name";
 NSString* PCSQLiteWeightColumnName                             = @"weight";
 NSString* PCSQLiteContentTextColumnName                        = @"content_text";
 NSString* PCSQLiteElementIDColumnName                          = @"element_id";
 NSString* PCSQLiteTypeColumnName                               = @"type";
 NSString* PCSQLiteValueColumnName                              = @"value";
 NSString* PCSQLitePositionIDColumnName                         = @"position_id";
 NSString* PCSQLiteStartXColumnName                             = @"start_x";
 NSString* PCSQLiteStartYColumnName                             = @"start_y";
 NSString* PCSQLiteEndXColumnName                               = @"end_x";
 NSString* PCSQLiteEndYColumnName                               = @"end_y";
 NSString* PCSQLiteFirstpageIDColumnName                        = @"firstpage_id";
 NSString* PCSQLiteDescriptionColumnName                        = @"description";
 NSString* PCSQLiteThumbStripeColumnName                        = @"thumb_stripe";
 NSString* PCSQLiteThumbSummaryColumnName                       = @"thumb_summary";
 NSString* PCSQLiteColorColumnName                              = @"color";
 NSString* PCSQLiteNameColumnName                               = @"name";
 NSString* PCSQLiteResourceColumnName                           = @"resource";
 NSString* PCSQLiteElementGalleryIDName                         = @"gallery_id";

 NSString* PCSQLitePositionLeftTypeValue                        = @"left";
 NSString* PCSQLitePositionRightTypeValue                       = @"right";
 NSString* PCSQLitePositionTopTypeValue                         = @"top";
 NSString* PCSQLitePositionBottomTypeValue                      = @"bottom";

 NSString* PCSQLiteElementResourceAttributeName                 = @"resource";
 NSString* PCSQLiteElementHtml5BodyAttributeName                = @"html5_body";
 NSString* PCSQLiteElementHtml5PositionAttributeName            = @"html5_position";
 NSString* PCSQLiteElementTwitterAccountAttributeName           = @"twitter_account";
 NSString* PCSQLiteElementTwitterTweetNumberAttributeName       = @"twitter_tweet_number";
 NSString* PCSQLiteElementAttributeName                         = @"resource";
 NSString* PCSQLiteElementDestinationAttributeName              = @"destination";
 NSString* PCSQLiteElementAdvertDurationAttributeName           = @"advert_duration";
 NSString* PCSQLiteElementTopAreaAttributeName                  = @"top_area";
 NSString* PCSQLiteElementThumbnailSelectedAttributeName        = @"thumbnail_selected";
 NSString* PCSQLiteElementThumbnailAttributeName                = @"thumbnail";
 NSString* PCSQLiteElementVideoAttributeName                    = @"video";
 NSString* PCSQLiteElementPostCodeAttributeName                 = @"post_code";
 NSString* PCSQLiteElementGoogleLinkToMapAttributeName          = @"google_link_to_map";
 NSString* PCSQLiteElementRSSLinkAttributeName                  = @"rss_link";
 NSString* PCSQLiteElementRSSLinkNumberAttributeName            = @"rss_link_number";
 NSString* PCSQLiteElementFacebookNameAttributeName             = @"facebook_name_page";
 NSString* PCSQLiteElementHtmlURLAttributeName                  = @"html_url";
 NSString* PCSQLiteElementTemplateTypeAttributeName             = @"template_type";
 NSString* PCSQLiteElementTopAttributeName                      = @"top";
 NSString* PCSQLiteElementStreamAttributeName                   = @"stream";
 NSString* PCSQLiteElementShowTopLayerAttributeName             = @"showTopLayer";
 NSString* PCSQLiteElementHasPhotoGalleryLinkAttributeName      = @"hasPhotoGalleryLink";
 NSString* PCSQLiteElementShowGalleryOnRotateAttributeName      = @"showGalleryOnRotate";
 NSString* PCSQLiteElementHeightAttributeName                   = @"height";
 NSString* PCSQLiteElementWidthAttributeName                    = @"width";
 NSString* PCSQLiteElementActiveZoneAttributeName               = @"active_zone";
 NSString* PCSQLiteElementZoomAttributeName                     = @"zoom";

 NSString* PCSQLiteTemplateTouchType                            = @"touch";
 NSString* PCSQLiteTemplateRotationType                         = @"rotation";


