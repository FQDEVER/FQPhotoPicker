# FQPhotoPicker
[![Version](https://img.shields.io/cocoapods/v/FQPhotoPicker.svg?style=flat)](http://cocoapods.org/pods/FQPhotoPicker)
[![License](https://img.shields.io/cocoapods/l/FQPhotoPicker.svg?style=flat)](http://cocoapods.org/pods/FQPhotoPicker)
[![Platform](https://img.shields.io/cocoapods/p/FQPhotoPicker.svg?style=flat)](http://cocoapods.org/pods/FQPhotoPicker)

###简介

一款功能齐全的图片选择工具

###使用
 
    -(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
    {

        FQImagePickerVc * imgPickerVc = [[FQImagePickerVc alloc]init];

        imgPickerVc.selectImageArrBlock = ^(NSArray<UIImage *> *imgArr) {
            NSLog(@"====================%@",imgArr);
        };

        UINavigationController *navigationVC = [[UINavigationController alloc]initWithRootViewController:imgPickerVc];

        [self presentViewController:navigationVC animated:YES completion:nil];
    }
