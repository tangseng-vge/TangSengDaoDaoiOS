//
//  WKSmallVideoCell.m
//  WuKongSmallVideo
//
//  Created by tt on 2020/4/30.
//

#import "WKSmallVideoCell.h"
#import "WKSmallVideoContent.h"
#import "UIImage+WK.h"
#import "WKImageView.h"
#import "WKSmallVideoModule.h"
#import <YBImageBrowser/YBImageBrowser.h>
#import "WKVideoData.h"
#import "WKDefaultWebImageMediator.h"

#import "WKLoadProgressView.h"
@interface WKSmallVideoCell ()
@property(nonatomic,strong) WKImageView *coverImgView;
@property(nonatomic,strong) UIButton *playButton;

@property(nonatomic,strong) WKLoadProgressView *progressView;

// 上传任务
@property(nonatomic,strong) WKMessageFileUploadTask *uploadTask;

@property(nonatomic,strong) UIView *durationBoxView;
@property(nonatomic,strong) UILabel *durationLbl;


@end

@implementation WKSmallVideoCell

+ (CGSize)contentSizeForMessage:(WKMessageModel *)model {
    WKSmallVideoContent *smallVideoContent = (WKSmallVideoContent*)model.content;
    return [UIImage lim_sizeWithImageOriginSize:CGSizeMake(smallVideoContent.width, smallVideoContent.height) maxLength:200.0f];
}

- (void)initUI {
    [super initUI];
    // cover
    self.coverImgView = [[WKImageView alloc] init];
    self.coverImgView.layer.masksToBounds = YES;
    self.coverImgView.layer.cornerRadius = 4.0f;
    [self.messageContentView addSubview:self.coverImgView];
    
    // play
    self.playButton = [[UIButton alloc] init];
    [self.playButton setUserInteractionEnabled:NO];
    [self.playButton setImage:[self imageName:@"Play"] forState:UIControlStateNormal];
    [self.playButton sizeToFit];
    
    [self.durationBoxView addSubview:self.durationLbl];
    [self.messageContentView addSubview:self.durationBoxView];
    
    [self.messageContentView addSubview:self.playButton];
    
    [self.messageContentView addSubview:self.progressView];
    
    [self.messageContentView bringSubviewToFront:self.trailingView];
}

- (void)refresh:(WKMessageModel *)model {
    [super refresh:model];
    
//    self.trailingView.timeLbl.textColor = [UIColor whiteColor];
    
    WKSmallVideoContent *smallVideoContent = (WKSmallVideoContent*)model.content;
    if([[NSFileManager defaultManager] fileExistsAtPath:[smallVideoContent coverLocalPath]]) {
        [self.coverImgView lim_setImageWithURL:[NSURL fileURLWithPath:[smallVideoContent coverLocalPath]]];
    }else {
         [self.coverImgView loadImage:[[WKApp shared] getImageFullUrl:smallVideoContent.cover] placeholderImage:[self imageName:@"DefaultVideo"]];
    }
    self.durationLbl.text = [self formatSecond:smallVideoContent.second];
    [self.durationLbl sizeToFit];
    
    [self updateProgress];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.coverImgView.lim_size = self.messageContentView.lim_size;
    
    self.progressView.frame = self.messageContentView.bounds;
    
    self.playButton.lim_top = self.messageContentView.lim_height/2.0f - self.playButton.lim_height/2.0f;
    self.playButton.lim_left = self.messageContentView.lim_width/2.0f - self.playButton.lim_width/2.0f;
    
    self.durationBoxView.lim_size = CGSizeMake(self.durationLbl.lim_width+8.0f, self.durationLbl.lim_height+2.0f);
    self.durationLbl.lim_centerX_parent = self.durationBoxView;
    self.durationLbl.lim_centerY_parent = self.durationBoxView;
    self.durationBoxView.lim_top = 4.0f;
    self.durationBoxView.lim_left = 4.0f;
    self.durationBoxView.layer.cornerRadius = self.durationBoxView.lim_height/2.0f;
    
//    self.trailingView.lim_top = self.messageContentView.lim_top + self.messageContentView.lim_height - self.trailingView.lim_height - 5.0f;
}

- (BOOL)tailWrap {
    return true;
}
+(BOOL) hiddenBubble {
    return YES;
}

-(NSString*) formatSecond:(NSInteger)second {
    int minute = (int)second/60;
    int s = second%60;
    return [NSString stringWithFormat:@"%02d:%02d",minute,s];
}

// 更新上传进度
-(void) updateProgress {
    self.playButton.hidden = YES;
      __weak typeof(self) weakSelf = self;
    // 上传进度控制
    self.uploadTask = [[WKSDK shared] getMessageFileUploadTask:self.messageModel.message];
    if(self.uploadTask && [self.uploadTask isKindOfClass:[WKMessageFileUploadTask class]]) {
        [self.uploadTask addListener:^{
            if(weakSelf.uploadTask.status == WKTaskStatusProgressing) {
                if (![NSThread isMainThread]) {
                     dispatch_sync(dispatch_get_main_queue(), ^{
                         weakSelf.progressView.hidden = NO;
                         [weakSelf.progressView setProgress:weakSelf.uploadTask.progress];
                     });
                 }else {
                     weakSelf.progressView.hidden = NO;
                     [weakSelf.progressView setProgress:weakSelf.uploadTask.progress];
                 }
                
            }else {
                weakSelf.playButton.hidden = NO;
                weakSelf.progressView.hidden = YES;
               [weakSelf.progressView setProgress:0];
            }
        } target:self];
       
    }else {
        self.playButton.hidden = NO;
        self.progressView.hidden = YES;
        [self.progressView setProgress:0];
    }
}
-(WKLoadProgressView*) progressView {
    if(!_progressView) {
        _progressView = [[WKLoadProgressView alloc] initWithFrame:CGRectMake(18, 0, 44, 44)];
        _progressView.maxProgress = 1.0f;
        _progressView.hidden = NO;
        _progressView.layer.masksToBounds = YES;
        _progressView.layer.cornerRadius = 4.0f;
        _progressView.backgroundColor =
        [UIColor colorWithRed:0.6 green:0.6 blue:0.6 alpha:0.7];
    }
    return _progressView;
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

-(void) onTap {
    [super onTap];
    if(!self.messageModel) {
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    WKBrowserToolbar *toolbar = WKBrowserToolbar.new;
    WKImageBrowser *imageBrowser = [[WKImageBrowser alloc] init];
    imageBrowser.webImageMediator = [WKDefaultWebImageMediator new];
    toolbar.browser = imageBrowser;
    imageBrowser.toolViewHandlers = @[toolbar];
    WKVideoData *data = [WKVideoData new];
    data.autoPlayCount = 1;
    data.thumbImage = self.coverImgView.image;
    data.extraData = @{@"message":self.messageModel};
    
    WKMessageFileDownloadTask *task =  [[WKSDK shared] getMessageDownloadTask:self.messageModel.message];
    if(!task) {
        task =  [[WKSDK shared].mediaManager download:weakSelf.messageModel.message];
    }
    data.downloadTask = task;
    
    imageBrowser.dataSourceArray = @[data];
    imageBrowser.currentPage = 0;
    [imageBrowser showToView:[WKApp.shared findWindow]];
    
}

-(UIImage*) imageName:(NSString*)name{
    return [[WKApp shared] loadImage:name moduleID:[WKSmallVideoModule gmoduleId]];
}

@end
