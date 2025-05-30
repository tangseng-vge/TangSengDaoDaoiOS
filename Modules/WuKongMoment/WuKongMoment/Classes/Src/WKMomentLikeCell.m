//
//  WKMomentLikeCell.m
//  WuKongMoment
//
//  Created by tt on 2020/11/6.
//

#import "WKMomentLikeCell.h"
#import <M80AttributedLabel/M80AttributedLabel.h>
#import "WKMomentConst.h"
#import "WKMomentModule.h"

@implementation WKMomentLikeUser

+ (instancetype)uid:(NSString *)uid name:(NSString *)name {
    WKMomentLikeUser *user = [WKMomentLikeUser new];
    user.uid = uid;
    user.name = name;
    return user;
}

@end

@implementation WKMomentLikeModel

- (Class)cell {
    return WKMomentLikeCell.class;
}

@end

@interface WKMomentLikeCell ()<M80AttributedLabelDelegate>

@property(nonatomic,strong) UIView *likeBox;
@property(nonatomic,strong) UIImageView *likeIcon;
@property(nonatomic,strong) M80AttributedLabel *likeLbl;

@property(nonatomic,strong) WKMomentLikeModel *model;

@end

@implementation WKMomentLikeCell

+ (CGSize)sizeForModel:(WKMomentLikeModel *)model {
    CGSize size = [self getTextLabelSize:model maxWidth:contentMaxWidth - likeIconLeftSpace - likeIconSize - likeIconRightSpace - likeBorder*2 fontSize:likeFontSize];
    return CGSizeMake(WKScreenWidth, size.height+ likeBorder*2);
}

- (void)setupUI {
    [super setupUI];
    
    [self.contentView addSubview:self.likeBox];
    
    [self.likeBox addSubview:self.likeLbl];
    
    [self.likeBox addSubview:self.likeIcon];
}

- (void)refresh:(WKMomentLikeModel *)model {
    [super refresh:model];
    self.model = model;
    
    if([WKApp shared].config.style == WKSystemStyleDark) {
        self.likeBox.backgroundColor = [UIColor colorWithRed:32.0f/255.0f green:32.0f/255.0f blue:32.0f/255.0f alpha:1.0f];
    }else{
        self.likeBox.backgroundColor = [WKApp shared].config.backgroundColor;
    }
    
    self.likeLbl.text = @"";
    
    [[self class] fillLblContent:model label:self.likeLbl];
    
    
    
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    
    self.likeIcon.lim_left = likeIconLeftSpace;
    self.likeIcon.lim_top = 4.0f;
    
    CGSize textSize = [[self class] getTextLabelSize:self.model maxWidth:contentMaxWidth - likeIconLeftSpace - likeIconSize - likeIconRightSpace - likeBorder*2 fontSize:likeFontSize];
    
    self.likeLbl.lim_size = textSize;
    
    self.likeBox.lim_size = CGSizeMake(contentMaxWidth, self.contentView.lim_height);
    
    self.likeLbl.lim_left = self.likeIcon.lim_right + likeIconRightSpace;
    self.likeLbl.lim_centerY_parent = self.likeBox;
    
    self.likeBox.lim_left = avatarLeftSpace + avatarSize + nameLeftSpace;
    
    [self.likeBox.layer setMask:nil];
    [self setTopCorner:self.likeBox];
    if(!self.model.hasComment) {
        [self setBottomCorner:self.likeBox];
    }
}


+ (CGSize)getTextLabelSize:(WKMomentLikeModel *)model maxWidth:(CGFloat)maxWidth fontSize:(CGFloat)fontSize{
    
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

+(void) fillLblContent:(WKMomentLikeModel*)model label:(M80AttributedLabel*)lbl{
    if(model.users && model.users.count>0) {
        NSInteger index = 0;
        for (WKMomentLikeUser *user in model.users) {
            NSString *name = user.name;
           WKChannelInfo *channelInfo = [[WKSDK shared].channelManager getChannelInfo:[WKChannel personWithChannelID:user.uid]];
            if(channelInfo) {
                name = channelInfo.displayName;
            }
            NSString *text = @"";
            if(index == model.users.count-1) {
                text = name;
            }else{
                text = [NSString stringWithFormat:@"%@ ",name];
            }
            [lbl addCustomLink:user forRange:NSMakeRange(lbl.text.length, name.length) linkColor:nameColor];
            [lbl appendText:text];
            
            index++;
        }
    }
}

- (M80AttributedLabel *)likeLbl {
    if(!_likeLbl) {
        _likeLbl = [[M80AttributedLabel alloc] init];
        _likeLbl.font = [UIFont systemFontOfSize:likeFontSize];
        _likeLbl.backgroundColor = [UIColor clearColor];
        _likeLbl.underLineForLink = false;
        _likeLbl.delegate = self;
    }
    return _likeLbl;
}

- (UIImageView *)likeIcon {
    if(!_likeIcon) {
        _likeIcon = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, likeIconSize, likeIconSize)];
        _likeIcon.image = [self imageName:@"Like"];
    }
    return _likeIcon;
}

- (UIView *)likeBox {
    if(!_likeBox) {
        _likeBox = [[UIView alloc] init];
        _likeBox.backgroundColor = [UIColor colorWithRed:247.0f/255.0f green:247.0f/255.0f blue:247.0f/255.0f alpha:1.0f];
        
    }
    return _likeBox;
}

-(void) setTopCorner:(UIView*)view {
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:view.bounds byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii:CGSizeMake(4, 4)];
     CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
     maskLayer.frame = view.bounds;
     maskLayer.path = maskPath.CGPath;
    view.layer.mask = maskLayer;
}
-(void) setBottomCorner:(UIView*)view {
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:view.bounds byRoundingCorners:UIRectCornerBottomLeft | UIRectCornerBottomRight cornerRadii:CGSizeMake(4, 4)];
     CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
     maskLayer.frame = view.bounds;
     maskLayer.path = maskPath.CGPath;
    view.layer.mask = maskLayer;
}

#pragma mark - M80AttributedLabelDelegate

- (void)m80AttributedLabel:(M80AttributedLabel *)label clickedOnLink:(id)linkData {
    WKMomentLikeUser *likeUser = (WKMomentLikeUser*)linkData;
    [[WKApp shared] invoke:WKPOINT_USER_INFO param:@{@"uid":likeUser.uid?:@""}];
}

- (UIImage*) imageName:(NSString*)name {
    return [[WKApp shared] loadImage:name moduleID:[WKMomentModule gmoduleId]];
}

@end
