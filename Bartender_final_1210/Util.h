//
//Util.h
//
//  Created by CHIA HAO HSU on 2018/3/30.
//  Copyright © 2018年 CHIA HAO HSU. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Util : NSObject

+ (NSData *) dataFromHexString:(NSString*)hexString;
+ (NSString *) cleanNonHexCharsFromHexString:(NSString *)input;
+ (NSString *) hexadecimalString:(Byte*) Data Length:(int)Length;
+ (NSString *) hexadecimalStringFromData:(NSData *)data;
+ (NSString *) GetTimeString;
+ (NSString *) DataToUTF8Str:(NSData *)Data;

@end

