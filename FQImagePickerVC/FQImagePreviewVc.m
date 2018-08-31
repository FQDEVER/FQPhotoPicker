//
//  FQImagePreviewVc.m
//  FQPhotoPicker
//
//  Created by 龙腾飞 on 2018/3/27.
//  Copyright © 2018年 fanqi. All rights reserved.
//

#import "FQImagePreviewVc.h"
#import "FQAsset.h"
#import "Masonry.h"
#import "FQImagePreviewCell.h"
#import "FQImagePickerContainer.h"

@interface FQImagePreviewVc ()<UICollectionViewDataSource,UICollectionViewDelegate>

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, strong) NSArray *assetDataArr;

@property (nonatomic, assign) NSInteger selectIndex;

@property (nonatomic, strong) UIButton *selectBtn;

@property (nonatomic, strong) UIView *bottomView;

@property (nonatomic, strong) UIButton *orginImgBtn;

//加载图片大小的进度提示
@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;

@end

@implementation FQImagePreviewVc

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    if (@available(iOS 11.0, *)) {
        
        self.collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        
    }else{
        
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    [self.view addSubview:self.collectionView];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.top.offset(0);
    }];
    
    self.title = [NSString stringWithFormat:@"%zd / %zd",(self.selectIndex + 1),self.assetDataArr.count];
    
    [self addBarButtonItem];
    
    //添加一个原图显示的view
    [self.view addSubview:self.bottomView];
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.left.right.offset(0);
        make.height.equalTo(@44);
    }];
}


-(void)addBarButtonItem{
    
    UIButton * cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancelBtn addTarget:self action:@selector(clickBackBtn:) forControlEvents:UIControlEventTouchUpInside];
    [cancelBtn setTitle:@"返回" forState:UIControlStateNormal];
    [cancelBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    cancelBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    cancelBtn.frame = CGRectMake(0, 0, 40, 33);
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:cancelBtn];
    
    //右边就是选中或者取消按钮
    FQAsset * selectAsset = self.assetDataArr[self.selectIndex];
    self.selectBtn = [[UIButton alloc]init];
    self.selectBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    self.selectBtn.selected = selectAsset.isSelect;
    [self.selectBtn setTitle:[NSString stringWithFormat:@"%zd",selectAsset.selectIndex] forState:UIControlStateSelected];
    [self.selectBtn setBackgroundImage:[UIImage imageNamed:@"btn-shareDetail-normal"] forState:UIControlStateNormal];
    [self.selectBtn setBackgroundImage:[UIImage imageNamed:@"btn-shareDetail-select"] forState:UIControlStateSelected];
    self.selectBtn.frame = CGRectMake(0, 0 , 20, 20);
    [self.selectBtn addTarget:self action:@selector(clickSelectBtn:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:self.selectBtn];
    
    self.collectionView.contentSize = CGSizeMake(ScreenW * self.assetDataArr.count, 0);
    [self.collectionView setContentOffset:CGPointMake((CGFloat)self.selectIndex * ScreenW, 0)];
}

-(void)clickBackBtn:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)clickSelectBtn:(UIButton *)sender {
    
    //首先判断是否达到了9张
    if (sender.selected == NO && [FQImagePickerContainer isUpperLimit]) {
        
        UIAlertController * alertVc = [UIAlertController alertControllerWithTitle:@"提示" message:@"每次最多可选9张图片!" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction * cancelAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil];
        [alertVc addAction:cancelAction];
    
        [self presentViewController:alertVc animated:YES completion:nil];
    return;

    }
    
    sender.selected = !sender.selected;
    
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
    }else{
        [[FQImagePickerContainer share] deleteAsset:selectAsset andImagePickerCell:nil];
        [sender.layer removeAllAnimations];
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
    
    self.selectIndex = page;
    
}

-(void)setSelectIndex:(NSInteger)selectIndex
{
    _selectIndex = selectIndex;
    
    self.title = [NSString stringWithFormat:@"%zd / %zd",(_selectIndex + 1),self.assetDataArr.count];
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
    [self.navigationController setNavigationBarHidden:!self.navigationController.navigationBar.hidden animated:YES];
    if (self.bottomView.hidden) {
        self.bottomView.hidden = NO;
        [UIView animateWithDuration:0.33 animations:^{
            self.bottomView.transform = CGAffineTransformIdentity;
        }];
    }else{
        [UIView animateWithDuration:0.33 animations:^{
                self.bottomView.transform = CGAffineTransformMakeTranslation(0, 44);
        }completion:^(BOOL finished) {
            self.bottomView.hidden = YES;
        }];
    }

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

-(UIView *)bottomView
{
    if (!_bottomView) {
        _bottomView = [[UIView alloc]init];
        _bottomView.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.6];
        //添加一个原图按钮

        [_bottomView addSubview:self.orginImgBtn];
        
        [self.orginImgBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.offset(20);
            make.top.bottom.offset(0);
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
        [isOrginBtn setImage:[UIImage imageNamed:@"btn-shareDetail-normal"] forState:UIControlStateNormal];
        [isOrginBtn setImage:[UIImage imageNamed:@"btn-shareDetail-select"] forState:UIControlStateSelected];
        [isOrginBtn addTarget:self action:@selector(clickOrginBtn:) forControlEvents:UIControlEventTouchUpInside];
        _orginImgBtn = isOrginBtn;
    }
    return _orginImgBtn;
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
