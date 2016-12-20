//
//  YodPictureEditViewController.m
//  WECAST
//
//  Created by 陈阳阳 on 16/12/13.
//  Copyright © 2016年 YOD. All rights reserved.
//

#import "YodPictureEditViewController.h"
#import "UIView+Extension.h"

#define DisplayViewWidth  self.view.bounds.size.width
#define DisplayViewHeight floor(DisplayViewWidth / self.cropScale)

@interface YodPictureEditViewController () <UIScrollViewDelegate>

@property (nonatomic,strong) UIScrollView *scrollView;
@property (nonatomic,strong) UIImageView  *imageView;

@property (nonatomic,strong) UIImage *originalImage; // 原始图片
@property (nonatomic,assign) CGFloat cropScale;      // 裁剪图片比例

@end

@implementation YodPictureEditViewController

- (instancetype)initWithImage:(UIImage *)originalImage cropScale:(CGFloat)scale{
    self = [super init];
    if (self) {
        self.originalImage = originalImage;
        NSLog(@"原始图片宽高 =  %f %f",originalImage.size.width,originalImage.size.height);
        self.cropScale = scale;

    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    CGFloat scaleX = self.view.bounds.size.width  / self.originalImage.size.width;
    CGFloat scaleY = self.view.bounds.size.height / self.originalImage.size.height;
    CGFloat scale  = MIN(scaleX, scaleY);
    NSLog(@"scaleX = %f scaleY = %f",scaleX,scaleY);
    
    self.imageView.frame = CGRectMake(0, 0, self.originalImage.size.width, self.originalImage.size.height);
    self.scrollView.zoomScale = scale;
    [self updateScrollViewContents];
    
    [self setupBottomView];
    
    [self setupDisplayView];

}

- (void)updateScrollViewContents {
    CGFloat top = 0;
    CGFloat left = 0;
    self.imageView.center = self.scrollView.center;
    
    if (self.imageView.frame.size.height > DisplayViewHeight) {
        top = (self.imageView.frame.size.height - DisplayViewHeight ) / 2;
    }
    if (self.imageView.frame.size.width > DisplayViewWidth) {
        left = (self.imageView.frame.size.width - DisplayViewWidth) / 2;
    }
    _scrollView.contentInset = UIEdgeInsetsMake(top, left, 0, 0);
    _scrollView.contentSize = CGSizeMake(self.view.bounds.size.width + left, self.view.height + (self.imageView.height - DisplayViewHeight ) / 2);
    self.scrollView.contentOffset = CGPointMake(0, 0);
    
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    [self updateScrollViewContents];
}

- (void)setupBottomView {
    UIView *bottomView = [[UIView alloc]initWithFrame:CGRectMake(0 , self.view.bounds.size.height - 44, self.view.bounds.size.width, 44)];
    bottomView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    [self.view addSubview:bottomView];
    UIButton *cancelBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, bottomView.bounds.size.width / 2, bottomView.bounds.size.height)];
    [cancelBtn setTitle:@"Cancel" forState:UIControlStateNormal];
    [cancelBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [cancelBtn addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];
    UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(CGRectGetMaxX(cancelBtn.frame), 0, 1, CGRectGetHeight(cancelBtn.frame))];
    lineView.backgroundColor = [UIColor whiteColor];
    [bottomView addSubview:lineView];
    UIButton *chooseBtn = [[UIButton alloc]initWithFrame:CGRectMake(bottomView.bounds.size.width / 2 + 1, 0, bottomView.bounds.size.width / 2 - 1, bottomView.bounds.size.height)];
    [chooseBtn setTitle:@"Choose" forState:UIControlStateNormal];
    [chooseBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [chooseBtn addTarget:self action:@selector(choose) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:cancelBtn];
    [bottomView addSubview:chooseBtn];
}

- (void)cancel {
    if (self.cancel_callback) {
        self.cancel_callback();
    }
}

- (void)choose {
    UIImage *image = [self cropImage];
    NSLog(@"result image width = %f height = %f",image.size.width,image.size.height);
    if (self.choose_callback) {
        self.choose_callback(image);
    }
}

- (UIImage *)cropImage{

    CGRect rect =self.view.frame;
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [self.view.layer renderInContext:context];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    NSLog(@"crop image width = %f",self.originalImage.size.width * self.scrollView.zoomScale);
//    CGFloat imageW = self.originalImage.size.width * self.scrollView.zoomScale;
//    CGFloat imageH = self.originalImage.size.height * self.scrollView.zoomScale;
//    if (imageW >= DisplayViewWidth && imageH >= DisplayViewHeight) {
        rect = CGRectMake(1, (self.view.bounds.size.height - DisplayViewHeight) / 2 + 1, DisplayViewWidth - 2, DisplayViewHeight - 2);
//    }else if 
    

    
    CGImageRef imageRef = CGImageCreateWithImageInRect([img CGImage],rect);
    
    UIImage * newImg = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    return newImg;
}

- (void)setupDisplayView {
    CGFloat topMaskViewHeight = (self.view.bounds.size.height - DisplayViewHeight) / 2;
    CGFloat bottomMaskViewHeight = topMaskViewHeight - 44;
    UIView *topMaskView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, topMaskViewHeight)];
    topMaskView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    [self.view addSubview:topMaskView];
    UIView *bottomMaskView = [[UIView alloc]initWithFrame:CGRectMake(0, self.view.bounds.size.height - 44 - bottomMaskViewHeight, DisplayViewWidth, bottomMaskViewHeight)];
    bottomMaskView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    [self.view addSubview:bottomMaskView];
    
    UIView *topLineView = [[UIView alloc]initWithFrame:CGRectMake(0, topMaskViewHeight, DisplayViewWidth, 1)];
    topLineView.backgroundColor = [UIColor redColor];
    [self.view addSubview:topLineView];
    
    UIView *leftLineView = [[UIView alloc]initWithFrame:CGRectMake(0, topMaskViewHeight, 1, DisplayViewHeight)];
    leftLineView.backgroundColor = [UIColor redColor];
    [self.view addSubview:leftLineView];
    
    UIView *bottomLineView = [[UIView alloc]initWithFrame:CGRectMake(0, bottomMaskView.frame.origin.y - 1, DisplayViewWidth, 1)];
    bottomLineView.backgroundColor = [UIColor redColor];
    [self.view addSubview:bottomLineView];
    
    UIView *rightLineView = [[UIView alloc]initWithFrame:CGRectMake(DisplayViewWidth - 1, topMaskViewHeight, 1, leftLineView.bounds.size.height)];
    rightLineView.backgroundColor = [UIColor redColor];
    [self.view addSubview:rightLineView];
}

- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc]initWithFrame:self.view.bounds];
        _scrollView.backgroundColor = [UIColor clearColor];
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.bounces = YES;
        _scrollView.alwaysBounceVertical = YES;
        _scrollView.alwaysBounceHorizontal = YES;
        _scrollView.scrollEnabled = YES;
        _scrollView.delegate = self;
        _scrollView.minimumZoomScale = 0.1;
        _scrollView.maximumZoomScale = 20;
        [self.view addSubview:_scrollView];
    }
    return _scrollView;
}

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc]init];
        _imageView.image = self.originalImage;
        [self.scrollView addSubview:_imageView];
    }
    return _imageView;
}

@end
