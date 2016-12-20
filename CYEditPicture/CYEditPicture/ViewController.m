//
//  ViewController.m
//  CYEditPicture
//
//  Created by 陈阳阳 on 16/12/15.
//  Copyright © 2016年 cyy. All rights reserved.
//

#import "ViewController.h"
#import "YodPictureEditViewController.h"

@interface ViewController () <UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property (nonatomic,strong) UIImageView *resultImageView;

@property (nonatomic,strong) UIImagePickerController *IPC;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIImageView *resultImageView = [[UIImageView alloc]initWithFrame:CGRectMake((self.view.bounds.size.width - 100) / 2, 100, 200, 200 * 3 / 4)];
    self.resultImageView = resultImageView;
    self.resultImageView.contentMode = UIViewContentModeScaleToFill;
    self.resultImageView.clipsToBounds = YES;
    [self.view addSubview:resultImageView];

    
    UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake((self.view.bounds.size.width - 60) / 2, 300, 60, 40)];
    [self.view addSubview:button];
    button.backgroundColor = [UIColor redColor];
    [button addTarget:self action:@selector(buttonClick) forControlEvents:UIControlEventTouchUpInside];
    
    self.IPC = [[UIImagePickerController alloc]init];
    self.IPC.delegate = self;
}

- (void)buttonClick {
    __weak typeof(self) weakSelf = self;
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *takePhotoAction = [UIAlertAction actionWithTitle:@"Take a photo" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"take a photo");
        weakSelf.IPC.sourceType = UIImagePickerControllerSourceTypeCamera;
        [weakSelf presentViewController:weakSelf.IPC animated:NO completion:nil];
    }];
    [takePhotoAction setValue:[UIColor blackColor] forKey:@"titleTextColor"];
    [alert addAction:takePhotoAction];
    UIAlertAction *choosePhotoAction = [UIAlertAction actionWithTitle:@"Choose from photo" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"choose from photo");
        weakSelf.IPC.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [weakSelf presentViewController:weakSelf.IPC animated:NO completion:nil];
    }];
    [choosePhotoAction setValue:[UIColor blackColor] forKey:@"titleTextColor"];
    [alert addAction:choosePhotoAction];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"cancel");
    }];
    [cancelAction setValue:[UIColor blackColor] forKey:@"titleTextColor"];
    [alert addAction:cancelAction];
    [self presentViewController:alert animated:NO completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    NSLog(@"info = %@",info);
    __weak typeof(self) weakSelf = self;
    UIImage *originalImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    NSLog(@"original size width = %f, height = %f",originalImage.size.width,originalImage.size.height);
    
    YodPictureEditViewController *edit = [[YodPictureEditViewController alloc]initWithImage:originalImage cropScale: 4.f / 3.f];
    [self dismissViewControllerAnimated:NO completion:^{
        [weakSelf presentViewController:edit animated:NO completion:nil];
    }];
    edit.cancel_callback = ^() {
        [weakSelf dismissViewControllerAnimated:NO completion:nil];
    };
    edit.choose_callback = ^(UIImage *image) {
        [weakSelf dismissViewControllerAnimated:NO completion:^{
            weakSelf.resultImageView.image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
            NSLog(@"we = %@",weakSelf.resultImageView);
        }];
        NSLog(@"edited size width = %f, height = %f",image.size.width,image.size.height);
    };
}

@end
