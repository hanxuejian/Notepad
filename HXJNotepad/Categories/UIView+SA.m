//
//  UIView+SA.m
//  ESignature_HD
//
//  Created by HanXueJian on 16-8-26.
//  Copyright (c) 2016年 china-sss. All rights reserved.
//

#import "UIView+SA.h"

@implementation UIView (SA)

#pragma mark 判断控件是否被键盘遮盖
-(BOOL)isCoveredByKeyboard:(CGRect)keyboardFrame heightOfCovered:(CGFloat *)heightOfCovered {
    if (!self) {
        return NO;
    }
    if (![self superview]) {
        return NO;
    }
    if (self.hidden) {
        return NO;
    }
    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
    NSArray *windows = [[UIApplication sharedApplication]windows];
    UIWindow *keyboardWindow;
    for (id window in windows) {
        
        NSString *keyboardWindowString = NSStringFromClass([window class]);
        if ([keyboardWindowString isEqualToString:@"UITextEffectsWindow"]) {
            keyboardWindow = window;
            break;
        }
    }
    CGRect keyboardRect = [keyboardWindow convertRect:keyboardFrame toWindow:keyWindow];
    CGRect rect = [self.superview convertRect:self.frame toView:keyWindow];
    if (CGRectIsEmpty(rect) || CGRectIsNull(rect) || CGSizeEqualToSize(rect.size, CGSizeZero)) {
        return NO;
    }
    
    //如果结果为负表示有遮盖
    *heightOfCovered = keyboardRect.origin.y - rect.origin.y - self.frame.size.height;
    //调整到无遮盖情况，最大调整不能超过键盘的高度
    *heightOfCovered = *heightOfCovered > -keyboardFrame.size.height ? *heightOfCovered : -keyboardFrame.size.height;
    return CGRectIntersectsRect(rect, keyboardRect);
}

@end
