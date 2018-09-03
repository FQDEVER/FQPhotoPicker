//
//  FQImagePickerTitleView.h
//  FQPhotoPicker
//
//  Created by 龙腾飞 on 2018/3/26.
//  Copyright © 2018年 fanqi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FQImagePickerTitleView : UIView

@property (nonatomic, strong) NSArray *dataSourceArr;

@property (nonatomic, copy) void(^handleTapGestureBlock)(void);

@property (nonatomic, copy) void(^clickTableCellBlock)(NSDictionary * dataDict);

/**
 展示tableView
 */
-(void)showTableView;

/**
 隐藏tableView
 */
-(void)hiddenTableView;



@end
