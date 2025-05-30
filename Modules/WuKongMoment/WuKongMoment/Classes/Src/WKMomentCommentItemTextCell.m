//
//  WKMomentCommentItemTextCell.m
//  WuKongMoment
//
//  Created by tt on 2020/11/18.
//

#import "WKMomentCommentItemTextCell.h"
#import <M80AttributedLabel/M80AttributedLabel.h>
#import "WKMomentConst.h"

@implementation WKMomentCommentItemTextModel

- (Class)cell {
    return WKMomentCommentItemTextCell.class;
}

@end

@interface WKMomentCommentItemTextCell ()<M80AttributedLabelDelegate>

@property(nonatomic,strong) UIView *commentBox;
@property(nonatomic,strong) M80AttributedLabel *commentLbl;


@end

@implementation WKMomentCommentItemTextCell

+ (CGSize)sizeForModel:(WKMomentCommentItemTextModel *)model {
    CGSize size = [self getTextLabelSize:model maxWidth:contentMaxWidth - commentBorder*2 fontSize:commentFontSize];
    return CGSizeMake(WKScreenWidth, size.height+ commentBorder*2);
}

- (void)setupUI {
    [super setupUI];
    [self.contentView addSubview:self.commentBox];
    [self.commentBox addSubview:self.commentLbl];
}

- (void)refresh:(WKMomentCommentItemTextModel *)model {
    [super refresh:model];
    
    if([WKApp shared].config.style == WKSystemStyleDark) {
        self.commentBox.backgroundColor = [UIColor colorWithRed:32.0f/255.0f green:32.0f/255.0f blue:32.0f/255.0f alpha:1.0f];
    }else{
        self.commentBox.backgroundColor = [WKApp shared].config.backgroundColor;
    }
    
    
    self.commentLbl.textColor = [WKApp shared].config.defaultTextColor;
    
    self.model= model;
    
    self.commentLbl.text = @"";
    [[self class] fillLblContent:model label:self.commentLbl];
}


- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.commentBox.lim_top = 0.0f;
    self.commentBox.lim_size = CGSizeMake(contentMaxWidth,self.contentView.lim_height);
    self.commentBox.lim_left = avatarLeftSpace + avatarSize + nameLeftSpace;
    
    
    self.commentLbl.lim_size = CGSizeMake(self.commentBox.lim_width - commentBorder*2, self.commentBox.lim_height-commentBorder*2);
    self.commentLbl.lim_left =8.0f;
    
    self.commentLbl.lim_centerY_parent = self.commentBox;
    
    [self.commentBox.layer setMask:nil];
    if(self.model.topCorner) {
        [self setTopCorner:self.commentBox];
    }
    if(self.model.bottomCorner) {
        [self setBottomCorner:self.commentBox];
    }
    
}


-(void) setTopCorner:(UIView*)view {
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:view.bounds byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii:CGSizeMake(4.0f, 4.0f)];
     CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
     maskLayer.frame = view.bounds;
     maskLayer.path = maskPath.CGPath;
    view.layer.mask = maskLayer;
}
-(void) setBottomCorner:(UIView*)view {
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:view.bounds byRoundingCorners:UIRectCornerBottomLeft | UIRectCornerBottomRight cornerRadii:CGSizeMake(4.0f, 4.0f)];
     CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
     maskLayer.frame = view.bounds;
     maskLayer.path = maskPath.CGPath;
    view.layer.mask = maskLayer;
}

- (UIView *)commentBox {
    if(!_commentBox) {
        _commentBox = [[UIView alloc] init];
        _commentBox.backgroundColor = [UIColor colorWithRed:247.0f/255.0f green:247.0f/255.0f blue:247.0f/255.0f alpha:1.0f];
    }
    return _commentBox;
}

- (M80AttributedLabel *)commentLbl {
    if(!_commentLbl) {
        _commentLbl = [[M80AttributedLabel alloc] init];
        _commentLbl.font = [UIFont systemFontOfSize:commentFontSize];
        _commentLbl.backgroundColor = [UIColor clearColor];
        _commentLbl.underLineForLink = false;
        _commentLbl.linkColor = nameColor;
        _commentLbl.textAlignment = NSTextAlignmentLeft;
        _commentLbl.delegate = self;
    }
    return _commentLbl;
}


+ (CGSize)getTextLabelSize:(WKMomentCommentItemTextModel *)model maxWidth:(CGFloat)maxWidth fontSize:(CGFloat)fontSize{

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

+(void) fillLblContent:(WKMomentCommentItemTextModel*)model label:(M80AttributedLabel*)lbl{
    NSString *name = model.name;
    WKChannelInfo *channelInfo = [[WKSDK shared].channelManager getChannelInfo:[WKChannel personWithChannelID:model.uid]];
    if(channelInfo) {
        name = channelInfo.displayName;
    }
    [lbl addCustomLink:@{@"type":@"commenter",@"uid":model.uid?:@""} forRange:NSMakeRange(lbl.text.length, name.length)];
    [lbl appendText:[NSString stringWithFormat:@"%@",name]];
    
    if(model.toUID && ![model.toUID isEqualToString:@""]) {
        WKChannelInfo *toChannelInfo = [[WKSDK shared].channelManager getChannelInfo:[WKChannel personWithChannelID:model.toUID]];
        [lbl appendText:LLang(@"回复")];
        NSString *toName = model.toName;
        if(toChannelInfo) {
            toName = toChannelInfo.displayName;
        }
        [lbl addCustomLink:@{@"type":@"replyer",@"uid":model.toUID?:@""} forRange:NSMakeRange(lbl.text.length, toName.length)];
        [lbl appendText:[NSString stringWithFormat:@"%@：",toName]];
        
    }else {
        [lbl appendText:[NSString stringWithFormat:@"："]];
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

#pragma mark -- M80AttributedLabelDelegate

- (void)m80AttributedLabel:(M80AttributedLabel *)label clickedOnLink:(id)linkData {
    NSDictionary *result = (NSDictionary*)linkData;
    if(result && result[@"uid"]) {
        NSString *uid = result[@"uid"];
        [[WKApp shared] invoke:WKPOINT_USER_INFO param:@{@"uid":uid?:@""}];
       
    }
}

@end
