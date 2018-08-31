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

//扫一扫是选择一张就回调
@property (nonatomic, assign) BOOL isScanCode;
//是否是添加图片
@property (nonatomic, assign) BOOL isAddImageCount;
//点击一张回调
@property (nonatomic, copy) void(^selectScanCodeImgBlock)(UIImage * scanCodeImg);
//最多选中几张
@property (nonatomic, assign) NSInteger maxSelectCount;
//直接返回图片
@property (nonatomic, copy) void(^selectImageArrBlock)(NSArray<UIImage *>*imgArr);
//直接返回预览图
@property (nonatomic, copy) void(^selectPreviewImageArrBlock)(NSArray<UIImage *>*imgArr);
//直接返回FQAsset对象
@property (nonatomic, copy) void(^selectAssetArrBlock)(NSArray<FQAsset *>*assetArr);

@end
