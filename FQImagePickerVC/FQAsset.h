//
//  FQAsset.h
//  FQPhotoPicker
//
//  Created by 龙腾飞 on 2018/3/24.
//  Copyright © 2018年 fanqi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>
#define FQPHImage  @"PHImage"
#define FQPHTitle  @"PHTitle"
#define FQPHCount  @"PHCount"
#define ScreenH     [UIScreen mainScreen].bounds.size.height
#define ScreenW     [UIScreen mainScreen].bounds.size.width

@interface FQAsset : NSObject

//传入一个PHAsset.
@property (nonatomic, strong) PHAsset *asset;

//是否选中
@property (nonatomic, assign) BOOL isSelect;

//是否原图
@property (nonatomic, assign) BOOL isOrgin;

//原图
@property (nonatomic, strong ,readonly) UIImage *orginImg;

//预览图
@property (nonatomic, strong ,readonly) UIImage *previewImg;

//获取图片尺寸
@property (nonatomic, assign, readonly) CGFloat imgSize;

//获取当前状态下的尺寸
-(void)getOrginImgSize:(void(^)(NSString * imgSizeStr,FQAsset * asset))imgSizeBlock;

//添加一个选中的索引
@property (nonatomic, assign) NSInteger selectIndex;

//同步获取原图
-(UIImage *)getSourceImage;

//异步获取原图
-(void)fetchSourceImageWithCompletion:(void(^)(UIImage * ,NSDictionary *))completion progressBlock:(PHAssetImageProgressHandler)progressHandler;

//同步获取缩略图
-(UIImage *)getThumbnailImageWithSize:(CGSize)size;

//异步获取缩略图
-(void)fetchThumbImageWithSize:(CGSize)size completion:(void(^)(UIImage * ,NSDictionary *))completion;

//同步获取预览图(以当前屏幕为标准获取的图片尺寸)
-(UIImage *)getPreviewImg;

//异步获取预览图(以当前屏幕为标准获取的图片尺寸)
-(void)fetchPreviewImgWithCompletion:(void(^)(UIImage *,NSDictionary *))completion;


@end
