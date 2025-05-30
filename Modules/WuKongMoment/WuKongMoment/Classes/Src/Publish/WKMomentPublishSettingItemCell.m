//
//  WKMomentPublishSettingItemCell.m
//  WuKongMoment
//
//  Created by tt on 2020/11/12.
//

#import "WKMomentPublishSettingItemCell.h"
#import "WKMomentModule.h"
@implementation WKMomentPublishSettingItemModel

- (Class)cell {
    return WKMomentPublishSettingItemCell.class;
}


@end

@interface WKMomentPublishSettingItemCell ()

@property(nonatomic,strong) UIImageView *iconImgView;

@property(nonatomic,strong) UILabel *titleLbl;
@property(nonatomic,strong) UILabel *valueLbl;

@end

@implementation WKMomentPublishSettingItemCell


- (void)setupUI {
    [super setupUI];
    [self.contentView addSubview:self.iconImgView];
    [self.contentView addSubview:self.titleLbl];
    [self.contentView addSubview:self.valueLbl];
}
- (void)refresh:(WKMomentPublishSettingItemModel *)model {
    [super refresh:model];
    
    self.titleLbl.text = model.title;
    [self.titleLbl sizeToFit];
    
    UIImage *icon = [model.icon imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.iconImgView setImage:icon];
    if(model.color) {
        [self.iconImgView setTintColor:model.color];
        
        self.titleLbl.textColor = model.color;
        self.valueLbl.textColor = model.color;
    }
    
    
    self.valueLbl.text = model.value;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat leftSpace =20.0f;
    
    self.iconImgView.lim_left = leftSpace;
    self.iconImgView.lim_centerY_parent = self.contentView;
    
    self.titleLbl.lim_left = self.iconImgView.lim_right + leftSpace;
    self.titleLbl.lim_centerY_parent = self.contentView;
    
    self.arrowImgView.lim_left = self.lim_width - leftSpace - self.arrowImgView.lim_width;
    

   
    self.valueLbl.lim_width = self.arrowImgView.lim_left - self.titleLbl.lim_right - 20.0f;
    [self.valueLbl sizeToFit];
    self.valueLbl.lim_left = self.arrowImgView.lim_left - self.valueLbl.lim_width - 10.0f;
    self.valueLbl.lim_centerY_parent = self.contentView;
}


- (UILabel *)titleLbl {
    if(!_titleLbl) {
        _titleLbl = [[UILabel alloc] init];
        _titleLbl.font = [[WKApp shared].config appFontOfSize:15.0f];
        _titleLbl.textColor = [WKApp shared].config.defaultTextColor;
    }
    return _titleLbl;
}

- (UILabel *)valueLbl {
    if(!_valueLbl) {
        _valueLbl = [[UILabel alloc] init];
        _valueLbl.textColor =  [WKApp shared].config.defaultTextColor;
        _valueLbl.font = [[WKApp shared].config appFontOfSize:15.0f];
        _valueLbl.numberOfLines = 2;
        _valueLbl.lineBreakMode = NSLineBreakByWordWrapping;
    }
    return _valueLbl;
}

- (UIImageView *)iconImgView {
    if(!_iconImgView) {
        _iconImgView = [[UIImageView alloc] initWithFrame:CGRectMake(20.0f, 0.0f, 20.0f, 20.0f)];
    }
    return _iconImgView;
}

@end
