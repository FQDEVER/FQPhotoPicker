//
//  FQImagePickerTitleView.m
//  FQPhotoPicker
//
//  Created by 龙腾飞 on 2018/3/26.
//  Copyright © 2018年 fanqi. All rights reserved.
//

#import "FQImagePickerTitleView.h"
#import "FQImagePickerTitleTableCell.h"
#import <Masonry.h>
#import "FQAsset.h"

@interface FQImagePickerTitleView()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *titleTableView;

@property (nonatomic, strong) UIView *coverView;

@end

@implementation FQImagePickerTitleView

-(instancetype)init
{
    if (self = [super init]) {
        [self creatUI];
    }
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self creatUI];
    }
    return self;
}

-(void)creatUI{
    
    
    
    //添加手势
    [self addSubview:self.coverView];
    
    [self.coverView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.insets(UIEdgeInsetsMake(0, 0, 0, 0));
    }];
    
    [self addSubview:self.titleTableView];
    
    [self.titleTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.offset(0);
        make.bottom.equalTo(self.mas_top).offset(0);
        make.height.equalTo(@(ScreenH * 0.7));
        make.right.offset(0);
    }];
    
    self.hidden = YES;
}


-(void)handleTapGestureTableView{
    
    if (_handleTapGestureBlock) {
        _handleTapGestureBlock();
    }
    [self hiddenTableView];
}


/**
 展示tableView
 */
-(void)showTableView
{
    self.hidden = NO;
    [UIView animateWithDuration:0.33 animations:^{
        self.titleTableView.transform = CGAffineTransformMakeTranslation(0, ScreenH * 0.7 + FQNAVIGATION_HEIGHT);
        self.coverView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    } completion:^(BOOL finished) {
    }];
}

/**
 隐藏tableView
 */
-(void)hiddenTableView
{
    //收回talbeView并且销毁
    [UIView animateWithDuration:0.33 animations:^{
        self.titleTableView.transform = CGAffineTransformIdentity;
        self.coverView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.0];
    } completion:^(BOOL finished) {
        self.hidden = YES;
    }];
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSourceArr.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FQImagePickerTitleTableCell * cell = [tableView dequeueReusableCellWithIdentifier:@"FQImagePickerTitleTableCellID" forIndexPath:indexPath];
    
    cell.dataDict = self.dataSourceArr[indexPath.row];
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70.0f;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (_clickTableCellBlock) {
        NSDictionary *dict = self.dataSourceArr[indexPath.row];
        _clickTableCellBlock(dict.allValues.firstObject);
        
        if (_handleTapGestureBlock) {
            _handleTapGestureBlock();
        }
        [self hiddenTableView];
    }
}


-(UITableView *)titleTableView
{
    if (!_titleTableView) {
        _titleTableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
        [_titleTableView registerClass:[FQImagePickerTitleTableCell class] forCellReuseIdentifier:@"FQImagePickerTitleTableCellID"];
        _titleTableView.delegate = self;
        _titleTableView.dataSource = self;
        _titleTableView.backgroundColor = [UIColor whiteColor];
        _titleTableView.tableFooterView = [UIView new];
        _titleTableView.sectionFooterHeight = CGFLOAT_MIN;
        
    }
    return _titleTableView;
}

-(UIView *)coverView
{
    if (!_coverView) {
        _coverView = [[UIView alloc]init];
        _coverView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.0];
        //添加手势
        UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleTapGestureTableView)];
        [_coverView addGestureRecognizer:tapGesture];
    }
    return _coverView;
}

@end
