//
//  NSString+AESCrypt.h
//
//  Created by Michael Sedlaczek, Gone Coding on 2011-02-22
//

#import <Foundation/Foundation.h>
#import "NSData+AESCrypt.h"

@interface NSString (AESCrypt)

- (NSString *)AES256EncryptWithKey:(NSString *)key;
- (NSString *)AES256DecryptWithKey:(NSString *)key;

@end






@interface NSString (TrimmingAdditions)
- (NSString *)stringByTrimmingTrailingCharactersInSet:(NSCharacterSet *)characterSet;
- (NSString *)stringByTrimmingLeadingCharactersInSet:(NSCharacterSet *)characterSet;
- (NSString *)stringByTrimmingLeadingWhitespace ;
- (NSString *)stringByTrimmingTrailingWhitespace ;
- (NSString *)stringByTrimmingLeadingWhitespaceAndNewline;
- (NSString *)stringByTrimmingTrailingWhitespaceAndNewline;
@end
