//
//  FQImagePickerContainer.h
//  FQPhotoPicker
//
//  Created by 龙腾飞 on 2018/3/26.
//  Copyright © 2018年 fanqi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FQAsset.h"
#import "FQImagePickerCollectionCell.h"

@interface FQImagePickerContainer : NSObject

@property (nonatomic, copy) void(^changAssetCountBlock)(NSInteger count);

+(instancetype)share;


/**
 获取选中的AssetArr
 */
-(NSArray *)getSelectAssetArr;

/**
 新增指定的asset对象以及对应的cell
 */
-(void)addAsset:(FQAsset *)asset andImagePickerCell:(FQImagePickerCollectionCell *)cell;

/**
 移除指定的asset对象
 */
-(void)deleteAsset:(FQAsset *)asset andImagePickerCell:(FQImagePickerCollectionCell *)cell;

/**
 根据选中的数组去更新需要刷新展示的数据

 @param selectArr 待刷新展示的数据
 @return 更新完成的数组
 */
-(NSArray *)reloadSelectArrayWithArr:(NSArray *)selectArr;

/**
 清空选中的Asset
 */
-(void)clearSelectAssetArr;

/**
 获得用户选中的所有图片

 @return 图片数组
 */
-(NSArray <UIImage *> *)getSelectImageArr;


/**
 是否达到上限.yes为已经达到上限.no为未达到上限

 @return 是否达到上限
 */
+(BOOL)isUpperLimit;
@end
