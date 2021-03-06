//
//  FQImagePreviewVc.m
//  FQPhotoPicker
//
//  Created by 龙腾飞 on 2018/3/27.
//  Copyright © 2018年 fanqi. All rights reserved.
//

#import "FQImagePreviewVc.h"
#import "FQAsset.h"
#import <Masonry/Masonry.h>
#import <YYKit/YYKit.h>
#import "FQImagePreviewCell.h"
#import "FQImagePickerContainer.h"

@interface FQImagePreviewVc ()<UICollectionViewDataSource,UICollectionViewDelegate>
{
    BOOL _statusBarShouldBeHidden;
    BOOL _previousStatusBarStyle;
}

/**
 图片预览collectionView
 */
@property (nonatomic, strong) UICollectionView *collectionView;

/**
 资源文件数组
 */
@property (nonatomic, strong) NSArray *assetDataArr;

/**
 选中索引
 */
@property (nonatomic, assign) NSInteger selectIndex;

/**
 选择按钮
 */
@property (nonatomic, strong) UIButton *selectBtn;

/**
 底部视图
 */
@property (nonatomic, strong) UIView *bottomView;

/**
 顶部视图
 */
@property (nonatomic, strong) UIView *topView;

/**
 原图按钮
 */
@property (nonatomic, strong) UIButton *orginImgBtn;

/**
 完成按钮
 */
@property (nonatomic, strong) UIButton *finishBtn;

/**
 加载图片大小的进度提示
 */
@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;

/**
 临时参考资源文件数组
 */
@property (nonatomic, strong) NSMutableArray *tempAssetArr;

/**
 是否显示toolBar
 */
@property (nonatomic, assign) BOOL isShowToolBar;

/**
 顶部视图的 d/d 文本
 */
@property (nonatomic, strong) UILabel *topTitleLabel;

@end



@implementation FQImagePreviewVc

- (BOOL)prefersStatusBarHidden {
    return _statusBarShouldBeHidden;
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    return UIStatusBarAnimationSlide;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.hidesBackButton = YES;
    self.isShowToolBar = YES;
    
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    
    self.extendedLayoutIncludesOpaqueBars=YES;
    if (@available(iOS 11.0, *)) {
        
        self.collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        
    }else{
        
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    [self creatUI];
}

- (void)viewWillAppear:(BOOL)animated {
    
    // Super
    [super viewWillAppear:animated];
    
    // Set style
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        _previousStatusBarStyle = [[UIApplication sharedApplication] statusBarStyle];
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:animated];
    }
    self.navigationController.navigationBar.hidden = YES;
    
}

-(void)viewWillDisappear:(BOOL)animated
{
    // Status bar
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [[UIApplication sharedApplication] setStatusBarStyle:_previousStatusBarStyle animated:animated];
    }
    [super viewWillDisappear:animated];
    
    self.navigationController.navigationBar.hidden = NO;
}

-(void)creatUI{
    [self.view addSubview:self.collectionView];
    
    //添加一个原图显示的view
    [self.view addSubview:self.bottomView];
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.left.right.offset(0);
        make.height.equalTo(@(44 + FQTABBAR_BOTTOM_SPACING));
    }];
    
    [self.view addSubview:self.topView];
    [self.topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.offset(0);
        make.height.equalTo(@(FQNAVIGATION_HEIGHT));
    }];
    
    [self.collectionView setContentOffset:CGPointMake((CGFloat)self.selectIndex * (BUBBLE_DIAMETER + BUBBLE_PADDING), 0)];
    
    self.topTitleLabel.text = [NSString stringWithFormat:@"%zd / %zd",(_selectIndex + 1),self.assetDataArr.count];
    
    self.finishBtn.hidden = [[FQImagePickerContainer share]getSelectAssetArr].count == 0;
}

#pragma mark - 响应事件

-(void)clickBackBtn:(UIButton *)sender
{
    if (_changPreviewBlock) {
        _changPreviewBlock(self.tempAssetArr.copy);
    }
    self.navigationController.navigationBar.hidden = NO;
    self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)clickSelectBtn:(UIButton *)sender {
    
    //首先判断是否达到了9张
    if (sender.selected == NO && [FQImagePickerContainer isUpperLimit]) {
        
        UIAlertController * alertVc = [UIAlertController alertControllerWithTitle:@"提示" message:[NSString stringWithFormat:@"每次最多可选%zd张图片!",self.maxSelectCount] preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction * cancelAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil];
        [alertVc addAction:cancelAction];
        
        [self presentViewController:alertVc animated:YES completion:nil];
        return;
    }
    
    sender.selected = !sender.selected;
    
    if (sender.selected == YES) {
        self.finishBtn.hidden = NO;
    }else{
        if ([[FQImagePickerContainer share]getSelectAssetArr].count == 1) {
            self.finishBtn.hidden = YES;
        }else{
            self.finishBtn.hidden = NO;
        }
    }
    
    FQAsset * selectAsset = self.assetDataArr[self.selectIndex];
    if (sender.selected) {
        
        [[FQImagePickerContainer share] addAsset:selectAsset andImagePickerCell:nil];
        
        [self.selectBtn setTitle:[NSString stringWithFormat:@"%zd",selectAsset.selectIndex] forState:UIControlStateSelected];
        
        //添加一个先放大.再还原的动画
        CABasicAnimation * basicAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
        
        basicAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        
        basicAnimation.duration = 0.2;
        
        basicAnimation.repeatCount = 1.0;
        
        basicAnimation.autoreverses = YES;
        
        basicAnimation.fromValue = @1.0;
        
        basicAnimation.toValue = @1.3;
        
        [sender.layer addAnimation:basicAnimation forKey:nil];
        
        if (_isReleasePreview) {
            
            [self.tempAssetArr addObject:selectAsset];
        }
        
    }else{
        [[FQImagePickerContainer share] deleteAsset:selectAsset andImagePickerCell:nil];
        [sender.layer removeAllAnimations];
        if (_isReleasePreview) {
            [self.tempAssetArr removeObject:selectAsset];
        }
    }
    
}

-(void)clickOrginBtn:(UIButton *)sender
{
    sender.selected = !sender.selected;
    FQAsset * selectAsset = self.assetDataArr[self.selectIndex];
    if (sender.selected) {
        [self.indicatorView startAnimating];
        __weak typeof(self) weakSelf = self;
        [selectAsset getOrginImgSize:^(NSString *imgSizeStr,FQAsset *asset) {
            dispatch_async(dispatch_get_main_queue(), ^{
                FQAsset * currentAsset = weakSelf.assetDataArr[weakSelf.selectIndex];
                if ([currentAsset isEqual:asset]) {
                    [sender setTitle:[NSString stringWithFormat:@"原图 (%@)",imgSizeStr] forState:UIControlStateNormal];
                }
                [weakSelf.orginImgBtn sizeToFit];
                weakSelf.orginImgBtn.height = 44;
                [weakSelf.indicatorView stopAnimating];
            });
        }];
        selectAsset.isOrgin = YES;
    }else{
        selectAsset.isOrgin = NO;
        [sender setTitle:@"原图" forState:UIControlStateNormal];
        [self.orginImgBtn sizeToFit];
        self.orginImgBtn.height = 44;
    }
}

/**
 点击完成按钮
 
 @param sender 完成按钮
 */
-(void)clickFinishBtn:(UIButton *)sender{
    
    //传所有图片
    if (_selectImageArrBlock) {
        _selectImageArrBlock([[FQImagePickerContainer share] getSelectImageArr]);
    }
    //传预览图
    if (_selectPreviewImageArrBlock) {
        _selectPreviewImageArrBlock([[FQImagePickerContainer share] getSelectPreviewImageArr]);
    }
    //传asset对象
    if (_selectAssetArrBlock) {
        _selectAssetArrBlock([[FQImagePickerContainer share] getSelectAssetArr]);
    }
    
    if (self.isReleasePreview) {
        self.navigationController.navigationBar.hidden = NO;
        self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
        if (_changPreviewBlock) {//更新cell的值即可
            _changPreviewBlock(self.tempAssetArr.copy);
        }
        [self.navigationController popViewControllerAnimated:YES];
        
    }else{
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - collectionDelegate

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.assetDataArr.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    FQImagePreviewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"FQImagePreviewCellID" forIndexPath:indexPath];
    cell.asset = self.assetDataArr[indexPath.row];
    __weak typeof(self) weakSelf = self;
    cell.singleTapGestureBlock = ^{
        [weakSelf showOrHiddenCoverView];
    };
    return cell;
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset{
    //因为offset不是对象不能用点访问
    CGFloat contentX = targetContentOffset->x;
    
    /*round：如果参数是小数，则求本身的四舍五入。
     ceil：如果参数是小数，则求最小的整数但不小于本身.
     floor：如果参数是小数，则求最大的整数但不大于本身.
     
     Example:如何值是3.4的话，则
     3.4 -- round 3.000000
     -- ceil 4.000000
     -- floor 3.00000
     **/
    
    //用四色五入 计算第几页
    float pageFloat = contentX/(BUBBLE_DIAMETER + BUBBLE_PADDING);
    
    NSInteger page = (int)round(pageFloat);
    //获取索引对应的cell.
    FQImagePreviewCell * cell = (FQImagePreviewCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:self.selectIndex inSection:0]];
    [cell reStoreScrollerScale];
    
    self.selectIndex = page;
}

#pragma mark - 显示与隐藏

-(void)showOrHiddenCoverView
{
    _statusBarShouldBeHidden = self.isShowToolBar;
    self.isShowToolBar = !self.isShowToolBar;
    [self toggleStatusBarAndNavBar:!self.isShowToolBar];
}


- (void)toggleStatusBarAndNavBar:(BOOL)hidden {
    if (hidden == NO) {
        self.topView.alpha = 1.0f;
        self.bottomView.alpha = 1.0f;
    }
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        // 先显示navigationBar
        if (!_isHiddenOrginBtn) {
            self.bottomView.transform = !hidden ? CGAffineTransformIdentity : CGAffineTransformMakeTranslation(0, 44);
            self.bottomView.alpha = !hidden ? 1.0f : 0.0f;
        }
        self.topView.top = hidden ? -self.topView.height : 0;
        
        [self setNeedsStatusBarAppearanceUpdate];
        [self.topView setAlpha:!hidden ? 1.0 : 0.0];
    } completion:nil];
}

#pragma mark - 初始化相关数据

-(void)setSelectIndex:(NSInteger)selectIndex
{
    _selectIndex = selectIndex;
    self.topTitleLabel.text = [NSString stringWithFormat:@"%zd / %zd",(_selectIndex + 1),self.assetDataArr.count];
    FQAsset * selectAsset = self.assetDataArr[_selectIndex];
    self.selectBtn.selected = selectAsset.isSelect;
    [self.selectBtn setTitle:[NSString stringWithFormat:@"%zd",selectAsset.selectIndex] forState:UIControlStateSelected];
    [self.indicatorView stopAnimating];
    if (selectAsset.isOrgin) {
        self.orginImgBtn.selected = YES;
        __weak typeof(self) weakSelf = self;
        [selectAsset getOrginImgSize:^(NSString *imgSizeStr,FQAsset *asset) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.orginImgBtn setTitle:[NSString stringWithFormat:@"原图 (%@)",imgSizeStr] forState:UIControlStateNormal];
                [weakSelf.orginImgBtn sizeToFit];
                weakSelf.orginImgBtn.height = 44;
            });
        }];
    }else{
        self.orginImgBtn.selected = NO;
        [self.orginImgBtn setTitle:@"原图" forState:UIControlStateNormal];
        [self.orginImgBtn sizeToFit];
        self.orginImgBtn.height = 44;
    }
}

-(void)setIsHiddenOrginBtn:(BOOL)isHiddenOrginBtn
{
    _isHiddenOrginBtn = isHiddenOrginBtn;
    self.bottomView.hidden = isHiddenOrginBtn;
}


/**
 传入数据
 
 @param previewArr 所有数据数组
 @param selectIndex 当前选中的索引
 */
-(void)setImgPreviewVc:(NSArray *)previewArr selectIndex:(NSInteger )selectIndex
{
    NSMutableArray * muAssetData = [NSMutableArray arrayWithArray:previewArr];
    
    FQAsset * asset = previewArr.firstObject;
    if (!asset.asset) { //去掉摄像头数据
        [muAssetData removeObjectAtIndex:0];
        selectIndex = selectIndex - 1;
    }
    self.selectIndex = selectIndex;
    self.assetDataArr = muAssetData.copy;
    self.tempAssetArr = [NSMutableArray arrayWithArray:muAssetData];
    FQAsset * selectAsset = self.assetDataArr[self.selectIndex];
    //设置他的原图按钮
    if (selectAsset.isOrgin) {
        self.orginImgBtn.selected = YES;
        __weak typeof(self) weakSelf = self;
        [selectAsset getOrginImgSize:^(NSString *imgSizeStr,FQAsset *asset) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.orginImgBtn setTitle:[NSString stringWithFormat:@"原图 (%@)",imgSizeStr] forState:UIControlStateNormal];
                [weakSelf.orginImgBtn sizeToFit];
                self.orginImgBtn.height = 44;
            });
        }];
    }else{
        self.orginImgBtn.selected = NO;
        [self.orginImgBtn setTitle:@"原图" forState:UIControlStateNormal];
        [self.orginImgBtn sizeToFit];
        self.orginImgBtn.height = 44;
    }
}

#pragma mark - 初始化相关控件

-(UICollectionView *)collectionView
{
    if (!_collectionView) {
        
        FQ_CollectionViewFlowLayout * flowLayout = [[FQ_CollectionViewFlowLayout alloc]init];
        flowLayout.minimumLineSpacing = BUBBLE_PADDING;
        _collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, BUBBLE_DIAMETER + BUBBLE_PADDING, self.view.bounds.size.height) collectionViewLayout:flowLayout];
        [_collectionView registerClass:[FQImagePreviewCell class] forCellWithReuseIdentifier:@"FQImagePreviewCellID"];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.pagingEnabled = YES;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.showsHorizontalScrollIndicator = NO;
        
    }
    return _collectionView;
}

-(UIView *)bottomView
{
    if (!_bottomView) {
        _bottomView = [[UIView alloc]init];
        _bottomView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
        /*
         毛玻璃的样式(枚举)
         UIBlurEffectStyleExtraLight,
         UIBlurEffectStyleLight,
         UIBlurEffectStyleDark
         */
        UIBlurEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithEffect:effect];
        effectView.frame = CGRectMake(0, 0, ScreenW, 44 + FQTABBAR_BOTTOM_SPACING);
        [_bottomView addSubview:effectView];
        
        [_bottomView addSubview:self.orginImgBtn];
        [_bottomView addSubview:self.finishBtn];
        [self.orginImgBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.offset(20);
            make.top.offset(0);
            make.height.equalTo(@44);
        }];
        
        [self.finishBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.offset(-20);
            make.centerY.equalTo(self.orginImgBtn.mas_centerY);
        }];
        
        self.orginImgBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, -10);
        
        [_bottomView addSubview:self.indicatorView];
        [self.indicatorView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.orginImgBtn.mas_right).offset(20);
            make.centerY.equalTo(self.orginImgBtn.mas_centerY);
        }];
        
    }
    return _bottomView;
}

-(UIView *)topView
{
    if (!_topView) {
        _topView = [[UIView alloc]init];
        _topView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
        /*
         毛玻璃的样式(枚举)
         UIBlurEffectStyleExtraLight,
         UIBlurEffectStyleLight,
         UIBlurEffectStyleDark
         */
        UIBlurEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithEffect:effect];
        effectView.frame = CGRectMake(0, 0, ScreenW, FQNAVIGATION_HEIGHT);
        [_topView addSubview:effectView];
        
        
        UIButton * cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [cancelBtn addTarget:self action:@selector(clickBackBtn:) forControlEvents:UIControlEventTouchUpInside];
        [cancelBtn setTitle:@"返回" forState:UIControlStateNormal];
        [cancelBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        cancelBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        
        //右边就是选中或者取消按钮
        FQAsset * selectAsset = self.assetDataArr[self.selectIndex];
        self.selectBtn = [[UIButton alloc]init];
        self.selectBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        self.selectBtn.selected = selectAsset.isSelect;
        self.selectBtn.contentMode = UIViewContentModeScaleAspectFit;
        [self.selectBtn setTitle:[NSString stringWithFormat:@"%zd",selectAsset.selectIndex] forState:UIControlStateSelected];
        [self.selectBtn setBackgroundImage:[UIImage imageNamed:@"icon_social_photo_normal_new" inBundle:MYBUNDLE compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
        [self.selectBtn setBackgroundImage:[UIImage imageNamed:@"icon_social_photo_select_new" inBundle:MYBUNDLE compatibleWithTraitCollection:nil] forState:UIControlStateSelected];
        [self.selectBtn addTarget:self action:@selector(clickSelectBtn:) forControlEvents:UIControlEventTouchUpInside];
        
        [_topView addSubview:cancelBtn];
        [_topView addSubview:self.selectBtn];
        [_topView addSubview:self.topTitleLabel];
        
        [cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.offset(20);
            make.top.offset(FQNAVIGATION_HEIGHT - 44);
            make.height.equalTo(@44);
        }];
        
        [self.selectBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.offset(-20);
            make.centerY.equalTo(cancelBtn.mas_centerY);
            make.height.width.equalTo(@25);
        }];
        
        [self.topTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(_topView.mas_centerX);
            make.height.equalTo(@44);
            make.bottom.equalTo(@0);
        }];
        
    }
    return _topView;
}

-(UIButton *)orginImgBtn
{
    if (!_orginImgBtn) {
        UIButton * isOrginBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        isOrginBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        [isOrginBtn setTitle:@"原图" forState:UIControlStateNormal];
        [isOrginBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [isOrginBtn setImage:[UIImage imageNamed:@"ios_systemImage_orgin_btn_normal_new" inBundle:MYBUNDLE compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
        [isOrginBtn setImage:[UIImage imageNamed:@"ios_systemImage_orgin_btn_select_new" inBundle:MYBUNDLE compatibleWithTraitCollection:nil] forState:UIControlStateSelected];
        [isOrginBtn addTarget:self action:@selector(clickOrginBtn:) forControlEvents:UIControlEventTouchUpInside];
        _orginImgBtn = isOrginBtn;
    }
    return _orginImgBtn;
}

-(UIButton *)finishBtn
{
    if (!_finishBtn) {
        UIButton * finishBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        finishBtn.titleLabel.font = [UIFont systemFontOfSize:12];
        [finishBtn setTitle:@"完成" forState:UIControlStateNormal];
        [finishBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [finishBtn setBackgroundImage:[UIImage imageWithColor:FQRGB(26.0, 137.0, 243.0)] forState:UIControlStateNormal];
        [finishBtn addTarget:self action:@selector(clickFinishBtn:) forControlEvents:UIControlEventTouchUpInside];
        finishBtn.contentEdgeInsets = UIEdgeInsetsMake(5, 15, 5, 15);
        finishBtn.layer.cornerRadius = 3;
        finishBtn.layer.masksToBounds = YES;
        _finishBtn = finishBtn;
    }
    return _finishBtn;
}

-(UIActivityIndicatorView *)indicatorView
{
    if (!_indicatorView) {
        _indicatorView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        _indicatorView.hidesWhenStopped = YES;
        _indicatorView.frame = CGRectMake(0, 0, 44, 44);
        [_indicatorView stopAnimating];
    }
    return _indicatorView;
}

-(NSMutableArray *)tempAssetArr
{
    if (!_tempAssetArr) {
        _tempAssetArr = [NSMutableArray array];
    }
    return _tempAssetArr;
}

-(UILabel *)topTitleLabel
{
    if (!_topTitleLabel) {
        _topTitleLabel = [[UILabel alloc]init];
        _topTitleLabel.textColor = [UIColor whiteColor];
        _topTitleLabel.textAlignment = NSTextAlignmentCenter;
        _topTitleLabel.text = [NSString stringWithFormat:@"%zd / %zd",(_selectIndex + 1),self.assetDataArr.count];
    }
    return _topTitleLabel;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
