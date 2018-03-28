//
//  FQImagePreviewCell.m
//  FQPhotoPicker
//
//  Created by 龙腾飞 on 2018/3/27.
//  Copyright © 2018年 fanqi. All rights reserved.
//

#import "FQImagePreviewCell.h"
#import "Masonry.h"
#import "FQAsset.h"

@interface FQImagePreviewCell()<UIScrollViewDelegate>

@property (nonatomic, strong) UIImageView *previewImg;

//添加一张scrollView
@property (nonatomic, strong) UIScrollView *imgScroller;

@end

@implementation FQImagePreviewCell

-(instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self creatUI];
    }
    return self;
}

-(void)creatUI{
    
    [self.contentView addSubview:self.imgScroller];
    self.imgScroller.frame = self.contentView.bounds;
    self.previewImg = [[UIImageView alloc]init];
    [self.imgScroller addSubview:self.previewImg];
    self.previewImg.contentMode = UIViewContentModeScaleAspectFit;
    self.previewImg.frame = self.contentView.bounds;
}

/**
 恢复scroller状态
 */
-(void)reStoreScrollerScale
{
    [self.imgScroller setZoomScale:1.0];
}


#pragma mark ------------------>scrollerDelegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.previewImg;
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale

{
    NSLog(@"scale is %f",scale);
    [self.imgScroller setZoomScale:scale animated:NO];
}



-(void)setAsset:(FQAsset *)asset
{
    _asset = asset;
    __weak typeof(self) weakSelf = self;
    [asset fetchPreviewImgWithCompletion:^(UIImage *previewImg, NSDictionary *infoDict) {
        weakSelf.previewImg.image = previewImg;
    }];
}

-(UIScrollView *)imgScroller
{
    if (!_imgScroller) {
        _imgScroller = [[UIScrollView alloc]init];
        _imgScroller.maximumZoomScale = 3;
        _imgScroller.minimumZoomScale = 1.0;
        _imgScroller.showsVerticalScrollIndicator = NO;
        _imgScroller.showsHorizontalScrollIndicator = NO;
        _imgScroller.delegate = self;
        
        //添加双击放大或者缩小
        UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(clickTapGesture)];
        [_imgScroller addGestureRecognizer:tapGesture];
        
        //添加手势
        UITapGestureRecognizer * doubleTapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(clickDoubleTapGesture:)];
        doubleTapGesture.numberOfTapsRequired = 2;
        [_imgScroller addGestureRecognizer:doubleTapGesture];
        //检测不了双击就使用单击手势
        [tapGesture requireGestureRecognizerToFail:doubleTapGesture];
        
    }
    return _imgScroller;
}

-(void)clickDoubleTapGesture:(UITapGestureRecognizer *)tapGesture
{
    //缩小
    if(self.imgScroller.zoomScale > 1.0){
        [self.imgScroller setZoomScale:1.0 animated:YES];
    }else{ //放大
        //偏移到响应的位置
        CGRect zoomRect = [self zoomRectForScale:3.0 withCenter:[tapGesture locationInView:tapGesture.view]];
        [self.imgScroller zoomToRect:zoomRect animated:YES];
    }
}

-(void)clickTapGesture
{
    if (_singleTapGestureBlock) {
        _singleTapGestureBlock();
    }
}

#pragma mark - CommonMethods
- (CGRect)zoomRectForScale:(float)scale withCenter:(CGPoint)center
{
    CGRect zoomRect;
    zoomRect.size.height =self.frame.size.height / scale;
    zoomRect.size.width  =self.frame.size.width  / scale;
    zoomRect.origin.x = center.x - (zoomRect.size.width  /2.0);
    zoomRect.origin.y = center.y - (zoomRect.size.height /2.0);
    return zoomRect;
}

@end
