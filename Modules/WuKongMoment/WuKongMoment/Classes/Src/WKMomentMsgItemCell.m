//
//  WKMomentMsgItemCell.m
//  WuKongMoment
//
//  Created by tt on 2020/11/16.
//

#import "WKMomentMsgItemCell.h"
#import "WKMomentConst.h"
#import <M80AttributedLabel/M80AttributedLabel.h>
#import "WKMomentCommentItemTextCell.h"
#import "WKMomentModule.h"
@implementation WKMomentMsgItemModel

- (Class)cell {
    return WKMomentMsgItemCell.class;
}
- (NSNumber *)showArrow {
    return @(false);
}
@end

@interface WKMomentMsgItemCell ()

@property(nonatomic,strong) UIImageView *avatarImgView;
@property(nonatomic,strong) UIImageView *likeImgView;
@property(nonatomic,strong) UILabel *nameLbl;
@property(nonatomic,strong) M80AttributedLabel *commentLbl;
@property(nonatomic,strong) UILabel *timeLbl;
@property(nonatomic,strong) UIImageView *contentImgView;
@property(nonatomic,strong) UILabel *contentLbl;
@property(nonatomic,strong) UIView *contentBoxView;

@property(nonatomic,strong) UIImageView *playIconImgView;

@property(nonatomic,strong) WKMomentMsgItemModel *model;

@end

#define conentBoxViewSize 60.0f
#define msgAvatarSize [WKApp shared].config.messageListAvatarSize.width
#define msgAvatarLeftSpace 15.0f
#define msgNameLeftSpace 15.0f
#define msgNameRightSpace 15.0f
#define msgContentBoxRightSpace 15.0f
@implementation WKMomentMsgItemCell

+ (CGSize)sizeForModel:(WKMomentMsgItemModel *)model {
    CGFloat commentHeight = 0.0f;
    CGFloat likeHeight = 0.0f;
    if([[self class] hasComment:model]) {
        commentHeight = [self getTextLabelSize:model.comment maxWidth:[self maxCommentTextWidth] fontSize:commentFontSize].height;
    }else{
        likeHeight = 16.0f;
    }
    return CGSizeMake(WKScreenWidth, conentBoxViewSize + 4.0f + commentHeight + likeHeight);
}

+(BOOL) hasComment:(WKMomentMsgItemModel*) model {
    if(model.comment && ![model.comment isEqualToString:@""]) {
        return true;
    }
    return false;
}

- (void)setupUI {
    [super setupUI];
    
    [self.contentView addSubview:self.avatarImgView];
    [self.contentView addSubview:self.likeImgView];
    [self.contentView addSubview:self.nameLbl];
    [self.contentView addSubview:self.commentLbl];
    [self.contentView addSubview:self.timeLbl];
    [self.contentView addSubview:self.contentBoxView];
    [self.contentView addSubview:self.playIconImgView];
}

- (void)refresh:(WKMomentMsgItemModel *)model {
    [super refresh:model];
    self.model = model;
    [self.avatarImgView lim_setImageWithURL:[NSURL URLWithString:[WKAvatarUtil getAvatar:model.uid]] placeholderImage:[WKApp shared].config.defaultAvatar];
    
    WKChannelInfo *channelInfo = [[WKSDK shared].channelManager getChannelInfo:[WKChannel personWithChannelID:model.uid]];
    if(channelInfo) {
        self.nameLbl.text = channelInfo.displayName;
    }else{
        self.nameLbl.text = model.name;
    }
    if(model.isDeleted) {
        self.commentLbl.textColor = WKApp.shared.config.tipColor;
    }else {
        self.commentLbl.textColor = WKApp.shared.config.defaultTextColor;
    }
   
    [[self class] fillLblContent:model.comment label:self.commentLbl];
    self.timeLbl.text = model.timeFormat;
    [self.timeLbl sizeToFit];
    
    [[self.contentBoxView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    if(model.firstImgURL && ![model.firstImgURL isEqualToString:@""]) {
        [self.contentBoxView addSubview:self.contentImgView];
        [self.contentImgView lim_setImageWithURL:[NSURL URLWithString:model.firstImgURL] placeholderImage:[WKApp shared].config.defaultPlaceholder];
    }else{
        self.contentLbl.text = model.content;
        [self.contentBoxView addSubview:self.contentLbl];
    }
    self.likeImgView.hidden = !model.like;
    
    self.playIconImgView.hidden = !model.isVideo;

}

+(CGFloat) maxCommentTextWidth {
    return WKScreenWidth - (msgAvatarLeftSpace + msgAvatarSize + msgNameLeftSpace + msgNameRightSpace + conentBoxViewSize + msgContentBoxRightSpace);
}


- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.avatarImgView.lim_centerY_parent = self.contentView;
    self.avatarImgView.lim_left = msgAvatarLeftSpace;
    
    CGFloat contentBoxRightSpace = msgContentBoxRightSpace;
    CGFloat nameRightSpace = msgNameRightSpace;
    self.nameLbl.lim_top = self.avatarImgView.lim_top - 2.0f;
    self.nameLbl.lim_left = self.avatarImgView.lim_right + msgNameLeftSpace;
    self.nameLbl.lim_height = 16.0f;
    self.nameLbl.lim_width = self.contentView.lim_width - self.nameLbl.lim_left - conentBoxViewSize - contentBoxRightSpace - nameRightSpace;
    
    CGFloat commentHeight = 0.0f;
    if([[self class] hasComment:self.model]) {
        commentHeight = [[self class] getTextLabelSize:self.model.comment maxWidth:[[self class] maxCommentTextWidth] fontSize:commentFontSize].height;
    }
    self.commentLbl.lim_top = self.nameLbl.lim_bottom + 5.0f;
    self.commentLbl.lim_left = self.nameLbl.lim_left;
    self.commentLbl.lim_height = commentHeight;
    
    self.likeImgView.lim_top = self.nameLbl.lim_bottom + 5.0f;
    self.likeImgView.lim_left = self.nameLbl.lim_left;
    
    CGFloat timeTopSpace = 0.0f;
    if(self.model.like) {
        timeTopSpace = self.likeImgView.lim_bottom + 5.0f;
    }else{
        timeTopSpace = self.commentLbl.lim_bottom + 5.0f;
    }
    
    self.timeLbl.lim_top = timeTopSpace;
    self.timeLbl.lim_left = self.nameLbl.lim_left;
    
    self.contentBoxView.lim_left = self.contentView.lim_width - self.contentBoxView.lim_width - 15.0f;
    self.contentBoxView.lim_centerY_parent = self.contentView;
    NSArray *subviews = self.contentBoxView.subviews;
    if(subviews && subviews.count>0) {
        UIView *subview = subviews[0];
        subview.lim_size = self.contentBoxView.lim_size;
    }
    
    self.playIconImgView.lim_left = self.contentBoxView.lim_left + (self.contentBoxView.lim_width/2.0f - self.playIconImgView.lim_width/2.0f);
    self.playIconImgView.lim_top = self.contentBoxView.lim_top + (self.contentBoxView.lim_height/2.0f - self.playIconImgView.lim_height/2.0f);
}

- (UIImageView *)avatarImgView {
    if(!_avatarImgView) {
        _avatarImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, msgAvatarSize,  msgAvatarSize)];
        _avatarImgView.layer.masksToBounds = YES;
        _avatarImgView.layer.cornerRadius = [WKApp shared].config.messageListAvatarSize.width/2.0f;
        
    }
    return _avatarImgView;
}

- (UIImageView *)likeImgView {
    if(!_likeImgView) {
        _likeImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 16.0f, 16.0f)];
        _likeImgView.image = [self imageName:@"Like"];
    }
    return _likeImgView;
}

- (UILabel *)nameLbl {
    if(!_nameLbl) {
        _nameLbl = [[UILabel alloc] init];
        _nameLbl.font = [[WKApp shared].config appFontOfSize:14.0f];
        _nameLbl.textColor = nameColor;
    }
    return _nameLbl;
}

- (M80AttributedLabel *)commentLbl {
    if(!_commentLbl) {
        _commentLbl = [[M80AttributedLabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, [[self class] maxCommentTextWidth], 0.0f)];
        _commentLbl.font = [UIFont systemFontOfSize:commentFontSize];
        _commentLbl.numberOfLines = 2;
        _commentLbl.backgroundColor = [UIColor clearColor];
        _commentLbl.lineBreakMode = NSLineBreakByTruncatingTail;
    }
    return _commentLbl;
}

- (UILabel *)timeLbl {
    if(!_timeLbl) {
        _timeLbl = [[UILabel alloc] init];
        _timeLbl.font = [[WKApp shared].config appFontOfSize:13.0f];
        _timeLbl.textColor = [WKApp shared].config.tipColor;
    }
    return _timeLbl;
}

- (UILabel *)contentLbl {
    if(!_contentLbl) {
        _contentLbl = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 0.0f, 0.0f)];
        _contentLbl.font = [[WKApp shared].config appFontOfSize:13.0f];
        _contentLbl.textColor = [WKApp shared].config.tipColor;
        _contentLbl.numberOfLines = 0;
        _contentLbl.lineBreakMode = NSLineBreakByWordWrapping;
        _contentLbl.textAlignment = NSTextAlignmentCenter;
    }
    return _contentLbl;
}

- (UIImageView *)contentImgView {
    if(!_contentImgView) {
        _contentImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 0.0f, 0.0f)];
        _contentImgView.contentMode = UIViewContentModeScaleAspectFill;
        _contentImgView.clipsToBounds = YES;
    }
    return _contentImgView;
}

+ (CGSize)getTextLabelSize:(NSString *)content maxWidth:(CGFloat)maxWidth fontSize:(CGFloat)fontSize{

    static M80AttributedLabel *textLbl;
    if(!textLbl) {
        textLbl = [[M80AttributedLabel alloc] init];
        textLbl.numberOfLines = 2;
        textLbl.lineBreakMode = NSLineBreakByTruncatingTail;
        [textLbl setFont:[UIFont systemFontOfSize:fontSize]];
    }
    textLbl.text = @"";
    [self fillLblContent:content label:textLbl];
    
    
    CGSize textSize = [textLbl sizeThatFits:CGSizeMake(maxWidth, CGFLOAT_MAX)];
    return textSize;
}

+(void) fillLblContent:(NSString*)content label:(M80AttributedLabel*)lbl{
    [lbl lim_setText:content];
}

- (UIView *)contentBoxView {
    if(!_contentBoxView) {
        _contentBoxView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, conentBoxViewSize, conentBoxViewSize)];
    }
    return _contentBoxView;
}

- (UIImageView *)playIconImgView {
    if(!_playIconImgView) {
        _playIconImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 16.0f, 16.0f)];
        _playIconImgView.image = [self imageName:@"Play"];
    }
    return _playIconImgView;
}


- (UIImage*) imageName:(NSString*)name {
    return [[WKApp shared] loadImage:name moduleID:[WKMomentModule gmoduleId]];
}


@end
