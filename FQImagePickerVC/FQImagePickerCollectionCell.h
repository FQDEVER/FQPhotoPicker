//
//  FQImagePickerCollectionCell.h
//  FQPhotoPicker
//
//  Created by 龙腾飞 on 2018/3/24.
//  Copyright © 2018年 fanqi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FQAsset.h"

@interface FQImagePickerCollectionCell : UICollectionViewCell

@property (nonatomic, copy) void(^isblock)(void);

@property (nonatomic, strong) FQAsset *asset;

@property (nonatomic, assign) NSInteger selectIndex;

//根据传入的Asset对象.更新指定的编号
-(void)upload;

@end
