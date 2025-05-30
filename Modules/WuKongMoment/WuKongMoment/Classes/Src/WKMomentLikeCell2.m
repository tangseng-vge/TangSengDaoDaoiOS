//
//  WKMomentLikeCell2.m
//  WuKongMoment
//
//  Created by tt on 2020/11/17.
//

#import "WKMomentLikeCell2.h"
#import "WKMomentModule.h"
#define avatarSize 25.0f
#define avatarColSpace 5.0f // 列间距离

#define leftSpace 15.0f

#define likeIconSize 16.0f
#define likeIconLeft 15.0f

#define likeIconWidth (likeIconSize + likeIconLeft*2)


#define likeBoxWidth (WKScreenWidth - leftSpace*2 - likeIconWidth -10.0f)
#define likeBoxTopSpace 5.0f



@implementation WKMomentLikeModel2

- (Class)cell {
    return WKMomentLikeCell2.class;
}

@end

@interface WKMomentLikeCell2 ()

@property(nonatomic,strong) UIView *boxView;
@property(nonatomic,strong) UIView *likeBox;
@property(nonatomic,strong) UIImageView *likeIcon;

@property(nonatomic,strong) WKMomentLikeModel2 *model;

@end

@implementation WKMomentLikeCell2

+ (CGSize)sizeForModel:(WKMomentLikeModel2 *)model {
    NSArray<WKMomentLikeUser*> *users = model.users;
    NSInteger width = users.count * (avatarSize+avatarColSpace) - avatarColSpace;
    NSInteger row = width/likeBoxWidth;
    if(width%(NSInteger)likeBoxWidth != 0) {
        row++;
    }
    return CGSizeMake(WKScreenWidth, row*(avatarSize+avatarColSpace)-avatarColSpace + likeBoxTopSpace*2);
}

- (void)setupUI {
    [super setupUI];
    [self.contentView addSubview:self.boxView];
    [self.boxView addSubview:self.likeBox];
    [self.boxView addSubview:self.likeIcon];
}

- (void)refresh:(WKMomentLikeModel2 *)model {
    [super refresh:model];
    self.model = model;
    
    if([WKApp shared].config.style == WKSystemStyleDark) {
        self.likeBox.backgroundColor = [UIColor colorWithRed:32.0f/255.0f green:32.0f/255.0f blue:32.0f/255.0f alpha:1.0f];
    }else{
        self.likeBox.backgroundColor = [WKApp shared].config.backgroundColor;
    }
    
    [[self.likeBox subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    if(model.users && model.users.count>0) {
        NSInteger i = 0;
        for (WKMomentLikeUser *user in model.users) {
            [self.likeBox addSubview:[self newAvatarImgView:user.uid index:i]];
            i++;
        }
    }
    
    
    
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.boxView.lim_width = WKScreenWidth - leftSpace*2;
    self.boxView.lim_height = self.contentView.lim_height;
    self.boxView.lim_left = leftSpace;
    
    self.likeBox.lim_top = likeBoxTopSpace;
    self.likeBox.lim_width = likeBoxWidth;
    self.likeBox.lim_height = self.boxView.lim_height;
    self.likeBox.lim_left = likeIconWidth;
    
    self.likeIcon.lim_left = likeIconLeft;
    self.likeIcon.lim_top = 10.0f;
    
    NSArray *subviews = self.likeBox.subviews;
    UIView *preView;
    for (UIView *view in subviews) {
        if(!preView) {
            view.lim_left = 0.0f;
            view.lim_top = 0.0f;
        }else{
            CGFloat left = preView.lim_right + avatarColSpace;
            CGFloat top = preView.lim_top;
            if(preView.lim_right  + avatarSize + avatarColSpace>likeBoxWidth) {
                left = 0.0f;
                top =  preView.lim_bottom + avatarColSpace;
            }
            view.lim_left = left;
            view.lim_top =  top;
        }
        preView = view;
    }
    
    
}

-(UIImageView*) newAvatarImgView:(NSString*)uid index:(NSInteger)index{
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, avatarSize, avatarSize)];
    [imgView lim_setImageWithURL:[NSURL URLWithString:[WKAvatarUtil getAvatar:uid]] placeholderImage:[WKApp shared].config.defaultAvatar];
    imgView.layer.masksToBounds = YES;
    imgView.layer.cornerRadius = imgView.lim_width/2.0f;
    imgView.userInteractionEnabled = YES;
    imgView.tag = index;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onAvatarTap:)];
    [imgView addGestureRecognizer:tap];
    return imgView;
}
-(void) onAvatarTap:(UITapGestureRecognizer*)tap {
    UIView *view = tap.view;
    WKMomentLikeUser *user =  self.model.users[view.tag];
    [[WKApp shared] invoke:WKPOINT_USER_INFO param:@{@"uid":user.uid?:@""}];
}

- (UIView *)likeBox {
    if(!_likeBox) {
        _likeBox = [[UIView alloc] init];
        [_likeBox setBackgroundColor:[UIColor clearColor]];
    }
    return _likeBox;
}

- (UIImageView *)likeIcon {
    if(!_likeIcon) {
        _likeIcon = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, likeIconSize, likeIconSize)];
        _likeIcon.image = [self imageName:@"Like"];
    }
    return _likeIcon;
}

- (UIView *)boxView {
    if(!_boxView) {
        _boxView = [[UIView alloc] init];
        _boxView.backgroundColor = [UIColor colorWithRed:247.0f/255.0f green:247.0f/255.0f blue:247.0f/255.0f alpha:1.0f];
    }
    return _boxView;
}

- (UIImage*) imageName:(NSString*)name {
    return [[WKApp shared] loadImage:name moduleID:[WKMomentModule gmoduleId]];
}
@end
