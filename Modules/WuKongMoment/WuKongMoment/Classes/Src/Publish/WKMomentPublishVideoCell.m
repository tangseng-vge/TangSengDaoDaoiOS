//
//  WKMomentPublishVideoCell.m
//  WuKongMoment
//
//  Created by tt on 2020/11/12.
//

#import "WKMomentPublishVideoCell.h"
#import "WKMomentModule.h"
@implementation WKMomentPublishVideoModel

- (Class)cell {
    return WKMomentPublishVideoCell.class;
}

@end

@interface WKMomentPublishVideoCell ()

@property(nonatomic,strong) UIImageView *coverImgView;

@property(nonatomic,strong) UIImageView *playImgView;

@property(nonatomic,strong) WKMomentPublishVideoModel *model;
@property(nonatomic,strong) WKLoadProgressView *progessView;

@end

@implementation WKMomentPublishVideoCell

+ (CGSize)sizeForModel:(WKMomentPublishVideoModel *)model {
    CGFloat height = 0.0f;
    if(model.videoTask.image.size.width>model.videoTask.image.size.height) {
        height = 144.0f;
    }else{
        height = 240.0f;
    }
    
    return CGSizeMake(WKScreenWidth, height);
}

- (void)setupUI {
    [super setupUI];
    [self.contentView addSubview:self.coverImgView];
    [self.contentView addSubview:self.playImgView];
    [self.coverImgView addSubview:self.progessView];
    
    self.coverImgView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTap)];
    [self.coverImgView addGestureRecognizer:tap];
    
}


- (void)refresh:(WKMomentPublishVideoModel *)model {
    [super refresh:model];
    self.model = model;
    
    [model.videoTask removeListener:self];
    self.playImgView.hidden = YES;
    if(model.videoTask.status != WKMomentTaskStatusSuccess) {
        self.progessView.hidden = NO;
        [self.progessView setProgress:0.0f];
        __weak typeof(model) weakModel = model;
        __weak typeof(self) weakSelf = self;
        [model.videoTask addListener:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                if(weakModel.videoTask.status == WKMomentTaskStatusSuccess) {
                    weakSelf.progessView.hidden = YES;
                    weakSelf.playImgView.hidden = NO;
                }else{
                    [weakSelf.progessView setProgress:weakModel.videoTask.progress];
                }
            });
            
            
        } target:self];
    }else{
        self.playImgView.hidden = NO;
        self.progessView.hidden = YES;
    }
    
    [self.coverImgView setImage:model.videoTask.image];
    [self.playImgView setImage:[self imageName:@"Play"]];
    
   
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    
    CGFloat imgWidth = 0.0f;
    if (self.model.videoTask.image.size.width > self.model.videoTask.image.size.height) {
        imgWidth = 255.0f;
    } else {
        imgWidth = 172.0f;
    }
    
    self.coverImgView.lim_size = CGSizeMake(imgWidth, self.lim_height);
    self.coverImgView.lim_left = 20.0f;
    
    self.playImgView.lim_left = self.coverImgView.lim_left +( self.coverImgView.lim_width/2.0f - self.playImgView.lim_width/2.0f);
    self.playImgView.lim_centerY_parent = self.contentView;
    
    self.progessView.lim_size = self.coverImgView.lim_size;
    
}

-(void) onTap {
    WKImageBrowser *imageBrowser = [[WKImageBrowser alloc] init];
    imageBrowser.toolViewHandlers = @[WKBrowserToolbar.new];
    imageBrowser.webImageMediator = [WKDefaultWebImageMediator new];
    
    
    WKVideoBrowserData *data = [WKVideoBrowserData new];
    data.coverImage = self.coverImgView.image;
    __weak typeof(self) weakSelf = self;
    data.download = ^(void (^ _Nonnull downCompleteBlock)(NSString * videoPath, NSError * err)) {
        downCompleteBlock(weakSelf.model.videoTask.videoPath,nil);
    };
    imageBrowser.dataSourceArray = @[data];
    imageBrowser.currentPage = 0;
    [imageBrowser show];
}

- (UIImageView *)coverImgView {
    if(!_coverImgView) {
        _coverImgView = [[UIImageView alloc] init];
        _coverImgView.contentMode = UIViewContentModeScaleAspectFill;
        _coverImgView.clipsToBounds = YES;
    }
    return _coverImgView;
}

- (UIImageView *)playImgView {
    if(!_playImgView) {
        _playImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 32.0f, 32.0f)];
    }
    return _playImgView;
}

- (WKLoadProgressView *)progessView {
    if(!_progessView) {
        _progessView = [[WKLoadProgressView alloc] init];
        _progessView.maxProgress = 1.0f;
    }
    return _progessView;
}

- (UIImage*) imageName:(NSString*)name {
    return [[WKApp shared] loadImage:name moduleID:[WKMomentModule gmoduleId]];
}

@end
