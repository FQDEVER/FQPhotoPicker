//
//  FQImagePickerService.h
//  FQPhotoPicker
//
//  Created by 龙腾飞 on 2018/3/24.
//  Copyright © 2018年 fanqi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FQImagePickerService : NSObject

@property (nonatomic, copy) void(^dataLoadCompelteBlock)(NSArray *array);

+(instancetype)share;

//获取当前分组.
-(NSArray *)dataSourceArray;


-(void)reloadData;

@end
