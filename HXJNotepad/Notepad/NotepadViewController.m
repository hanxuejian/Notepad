//
//  NotepadViewController.m
//  ESignature_HD
//
//  Created by HanXueJian on 16-8-17.
//  Copyright (c) 2016年 china-sss. All rights reserved.
//

#import "NotepadViewController.h"

#import "Notify.h"
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>
#import "NotepadTableViewCell.h"
#import "NSString+SA.h"
#import "UIView+SA.h"
#import "Constant.h"

#define NoteMediaTypeImage @"public.image"
#define NoteMediaTypeVideo @"public.movie"

#define notepadCellIdentifier @"notepadCellIdentifier"

@interface NotepadViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate,UITableViewDataSource,UITableViewDelegate,AVAudioRecorderDelegate,UIScrollViewDelegate>

///所有视图的父视图
@property (weak, nonatomic) IBOutlet UIView *contentView;
///问题便签列表
@property (nonatomic, weak) IBOutlet UITableView *notepadTableView;
///输入框和按钮的父容器
@property (weak, nonatomic) IBOutlet UIView *footerView;
///文本便签输入框
@property (weak, nonatomic) IBOutlet UITextField *noteTextFeild;
///保存文本便签的按钮
@property (weak, nonatomic) IBOutlet UIButton *senderNoteButton;

///附件添加按钮容器视图
@property (nonatomic, strong) UIView *accessoryView;

///当前选中的添加便签的按钮
@property (nonatomic, weak) UIButton *selectedAddNoteButton;

///键盘是否是显示状态
@property (nonatomic) BOOL isKeyBoardShowing;

///当前是否正在录音
@property (nonatomic) BOOL isRecordingVoice;

///便签保存的路径
@property (nonatomic, strong) NSString *noteSavedPath;

///录音
@property (nonatomic, strong) AVAudioRecorder *audioRecord;
///录音按钮
@property (nonatomic, strong) UIButton *audioRecordButton;
///录音文件地址
@property (nonatomic, strong) NSString *audioFilePath;

///音频播放器
@property (nonatomic, strong) AVAudioPlayer *audioPlayer;
///当前播放的音频地址
@property (nonatomic, strong) NSString *audioPlayingFilePath;

///问题便签列表数据源
@property (nonatomic, strong) NSMutableArray *notepadFilePaths;

@end

@implementation NotepadViewController

+ (instancetype)notepadViewController {
    return [[NotepadViewController alloc]initWithNibName:NSStringFromClass(self.class) bundle:HXJNotepadBundle];
}

#pragma mark - view life cycle methods
- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];
    [self initData];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    NSLog(@"==============");
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    self.isKeyBoardShowing = NO;
    [self.noteTextFeild resignFirstResponder];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

- (void)viewWillDisappear:(BOOL)animated {
    self.audioPlayer = nil;
    self.audioPlayingFilePath = nil;
}

#pragma mark - accessor methods
#pragma mark 设置当前选中的添加便签的按钮
- (void)setSelectedAddNoteButton:(UIButton *)selectedAddNoteButton {
    if (_selectedAddNoteButton != selectedAddNoteButton ) {
        _selectedAddNoteButton.selected = NO;
        _selectedAddNoteButton = selectedAddNoteButton;
        _selectedAddNoteButton.selected = YES;
    }
}

#pragma mark 获取所有问题便签的文件的路径
- (NSMutableArray *)notepadFilePaths {
    if (_notepadFilePaths == nil) {
        _notepadFilePaths = [NSMutableArray array];
    }
    return _notepadFilePaths;
}

#pragma mark 获取便签保存的路径
- (NSString *)noteSavedPath {
    if (_noteSavedPath.length == 0) {
        NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        NSString *identitierDoc = @"test";//[NSString stringWithFormat:@"%@-%@-%@",self.workingViewController.lmrTask.lmrTaskID,self.workingViewController.lmrTask.billing.repairLmrWorkId,self.workingViewController.lmrTask.billing.airplaneNumber];
        path = [NSString stringWithFormat:@"%@/noteSaved/%@",path,identitierDoc];
        _noteSavedPath = path;
    }
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    if (![fileManager fileExistsAtPath:_noteSavedPath]) {
        [fileManager createDirectoryAtPath:_noteSavedPath withIntermediateDirectories:YES attributes:nil error:&error];
        if (error) {
//            [Notify showAlertDialog:nil messageString:@"文件错误"];
            return nil;
        }
    }
    return _noteSavedPath;
}

#pragma mark 获取录音按钮
- (UIButton *)audioRecordButton {
    if (_audioRecordButton == nil) {
        //录音按钮
        _audioRecordButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _audioRecordButton.frame = CGRectMake((kScreenWidth-150)/2, 0, 150, 250);
        _audioRecordButton.reversesTitleShadowWhenHighlighted = YES;
        _audioRecordButton.adjustsImageWhenHighlighted = YES;
        [_audioRecordButton setImage:HXJNotepadBundleImage(@"speak") forState:UIControlStateNormal];
        [_audioRecordButton setImage:HXJNotepadBundleImage(@"speaking") forState:UIControlStateHighlighted];
        [_audioRecordButton setTitle:@"长按录音" forState:UIControlStateNormal];
        [_audioRecordButton setTitle:@"正在录音" forState:UIControlStateHighlighted];
        [_audioRecordButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [_audioRecordButton setTitleEdgeInsets:UIEdgeInsetsMake(150, -135, 0, 0)];
        [_audioRecordButton setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 60, 0)];
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(btnLongPressOfRecordVoice:)];
        longPress.minimumPressDuration = 1;
        [_audioRecordButton addGestureRecognizer:longPress];
    }
    return _audioRecordButton;
}

#pragma mark - inside methods
- (void)initView {
    [self initAddNoteButton];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
}

#pragma mark 初始化界面数据
- (void)initData {
    if (self.noteSavedPath.length > 0) {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSArray *subpaths = [fileManager subpathsAtPath:self.noteSavedPath];
        if (subpaths.count == 0) return;
        subpaths = [subpaths sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            return [obj1 compare:obj2 options:NSCaseInsensitiveSearch];
        }];
        
        for (NSString *fileName in subpaths) {
            if (![self isValidFile:fileName]) continue;
            [self.notepadFilePaths addObject:[self.noteSavedPath stringByAppendingPathComponent:fileName]];
        }
    }
    [self.notepadTableView reloadData];
}

#pragma mark 判断文件是否有效
- (BOOL)isValidFile:(NSString *)fileName {
    if ([fileName hasSuffix:NoteFileTypeText]) return YES;
    if ([fileName hasSuffix:NoteFileTypeAudio]) return YES;
    if ([fileName hasSuffix:NoteFileTypeImage]) return YES;
    if ([fileName hasSuffix:NoteFileTypeVidoe]) return YES;
    return NO;
}

#pragma mark 绘制问题标签-图片
- (void)drawNoteImageWithImage:(UIImage *)image {
    NSError *error;
    NSString *path = [self.noteSavedPath stringByAppendingPathComponent:[self getNoteFileName]];
    path = [path stringByAppendingPathExtension:NoteFileTypeImage];
    [UIImagePNGRepresentation(image) writeToFile:path options:NSDataWritingAtomic error:&error];
    if (error) {
//        [Notify showAlertDialog:nil messageString:@"图片保存错误"];
        return;
    }
    [self addNotepadFilePathsWithFilePath:path];
}

#pragma mark 初始化添加便签按钮
- (void)initAddNoteButton {
    self.senderNoteButton.layer.cornerRadius = 6;
    self.accessoryView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
    self.accessoryView.backgroundColor = [UIColor whiteColor];
    self.noteTextFeild.inputAccessoryView = self.accessoryView;
    
    UIButton *addTextButton = [UIButton buttonWithType:UIButtonTypeCustom];
    addTextButton.frame = CGRectMake(10, 0, 60, 50);
    [addTextButton setImage:HXJNotepadBundleImage(@"icon_19") forState:UIControlStateNormal];
    [addTextButton setImage:HXJNotepadBundleImage(@"icon_34") forState:UIControlStateSelected];
    [addTextButton addTarget:self action:@selector(btnClickedOfaddAccessory:) forControlEvents:UIControlEventTouchUpInside];
    addTextButton.tag = 1;
    [self.accessoryView addSubview:addTextButton];
    
    UIButton *addVoiceButton = [UIButton buttonWithType:UIButtonTypeCustom];
    addVoiceButton.frame = CGRectMake(70, 0, 60, 50);
    [addVoiceButton setImage:HXJNotepadBundleImage(@"icon_21") forState:UIControlStateNormal];
    [addVoiceButton setImage:HXJNotepadBundleImage(@"icon_35") forState:UIControlStateSelected];
    [addVoiceButton addTarget:self action:@selector(btnClickedOfaddAccessory:) forControlEvents:UIControlEventTouchUpInside];
    addVoiceButton.tag = 2;
    [self.accessoryView addSubview:addVoiceButton];
    
    UIButton *addPictureButton = [UIButton buttonWithType:UIButtonTypeCustom];
    addPictureButton.frame = CGRectMake(130, 0, 60, 50);
    [addPictureButton setImage:HXJNotepadBundleImage(@"icon_23") forState:UIControlStateNormal];
    [addPictureButton setImage:HXJNotepadBundleImage(@"icon_36") forState:UIControlStateHighlighted];
    [addPictureButton addTarget:self action:@selector(btnClickedOfaddAccessory:) forControlEvents:UIControlEventTouchUpInside];
    addPictureButton.tag = 3;
    [self.accessoryView addSubview:addPictureButton];
    
    UIButton *addPhotoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    addPhotoButton.frame = CGRectMake(190, 0, 60, 50);
    [addPhotoButton setImage:HXJNotepadBundleImage(@"icon_25") forState:UIControlStateNormal];
    [addPhotoButton setImage:HXJNotepadBundleImage(@"icon_37") forState:UIControlStateHighlighted];
    [addPhotoButton addTarget:self action:@selector(btnClickedOfaddAccessory:) forControlEvents:UIControlEventTouchUpInside];
    addPhotoButton.tag = 4;
    [self.accessoryView addSubview:addPhotoButton];
    
    UIButton *addVidoeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    addVidoeButton.frame = CGRectMake(250, 0, 60, 50);
    [addVidoeButton setImage:HXJNotepadBundleImage(@"icon_27") forState:UIControlStateNormal];
    [addVidoeButton setImage:HXJNotepadBundleImage(@"icon_38") forState:UIControlStateHighlighted];
    [addVidoeButton addTarget:self action:@selector(btnClickedOfaddAccessory:) forControlEvents:UIControlEventTouchUpInside];
    addVidoeButton.tag = 5;
    [self.accessoryView addSubview:addVidoeButton];
    
    self.selectedAddNoteButton = addTextButton;
}

#pragma mark 初始化录音器
- (BOOL)initAudioRecordWithFile:(NSString *)filePath {
    //录音设置
    NSMutableDictionary * recordSetting = [[NSMutableDictionary alloc] init];
    //设置录音格式 AVFormatIDKey == kAudioFormatLinearPCM
    [recordSetting setValue:[NSNumber numberWithInt:kAudioFormatMPEG4AAC] forKey:AVFormatIDKey];
    //设置录音采样率(Hz) 如:AVSampleRateKey==8000/44100/96000(影响音频的质量)
    [recordSetting setValue:[NSNumber numberWithFloat:44100] forKey:AVSampleRateKey];
    //语音通道数 1 或 2
    [recordSetting setValue:[NSNumber numberWithInt:1] forKey:AVNumberOfChannelsKey];
    //线性采样位数 8  16  24  32
    [recordSetting setValue:[NSNumber numberWithInt:16] forKey:AVLinearPCMBitDepthKey];
    //录音的质量
    [recordSetting setValue:[NSNumber numberWithInt:AVAudioQualityHigh] forKey:AVEncoderAudioQualityKey];
    
    NSURL *audioURL = [NSURL fileURLWithPath:filePath];
    NSError *error;
    //初始化
    self.audioRecord = [[AVAudioRecorder alloc]initWithURL:audioURL settings:recordSetting error:&error];
    //开启音量检测
    self.audioRecord.meteringEnabled = YES;
//    [self.audioRecord recordForDuration:60];
    self.audioRecord.delegate = self;
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryRecord error:&error];
    [session setActive:YES error:&error];
    if (error || ![self.audioRecord prepareToRecord]){
//        [Notify showAlertDialog:nil messageString:@"录音准备错误"];
        @"录音准备错误".show;
        [self.audioRecord deleteRecording];
        [[NSFileManager defaultManager]removeItemAtPath:self.audioFilePath error:nil];
        return NO;
    }
    return YES;
}

#pragma mark 获取新增便签的文件名称
- (NSString *)getNoteFileName {
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    formatter.dateFormat = @"YYYY-MM-dd-HH-mm-ss";
    NSString *fileName = [formatter stringFromDate:[NSDate date]];
    return fileName;
}

#pragma mark 新增问题便签
- (void)addNotepadFilePathsWithFilePath:(NSString *)filePath {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.notepadFilePaths addObject:filePath];
        NSIndexPath *index = [NSIndexPath indexPathForRow:self.notepadFilePaths.count-1 inSection:0];
        [self.notepadTableView insertRowsAtIndexPaths:@[index] withRowAnimation:UITableViewRowAnimationFade];
        [self.notepadTableView scrollToRowAtIndexPath:index atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    });
}

#pragma mark - button clicked methods
#pragma mark 保存文本便签
- (IBAction)btnClickedOfSaveNote:(UIButton *)sender {
    if (self.isRecordingVoice || [self.noteTextFeild.text isEmptyIgnoreBlankAndEnter]) return;
    NSError *error;
    NSString *path = [self.noteSavedPath stringByAppendingPathComponent:[self getNoteFileName]];
    path = [path stringByAppendingPathExtension:NoteFileTypeText];
    //保存文本文件
    [self.noteTextFeild.text writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:&error];
    if (error) {
        [Notify showAlertDialog:nil messageString:@"文件错误"];
        return;
    }
    self.noteTextFeild.text = @"";
    [self.noteTextFeild resignFirstResponder];
    [self addNotepadFilePathsWithFilePath:path];
}

#pragma mark 录音按钮长按事件
- (void)btnLongPressOfRecordVoice:(UILongPressGestureRecognizer *)sender {
    NSLog(@"录音时长 %fs  ",self.audioRecord.currentTime);
    if (sender.state == UIGestureRecognizerStateBegan) {
        NSString *fileName = [self getNoteFileName];
        self.audioFilePath = [self.noteSavedPath stringByAppendingPathComponent:fileName];
        self.audioFilePath = [self.audioFilePath stringByAppendingPathExtension:NoteFileTypeAudio];
        if (![self initAudioRecordWithFile:self.audioFilePath]) return;
        [self.audioRecord record];
        self.isRecordingVoice = YES;
        [self.audioRecordButton setTitle:@"正在录音" forState:UIControlStateNormal];
        [self.audioRecordButton setImage:HXJNotepadBundleImage(@"speaking") forState:UIControlStateNormal];
    }else if(sender.state == UIGestureRecognizerStateEnded) {
        [self.audioRecordButton setTitle:@"长按录音" forState:UIControlStateNormal];
        [self.audioRecordButton setImage:HXJNotepadBundleImage(@"speak") forState:UIControlStateNormal];
        if (self.audioRecord.currentTime < 2) {
            [self.audioRecord stop];
            self.isRecordingVoice = NO;
            [self.audioRecord deleteRecording];
            [[NSFileManager defaultManager]removeItemAtPath:self.audioFilePath error:nil];
            self.audioFilePath = nil;
//            [Notify showAlertDialog:nil messageString:@"音频时长不能低于2s"];
            @"音频时长不能低于2s".show;
        }else {
            [self.audioRecord stop];
            self.isRecordingVoice = NO;
        }
    }
}

#pragma mark 选择附件类型按钮点击事件
- (void)btnClickedOfaddAccessory:(UIButton *)sender {
    if (sender.selected) return;
    self.isKeyBoardShowing = YES;
    switch (sender.tag) {
        case 1:
            self.selectedAddNoteButton = sender;
            self.noteTextFeild.inputView = nil;
            [self.noteTextFeild reloadInputViews];
            self.isKeyBoardShowing = NO;
            break;
        case 2: {
            self.selectedAddNoteButton = sender;
            UIView *inputView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 250)];
            inputView.backgroundColor = [UIColor whiteColor];
            [inputView addSubview:self.audioRecordButton];
            self.noteTextFeild.inputView = inputView;
            [self.noteTextFeild reloadInputViews];
            self.isKeyBoardShowing = NO;
            break;
        }
        case 3:{
            self.isKeyBoardShowing = NO;
//            [self.noteTextFeild resignFirstResponder];
            UIImagePickerController *imagePickerController = [[UIImagePickerController alloc]init];
            imagePickerController.delegate = self;
            [self.noteTextFeild resignFirstResponder];
            [self presentViewController:imagePickerController animated:YES completion:nil];
            break;
        }
        case 4:{
            self.isKeyBoardShowing = NO;
//            [self.noteTextFeild resignFirstResponder];
            UIImagePickerController *imagePickerController = [[UIImagePickerController alloc]init];
            imagePickerController.delegate = self;
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
                [self.noteTextFeild resignFirstResponder];
                [self presentViewController:imagePickerController animated:YES completion:nil];
            }else{
//                [Notify showAlertDialog:nil messageString:@"相机损坏或无权限"];
                @"相机损坏或无权限".show;
                return;
            }
            break;
        }
        case 5:{
            self.isKeyBoardShowing = NO;
//            [self.noteTextFeild resignFirstResponder];
            UIImagePickerController *videoPickerController = [[UIImagePickerController alloc]init];
            videoPickerController.delegate = self;
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                NSArray *availableMedia = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
                if ([availableMedia containsObject:NoteMediaTypeVideo]) {
                    videoPickerController.mediaTypes = @[NoteMediaTypeVideo];
                    videoPickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
                    [self.noteTextFeild resignFirstResponder];
                    [self presentViewController:videoPickerController animated:YES completion:nil];
                }else{
//                    [self.noteTextFeild resignFirstResponder];
//                    [Notify showAlertDialog:nil messageString:@"相机不可用"];
                    @"相机不可用".show;
                    return;
                }
            }else{
//                [self.noteTextFeild resignFirstResponder];
//                [Notify showAlertDialog:nil messageString:@"相机损坏或无权限"];
                @"相机损坏或无权限".show;
                return;
            }
            break;
        }
        default:
            break;
    }
}

#pragma mark - <UINavigationControllerDelegate, UIImagePickerControllerDelegate> methods
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    NSString *mediaType = info[UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:NoteMediaTypeImage]) {
        UIImage *image = info[UIImagePickerControllerOriginalImage];
        [self drawNoteImageWithImage:image];
    }else if([mediaType isEqualToString:NoteMediaTypeVideo]){
        
        NSString *fileName = [self getNoteFileName];
        fileName = [fileName stringByAppendingPathExtension:NoteFileTypeVidoe];
        NSString *filePath = [self.noteSavedPath stringByAppendingPathComponent:fileName];
        
        NSURL *videoURL = info[UIImagePickerControllerMediaURL];
        
        AVURLAsset *videoAssert = [AVURLAsset URLAssetWithURL:videoURL options:nil];
        NSArray *exportPresets = [AVAssetExportSession exportPresetsCompatibleWithAsset:videoAssert];
        if ([exportPresets containsObject:AVAssetExportPresetHighestQuality]) {
            UIAlertView *saveAlert = [[UIAlertView alloc]init];
            saveAlert.title = @"正在保存视频···";
            [saveAlert show];
            
            
            AVAssetExportSession *exportSession = [[AVAssetExportSession alloc]initWithAsset:videoAssert presetName:AVAssetExportPresetHighestQuality];
            exportSession.outputURL = [NSURL fileURLWithPath:filePath];
            exportSession.shouldOptimizeForNetworkUse = NO;
            exportSession.outputFileType = AVFileTypeQuickTimeMovie;
            [exportSession exportAsynchronouslyWithCompletionHandler:^{
                switch ([exportSession status]) {
                    case AVAssetExportSessionStatusFailed:{
                        [saveAlert dismissWithClickedButtonIndex:0 animated:YES];
                        [Notify showAlertDialog:nil messageString:@"录屏失败"];
                        [self imagePickerControllerDidCancel:picker];
                        [[NSFileManager defaultManager]removeItemAtURL:videoURL error:nil];
                        return;
                    }
                    case AVAssetExportSessionStatusCancelled:
                        [saveAlert dismissWithClickedButtonIndex:0 animated:YES];
                        [Notify showAlertDialog:nil messageString:@"录屏取消"];
//                        @"video is cancel".show;
                        [self imagePickerControllerDidCancel:picker];
                        [[NSFileManager defaultManager]removeItemAtURL:videoURL error:nil];
                        return;
                    case AVAssetExportSessionStatusCompleted:
                        [self addNotepadFilePathsWithFilePath:filePath];
                        [saveAlert dismissWithClickedButtonIndex:0 animated:YES];
                        [[NSFileManager defaultManager]removeItemAtURL:videoURL error:nil];
                        break;
                    default:
                        [saveAlert dismissWithClickedButtonIndex:0 animated:YES];
                        break;
                }
            }];
        }else{
            [[NSFileManager defaultManager]removeItemAtURL:videoURL error:nil];
            [Notify showAlertDialog:nil messageString:@"不支持MP4高清录屏"];
        }
    }
    [self imagePickerControllerDidCancel:picker];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - <UITableViewDataSource,UITableViewDelegate> methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.notepadFilePaths.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NotepadTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:notepadCellIdentifier];
    if (!cell) {
        cell = [NotepadTableViewCell cell];
//        cell = [[[NSBundle mainBundle]loadNibNamed:@"NotepadTableViewCell" owner:self options:nil]lastObject];
        //cell.menuBarViewController = self.workingViewController.menuBarViewController;
        cell.deleteNoteFileBlock = ^(NSString *filePath){
            if (![self.notepadFilePaths containsObject:filePath]) return;
            if ([self.audioPlayer isPlaying] && [filePath isEqualToString:self.audioPlayingFilePath]) {
                [self.audioPlayer stop];
                self.audioPlayer = nil;
            }
            NSIndexPath *index = [NSIndexPath indexPathForRow:[self.notepadFilePaths indexOfObject:filePath] inSection:0];
            [self.notepadFilePaths removeObject:filePath];
            [tableView deleteRowsAtIndexPaths:@[index] withRowAnimation:UITableViewRowAnimationFade];
            [[NSFileManager defaultManager]removeItemAtURL:[NSURL fileURLWithPath:filePath] error:nil];
        };
        cell.audioPlayBlock = ^(NSString *filePath) {
            NSFileManager *fileManager = [NSFileManager defaultManager];
            if ([self.audioPlayer isPlaying] && [filePath isEqualToString:self.audioPlayingFilePath]) {
                [self.audioPlayer pause];
                return;
            }
            NSError *error;
            if ([fileManager fileExistsAtPath:filePath]){
                self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:filePath] error:&error];
                AVAudioSession *session = [AVAudioSession sharedInstance];
                [session setCategory:AVAudioSessionCategoryPlayback error:&error];
                [session setActive:YES error:&error];
                if (error) {
                    [Notify showAlertDialog:nil messageString:@"无效的音频文件"];
                    return;
                }
                [self.audioPlayer play];
                self.audioPlayingFilePath = filePath;
            }else{
                [Notify showAlertDialog:nil messageString:@"音频文件不存在"];
                return;
            }
        };
        cell.videoPlayBlock = ^(NSString *filePath) {
            NSURL *url = [NSURL fileURLWithPath:filePath];
            AVPlayer *player = [[AVPlayer alloc]initWithURL:url];
            AVPlayerViewController *playerVC = [[AVPlayerViewController alloc]init];
            playerVC.player = player;
            [self presentViewController:playerVC animated:YES completion:nil];
        };
    }
    cell.filePath = self.notepadFilePaths[indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat cellHeight = 150;
    NSString *filePath = self.notepadFilePaths[indexPath.row];
    if ([filePath containsString:NoteFileTypeText]) {
        NSError *error;
        NSString *noteMessage = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:&error];
        CGRect sizeRect = [noteMessage boundingRectWithSize:CGSizeMake(500, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:20.0]} context:nil];
        cellHeight = sizeRect.size.height + 50;
    }else if([filePath containsString:NoteFileTypeAudio]){
        cellHeight = 90;
    }
    return cellHeight;
}

#pragma mark - <UIScrollViewDelegate> method
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (self.noteTextFeild.isFirstResponder) {
        [self.noteTextFeild resignFirstResponder];
    }
}

#pragma mark - <AVAudioRecorderDelegate> methods
- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag {
    if (self.audioFilePath) {
        [self.noteTextFeild resignFirstResponder];
        [self addNotepadFilePathsWithFilePath:self.audioFilePath];
    }
}

- (void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError *)error {
    NSLog(@"录音错误%@",error);
    [Notify showAlertDialog:nil messageString:@"录音失败"];
}

#pragma mark - UIKeyboardWillChangeFrameNotification method
#pragma mark 键盘弹出与收起事件
- (void)keyboardWillChangeFrame:(NSNotification *)notification {
    CGRect endFrame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey]CGRectValue];
    CGFloat heihtOfCovered = 0;
    BOOL isCovered = [self.footerView isCoveredByKeyboard:endFrame heightOfCovered:&heihtOfCovered];
    CGRect temp = self.footerView.frame;
    
    if (isCovered) {
        //调整被键盘遮盖的视图
        self.footerView.frame = CGRectMake(temp.origin.x, temp.origin.y + heihtOfCovered, temp.size.width, temp.size.height);
    }else {
        if (endFrame.origin.y < [UIScreen mainScreen].bounds.size.height) {
            //当键盘高度改变时，调整视图
            temp.origin.y = heihtOfCovered + temp.origin.y;
            self.footerView.frame = temp;
        }else{
            [self.contentView setNeedsLayout];
            if (self.isKeyBoardShowing) return;
        }
    }
}

@end
