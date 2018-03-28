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
#import "Masonry.h"
#import "FQImagePickerContainer.h"
#import "FQImagePreviewVc.h"

// 渐变蓝按钮开始的颜色
#define COLOR_BLUE_BUTTON_START [UIColor colorWithRed:0.00 green:0.45 blue:0.98 alpha:1.00]
// 渐变蓝按钮结束的颜色
#define COLOR_BLUE_BUTTON_END [UIColor colorWithRed:0.13 green:0.65 blue:0.99 alpha:1.00]


@interface FQImagePickerVc ()<UICollectionViewDelegate,UICollectionViewDataSource,UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, strong) NSArray *dataArr;

@property (nonatomic, strong) NSArray *totalArr;

@property (nonatomic, strong) FQImagePickerTitleBtn *titleViewBtn;

//弹出相册组名列表
@property (nonatomic, strong) FQImagePickerTitleView *titleCoverView;

@property (nonatomic, weak) UIButton * previewBtn;

//确认选中按钮
@property (nonatomic, strong) UIButton *confirmBtn;

@end

@implementation FQImagePickerVc

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIButton * cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancelBtn addTarget:self action:@selector(clickCancelBtn:) forControlEvents:UIControlEventTouchUpInside];
    [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    [cancelBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    cancelBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    cancelBtn.frame = CGRectMake(0, 0, 40, 33);
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:cancelBtn];
    
    if ([PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusAuthorized) {
        [self userAuthorizationStatusAuthorized];
    }else if([PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusNotDetermined){
        [self askForAuthorize];
    }else{
        [self buildRestrictedUI];
    }
}

- (void)buildRestrictedUI
{
    UIButton *tipBtn  = [UIButton buttonWithType:UIButtonTypeCustom];
    [tipBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    tipBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    tipBtn.titleLabel.numberOfLines = 2;
    tipBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    [tipBtn setTitle:@"相册权限未开启，请在设置中选择当前应用,开启相册功能 \n 点击去设置" forState:UIControlStateNormal];
    tipBtn.frame = CGRectMake(0, (ScreenH/2.)-25, ScreenW, 50);
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
    
    //添加预览按钮
    [self addBarButtonItem];
    
    [self.view addSubview:self.confirmBtn];
    
    [self.confirmBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.offset(0);
        make.height.equalTo(@50);
    }];
    
    [self.view addSubview:self.collectionView];
    
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.offset(64);
        make.left.right.offset(0);
        make.bottom.equalTo(self.confirmBtn.mas_top).offset(0);
    }];
    
    __weak typeof(self)weakSelf = self;
    [FQImagePickerService share].dataLoadCompelteBlock = ^(NSArray *array){
        weakSelf.totalArr = array;
        for (NSDictionary *dataDict in weakSelf.totalArr) {
            if ([dataDict.allKeys.firstObject isEqualToString:@"所有照片"]) {
                weakSelf.dataArr = dataDict.allValues.firstObject[FQPHImage];
            }
        }
        [weakSelf.collectionView reloadData];
    };
    
    [FQImagePickerContainer share].changAssetCountBlock = ^(NSInteger count) {
        weakSelf.previewBtn.userInteractionEnabled = count;
        if (count) {
            weakSelf.confirmBtn.enabled = YES;
            [weakSelf.confirmBtn setTitle:[NSString stringWithFormat:@"确定 %zd/9",count] forState:UIControlStateNormal];
            [weakSelf.previewBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        }else{
            weakSelf.confirmBtn.enabled = NO;
            [weakSelf.confirmBtn setTitle:@"确定" forState:UIControlStateNormal];
            [weakSelf.previewBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        }
    };

}

- (void)askForAuthorize
{
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        if (status == PHAuthorizationStatusAuthorized) {//授权
            dispatch_async(dispatch_get_main_queue(), ^{
                [self userAuthorizationStatusAuthorized];
            });
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{//未授权
                [self buildRestrictedUI];
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

-(void)addBarButtonItem{
    
    UIButton * previewBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [previewBtn addTarget:self action:@selector(clickPreviewBtn:) forControlEvents:UIControlEventTouchUpInside];
    [previewBtn setTitle:@"预览" forState:UIControlStateNormal];
    [previewBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    previewBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    previewBtn.frame = CGRectMake(0, 0, 40, 33);
    self.previewBtn = previewBtn;
    previewBtn.userInteractionEnabled = NO;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:previewBtn];
}

#pragma mark =================>响应事件
-(void)clickCancelBtn:(UIButton *)sender{
    
    [[FQImagePickerContainer share] clearSelectAssetArr];
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)clickPreviewBtn:(UIButton *)sender
{
//    跳转到下一个界面
    FQImagePreviewVc * previewVc = [[FQImagePreviewVc alloc]init];
    [previewVc setImgPreviewVc:[[FQImagePickerContainer share] getSelectAssetArr] selectIndex:0];
    [self.navigationController pushViewController:previewVc animated:YES];
}

-(void)clickConfirmBtn:(UIButton *)sender
{
    //传图片出去
    if (_selectImageArrBlock) {
        _selectImageArrBlock([[FQImagePickerContainer share] getSelectImageArr]);
    }
    [[FQImagePickerContainer share] clearSelectAssetArr];
    [self dismissViewControllerAnimated:YES completion:nil];
}

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
        //跳转到预览
        FQImagePreviewVc * previewVc = [[FQImagePreviewVc alloc]init];
        [previewVc setImgPreviewVc:self.dataArr selectIndex:indexPath.row];
        [self.navigationController pushViewController:previewVc animated:YES];
    }
    
}

#pragma mark =================>系统相机
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    [picker dismissViewControllerAnimated:YES completion:nil];
    //这种图片没有保存到相册
    __weak typeof(self)weakSelf = self;
    [self loadImageFinished:info[UIImagePickerControllerOriginalImage] block:^(FQAsset *asset){
        
        dispatch_async(dispatch_get_main_queue(), ^{
#warning 如果性能不行.就考虑只是插入到最近添加以及所有照片字典中
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
                    if ([dataDict.allKeys.firstObject isEqualToString:@"所有照片"]) {
                        weakSelf.dataArr = dataDict.allValues.firstObject[FQPHImage];
                    }
                }
                weakSelf.dataArr = [[FQImagePickerContainer share]reloadSelectArrayWithArr:weakSelf.dataArr];
                [weakSelf.collectionView reloadData];
            };
        });
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
    UIAlertController * alertVc = [UIAlertController alertControllerWithTitle:@"提示" message:@"每次最多可选9张图片!" preferredStyle:UIAlertControllerStyleAlert];
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
            if ([dataDict.allKeys.firstObject isEqualToString:@"所有照片"]) {
                _dataArr = dataDict.allValues.firstObject[FQPHImage];
            }
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
        
        [button setTitle:@"所有照片" forState:UIControlStateNormal];
        
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
        [_confirmBtn setBackgroundImage:[self getGradientImageWithColors:@[COLOR_BLUE_BUTTON_START,COLOR_BLUE_BUTTON_END] imgSize:CGSizeMake(ScreenW, 50)] forState:UIControlStateNormal];
        _confirmBtn.enabled = NO;
        _confirmBtn.backgroundColor = [UIColor whiteColor];
        [_confirmBtn setTitle:@"确定" forState:UIControlStateNormal];
        [_confirmBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_confirmBtn addTarget:self action:@selector(clickConfirmBtn:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _confirmBtn;
}

/**
 获取渐变色的图片
 
 @param colors 渐变色颜色
 @param imgSize 图片的尺寸
 @return  image
 */
-(UIImage *)getGradientImageWithColors:(NSArray*)colors imgSize:(CGSize)imgSize
{
    NSMutableArray *arRef = [NSMutableArray array];
    for (NSInteger i = 0; i < colors.count; i++)
    {
        UIColor *ref = colors[i];
        [arRef addObject:(id)ref.CGColor];
    }
    UIGraphicsBeginImageContextWithOptions(imgSize, YES, [UIScreen mainScreen].scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    CGColorSpaceRef colorSpace = CGColorGetColorSpace([[colors lastObject] CGColor]);
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (CFArrayRef)arRef, NULL);
    CGPoint start = CGPointMake(0.0, 0.0);
    CGPoint end = CGPointMake(imgSize.width, imgSize.height);
    CGContextDrawLinearGradient(context, gradient, start, end, kCGGradientDrawsBeforeStartLocation | kCGGradientDrawsAfterEndLocation);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    CGGradientRelease(gradient);
    CGContextRestoreGState(context);
    UIGraphicsEndImageContext();
    return image;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
