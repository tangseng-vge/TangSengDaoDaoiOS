//
//  WKManagerCell.m
//  WuKongBase
//
//  Created by tt on 2020/4/1.
//

#import "WKManagerCell.h"
#import "UIView+WK.h"
#import "WKConstant.h"
#import "WKApp.h"
#import "UIImageView+WK.h"
@implementation WKManagerModel

- (Class)cell {
    return WKManagerCell.class;
}

@end

@interface WKManagerCell ()

@property(nonatomic,strong) UILabel *nameLbl;

@property(nonatomic,strong) UIImageView *iconImgView;

@property(nonatomic,strong) UIButton *subButton;

@property(nonatomic,strong) WKManagerModel *managerModel;

@end

@implementation WKManagerCell

+(CGSize) sizeForModel:(WKFormItemModel*)model{
    return CGSizeMake(WKScreenWidth, 60.0f);
}

- (void)setupUI {
    [super setupUI];
    
    self.nameLbl = [[UILabel alloc] init];
    [self.nameLbl setFont:[[WKApp shared].config appFontOfSizeMedium:16.0f]];
    [self addSubview:self.nameLbl];
    
    CGFloat iconSize = 40.0f;
    
    self.iconImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, iconSize, iconSize)];
    self.iconImgView.layer.masksToBounds = YES;
    self.iconImgView.layer.cornerRadius = iconSize/2.0f;
    [self addSubview:self.iconImgView];
    // 减号
    self.subButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 20.0f, 20.0f)];
    [self.subButton setImage:[self imageName:@"ManagerSub"] forState:UIControlStateNormal];
    [self addSubview:self.subButton];
    
    [self.subButton addTarget:self action:@selector(onSub) forControlEvents:UIControlEventTouchUpInside];
    
}

-(void) onSub {
    if(self.managerModel.onSub) {
        self.managerModel.onSub();
    }
}

- (void)refresh:(WKManagerModel *)model {
    [super refresh:model];
    self.managerModel = model;
    
    [self.nameLbl setTextColor:[WKApp shared].config.defaultTextColor];
    
    self.nameLbl.text = model.title;
    if(model.icon && [model.icon hasPrefix:@"http"]) {
        [self.iconImgView lim_setImageWithURL:[NSURL URLWithString:model.icon] placeholderImage:[WKApp shared].config.defaultAvatar];
    }else {
        [self.iconImgView setImage:[self imageName:model.icon]];
    }
    
    if(model.showSub) {
        self.subButton.hidden = NO;
    }else {
         self.subButton.hidden = YES;
    }
    
    [self.nameLbl sizeToFit];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.iconImgView.lim_left = 20.0f;
    self.iconImgView.lim_top = self.lim_height/2.0f - self.iconImgView.lim_height/2.0f;
    
    self.nameLbl.lim_left = self.iconImgView.lim_right + 10.0f;
    self.nameLbl.lim_top = self.lim_height/2.0f - self.nameLbl.lim_height/2.0f;
    
    self.subButton.lim_left = self.lim_width - self.subButton.lim_width - 20.0f;
    self.subButton.lim_top = self.lim_height/2.0f - self.subButton.lim_height/2.0f;
}

-(UIImage*) imageName:(NSString*)name {
    return [[WKApp shared] loadImage:name moduleID:@"WuKongGroupManager"];
}

@end

@implementation WKManagerAddModel
- (Class)cell {
    return WKManagerAddCell.class;
}

- (NSNumber *)showArrow {
    return @(false);
}

@end

@interface WKManagerAddCell ()
@property(nonatomic,strong) UILabel *nameLbl;

@property(nonatomic,strong) UIImageView *iconImgView;
@end

@implementation WKManagerAddCell

+(CGSize) sizeForModel:(WKManagerAddModel*)model{
    return CGSizeMake(WKScreenWidth, 60.0f);
}
- (void)setupUI {
    [super setupUI];
     self.nameLbl = [[UILabel alloc] init];
    [self.nameLbl setFont:[[WKApp shared].config appFontOfSize:14.0f]];
    [self addSubview:self.nameLbl];
    
    CGFloat iconSize = 25.0f;
    self.iconImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, iconSize, iconSize)];
    self.iconImgView.layer.masksToBounds = YES;
    self.iconImgView.layer.cornerRadius = iconSize/2.0f;
    [self.iconImgView setImage:[self imageName:@"ManagerAdd"]];
    [self addSubview:self.iconImgView];
}

- (void)refresh:(WKManagerAddModel *)model {
    [super refresh:model];
    self.nameLbl.text = model.title;
    self.nameLbl.textColor = [WKApp shared].config.defaultTextColor;
    [self.nameLbl sizeToFit];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.iconImgView.lim_left = 20.0f;
    self.iconImgView.lim_top = self.lim_height/2.0f - self.iconImgView.lim_height/2.0f;
    self.nameLbl.lim_left = self.iconImgView.lim_right + 10.0f;
    self.nameLbl.lim_top = self.lim_height/2.0f - self.nameLbl.lim_height/2.0f;
}
-(UIImage*) imageName:(NSString*)name {
    return [[WKApp shared] loadImage:name moduleID:@"WuKongGroupManager"];
}
@end
