//
//  FQImagePickerTitleTableCell.m
//  FQPhotoPicker
//
//  Created by 龙腾飞 on 2018/3/26.
//  Copyright © 2018年 fanqi. All rights reserved.
//

#import "FQImagePickerTitleTableCell.h"
#import <Masonry.h>
#import "FQAsset.h"
#import "FQImagePickerService.h"

@interface FQImagePickerTitleTableCell()

@property (nonatomic, strong) UIImageView *titleImgView;

@property (nonatomic, strong) UILabel *titleLab;

@property (nonatomic, strong) UILabel *countLab;

@end

@implementation FQImagePickerTitleTableCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self creatUI];
    }
    return self;
}


-(void)creatUI{
    
    [self addSubview:self.titleImgView];
    [self.titleImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.offset(5);
        make.bottom.offset(-5);
        make.width.equalTo(@(70 - 2 * 5));
    }];
    
    [self addSubview:self.titleLab];
    [self.titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.titleImgView.mas_centerY).offset(0);
        make.left.equalTo(self.titleImgView.mas_right).offset(10);
    }];
    
    [self addSubview:self.countLab];
    [self.countLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.titleImgView.mas_centerY).offset(0);
        make.left.equalTo(self.titleLab.mas_right).offset(5);
    }];
}

-(void)setDataDict:(NSDictionary *)dataDict
{
    _dataDict = dataDict;
    
    NSDictionary *imgDict = dataDict.allValues.firstObject;
    
    self.titleLab.text = imgDict[FQPHTitle];
    
    
    FQAsset * firstAsset = [imgDict[FQPHImage] firstObject];
    if ([self.titleLab.text isEqualToString:[FQImagePickerService getAllPhotosStr]]) {
        firstAsset = imgDict[FQPHImage][1];
    }
    __weak typeof(self) weakSelf = self;
    [firstAsset fetchThumbImageWithSize:CGSizeMake(70, 70) completion:^(UIImage *resultImg, NSDictionary *info) {
        weakSelf.titleImgView.image = resultImg;
    }];
    self.countLab.text = [NSString stringWithFormat:@"(%@)",imgDict[FQPHCount]];
}


-(UIImageView *)titleImgView
{
    if (!_titleImgView) {
        _titleImgView = [[UIImageView alloc]init];
        _titleImgView.contentMode = UIViewContentModeScaleAspectFill;
        _titleImgView.clipsToBounds = YES;
    }
    return _titleImgView;
}

-(UILabel *)titleLab{
    if (!_titleLab) {
        _titleLab = [[UILabel alloc]init];
        _titleLab.textColor = [UIColor blackColor];
        _titleLab.textAlignment = NSTextAlignmentLeft;
        _titleLab.font = [UIFont systemFontOfSize:15];
    }
    return _titleLab;
}

-(UILabel *)countLab
{
    if (!_countLab) {
        _countLab = [[UILabel alloc]init];
        _countLab.textColor = [UIColor blackColor];
        _countLab.textAlignment = NSTextAlignmentLeft;
        _countLab.font = [UIFont systemFontOfSize:11];
    }
    return _countLab;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
