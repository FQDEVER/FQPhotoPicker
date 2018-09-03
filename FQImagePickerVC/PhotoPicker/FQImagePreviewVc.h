//
//  FQImagePreviewVc.h
//  FQPhotoPicker
//
//  Created by 龙腾飞 on 2018/3/27.
//  Copyright © 2018年 fanqi. All rights reserved.
//

#import <UIKit/UIKit.h>
@class FQAsset;
@interface FQImagePreviewVc : UIViewController

/**
 最多选中几张
 */
@property (nonatomic, assign) NSInteger maxSelectCount;

/**
 是否是发布时预览
 */
@property (nonatomic, assign) BOOL isReleasePreview;

/**
 发布预览的删除与增加回调
 */
@property (nonatomic, copy) void(^changPreviewBlock)(NSArray * assetArr);

/**
 是否隐藏原图按钮.默认为YES
 */
@property (nonatomic, assign) BOOL isHiddenOrginBtn;

/**
 直接返回图片
 */
@property (nonatomic, copy) void(^selectImageArrBlock)(NSArray<UIImage *>*imgArr);

/**
 直接返回预览图
 */
@property (nonatomic, copy) void(^selectPreviewImageArrBlock)(NSArray<UIImage *>*imgArr);

/**
 直接返回FQAsset对象
 */
@property (nonatomic, copy) void(^selectAssetArrBlock)(NSArray<FQAsset *>*assetArr);

/**
 传入数据

 @param previewArr 所有数据数组
 @param selectIndex 当前选中的索引
 */
-(void)setImgPreviewVc:(NSArray *)previewArr selectIndex:(NSInteger )selectIndex;

@end
