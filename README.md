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
    
    V0.1.2  a.在某种情况下预览图获取失败.导致获取用户选中的所有图片数组时.在数组中添加nil而崩溃.当预览图获取失败时.直接使用thumbImg
            b.在iOS10.0版本的手机上.StatusBar会变透明.隐藏navigationBar然后使用topView来替代
