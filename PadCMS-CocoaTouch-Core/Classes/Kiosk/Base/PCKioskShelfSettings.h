//
//  PCKioskShelfSettings.h
//  Pad CMS
//
//  Created by Oleg Zhitnik on 26.04.12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#ifndef Pad_CMS_PCKioskShelfSettings_h
#define Pad_CMS_PCKioskShelfSettings_h

#define KIOSK_SHELF_ROW_HEIGHT                220
#define KIOSK_SHELF_ROW_MARGIN_TOP            10
#define KIOSK_SHELF_COLUMN_MARGIN_LEFT        10

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
