# FQPhotoPicker
[![Version](https://img.shields.io/cocoapods/v/FQPhotoPicker.svg?style=flat)](http://cocoapods.org/pods/FQPhotoPicker)
[![License](https://img.shields.io/cocoapods/l/FQPhotoPicker.svg?style=flat)](http://cocoapods.org/pods/FQPhotoPicker)
[![Platform](https://img.shields.io/cocoapods/p/FQPhotoPicker.svg?style=flat)](http://cocoapods.org/pods/FQPhotoPicker)

**简介**

一款功能齐全的图片选择工具

**使用**
 
    -(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
    {

        FQImagePickerVc * imgPickerVc = [[FQImagePickerVc alloc]init];

        imgPickerVc.selectImageArrBlock = ^(NSArray<UIImage *> *imgArr) {
            NSLog(@"====================%@",imgArr);
        };

        UINavigationController *navigationVC = [[UINavigationController alloc]initWithRootViewController:imgPickerVc];

        [self presentViewController:navigationVC animated:YES completion:nil];
    }

**版本纪录**

    V0.0.6 添加gif图标以及gif动图效果

    V0.0.8 更改预览界面页面导航条动画效果

    V0.0.9 修复已经gif放大异常bug

    V0.1.1  新增预览界面滑动有系统相册效果.修复ios11版本上.快速滑动预览图片内存过大崩溃问题
