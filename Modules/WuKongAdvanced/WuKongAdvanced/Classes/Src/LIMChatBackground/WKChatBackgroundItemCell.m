//
//  WKChatBackgroundItemCell.m
//  WuKongAdvanced
//
//  Created by tt on 2022/9/12.
//

#import "WKChatBackgroundItemCell.h"
#import <WuKongBase/WuKongBase-Swift.h>
#import <AsyncDisplayKit/AsyncDisplayKit.h>

@interface WKChatBackgroundImageView : UIImageView

@property(nonatomic,copy) void(^onClick)(void);

@end

@implementation WKChatBackgroundItemCellModel

- (Class)cell {
    return WKChatBackgroundItemCell.class;
}

- (NSArray<WKChatBackground *> *)chatBackgrounds {
    if(!_chatBackgrounds) {
        _chatBackgrounds = [NSArray array];
    }
    return _chatBackgrounds;
}

- (NSInteger)maxNum {
    if(!_maxNum) {
        _maxNum = 3;
    }
    return _maxNum;
}

- (CGFloat)cellHeight {
    return 200.0f;
}

@end

@interface WKChatBackgroundItemCell ()

@property(nonatomic,strong) ASDisplayNode *bgBox;

@property(nonatomic,strong) WKChatBackgroundItemCellModel *model;


@end

#define space 5.0f

@implementation WKChatBackgroundItemCell

- (void)setupUI {
    [super setupUI];
    
    [self.contentView addSubnode:self.bgBox];
    
    for (NSInteger i=0; i<3; i++) {
        [self.bgBox addSubnode:[self newChatBackgroundView]];
    }
}

- (void)refresh:(WKChatBackgroundItemCellModel *)model {
    [super refresh:model];
    self.model = model;

}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.bgBox.frame = self.contentView.bounds;
    
    UIView *lastView;
    CGFloat width = (self.bgBox.frame.size.width - space*(self.model.maxNum+1))/self.model.maxNum;
    for (NSInteger i=0; i<self.bgBox.subnodes.count; i++) {
        if(i>=self.model.chatBackgrounds.count) {
            break;
        }
        GradientBackgroundNode *v = (GradientBackgroundNode*)self.bgBox.subnodes[i];
        CGFloat left;
        CGFloat top;
        if(lastView) {
            left = lastView.lim_right + space;
        }else{
            left = space;
        }
        top = space;
        
        v.frame = CGRectMake(left, top, width, self.bgBox.frame.size.height - space);
        [v updateLayoutWithSize:v.frame.size];
        [self updateChatBackground:self.model.chatBackgrounds[i] node:v];
        if(v.view.subviews.count>0) {
            for (UIView *vw in v.view.subviews) {
                if(vw.tag ==99) {
                    vw.frame = v.bounds;
                }
            }
        }
        
        lastView = v.view;
    }
}


-(void) updateChatBackground:(WKChatBackground*)chatBg node:(GradientBackgroundNode*)node{
    WKChatBackgroundImageView *imgView = [node.view viewWithTag:99];
    if(chatBg.image) {
        imgView.image = chatBg.image;
    }else{
        [imgView lim_setImageWithURL:[WKApp.shared getImageFullUrl:chatBg.cover]];
        if(chatBg.isSvg) {
            imgView.alpha = 0.2f;
            [node updateColorsWithColors:[self getColors:chatBg]];
        }else {
            imgView.alpha = 1.0f;
        }
    }
    
    imgView.onClick = ^{
        if(self.model.onBackground) {
            self.model.onBackground(chatBg);
        }
    };
    
//    [node.view bringSubviewToFront:imgView];
}

-(NSArray<UIColor*>*) getColors:(WKChatBackground*)chatBg {
    if(WKApp.shared.config.style == WKSystemStyleDark) {
        return chatBg.darkColors;
    }
    return chatBg.lightColors;
}

-(GradientBackgroundNode*) newChatBackgroundView{
    GradientBackgroundNode *gradientBackgroundNode = [[GradientBackgroundNode alloc] initWithColors:nil useSharedAnimationPhase:false adjustSaturation:false];
    WKChatBackgroundImageView *imgView = [[WKChatBackgroundImageView alloc] init];
    imgView.tag = 99;
    imgView.contentMode = UIViewContentModeScaleAspectFill;
    imgView.clipsToBounds = YES;
    [gradientBackgroundNode.view addSubview:imgView];
    
    return gradientBackgroundNode;
}

- (ASDisplayNode *)bgBox {
    if(!_bgBox) {
        _bgBox = [[ASDisplayNode alloc] init];
    }
    return _bgBox;
}

@end



@implementation WKChatBackgroundImageView

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.userInteractionEnabled = YES;
        [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pressed)]];
    }
    return self;
}

-(void) pressed {
    if(self.onClick) {
        self.onClick();
    }
}

@end
