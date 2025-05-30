//
//  WKReactionsCell.m
//  WuKongAdvanced
//
//  Created by tt on 2022/8/9.
//

#import "WKReactionsCell.h"
#import "WKReactionsUtil.h"
@interface WKReactionsCell ()

@property(nonatomic,strong) WKUserAvatar *avatar;
@property(nonatomic,strong) UILabel *nameLbl;

@property(nonatomic,strong) UIImageView *emojiImgView;

@end

@implementation WKReactionsCell

- (void)setupUI {
    [super setupUI];
    
    [self.contentView addSubview:self.avatar];
    [self.contentView addSubview:self.nameLbl];
    
    [self.contentView addSubview:self.emojiImgView];
    
}

- (void)refresh:(WKReactionsCellModel *)model {
    [super refresh:model];
    WKReaction *reaction = model.reaction;
    
    self.nameLbl.text = [self getDisplayName:reaction];
    
    self.avatar.url = [WKAvatarUtil getAvatar:reaction.uid];
    
    [self.emojiImgView sd_setImageWithURL:[NSURL URLWithString:[WKReactionsUtil getReactionIconURL:reaction.emoji]]];
}

-(NSString*) getDisplayName:(WKReaction*)reaction {
    WKChannelInfo *channelInfo = [WKSDK.shared.channelManager getChannelInfoOfUser:reaction.uid];
    if(channelInfo && channelInfo.remark && ![channelInfo.remark isEqualToString:@""]) {
        return channelInfo.remark;
    }
    if(reaction.channel && reaction.channel.channelType == WK_GROUP) {
       WKChannelMember *channelMember = [WKSDK.shared.channelManager getMember:reaction.channel uid:reaction.uid];
        if(channelMember) {
            return channelMember.displayName;
        }
    }
    if(channelInfo) {
        return channelInfo.displayName;
    }
    return @"";
   
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.avatar.lim_centerY_parent = self.contentView;
    self.avatar.lim_left = 15.0f;
    
    self.emojiImgView.lim_centerY_parent = self.contentView;
    self.emojiImgView.lim_left = self.contentView.lim_width - self.emojiImgView.lim_width - 15.0f;
    
    self.nameLbl.lim_left = self.avatar.lim_right + 15.0f;
    self.nameLbl.lim_width =  self.emojiImgView.lim_left - self.nameLbl.lim_left - 15.0f;
    self.nameLbl.lim_height = self.contentView.lim_height;
}

- (WKUserAvatar *)avatar {
    if(!_avatar) {
        _avatar = [[WKUserAvatar alloc] init];
    }
    return _avatar;
}

- (UILabel *)nameLbl {
    if(!_nameLbl) {
        _nameLbl = [[UILabel alloc] init];
        _nameLbl.font = [WKApp shared].config.defaultFont;
        _nameLbl.lineBreakMode = NSLineBreakByTruncatingTail;
    }
    return _nameLbl;
}

- (UIImageView *)emojiImgView {
    if(!_emojiImgView) {
        _emojiImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 28.0f, 28.0f)];
    }
    return _emojiImgView;
}

@end


@implementation WKReactionsCellModel

- (CGFloat)cellHeight {
    return 80.0f;
}

- (Class)cell {
    return WKReactionsCell.class;
}

@end
