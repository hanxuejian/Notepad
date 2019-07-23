//
//  NotepadTableViewCell.h
//  ESignature_HD
//
//  Created by HanXueJian on 16-8-23.
//  Copyright (c) 2016年 china-sss. All rights reserved.
//

#import <UIKit/UIKit.h>

#define NoteFileTypeText  @"txt"
#define NoteFileTypeAudio @"m4a"
#define NoteFileTypeImage @"png"
#define NoteFileTypeVidoe @"mp4"

@class LMRRootViewController;

@interface NotepadTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (weak, nonatomic) IBOutlet UILabel *noteMessageLabel;

@property (weak, nonatomic) IBOutlet UIButton *voiceButton;

@property (weak, nonatomic) IBOutlet UIButton *imageButton;

@property (weak, nonatomic) IBOutlet UIButton *videoButton;

@property (weak, nonatomic) IBOutlet UIButton *deleteButton;

@property (weak, nonatomic) IBOutlet UIView *lineView;

///文件的路径
@property (nonatomic, strong) NSString *filePath;

///根控制器
@property (nonatomic, weak) LMRRootViewController *menuBarViewController;

///删除事件回调
@property (nonatomic, strong) void(^deleteNoteFileBlock)(NSString *filePath);

///音频事件回调
@property (nonatomic, strong) void(^audioPlayBlock)(NSString *filePath);

///视频事件播放回调
@property (nonatomic, strong) void(^videoPlayBlock)(NSString *filePath);


+ (instancetype)cell;

@end
