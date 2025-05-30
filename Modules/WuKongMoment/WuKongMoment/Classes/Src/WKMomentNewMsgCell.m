//
//  WKMomentNewMsgCell.m
//  WuKongMoment
//
//  Created by tt on 2020/11/6.
//

#import "WKMomentNewMsgCell.h"

@implementation WKMomentNewMsgModel


- (Class)cell {
    return WKMomentNewMsgCell.class;
}

- (NSNumber *)showArrow {
    return @(false);
}

@end

@interface WKMomentNewMsgCell ()

@property(nonatomic,strong) UIView *msgBox;
@property(nonatomic,strong) WKUserAvatar *lastMsgAvatarImgView;
@property(nonatomic,strong) UILabel *tipLbl;

@end

@implementation WKMomentNewMsgCell

+ (CGSize)sizeForModel:(WKMomentNewMsgModel *)model {
    CGFloat height = 30.0f;
    if(model.hasNewMsg) {
        height = 60.0f;
    }
    return CGSizeMake(WKScreenWidth, height);
}

- (void)setupUI {
    [super setupUI];
    
    [self.contentView addSubview:self.msgBox];
    
    [self.msgBox addSubview:self.lastMsgAvatarImgView];
    [self.msgBox addSubview:self.tipLbl];
    
}

- (void)refresh:(WKMomentNewMsgModel *)model {
    [super refresh:model];
    
    self.msgBox.hidden = YES;
    self.tipLbl.text = @"";
    if(model.hasNewMsg) {
        self.msgBox.hidden = NO;
        self.tipLbl.text = [NSString stringWithFormat:LLang(@"%ld条新消息"),(long)model.msgCount.integerValue];
        [self.tipLbl sizeToFit];
        self.lastMsgAvatarImgView.url = model.lastMsgAvatar;
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.msgBox.lim_centerY_parent = self.contentView;
    self.msgBox.lim_centerX_parent = self.contentView;
    
    self.lastMsgAvatarImgView.lim_centerY_parent = self.msgBox;
    self.lastMsgAvatarImgView.lim_left = 4.0f;
    
    self.tipLbl.lim_centerY_parent = self.msgBox;
    self.tipLbl.lim_left = self.msgBox.lim_width/2.0f - self.tipLbl.lim_width/2.0f + 10.0f;
}

- (UIView *)msgBox {
    if(!_msgBox) {
        _msgBox = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 160.0f, 36.0f)];
        _msgBox.backgroundColor = [UIColor colorWithWhite:0 alpha:0.8];
        _msgBox.layer.masksToBounds = YES;
        _msgBox.layer.cornerRadius = 4;
    }
    return _msgBox;
}

- (UILabel *)tipLbl {
    if(!_tipLbl) {
        _tipLbl = [[UILabel alloc] init];
        _tipLbl.textColor = [UIColor whiteColor];
        _tipLbl.font = [[WKApp shared].config appFontOfSize:15.0f];
    }
    return _tipLbl;
}

- (WKUserAvatar *)lastMsgAvatarImgView {
    if(!_lastMsgAvatarImgView) {
        _lastMsgAvatarImgView = [[WKUserAvatar alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 28.0f, 28.0f)];
        _lastMsgAvatarImgView.borderWidth = 2.0f;
    }
    return _lastMsgAvatarImgView;
}



@end
