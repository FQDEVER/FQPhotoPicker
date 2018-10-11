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
#define FQIS_IPHONE_X ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125, 2436), [[UIScreen mainScreen] currentMode].size) : NO)
#define FQNAVIGATION_HEIGHT ((FQIS_IPHONE_X == YES) ? 88.0f : 64.0f)
//tabbar 高度
#define FQTABBAR_HEIGHT ((FQIS_IPHONE_X == YES) ? 83.0f : 49.0f)
#define FQTABBAR_BOTTOM_SPACING  (FQTABBAR_HEIGHT- 49.0)
// 渐变蓝按钮开始的颜色
#define FQCOLOR_BLUE_BUTTON_START [UIColor colorWithRed:0.00 green:0.45 blue:0.98 alpha:1.00]
// 渐变蓝按钮结束的颜色
#define FQCOLOR_BLUE_BUTTON_END [UIColor colorWithRed:0.13 green:0.65 blue:0.99 alpha:1.00]

// 获取RGB颜色
#define FQRGBA(r,g,b,a) [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:a]
#define FQRGB(r,g,b) FQRGBA(r,g,b,1.0f)

#define MYBUNDLE_NAME @"PhotoPicker.bundle"

#define MYBUNDLE_PATH [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent: MYBUNDLE_NAME]

#define MYBUNDLE [NSBundle bundleWithPath: MYBUNDLE_PATH]


@interface FQAsset : NSObject

//传入一个PHAsset.
@property (nonatomic, strong) PHAsset *asset;

//是否选中
@property (nonatomic, assign) BOOL isSelect;

//是否原图
@property (nonatomic, assign) BOOL isOrgin;

//是否gif图
@property (nonatomic, assign) BOOL isGif;

//是否是长图
@property (nonatomic, assign) BOOL isLong;

//是否是宽图
@property (nonatomic, assign) BOOL isWidth;

//原图
@property (nonatomic, strong ,readonly) UIImage *orginImg;

//缩略图
@property (nonatomic, strong ,readonly) UIImage *thumbImg;

//预览图
@property (nonatomic, strong ,readonly) UIImage *previewImg;

//获取gif图片数据
@property (nonatomic, strong ,readonly) UIImage *gifImage;

//获取gif图片data数据
@property (nonatomic, strong ,readonly) NSData *gifImageData;

//获取原图图片data数据
@property (nonatomic, strong ,readonly) NSData *originImageData;

//获取图片尺寸
@property (nonatomic, assign, readonly) CGFloat imgSize;

//获取当前状态下的尺寸
-(void)getOrginImgSize:(void(^)(NSString * imgSizeStr,FQAsset * asset))imgSizeBlock;

//添加一个选中的索引
@property (nonatomic, assign) NSInteger selectIndex;

//更新asset数据
-(void)setAssetWithFQAsset:(FQAsset *)asset;

//同步获取原图
-(UIImage *)getSourceImage;

//异步获取原图
-(void)fetchSourceImageWithCompletion:(void(^)(UIImage * ,NSDictionary *))completion progressBlock:(PHAssetImageProgressHandler)progressHandler;

//异步获取原图Data数据
-(void)fetchOriginImageDataWithCompletion:(void(^)(NSData * ,NSDictionary *))completion;

//异步获取原图 - 因为内存原因.使用高清预览图代替原图
-(void)fetchPreviewReplaceOriginImageWithCompletion:(void(^)(UIImage * ,NSDictionary *))completion;

//同步获取缩略图
-(UIImage *)getThumbnailImageWithSize:(CGSize)size;

//异步获取缩略图
-(void)fetchThumbImageWithSize:(CGSize)size completion:(void(^)(UIImage * ,NSDictionary *))completion;

//异步获取GIF图
-(void)fetchGIFImgWithCompletion:(void(^)(UIImage *,NSDictionary *))completion progressBlock:(PHAssetImageProgressHandler)progressHandler;

//同步获取预览图(以当前屏幕为标准获取的图片尺寸)
-(UIImage *)getPreviewImg;

//异步获取预览图(以当前屏幕为标准获取的图片尺寸)
-(void)fetchPreviewImgWithCompletion:(void(^)(UIImage *,NSDictionary *))completion progressBlock:(PHAssetImageProgressHandler)progressHandler;

@end
