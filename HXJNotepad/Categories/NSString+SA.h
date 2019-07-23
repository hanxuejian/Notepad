//
//  NSString+SA.h
//  EDispatchManager_Release
//
//  Created by Cheng WeiWei on 11/21/14.
//  Copyright (c) 2014 china-sss. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "HXJMessageShow.h"

@interface NSString (SA)

- (id)saToJSONObject;

- (BOOL)saIsEmpty;

//非空
- (BOOL)saIsNotEmpty;

+ (instancetype)saUniqueString;
/*
 判断指定路径的文件是否是图片
 */
- (BOOL)isImageFile;
/*
 判断指定路径的文件是否是zip包
 */
- (BOOL)isZIPFile;
/*
 判断指定路径的文件是否是txt文件
 */
- (BOOL)isTXTFile;
/*
 判断指定路径的文件是否是pdf文件
 */
- (BOOL)isPDFFile;
/*
 计算字符串长度
 */
- (float)widthForFont:(UIFont *)tempFont maxHeight:(float)tempHeight;
/*
去掉空格
 */
+ (NSString *)saTrim:(NSString *)tempValue;

///去除空格后非空
- (BOOL)isEmptyIgnoreBlankAndEnter;

#if __IPHONE_7_0 || __IPHONE_7_1
- (BOOL)containsString:(NSString *)subString;
#endif

- (void)show;
@end
