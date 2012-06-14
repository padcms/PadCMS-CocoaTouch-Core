//
//  PCSQLLiteModelBuilder.h
//  Pad CMS
//
//  Created by Rustam Mallakurbanov on 15.02.12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

/**
 @class PCSQLLiteModelBuilder
 @brief Responsible for Data Model creating. Model creating goes in two stages. First stage is PCApplication initialization and filling basic magazine information received from client.getIssues. On the second stage downloaded magazines fills with data from sqlite database and magazines structure is built.
 */



#import <UIKit/UIKit.h>
#import "PCData.h"

@interface PCSQLLiteModelBuilder : NSObject

+ (void)addPagesFromSQLiteBaseWithPath:(NSString*)path toRevision:(PCRevision*)revision;

/**
 @brief Creates data model
 
 @param applicatinDictionary - Dictionary with information received from client.getIssues
 */
//+(PCApplication*)buildApplicationFromDictionary:(NSDictionary*)applicatinDictionary;

/**
 @brief Updates data model
 
 @param application - PCApplication object which needs updating
 @param applicatinDictionary - Dictionary with information received from client.getIssues
 */
//+(void)updateApplication:(PCApplication*)application withDictionary:(NSDictionary*)applicatinDictionary;

@end
