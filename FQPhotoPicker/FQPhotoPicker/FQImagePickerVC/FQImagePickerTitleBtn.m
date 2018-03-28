//
//  FQImagePickerTitleBtn.m
//  FQPhotoPicker
//
//  Created by 龙腾飞 on 2018/3/26.
//  Copyright © 2018年 fanqi. All rights reserved.
//

#import "FQImagePickerTitleBtn.h"

@implementation FQImagePickerTitleBtn

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    //重新布局按钮
    self.titleLabel.center = CGPointMake(self.bounds.size.width * 0.5, self.bounds.size.height * 0.5);
    
    self.imageView.frame = CGRectMake(CGRectGetMaxX(self.titleLabel.frame) + 3, (self.bounds.size.height - self.imageView.bounds.size.height) * 0.5, self.imageView.bounds.size.width, self.imageView.bounds.size.height);
    
}

-(void)setSelected:(BOOL)selected
{
    [super setSelected:selected];

    [UIView animateWithDuration:0.33 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        if (selected) { //选中
            self.imageView.transform = CGAffineTransformMakeRotation(M_PI);
        }else{
            self.imageView.transform = CGAffineTransformIdentity;
        }
    } completion:nil];
}

@end
