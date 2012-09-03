//
//  PCLocalizationManager.m
//  PadCMS-CocoaTouch-Core
//
//  Created by Oleg Zhitnik on 18.07.12.
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

#import "PCLocalizationManager.h"
#import "PCConfig.h"

static PCLocalizationManager *sharedLocalizationManager = nil;

@interface PCLocalizationManager()

- (NSString *)localizedStringForKey:(NSString *)key value:(NSString *)comment;
- (void) additionalInitialization;
- (NSString *)systemLanguage;
- (NSString *)applicationDefaultLanguage;
- (NSURL *) coreResourcesBundleURL;
- (NSBundle *)coreResourcesBundle;
- (NSBundle *)bundleForLanguage:(NSString *)language;

@end

@implementation PCLocalizationManager

static NSBundle *translatingBundle = nil;       // bundle for translating
static NSBundle *fallbackBundle = nil;          // bundle for translate if previous bundle returns nil for localize

+ (PCLocalizationManager *)sharedManager
{
    if (sharedLocalizationManager == nil) {
        sharedLocalizationManager = [[super allocWithZone:NULL] init];
        [sharedLocalizationManager additionalInitialization];
    }
    return sharedLocalizationManager;
}

+ (id)allocWithZone:(NSZone *)zone
{
    return [[self sharedManager] retain];
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

- (id)retain
{
    return self;
}

- (NSUInteger)retainCount
{
    return NSUIntegerMax;  //denotes an object that cannot be released
}

- (void)release
{
    //do nothing
}

- (id)autorelease
{
    return self;
}

+ (NSString *)localizedStringForKey:(NSString *)key value:(NSString *)comment
{
    return [[PCLocalizationManager sharedManager] localizedStringForKey:key value:comment];
}


#pragma mark Private

- (NSString *)localizedStringForKey:(NSString *)key value:(NSString *)comment
{
    NSString        *result = nil;
    
    if(translatingBundle)
    {
        result = [translatingBundle localizedStringForKey:key
                                                    value:nil
                                                    table:nil];
    }
    
    if(result==nil)
    {
        if(fallbackBundle)
        {
            result = [fallbackBundle localizedStringForKey:key
                                                     value:nil
                                                     table:nil];
        }
    }
    
    if(result==nil)
    {
        if(comment)
        {
            result = comment;
        } else {
            result = key;
        }
    }

    return result;
}

- (void)additionalInitialization
{
    
    NSString        *language = [self applicationDefaultLanguage];
    NSBundle        *selectedLanguageBundle = nil;
    NSBundle        *fallbackLanguageBundle = nil;
    
    if(language)
    {
        selectedLanguageBundle = [self bundleForLanguage:language];
    }
    
    if(selectedLanguageBundle==nil)
    {
        if(language!=nil)
        {
            NSLog(@"ERROR: Can't find localization bundle for default application language (%@)!", language);
        }
        language = [self systemLanguage];
        selectedLanguageBundle = [self bundleForLanguage:language];
    }
    
    if(selectedLanguageBundle==nil)  // no language pack, try English
    {
        NSLog(@"ERROR: Can't find localization bundle for system language (%@)! Trying to use English localization", language);
        selectedLanguageBundle = [self bundleForLanguage:@"en"];
    } else {                         // language pack is present, using English ass fallback
        if(![[language uppercaseString] isEqualToString:@"EN"])
        {
            fallbackLanguageBundle = [self bundleForLanguage:@"en"]; 
        }
    }
    
    if(selectedLanguageBundle) translatingBundle = [selectedLanguageBundle retain];
    if(fallbackLanguageBundle) fallbackBundle = [fallbackLanguageBundle retain];
}

- (NSString *)systemLanguage
{
    NSArray     *languages = [[NSUserDefaults standardUserDefaults] objectForKey:@"AppleLanguages"];
    
    if(languages)
    {
        if([languages count] > 0)
        {
            NSString    *preferredLanguage = [languages objectAtIndex:0];
            return preferredLanguage;
        }
    }
    return nil;
}

- (NSString *)applicationDefaultLanguage
{
    return [PCConfig ApplicationDefaultLanguage];
}

- (NSURL *)coreResourcesBundleURL
{
    return [[NSBundle mainBundle] URLForResource:@"PadCMS-CocoaTouch-Core-Resources"
                                   withExtension:@"bundle"];
}

- (NSBundle *)coreResourcesBundle
{
    NSURL    *url = [self coreResourcesBundleURL];
    
    if(url)
    {
        NSBundle *coreBundle = [NSBundle bundleWithURL:url];
        return coreBundle;
    } else {
        NSLog(@"PadCMS-CocoaTouch-Core-Resources!");
    }
    return nil;
}

- (NSBundle *)bundleForLanguage:(NSString*)language
{
    NSBundle *coreBundle = [self coreResourcesBundle];
    
    if(coreBundle)
    {
        NSString *path = [coreBundle pathForResource:language
                                              ofType:@"lproj"];
        
        return [NSBundle bundleWithPath:path];
    }
    return nil;
}

@end
