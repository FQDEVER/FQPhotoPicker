//
//  FQImagePickerCollectionCell.m
//  FQPhotoPicker
//
//  Created by 龙腾飞 on 2018/3/24.
//  Copyright © 2018年 fanqi. All rights reserved.
//

#import "FQImagePickerCollectionCell.h"
#import "FQImagePickerContainer.h"

@interface FQImagePickerCollectionCell()

@property (strong, nonatomic) UIImageView *contentImg;

@property (strong, nonatomic) UIButton *selectBtn;

@end

@implementation FQImagePickerCollectionCell

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self creatUI];
    }
    return self;
}


-(void)creatUI{
    self.contentImg = [[UIImageView alloc]init];
    self.contentImg.frame = self.bounds;
    [self addSubview:self.contentImg];
    self.backgroundColor = [UIColor whiteColor];
    self.selectBtn = [[UIButton alloc]init];
    self.selectBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [self.selectBtn setBackgroundImage:[UIImage imageNamed:@"btn-shareDetail-normal"] forState:UIControlStateNormal];
    [self.selectBtn setBackgroundImage:[UIImage imageNamed:@"btn-shareDetail-select"] forState:UIControlStateSelected];
    self.selectBtn.frame = CGRectMake(self.bounds.size.width - 25, 5 , 20, 20);
    [self addSubview:self.selectBtn];
    [self.selectBtn addTarget:self action:@selector(clickSelectBtn:) forControlEvents:UIControlEventTouchUpInside];
}


-(void)setAsset:(FQAsset *)asset 
{
    _asset = asset;
    self.selectBtn.selected = asset.isSelect;
    //如果选中.添加这个
    if (asset.isSelect) {
        [[FQImagePickerContainer share] addAsset:_asset andImagePickerCell:self];
    }
    [self.selectBtn setTitle:[NSString stringWithFormat:@"%zd",asset.selectIndex] forState:UIControlStateSelected];
    __weak typeof(self)weakSelf = self;
    [asset fetchThumbImageWithSize:self.bounds.size completion:^(UIImage *thumbImg, NSDictionary *dict) {
        weakSelf.contentImg.image = thumbImg;
    }];
}

//根据传入的Asset对象.更新指定的编号
-(void)upload
{
    [self.selectBtn setTitle:[NSString stringWithFormat:@"%zd",self.asset.selectIndex] forState:UIControlStateSelected];
}



- (void)clickSelectBtn:(UIButton *)sender {
    
    //首先判断是否达到了9张
    if (sender.selected == NO && [FQImagePickerContainer isUpperLimit]) {
        if (_isblock) {
            _isblock();
        }
        NSLog(@"=======>已经达到上限");
        return;
    }
    
    sender.selected = !sender.selected;

    if (sender.selected) {
        [[FQImagePickerContainer share] addAsset:_asset andImagePickerCell:self];
        
        [self.selectBtn setTitle:[NSString stringWithFormat:@"%zd",_asset.selectIndex] forState:UIControlStateSelected];
        
        //添加一个先放大.再还原的动画
        CABasicAnimation * basicAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
        
        basicAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        
        basicAnimation.duration = 0.2;
        
        basicAnimation.repeatCount = 1.0;
        
        basicAnimation.autoreverses = YES;
        
        basicAnimation.fromValue = @1.0;
        
        basicAnimation.toValue = @1.3;
        
        [sender.layer addAnimation:basicAnimation forKey:nil];
    }else{
        [[FQImagePickerContainer share] deleteAsset:_asset andImagePickerCell:self];
        [sender.layer removeAllAnimations];
    }
    
}


@end
