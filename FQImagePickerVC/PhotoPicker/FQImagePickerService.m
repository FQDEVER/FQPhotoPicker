//
//  FQImagePickerService.m
//  FQPhotoPicker
//
//  Created by 龙腾飞 on 2018/3/24.
//  Copyright © 2018年 fanqi. All rights reserved.
//

#import "FQImagePickerService.h"
#import <Photos/Photos.h>
#import "FQAsset.h"

@interface FQImagePickerService()
@property (nonatomic, strong) NSMutableArray *allAlbumArr; //保存格式
//@{@"相册名称":@{FQPHImage:相册所有FQAsset数组,FQPHTitle:相册名称,FQPHCount:图片数量}}

@property (nonatomic, strong) NSMutableArray *titleStrArr;

@property (nonatomic, copy) NSString *allPhotosStr;
@end
@implementation FQImagePickerService

static FQImagePickerService *imgPickerService;

+(instancetype)allocWithZone:(struct _NSZone *)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        imgPickerService = [super allocWithZone:zone];
    });
    return imgPickerService;
}

+(instancetype)share
{
    return [[FQImagePickerService alloc]init];
}

-(id)copyWithZone:(NSZone *)zone
{
    return imgPickerService;
}

-(id)mutableCopyWithZone:(NSZone *)zone
{
    return imgPickerService;
}


-(NSArray *)dataSourceArray
{
    return _allAlbumArr;
}

//更新数据
-(void)reloadData
{
    [self getThumnailImages];
}

//清空数据-释放内存
-(void)clearDataArr{
    [self.titleStrArr removeAllObjects];
    [self.allAlbumArr removeAllObjects];
}

-(void)getThumnailImages
{
    [self clearDataArr];
    
    PHFetchResult<PHAssetCollection *> * assetCollections = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:nil];
    for (PHAssetCollection * assetCollection in assetCollections) {
        //获取某个相册的所有内容
        PHFetchResult <PHAsset*> *assets = [PHAsset fetchAssetsInAssetCollection:assetCollection options:nil];
        
        if (assets.count > 0) {
            //相册标题
            self.allPhotosStr = assetCollection.localizedTitle;
        }
        
        [self enumerateAssetsInAssetCollection:assetCollection];
    }
    
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        // 处理耗时操作的代码块...
        for (int i = 2; i < 7; ++i) {
            //获取自定义
            PHFetchResult<PHAssetCollection *> * assetCollections = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:i options:nil];
            
            for (PHAssetCollection * assetCollection in assetCollections) {
                [self enumerateAssetsInAssetCollection:assetCollection];
            }
        }
        
        for (int i = 100; i < 102; ++i) {
            //获取自定义
            PHFetchResult<PHAssetCollection *> * assetCollections = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:i options:nil];
            
            for (PHAssetCollection * assetCollection in assetCollections) {
                [self enumerateAssetsInAssetCollection:assetCollection];
            }
        }
        
        for (int i = 200; i < 209; ++i) {
            //获取自定义
            PHFetchResult<PHAssetCollection *> * assetCollections = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:i options:nil];
            
            for (PHAssetCollection * assetCollection in assetCollections) {
                [self enumerateAssetsInAssetCollection:assetCollection];
            }
        }
        
        for (int i = 210; i < 216; ++i) {
            //获取自定义
            PHFetchResult<PHAssetCollection *> * assetCollections = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:i options:nil];
            
            for (PHAssetCollection * assetCollection in assetCollections) {
                [self enumerateAssetsInAssetCollection:assetCollection];
            }
        }
        
        //通知主线程刷新
        dispatch_async(dispatch_get_main_queue(), ^{
            //回调或者说是通知主线程刷新，
            if (_dataLoadCompelteBlock) {
                _dataLoadCompelteBlock(self.dataSourceArray);
            }
        });
        
    });
}

/**
 获取当前所有照片的文本
 
 @return 当前语言环境下所有照片相应的描述
 */
+(NSString *)getAllPhotosStr
{
    NSString * allPhotosStr = [FQImagePickerService share].allPhotosStr;
    
    if (allPhotosStr.length && allPhotosStr) {
        return allPhotosStr;
    }else{
        return @"";
    }
}

//遍历相册中的所有图片
-(void)enumerateAssetsInAssetCollection:(PHAssetCollection *)assetCollection
{
    //获取某个相册的所有内容
    PHFetchResult <PHAsset*> *assets = [PHAsset fetchAssetsInAssetCollection:assetCollection options:nil];
    
    if (assets.count > 0) {
        //相册标题
        NSString * titleStr = assetCollection.localizedTitle;
        
        if (!titleStr) {
            return;
        }
        
        //当前相册的个数
        NSInteger count = assets.count;
        
        //所有图片FQAsset对象
        __block NSMutableArray * fq_assets = [NSMutableArray array];
        //遍历所有对应assets的数组
        for (PHAsset * asset in assets) {
            
            FQAsset * fq_asset = [[FQAsset alloc]init];
            fq_asset.asset = asset;
            [fq_assets addObject:fq_asset];
        }
        
        fq_assets = (NSMutableArray *)[[fq_assets reverseObjectEnumerator]allObjects];
        
        if ([titleStr isEqualToString:self.allPhotosStr]) {
            [fq_assets insertObject:[FQAsset new] atIndex:0];
        }
        
        if (![self.titleStrArr containsObject:titleStr]) {
            [self.titleStrArr addObject:titleStr];
            [self.allAlbumArr addObject:@{titleStr : @{FQPHImage:fq_assets.copy,FQPHTitle:titleStr,FQPHCount:@(count)}}];
        }
    }
    
}

-(NSMutableArray *)allAlbumArr
{
    if (!_allAlbumArr) {
        _allAlbumArr = [NSMutableArray array];
    }
    return _allAlbumArr;
}

-(NSMutableArray *)titleStrArr
{
    if (!_titleStrArr) {
        _titleStrArr = [NSMutableArray  array];
    }
    return _titleStrArr;
}

@end
