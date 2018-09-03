//
//  FQImagePickerVc.m
//  FQPhotoPicker
//
//  Created by 龙腾飞 on 2018/3/26.
//  Copyright © 2018年 fanqi. All rights reserved.
//

#import "FQImagePickerVc.h"
#import "FQImagePickerService.h"
#import "FQImagePickerCollectionCell.h"
#import "FQVideoStreamCollectionCell.h"
#import "FQImagePickerTitleView.h"
#import "FQImagePickerTitleBtn.h"
#import "FQImagePickerContainer.h"
#import "FQImagePreviewVc.h"
#import <YYKit.h>
#import <Masonry.h>
#import <MBProgressHUD.h>

@interface FQImagePickerVc ()<UICollectionViewDelegate,UICollectionViewDataSource,UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, strong) NSArray *dataArr;

@property (nonatomic, strong) NSArray *totalArr;

@property (nonatomic, strong) FQImagePickerTitleBtn *titleViewBtn;

//弹出相册组名列表
@property (nonatomic, strong) FQImagePickerTitleView *titleCoverView;

@property (nonatomic, strong) UIButton * previewBtn;

//确认选中按钮
@property (nonatomic, strong) UIButton *confirmBtn;

//记录之前选中的数组
@property (nonatomic, strong) NSArray *oldSelectArr;

@property (nonatomic, strong) UIButton *cancelBtn;
@end

@implementation FQImagePickerVc

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:self.cancelBtn];
    
    self.navigationController.navigationBar.translucent = YES;
    if (@available(iOS 11.0, *))
    {
        self.collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    else
    {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusAuthorized) {
            [self userAuthorizationStatusAuthorized];
        }else if([PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusNotDetermined){
            [self askForAuthorize];
        }else{
            [self buildRestrictedUI];
        }
    });
}


- (void)buildRestrictedUI
{
    UIButton *tipBtn  = [UIButton buttonWithType:UIButtonTypeCustom];
    [tipBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    tipBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    tipBtn.titleLabel.numberOfLines = 2;
    tipBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    [tipBtn setTitle:@"相册权限未开启，请在设置中选择当前应用,开启相册功能 \n 点击去设置" forState:UIControlStateNormal];
    tipBtn.frame = CGRectMake(0, FQNAVIGATION_HEIGHT, ScreenW, 50);
    tipBtn.backgroundColor = [UIColor grayColor];
    [self.view addSubview:tipBtn];
    [self.view bringSubviewToFront:tipBtn];
    [tipBtn addTarget:self action:@selector(openAuthorization) forControlEvents:UIControlEventTouchUpInside];
}

-(void)openAuthorization
{
    [self openAuthorizationIsCamera:NO];
}

- (void)openAuthorizationIsCamera:(BOOL)isCamera
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:isCamera ? @"相机权限未开启": @"相册权限未开启" message:isCamera ? @"请前往设置->隐私->相机授权应用拍照权限" : @"请前往设置->隐私->相机授权应用相册权限" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *open = [UIAlertAction actionWithTitle:@"立即开启" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    }];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    
    [alert addAction:open];
    [alert addAction:cancel];
    
    [self.navigationController presentViewController:alert animated:YES completion:nil];
    
}


-(void)userAuthorizationStatusAuthorized
{
    self.navigationItem.titleView = self.titleViewBtn;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:self.previewBtn];
    if (!self.isScanCode) {
        [self.view addSubview:self.confirmBtn];
        [self.confirmBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.offset(0);
            make.height.equalTo(@(50 + FQTABBAR_BOTTOM_SPACING));
        }];
    }
    
    [self.view addSubview:self.collectionView];
    __weak typeof(self)weakSelf = self;
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.offset(FQNAVIGATION_HEIGHT);
        make.left.right.offset(0);
        weakSelf.isScanCode ? make.bottom.offset(0):make.bottom.equalTo(weakSelf.confirmBtn.mas_top).offset(0);
    }];
    
    [[FQImagePickerService share] reloadData];
    [[FQImagePickerContainer share] clearSelectCellArr];
    
    [FQImagePickerService share].dataLoadCompelteBlock = ^(NSArray *array){
        weakSelf.totalArr = array;
        for (NSDictionary *dataDict in weakSelf.totalArr) {
            if ([dataDict.allKeys.firstObject isEqualToString:[FQImagePickerService getAllPhotosStr]]) {
                [weakSelf.titleViewBtn setTitle:[FQImagePickerService getAllPhotosStr] forState:UIControlStateNormal];
                weakSelf.dataArr = dataDict.allValues.firstObject[FQPHImage];
                //这里为什么刷新以后数据就不对了
                weakSelf.dataArr = [[FQImagePickerContainer share]reloadSelectArrayNoneClearCurrentCellWithArr:weakSelf.dataArr];
                return;
            }
        }
    };
    
    [FQImagePickerContainer share].changAssetCountBlock = ^(NSInteger count) {
        if (!weakSelf.isScanCode) {
            if (count) {
                weakSelf.confirmBtn.enabled = YES;
                [weakSelf.confirmBtn setTitle:[NSString stringWithFormat:@"确定 %zd/%ld",count,weakSelf.maxSelectCount] forState:UIControlStateNormal];
                [weakSelf.previewBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                weakSelf.previewBtn.userInteractionEnabled = YES;
            }else{
                weakSelf.confirmBtn.enabled = NO;
                [weakSelf.confirmBtn setTitle:@"确定" forState:UIControlStateNormal];
                [weakSelf.previewBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
                weakSelf.previewBtn.userInteractionEnabled = NO;
            }
        }
    };
    
}

- (void)askForAuthorize
{
    __weak typeof(self)weakSelf = self;
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        if (status == PHAuthorizationStatusAuthorized) {//授权
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf userAuthorizationStatusAuthorized];
            });
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{//未授权
                [weakSelf buildRestrictedUI];
            });
        }
    }];
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if ([PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusAuthorized) {
        [self.collectionView reloadData];
    }
}


-(void)setIsScanCode:(BOOL)isScanCode
{
    _isScanCode = isScanCode;
    
    if (isScanCode) {
        //添加预览按钮
        [self.previewBtn setTitle:@"" forState:UIControlStateNormal];
    }
}

-(void)setIsAddImageCount:(BOOL)isAddImageCount
{
    _isAddImageCount = isAddImageCount;
    
    if (isAddImageCount) { //如果是YES.就需要先记录当前选中的cell.
        self.oldSelectArr = [[FQImagePickerContainer share]getSelectAssetArr];
    }
}


-(NSInteger)maxSelectCount
{
    if (_maxSelectCount == 0) {
        return 9;
    }else{
        return _maxSelectCount;
    }
}

#pragma mark =================>响应事件

/**
 点击取消按钮
 
 @param sender 取消按钮
 */
-(void)clickCancelBtn:(UIButton *)sender{
    /*
     不要再这处理.把清理权放到外面去
     */
    //    dispatch_async(dispatch_get_main_queue(), ^{
    //        [[FQImagePickerContainer share] clearSelectAssetArr];
    //    });
    
    if (self.isAddImageCount) { //那么就需要更换为原数组
        [[FQImagePickerContainer share] setSelectAssetArr:self.oldSelectArr];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

/**
 点击预览图片
 
 @param sender 预览按钮
 */
-(void)clickPreviewBtn:(UIButton *)sender
{
    FQImagePreviewVc * previewVc = [[FQImagePreviewVc alloc]init];
    previewVc.maxSelectCount = self.maxSelectCount;
    previewVc.selectImageArrBlock = self.selectImageArrBlock;
    previewVc.selectPreviewImageArrBlock = self.selectPreviewImageArrBlock;
    previewVc.selectAssetArrBlock = self.selectAssetArrBlock;
    [previewVc setImgPreviewVc:[[FQImagePickerContainer share] getSelectAssetArr] selectIndex:0];
    [self.navigationController pushViewController:previewVc animated:YES];
}

/**
 点击确定按钮
 
 @param sender 确定按钮
 */
-(void)clickConfirmBtn:(UIButton *)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
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
}

/**
 点击titleView
 */
-(void)clickTitleView
{
    self.titleViewBtn.selected = !self.titleViewBtn.selected;
    
    if (self.titleViewBtn.selected) {
        //展示出来
        [self.titleCoverView showTableView];
    }else{
        //隐藏
        [self.titleCoverView hiddenTableView];
    }
}


#pragma mark =================>CollectionDelegate


-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.dataArr.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    FQAsset * asset = self.dataArr[indexPath.row];
    if (!asset.asset) {
        FQVideoStreamCollectionCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"FQVideoStreamCollectionCellID" forIndexPath:indexPath];
        return cell;
    }else{
        FQImagePickerCollectionCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"FQImagePickerCollectionCellID" forIndexPath:indexPath];
        cell.asset =  self.dataArr[indexPath.row];
        cell.isScanCode = self.isScanCode;
        __weak typeof(self)weakSelf = self;
        cell.isblock = ^{
            [weakSelf alertTipWithUpperLimit];
        };
        return cell;
    }
}



-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    
    FQAsset * asset = self.dataArr[indexPath.row];
    
    if (!asset.asset) {
        //跳转到拍照
        //是否获取了拍摄全新啊
        AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        if (authStatus == AVAuthorizationStatusDenied||authStatus == AVAuthorizationStatusRestricted) {
            [self openAuthorizationIsCamera:YES];
            return ;
        }
        UIImagePickerController * imgPickerVc = [[UIImagePickerController alloc]init];
        imgPickerVc.sourceType = UIImagePickerControllerSourceTypeCamera;
        imgPickerVc.delegate = self;
        [self presentViewController:imgPickerVc animated:YES completion:nil];
    }else{
        if (self.isScanCode) {//选中一个返回
            MBProgressHUD * hud = [self showHUDOnlyActivityIndicatorOnView:self.view hiddenAfterDelay:0];
            //处理单张回调图
            if (asset.isOrgin) {
                if (_selectScanCodeImgBlock) {
                    _selectScanCodeImgBlock(asset.orginImg);
                }
            }else{
                if (asset.previewImg) {
                    if (_selectScanCodeImgBlock) {
                        _selectScanCodeImgBlock(asset.previewImg);
                    }
                }else{
                    if (_selectScanCodeImgBlock) {
                        _selectScanCodeImgBlock([asset getPreviewImg]);
                    }
                }
            }
            [hud hideAnimated:YES];
            [self dismissViewControllerAnimated:YES completion:nil];
            return;
        }
        //跳转到预览
        FQImagePreviewVc * previewVc = [[FQImagePreviewVc alloc]init];
        previewVc.maxSelectCount = self.maxSelectCount;
        previewVc.selectImageArrBlock = self.selectImageArrBlock;
        previewVc.selectPreviewImageArrBlock = self.selectPreviewImageArrBlock;
        previewVc.selectAssetArrBlock = self.selectAssetArrBlock;
        [previewVc setImgPreviewVc:self.dataArr selectIndex:indexPath.row];
        [self.navigationController pushViewController:previewVc animated:YES];
    }
    
}

#pragma mark - HUD

/**
 在view 上显示转圈
 
 @param view 目标 view
 @param delayTime 延迟消失时间.不添加可自己回调手动隐藏
 @return hud对象
 */
-(MBProgressHUD *)showHUDOnlyActivityIndicatorOnView:(UIView *)view hiddenAfterDelay:(CGFloat)delayTime
{
    UIView *showView = nil;
    if (view == nil)
    {
        showView = [UIApplication sharedApplication].keyWindow;
    }
    else
    {
        showView = view;
    }
    
    MBProgressHUD *oldHud = [MBProgressHUD HUDForView:showView];
    [oldHud hideAnimated:NO];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:showView animated:YES];
    hud.contentColor = [UIColor whiteColor];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.animationType = MBProgressHUDAnimationZoom;
    hud.bezelView.backgroundColor = [UIColor blackColor];
    hud.removeFromSuperViewOnHide = YES;
    hud.square = NO;
    
    if (delayTime) {
        [hud hideAnimated:YES afterDelay:delayTime];
    }
    
    return hud;
}

#pragma mark =================>系统相机
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    [picker dismissViewControllerAnimated:YES completion:nil];
    //这种图片没有保存到相册
    __weak typeof(self)weakSelf = self;
    
    [self loadImageFinished:info[UIImagePickerControllerOriginalImage] block:^(FQAsset *asset){
        
        if (weakSelf.isScanCode) {
            //处理单张回调图
            if (asset.isOrgin) {
                if (weakSelf.selectScanCodeImgBlock) {
                    weakSelf.selectScanCodeImgBlock(asset.orginImg);
                }
            }else{
                if (weakSelf.selectScanCodeImgBlock) {
                    
                    if (asset.previewImg) {
                        weakSelf.selectScanCodeImgBlock(asset.previewImg);
                    }else{
                        weakSelf.selectScanCodeImgBlock([asset getPreviewImg]);
                    }
                }
            }
            //处理单张回调图
            [weakSelf dismissViewControllerAnimated:YES completion:nil];
            return;
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                //#warning 如果性能不行.就考虑只是插入到最近添加以及所有照片字典中
                if (![FQImagePickerContainer isUpperLimit]) {
                    [[FQImagePickerContainer share] addAsset:asset andImagePickerCell:nil];
                    //提示框
                }else{
                    [weakSelf alertTipWithUpperLimit];
                }
                [[FQImagePickerService share] reloadData];
                __weak typeof(self)weakSelf = self;
                [FQImagePickerService share].dataLoadCompelteBlock = ^(NSArray *array){
                    weakSelf.totalArr = array;
                    for (NSDictionary *dataDict in weakSelf.totalArr) {
                        if ([dataDict.allKeys.firstObject isEqualToString:[FQImagePickerService getAllPhotosStr]]) {
                            weakSelf.dataArr = dataDict.allValues.firstObject[FQPHImage];
                        }
                    }
                    weakSelf.dataArr = [[FQImagePickerContainer share]reloadSelectArrayWithArr:weakSelf.dataArr];
                    [weakSelf.collectionView reloadData];
                };
            });
        }
    }];
}

- (void)loadImageFinished:(UIImage *)image block:(void(^)(FQAsset * asset))completionBlock
{
    //成功后取相册中的图片对象
    NSMutableArray *imageIds = [NSMutableArray array];
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        
        //写入图片到相册
        PHAssetChangeRequest *req = [PHAssetChangeRequest creationRequestForAssetFromImage:image];
        //记录本地标识，等待完成后取到相册中的图片对象
        [imageIds addObject:req.placeholderForCreatedAsset.localIdentifier];
        
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        
        if (success)
        {
            PHFetchResult *result = [PHAsset fetchAssetsWithLocalIdentifiers:imageIds options:nil];
            [result enumerateObjectsUsingBlock:^(PHAsset * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                
                FQAsset * asset = [FQAsset new];
                asset.asset = obj;
                if (completionBlock) {
                    completionBlock(asset);
                }
                *stop = YES;
            }];
        }
    }];
}


-(void)alertTipWithUpperLimit
{
    UIAlertController * alertVc = [UIAlertController alertControllerWithTitle:@"提示" message:[NSString stringWithFormat:@"每次最多可选%ld张图片!",(long)self.maxSelectCount] preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction * cancelAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil];
    [alertVc addAction:cancelAction];
    [self presentViewController:alertVc animated:YES completion:nil];
}


#pragma mark =================>懒加载

-(UICollectionView *)collectionView
{
    if (!_collectionView) {
        UICollectionViewFlowLayout * flowLayout = [[UICollectionViewFlowLayout alloc]init];
        flowLayout.minimumLineSpacing = 5;
        flowLayout.minimumInteritemSpacing = 5;
        CGFloat sizeWH = (self.view.bounds.size.width - 5 * 5) * 0.25;
        flowLayout.itemSize = CGSizeMake(sizeWH,sizeWH);
        _collectionView = [[UICollectionView alloc]initWithFrame:CGRectZero collectionViewLayout:flowLayout];
        _collectionView.contentInset = UIEdgeInsetsMake(5, 5, 5, 5);
        [_collectionView registerClass:[FQImagePickerCollectionCell class] forCellWithReuseIdentifier:@"FQImagePickerCollectionCellID"];
        [_collectionView registerClass:[FQVideoStreamCollectionCell class] forCellWithReuseIdentifier:@"FQVideoStreamCollectionCellID"];
        _collectionView.backgroundColor = [UIColor groupTableViewBackgroundColor];
        _collectionView.delegate = self;
        _collectionView.dataSource  = self;
    }
    return _collectionView;
}

-(NSArray *)dataArr
{
    if (!_dataArr) {
        
        for (NSDictionary *dataDict in self.totalArr) {
            if ([dataDict.allKeys.firstObject isEqualToString:[FQImagePickerService getAllPhotosStr]]) {
                _dataArr = dataDict.allValues.firstObject[FQPHImage];
            }
            _dataArr = [[FQImagePickerContainer share]reloadSelectArrayWithArr:_dataArr];
        }
    }
    return _dataArr;
}

-(NSArray *)totalArr
{
    if (!_totalArr) {
        _totalArr = [[FQImagePickerService share] dataSourceArray];
    }
    return _totalArr;
}

-(FQImagePickerTitleBtn *)titleViewBtn
{
    if (!_titleViewBtn) {
        FQImagePickerTitleBtn * button = [[FQImagePickerTitleBtn alloc]init];
        
        [button setTitle:[FQImagePickerService getAllPhotosStr] forState:UIControlStateNormal];
        
        button.titleLabel.font = [UIFont systemFontOfSize:15];
        
        [button addTarget:self action:@selector(clickTitleView) forControlEvents:UIControlEventTouchUpInside];
        
        [button setImage:[UIImage imageNamed:@"btn-shareDetailTriathlon-isOpen-down"] forState:UIControlStateNormal];
        
        button.frame = CGRectMake(0, 0, ScreenW - 100, 33);
        
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        
        _titleViewBtn = button;
    }
    
    return _titleViewBtn;
}

-(FQImagePickerTitleView *)titleCoverView
{
    if (!_titleCoverView) {
        _titleCoverView = [[FQImagePickerTitleView alloc]initWithFrame:self.view.bounds];
        _titleCoverView.dataSourceArr = self.totalArr;
        [self.view addSubview:_titleCoverView];
        __weak typeof(self) weakSelf = self;
        _titleCoverView.handleTapGestureBlock = ^{
            weakSelf.titleViewBtn.selected = NO;
        };
        _titleCoverView.clickTableCellBlock = ^(NSDictionary *dataDict) {
            
            [weakSelf.titleViewBtn setTitle:dataDict[FQPHTitle] forState:UIControlStateNormal];
            weakSelf.dataArr =  [[FQImagePickerContainer share] reloadSelectArrayWithArr:dataDict[FQPHImage]];
            //根据统一数组更新dataArr里面的数据
            [weakSelf.collectionView reloadData];
        };
    }
    return _titleCoverView;
}

-(UIButton *)confirmBtn
{
    if (!_confirmBtn) {
        _confirmBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_confirmBtn setBackgroundImage:[UIImage imageNamed:@"icon_social_confirm_normal_icon"] forState:UIControlStateDisabled];
        [_confirmBtn setBackgroundImage:[UIImage imageNamed:@"icon_social_confirm_select_icon"] forState:UIControlStateNormal];
        _confirmBtn.enabled = NO;
        _confirmBtn.backgroundColor = [UIColor whiteColor];
        [_confirmBtn setTitle:@"确定" forState:UIControlStateNormal];
        _confirmBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        [_confirmBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        if (FQIS_IPHONE_X) {
            _confirmBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 20, 0);
        }
        [_confirmBtn addTarget:self action:@selector(clickConfirmBtn:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _confirmBtn;
}

-(UIButton *)previewBtn
{
    if (!_previewBtn) {
        UIButton * previewBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [previewBtn addTarget:self action:@selector(clickPreviewBtn:) forControlEvents:UIControlEventTouchUpInside];
        [previewBtn setTitle:@"预览" forState:UIControlStateNormal];
        [previewBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        previewBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        previewBtn.frame = CGRectMake(0, 0, 40, 33);
        previewBtn.userInteractionEnabled = [[FQImagePickerContainer share] getSelectAssetArr].count ? YES : NO;
        _previewBtn = previewBtn;
    }
    return _previewBtn;
}

-(UIButton *)cancelBtn
{
    if (!_cancelBtn) {
        _cancelBtn  = [UIButton buttonWithType:UIButtonTypeCustom];
        [_cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
        [_cancelBtn addTarget:self action:@selector(clickCancelBtn:) forControlEvents:UIControlEventTouchUpInside];
        [_cancelBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        _cancelBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        _cancelBtn.frame = CGRectMake(0, 0, 40, 33);
        
    }
    return _cancelBtn;
}


-(void)dealloc
{
    //清空数据
    [[FQImagePickerContainer share] clearSelectCellArr];
    [[FQImagePickerService share] clearDataArr];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
