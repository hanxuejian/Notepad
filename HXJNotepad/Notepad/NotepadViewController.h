//
//  NotepadViewController.h
//  ESignature_HD
//
//  Created by HanXueJian on 16-8-17.
//  Copyright (c) 2016年 china-sss. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NotepadViewController : UIViewController

+ (instancetype)notepadViewController;

///当前是否正在录音
@property (nonatomic, readonly) BOOL isRecordingVoice;

@end
