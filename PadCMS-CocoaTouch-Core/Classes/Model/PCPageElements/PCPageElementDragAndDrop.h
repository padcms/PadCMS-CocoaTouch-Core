//
//  PCPageElementDragAndDrop.h
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

/**
 @class PCPageElementDragAndDrop
 @brief Represents drag and drop element of the page.
 */

@interface PCPageElementDragAndDrop : PCPageElement
{
    NSString* video;
    NSString* thumbnail;
    NSString* thumbnailSelected;
    NSInteger topArea;
}

@property (nonatomic,retain) NSString* video; ///< Relative path to the video
@property (nonatomic,retain) NSString* thumbnail; ///< Relative path to the thumbnail
@property (nonatomic,retain) NSString* thumbnailSelected; ///< Relative path to the thumbnail selected
@property (nonatomic,assign) NSInteger topArea; ///< A top area (in pixel) where there is no mini-articles

@end
