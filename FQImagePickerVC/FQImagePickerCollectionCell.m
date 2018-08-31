//
//  FQImagePickerCollectionCell.m
//  FQPhotoPicker
//
//  Created by 龙腾飞 on 2018/3/24.
//  Copyright © 2018年 fanqi. All rights reserved.
//

#import "FQImagePickerCollectionCell.h"
#import "FQImagePickerContainer.h"
#import "UIButton+JTFQSpacing.h"
@interface FQImagePickerCollectionCell()

@property (strong, nonatomic) UIImageView *contentImg;

@property (strong, nonatomic) UIButton *selectBtn;

@property (nonatomic, strong) UILabel *gifLabel;

@property (nonatomic, strong) CAShapeLayer *progressLayer;

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
    self.contentImg.contentMode = UIViewContentModeScaleAspectFill;
    self.contentImg.clipsToBounds = YES;
    [self addSubview:self.contentImg];
    self.backgroundColor = [UIColor whiteColor];
    self.selectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.selectBtn.style = FQ_ButtonImageTitleStyleFloatingTop;
    self.selectBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [self.selectBtn setBackgroundImage:[UIImage imageNamed:IMAGE_NAME_SOCIAL_RELEASE_PHOTOT_NORMAL_ICON] forState:UIControlStateNormal];
    [self.selectBtn setBackgroundImage:[UIImage imageNamed:IMAGE_NAME_SOCIAL_RELEASE_PHOTOT_SELECT_ICON] forState:UIControlStateSelected];
    self.selectBtn.frame = CGRectMake(self.bounds.size.width - 30, 5 , 25, 25);
    [self addSubview:self.selectBtn];
    [self.selectBtn addTarget:self action:@selector(clickSelectBtn:) forControlEvents:UIControlEventTouchUpInside];
    
    self.gifLabel = [[UILabel alloc]init];
    self.gifLabel.text = @"GIF";
    self.gifLabel.font = FONT_SIZE_11;
    self.gifLabel.backgroundColor = [UIColor orangeColor];
    self.gifLabel.textColor = [UIColor whiteColor];
    self.gifLabel.textAlignment = NSTextAlignmentCenter;
    [self.gifLabel sizeToFit];
    [self addSubview:self.gifLabel];
    [self.gifLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.offset(0);
        make.right.offset(0);
        make.width.mas_equalTo(self.gifLabel.width + 6);
        make.height.mas_equalTo(self.gifLabel.height + 2);
    }];
    
    _progressLayer = [CAShapeLayer layer];
    _progressLayer.size = CGSizeMake(40, 40);
    _progressLayer.cornerRadius = 20;
    _progressLayer.backgroundColor = [UIColor colorWithWhite:0.000 alpha:0.500].CGColor;
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectInset(_progressLayer.bounds, 7, 7) cornerRadius:(40 / 2 - 7)];
    _progressLayer.path = path.CGPath;
    _progressLayer.fillColor = [UIColor clearColor].CGColor;
    _progressLayer.strokeColor = [UIColor whiteColor].CGColor;
    _progressLayer.lineWidth = 4;
    _progressLayer.lineCap = kCALineCapRound;
    _progressLayer.strokeStart = 0;
    _progressLayer.strokeEnd = 0;
    _progressLayer.hidden = YES;
    [self.layer addSublayer:_progressLayer];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _progressLayer.center = CGPointMake(self.width / 2, self.height / 2);
}


-(void)setAsset:(FQAsset *)asset
{
    _asset = asset;
    self.selectBtn.selected = asset.isSelect;
    __weak typeof(self)weakSelf = self;
    //如果选中.添加这个
    if (asset.isSelect) {
        [[FQImagePickerContainer share] addAsset:_asset andImagePickerCell:weakSelf];
    }
    [self.selectBtn setTitle:[NSString stringWithFormat:@"%zd",asset.selectIndex] forState:UIControlStateSelected];
    
    if (asset.isGif) {
        [asset fetchGIFImgWithCompletion:^(UIImage *img, NSDictionary *dict) {
            weakSelf.progressLayer.hidden = YES;
        } progressBlock:^(double progress, NSError * _Nullable error, BOOL * _Nonnull stop, NSDictionary * _Nullable info) {
            
            if (isnan(progress)) progress = 0;
            weakSelf.progressLayer.hidden = NO;
            weakSelf.progressLayer.strokeEnd = progress;
            
        }];
        self.gifLabel.hidden = NO;
    }else{
        self.gifLabel.hidden = YES;
    }
    [asset fetchThumbImageWithSize:self.bounds.size completion:^(UIImage *thumbImg, NSDictionary *dict) {
        weakSelf.contentImg.image = thumbImg;
    }];
    
}

-(void)setIsScanCode:(BOOL)isScanCode
{
    _isScanCode = isScanCode;
    self.selectBtn.hidden = isScanCode;
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
        return;
    }
    
    sender.selected = !sender.selected;
    MJWeakSelf
    if (sender.selected) {
        [[FQImagePickerContainer share] addAsset:_asset andImagePickerCell:weakSelf];
        
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
        [[FQImagePickerContainer share] deleteAsset:_asset andImagePickerCell:weakSelf];
        [sender.layer removeAllAnimations];
    }
    
}


@end
