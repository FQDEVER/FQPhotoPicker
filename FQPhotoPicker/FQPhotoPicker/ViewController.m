//
//  ViewController.m
//  FQPhotoPicker
//
//  Created by 龙腾飞 on 2018/3/24.
//  Copyright © 2018年 fanqi. All rights reserved.
//

#import "ViewController.h"
#import "FQImagePickerVc.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    
    FQImagePickerVc * imgPickerVc = [[FQImagePickerVc alloc]init];
    
    imgPickerVc.selectImageArrBlock = ^(NSArray<UIImage *> *imgArr) {
        NSLog(@"====================%@",imgArr);
    };
    
    UINavigationController *navigationVC = [[UINavigationController alloc]initWithRootViewController:imgPickerVc];
    
    [self presentViewController:navigationVC animated:YES completion:nil];
}


@end
