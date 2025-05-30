//
//  WKMomentOperateCell.m
//  WuKongMoment
//
//  Created by tt on 2020/11/5.
//

#import "WKMomentOperateCell.h"
#import "WKMomentConst.h"
#import "WKMomentModule.h"


@interface WKMoreMenus : UIView

@property(nonatomic,strong) UIView *box;

@property(nonatomic,strong) UIView *splitLineView;

@property(nonatomic,assign) BOOL liked; // 是否已经点赞
@property(nonatomic,assign) BOOL hiddenItem;
@property(nonatomic,copy) void(^onComment)(void); // 评论
@property(nonatomic,copy) void(^onLike)(void); // 点赞


@end

@implementation WKMomentOperateModel


- (Class)cell {
    return WKMomentOperateCell.class;
}

@end

@interface WKMomentOperateCell ()

@property(nonatomic,strong) UILabel *timeLbl;
@property(nonatomic,strong) UIButton *moreBtn;

@property(nonatomic,strong) UIButton *deleteBtn;

@property(nonatomic,strong) WKMoreMenus *moreMenus;

@property(nonatomic,strong) UIView *coverView;

@property(nonatomic,strong) WKMomentOperateModel *model;

@property(nonatomic,strong) UIButton *privateBtn;

@end

@implementation WKMomentOperateCell

+ (CGSize)sizeForModel:(WKFormItemModel *)model {
    return CGSizeMake(WKScreenWidth, 50.0f);
}

- (void)setupUI {
    [super setupUI];
    [self.contentView addSubview:self.timeLbl];
    [self.contentView addSubview:self.moreBtn];
    [self.contentView addSubview:self.deleteBtn];
    [self.contentView addSubview:self.privateBtn];
    
    
}

- (void)refresh:(WKMomentOperateModel *)model {
    [super refresh:model];
    self.model = model;
    
    self.moreMenus.hidden = YES;
    self.moreMenus.liked = model.liked;
    
    self.timeLbl.text = model.timeFormat;
    [self.timeLbl sizeToFit];
    
    self.deleteBtn.hidden = !model.showDelete;
    
    self.privateBtn.hidden = !(model.showPrivate||model.selfVisiable);
    
    if(model.showPrivate) {
        UIImage *img = LImage(@"icon_private");
        img = [img imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [self.privateBtn setImage:img forState:UIControlStateNormal];
    }else if(model.selfVisiable) {
        UIImage *img = LImage(@"Lock");
        img = [img imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [self.privateBtn setImage:img forState:UIControlStateNormal];
    }
    
    
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.timeLbl.lim_left = avatarLeftSpace + avatarSize + nameLeftSpace;
    self.timeLbl.lim_height = self.contentView.lim_height;
    
    CGFloat privateLeftSpace = self.timeLbl.lim_right;
    if(!self.privateBtn.hidden) {
        self.privateBtn.lim_left = self.timeLbl.lim_right + 15.0f;
        self.privateBtn.lim_centerY_parent = self.contentView;
        
        privateLeftSpace = self.privateBtn.lim_right;
    }
    
    self.deleteBtn.lim_left = privateLeftSpace + 15.0f;
    self.deleteBtn.lim_centerY_parent = self.contentView;
    
    self.moreBtn.lim_left = WKScreenWidth - self.moreBtn.lim_width - 15.0f;
    self.moreBtn.lim_top = self.contentView.lim_height/2.0f - self.moreBtn.lim_height/2.0f;
    
    
    
//    self.moreMenus.lim_width = 140.0f;
//    self.moreMenus.lim_left = self.moreBtn.lim_left - self.moreMenus.lim_width - 10.0f;
//    self.moreMenus.lim_centerY_parent = self.contentView;
    
}

- (UILabel *)timeLbl {
    if(!_timeLbl) {
        _timeLbl = [[UILabel alloc] init];
        _timeLbl.font = [[WKApp shared].config appFontOfSize:13.0f];
        _timeLbl.textColor = [WKApp shared].config.tipColor;
    }
    return _timeLbl;
}

- (UIButton *)moreBtn {
    if(!_moreBtn) {
        _moreBtn = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 32.0f, 20.0f)];
        [_moreBtn setImage:[self imageName:@"More"] forState:UIControlStateNormal];
        [_moreBtn addTarget:self action:@selector(morePressed) forControlEvents:UIControlEventTouchUpInside];
    }
    return _moreBtn;
}

-(void) morePressed {
    UIView *topView = [WKNavigationManager shared].topViewController.view;
    if(!self.moreMenus.superview) {
        [topView addSubview:self.moreMenus];
        [self.moreMenus layoutSubviews];
    }
    UITableView *tableView;
    if([self.superview isKindOfClass:[UITableView class]]) {
        tableView = (UITableView*)self.superview;
    }
    if(!tableView) {
        return;
    }
    
    BOOL show = false;
    self.moreMenus.lim_top = (self.lim_top  - tableView.contentOffset.y + tableView.lim_top) + (self.contentView.lim_height/2.0f - self.moreMenus.lim_height/2.0f);
    
    if(self.moreMenus.hidden) {
        self.moreMenus.lim_width = 0.0f;
        self.moreMenus.lim_left = self.contentView.lim_width - self.moreMenus.lim_width - self.moreBtn.lim_width - 15 *2.0f;
        self.moreMenus.hidden = NO;
        self.moreMenus.hiddenItem = YES;
        show = true;
        [topView addSubview:self.coverView];
        [topView bringSubviewToFront:self.moreMenus];
    }else{
        self.moreMenus.lim_width = menusWidth;
        self.moreMenus.lim_left = self.contentView.lim_width - self.moreMenus.lim_width - self.moreBtn.lim_width - 15 *2.0f;
        show = false;
        [self.coverView removeFromSuperview];
    }
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.1f animations:^{
        if(show) {
            weakSelf.moreMenus.lim_width = menusWidth;
            weakSelf.moreMenus.lim_left = weakSelf.contentView.lim_width - weakSelf.moreMenus.lim_width - weakSelf.moreBtn.lim_width - 15 *2.0f;
        }else{
            weakSelf.moreMenus.lim_width = 0.0f;
            weakSelf.moreMenus.lim_left = weakSelf.contentView.lim_width - weakSelf.moreMenus.lim_width - weakSelf.moreBtn.lim_width - 15 *2.0f;
        }
       
        [weakSelf.moreMenus layoutSubviews];
        
    } completion:^(BOOL finished) {
        if(!show) {
            weakSelf.moreMenus.hidden = YES;
            weakSelf.moreMenus.hiddenItem = YES;
        }else{
            weakSelf.moreMenus.hiddenItem = NO;
        }
    }];
    
}

- (UIButton *)deleteBtn {
    if(!_deleteBtn) {
        _deleteBtn = [[UIButton alloc] init];
        [_deleteBtn setTitleColor:nameColor forState:UIControlStateNormal];
        [_deleteBtn setTitle:LLang(@"删除") forState:UIControlStateNormal];
        [[_deleteBtn titleLabel] setFont:[UIFont systemFontOfSize:13.0f]];
        [_deleteBtn sizeToFit];
        [_deleteBtn addTarget:self action:@selector(deletePressed) forControlEvents:UIControlEventTouchUpInside];
    }
    return _deleteBtn;
}

- (UIButton *)privateBtn {
    if(!_privateBtn) {
        _privateBtn = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 16.0f, 16.0f)];
        [_privateBtn setTintColor:nameColor];
        [_privateBtn addTarget:self action:@selector(privateBtnPressed) forControlEvents:UIControlEventTouchUpInside];
    }
    return _privateBtn;
}

-(void) privateBtnPressed {
    if(self.model.onPrivate) {
        self.model.onPrivate();
    }

}

-(void)deletePressed {
    if(self.model.onDelete) {
        self.model.onDelete();
    }
}

- (UIView *)coverView {
    if(!_coverView) {
        _coverView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, WKScreenWidth, WKScreenHeight)];
        [_coverView setBackgroundColor:[UIColor clearColor]];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideMenus)];
        _coverView.userInteractionEnabled = YES;
        [_coverView addGestureRecognizer:tap];
    }
    return _coverView;
}


-(void) hideMenus {
    [self.coverView removeFromSuperview];
    [self.moreMenus removeFromSuperview];
    [self morePressed];
}

- (WKMoreMenus *)moreMenus {
    if(!_moreMenus) {
        _moreMenus = [[WKMoreMenus alloc] initWithFrame:CGRectMake(0.0f, 0.0f, menusWidth, 40.0f)];
        _moreMenus.hidden = YES;
        [_moreMenus layoutSubviews]; // 为了让item布局好
        _moreMenus.lim_width = 0.0f;
        [_moreMenus layoutSubviews]; // 为了让item布局好
        __weak typeof(self) weakSelf = self;
        [_moreMenus setOnComment:^{
            [weakSelf hideMenus];
            if(weakSelf.model.onComment) {
                weakSelf.model.onComment(weakSelf, weakSelf.model);
            }
        }];
        [_moreMenus setOnLike:^{
            [weakSelf hideMenus];
            if(weakSelf.model.onLike) {
                weakSelf.model.onLike(weakSelf, weakSelf.model);
            }
            
        }];
    }
    return _moreMenus;
}

- (UIImage*) imageName:(NSString*)name {
    return [[WKApp shared] loadImage:name moduleID:[WKMomentModule gmoduleId]];
}

@end


#define likeTag 1
#define commentTag 2
@implementation WKMoreMenus

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

-(void) setupUI {
    [self addSubview:self.box];
    [self addSubview:self.splitLineView];
   
    
   
}

- (void)setHiddenItem:(BOOL)hiddenItem {
    if(hiddenItem) {
        [[self.box subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    }else{
        [self.box addSubview:[self itemBtn:LLang(@"点赞") tag:likeTag]];
        [self.box addSubview:[self itemBtn:LLang(@"评论") tag:commentTag]];
       
    }
    [self bringSubviewToFront:self.splitLineView];
    [self refreshLikeTitle];
    [self layoutSubviews];
}

-(void) refreshLikeTitle {
    UIButton *likeBtn = (UIButton*)[self.box viewWithTag:likeTag];
    if(likeBtn) {
        if(self.liked) {
            [likeBtn setTitle:LLang(@"取消") forState:UIControlStateNormal];
        }else{
            [likeBtn setTitle:LLang(@"点赞") forState:UIControlStateNormal];
        }
        [likeBtn sizeToFit];
    }
    
}



- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.box.frame = self.bounds;
    
    NSArray *subviews = self.box.subviews;
    
    CGFloat itemWidth = self.lim_width/subviews.count;
    
    for (NSInteger i=0; i<subviews.count; i++) {
        UIView *v = subviews[i];
        v.lim_size = CGSizeMake(itemWidth, self.lim_height);
        v.lim_left = i*v.lim_width;
    }
    
    self.splitLineView.lim_height = self.lim_height/2.0f;
    self.splitLineView.lim_width = 0.5f;
    self.splitLineView.lim_top = self.lim_height/2.0f - self.splitLineView.lim_height/2.0f;
    self.splitLineView.lim_left = self.lim_width/2.0f - self.splitLineView.lim_width/2.0f;
}

- (UIView *)box {
    if(!_box) {
        _box = [[UIView alloc] init];
        _box.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.8f];
        _box.layer.masksToBounds = YES;
        _box.layer.cornerRadius = 4.0f;
    }
    return _box;
}

- (UIView *)splitLineView {
    if(!_splitLineView) {
        _splitLineView = [[UIView alloc] init];
        _splitLineView.backgroundColor =[WKApp shared].config.tipColor;
    }
    return _splitLineView;
}

-(UIButton*) itemBtn:(NSString*)title tag:(NSInteger)tag {
    UIButton *btn = [[UIButton alloc] init];
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn.titleLabel setFont:[[WKApp shared].config appFontOfSize:14.0f]];
    [btn sizeToFit];
    btn.tag = tag;
    [btn addTarget:self action:@selector(pressed:) forControlEvents:UIControlEventTouchUpInside];
    return btn;
}

-(void) pressed:(UIButton*)btn {
    if(btn.tag == likeTag) {
        if(self.onLike) {
            self.onLike();
        }
    }else if(btn.tag == commentTag) {
        if(self.onComment) {
            self.onComment();
        }
    }
}

@end
