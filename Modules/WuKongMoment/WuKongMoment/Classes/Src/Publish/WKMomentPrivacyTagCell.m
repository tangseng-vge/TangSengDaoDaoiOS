//
//  WKMomentPrivacyTagCell.m
//  WuKongMoment
//
//  Created by tt on 2022/11/29.
//

#import "WKMomentPrivacyTagCell.h"

@implementation WKMomentPrivacyTagModel

- (Class)cell {
    return WKMomentPrivacyTagCell.class;
}

- (CGFloat)cellHeight {
    return 60.0f;
}

@end

@interface WKMomentPrivacyTagCell ()<WKCheckBoxDelegate>

@property(nonatomic,strong) WKCheckBox *checkBox;

@property(nonatomic,strong) UILabel *titleLbl;

@property(nonatomic,strong) UILabel *contentLbl;

@property(nonatomic,strong) UIButton *settingBtn;

@property(nonatomic,strong) WKMomentPrivacyTagModel *momentPrivacyTagModel;

@end

@implementation WKMomentPrivacyTagCell

- (void)setupUI {
    [super setupUI];
    
    [self.contentView addSubview:self.checkBox];
    [self.contentView addSubview:self.titleLbl];
    [self.contentView addSubview:self.contentLbl];
    [self.contentView addSubview:self.settingBtn];
    
}

- (void)refresh:(WKMomentPrivacyTagModel *)model {
    [super refresh:model];
    
    self.momentPrivacyTagModel = model;
    
    self.titleLbl.text = model.title;
    
    self.contentLbl.text = model.content;
    
    self.checkBox.on = model.checked;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.checkBox.lim_left = 45.0f;
    self.checkBox.lim_centerY_parent = self.contentView;
    
    self.settingBtn.lim_left = self.contentView.lim_width - self.settingBtn.lim_width - 15.0f;
    self.settingBtn.lim_centerY_parent = self.contentView;
    
    CGFloat titleLeftSpace = 15.0f;
    self.titleLbl.lim_width = self.settingBtn.lim_left - (self.checkBox.lim_right + titleLeftSpace) - titleLeftSpace;
    self.titleLbl.lim_height = 16.0f;
    self.titleLbl.lim_left = self.checkBox.lim_right + titleLeftSpace;
    
    self.contentLbl.lim_width = self.titleLbl.lim_width;
    self.contentLbl.lim_height = 14.0f;
    
    CGFloat contentTopSpace = 5.0f;
    
    CGFloat contentHeight = self.titleLbl.lim_height + contentTopSpace + self.contentLbl.lim_height;
    
    self.titleLbl.lim_top = self.lim_height/2.0f - contentHeight/2.0f;
    self.contentLbl.lim_top = self.titleLbl.lim_bottom + contentTopSpace;
    self.contentLbl.lim_left = self.titleLbl.lim_left;
}

- (WKCheckBox *)checkBox {
    if(!_checkBox) {
        _checkBox = [[WKCheckBox alloc] initWithFrame:CGRectMake(0, 0, 24.0f, 24.0f)];
        _checkBox.onFillColor = [WKApp shared].config.themeColor;
        _checkBox.onCheckColor = [UIColor whiteColor];
        _checkBox.onAnimationType = BEMAnimationTypeBounce;
        _checkBox.offAnimationType = BEMAnimationTypeBounce;
//        _checkBox.animationDuration = 0.0f;
        _checkBox.lineWidth = 1.0f;
        _checkBox.delegate = self;
    }
    return _checkBox;
}

- (UILabel *)titleLbl {
    if(!_titleLbl) {
        _titleLbl = [[UILabel alloc] init];
        _titleLbl.font = [WKApp.shared.config appFontOfSize:16.0f];
        _titleLbl.lineBreakMode = NSLineBreakByTruncatingTail;
    }
    return _titleLbl;
}
- (UILabel *)contentLbl {
    if(!_contentLbl) {
        _contentLbl = [[UILabel alloc] init];
        _contentLbl.font = [WKApp.shared.config appFontOfSize:13.0f];
        _contentLbl.textColor = WKApp.shared.config.tipColor;
        _contentLbl.lineBreakMode = NSLineBreakByTruncatingTail;
    }
    return _contentLbl;
}

- (UIButton *)settingBtn {
    if(!_settingBtn) {
        _settingBtn = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 20.0f, 20.0f)];
        UIImage *img = LImage(@"Setting");
        img = [img imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [_settingBtn setImage:img forState:UIControlStateNormal];
        [_settingBtn setTintColor:WKApp.shared.config.tipColor];
        [_settingBtn addTarget:self action:@selector(settingPressed) forControlEvents:UIControlEventTouchUpInside];
    }
    return _settingBtn;
}

-(void) settingPressed {
    if(self.momentPrivacyTagModel.onMore) {
        self.momentPrivacyTagModel.onMore();
    }
}

#pragma mark --- WKCheckBoxDelegate

- (void)didTapCheckBox:(WKCheckBox *)checkBox {
    if(self.momentPrivacyTagModel.onCheck) {
        self.momentPrivacyTagModel.onCheck(checkBox.on);
    }
}


@end
