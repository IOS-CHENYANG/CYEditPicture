//
//  YodPictureEditViewController.h
//  WECAST
//
//  Created by 陈阳阳 on 16/12/13.
//  Copyright © 2016年 YOD. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YodPictureEditViewController : UIViewController

@property (nonatomic,copy) void (^cancel_callback) ();
@property (nonatomic,copy) void (^choose_callback) (UIImage *);

// originalImage : 原始图片     scale : 裁剪比例   4 / 3    16 / 9 
- (instancetype)initWithImage:(UIImage *)originalImage cropScale:(CGFloat)scale;

@end
