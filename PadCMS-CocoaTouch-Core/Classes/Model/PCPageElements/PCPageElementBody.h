//
//  PCPageElementBody.h
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
 @class PCPageElementBody
 @brief Represents Body element of the page.
 */

@interface PCPageElementBody : PCPageElement
{
    BOOL hasPhotoGalleryLink;
    BOOL showTopLayer;
    NSInteger top;
    BOOL showGalleryOnRotate;
}

@property (nonatomic,assign) BOOL hasPhotoGalleryLink; ///< If YES means that body template have a link to launch photo gallery, and there is no need to show the default one. If NO, the default one will be shown.
@property (nonatomic,assign) BOOL showTopLayer; ///< Do we have to show scroller
@property (nonatomic,assign) NSInteger top; ///< Says where the body content should be positioned from the top of the screen
@property (nonatomic,assign) BOOL showGalleryOnRotate; ///< Do we have to show gallery after changing device orientation that opposite to magazine orientation

@end
