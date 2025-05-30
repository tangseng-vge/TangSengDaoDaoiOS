//
//  WKReactionView.m
//  WuKongBase
//
//  Created by tt on 2021/9/13.
//

#import "WKReactionView.h"
#import "WKReactionsUtil.h"
#define reactionItemSize CGSizeMake(18.0f,18.0f)
#define reactionItemCircePadding 2.0f
@interface WKReactionItemView : UIView

@property(nonatomic,strong) WKReaction *reaction;

@property(nonatomic,strong) UIImageView *contentBoxView;

-(instancetype) initWithReaction:(WKReaction*)reaction;

@end

@implementation WKReactionItemView

-(instancetype) initWithReaction:(WKReaction*)reaction {
    self = [super initWithFrame:CGRectMake(0.0f, 0.0f, reactionItemSize.width + reactionItemCircePadding*2.0f, reactionItemSize.height + reactionItemCircePadding*2.0f)];
    if(self) {
        [self setBackgroundColor:[WKApp shared].config.cellBackgroundColor];
        self.reaction = reaction;
        
        [self addSubview:self.contentBoxView];
        self.layer.masksToBounds = YES;
        self.layer.cornerRadius = self.lim_height/2.0f;
        self.contentBoxView.layer.masksToBounds = YES;
        self.contentBoxView.layer.cornerRadius = self.contentBoxView.lim_height/2.0f;
    }
    return self;
}

- (UIImageView *)contentBoxView {
    if(!_contentBoxView) {
        _contentBoxView = [[UIImageView alloc] initWithFrame:CGRectMake(reactionItemCircePadding, reactionItemCircePadding, reactionItemSize.width, reactionItemSize.height)];
        [_contentBoxView lim_setImageWithURL:[NSURL URLWithString:[WKReactionsUtil getReactionIconURL:self.reaction.emoji]]];
    }
    return _contentBoxView;
}

//-(UIImage*) getReactionIcon {
//    return [self getImageNameForBaseModule:[NSString stringWithFormat:@"icon_msg_reactions_%@",self.reaction.emoji]];
//}



//-(UIImage*) getImageNameForBaseModule:(NSString*)name {
//    return [[WKResource shared] resourceForImage:name podName:@"WuKongAdvanced_images"];
//}
@end

@interface WKReactionView ()

@property(nonatomic,strong) UIView *reactionBoxView;

@property(nonatomic,strong) UILabel *reactionNumLbl;

@end

@implementation WKReactionView

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [WKApp shared].config.cellBackgroundColor;
//        self.layer.masksToBounds = YES;
        self.layer.cornerRadius = [[self class] height]/2.0f;
        self.layer.shadowRadius = 1.0f;
        self.layer.shadowColor = [UIColor colorWithRed:0.0f/255.0f green:0.0f/255.0f blue:0.0f/255.0f alpha:0.5f].CGColor;
        self.layer.shadowOffset = CGSizeMake(0.0f, 1.0f);
        self.layer.shadowOpacity = 0.5f;
        
        
        [self addSubview:self.reactionBoxView];
        [self addSubview:self.reactionNumLbl];
        
        self.reactionBoxView.layer.cornerRadius = self.layer.cornerRadius;
    }
    return self;
}

+(CGFloat) height {
    return reactionItemSize.height + reactionItemCircePadding*2.0f;
}

- (void)render:(NSArray<WKReaction *> *)reactions {
    [self.reactionBoxView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    if(reactions && reactions.count>0) {
        self.reactionBoxView.lim_size = CGSizeMake(reactions.count * (reactionItemSize.width + reactionItemCircePadding*2.0f) , [[self class] height]);
        for (WKReaction *reaction in reactions) {
            [self.reactionBoxView addSubview:[[WKReactionItemView alloc] initWithReaction:reaction]];
        }
    }else {
        self.reactionBoxView.lim_size = CGSizeZero;
    }
    
    [self layoutSubviews];

}

- (void)setReactionNum:(NSInteger)reactionNum {
    self.reactionNumLbl.text = [NSString stringWithFormat:@"%lu",(unsigned long)reactionNum];
    [self.reactionNumLbl sizeToFit];
    [self layoutSubviews];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if(self.reactionBoxView.subviews.count>0) {
        UIView *preView;
        for (UIView *subview in self.reactionBoxView.subviews) {
            if(preView) {
                subview.lim_left =  preView.lim_right - reactionItemCircePadding *2.0f;
            }else {
                subview.lim_left = 0.0f;
            }
            subview.lim_centerY_parent = self.reactionBoxView;
            
            [self.reactionBoxView sendSubviewToBack:subview];
            
            preView = subview;
            
        }
        self.reactionBoxView.lim_width = preView.lim_right;
        
        self.lim_size = CGSizeMake(self.reactionBoxView.lim_size.width + self.reactionNumLbl.lim_width + 4.0f, self.reactionBoxView.lim_size.height);
        
        self.reactionNumLbl.lim_centerY_parent = self;
        
        self.reactionNumLbl.lim_left = preView.lim_right;
    }
    
   
}

- (UIView *)reactionBoxView {
    if(!_reactionBoxView) {
        _reactionBoxView = [[UIView alloc] init];
    }
    return _reactionBoxView;
}

- (UILabel *)reactionNumLbl {
    if(!_reactionNumLbl) {
        _reactionNumLbl = [[UILabel alloc] init];
        _reactionNumLbl.font = [[WKApp shared].config appFontOfSize:12.0f];
        _reactionNumLbl.textColor = [WKApp shared].config.tipColor;
    }
    return _reactionNumLbl;
}


@end

