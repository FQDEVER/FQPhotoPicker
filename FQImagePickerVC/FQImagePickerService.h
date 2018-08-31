//
//  FQImagePickerService.h
//  FQPhotoPicker
//
//  Created by 龙腾飞 on 2018/3/24.
//  Copyright © 2018年 fanqi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FQImagePickerService : NSObject

/**
 数据加载完成回调
 */
@property (nonatomic, copy) void(^dataLoadCompelteBlock)(NSArray *array);

+(instancetype)share;

/**
 获取当前分组.
 
 @return 获取当前组
 */
-(NSArray *)dataSourceArray;

/**
 重新加载数据
 */
-(void)reloadData;

/**
 清空数据-释放内存
 */
-(void)clearDataArr;

/**
 获取当前所有照片的文本

 @return 当前语言环境下所有照片相应的描述
 */
+(NSString *)getAllPhotosStr;

@end
