//
//  FQImagePreviewCell.h
//  FQPhotoPicker
//
//  Created by 龙腾飞 on 2018/3/27.
//  Copyright © 2018年 fanqi. All rights reserved.
//

#import <UIKit/UIKit.h>
@class FQAsset;

@interface FQImagePreviewCell : UICollectionViewCell

@property (nonatomic, copy) void(^singleTapGestureBlock)(void);

@property (nonatomic, strong) FQAsset *asset;

/**
 恢复scroller状态
 */
-(void)reStoreScrollerScale;

@end
