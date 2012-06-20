//
//  PCPageElementBody.m
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

#import "PCPageElementBody.h"

@implementation PCPageElementBody

@synthesize hasPhotoGalleryLink;
@synthesize showTopLayer;
@synthesize top;

- (id)init
{
    if (self = [super init])
    {
        hasPhotoGalleryLink = NO;
        showTopLayer = NO;
        top = -1;
    }
    return self;
}

- (void)pushElementData:(NSDictionary*)data
{
    [super pushElementData:data];
    
    if ([data objectForKey:PCSQLiteElementShowTopLayerAttributeName])
        self.showTopLayer = [[data objectForKey:PCSQLiteElementShowTopLayerAttributeName] boolValue];
    
    if ([data objectForKey:PCSQLiteElementHasPhotoGalleryLinkAttributeName])
        self.hasPhotoGalleryLink = [[data objectForKey:PCSQLiteElementHasPhotoGalleryLinkAttributeName] boolValue];   
   
    if ([data objectForKey:PCSQLiteElementTopAttributeName])
        self.top = [[data objectForKey:PCSQLiteElementTopAttributeName] integerValue];
}

-(NSString*)description
{
    return [[super description] stringByAppendingFormat:@"\rshowTopLayer=%d\rhasPhotoGalleryLink=%d\rtop=%d\r",self.showTopLayer,self.hasPhotoGalleryLink,self.top];
}

@end
