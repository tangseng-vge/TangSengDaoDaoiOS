//
//  WKMomentPrivacySecondCell.m
//  WuKongMoment
//
//  Created by tt on 2020/11/19.
//

#import "WKMomentPrivacySecondCell.h"

@implementation WKMomentPrivacySecondModel

- (Class)cell {
    return WKMomentPrivacySecondCell.class;
}

- (NSNumber *)showArrow {
    return @(NO);
}

@end

@interface WKMomentPrivacySecondCell ()

@property(nonatomic,strong) UILabel *titleLbl;
@property(nonatomic,strong) UILabel *subtitleLbl;

@property(nonatomic,strong) WKMomentPrivacySecondModel *model;
@end

@implementation WKMomentPrivacySecondCell

- (void)setupUI {
    [super setupUI];
    [self.contentView addSubview:self.titleLbl];
    [self.contentView addSubview:self.subtitleLbl];
}

- (void)refresh:(WKMomentPrivacySecondModel *)model {
    [super refresh:model];
    self.model = model;
    self.titleLbl.text = model.title;
    [self.titleLbl sizeToFit];
    
    self.subtitleLbl.hidden = YES;
    if(model.subtitle && ![model.subtitle isEqualToString:@""]) {
        self.subtitleLbl.hidden = NO;
        self.subtitleLbl.text = model.subtitle;
    }
    
}

#define leftSpace 80.0f

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.titleLbl.lim_left =leftSpace;
    self.titleLbl.lim_centerY_parent = self.contentView;
    
    self.subtitleLbl.lim_left = leftSpace;
    self.subtitleLbl.lim_width = self.contentView.lim_width - leftSpace -15.0f;
    self.subtitleLbl.lim_height = 14.0f;
    
    if(self.model.subtitle && ![self.model.subtitle isEqualToString:@""]) {
        CGFloat subtitleTopSpace = 4.0f;
        self.titleLbl.lim_top = self.lim_height/2.0f - (self.titleLbl.lim_height + self.subtitleLbl.lim_height + subtitleTopSpace)/2.0f;
        self.subtitleLbl.lim_top = self.titleLbl.lim_bottom + subtitleTopSpace;
    }
}


- (UILabel *)titleLbl {
    if(!_titleLbl) {
        _titleLbl = [[UILabel alloc] init];
        _titleLbl.textColor = [WKApp shared].config.themeColor;
        _titleLbl.font = [[WKApp shared].config appFontOfSize:16.0f];
    }
    return _titleLbl;
}

- (UILabel *)subtitleLbl {
    if(!_subtitleLbl) {
        _subtitleLbl = [[UILabel alloc] init];
        _subtitleLbl.textColor = [UIColor colorWithRed:87.0f/255.0f green:189.0f/255.0f blue:106.0f/255.0f alpha:1.0f];
        _subtitleLbl.font = [[WKApp shared].config appFontOfSize:13.0f];
        _subtitleLbl.numberOfLines = 1;
        _subtitleLbl.lineBreakMode = NSLineBreakByTruncatingTail;
    }
    return _subtitleLbl;
}

@end
