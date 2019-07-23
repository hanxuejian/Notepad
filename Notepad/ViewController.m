//
//  ViewController.m
//  Notepad
//
//  Created by han on 2019/7/9.
//  Copyright © 2019 han. All rights reserved.
//

#import "ViewController.h"
#import <HXJNotepad/HXJNotepad.h>

@interface ViewController ()

@property (nonatomic, strong) NotepadViewController *notepadViewController;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self addChildViewController:self.notepadViewController];
    [self.view addSubview:self.notepadViewController.view];
    
    NSString *a =  @__BASE_FILE__;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.notepadViewController.view.frame = self.view.frame;
}

- (NotepadViewController *)notepadViewController {
    if (_notepadViewController == nil) {
        _notepadViewController = [NotepadViewController notepadViewController];
    }
    return _notepadViewController;
}


@end
