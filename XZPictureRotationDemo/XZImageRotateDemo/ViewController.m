//
//  ViewController.m
//  XZImageRotateDemo
//
//  Created by 徐章 on 16/5/31.
//  Copyright © 2016年 徐章. All rights reserved.
//

#import "ViewController.h"

@interface ViewController (){

    CGSize _initialSize;
    
    CATransform3D _transform3D;
    
    CGFloat _flipState1;
    CGFloat _flipState2;
    
}
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UISlider *slider;
@property (weak, nonatomic) IBOutlet UIImageView *preImageView;

@property (strong, nonatomic) UIView *backgroundView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.backgroundView = [[UIView alloc] initWithFrame:self.imageView.frame];
    self.backgroundView.backgroundColor = [UIColor clearColor];
    self.backgroundView.center = self.view.center;
    self.backgroundView.layer.borderColor = [UIColor redColor].CGColor;
    self.backgroundView.layer.borderWidth = 1.0f;
    [self.view addSubview:self.backgroundView];
    
    _flipState1 = 0;
    _flipState2 = 0;
    
    _initialSize = self.imageView.frame.size;

    [self.slider addTarget:self action:@selector(slideValue_Changed:) forControlEvents:UIControlEventValueChanged];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)slideValue_Changed:(UISlider *)slider{

    CGFloat arg = slider.value * M_PI;
    
    CATransform3D transform = CATransform3DIdentity;
    transform = CATransform3DRotate(transform, arg, 0, 0, 1);
    transform = CATransform3DRotate(transform, _flipState1*M_PI, 0, 1, 0);
    transform = CATransform3DRotate(transform, _flipState2*M_PI, 1, 0, 0);
    
    CGFloat new_W = fabs(_initialSize.width * cos(arg)) + fabs(_initialSize.height * sin(arg));
    CGFloat new_H = fabs(_initialSize.width * sin(arg)) + fabs(_initialSize.height * cos(arg));
    
    CGFloat scale = MIN(([UIScreen mainScreen].bounds.size.width - _initialSize.width)/new_W , ([UIScreen mainScreen].bounds.size.height- 140)/new_H);

    transform = CATransform3DScale(transform, scale, scale, 1);
    
    _transform3D = transform;
    
    self.imageView.layer.transform = transform;
    
    
    self.backgroundView.frame = self.imageView.frame;

}
- (IBAction)horizontalBtn_Pressed:(id)sender {
    
    _flipState1 = (_flipState1 == 0) ? 1 : 0;
    [self slideValue_Changed:self.slider];
}
- (IBAction)verticalBtn_Pressed:(id)sender {
    
    _flipState2 = (_flipState2 == 0) ? 1 : 0;
    [self slideValue_Changed:self.slider];
}
- (IBAction)completeBtn_Pressed:(id)sender {
    
    CIImage *ciImage = [[CIImage alloc] initWithImage:self.imageView.image];
    CIFilter *filter = [CIFilter filterWithName:@"CIAffineTransform" keysAndValues:kCIInputImageKey, ciImage, nil];

    [filter setDefaults];
    CGAffineTransform transform = CATransform3DGetAffineTransform(_transform3D);
    
    [filter setValue:[NSValue valueWithBytes:&transform objCType:@encode(CGAffineTransform)] forKey:@"inputTransform"];
    
    
    CIContext *context = [CIContext contextWithOptions:@{kCIContextUseSoftwareRenderer : @(NO)}];
    CIImage *outputImage = [filter outputImage];
    CGImageRef cgImage = [context createCGImage:outputImage fromRect:[outputImage extent]];
    
    UIImage *result = [UIImage imageWithCGImage:cgImage];
    
    CGImageRelease(cgImage);
    
    self.preImageView.image = [UIImage imageWithCGImage:result.CGImage];

}

@end
