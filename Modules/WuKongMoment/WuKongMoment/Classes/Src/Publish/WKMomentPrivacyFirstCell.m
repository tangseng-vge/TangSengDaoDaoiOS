//
//  WKMomentPrivacyFirstCell.m
//  WuKongMoment
//
//  Created by tt on 2020/11/13.
//

#import "WKMomentPrivacyFirstCell.h"
#import "WKMomentModule.h"

@implementation WKMomentPrivacyFirstModel

- (Class)cell {
    return WKMomentPrivacyFirstCell.class;
}

- (NSNumber *)showArrow {
    return @(NO);
}

@end

@interface WKMomentPrivacyFirstCell ()

@property(nonatomic,strong) UIImageView *checkImgVIew;
@property(nonatomic,strong) UILabel *titleLbl;
@property(nonatomic,strong) UILabel *subtitleLbl;
@property(nonatomic,strong) UIImageView *unfoldImgVIew;
@end

@implementation WKMomentPrivacyFirstCell

+ (CGSize)sizeForModel:(WKFormItemModel *)model {
    return CGSizeMake(WKScreenWidth, 70.0f);
}

- (void)setupUI {
    [super setupUI];
    [self.contentView addSubview:self.checkImgVIew];
    [self.contentView addSubview:self.titleLbl];
    [self.contentView addSubview:self.subtitleLbl];
    
    [self.contentView addSubview:self.unfoldImgVIew];
}

- (void)refresh:(WKMomentPrivacyFirstModel *)model {
    [super refresh:model];
    
    self.titleLbl.text = model.title;
    [self.titleLbl sizeToFit];
    
    self.subtitleLbl.text = model.subtitle;
    [self.subtitleLbl sizeToFit];
    
    self.checkImgVIew.hidden = !model.checked;
    
    self.unfoldImgVIew.hidden = !model.canUnfold;
    if(model.checked) {
        self.unfoldImgVIew.image = [self imageName:@"Closeup"];
    }else{
        self.unfoldImgVIew.image = [self imageName:@"Unfold"];
    }
    
    if(model.ticketRed) {
        self.checkImgVIew.image = [self imageName:@"TickRed"];
    }else{
        self.checkImgVIew.image = [self imageName:@"Tick"];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat subtitleTopSpace =2.0f;
    CGFloat leftSpace = 40.0f;
    
    self.checkImgVIew.lim_left = leftSpace/2.0f - self.checkImgVIew.lim_width/2.0f;
    self.checkImgVIew.lim_centerY_parent = self.contentView;
    
    self.titleLbl.lim_top = self.contentView.lim_height/2.0f - (self.titleLbl.lim_height +  subtitleTopSpace + self.subtitleLbl.lim_height)/2.0f;
    self.titleLbl.lim_left = leftSpace;
    
    self.subtitleLbl.lim_top = self.titleLbl.lim_bottom + 4.0f;
    self.subtitleLbl.lim_left = self.titleLbl.lim_left;
    
    self.unfoldImgVIew.lim_centerY_parent = self.contentView;
    self.unfoldImgVIew.lim_left = self.lim_width - self.unfoldImgVIew.lim_width - 15.0f;
    
}

- (UILabel *)titleLbl {
    if(!_titleLbl) {
        _titleLbl = [[UILabel alloc] init];
        _titleLbl.font = [[WKApp shared].config appFontOfSizeMedium:16.0f];
    }
    return _titleLbl;
}

- (UILabel *)subtitleLbl {
    if(!_subtitleLbl) {
        _subtitleLbl = [[UILabel alloc] init];
        _subtitleLbl.font = [[WKApp shared].config appFontOfSize:13.0f];
        _subtitleLbl.textColor = [WKApp shared].config.tipColor;
    }
    return _subtitleLbl;
}


- (UIImageView *)checkImgVIew {
    if(!_checkImgVIew) {
        _checkImgVIew = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 14.0f, 14.0f)];
    }
    return _checkImgVIew;
}
- (UIImageView *)unfoldImgVIew {
    if(!_unfoldImgVIew) {
        _unfoldImgVIew = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 16.0f, 16.0f)];
    }
    return _unfoldImgVIew;
}


- (UIImage*) imageName:(NSString*)name {
    return [[WKApp shared] loadImage:name moduleID:[WKMomentModule gmoduleId]];
}

@end
