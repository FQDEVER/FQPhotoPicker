//
//  FQAsset.m
//  FQPhotoPicker
//
//  Created by 龙腾飞 on 2018/3/24.
//  Copyright © 2018年 fanqi. All rights reserved.
//

#import "FQAsset.h"

#define screenScale [UIScreen mainScreen].scale

@interface FQAsset()

@property (nonatomic, strong) UIImage *orginImg;

@property (nonatomic, strong) UIImage *thumbImg;

@property (nonatomic, strong) UIImage *previewImg;

@property (nonatomic, assign) CGFloat imgSize;

@property (nonatomic, copy) void(^getImgSizeBlock)(NSString * imgSizeStr,FQAsset * asset);

@end

@implementation FQAsset

//同步获取原图
-(UIImage *)getSourceImage
{
    if (_orginImg) {
       return _orginImg;
    }
    __block UIImage * orginImg;
    PHImageRequestOptions * requestOptions = [[PHImageRequestOptions alloc]init];
    requestOptions.synchronous = YES;
    requestOptions.resizeMode = PHImageRequestOptionsResizeModeFast;
    requestOptions.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    requestOptions.networkAccessAllowed = YES;//icloud图片
    [[PHImageManager defaultManager] requestImageForAsset:self.asset targetSize:PHImageManagerMaximumSize contentMode:PHImageContentModeDefault options:requestOptions resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        orginImg = result;
    }];
    _orginImg = orginImg;
    return orginImg;
}

//异步获取原图
-(void)fetchSourceImageWithCompletion:(void(^)(UIImage * ,NSDictionary *))completion progressBlock:(PHAssetImageProgressHandler)progressHandler
{
    if (_orginImg) {
        if (completion) {
            completion(_orginImg,nil);
        }
        return;
    }
    
    PHImageRequestOptions * requestOptions = [[PHImageRequestOptions alloc]init];
    requestOptions.resizeMode = PHImageRequestOptionsResizeModeFast;
    requestOptions.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    requestOptions.networkAccessAllowed = YES;//icloud图片
    requestOptions.progressHandler = progressHandler;
    [[PHImageManager defaultManager] requestImageForAsset:self.asset targetSize:PHImageManagerMaximumSize contentMode:PHImageContentModeDefault options:requestOptions resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        
        if (result) {//如果下载成功
            _orginImg = result;
        }
        
        if (completion) {
            completion(result,info);
        }
        
    }];
}


//同步获取缩略图
-(UIImage *)getThumbnailImageWithSize:(CGSize)size
{
    if (_thumbImg) {
        return _thumbImg;
    }
    
    __block UIImage * thumbImg;
    PHImageRequestOptions * requestOptions = [[PHImageRequestOptions alloc]init];
    requestOptions.synchronous = YES;
    requestOptions.resizeMode = PHImageRequestOptionsResizeModeExact;
    [[PHImageManager defaultManager] requestImageForAsset:self.asset targetSize:CGSizeMake(size.width * screenScale, size.height * screenScale) contentMode:PHImageContentModeAspectFill options:requestOptions resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        thumbImg = result;
    }];
    _thumbImg = thumbImg;
    return thumbImg;
}


//异步获取缩略图
-(void)fetchThumbImageWithSize:(CGSize)size completion:(void(^)(UIImage * ,NSDictionary *))completion
{
    if (_thumbImg) {
        if (completion) {
            completion(_thumbImg,nil);
        }
        return;
    }
    
    PHImageRequestOptions * requestOptions = [[PHImageRequestOptions alloc]init];
    requestOptions.resizeMode = PHImageRequestOptionsResizeModeExact;
    [[PHImageManager defaultManager] requestImageForAsset:self.asset targetSize:CGSizeMake(size.width * screenScale, size.height * screenScale) contentMode:PHImageContentModeAspectFill options:requestOptions resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        
        //首先获取
        if (result) {//如果下载成功
            _thumbImg = result;
        }
        
        if (completion) {
            completion(result,info);
        }
        
    }];
}

//同步获取预览图
-(UIImage *)getPreviewImg
{
    if (_previewImg) {
        return _previewImg;
    }
    
    __block UIImage * previewImg;
    PHImageRequestOptions * requestOptions = [[PHImageRequestOptions alloc]init];
    requestOptions.synchronous = YES;
    requestOptions.version = PHImageRequestOptionsVersionCurrent;
    [[PHImageManager defaultManager]requestImageForAsset:self.asset targetSize:CGSizeMake(ScreenW* screenScale, ScreenH* screenScale) contentMode:PHImageContentModeAspectFit options:requestOptions resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        previewImg = result;
    }];
    _previewImg = previewImg;
    return _previewImg;
}



//异步获取预览图
-(void)fetchPreviewImgWithCompletion:(void(^)(UIImage *,NSDictionary *))completion
{
    if (_previewImg) {
        if (completion) {
            completion(_previewImg,nil);
        }
        return;
    }
    
    PHImageRequestOptions * requestOptions = [[PHImageRequestOptions alloc]init];
    requestOptions.version = PHImageRequestOptionsVersionCurrent;
    requestOptions.resizeMode = PHImageRequestOptionsResizeModeExact;//获取指定的图片.就需要设定resizeMode参数
    [[PHImageManager defaultManager]requestImageForAsset:self.asset targetSize:CGSizeMake(ScreenW * screenScale, ScreenH * screenScale) contentMode:PHImageContentModeAspectFit options:requestOptions resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        if (result) {
            _previewImg = result;
        }
        if (completion) {
            completion(result,info);
        }
    }];
}

- (CGFloat)imgSize
{
    if (_imgSize == 0) {
        [self getImageInfo];
    }
    return _imgSize;
}

-(void)setIsOrgin:(BOOL)isOrgin
{
    _isOrgin = isOrgin;
    
    if (_isSelect && _isOrgin) { //如果又是原图.又是选中状态.就获取原图
        [self fetchSourceImageWithCompletion:nil progressBlock:nil];
    }
}

-(void)setIsSelect:(BOOL)isSelect
{
    _isSelect = isSelect;
    if (_isSelect && _isOrgin) { //如果又是原图.又是选中状态.就获取原图
        [self fetchSourceImageWithCompletion:nil progressBlock:nil];
    }else if (_isSelect && !_isOrgin){
        [self fetchPreviewImgWithCompletion:nil];
    }
}


-(void)getImageInfo
{
    // Fallback on earlier versions
    PHImageRequestOptions * requestOptions = [[PHImageRequestOptions alloc]init];
    requestOptions.networkAccessAllowed = YES;//icloud图片
    [[PHImageManager defaultManager] requestImageDataForAsset:_asset options:requestOptions resultHandler:^(NSData *imageData, NSString *dataUTI, UIImageOrientation orientation, NSDictionary *info) {
        float imageSize = imageData.length; //convert to MB
        imageSize = imageSize/(1024*1024.0);
        _imgSize = imageSize;
        if (_getImgSizeBlock) {
            _getImgSizeBlock([NSString stringWithFormat:@"%.02fM",_imgSize],self);
        }
    }];
    
}

-(void)getOrginImgSize:(void(^)(NSString * imgSizeStr,FQAsset * asset))imgSizeBlock
{
    if (self.imgSize == 0) {
        _getImgSizeBlock = imgSizeBlock;
    }else{
        if (imgSizeBlock) {
            imgSizeBlock([NSString stringWithFormat:@"%.02fM",self.imgSize],self);
        }
    }
}


@end
