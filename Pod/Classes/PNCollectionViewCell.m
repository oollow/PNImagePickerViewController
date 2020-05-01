//
//  PNCollectionViewCell.m
//  Pods
//
//  Created by Giuseppe Nucifora on 09/02/16.
//
//

#import "PNCollectionViewCell.h"
#import <DGActivityIndicatorView/DGActivityIndicatorView.h>

@interface PNCollectionViewCell()

@property (nonatomic, strong) UIImageView *photoImageView;
@property (nonatomic, strong) DGActivityIndicatorView *loadingSpinner;

@end

@implementation PNCollectionViewCell

+ (NSString *)cellIdentifier {
    return [NSStringFromClass([self class]) stringByAppendingString:@"Identifier"];
}

- (instancetype) initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self.contentView setTranslatesAutoresizingMaskIntoConstraints:NO];

        _photoImageView = [UIImageView new];
        _photoImageView.translatesAutoresizingMaskIntoConstraints = NO;
        [_photoImageView setContentMode:UIViewContentModeScaleAspectFill];
        [_photoImageView.layer setCornerRadius:4];
        [_photoImageView.layer setMasksToBounds:YES];

        [self.contentView addSubview:_photoImageView];

        _loadingSpinner = [[DGActivityIndicatorView alloc] initWithType:DGActivityIndicatorAnimationTypeBallClipRotate tintColor:[[UIColor lightGrayColor] colorWithAlphaComponent:0.7] size:35];
        [_loadingSpinner setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.contentView addSubview:_loadingSpinner];

        [_loadingSpinner startAnimating];
    }
    return self;
}

- (void) updateConstraints {

    [super updateConstraints];

    if (!self.didUpdateConstraints) {
        
        [self.contentView.topAnchor constraintEqualToAnchor:self.contentView.superview.topAnchor].active = YES;
        [self.contentView.trailingAnchor constraintEqualToAnchor:self.contentView.superview.trailingAnchor].active = YES;
        [self.contentView.leadingAnchor constraintEqualToAnchor:self.contentView.superview.leadingAnchor].active = YES;
        [self.contentView.bottomAnchor constraintEqualToAnchor:self.contentView.superview.bottomAnchor].active = YES;
        
        [_photoImageView.topAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:8].active = YES;
        [_photoImageView.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor constant:-8].active = YES;
        [_photoImageView.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:8].active = YES;
        [_photoImageView.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-8].active = YES;
        
        [_photoImageView.centerXAnchor constraintEqualToAnchor:self.contentView.centerXAnchor].active = YES;
        [_photoImageView.centerYAnchor constraintEqualToAnchor:self.contentView.centerYAnchor].active = YES;

        [_loadingSpinner.centerYAnchor constraintEqualToAnchor:self.contentView.centerYAnchor].active = YES;
        [_loadingSpinner.centerXAnchor constraintEqualToAnchor:self.contentView.centerXAnchor].active = YES;
        
        self.didUpdateConstraints = YES;
    }
}

- (void) setPhotoImage:(UIImage *)photoImage {
    if (photoImage) {
        [_photoImageView setImage:photoImage];
        [_loadingSpinner stopAnimating];
        [_loadingSpinner setAlpha:0];
    }
}

@end
