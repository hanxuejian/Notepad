//
//  Constant.h
//  Notepad
//
//  Created by han on 2019/7/11.
//  Copyright © 2019 han. All rights reserved.
//

#ifndef Constant_h
#define Constant_h

#define kScreenWidth UIScreen.mainScreen.bounds.size.width

#define HXJNotepadBundle FrameworkBundle(@"HXJNotepad")

#define HXJNotepadBundlePath FrameworkBundlePath(@"HXJNotepad")

#define HXJNotepadBundleImage(imageName) ResourceImage(imageName,HXJNotepadBundle)

/************************ 通用宏  ************************/

#define FrameworkBundle(name) [NSBundle bundleWithPath:FrameworkBundlePath(name)]

#define FrameworkBundlePath(name) [[NSBundle mainBundle]pathForResource:name ofType:@"framework" inDirectory:@"Frameworks"]

///获取资源包中指定的图片资源
#define ResourceImage(imageName,bundle) [UIImage imageWithContentsOfFile:ResourcesImagePath(imageName,bundle)]

///获取资源包中指定的图片资源路径
#define ResourcesImagePath(imageName,bundle) [ResourcesBundle(bundle) pathForResource:imageName ofType:@"png" inDirectory:@"pictures"]

///获取资源包
#define ResourcesBundle(bundle) [NSBundle bundleWithPath:[bundle pathForResource:@"Resources" ofType:@"bundle"]]

#define MainResourcesBundle ResourcesBundle([NSBundle mainBundle])

#define BundleInMainBundle(name,type) [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:name ofType:type]]

#endif /* Constant_h */
