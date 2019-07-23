//
//  HXJMessageShow.h
//  Notepad
//
//  Created by han on 2019/7/11.
//  Copyright © 2019 han. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HXJMessageShow : NSObject

+ (void)message:(NSString *)message showInController:(UIViewController *)controller;

+ (void)message:(NSString *)message title:(nullable NSString *)title showInController:(UIViewController *)controller;

@end

NS_ASSUME_NONNULL_END
