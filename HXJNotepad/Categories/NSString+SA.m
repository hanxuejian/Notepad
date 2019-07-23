//
//  NSString+SA.m
//  EDispatchManager_Release
//
//  Created by Cheng WeiWei on 11/21/14.
//  Copyright (c) 2014 china-sss. All rights reserved.
//

#import "NSString+SA.h"
#import "NSObject+SA.h"
#import <UIKit/UIKit.h>

@implementation NSString (SA)

- (id)saToJSONObject
{
    NSError *error;
    return [NSJSONSerialization JSONObjectWithData:[self dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&error];
}

- (BOOL)saIsEmpty
{
    return [super saIsEmpty] || !self.length;
}

+ (instancetype)saUniqueString
{
    CFUUIDRef UUID = CFUUIDCreate(kCFAllocatorDefault);
    CFStringRef uuidRef = CFUUIDCreateString(kCFAllocatorDefault, UUID);
    
    if (UUID) CFRelease(UUID);
    return CFBridgingRelease(uuidRef);
}

#pragma mark -判断指定路径的文件是否是图片
- (BOOL)isImageFile {
    BOOL result = NO;
    @autoreleasepool {
        UIImage *image = [UIImage imageWithContentsOfFile:self];
        if (image) {
            result = YES;
        }
    }
    return result;
}

#pragma mark -判断指定路径的文件是否是zip包
- (BOOL)isZIPFile{
    BOOL result = NO;
    @autoreleasepool {
        NSFileHandle *fh = [NSFileHandle fileHandleForReadingAtPath:self];
        NSData *data = [fh readDataOfLength:4];
        if ([data length] == 4) {
            const char *bytes = [data bytes];
            if (bytes[0] == 'P' && bytes[1] == 'K' && bytes[2] == 3 && bytes[3] == 4) {
                result = YES;
            }
        }
    }
    return result;
}

#pragma mark - 判断指定路径的文件是否是txt文件
- (BOOL)isTXTFile {
    BOOL result = NO;
    @autoreleasepool {
        NSString *fileExtension = [self pathExtension];
        if (fileExtension && [[fileExtension lowercaseString] isEqualToString:@"txt"]) {
            result = YES;
        }
    }
    return result;
}

#pragma mark - 判断指定路径的文件是否是pdf文件
- (BOOL)isPDFFile {
    BOOL result = NO;
    NSString *fileExtension = [self pathExtension];
    if (fileExtension && [[fileExtension lowercaseString] isEqualToString:@"pdf"]) {
        result = YES;
    }
    return result;
}

#pragma mark - 计算字符串长度
- (float)widthForFont:(UIFont *)tempFont maxHeight:(float)tempHeight {
    float finalWidth = 0.0;
    if (self.length == 0 || !tempFont) {
        return finalWidth;
    }
    NSDictionary *fontAttributeDict = [NSDictionary dictionaryWithObject:tempFont forKey:NSFontAttributeName];
    CGRect tempRect = [self boundingRectWithSize:CGSizeMake(0, tempHeight) options: NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:fontAttributeDict context:nil];
    finalWidth = tempRect.size.width;
    return finalWidth;
}

#pragma mark - 去掉空格
+ (NSString *)saTrim:(NSString *)tempValue {
    if ([NSNull null] == (NSNull *)tempValue || tempValue.length == 0) {
        return @"";
    }
    return [tempValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}

#pragma mark -非空
- (BOOL)saIsNotEmpty {
    if ([self isKindOfClass:[NSString class]] && self.length > 0) {
        return YES;
    }
    return NO;
}

#pragma mark 去除空格后非空
- (BOOL)isEmptyIgnoreBlankAndEnter {
    NSString *temp = [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    return temp.length == 0;
}

#if __IPHONE_7_0 || __IPHONE_7_1
- (BOOL)containsString:(NSString *)subString {
    if ([self rangeOfString:subString].length > 0) return YES;
    return NO;
}
#endif

- (void)show {
    [HXJMessageShow message:self showInController:UIApplication.sharedApplication.keyWindow.rootViewController];    
}
@end
