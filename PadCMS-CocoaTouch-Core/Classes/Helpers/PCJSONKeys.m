//
//  PCJSONKeys.m
//  Pad CMS
//
//  Created by Rustam Mallakurbanov on 16.02.12.
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

#import "PCJSONKeys.h"

 NSString* PCJSONIDKey                                      = @"id";
 NSString* PCJSONError                                      = @"result";

 NSString* PCJSONResultKey                                  = @"result";

 NSString* PCJSONSettingExportCheckUDIDKey                  = @"setting_export_check_udid";
 NSString* PCJSONUDIDIsValidKey                             = @"udid_is_valid";
 NSString* PCJSONUDIDIsUserAdminKey                         = @"udid_is_user_admin";

 NSString* PCJSONApplicationsKey                             = @"applications";

 NSString* PCJSONApplicationKey                             = @"application";
 NSString* PCJSONApplicationIDKey                           = @"application_id";
 NSString* PCJSONApplicationTitleKey                        = @"application_title";
 NSString* PCJSONApplicationDescriptionKey                  = @"application_description";
 NSString* PCJSONApplicationProductIDKey                    = @"application_product_id";
 NSString* PCJSONApplicationNotificationEmailKey            = @"application_notification_email";
 NSString* PCJSONApplicationNotificationEmailTitleKey       = @"application_notification_email_title";
 NSString* PCJSONApplicationNotificationTwitterKey          = @"application_notification_twitter";
 NSString* PCJSONApplicationNotificationFacebookKey         = @"application_notification_facebook";

 NSString* PCJSONIssuesKey                                  = @"issues";
 NSString* PCJSONIssueIDKey                                 = @"issue_id";
 NSString* PCJSONIssueTitleKey                              = @"issue_title";
 NSString* PCJSONIssueNumberKey                              = @"issue_number";
 NSString* PCJSONIssueProductIDKey                          = @"issue_product_id";
 NSString* PCJSONIssueStateKey                              = @"issue_state";
 NSString* PCJSONIssueApplicationIDKey                      = @"application_id";
 NSString* PCJSONIssueApplicationTitleKey                   = @"application_title";
 NSString* PCJSONIssuePaidKey                               = @"paid";
 NSString* PCJSONIssueSubscriptionTypeKey                   = @"subscription_type";
 NSString* PCJSONIssueColorKey                              = @"revision_color";
 NSString* PCJSONIssueHorizontalMode                        = @"revision_horizontal_mode";
 NSString* PCJSONIssueHelpPagesKey                          = @"help_pages";

 NSString* PCJSONRevisionsKey                               = @"revisions";
 NSString* PCJSONRevisionIDKey                              = @"revision_id";
 NSString* PCJSONRevisionTitleKey                           = @"revision_title";
 NSString* PCJSONRevisionStateKey                           = @"revision_state";
 NSString* PCJSONRevisionRevisionCoverImageListKey          = @"revision_cover_image_list";
 NSString* PCJSONRevisionRevisionCreatedKey                 = @"revision_created";
 NSString* PCJSONRevisionStartVideoKey                      = @"revision_video";
 NSString* PCJSONRevisionOrientationKey                     = @"revision_orientation";


 NSString* PCJSONIssueWorkInProgressStateValue              = @"work-in-progress";
 NSString* PCJSONIssuePublishedStateValue                   = @"published";
 NSString* PCJSONIssueArchivedStateValue                    = @"archived";
 NSString* PCJSONIssueForReviewStateValue                   = @"for-review";

 NSString* PCJSONIssueAutoRenewableSubscriptionTypeValue    = @"auto-renewable";

 NSString* PCJSONMethodNameKey                              = @"method";
 NSString* PCJSONParamsKey                                  = @"params";

 NSString* PCJSONSetDeviceTokenMethodName                   = @"apns.setDeviceToken";
 NSString* PCJSONSDUDIDKey                                  = @"sUdid";
 NSString* PCJSONSDTokenKey                                 = @"sToken";
 NSString* PCJSONSDClientIDKey                              = @"iClientId";
 NSString* PCJSONSDApplicationIDKey                         = @"iApplicationId";
