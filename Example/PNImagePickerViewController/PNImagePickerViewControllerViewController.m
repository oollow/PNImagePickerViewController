//
//  PNImagePickerViewControllerViewController.m
//  PNImagePickerViewController
//
//  Created by Giuseppe Nucifora on 02/09/2016.
//  Copyright (c) 2016 Giuseppe Nucifora. All rights reserved.
//

#import "PNImagePickerViewControllerViewController.h"
#import "PNImagePickerViewController.h"

@interface PNImagePickerViewControllerViewController () <PNImagePickerViewControllerDelegate>

@property (nonatomic) BOOL didSetupConstraints;
@property (nonatomic, strong) UIButton *button;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) PNImagePickerViewController *imagePickerController;

@end

@implementation PNImagePickerViewControllerViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    _button = [UIButton new];
    _button.translatesAutoresizingMaskIntoConstraints = NO;
    [_button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [_button setTitle:@"Show Picker" forState:UIControlStateNormal];
    [_button addTarget:self action:@selector(showPicker) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_button];

    _imageView = [UIImageView new];
    _imageView.translatesAutoresizingMaskIntoConstraints = NO;
    [_imageView setBackgroundColor:[[UIColor lightGrayColor] colorWithAlphaComponent:0.6]];
    [_imageView setContentMode:UIViewContentModeScaleAspectFit];
    
    [self.view addSubview:_imageView];

    [self.view setNeedsUpdateConstraints];

	// Do any additional setup after loading the view, typically from a nib.
}

- (void) updateViewConstraints {
    if (!_didSetupConstraints) {
        _didSetupConstraints = YES;
        [self.view.topAnchor constraintEqualToAnchor:self.view.superview.topAnchor].active = YES;
        [self.view.leadingAnchor constraintEqualToAnchor:self.view.superview.leadingAnchor].active = YES;
        [self.view.trailingAnchor constraintEqualToAnchor:self.view.superview.trailingAnchor].active = YES;
        [self.view.bottomAnchor constraintEqualToAnchor:self.view.superview.bottomAnchor].active = YES;
        
        [_imageView.topAnchor constraintEqualToAnchor:_imageView.superview.topAnchor].active = YES;
        [_imageView.leadingAnchor constraintEqualToAnchor:_imageView.superview.leadingAnchor].active = YES;
        [_imageView.trailingAnchor constraintEqualToAnchor:_imageView.superview.trailingAnchor].active = YES;
        [_imageView.centerXAnchor constraintEqualToAnchor:_imageView.superview.centerXAnchor].active = YES;
        
        [_button.topAnchor constraintEqualToAnchor:_imageView.bottomAnchor constant:20].active = YES;
        [_button.bottomAnchor constraintEqualToAnchor:_button.superview.bottomAnchor constant:-20].active = YES;
        [_button.centerXAnchor constraintEqualToAnchor:_button.superview.centerXAnchor].active = YES;
        [_button.heightAnchor constraintEqualToConstant:30].active = YES;
        [_button.leadingAnchor constraintGreaterThanOrEqualToAnchor:_button.superview.leadingAnchor constant:100].active = YES;
        [_button.trailingAnchor constraintGreaterThanOrEqualToAnchor:_button.superview.trailingAnchor constant:-100].active = YES;
    }
    [super updateViewConstraints];
}

- (void) showPicker {

    if (!_imagePickerController) {
        _imagePickerController = [[PNImagePickerViewController alloc] init];
        _imagePickerController.delegate = self;
    }
    [_imagePickerController setEnableEditMode:YES];
    [_imagePickerController showImagePickerInController:self animated:YES];

}

#pragma mark - PNImagePickerViewControllerDelegate

- (void)imagePicker:(PNImagePickerViewController *)imagePicker didSelectImage:(UIImage *)image {
    self.imageView.image = image;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
