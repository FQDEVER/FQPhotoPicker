//
//  FQImagePreviewVc.h
//  FQPhotoPicker
//
//  Created by 龙腾飞 on 2018/3/27.
//  Copyright © 2018年 fanqi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FQImagePreviewVc : UIViewController

/**
 传入数据

 @param previewArr 所有数据数组
 @param selectIndex 当前选中的索引
 */
-(void)setImgPreviewVc:(NSArray *)previewArr selectIndex:(NSInteger )selectIndex;

@end
