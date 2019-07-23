//
//  NotepadTableViewCell.m
//  ESignature_HD
//
//  Created by HanXueJian on 16-8-23.
//  Copyright (c) 2016年 china-sss. All rights reserved.
//

#import "NotepadTableViewCell.h"
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>

#import "Notify.h"
#import "Constant.h"

@interface NotepadTableViewCell ()

///音频播放器
@property (nonatomic, strong) AVAudioPlayer *audioPlayer;

///文本便签内容
@property (nonatomic, strong) NSString *noteMessage;

@end

@implementation NotepadTableViewCell

+ (instancetype)cell {
    return [[HXJNotepadBundle loadNibNamed:NSStringFromClass(self.class) owner:nil options:nil]lastObject];
}

#pragma mark - accessor methods
#pragma mark 获取文本文件内容
- (NSString *)noteMessage {
    NSError *error;
    NSString *noteMessage = [NSString stringWithContentsOfFile:self.filePath encoding:NSUTF8StringEncoding error:&error];
    if (error) {
        [Notify showAlertDialog:nil messageString:@"文本文件错误"];
    }
    return noteMessage;
}

#pragma mark 设置文件路径
- (void)setFilePath:(NSString *)filePath {
    _filePath = filePath;
    [self hideNote];
    NSFileManager *fileManage = [NSFileManager defaultManager];
    if (![fileManage fileExistsAtPath:filePath]) return;
    [self drawTitle];
    NSString *extension = [filePath pathExtension];
    
    if ([extension isEqualToString:NoteFileTypeText]) {
        self.noteMessageLabel.hidden = NO;
        self.noteMessageLabel.text = self.noteMessage;
    }else if ([extension isEqualToString:NoteFileTypeAudio]) {
        self.voiceButton.hidden = NO;
        NSURL *fileURL = [[NSURL alloc]initFileURLWithPath:filePath];
        AVURLAsset *audioAssert = [AVURLAsset URLAssetWithURL:fileURL options:nil];
        [audioAssert loadValuesAsynchronouslyForKeys:@[@"duration"] completionHandler:^{
            NSError *error = nil;
            NSInteger status = [audioAssert statusOfValueForKey:@"duration" error:&error];
            switch (status) {
                case AVKeyValueStatusLoaded:{
                    dispatch_async(dispatch_get_main_queue(), ^{
                        CMTime audioDuration = audioAssert.duration;
                        float audioDurationSeconds = CMTimeGetSeconds(audioDuration);
                        [self.voiceButton setTitle:[NSString stringWithFormat:@"%.0fs",audioDurationSeconds] forState:UIControlStateNormal];
                        [self.voiceButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                    });
                    break;
                }
                default:
                    dispatch_async(dispatch_get_main_queue(), ^{
                        NSLog(@"读取音频文件时长错误：%@",error);
                        [Notify showAlertDialog:nil messageString:@"读取音频文件时长错误"];
                    });
                    break;
            }
        }];
    }else if ([extension isEqualToString:NoteFileTypeImage]) {
        self.imageButton.hidden = NO;
        UIImage *image = [UIImage imageWithContentsOfFile:filePath];
        [self.imageButton setImage:image forState:UIControlStateNormal];
        
    }else if ([extension isEqualToString:NoteFileTypeVidoe]) {
        self.videoButton.hidden = NO;
        UIImage *image = [self getImageWithVideoURL:[NSURL fileURLWithPath:filePath]];
        [self.videoButton setBackgroundImage:image forState:UIControlStateNormal];
    }
    [self setNeedsLayout];
}

#pragma mark - view life cycle methods
- (void)awakeFromNib {
    [super awakeFromNib];
    self.deleteButton.layer.cornerRadius = 6;
    self.deleteButton.layer.borderWidth = 1;
    self.voiceButton.layer.cornerRadius = 6;
    self.voiceButton.layer.borderWidth = 1;
    [self.videoButton setImage:HXJNotepadBundleImage(@"moviePlay") forState:UIControlStateNormal];
}

- (void)layoutSubviews {
//    CGFloat cellHeight = 150;
//    if ([self.filePath containsString:NoteFileTypeText]) {
//        CGRect sizeRect = [self.noteMessage boundingRectWithSize:CGSizeMake(500, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:20.0]} context:nil];
//        self.noteMessageLabel.frame = CGRectMake(20, 40, 500, sizeRect.size.height);
//        cellHeight = sizeRect.size.height + 50;
//    }else if ([self.filePath containsString:NoteFileTypeAudio]){
//        cellHeight = 90;
//    }
//    self.contentView.frame = CGRectMake(0, 0, 748, cellHeight);
//    self.lineView.frame = CGRectMake(0, self.contentView.frame.size.height - 2, 748, 2);
//    self.deleteButton.center = CGPointMake(650, self.contentView.frame.size.height/2.0);
}

#pragma mark - inside methods
#pragma mark 隐藏控件
- (void)hideNote {
    self.noteMessageLabel.hidden = YES;
    self.voiceButton.hidden = YES;
    self.imageButton.hidden = YES;
    self.videoButton.hidden = YES;
}

#pragma mark 绘制时间标签
- (void)drawTitle {
    NSString *fileName = [self.filePath lastPathComponent];
    fileName = [fileName stringByDeletingPathExtension];
    NSArray *array = [fileName componentsSeparatedByString:@"-"];
    NSString *title = [NSString stringWithFormat:@"%@年%@月%@日  %@:%@",array[0],array[1],array[2],array[3],array[4]];
    self.titleLabel.text = title;
}

#pragma mark 获取视频截屏图片
- (UIImage *)getImageWithVideoURL:(NSURL *)videoURL {
    AVURLAsset *asset = [[AVURLAsset alloc]initWithURL:videoURL options:nil];
    AVAssetImageGenerator *generator = [[AVAssetImageGenerator alloc]initWithAsset:asset];
    generator.appliesPreferredTrackTransform = YES;
    CMTime time = CMTimeMakeWithSeconds(1.0, 600);
    NSError *error = nil;
    CMTime actualTime;
    CGImageRef image = [generator copyCGImageAtTime:time actualTime:&actualTime error:&error];
    UIImage *thumb = [[UIImage alloc]initWithCGImage:image];
    CGImageRelease(image);
    return thumb;
}

#pragma mark - 按钮点击事件
#pragma mark - 放大图片
- (IBAction)btnClickedOfImage:(UIButton *)sender {
    UIImage *image = [sender imageForState:UIControlStateNormal];
    if (image) {
        UIWindow *mainWindow = [[UIApplication sharedApplication]keyWindow];
        UIButton *imageButton = [[UIButton alloc]initWithFrame:mainWindow.frame];
        [imageButton setImage:image forState:UIControlStateNormal];
        [imageButton addTarget:self action:@selector(hideImageButton:) forControlEvents:UIControlEventTouchUpInside];
        [mainWindow addSubview:imageButton];
    }
}
- (void)hideImageButton:(UIButton *)sender {
    [sender removeFromSuperview];
}

#pragma mark 播放视频
- (IBAction)btnClickedOfVideo:(UIButton *)sender {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (self.videoPlayBlock && [fileManager fileExistsAtPath:self.filePath]){
        
        self.videoPlayBlock(self.filePath);
//        ALMPViewController *videoPalyerController = [[ALMPViewController alloc]init];
//        videoPalyerController.pathString = self.filePath;
//        [self.menuBarViewController.navigationController pushViewController:videoPalyerController animated:YES];
    }else{
        [Notify showAlertDialog:nil messageString:@"视频文件不存在"];
//        return;
    }
}

#pragma mark 音频播放按钮点击事件
- (IBAction)btnClickedOfAudioPlayer:(UIButton *)sender {
    if (!self.audioPlayBlock || ![self.filePath containsString:NoteFileTypeAudio]) return;
    self.audioPlayBlock(self.filePath);
}

#pragma mark 删除按钮放按钮点击事件
- (IBAction)btnClickedOfdelete:(UIButton *)sender {
    if (!self.deleteNoteFileBlock) return;
    self.deleteNoteFileBlock(self.filePath);
}
@end
