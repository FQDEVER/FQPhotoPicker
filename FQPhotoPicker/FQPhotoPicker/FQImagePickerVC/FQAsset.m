//
//  FQAsset.m
//  FQPhotoPicker
//
//  Created by 龙腾飞 on 2018/3/24.
//  Copyright © 2018年 fanqi. All rights reserved.
//

#import "FQAsset.h"
#import <YYKit/YYKit.h>
#define screenScale [UIScreen mainScreen].scale

@interface FQAsset()

@property (nonatomic, strong) UIImage *orginImg;

@property (nonatomic, strong) UIImage *thumbImg;

@property (nonatomic, strong) UIImage *previewImg;

@property (nonatomic, strong) UIImage *gifImage;

@property (nonatomic, strong) NSData *gifImageData;

@property (nonatomic, strong) NSData *originImageData;

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
    if (progressHandler) {
        requestOptions.progressHandler = progressHandler;
    }
    
    [[PHImageManager defaultManager] requestImageForAsset:self.asset targetSize:PHImageManagerMaximumSize contentMode:PHImageContentModeDefault options:requestOptions resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        
        BOOL downloadFinined = (![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey]);
        if (downloadFinined && result) {
            BOOL isDegraded = [[info objectForKey:PHImageResultIsDegradedKey] boolValue];
            if (!isDegraded) {
                if (result) {//如果下载成功
                    _orginImg = result;
                }
                
                if (completion) {
                    completion(result,info);
                }
            }
        }
    }];
}

//异步获取原图 - 因为内存原因.使用高清预览图代替原图
-(void)fetchPreviewReplaceOriginImageWithCompletion:(void(^)(UIImage * ,NSDictionary *))completion
{
    if (_orginImg) {
        if (completion) {
            completion(_orginImg,nil);
        }
        return;
    }
    
    PHImageRequestOptions * requestOptions = [[PHImageRequestOptions alloc]init];
    requestOptions.resizeMode = PHImageRequestOptionsResizeModeFast;//获取指定的图片.就需要设定resizeMode参数
    requestOptions.networkAccessAllowed = YES;//icloud图片
    requestOptions.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    
    CGSize targetSize = CGSizeMake(ScreenW * 3, ScreenH * 3);
    
    if (self.asset.pixelHeight / self.asset.pixelWidth > 3.0) {
        
        if (self.asset.pixelWidth > ScreenW * 2) {
            
            targetSize = CGSizeMake(ScreenW * 2.0, self.asset.pixelHeight * ScreenW * 2.0/ self.asset.pixelWidth);
        }else{
            
            targetSize = CGSizeMake(self.asset.pixelWidth, self.asset.pixelHeight);
        }
    }else if(self.asset.pixelWidth / self.asset.pixelHeight > 3.0){
        
        if (self.asset.pixelHeight > ScreenH) {
            
            targetSize = CGSizeMake(self.asset.pixelWidth * ScreenH/ self.asset.pixelHeight,ScreenH);
            
        }else{
            
            targetSize = CGSizeMake(self.asset.pixelHeight,self.asset.pixelWidth);
        }
    }
    
    [[PHImageManager defaultManager]requestImageForAsset:self.asset targetSize:targetSize contentMode:PHImageContentModeAspectFit options:requestOptions resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        BOOL downloadFinined = (![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey]);
        if (downloadFinined && result) {
            BOOL isDegraded = [[info objectForKey:PHImageResultIsDegradedKey] boolValue];
            if (!isDegraded) {
                if (result) {
                    _orginImg = result;
                }
                if (completion) {
                    completion(result,info);
                }
            }else{
            }
        }else{
        }
    }];
    
}



//异步获取原图Data数据
-(void)fetchOriginImageDataWithCompletion:(void(^)(NSData * ,NSDictionary *))completion
{
    if (_originImageData) {
        if (completion) {
            completion(_originImageData,nil);
        }
        return;
    }
    
    PHImageRequestOptions * requestOptions = [[PHImageRequestOptions alloc]init];
    requestOptions.resizeMode = PHImageRequestOptionsResizeModeFast;
    requestOptions.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    requestOptions.networkAccessAllowed = YES;//icloud图片
    
    [[PHImageManager defaultManager] requestImageDataForAsset:self.asset options:requestOptions resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
        BOOL downloadFinined = (![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey]);
        if (downloadFinined && imageData) {
            float imageSize = imageData.length; //convert to MB
            _imgSize = imageSize/(1024*1024.0);
            
            BOOL isDegraded = [[info objectForKey:PHImageResultIsDegradedKey] boolValue];
            if (!isDegraded) {
                if (imageData) {
                    _originImageData = imageData;
                    if (completion) {
                        completion(_originImageData,info);
                    }
                }
            }
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
    [[PHImageManager defaultManager] requestImageForAsset:self.asset targetSize:CGSizeMake(size.width * screenScale, size.height * screenScale) contentMode:PHImageContentModeDefault options:requestOptions resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
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
    CGSize thumbImg = CGSizeMake(size.width * screenScale, size.height * screenScale);
    
    //获取是否是长图还是宽图
    if (_asset.pixelHeight / _asset.pixelWidth > 3.0) {
        self.isLong = YES;
        thumbImg.height = thumbImg.width *_asset.pixelHeight / _asset.pixelWidth;
    }else if(_asset.pixelWidth / _asset.pixelHeight > 3.0){
        self.isWidth = YES;
        thumbImg.width = thumbImg.height *_asset.pixelWidth / _asset.pixelHeight;
    }else if([[_asset valueForKey:@"filename"] containsString:@".GIF"]){
        self.isGif = YES;
    }
    
    [[PHImageManager defaultManager] requestImageForAsset:self.asset targetSize:thumbImg contentMode:PHImageContentModeDefault options:requestOptions resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        
        BOOL downloadFinined = (![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey]);
        if (downloadFinined) {
            BOOL isDegraded = [[info objectForKey:PHImageResultIsDegradedKey] boolValue];
            if (!isDegraded) {
                //首先获取
                if (result) {//如果下载成功
                    _thumbImg = result;
                }
                
                if (completion) {
                    completion(result,info);
                }
            }else{
                
                if (completion) {
                    completion(result,info);
                }
            }
        }else{
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
    [[PHImageManager defaultManager]requestImageForAsset:self.asset targetSize:CGSizeMake(ScreenW * 2, ScreenH * 2) contentMode:PHImageContentModeAspectFit options:requestOptions resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        previewImg = result;
    }];
    _previewImg = previewImg;
    return _previewImg;
}


//异步获取预览图
-(void)fetchPreviewImgWithCompletion:(void(^)(UIImage *,NSDictionary *))completion progressBlock:(PHAssetImageProgressHandler)progressHandler
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
    requestOptions.networkAccessAllowed = YES;//icloud图片
    requestOptions.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    if (progressHandler) {
        requestOptions.progressHandler = progressHandler;
    }
    
    CGSize targetSize = CGSizeMake(ScreenW * 1.5, ScreenH * 1.5);
    
    if (self.asset.pixelHeight / self.asset.pixelWidth > 3.0) {
        
        if (self.asset.pixelWidth > ScreenW) {
            
            targetSize = CGSizeMake(ScreenW, self.asset.pixelHeight * ScreenW/ self.asset.pixelWidth);
        }else{
            targetSize = CGSizeMake(self.asset.pixelWidth, self.asset.pixelHeight);
        }
    }else if(self.asset.pixelWidth / self.asset.pixelHeight > 3.0){
        if (self.asset.pixelHeight > ScreenH * 0.5) {
            
            targetSize = CGSizeMake(self.asset.pixelWidth * ScreenH * 0.5/ self.asset.pixelHeight,ScreenH * 0.5);
        }else{
            targetSize = CGSizeMake(self.asset.pixelHeight,self.asset.pixelWidth);
        }
    }
    
    [[PHImageManager defaultManager]requestImageForAsset:self.asset targetSize:targetSize contentMode:PHImageContentModeAspectFit options:requestOptions resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        BOOL downloadFinined = (![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey]);
        if (downloadFinined && result) {
            BOOL isDegraded = [[info objectForKey:PHImageResultIsDegradedKey] boolValue];
            if (!isDegraded) {
                if (result) {
                    _previewImg = result;
                }
                if (completion) {
                    completion(result,info);
                }
            }else{
            }
        }else{
        }
    }];
}

//异步获取GIF图
-(void)fetchGIFImgWithCompletion:(void(^)(UIImage *,NSDictionary *))completion progressBlock:(PHAssetImageProgressHandler)progressHandler
{
    if (_gifImage) {
        if (completion) {
            completion(_gifImage,nil);
        }
        return;
    }
    
    PHImageRequestOptions * requestOptions = [[PHImageRequestOptions alloc]init];
    requestOptions.version = PHImageRequestOptionsVersionOriginal;
    requestOptions.resizeMode = PHImageRequestOptionsResizeModeExact;//获取指定的图片.就需要设定resizeMode参数
    requestOptions.networkAccessAllowed = YES;//icloud图片
    /*
     针对icloud加载到本地的进度
     // 下载iCloud 图片的进度回调 只要图片是在icloud中 然后去请求图片就会走这个回调 如果图片没有在iCloud中不回走这个回调
     //里面的会调中的参数重 NSDictionary *info 是否有cloudKey 来判断是否是  iCloud 处理UI放到主线程
     */
    if (progressHandler) {
        requestOptions.progressHandler = progressHandler;
    }

    [[PHImageManager defaultManager] requestImageDataForAsset:self.asset options:requestOptions resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
        BOOL downloadFinined = (![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey]);
        if (downloadFinined && imageData) {
            BOOL isDegraded = [[info objectForKey:PHImageResultIsDegradedKey] boolValue];
            if (!isDegraded) {
                if (imageData) {
                    _gifImageData = imageData;
                    _gifImage = [YYImage imageWithData:_gifImageData];
                    if (completion) {
                        completion(_gifImage,info);
                    }
                }
            }
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

-(BOOL)isGif
{
    if ([[self.asset valueForKey:@"filename"] containsString:@".GIF"]) {
        return YES;
    }else{
        return NO;
    }
}

-(void)setIsOrgin:(BOOL)isOrgin
{
    _isOrgin = isOrgin;
    
    if (_isSelect && _isOrgin) { //如果又是原图.又是选中状态.就获取原图.获取原图数据
        [self fetchPreviewReplaceOriginImageWithCompletion:nil];
    }
}

-(void)setIsSelect:(BOOL)isSelect
{
    _isSelect = isSelect;
    if (_isSelect && _isOrgin) { //如果又是原图.又是选中状态.就获取原图.获取原图数据
        [self fetchPreviewReplaceOriginImageWithCompletion:nil];
    }else if (_isSelect && !_isOrgin){
        if (!self.isGif) {
            [self fetchPreviewImgWithCompletion:nil progressBlock:nil];
        }else{
            [self fetchGIFImgWithCompletion:nil progressBlock:nil];
        }
    }
}

-(void)setAssetWithFQAsset:(FQAsset *)asset
{
    self.selectIndex = asset.selectIndex;
    self.isSelect = asset.isSelect;
    self.isOrgin = asset.isOrgin;
    self.isGif = asset.isGif;
    self.isLong = asset.isLong;
    self.isWidth = asset.isWidth;
    self.orginImg = asset.orginImg;
    self.thumbImg = asset.thumbImg;
    self.previewImg = asset.previewImg;
    self.gifImage = asset.gifImage;
    self.gifImageData = asset.gifImageData;
    self.originImageData = asset.originImageData;
    self.imgSize = asset.imgSize;
}

-(void)getImageInfo
{
    
    [self fetchOriginImageDataWithCompletion:^(NSData *data, NSDictionary *dict) {
        if (_getImgSizeBlock) {
            _getImgSizeBlock([NSString stringWithFormat:@"%.02fM",_imgSize],self);
        };
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

-(void)dealloc
{
    //    FQLog(@"------------>释放了%s",__func__);
}

@end
