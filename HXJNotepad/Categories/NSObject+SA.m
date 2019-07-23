//
//  NSObject+SA.m
//  EDispatchManager_Release
//
//  Created by Cheng WeiWei on 11/21/14.
//  Copyright (c) 2014 china-sss. All rights reserved.
//

#import "NSObject+SA.h"

@implementation NSObject (SA)


- (id)saJSONString
{
    if ([NSJSONSerialization isValidJSONObject:self]) {
        NSError *error;
#ifdef DEBUG
        NSJSONWritingOptions options = NSJSONWritingPrettyPrinted;
#else
        NSJSONWritingOptions options = 0;
#endif
        
        NSString *jsonString = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:self options:options error:&error] encoding:NSUTF8StringEncoding];
        return jsonString;
    }
    return nil;
}

- (BOOL)saIsEmpty
{
    return [self isKindOfClass:NSNull.class];
}

#pragma mark -非空
- (BOOL)saIsNotEmpty {
    return ![self isKindOfClass:NSNull.class];
}
@end
