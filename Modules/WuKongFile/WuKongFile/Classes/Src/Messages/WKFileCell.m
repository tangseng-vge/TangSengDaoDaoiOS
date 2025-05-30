//
//  WKFileCell.m
//  WuKongFile
//
//  Created by tt on 2020/5/5.
//

#import "WKFileCell.h"
#import "WKFileContent.h"
#import "WKFileCommon.h"
#import "WKFileModule.h"
#import "WKFileInfoVC.h"
@interface WKFileCell ()

@property(nonatomic,strong) UIView *fileHeaderView;
@property(nonatomic,strong) UIImageView *fileIconImgView;
@property(nonatomic,strong) UILabel *fileNameLbl;
@property(nonatomic,strong) UILabel *sizeLbl;
@property(nonatomic,strong) UIProgressView *progressView;

// 上传任务
@property(nonatomic,strong) WKMessageFileUploadTask *uploadTask;

@end

@implementation WKFileCell

+ (CGSize)contentSizeForMessage:(WKMessageModel *)model {
    return CGSizeMake(250.0f,66.0f);
}
- (void)initUI {
    [super initUI];
    
    self.fileHeaderView = [[UIView alloc] init];
    [self.fileHeaderView setBackgroundColor:[UIColor blueColor]];
    self.fileHeaderView.userInteractionEnabled = NO;
    [self.messageContentView addSubview:self.fileHeaderView];
    
    self.fileIconImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 36.0f, 36.0f)];
    [self.fileHeaderView addSubview:self.fileIconImgView];
    
    self.fileNameLbl = [[UILabel alloc] init];
    [self.fileNameLbl setFont:[UIFont systemFontOfSize:15.0f]];
    [self.messageContentView addSubview:self.fileNameLbl];
    
    self.sizeLbl = [[UILabel alloc] init];
    [self.sizeLbl setFont:[UIFont systemFontOfSize:12.0f]];
   
   
    [self.messageContentView addSubview:self.sizeLbl];
    
    [self.messageContentView addSubview:self.progressView];
}

- (UIProgressView *)progressView {
    if(!_progressView) {
        _progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 0.0f, 20.0f)];
    }
    return _progressView;
}

-(void) setFileHeaderCorner {
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.fileHeaderView.bounds byRoundingCorners:UIRectCornerTopLeft | UIRectCornerBottomLeft cornerRadii:CGSizeMake(5, 5)];
     CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
     maskLayer.frame = self.fileHeaderView.bounds;
     maskLayer.path = maskPath.CGPath;
     self.fileHeaderView.layer.mask = maskLayer;
}

- (void)refresh:(WKMessageModel *)model {
    [super refresh:model];
    
    WKFileContent *content = (WKFileContent*)model.content;
    self.fileNameLbl.text =content.name;
    self.sizeLbl.text = [[WKFileCommon shared] sizeFormat:content.size];
    
   WKFileInfoModel *fileModel = [[WKFileCommon shared] fileInfoWithName:content.name];
   [self.fileHeaderView setBackgroundColor:fileModel.fileColor];
    [self.fileIconImgView setImage:[self imageName:fileModel.extendIcon]];
    
    if(model.isSend) {
        self.fileNameLbl.textColor = [WKApp shared].config.messageSendTextColor;
        self.sizeLbl.textColor = [WKApp shared].config.messageTipColor;
    }else{
        self.fileNameLbl.textColor = [WKApp shared].config.messageRecvTextColor;
        [self.sizeLbl setTextColor:[UIColor grayColor]];
    }
    
    // 更新上传进度
    [self updateProgress];
}

- (void)onTap {
    [super onTap];
    WKFileInfoVC *fileInfo = [WKFileInfoVC new];
    fileInfo.fileMessage = self.messageModel;
    [[WKNavigationManager shared] pushViewController:fileInfo animated:YES];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.fileHeaderView.lim_height =self.messageContentView.lim_height;
    self.fileHeaderView.lim_width = self.messageContentView.lim_height;
    [self setFileHeaderCorner];
    
    self.fileIconImgView.lim_top = self.fileHeaderView.lim_height/2.0f - self.fileIconImgView.lim_height/2.0f;
    self.fileIconImgView.lim_left = self.fileHeaderView.lim_width/2.0f - self.fileIconImgView.lim_width/2.0f;
    
    CGFloat fileHeaderRightSpace = 10.0f;
    self.fileNameLbl.lim_left = self.fileHeaderView.lim_right + fileHeaderRightSpace;
    self.fileNameLbl.lim_top = 10.0f;
    self.fileNameLbl.lim_height = 20.0f;
    self.fileNameLbl.lim_width = self.messageContentView.lim_width - (self.fileHeaderView.lim_right + fileHeaderRightSpace) - 10.0f;
    
    self.sizeLbl.lim_height = 16.0f;
    self.sizeLbl.lim_width = self.fileNameLbl.lim_width;
    self.sizeLbl.lim_top = self.messageContentView.lim_height - self.sizeLbl.lim_height - 10.0f;
    self.sizeLbl.lim_left = self.fileNameLbl.lim_left;
    
    self.progressView.lim_left = self.fileHeaderView.lim_width;
    self.progressView.lim_width = self.messageContentView.lim_width - self.fileHeaderView.lim_width - 7.0f;
    self.progressView.lim_top = self.fileHeaderView.lim_height - self.progressView.lim_height;
    
    self.trailingView.lim_top = self.messageContentView.lim_bottom - self.trailingView.lim_height - 5.0f;
    self.trailingView.lim_left = self.messageContentView.lim_width - self.trailingView.lim_width - 5.0f;
}


// 更新上传进度
-(void) updateProgress {
      __weak typeof(self) weakSelf = self;
    // 上传进度控制
    self.uploadTask = [[WKSDK shared] getMessageFileUploadTask:self.messageModel.message];
    if(self.uploadTask) {
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
                weakSelf.progressView.hidden = YES;
               [weakSelf.progressView setProgress:0];
            }
        } target:self];
       
    }else {
        self.progressView.hidden = YES;
        [self.progressView setProgress:0];
    }
}



// 正文边距
+(UIEdgeInsets) contentEdgeInsets:(WKMessageModel*)model {
    return UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f);
}

-(UIImage*) imageName:(NSString*)name {
    return [[WKApp shared] loadImage:name moduleID:[WKFileModule gmoduleId]];
}



@end
