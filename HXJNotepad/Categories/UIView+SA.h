//
//  UIView+SA.h
//  ESignature_HD
//
//  Created by HanXueJian on 16-8-26.
//  Copyright (c) 2016年 china-sss. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (SA)

/** 
 判断控件是否被键盘遮盖
 @param keyboardFrame 键盘显示后的位置
 @param heightOfCovered 当前视图被键盘覆盖后应该移动的矢量值，负值（表示向上移动量），正值（表示当前视图的底部在键盘顶部的距离）
 @return BOOL YES 则表示当前视图与键盘有交叉的部分，NO 则无交叉部分
*/
-(BOOL)isCoveredByKeyboard:(CGRect)keyboardFrame heightOfCovered:(CGFloat *)heightOfCovered;
@end
