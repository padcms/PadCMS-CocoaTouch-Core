//
//  PCSearchingTest.m
//  PadCMS-CocoaTouch-Core
//
//  Created by Oleg Zhitnik on 30.07.12.
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
#import <GHUnitIOS/GHUnit.h>
#import "PCSearchBaseProvider.h"

@class PCSearchBaseProvider;

@interface PCSearchingTest : GHTestCase
{
    PCSearchBaseProvider *_searchProvider;
}

@end

@implementation PCSearchingTest

- (void)setUp
{
    _searchProvider = [[PCSearchBaseProvider alloc] initWithKeyPhrase:@"test   phrase"];
}

- (void)tearDown
{
    [_searchProvider release];
    _searchProvider = nil;
}

- (void)testSearchingRegexp
{
    NSString        *regexpSimple = [_searchProvider searchingRegexpFromKeyPhrase:@"test   phrase"];
    NSString        *regexpComplicated = [_searchProvider searchingRegexpFromKeyPhrase:@"test . \\ * [ ] { } \\"];
    
    GHAssertEqualStrings(regexpSimple, @"test[ ]+phrase", nil);
    GHAssertEqualStrings(regexpComplicated, @"test[ ]+\\.[ ]+\\\\[ ]+\\*[ ]+\\[[ ]+\\][ ]+\\{[ ]+\\}[ ]+\\\\", nil);
}

- (void)testSearchingInText
{
    NSString        *srcTextContains = @"I want to show test phrase on white screen";
    NSString        *srcTextNotContains = @"Specify the number of bytes to increment the size of ICMP";
    NSString        *srcTextContainsComplicated = @"test . \\ * [ ] { } \\";

    GHAssertTrue([_searchProvider isStringContainsRegexp:srcTextContains], nil);
    GHAssertFalse([_searchProvider isStringContainsRegexp:srcTextNotContains], nil);
    
    _searchProvider.keyPhraseRegexp = [_searchProvider searchingRegexpFromKeyPhrase:@"test . \\ * [ ] { } \\"];
    GHAssertTrue([_searchProvider isStringContainsRegexp:srcTextContainsComplicated], nil);

    NSString        *srcTextContainsComplicated1 = @"test 1.1 point";
    NSString        *srcTextNotContainsComplicated1 = @"test 11 without point";
    _searchProvider.keyPhraseRegexp = [_searchProvider searchingRegexpFromKeyPhrase:@"."];
    GHAssertTrue([_searchProvider isStringContainsRegexp:srcTextContainsComplicated1], nil);
    GHAssertFalse([_searchProvider isStringContainsRegexp:srcTextNotContainsComplicated1], nil);

    NSString        *srcTextContainsComplicated2 = @"test \\ with";
    NSString        *srcTextNotContainsComplicated2 = @"test without";
    _searchProvider.keyPhraseRegexp = [_searchProvider searchingRegexpFromKeyPhrase:@"\\"];
    GHAssertTrue([_searchProvider isStringContainsRegexp:srcTextContainsComplicated2], nil);
    GHAssertFalse([_searchProvider isStringContainsRegexp:srcTextNotContainsComplicated2], nil);

    NSString        *srcTextContainsComplicated3 = @"test [] with";
    _searchProvider.keyPhraseRegexp = [_searchProvider searchingRegexpFromKeyPhrase:@"[]"];
    GHAssertTrue([_searchProvider isStringContainsRegexp:srcTextContainsComplicated3], nil);
    GHAssertFalse([_searchProvider isStringContainsRegexp:srcTextNotContainsComplicated2], nil);

    NSString        *srcTextContainsComplicated4 = @"test {} with";
    _searchProvider.keyPhraseRegexp = [_searchProvider searchingRegexpFromKeyPhrase:@"{}"];
    GHAssertTrue([_searchProvider isStringContainsRegexp:srcTextContainsComplicated4], nil);
    GHAssertFalse([_searchProvider isStringContainsRegexp:srcTextNotContainsComplicated2], nil);

    NSString        *srcTextContainsComplicated5 = @"test *.* with";
    _searchProvider.keyPhraseRegexp = [_searchProvider searchingRegexpFromKeyPhrase:@".*"];
    GHAssertTrue([_searchProvider isStringContainsRegexp:srcTextContainsComplicated5], nil);
    GHAssertFalse([_searchProvider isStringContainsRegexp:srcTextNotContainsComplicated2], nil);
    
    GHAssertNil(nil, nil);
}

@end
