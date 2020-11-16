//
//  PNCollectionViewCell.h
//  Pods
//
//  Created by Giuseppe Nucifora on 09/02/16.
//
//

#import "PNImagePickerViewController.h"
#import <Photos/Photos.h>
#import <PhotosUI/PhotosUI.h>
#import <MobileCoreServices/UTCoreTypes.h>
#import "PNCollectionViewCell.h"
#import "NSString+HexColor.h"
// #import <PureLayout/PureLayout.h>
#import <CLImageEditor/CLImageEditor.h>


#pragma mark - PNImagePickerViewController -

@interface PNImagePickerViewController ()  <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIImagePickerControllerDelegate, UINavigationControllerDelegate,CLImageEditorDelegate>

#define imagePickerHeight 290.0f

@property (readwrite) bool isVisible;
@property (readwrite) bool haveCamera;
@property (nonatomic) NSTimeInterval animationTime;

@property (nonatomic, strong) UIViewController *targetController;

@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, strong) UIView *imagePickerView;
@property (nonatomic, strong) UIView *separator1;
@property (nonatomic, strong) UIView *separator2;
@property (nonatomic, strong) UIView *separator3;

@property (nonatomic, strong) NSLayoutConstraint *hideConstraint;

@property (nonatomic) TransitionDelegate *transitionController;

@property (nonatomic, strong) NSMutableArray *assets;

@property (nonatomic, assign) BOOL didUpdateConstraints;

@end

@implementation PNImagePickerViewController

@synthesize delegate;
@synthesize transitionController;

- (id)init {
    self = [super init];
    if (self) {
        _assets = [[NSMutableArray alloc] init];
        _targetSize = CGSizeMake(1024, 1024);
        _haveCamera = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
        _animationTime = 0.4;
        _enableEditMode = NO;
        
    }
    return self;
}

- (void) viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor clearColor];
    
    _imagePickerView = [UIView new];
    _imagePickerView.translatesAutoresizingMaskIntoConstraints = NO;
    [_imagePickerView setBackgroundColor:[UIColor whiteColor]];
    
    _backgroundView = [UIView new];
    _backgroundView.translatesAutoresizingMaskIntoConstraints = NO;
    _backgroundView.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.7];
    _backgroundView.alpha = 0;
    UITapGestureRecognizer *dismissTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss)];
    _backgroundView.userInteractionEnabled = YES;
    [_backgroundView addGestureRecognizer:dismissTap];
    
    [self.view addSubview:_backgroundView];
        
    UICollectionViewFlowLayout *aFlowLayout = [[UICollectionViewFlowLayout alloc] init];
    [aFlowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, 0, 0) collectionViewLayout:aFlowLayout];
    [_collectionView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_collectionView setBackgroundColor:[UIColor whiteColor]];
    _collectionView.showsHorizontalScrollIndicator = NO;
    _collectionView.showsVerticalScrollIndicator = NO;
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    [_collectionView registerClass:[PNCollectionViewCell class] forCellWithReuseIdentifier:[PNCollectionViewCell cellIdentifier]];
    
    UIFont *btnFont = [UIFont systemFontOfSize:19.0];
    
    _photoLibraryBtn = [UIButton new];
    _photoLibraryBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [_photoLibraryBtn setTitle:NSLocalizedString(@"Photo Library",@"") forState:UIControlStateNormal];
    _photoLibraryBtn.titleLabel.font = btnFont;
    [_photoLibraryBtn addTarget:self action:@selector(selectFromLibraryWasPressed) forControlEvents:UIControlEventTouchUpInside];
    [_photoLibraryBtn setTitleColor:[@"0b60fe" colorFromHex] forState:UIControlStateNormal];
    [_photoLibraryBtn setTitleColor:[@"70b3fd" colorFromHex] forState:UIControlStateHighlighted];
    
    _cancelBtn = [UIButton new];
    _cancelBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [_cancelBtn setTitle:NSLocalizedString(@"Cancel",@"") forState:UIControlStateNormal];
    _cancelBtn.titleLabel.font = btnFont;
    [_cancelBtn addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];
    [_cancelBtn setTitleColor:[@"0b60fe" colorFromHex] forState:UIControlStateNormal];
    [_cancelBtn setTitleColor:[@"70b3fd" colorFromHex] forState:UIControlStateHighlighted];
        
    _separator2 = [UIView new];
    _separator2.translatesAutoresizingMaskIntoConstraints = NO;
    _separator2.backgroundColor = [@"cacaca" colorFromHex];
    [_imagePickerView addSubview:_separator2];
    
    _separator3 = [UIView new];
    _separator3.translatesAutoresizingMaskIntoConstraints = NO;
    _separator3.backgroundColor = [@"cacaca" colorFromHex];
    [_imagePickerView addSubview:_separator3];
    
    if(_haveCamera) {
        _cameraBtn = [UIButton new];
        _cameraBtn.translatesAutoresizingMaskIntoConstraints = NO;
        [_cameraBtn setTitle:NSLocalizedString(@"Take Photo",@"") forState:UIControlStateNormal];
        _cameraBtn.titleLabel.font = btnFont;
        [_cameraBtn addTarget:self action:@selector(takePhotoWasPressed) forControlEvents:UIControlEventTouchUpInside];
        [_cameraBtn setTitleColor:[@"0b60fe" colorFromHex] forState:UIControlStateNormal];
        [_cameraBtn setTitleColor:[@"70b3fd" colorFromHex] forState:UIControlStateHighlighted];
        _cameraBtn.hidden = !_haveCamera;
        [_imagePickerView addSubview:_cameraBtn];
        
        _separator1 = [UIView new];
        _separator1.translatesAutoresizingMaskIntoConstraints = NO;
        _separator1.backgroundColor = [@"cacaca" colorFromHex];
        [_imagePickerView addSubview:_separator1];
    }
    
    
    [_imagePickerView addSubview:_collectionView];
    [_imagePickerView addSubview:_photoLibraryBtn];
    [_imagePickerView addSubview:_cancelBtn];
    
    [self.view addSubview:_imagePickerView];
    
    [self.view setNeedsUpdateConstraints];
    [_imagePickerView setNeedsUpdateConstraints];
    [_collectionView setNeedsUpdateConstraints];
    [_backgroundView setNeedsUpdateConstraints];
    
}

- (void) updateViewConstraints {
    if (!_didUpdateConstraints) {
        _didUpdateConstraints = YES;
        [_backgroundView.topAnchor constraintEqualToAnchor:_backgroundView.superview.topAnchor].active = YES;
        [_backgroundView.leadingAnchor constraintEqualToAnchor:_backgroundView.superview.leadingAnchor].active = YES;
        [_backgroundView.trailingAnchor constraintEqualToAnchor:_backgroundView.superview.trailingAnchor].active = YES;
        [_backgroundView.bottomAnchor constraintEqualToAnchor:_backgroundView.superview.bottomAnchor].active = YES;
        
        [_imagePickerView.leadingAnchor constraintEqualToAnchor:_imagePickerView.superview.leadingAnchor].active = YES;
        [_imagePickerView.trailingAnchor constraintEqualToAnchor:_imagePickerView.superview.trailingAnchor].active = YES;
        _hideConstraint = [_imagePickerView.bottomAnchor constraintEqualToAnchor:_imagePickerView.superview.bottomAnchor constant:-imagePickerHeight];
        _hideConstraint.active = YES;
        [_imagePickerView.heightAnchor constraintGreaterThanOrEqualToConstant:290].active = YES;
        
        [_collectionView.widthAnchor constraintEqualToAnchor:_imagePickerView.widthAnchor].active = YES;
        [_collectionView.heightAnchor constraintEqualToConstant:122].active = YES;
        
        [_cancelBtn.widthAnchor constraintEqualToAnchor:_imagePickerView.widthAnchor constant:-20].active = YES;
        [_cancelBtn.centerXAnchor constraintEqualToAnchor:_imagePickerView.centerXAnchor].active = YES;
        [_cancelBtn.bottomAnchor constraintEqualToAnchor:_imagePickerView.bottomAnchor constant:-15].active = YES;
        [_cancelBtn.heightAnchor constraintEqualToConstant:30].active = YES;
        
        [_separator2.widthAnchor constraintEqualToAnchor:_imagePickerView.widthAnchor constant:-20].active = YES;
        [_separator2.bottomAnchor constraintGreaterThanOrEqualToAnchor:_cancelBtn.topAnchor constant:-10].active = YES;
        [_separator2.centerXAnchor constraintEqualToAnchor:_imagePickerView.centerXAnchor].active = YES;
        [_separator2.heightAnchor constraintEqualToConstant:1].active = YES;
        
        [_photoLibraryBtn.widthAnchor constraintEqualToAnchor:_imagePickerView.widthAnchor constant:-20].active = YES;
        [_photoLibraryBtn.centerXAnchor constraintEqualToAnchor:_imagePickerView.centerXAnchor].active = YES;
        [_photoLibraryBtn.heightAnchor constraintEqualToConstant:30].active = YES;
        [_photoLibraryBtn.bottomAnchor constraintEqualToAnchor:_separator2.topAnchor constant:-10].active = YES;
        
        [_separator3.widthAnchor constraintEqualToAnchor:_imagePickerView.widthAnchor constant:-20].active = YES;
        [_separator3.centerXAnchor constraintEqualToAnchor:_imagePickerView.centerXAnchor].active = YES;
        [_separator3.bottomAnchor constraintEqualToAnchor:_photoLibraryBtn.topAnchor constant: -10].active = YES;
        [_separator3.heightAnchor constraintEqualToConstant:1].active = YES;
        
        if (_haveCamera) {
            [_cameraBtn.widthAnchor constraintEqualToAnchor:_imagePickerView.widthAnchor constant:-20].active = YES;
            [_cameraBtn.centerXAnchor constraintEqualToAnchor:_imagePickerView.centerXAnchor].active = YES;
            [_cameraBtn.heightAnchor constraintEqualToConstant:30].active = YES;
            [_cameraBtn.bottomAnchor constraintEqualToAnchor:_separator3.topAnchor constant:-10].active = YES;
            
            [_separator1.widthAnchor constraintEqualToAnchor:_imagePickerView.widthAnchor constant:-20].active = YES;
            [_separator1.centerXAnchor constraintEqualToAnchor:_imagePickerView.centerXAnchor].active = YES;
            [_separator1.bottomAnchor constraintEqualToAnchor:_cameraBtn.topAnchor constant: -10].active = YES;
            [_separator1.heightAnchor constraintEqualToConstant:1].active = YES;
        }
        
        
//        [_separator3.widthAnchor constraintEqualToAnchor:_imagePickerView.widthAnchor constant:-20].active = YES;
//        [_separator3.bottomAnchor constraintEqualToAnchor:_cancelBtn.bottomAnchor constant:10].active = YES;
//        [_separator3.centerXAnchor constraintEqualToAnchor:_separator3.centerXAnchor].active = YES;
//        [_separator3.heightAnchor constraintEqualToConstant:1].active = YES;
//
//        [_photoLibraryBtn.leadingAnchor constraintEqualToAnchor:_photoLibraryBtn.superview.leadingAnchor constant: 10].active = YES;
//        [_photoLibraryBtn.trailingAnchor constraintEqualToAnchor:_photoLibraryBtn.superview.trailingAnchor constant: 10].active = YES;
//        [_photoLibraryBtn.centerXAnchor constraintEqualToAnchor:_photoLibraryBtn.superview.centerXAnchor].active = YES;
//        [_photoLibraryBtn.heightAnchor constraintEqualToConstant:30].active = YES;
//        [_photoLibraryBtn.bottomAnchor constraintEqualToAnchor:_separator3.topAnchor constant:10].active = YES;
//

//
//        if (_haveCamera) {
//            [_cameraBtn.leadingAnchor constraintEqualToAnchor:_cameraBtn.superview.leadingAnchor constant: 10].active = YES;
//            [_cameraBtn.trailingAnchor constraintEqualToAnchor:_cameraBtn.superview.trailingAnchor constant: 10].active = YES;
//            [_cameraBtn.centerXAnchor constraintEqualToAnchor:_cameraBtn.superview.centerXAnchor].active = YES;
//            [_cameraBtn.heightAnchor constraintEqualToConstant:30].active = YES;
//            [_cameraBtn.bottomAnchor constraintEqualToAnchor:_separator2.topAnchor constant:-10].active = YES;
//
//            [_separator1.leadingAnchor constraintEqualToAnchor:_separator1.superview.leadingAnchor constant: 10].active = YES;
//            [_separator1.trailingAnchor constraintEqualToAnchor:_separator1.superview.trailingAnchor constant: 10].active = YES;
//            [_separator1.bottomAnchor constraintEqualToAnchor:_cameraBtn.topAnchor constant:10].active = YES;
//            [_separator1.centerXAnchor constraintEqualToAnchor: _separator1.superview.centerXAnchor].active = YES;
//            [_separator1.heightAnchor constraintEqualToConstant:1].active = YES;
//
//        }
//
//        [_collectionView.leadingAnchor constraintEqualToAnchor:_collectionView.superview.leadingAnchor].active = YES;
//        [_collectionView.trailingAnchor constraintEqualToAnchor:_collectionView.superview.trailingAnchor].active = YES;
//        [_collectionView.centerXAnchor constraintEqualToAnchor:_collectionView.superview.centerXAnchor].active = YES;
//
//        if (_haveCamera) {
//            [_collectionView.bottomAnchor constraintEqualToAnchor:_separator1.topAnchor constant:-15].active = YES;
//        }
//        else {
//            [_collectionView.bottomAnchor constraintEqualToAnchor:_separator2.topAnchor constant:-15].active = YES;
//        }
//
//        [_collectionView.topAnchor constraintEqualToAnchor:_collectionView.superview.topAnchor constant:10].active = YES;
        
    }
    [super updateViewConstraints];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if ([AVCaptureDevice respondsToSelector:@selector(requestAccessForMediaType: completionHandler:)]) {
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            // Will get here on both iOS 7 & 8 even though camera permissions weren't required
            // until iOS 8. So for iOS 7 permission will always be granted.
            if (granted) {
                // Permission has been granted. Use dispatch_async for any UI updating
                // code because this block may be executed in a thread.
                
            } else {
                // Permission has been denied.
            }
        }];
    }
    
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    
    if (@available(iOS 14, *)) {
        if (status == PHAuthorizationStatusLimited || status == PHAuthorizationStatusAuthorized) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self getCameraRollImages];
            });
            return;
        }
    } else {
        if (status == PHAuthorizationStatusAuthorized) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self getCameraRollImages];
            });
            return;
        }
    }
    
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        switch (status) {
            case PHAuthorizationStatusNotDetermined:
            case PHAuthorizationStatusRestricted:
            case PHAuthorizationStatusDenied: {

                break;
            }
            case PHAuthorizationStatusLimited:
            case PHAuthorizationStatusAuthorized: {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self getCameraRollImages];
                });
            }
        }
    }];
}

#pragma mark - Collection view

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return MIN(20, _assets.count);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PNCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[PNCollectionViewCell cellIdentifier] forIndexPath:indexPath];
    
    PHAsset *asset = _assets[_assets.count-1 - indexPath.row];
    
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    options.networkAccessAllowed = YES;
    options.progressHandler = ^(double progress, NSError *error, BOOL *stop, NSDictionary *info) {
        /*
         Progress callbacks may not be on the main thread. Since we're updating
         the UI, dispatch to the main queue.
         */
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([self->delegate respondsToSelector:@selector(imagePicker:downloadImageWithProgress:)]) {
                [self->delegate imagePicker:self downloadImageWithProgress:progress];
            }
        });
    };
    
    [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:CGSizeMake(300, 300) contentMode:PHImageContentModeAspectFit options:options resultHandler:^(UIImage *result, NSDictionary *info) {
        // Check if the request was successful.
        if (!result) {
            return;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [cell setPhotoImage:result];
            [cell setNeedsUpdateConstraints];
        });
    }];
    
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    
    PHAsset *asset = _assets[_assets.count-1 - indexPath.row];
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    options.networkAccessAllowed = YES;
    options.progressHandler = ^(double progress, NSError *error, BOOL *stop, NSDictionary *info) {
        /*
         Progress callbacks may not be on the main thread. Since we're updating
         the UI, dispatch to the main queue.
         */
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([self->delegate respondsToSelector:@selector(imagePicker:downloadImageWithProgress:)]) {
                [self->delegate imagePicker:self downloadImageWithProgress:progress];
            }
        });
    };
    
    [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:_targetSize contentMode:PHImageContentModeAspectFit options:options resultHandler:^(UIImage *result, NSDictionary *info) {
        // Hide the progress view now the request has completed.
        
        // Check if the request was successful.
        if (!result) {
            return;
        }
        
        // Show the UIImageView and use it to display the requested image.
        if (self->_enableEditMode) {
            CLImageEditor *editor = [[CLImageEditor alloc] initWithImage:result];
            editor.delegate = self;
            editor.theme.toolbarColor = [@"f3f2f2" colorFromHex];
            if (@available(iOS 13.0, *)) {
                [editor setModalInPresentation:YES];
            }
            
            [self presentViewController:editor animated:YES completion:nil];
        }
        else {
            if ([self->delegate respondsToSelector:@selector(imagePicker:didSelectImage:)]) {
                [self->delegate imagePicker:self didSelectImage:result];
            }
            
            [self dismissAnimated:YES];
        }
    }];
    
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(180, 120);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0.0f;
}

#pragma mark - Image library


- (void)getCameraRollImages {
    if ([delegate respondsToSelector:@selector(imagePickerWillStartEnumeratingPhotos:)]) {
        [delegate imagePickerWillStartEnumeratingPhotos: ^{
            [self actualGetCameraRollImages];
        }];
        return;
    }
    
    [self actualGetCameraRollImages];
}

- (void)actualGetCameraRollImages {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self->_assets removeAllObjects];
        
        PHFetchOptions *allPhotosOptions = [PHFetchOptions new];
        allPhotosOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
        //[allPhotosOptions setFetchLimit:20];
        
        PHFetchResult *allPhotosResult = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:allPhotosOptions];
        [allPhotosResult enumerateObjectsUsingBlock:^(PHAsset *asset, NSUInteger idx, BOOL *stop) {
            if (asset) {
                [self->_assets addObject:asset];
            }
        }];
        [self->_collectionView reloadData];
    });
}

#pragma mark - Image picker

- (void)takePhotoWasPressed {
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        
        UIAlertController* noCameraAlert = [UIAlertController alertControllerWithTitle:@"Error"
                                   message:@"Device has no camera"
                                   preferredStyle:UIAlertControllerStyleAlert];

        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                       handler:^(UIAlertAction * action) {}];

        [noCameraAlert addAction:defaultAction];
        
        [self presentViewController:noCameraAlert animated:YES completion:nil];
        
    } else {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        picker.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *) kUTTypeImage, nil];
        
        [self presentViewController:picker animated:YES completion:^{
            
        }];
    }
}

- (void)selectFromLibraryWasPressed {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *) kUTTypeImage, nil];
    
    [self presentViewController:picker animated:YES completion:^{
        
    }];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *chosenImage = info[UIImagePickerControllerOriginalImage];
    
    if (self->_enableEditMode) {
        [picker dismissViewControllerAnimated:YES completion:^{
            
            CLImageEditor *editor = [[CLImageEditor alloc] initWithImage:chosenImage];
            editor.delegate = self;
            editor.theme.toolbarColor = [@"f3f2f2" colorFromHex];
            if (@available(iOS 13.0, *)) {
                [editor setModalInPresentation:YES];
            }
            
            [self presentViewController:editor animated:YES completion:nil];
        }];
    }
    else {
        [self dismissAnimated:YES];
        [picker dismissViewControllerAnimated:YES completion:^{
            if ([self->delegate respondsToSelector:@selector(imagePicker:didSelectImage:)]) {
                [self->delegate imagePicker:self didSelectImage:chosenImage];
            }
        }];
    }
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:^{
        [self showImagePickerInController:self->_targetController];
    }];
}

#pragma mark - Show

- (void)showImagePickerInController:(UIViewController *)controller {
    [self showImagePickerInController:controller animated:YES];
}

- (void)showImagePickerInController:(UIViewController *)controller animated:(BOOL)animated {
    if (_isVisible != YES) {
        _targetController = controller;
        
        if ([delegate respondsToSelector:@selector(imagePickerWillOpen)]) {
            [delegate imagePickerWillOpen];
        }
        _isVisible = YES;
        
        [self setTransitioningDelegate:transitionController];
        self.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        
        [_targetController presentViewController:self animated:NO completion:^{
            
            [self->_hideConstraint setConstant:0];
            [self->_imagePickerView setNeedsUpdateConstraints];
            
            if (animated) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [UIView animateWithDuration:self->_animationTime
                                          delay:0.0
                         usingSpringWithDamping:1
                          initialSpringVelocity:0
                                        options:0
                                     animations:^{
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self.view layoutIfNeeded];
                            [self->_backgroundView setAlpha:1];
                            
                            [self->_imagePickerView layoutIfNeeded];
                        });
                    } completion:^(BOOL finished) {
                        if ([self->delegate respondsToSelector:@selector(imagePickerDidOpen)]) {
                            [self->delegate imagePickerDidOpen];
                        }
                    }];
                });
                
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self->_backgroundView setAlpha:1];
                    
                    [self->_imagePickerView layoutIfNeeded];
                });
                
                if ([self->delegate respondsToSelector:@selector(imagePickerDidOpen)]) {
                    [self->delegate imagePickerDidOpen];
                }
            }
        }];
    }
}

#pragma mark - Dismiss

- (void)cancel {
    if ([delegate respondsToSelector:@selector(imagePickerDidCancel)]) {
        [delegate imagePickerDidCancel];
    }
    
    [self dismiss];
}

- (void)dismiss {
    [self dismissAnimated:YES];
}

- (void)dismissAnimated:(BOOL)animated {
    if (_isVisible == YES) {
        if ([delegate respondsToSelector:@selector(imagePickerWillClose)]) {
            [delegate imagePickerWillClose];
        }
        
        [_hideConstraint setConstant:-imagePickerHeight];
        [_imagePickerView setNeedsUpdateConstraints];
        
        if (animated) {
            
            [UIView animateWithDuration:_animationTime
                                  delay:0.0
                 usingSpringWithDamping:1
                  initialSpringVelocity:0
                                options:0
                             animations:^{
                                 [self.view layoutIfNeeded];
                                 [self->_backgroundView setAlpha:0];
                                 
                                 [self->_imagePickerView layoutIfNeeded];
                             }
                             completion:^(BOOL finished) {
                                 [self dismissViewControllerAnimated:YES completion:^{
                                     if ([self->delegate respondsToSelector:@selector(imagePickerDidClose)]) {
                                         [self->delegate imagePickerDidClose];
                                     }
                                 }];
                             }];
        } else {
            
            [_backgroundView setAlpha:0];
            
            [_imagePickerView layoutIfNeeded];
            
            [self dismissViewControllerAnimated:NO completion:^{
                if ([self->delegate respondsToSelector:@selector(imagePickerDidClose)]) {
                    [self->delegate imagePickerDidClose];
                }
            }];
        }
        _isVisible = NO;
    }
}

#pragma mark- CLImageEditor delegate

- (void)imageEditor:(CLImageEditor*)editor didFinishEditingWithImage:(UIImage*)image
{
    [self dismissAnimated:YES];
    [editor dismissViewControllerAnimated:YES completion:^{
        if ([self->delegate respondsToSelector:@selector(imagePicker:didSelectImage:)]) {
            [self->delegate imagePicker:self didSelectImage:image];
        }
    }];
}

@end



#pragma mark - TransitionDelegate -
@implementation TransitionDelegate

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    AnimatedTransitioning *controller = [[AnimatedTransitioning alloc] init];
    controller.isPresenting = YES;
    return controller;
}

@end




#pragma mark - AnimatedTransitioning -
@implementation AnimatedTransitioning

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext {
    return 0.25f;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    UIView *inView = [transitionContext containerView];
    UIViewController *toVC = (UIViewController *)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIViewController *fromVC = (UIViewController *)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    [inView addSubview:toVC.view];
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    [toVC.view setFrame:CGRectMake(0, screenRect.size.height, fromVC.view.frame.size.width, fromVC.view.frame.size.height)];
    
    [UIView animateWithDuration:0.25f
                     animations:^{
                         [toVC.view setFrame:CGRectMake(0, 0, fromVC.view.frame.size.width, fromVC.view.frame.size.height)];
                     }
                     completion:^(BOOL finished) {
                         [transitionContext completeTransition:YES];
                     }];
}


@end
