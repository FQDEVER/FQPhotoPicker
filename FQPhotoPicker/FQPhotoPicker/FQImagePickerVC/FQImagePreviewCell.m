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

@property (nonatomic, strong) UIView *containerView;

@property (nonatomic, strong) YYAnimatedImageView * imageView; //UIImageView *imageView;

//添加一张scrollView
@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, strong) CAShapeLayer *progressLayer;

@end

@implementation FQImagePreviewCell

-(instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    return self;
}

- (void)setup {
    
    self.frame = [UIScreen mainScreen].bounds;
    self.backgroundColor = COLOR_WHITE;
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickTapGesture)];
    [self addGestureRecognizer:singleTap];
    
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
    doubleTap.numberOfTapsRequired = 2;
    [singleTap requireGestureRecognizerToFail:doubleTap];
    [self addGestureRecognizer:doubleTap];
    
    // 设置 UIScrollView 相关属性
    self.scrollView = [[UIScrollView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.scrollView.delegate = self;
    self.scrollView.bouncesZoom = YES;
    self.scrollView.maximumZoomScale = 3.0;
    self.scrollView.multipleTouchEnabled = YES;
    self.scrollView.alwaysBounceVertical = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    [self addSubview:self.scrollView];
    
    // containerView
    self.containerView = [[UIView alloc] init];
    [self.scrollView addSubview:self.containerView];
    
    
    // imageView
    self.imageView = [[YYAnimatedImageView alloc]init];//[[UIImageView alloc] init];
    self.imageView.clipsToBounds = YES;
    self.imageView.backgroundColor = COLOR_WHITE;
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.imageView.frame = self.contentView.bounds;
    [self.containerView addSubview:self.imageView];
    
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
    [self.layer addSublayer:_progressLayer];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _progressLayer.center = CGPointMake(self.width / 2, self.height / 2);
}

/**
 恢复scroller状态
 */
-(void)reStoreScrollerScale
{
    [self.scrollView setZoomScale:1.0 animated:YES];
}


#pragma mark ------------------>scrollerDelegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return self.containerView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    UIView *subView = self.containerView;
    
    CGFloat offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width)?
    (scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5 : 0.0;
    
    CGFloat offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height)?
    (scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5 : 0.0;
    
    subView.center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX,
                                 scrollView.contentSize.height * 0.5 + offsetY);
}

- (void)doubleTap:(UITapGestureRecognizer *)recognizer {
    
    if (self.asset.isGif) {
        return;
    }
    if (self.scrollView.zoomScale > 1.0) {
        [self.scrollView setZoomScale:1.0 animated:YES];
    } else {
        CGPoint touchPoint = [recognizer locationInView:self.imageView];
        CGFloat newZoomScale = self.scrollView.maximumZoomScale;
        CGFloat xSize = self.width / newZoomScale;
        CGFloat ySize = self.height / newZoomScale;
        [self.scrollView zoomToRect:CGRectMake(touchPoint.x - xSize / 2, touchPoint.y - ySize / 2, xSize, ySize) animated:YES];
    }
}


-(void)setAsset:(FQAsset *)asset
{
    _asset = asset;
    __weak typeof(self) weakSelf = self;
    self.progressLayer.hidden = YES;
    self.imageView.image = asset.thumbImg;
    if (asset.isGif) {
        [asset fetchGIFImgWithCompletion:^(UIImage *gifImg, NSDictionary *dict) {
            weakSelf.imageView.image = gifImg;
            weakSelf.progressLayer.hidden = YES;
        }progressBlock:^(double progress, NSError * _Nullable error, BOOL * _Nonnull stop, NSDictionary * _Nullable info) {
            if (isnan(progress)) progress = 0;
            weakSelf.progressLayer.hidden = NO;
            weakSelf.progressLayer.strokeEnd = progress;
        }];
    }else{
        [asset fetchPreviewImgWithCompletion:^(UIImage *image, NSDictionary *dict) {
            weakSelf.imageView.image = image;
            [weakSelf resizeSubviewSize];
        } progressBlock:nil];
    }
}

- (void)resizeSubviewSize {
    self.containerView.origin = CGPointZero;
    self.containerView.width = self.width;
    
    UIImage *image = _imageView.image;
    if (image.size.height / image.size.width > self.height / self.width) {
        self.containerView.height = floor(image.size.height / (image.size.width / self.width));
    } else {
        CGFloat height = image.size.height / image.size.width * self.width;
        if (height < 1 || isnan(height)) height = self.height;
        height = floor(height);
        self.containerView.height = height;
        self.containerView.centerY = self.height / 2;
    }
    if (self.containerView.height > self.height && self.containerView.height - self.height <= 1) {
        self.containerView.height = self.height;
    }
    self.scrollView.contentSize = CGSizeMake(self.width, MAX(self.containerView.height, self.height));
    [self.scrollView scrollRectToVisible:self.bounds animated:NO];
    
    if (self.containerView.height <= self.height) {
        self.scrollView.alwaysBounceVertical = NO;
    } else {
        self.scrollView.alwaysBounceVertical = YES;
    }
    
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    _imageView.frame = self.containerView.bounds;
    [CATransaction commit];
}


-(void)clickTapGesture
{
    if (_singleTapGestureBlock) {
        _singleTapGestureBlock();
    }
}


@end
