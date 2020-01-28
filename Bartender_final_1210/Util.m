//
//  Util.m
//
//  Created by CHIA HAO HSU on 2018/3/30.
//  Copyright © 2018年 CHIA HAO HSU. All rights reserved.
//

#import "Util.h"

@implementation Util

+ (NSData *) dataFromHexString:(NSString*)hexString
{
    NSString * cleanString = [self cleanNonHexCharsFromHexString:hexString];
    if (cleanString == nil) {
        return nil;
    }
    
    NSMutableData *result = [[NSMutableData alloc] init];
    
    int i = 0;
    for (i = 0; i+2 <= cleanString.length; i+=2) {
        NSRange range = NSMakeRange(i, 2);
        NSString* hexStr = [cleanString substringWithRange:range];
        NSScanner* scanner = [NSScanner scannerWithString:hexStr];
        unsigned int intValue;
        [scanner scanHexInt:&intValue];
        unsigned char uc = (unsigned char) intValue;
        [result appendBytes:&uc length:1];
    }
    NSData * data = [NSData dataWithData:result];
    // [result release];
    return data;
}

+(NSString *) cleanNonHexCharsFromHexString:(NSString *)input
{
    if (input == nil) {
        return nil;
    }
    
    NSString * output = [input stringByReplacingOccurrencesOfString:@"0x" withString:@""
                                                            options:NSCaseInsensitiveSearch range:NSMakeRange(0, input.length)];
    NSString * hexChars = @"0123456789abcdefABCDEF";
    
    
    NSCharacterSet *hexc = [NSCharacterSet characterSetWithCharactersInString:hexChars];
    NSCharacterSet *invalidHexc = [hexc invertedSet];
    
    BOOL isValid = (NSNotFound == [output rangeOfCharacterFromSet:invalidHexc].location);
    
    if(!isValid) return nil;
    
    NSString * allHex = [[output componentsSeparatedByCharactersInSet:invalidHexc] componentsJoinedByString:@""];
    return allHex;
}

//-----------------------------------------------------------------------------------
+ (NSString *)hexadecimalString:(Byte*) Data Length:(int)Length{
    
    const unsigned char *dataBuffer = (const unsigned char *)Data;
    
    if (!dataBuffer)
        return [NSString string];
    
    NSUInteger          dataLength  = Length;
    NSMutableString     *hexString  = [NSMutableString stringWithCapacity:(dataLength * 2)];
    
    for (int i = 0; i < dataLength; ++i)
        [hexString appendString:[NSString stringWithFormat:@"%02lx", (unsigned long)dataBuffer[i]]];
    
    return [NSString stringWithString:hexString];
}

+ (NSString *)hexadecimalStringFromData:(NSData *)data
{
    NSUInteger dataLength = data.length;
    if (dataLength == 0) {
        return nil;
    }
    
    const unsigned char *dataBuffer = data.bytes;
    NSMutableString *hexString  = [NSMutableString stringWithCapacity:(dataLength * 2)];
    for (int i = 0; i < dataLength; ++i) {
        [hexString appendFormat:@"%02x", dataBuffer[i]];
    }
    return [hexString copy];
}

+(NSString *) GetTimeString {
    
    NSString *dateString = [NSDateFormatter localizedStringFromDate:[NSDate date]
                                                          dateStyle:NSDateFormatterShortStyle
                                                          timeStyle:NSDateFormatterMediumStyle];
    
    return dateString;
}

+(NSString *) DataToUTF8Str:(NSData *)Data{
    
    NSString *string = [[NSString alloc] initWithData:Data encoding:NSUTF8StringEncoding];
    
    return string;
}


@end




