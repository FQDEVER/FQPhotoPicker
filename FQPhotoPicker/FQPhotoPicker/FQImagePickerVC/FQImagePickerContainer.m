//
//  FQImagePickerContainer.m
//  FQPhotoPicker
//
//  Created by 龙腾飞 on 2018/3/26.
//  Copyright © 2018年 fanqi. All rights reserved.
//

#import "FQImagePickerContainer.h"
#import "FQImagePickerCollectionCell.h"

@interface FQImagePickerContainer()

//选中的assetArr
@property (nonatomic, strong) NSMutableArray * assetArr;

//纪录当前页面选中的cell.
@property (nonatomic, strong) NSMutableArray *selectCurrentCellArr;

@end

@implementation FQImagePickerContainer

static FQImagePickerContainer *imgPickerContainer;

+(instancetype)allocWithZone:(struct _NSZone *)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        imgPickerContainer = [super allocWithZone:zone];
    });
    return imgPickerContainer;
}

+(instancetype)share
{
    return [[FQImagePickerContainer alloc]init];
}

-(id)copyWithZone:(NSZone *)zone
{
    return imgPickerContainer;
}

-(id)mutableCopyWithZone:(NSZone *)zone
{
    return imgPickerContainer;
}


-(void)addAsset:(FQAsset *)asset andImagePickerCell:(FQImagePickerCollectionCell *)cell
{
    if (![self.assetArr containsObject:asset] && asset != nil) {
        [self.assetArr addObject:asset];
        asset.isSelect = YES;
        asset.selectIndex = self.assetArr.count;
    }
    
    if (![self.selectCurrentCellArr containsObject:cell] && cell != nil) {
        [self.selectCurrentCellArr addObject:cell];
    }
    
    //每添加一次就回调一次到控制器
    if (_changAssetCountBlock) {
        _changAssetCountBlock(self.assetArr.count);
    }
}

-(void)deleteAsset:(FQAsset *)asset andImagePickerCell:(FQImagePickerCollectionCell *)cell
{
    if ([self.assetArr containsObject:asset]) {
        asset.isSelect = NO;
        asset.selectIndex = 0;
        [self.assetArr removeObject:asset];
        
        for (int i = 0; i < self.assetArr.count; ++i) {
            FQAsset * asset = self.assetArr[i];
            asset.isSelect = YES;
            asset.selectIndex = i + 1;
        }
    }

    if ([self.selectCurrentCellArr containsObject:cell] && cell != nil) {
        [self.selectCurrentCellArr removeObject:cell];
    }
    
    //编号重新更新
    for (FQImagePickerCollectionCell * selectCell in self.selectCurrentCellArr) {
        [selectCell upload];
    }
    
    //每添加一次就回调一次到控制器
    if (_changAssetCountBlock) {
        _changAssetCountBlock(self.assetArr.count);
    }
}

/**
 获得用户选中的所有图片
 
 @return 图片数组
 */
-(NSArray <UIImage *> *)getSelectImageArr
{
    NSMutableArray * selectImgArr = [NSMutableArray array];
    for (FQAsset * asset in self.assetArr) {
         if (asset.isGif) {
             [selectImgArr addObject:asset.gifImage ? asset.gifImage : asset.previewImg];
         }else{
             if (asset.isOrgin) {
                 [selectImgArr addObject:asset.orginImg];
             }else{
                 if (asset.previewImg) {
                     [selectImgArr addObject:asset.previewImg];
                 }else{
                     [selectImgArr addObject:asset.thumbImg];
                 }
             }
         }
    }
    return selectImgArr.copy;
}


/**
 获得用户选中的所有预览图
 
 @return 图片数组
 */
-(NSArray <UIImage *> *)getSelectPreviewImageArr
{
    NSMutableArray * selectImgArr = [NSMutableArray array];
    for (FQAsset * asset in self.assetArr) {
            [selectImgArr addObject:asset.previewImg];
    }
    return selectImgArr.copy;
}

/**
 获得用户选中的所有Asset对象
 
 @return 图片数组
 */
-(NSArray <FQAsset *> *)getSelectAssetArr
{
    return self.assetArr.copy;
}

/**
 清空选中的Asset
 */
-(void)clearSelectAssetArr
{
    for (FQAsset * asset in self.assetArr) {
        asset.selectIndex = 0;
        asset.isSelect = NO;
        asset.isOrgin = NO;
    }
    [self.assetArr removeAllObjects];
    
    [self.selectCurrentCellArr removeAllObjects];
}

/**
 根据选中的数组去更新需要刷新展示的数据 - 并且清空当前选中的cell.
 
 @param selectArr 待刷新展示的数据
 @return 更新完成的数组
 */
-(NSArray *)reloadSelectArrayWithArr:(NSArray *)selectArr
{
    NSMutableArray * dataMuArr = [NSMutableArray array]; //更新self.assetArr
    for (FQAsset * selectIndexAsset in self.assetArr) {
        NSInteger count = 0;
        for (FQAsset * selectAsset in selectArr) {
            if ([selectAsset.asset.localIdentifier isEqualToString:selectIndexAsset.asset.localIdentifier] && ![selectAsset isEqual:selectIndexAsset]) {
                [selectAsset setAssetWithFQAsset:selectIndexAsset];
                [dataMuArr addObject:selectAsset];
                count = 1;
                selectIndexAsset.selectIndex = 0;
                selectIndexAsset.isSelect = NO;
                selectIndexAsset.isOrgin = NO;
            }else if ([selectAsset isEqual:selectIndexAsset]){
                [dataMuArr addObject:selectIndexAsset];
                count = 1;
            }
        }
        if (count == 0) {
            [dataMuArr addObject:selectIndexAsset];
        }
    }
    
    self.assetArr = dataMuArr;
    
    //删除所有文件
    [self.selectCurrentCellArr removeAllObjects];
    
    return selectArr;
}

/**
 根据选中的数组去更新需要刷新展示的数据 - 并且不清空当前选中的cell.
 
 @param selectArr 待刷新展示的数据
 @return 更新完成的数组
 */
-(NSArray *)reloadSelectArrayNoneClearCurrentCellWithArr:(NSArray *)selectArr
{
    NSMutableArray * dataMuArr = [NSMutableArray array]; //更新self.assetArr
    for (FQAsset * selectIndexAsset in self.assetArr) {
        NSInteger count = 0;
        for (FQAsset * selectAsset in selectArr) {
            if ([selectAsset.asset.localIdentifier isEqualToString:selectIndexAsset.asset.localIdentifier] && ![selectAsset isEqual:selectIndexAsset]) {
                selectAsset.selectIndex = selectIndexAsset.selectIndex;
                selectAsset.isSelect = selectIndexAsset.isSelect;
                selectAsset.isOrgin = selectIndexAsset.isOrgin;
                [dataMuArr addObject:selectAsset];
                count = 1;
                selectIndexAsset.selectIndex = 0;
                selectIndexAsset.isSelect = NO;
                selectIndexAsset.isOrgin = NO;
            }else if ([selectAsset isEqual:selectIndexAsset]){
                [dataMuArr addObject:selectIndexAsset];
                count = 1;
            }
        }
        if (count == 0) {
            [dataMuArr addObject:selectIndexAsset];
        }
    }
    
    self.assetArr = dataMuArr;
    
    return selectArr;
}

/**
 清空选中的Cell
 */
-(void)clearSelectCellArr
{

    [self.selectCurrentCellArr removeAllObjects];
}


//外部调用时.更新选中的cell
-(void)setSelectAssetArr:(NSArray * )assetArr
{
    for (FQAsset *asset in self.assetArr) {
            asset.isSelect = NO;
            asset.selectIndex = 0;
    }
    
    self.assetArr = [NSMutableArray arrayWithArray:assetArr];
    
    for (int i = 0; i < self.assetArr.count; ++i) {
        FQAsset * asset = self.assetArr[i];
        asset.isSelect = YES;
        asset.selectIndex = i + 1;
    }
}

+(BOOL)isUpperLimit
{
    return [[FQImagePickerContainer share]getSelectAssetArr].count >= 9;
}

+(NSData *)getImageDataWithAsset:(FQAsset *)asset{
    if (asset.isGif) {
        return asset.gifImageData;
    }else{
        if (asset.isOrgin) {
            NSData * originimageData = asset.originImageData;
            if (originimageData.length > 1.0 * 1024 * 1024) {
                CGFloat scale = 1.0 *1024*1024/originimageData.length;
                NSData * changData = UIImageJPEGRepresentation(asset.orginImg, scale);
                return changData;
            }else{
                return originimageData;
            }
        }else{
            if (asset.previewImg) {
                return UIImageJPEGRepresentation(asset.previewImg, 1.0);
            }else{
                return UIImageJPEGRepresentation(asset.thumbImg, 1.0);
            }
        }
    }
}


-(NSMutableArray *)assetArr
{
    if (!_assetArr) {
        _assetArr = [NSMutableArray array];
    }
    return _assetArr;
}

-(NSMutableArray *)selectCurrentCellArr
{
    if (!_selectCurrentCellArr) {
        _selectCurrentCellArr = [NSMutableArray array];
    }
    return _selectCurrentCellArr;
}

@end
