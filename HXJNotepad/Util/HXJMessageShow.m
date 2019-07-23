//
//  HXJMessageShow.m
//  Notepad
//
//  Created by han on 2019/7/11.
//  Copyright © 2019 han. All rights reserved.
//

#import "HXJMessageShow.h"

@implementation HXJMessageShow

+ (void)message:(NSString *)message showInController:(UIViewController *)controller {
    [self message:message title:nil showInController:controller];
}

+ (void)message:(NSString *)message title:(NSString *)title showInController:(UIViewController *)controller {
    UIAlertController *alerController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *confirm  = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:nil];
    [alerController addAction:confirm];
    
    [controller presentViewController:alerController animated:YES completion:nil];
}

@end
