//
//  WKUserMomentCell.m
//  WuKongMoment
//
//  Created by tt on 2020/11/30.
//

#import "WKUserMomentCell.h"

@implementation WKUserMomentModel

- (Class)cell {
    return WKUserMomentCell.class;
}

@end

@interface WKUserMomentCell ()


@end

#define imgSize 48.0f
@implementation WKUserMomentCell

+ (CGSize)sizeForModel:(WKFormItemModel *)model {
    return CGSizeMake(WKScreenWidth, imgSize+20.0f);
}

- (void)setupUI {
    [super setupUI];
}

- (void)refresh:(WKUserMomentModel *)model {
    [super refresh:model];
    [[self.valueView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    if(model.imgs && model.imgs.count>0) {
        NSInteger i= 0 ;
        for (NSString *imgURL in model.imgs) {
            if(i>3) {
                break;
            }
            [self.valueView addSubview: [self newImgView:imgURL]];
            i++;
        }
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.valueView.lim_left = self.labelLbl.lim_right + 30.0f;
    NSArray *subviews = self.valueView.subviews;
    CGFloat space = 5.0f;
    if(subviews && subviews.count>0) {
        NSInteger i = 0;
        for (UIView *subview in subviews) {
            subview.lim_centerY_parent = self.contentView;
            subview.lim_left = i * imgSize + i *space;
            i++;
        }
    }
}

-(UIImageView*) newImgView:(NSString*)imgURL {
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, imgSize, imgSize)];
//    imgView.layer.cornerRadius = 4.0f;
//    imgView.layer.masksToBounds = YES;
    imgView.clipsToBounds = YES;
    imgView.contentMode = UIViewContentModeScaleAspectFill;
    [imgView lim_setImageWithURL:[[WKApp shared] getImageFullUrl:imgURL] placeholderImage:[WKApp shared].config.defaultPlaceholder];
    return imgView;
}

@end
