//
//  PCKioskShelfSettings.h
//  Pad CMS
//
//  Created by Oleg Zhitnik on 26.04.12.
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

#ifndef Pad_CMS_PCKioskShelfSettings_h
#define Pad_CMS_PCKioskShelfSettings_h

#define KIOSK_SHELF_ROW_HEIGHT                220
#define KIOSK_SHELF_ROW_MARGIN_TOP            50
#define KIOSK_SHELF_COLUMN_MARGIN_LEFT        10

#define KIOSK_ADVANCED_SHELF_MARGIN_TOP                16
#define KIOSK_ADVANCED_SHELF_ROW_MARGIN                0
#define KIOSK_ADVANCED_SHELF_ROW_HEIGHT                312
#define KIOSK_ADVANCED_SHELF_COLUMN_MARGIN_LEFT        35

#define UIColorFromRGB(rgbValue)        ([UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0])

#define KIOSK_SHELF_CELL_COVER_MARGIN_LEFT               5
#define KIOSK_SHELF_CELL_COVER_WIDTH                     128
#define KIOSK_SHELF_CELL_COVER_HEIGHT                    185

#define KIOSK_SHELF_CELL_COVER_RIGHT_MARGIN              20
#define KIOSK_SHELF_CELL_ELEMENTS_LEFT_MARGIN            (KIOSK_SHELF_CELL_COVER_MARGIN_LEFT + KIOSK_SHELF_CELL_COVER_WIDTH + KIOSK_SHELF_CELL_COVER_RIGHT_MARGIN)

#define KIOSK_SHELF_CELL_ISSUE_TITLE_TOP_MARGIN          15
#define KIOSK_SHELF_CELL_ISSUE_TITLE_HEIGHT              30

#define KIOSK_SHELF_CELL_REVISION_TITLE_TOP_MARGIN       45
#define KIOSK_SHELF_CELL_REVISION_TITLE_HEIGHT           20

#define KIOSK_SHELF_CELL_REVISION_STATE_TOP_MARGIN       70
#define KIOSK_SHELF_CELL_REVISION_STATE_HEIGHT           20

#define KIOSK_SHELF_CELL_BUTTONS_WIDTH                   101
#define KIOSK_SHELF_CELL_BUTTONS_HEIGHT                  30
#define KIOSK_SHELF_CELL_BUTTONS_INTERVAL                10
#define KIOSK_SHELF_CELL_FIRST_BUTTON_TOP_MARGIN         100
#define KIOSK_SHELF_CELL_SECOND_BUTTON_TOP_MARGIN        (KIOSK_SHELF_CELL_FIRST_BUTTON_TOP_MARGIN + KIOSK_SHELF_CELL_BUTTONS_HEIGHT + KIOSK_SHELF_CELL_BUTTONS_INTERVAL)
#define KIOSK_SHELF_CELL_THIRD_BUTTON_TOP_MARGIN         (KIOSK_SHELF_CELL_SECOND_BUTTON_TOP_MARGIN + KIOSK_SHELF_CELL_BUTTONS_HEIGHT + KIOSK_SHELF_CELL_BUTTONS_INTERVAL)

#endif
