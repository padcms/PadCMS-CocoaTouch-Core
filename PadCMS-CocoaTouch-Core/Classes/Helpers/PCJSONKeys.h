//
//  PCJSONKeys.h
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

#import <Foundation/Foundation.h>
#import "PCMacros.h"

PADCMS_EXTERN NSString* PCJSONIDKey;
PADCMS_EXTERN NSString* PCJSONError;

PADCMS_EXTERN NSString* PCJSONResultKey;

PADCMS_EXTERN NSString* PCJSONSettingExportCheckUDIDKey;
PADCMS_EXTERN NSString* PCJSONUDIDIsValidKey;
PADCMS_EXTERN NSString* PCJSONUDIDIsUserAdminKey;

PADCMS_EXTERN NSString* PCJSONApplicationsKey;

PADCMS_EXTERN NSString* PCJSONApplicationKey;
PADCMS_EXTERN NSString* PCJSONApplicationIDKey;
PADCMS_EXTERN NSString* PCJSONApplicationTitleKey;
PADCMS_EXTERN NSString* PCJSONApplicationDescriptionKey;
PADCMS_EXTERN NSString* PCJSONApplicationProductIDKey;
PADCMS_EXTERN NSString* PCJSONApplicationNotificationEmailKey;
PADCMS_EXTERN NSString* PCJSONApplicationNotificationEmailTitleKey;
PADCMS_EXTERN NSString* PCJSONApplicationNotificationTwitterKey;
PADCMS_EXTERN NSString* PCJSONApplicationNotificationFacebookKey;
PADCMS_EXTERN NSString* PCJSONApplicationPreviewKey;

PADCMS_EXTERN NSString* PCJSONIssuesKey;
PADCMS_EXTERN NSString* PCJSONIssueIDKey;
PADCMS_EXTERN NSString* PCJSONIssueTitleKey;
PADCMS_EXTERN NSString* PCJSONIssueNumberKey;
PADCMS_EXTERN NSString* PCJSONIssueProductIDKey;
PADCMS_EXTERN NSString* PCJSONIssueStateKey;
PADCMS_EXTERN NSString* PCJSONIssueApplicationIDKey;
PADCMS_EXTERN NSString* PCJSONIssueApplicationTitleKey;
PADCMS_EXTERN NSString* PCJSONIssuePaidKey;
PADCMS_EXTERN NSString* PCJSONIssueSubscriptionTypeKey;
PADCMS_EXTERN NSString* PCJSONIssueColorKey;
PADCMS_EXTERN NSString* PCJSONIssueHorizontalMode;
PADCMS_EXTERN NSString* PCJSONIssueHelpPagesKey;
PADCMS_EXTERN NSString* PCJSONIssueAuthorKey;
PADCMS_EXTERN NSString* PCJSONIssueExcerptKey;
PADCMS_EXTERN NSString* PCJSONIssueImageLargeURLKey;
PADCMS_EXTERN NSString* PCJSONIssueImageSmallURLKey;
PADCMS_EXTERN NSString* PCJSONIssueWordsCountKey;
PADCMS_EXTERN NSString* PCJsonIssueCategoryKey;

PADCMS_EXTERN NSString* PCJSONRevisionsKey;
PADCMS_EXTERN NSString* PCJSONRevisionIDKey;
PADCMS_EXTERN NSString* PCJSONRevisionTitleKey;
PADCMS_EXTERN NSString* PCJSONRevisionStateKey;
PADCMS_EXTERN NSString* PCJSONRevisionRevisionCoverImageListKey;
PADCMS_EXTERN NSString* PCJSONRevisionRevisionCreatedKey;
PADCMS_EXTERN NSString* PCJSONRevisionStartVideoKey;
PADCMS_EXTERN NSString* PCJSONRevisionOrientationKey;
PADCMS_EXTERN NSString* PCJSONRevisionPastilleColorKey;
PADCMS_EXTERN NSString* PCJSONRevisionSummaryButtonTextColorKey;

PADCMS_EXTERN NSString* PCJSONIssueWorkInProgressStateValue;
PADCMS_EXTERN NSString* PCJSONIssuePublishedStateValue;
PADCMS_EXTERN NSString* PCJSONIssueArchivedStateValue;
PADCMS_EXTERN NSString* PCJSONIssueForReviewStateValue;

PADCMS_EXTERN NSString* PCJSONIssueAutoRenewableSubscriptionTypeValue;

PADCMS_EXTERN NSString* PCJSONMethodNameKey;
PADCMS_EXTERN NSString* PCJSONParamsKey;

PADCMS_EXTERN NSString* PCJSONSetDeviceTokenMethodName;
PADCMS_EXTERN NSString* PCJSONSDUDIDKey;
PADCMS_EXTERN NSString* PCJSONSDTokenKey;
PADCMS_EXTERN NSString* PCJSONSDClientIDKey;
PADCMS_EXTERN NSString* PCJSONSDApplicationIDKey;
