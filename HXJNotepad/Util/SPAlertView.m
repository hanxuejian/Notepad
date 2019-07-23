//
//  SPAlertView.m
//  ESignature_HD
//
//  Created by SimonDing on 14-11-10.
//  Copyright (c) 2014年 china-sss. All rights reserved.
//

#import "SPAlertView.h"

@implementation SPAlertView
- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (id)init {
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(dismiss:)
                                                     name:UIApplicationDidEnterBackgroundNotification
                                                   object:nil];
    }
    return self;
}

- (id) initWithTitle:(NSString *)title
             message:(NSString *)message
            delegate:(id)delegate
   cancelButtonTitle:(NSString *)cancelButtonTitle
   otherButtonTitles:(NSString *)otherButtonTitles, ... {
    self = [super initWithTitle:title
                        message:message
                       delegate:delegate
              cancelButtonTitle:cancelButtonTitle
              otherButtonTitles:otherButtonTitles, nil];
    
    if (self) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(dismiss:)
                                                     name:UIApplicationDidEnterBackgroundNotification
                                                   object:nil];
    }
    return self;
}

- (void) dismiss:(NSNotification *)notication {
    self.delegate = nil;
    [self dismissWithClickedButtonIndex:[self cancelButtonIndex] animated:NO];
}
@end
