//
//  WKMergeForwardDetailVideoCell.m
//  WuKongSmallVideo
//
//  Created by tt on 2023/2/21.
//

#import "WKMergeForwardDetailVideoCell.h"
#import "WKSmallVideoContent.h"
#import "WKSmallVideoModule.h"
#import <YBImageBrowser/YBImageBrowser.h>
#import "WKVideoData.h"
#import "WKDefaultWebImageMediator.h"

//----------视频cell ----------

@implementation WKMergeForwardDetailVideoModel


- (Class)cell {
    return WKMergeForwardDetailVideoCell.class;
}

@end

@interface WKMergeForwardDetailVideoCell ()

@property(nonatomic,strong) WKImageView *coverImgView;

@property(nonatomic,strong) WKSmallVideoContent *smallVideoContent;
@property(nonatomic,strong) WKMessage *message;

@property(nonatomic,strong) UIButton *playButton;

@property(nonatomic,strong) UIView *durationBoxView;
@property(nonatomic,strong) UILabel *durationLbl;

@end

@implementation WKMergeForwardDetailVideoCell

+ (CGFloat)contentHeightForModel:(WKMergeForwardDetailVideoModel *)model maxWidth:(CGFloat)maxWidth{
    WKSmallVideoContent *content = (WKSmallVideoContent*)model.message.content;
    
    CGSize size = [self videoSize:CGSizeMake(content.width, content.height)];
    return size.height;
}

+(CGSize) videoSize:(CGSize)orgSize {
    return [UIImage lim_sizeWithImageOriginSize:CGSizeMake(orgSize.width, orgSize.height) maxLength:200.0f];
}

- (void)setupUI {
    [super setupUI];
    
    
    [self.messageContentView addSubview:self.coverImgView];

    [self.messageContentView addSubview:self.playButton];
    
    [self.durationBoxView addSubview:self.durationLbl];
    [self.messageContentView addSubview:self.durationBoxView];
    
    self.messageContentView.userInteractionEnabled = YES;
    [self.messageContentView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTap)]];
}

- (void)refresh:(WKMergeForwardDetailVideoModel *)model {
    [super refresh:model];
    self.message = model.message;
    self.smallVideoContent = (WKSmallVideoContent*)model.message.content;
    
    if([[NSFileManager defaultManager] fileExistsAtPath:[self.smallVideoContent coverLocalPath]]) {
        [self.coverImgView lim_setImageWithURL:[NSURL fileURLWithPath:[self.smallVideoContent coverLocalPath]]];
    }else {
         [self.coverImgView loadImage:[[WKApp shared] getImageFullUrl:self.smallVideoContent.cover] placeholderImage:[self imageName:@"DefaultVideo"]];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGSize contentSize =  [[self class] videoSize:CGSizeMake(self.smallVideoContent.width, self.smallVideoContent.height)];
    
    self.coverImgView.lim_size = contentSize;

    
    self.playButton.lim_top = contentSize.height/2.0f - self.playButton.lim_height/2.0f;
    self.playButton.lim_left = contentSize.width/2.0f - self.playButton.lim_width/2.0f;
    
    self.durationBoxView.lim_size = CGSizeMake(self.durationLbl.lim_width+8.0f, self.durationLbl.lim_height+2.0f);
    self.durationLbl.lim_centerX_parent = self.durationBoxView;
    self.durationLbl.lim_centerY_parent = self.durationBoxView;
    self.durationBoxView.lim_top = 4.0f;
    self.durationBoxView.lim_left = 4.0f;
    self.durationBoxView.layer.cornerRadius = self.durationBoxView.lim_height/2.0f;
    
    
    
}

-(void) onTap {
    __weak typeof(self) weakSelf = self;
    WKBrowserToolbar *toolbar = WKBrowserToolbar.new;
    WKImageBrowser *imageBrowser = [[WKImageBrowser alloc] init];
    imageBrowser.webImageMediator = [WKDefaultWebImageMediator new];
    toolbar.browser = imageBrowser;
    imageBrowser.toolViewHandlers = @[toolbar];
    WKVideoData *data = [WKVideoData new];
    data.autoPlayCount = 1;
    data.thumbImage = self.coverImgView.image;
//    data.extraData = @{@"message":self.message};
    
    WKMessageFileDownloadTask *task =  [[WKSDK shared] getMessageDownloadTask:self.message];
    if(!task) {
        task =  [[WKSDK shared].mediaManager download:weakSelf.message];
    }
    data.downloadTask = task;
    
    imageBrowser.dataSourceArray = @[data];
    imageBrowser.currentPage = 0;
    [imageBrowser showToView:[WKApp.shared findWindow]];
}


- (WKImageView *)coverImgView {
    if(!_coverImgView) {
        _coverImgView = [[WKImageView alloc] init];
        _coverImgView.layer.maskedCorners = YES;
        _coverImgView.layer.cornerRadius = 4.0f;
    }
    return _coverImgView;
}

- (UIButton *)playButton {
    if(!_playButton) {
        // play
        _playButton = [[UIButton alloc] init];
        [_playButton setUserInteractionEnabled:NO];
        [_playButton setImage:[self imageName:@"Play"] forState:UIControlStateNormal];
        [_playButton sizeToFit];
    }
    return _playButton;
}


- (UILabel *)durationLbl {
    if(!_durationLbl) {
        _durationLbl = [[UILabel alloc] init];
        _durationLbl.font = [[WKApp shared].config appFontOfSize:10.0f];
        _durationLbl.textColor = [UIColor whiteColor];
    }
    return _durationLbl;
}
- (UIView *)durationBoxView {
    if(!_durationBoxView) {
        _durationBoxView = [[UIView alloc] init];
        _durationBoxView.backgroundColor = [UIColor colorWithRed:0.0f/255.0f green:0.0f/255.0f blue:0.0f/255.0f alpha:0.2f];
        _durationBoxView.layer.masksToBounds = YES;
    }
    return _durationBoxView;
}

-(UIImage*) imageName:(NSString*)name{
    return [[WKApp shared] loadImage:name moduleID:[WKSmallVideoModule gmoduleId]];
}

@end
