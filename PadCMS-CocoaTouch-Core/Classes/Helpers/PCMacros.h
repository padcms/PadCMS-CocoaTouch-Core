//
//  PCMacros.h
//  the_reader
//
//  Created by Rustam Mallakurbanov on 01.02.12.
//  Copyright (c) 2012 Adyax Pad CMS. All rights reserved.
//

#if defined(__cplusplus)
#define PADCMS_EXTERN extern "C"
#else
#define PADCMS_EXTERN extern
#endif

// iOS5 detector
#define isOS5() \
([[[UIDevice currentDevice] systemVersion] floatValue]>=5.0)

#define PCApplicationDataWillUpdate @"applicationNeedToUpdate"
#define PCElementDownloadOperationDidEnded @"DownloadingPCPageElementOperationDidEnded"
