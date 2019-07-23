//
//  Notify.m
//  Spring
//
//  Created by MeMac.cn on 11-7-13.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Notify.h"
#import "SPAlertView.h"

@implementation Notify

+ (void)showAlertDialog:(id)context titleString:(NSString *)titleString messageString:(NSString *)messageString {
    dispatch_async(dispatch_get_main_queue(), ^{
        SPAlertView *myAlert = [[SPAlertView alloc] initWithTitle:titleString
                                                          message:messageString
                                                         delegate:context
                                                cancelButtonTitle:@"确定"//NSLocalizedStringWithInternational(@"common_util_notify_002", @"确定")
                                                otherButtonTitles:nil];
        [myAlert show];
    });
}

+ (void)showAlertDialog:(id)context messageString:(NSString *)messageString {
    dispatch_async(dispatch_get_main_queue(), ^{
        SPAlertView *myAlert = [[SPAlertView alloc] initWithTitle:@"提示"//NSLocalizedStringWithInternational(@"common_util_notify_001", @"提示")
                                                          message:messageString
                                                         delegate:context
                                                cancelButtonTitle:@"确定"//NSLocalizedStringWithInternational(@"common_util_notify_002", @"确定")
                                                otherButtonTitles:nil];
        [myAlert show];
        
    });
}

@end
