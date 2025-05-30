//
//  WKMomentCommentItemCell.m
//  WuKongMoment
//
//  Created by tt on 2020/11/17.
//
#import "WKMomentConst.h"
#import "WKMomentCommentItemCell.h"
#import <M80AttributedLabel/M80AttributedLabel.h>

#import "WKMomentModule.h"

@implementation WKMomentCommentItemModel



- (Class)cell {
    return WKMomentCommentItemCell.class;
}

@end

@interface WKMomentCommentItemCell ()<M80AttributedLabelDelegate>

@property(nonatomic,strong) UIView *boxView;

@property(nonatomic,strong) UIImageView *commentIcon;
@property(nonatomic,strong) UIImageView *avatarImgView;
@property(nonatomic,strong) UILabel *nameLbl;
@property(nonatomic,strong) UILabel *timeLbl;
@property(nonatomic,strong) M80AttributedLabel *contentLbl;


@end

#define leftSpace 15.0f

#define boxTopSpace 5.0f
#define boxBottomSpace 5.0f
#define boxRightSpace 10.0f

#define commentIconLeftSpace 15.0f

#define commentIconSize 16.0f

#define commentAvatarSize 25.0f
#define commentNameTopSpace 4.0f
#define commentNameHeight 15.0f
#define commentNameLeftSpace 5.0f

#define commentContentTopSpace 4.0f

//#define commentAvatarLeftSpace 20.0f



#define commentContentMaxWidth (WKScreenWidth - leftSpace*2 - commentIconLeftSpace*2 - commentIconSize - commentAvatarSize - commentNameLeftSpace)

@implementation WKMomentCommentItemCell

+ (CGSize)sizeForModel:(WKMomentCommentItemModel *)model {
    CGSize size = [self getTextLabelSize:model maxWidth:commentContentMaxWidth fontSize:commentFontSize];
    return CGSizeMake(WKScreenWidth, size.height + commentNameTopSpace + commentNameHeight + commentContentTopSpace + boxTopSpace + boxBottomSpace);
}

- (void)setupUI {
    [super setupUI];
    
    
    [self.contentView addSubview:self.boxView];
    
    [self.boxView addSubview:self.commentIcon];
    [self.boxView addSubview:self.avatarImgView];
    [self.boxView addSubview:self.nameLbl];
    [self.boxView addSubview:self.timeLbl];
    [self.boxView addSubview:self.contentLbl];
}

- (void)refresh:(WKMomentCommentItemModel *)model {
    [super refresh:model];
    
    self.model = model;
    
    if([WKApp shared].config.style == WKSystemStyleDark) {
        self.boxView.backgroundColor = [UIColor colorWithRed:32.0f/255.0f green:32.0f/255.0f blue:32.0f/255.0f alpha:1.0f];
    }else{
        self.boxView.backgroundColor = [WKApp shared].config.backgroundColor;
    }
    
    self.contentLbl.textColor = [WKApp shared].config.defaultTextColor;
    
    [self.avatarImgView lim_setImageWithURL:[NSURL URLWithString:[WKAvatarUtil getAvatar:model.uid]] placeholderImage:[WKApp shared].config.defaultAvatar];
    
    WKChannelInfo *channelInfo = [[WKSDK shared].channelManager getChannelInfo:[WKChannel personWithChannelID:model.uid]];
    if(channelInfo) {
        self.nameLbl.text = channelInfo.displayName;
    }else{
        self.nameLbl.text = model.name;
    }
    
    
    self.timeLbl.text = model.timeFormat;
    [self.timeLbl sizeToFit];
    
    self.contentLbl.text = @"";
    [[self class] fillLblContent:model label:self.contentLbl];
    
    self.commentIcon.hidden = YES;
    if(model.first) {
        self.commentIcon.hidden = NO;
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
   
    
    self.boxView.lim_left = 15.0f;
    self.boxView.lim_width = self.lim_width - self.boxView.lim_left * 2;
    self.boxView.lim_height = self.lim_height;
    
    self.commentIcon.lim_top = 15.0f;
    self.commentIcon.lim_left = commentIconLeftSpace;
    
    self.avatarImgView.lim_top = 4.0f+boxTopSpace;
    self.avatarImgView.lim_left =  (commentIconLeftSpace*2 + commentIconSize);
    
    
    self.nameLbl.lim_top = commentNameTopSpace + boxTopSpace;
    self.nameLbl.lim_left = self.avatarImgView.lim_right + commentNameLeftSpace;
    self.nameLbl.lim_height = commentNameHeight;
    self.nameLbl.lim_width = self.boxView.lim_width - self.avatarImgView.lim_right -self.timeLbl.lim_width - 15.0f -boxRightSpace;
    
    self.timeLbl.lim_top = self.nameLbl.lim_top +  self.nameLbl.lim_height/2.0f - self.timeLbl.lim_height/2.0f;
    self.timeLbl.lim_left = self.boxView.lim_width - self.timeLbl.lim_width  - boxRightSpace;
    
    self.contentLbl.lim_top = commentContentTopSpace + self.nameLbl.lim_bottom;
    self.contentLbl.lim_left = self.nameLbl.lim_left;
    self.contentLbl.lim_width = commentContentMaxWidth;
    self.contentLbl.lim_height = self.boxView.lim_height - (self.nameLbl.lim_bottom + commentContentTopSpace);
    
    
}

- (UIView *)boxView {
    if(!_boxView) {
        _boxView = [[UIView alloc] init];
        _boxView.backgroundColor = [UIColor colorWithRed:247.0f/255.0f green:247.0f/255.0f blue:247.0f/255.0f alpha:1.0f];
    }
    return _boxView;
}

- (UILabel *)timeLbl {
    if(!_timeLbl) {
        _timeLbl = [[UILabel alloc] init];
        _timeLbl.font = [[WKApp shared].config appFontOfSize:12.0f];
        _timeLbl.textColor = [WKApp shared].config.tipColor;
    }
    return _timeLbl;
}

- (M80AttributedLabel *)contentLbl {
    if(!_contentLbl) {
        _contentLbl = [[M80AttributedLabel alloc] init];
        _contentLbl.font = [UIFont systemFontOfSize:commentFontSize];
        _contentLbl.textColor = [WKApp shared].config.defaultTextColor;
        [_contentLbl setBackgroundColor:[UIColor clearColor]];
        _contentLbl.underLineForLink = false;
        _contentLbl.linkColor = nameColor;
        _contentLbl.textAlignment = NSTextAlignmentLeft;
        _contentLbl.delegate = self;
    }
    return _contentLbl;
}

- (UILabel *)nameLbl {
    if(!_nameLbl) {
        _nameLbl = [[UILabel alloc] init];
        _nameLbl.font = [[WKApp shared].config appFontOfSize:14.0f];
        _nameLbl.textColor = nameColor;
        
        _nameLbl.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onNameTap)];
        [_nameLbl addGestureRecognizer:tap];
    }
    return _nameLbl;
}
-(void) onNameTap {
    [[WKApp shared] invoke:WKPOINT_USER_INFO param:@{@"uid":self.model.uid?:@""}];
}

- (UIImageView *)avatarImgView {
    if(!_avatarImgView) {
        _avatarImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, commentAvatarSize, commentAvatarSize)];
        _avatarImgView.layer.masksToBounds = YES;
        _avatarImgView.layer.cornerRadius = _avatarImgView.lim_width/2.0f;
        
        _avatarImgView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onAvatarTap)];
        [_avatarImgView addGestureRecognizer:tap];
    }
    return _avatarImgView;
}
-(void) onAvatarTap {
    [[WKApp shared] invoke:WKPOINT_USER_INFO param:@{@"uid":self.model.uid?:@""}];
}

- (UIImageView *)commentIcon {
    if(!_commentIcon) {
        _commentIcon = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, commentIconSize, commentIconSize)];
        _commentIcon.image = [self imageName:@"Comment"];
    }
    return _commentIcon;
}


+ (CGSize)getTextLabelSize:(WKMomentCommentItemModel *)model maxWidth:(CGFloat)maxWidth fontSize:(CGFloat)fontSize{
    
    static M80AttributedLabel *textLbl;
    if(!textLbl) {
        textLbl = [[M80AttributedLabel alloc] init];
        [textLbl setFont:[UIFont systemFontOfSize:fontSize]];
    }
    textLbl.text = @"";
    [self fillLblContent:model label:textLbl];
    
    
    CGSize textSize = [textLbl sizeThatFits:CGSizeMake(maxWidth, CGFLOAT_MAX)];
    return textSize;
}

+(void) fillLblContent:(WKMomentCommentItemModel*)model label:(M80AttributedLabel*)lbl{
    
    if(model.toUID && ![model.toUID isEqualToString:@""]) {
        WKChannelInfo *toChannelInfo = [[WKSDK shared].channelManager getChannelInfo:[WKChannel personWithChannelID:model.uid]];
        NSString *toName = model.toName;
        if(toChannelInfo) {
            toName = toChannelInfo.displayName;
        }
        [lbl appendText:[NSString stringWithFormat:@"回复"]];
        [lbl addCustomLink:@{@"uid":model.toUID?:@""} forRange:NSMakeRange(lbl.text.length, toName.length)];
        [lbl appendText:[NSString stringWithFormat:@"%@：",toName]];
    }
    NSArray<id<WKMatchToken>> *tokens = [ [WKEmoticonService shared] parseEmotion:model.content];
    for(id<WKMatchToken> token in tokens){
        if (token.type == WKatchTokenTypeEmoji){
            WKEmotionToken *emojiToken = (WKEmotionToken*)token;
            UIImage *image = [[WKEmoticonService shared] emojiImageNamed:emojiToken.imageName];
            if(image){
                [lbl appendImage:image
                          maxSize:CGSizeMake(24, 24)];
            }
        }else{
            [lbl appendText:token.text];
        }
    }
}

- (UIImage*) imageName:(NSString*)name {
    return [[WKApp shared] loadImage:name moduleID:[WKMomentModule gmoduleId]];
}


#pragma mark -- M80AttributedLabelDelegate

- (void)m80AttributedLabel:(M80AttributedLabel *)label clickedOnLink:(id)linkData {
    NSDictionary *result = (NSDictionary*)linkData;
    if(result && result[@"uid"]) {
        NSString *uid = result[@"uid"];
        [[WKApp shared] invoke:WKPOINT_USER_INFO param:@{@"uid":uid?:@""}];
       
    }
}

@end
