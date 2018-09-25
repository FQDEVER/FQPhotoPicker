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
    BOOL _statusBarStyleControl;
    BOOL _leaveStatusBarAlone;
    BOOL _statusBarShouldBeHidden;
    BOOL _previousStatusBarStyle;
}

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, strong) NSArray *assetDataArr;

@property (nonatomic, assign) NSInteger selectIndex;

@property (nonatomic, strong) UIButton *selectBtn;

@property (nonatomic, strong) UIToolbar *bottomView;

/**
 原图按钮
 */
@property (nonatomic, strong) UIButton *orginImgBtn;

/**
 完成按钮
 */
@property (nonatomic, strong) UIButton *finishBtn;

//加载图片大小的进度提示
@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;

@property (nonatomic, strong) NSMutableArray *tempAssetArr;

//顶部容器
//@property (nonatomic, strong) UIView *topContainer;
//
//@property (nonatomic, strong) UIView *topContainerContentView;

@property (nonatomic, assign) BOOL isShowToolBar;

@property (nonatomic, strong) UILabel *topTitleLabel;

@end



@implementation FQImagePreviewVc

- (BOOL)prefersStatusBarHidden {
    if (!_leaveStatusBarAlone) {
        return _statusBarShouldBeHidden;
    } else {
        return [self presentingViewControllerPrefersStatusBarHidden];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    //    self.navigationController.navigationBar.hidden = YES;
    self.isShowToolBar = YES;
    
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    if (@available(iOS 11.0, *)) {
        
        self.collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        
    }else{
        
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    self.extendedLayoutIncludesOpaqueBars=YES;
    
    [self.view addSubview:self.collectionView];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.top.offset(0);
    }];
    
    //添加一个原图显示的view
    [self.view addSubview:self.bottomView];
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.left.right.offset(0);
        make.height.equalTo(@(44 + FQTABBAR_BOTTOM_SPACING));
    }];
    
    [self addBarButtonItem];
    
    self.topTitleLabel.text = [NSString stringWithFormat:@"%zd / %zd",(_selectIndex + 1),self.assetDataArr.count];
    
    self.finishBtn.hidden = [[FQImagePickerContainer share]getSelectAssetArr].count == 0;
}

- (void)viewWillAppear:(BOOL)animated {
    
    // Super
    [super viewWillAppear:animated];
    
    // Status bar
    
    _leaveStatusBarAlone = [self presentingViewControllerPrefersStatusBarHidden];
    // Check if status bar is hidden on first appear, and if so then ignore it
    if (CGRectEqualToRect([[UIApplication sharedApplication] statusBarFrame], CGRectZero)) {
        _leaveStatusBarAlone = YES;
    }
    
    // Set style
    if (!_leaveStatusBarAlone && UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        _previousStatusBarStyle = [[UIApplication sharedApplication] statusBarStyle];
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:animated];
    }
    
    [self setNavBarAppearance:animated];
}

-(void)viewWillDisappear:(BOOL)animated
{
    // Status bar
    if (!_leaveStatusBarAlone && UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [[UIApplication sharedApplication] setStatusBarStyle:_previousStatusBarStyle animated:animated];
    }
    [super viewWillDisappear:animated];
}


- (BOOL)presentingViewControllerPrefersStatusBarHidden {
    UIViewController *presenting = self.presentingViewController;
    if (presenting) {
        if ([presenting isKindOfClass:[UINavigationController class]]) {
            presenting = [(UINavigationController *)presenting topViewController];
        }
    } else {
        // We're in a navigation controller so get previous one!
        if (self.navigationController && self.navigationController.viewControllers.count > 1) {
            presenting = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count-2];
        }
    }
    if (presenting) {
        return [presenting prefersStatusBarHidden];
    } else {
        return NO;
    }
}

- (void)setNavBarAppearance:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    UINavigationBar *navBar = self.navigationController.navigationBar;
    navBar.tintColor = [UIColor whiteColor];
    navBar.barTintColor = nil;
    navBar.shadowImage = nil;
    navBar.translucent = YES;
    navBar.barStyle = UIBarStyleBlackTranslucent;
    [navBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    [navBar setBackgroundImage:nil forBarMetrics:UIBarMetricsCompact];
}

-(void)addBarButtonItem{
    
    UIButton * cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancelBtn addTarget:self action:@selector(clickBackBtn:) forControlEvents:UIControlEventTouchUpInside];
    [cancelBtn setTitle:@"返回" forState:UIControlStateNormal];
    [cancelBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    cancelBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    cancelBtn.frame = CGRectMake(0, 0, 40, 40);
    

    //右边就是选中或者取消按钮
    FQAsset * selectAsset = self.assetDataArr[self.selectIndex];
    self.selectBtn = [[UIButton alloc]init];
    self.selectBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    self.selectBtn.selected = selectAsset.isSelect;
    [self.selectBtn setTitle:[NSString stringWithFormat:@"%zd",selectAsset.selectIndex] forState:UIControlStateSelected];
    [self.selectBtn setBackgroundImage:[UIImage imageNamed:@"icon_social_photo_normal_new" inBundle:MYBUNDLE compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
    [self.selectBtn setBackgroundImage:[UIImage imageNamed:@"icon_social_photo_select_new" inBundle:MYBUNDLE compatibleWithTraitCollection:nil] forState:UIControlStateSelected];
    self.selectBtn.frame = CGRectMake(0, 0 , 25, 25);
    [self.selectBtn addTarget:self action:@selector(clickSelectBtn:) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:cancelBtn];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:self.selectBtn];
    [_topTitleLabel sizeToFit];
    self.navigationItem.titleView = self.topTitleLabel;
    
    self.collectionView.contentSize = CGSizeMake(ScreenW * self.assetDataArr.count, 0);
    [self.collectionView setContentOffset:CGPointMake((CGFloat)self.selectIndex * ScreenW, 0)];
}

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
        selectAsset.isOrgin = YES;
        [self.indicatorView startAnimating];
        __weak typeof(self) weakSelf = self;
        [selectAsset getOrginImgSize:^(NSString *imgSizeStr,FQAsset *asset) {
            dispatch_async(dispatch_get_main_queue(), ^{
                FQAsset * currentAsset = weakSelf.assetDataArr[weakSelf.selectIndex];
                if ([currentAsset isEqual:asset]) {
                    [sender setTitle:[NSString stringWithFormat:@"原图 (%@)",imgSizeStr] forState:UIControlStateNormal];
                }
                [weakSelf.indicatorView stopAnimating];
            });
        }];
    }else{
        selectAsset.isOrgin = NO;
        [sender setTitle:@"原图" forState:UIControlStateNormal];
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
    float pageFloat = contentX/ScreenW;
    
    NSInteger page = (int)round(pageFloat);
    
    targetContentOffset->x = page * ScreenW;
    
    //获取索引对应的cell.
    FQImagePreviewCell * cell = (FQImagePreviewCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:self.selectIndex inSection:0]];
    [cell reStoreScrollerScale];
    
    self.selectIndex = page;
    
}

-(void)setSelectIndex:(NSInteger)selectIndex
{
    _selectIndex = selectIndex;
    self.topTitleLabel.text = [NSString stringWithFormat:@"%zd / %zd",(_selectIndex + 1),self.assetDataArr.count];
    [_topTitleLabel sizeToFit];
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
            });
        }];
    }else{
        self.orginImgBtn.selected = NO;
        [self.orginImgBtn setTitle:@"原图" forState:UIControlStateNormal];
    }
}

-(void)showOrHiddenCoverView
{
    if (!self.isShowToolBar) {
        if (!_leaveStatusBarAlone) {
            _statusBarShouldBeHidden = NO;
        }
        [UIView animateWithDuration:0.33 animations:^{
            if (!_isHiddenOrginBtn) {
                self.bottomView.transform = CGAffineTransformIdentity;
                self.bottomView.alpha = 1.0f;
            }
            if (!_leaveStatusBarAlone) {
                [self setNeedsStatusBarAppearanceUpdate];
                // Nav bar slides up on it's own on iOS 7+
                [self.navigationController.navigationBar setAlpha:1.0];
            }
        }];
    }else{
        if (!_leaveStatusBarAlone) {
            _statusBarShouldBeHidden = YES;
        }
        [UIView animateWithDuration:0.33 animations:^{
            if (!_isHiddenOrginBtn) {
                self.bottomView.transform = CGAffineTransformMakeTranslation(0, 44);
                self.bottomView.alpha = 0.0f;
            }
            if (!_leaveStatusBarAlone) {
                [self setNeedsStatusBarAppearanceUpdate];
                [self.navigationController.navigationBar setAlpha:0.0];
            }
        }];
    }
    self.isShowToolBar = !self.isShowToolBar;
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
            });
        }];
    }else{
        self.orginImgBtn.selected = NO;
        [self.orginImgBtn setTitle:@"原图" forState:UIControlStateNormal];
    }
}

-(UICollectionView *)collectionView
{
    if (!_collectionView) {
        
        UICollectionViewFlowLayout * flowLayout = [[UICollectionViewFlowLayout alloc]init];
        flowLayout.itemSize = self.view.bounds.size;
        flowLayout.minimumLineSpacing = 0;
        flowLayout.minimumInteritemSpacing = 0;
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _collectionView = [[UICollectionView alloc]initWithFrame:CGRectZero collectionViewLayout:flowLayout];
        [_collectionView registerClass:[FQImagePreviewCell class] forCellWithReuseIdentifier:@"FQImagePreviewCellID"];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.pagingEnabled = YES;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.showsHorizontalScrollIndicator = NO;
        
    }
    return _collectionView;
}

-(UIToolbar *)bottomView
{
    if (!_bottomView) {
        _bottomView = [[UIToolbar alloc]init];
        //        _bottomView.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.6];
        //添加一个原图按钮
        
        _bottomView.tintColor = [UIColor whiteColor];
        _bottomView.barTintColor = nil;
        [_bottomView setBackgroundImage:nil forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
        [_bottomView setBackgroundImage:nil forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsCompact];
        _bottomView.barStyle = UIBarStyleBlackTranslucent;
        _bottomView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
        
        [_bottomView addSubview:self.orginImgBtn];
        [_bottomView addSubview:self.finishBtn];
        
        [self.orginImgBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.offset(20);
            make.top.bottom.offset(0);
        }];
        
        [self.finishBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.offset(-20);
            make.centerY.offset(0);
        }];
        
        self.orginImgBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, -10);
        
        [_bottomView addSubview:self.indicatorView];
        [self.indicatorView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.orginImgBtn.mas_right).offset(20);
            make.top.bottom.offset(0);
        }];
        
    }
    return _bottomView;
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
