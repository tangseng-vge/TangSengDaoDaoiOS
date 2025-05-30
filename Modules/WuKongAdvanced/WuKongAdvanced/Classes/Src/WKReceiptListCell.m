//
//  WKReceiptListCell.m
//  WuKongBase
//
//  Created by tt on 2021/4/10.
//

#import "WKReceiptListCell.h"

@interface WKReceiptListCell ()



@end

@implementation WKReceiptListCell

- (void)setupUI {
    [super setupUI];
    
    [self.contentView addSubview:self.avatarImgView];
    [self.contentView addSubview:self.nameLbl];
}

- (void)refresh:(id)cellModel {
    [super refresh:cellModel];
    
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.avatarImgView.lim_centerY_parent = self.contentView;
    self.avatarImgView.lim_left = 15.0f;
    self.avatarImgView.layer.masksToBounds = YES;
    self.avatarImgView.layer.cornerRadius = self.avatarImgView.lim_height/2.0f;
    
    self.nameLbl.lim_left = self.avatarImgView.lim_right + 10.0f;
    self.nameLbl.lim_centerY_parent = self.contentView;
}

- (UIImageView *)avatarImgView {
    if(!_avatarImgView) {
        _avatarImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, [WKApp shared].config.messageListAvatarSize.width, [WKApp shared].config.messageListAvatarSize.height)];
    }
    return _avatarImgView;
}

- (UILabel *)nameLbl {
    if(!_nameLbl) {
        _nameLbl = [[UILabel alloc] init];
    }
    return _nameLbl;
}
@end
