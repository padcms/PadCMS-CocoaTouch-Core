#import <Foundation/Foundation.h>

@interface NSString (XMLEntities)

// Instance Methods
- (NSString *)stringByStrippingTags;
- (NSString *)stringByDecodingXMLEntities;
- (NSString *)stringByEncodingXMLEntities;
- (NSString *)stringWithNewLinesAsBRs;
- (NSString *)stringByRemovingNewLinesAndWhitespace;

@end