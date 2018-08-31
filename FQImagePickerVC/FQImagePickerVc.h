//
//  FQImagePickerVc.h
//  FQPhotoPicker
//
//  Created by 龙腾飞 on 2018/3/26.
//  Copyright © 2018年 fanqi. All rights reserved.
//

#import <UIKit/UIKit.h>
@class FQAsset;

@interface FQImagePickerVc : UIViewController

@property (nonatomic, copy) void(^selectImageArrBlock)(NSArray<UIImage *>*imgArr);

@end
