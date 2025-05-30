//
//  WKMomentContentVideoCell.m
//  WuKongMoment
//
//  Created by tt on 2020/11/24.
//

#import "WKMomentContentVideoCell.h"
#import "WKMomentConst.h"
#import "WKMomentModule.h"
#import <WuKongBase/WKVideoData.h>
@implementation WKMomentContentVideoModel

- (Class)cell {
    return WKMomentContentVideoCell.class;
}
@end

@interface WKMomentContentVideoCell ()

@property(nonatomic,strong) UIImageView *avatarImgView; // 头像
@property(nonatomic,strong) UILabel *nameLbl; // 名字

@property(nonatomic,strong) M80AttributedLabel *contentLbl; // 朋友圈文字内容

@property(nonatomic,strong) UIImageView *coverImgView;
@property(nonatomic,strong) UIImageView *playIconImgView;

@property(nonatomic,strong) WKMomentContentVideoModel *model;

@property(nonatomic,strong) NSURLSessionDownloadTask *downloadTask;

@end

@implementation WKMomentContentVideoCell

+ (CGSize)sizeForModel:(WKMomentContentVideoModel *)model {
    CGFloat contentHeight = 0.0f;
    if(model.content) {
        contentHeight = [self getMomentContentLabelSize:model fontSie:contentFontSize].height;
    }
   CGFloat height = [self getImgSizeWithPath:model.videoCoverURL].height;
    return CGSizeMake(WKScreenWidth, height + contentHeight +  nameTopSpace + nameHeight + contentTopSpace+cellTopSpace);
}

- (void)setupUI {
    [super setupUI];
    [self.contentView addSubview:self.coverImgView];
    [self.contentView addSubview:self.playIconImgView];
    [self.contentView addSubview:self.avatarImgView];
    [self.contentView addSubview:self.nameLbl];
    
    [self.contentView addSubview:self.contentLbl];
}

- (void)refresh:(WKMomentContentVideoModel *)model {
    [super refresh:model];
    self.model = model;
    
    self.contentLbl.backgroundColor = [UIColor clearColor];
    self.contentLbl.textColor = [WKApp shared].config.defaultTextColor;
    [self.contentLbl lim_setText:model.content];
    
    [self.avatarImgView lim_setImageWithURL:[NSURL URLWithString:model.avatar] placeholderImage:[WKApp shared].config.defaultAvatar];
    WKChannelInfo *channelInfo = [[WKSDK shared].channelManager getChannelInfo:[WKChannel personWithChannelID:model.uid]];
    self.nameLbl.text = model.name;
    if(channelInfo) {
        self.nameLbl.text = channelInfo.displayName;
    }
    
    [self.coverImgView lim_setImageWithURL:[WKApp.shared getImageFullUrl:model.videoCoverURL] placeholderImage:[WKApp shared].config.defaultPlaceholder];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.avatarImgView.lim_left = avatarLeftSpace;
    self.avatarImgView.lim_top = cellTopSpace;
    
    self.nameLbl.lim_left = self.avatarImgView.lim_right + nameLeftSpace;
    self.nameLbl.lim_top =  nameTopSpace + cellTopSpace;
    
    CGFloat contentWidth = contentMaxWidth;
    self.nameLbl.lim_width = contentWidth;
    
    if(!self.model.content||[self.model.content isEqualToString:@""]) {
        self.contentLbl.lim_top = self.nameLbl.lim_bottom;
        self.contentLbl.lim_left = self.nameLbl.lim_left;
    }else{
        self.contentLbl.lim_width = contentWidth;
        self.contentLbl.lim_left = self.nameLbl.lim_left;
        self.contentLbl.lim_top = self.nameLbl.lim_bottom + contentTopSpace;
    }
    CGFloat contentHeight  = [[self class] getMomentContentLabelSize:self.model fontSie:contentFontSize].height;
    self.contentLbl.lim_height = contentHeight;
    
    CGSize coverImgSize = [[self class] getImgSizeWithPath:self.model.videoCoverURL];
    
    self.coverImgView.lim_top = self.contentLbl.lim_bottom + contentTopSpace;
    self.coverImgView.lim_left = self.contentLbl.lim_left;
    self.coverImgView.lim_size = coverImgSize;
    
    self.playIconImgView.lim_left = self.coverImgView.lim_left + ( self.coverImgView.lim_width/2.0f - self.playIconImgView.lim_width/2.0f);
    self.playIconImgView.lim_top = self.coverImgView.lim_top + (self.coverImgView.lim_height/2.0f - self.playIconImgView.lim_height/2.0f);
    
    
    
}

- (UIImageView *)coverImgView {
    if(!_coverImgView) {
        _coverImgView = [[UIImageView alloc] init];
        _coverImgView.contentMode = UIViewContentModeScaleAspectFill;
        _coverImgView.clipsToBounds = YES;
        _coverImgView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTap)];
        [_coverImgView addGestureRecognizer:tap];
    }
    return _coverImgView;
}

-(void) onTap {
    
    YBImageBrowser *imageBrowser = [[YBImageBrowser alloc] init];
    imageBrowser.webImageMediator = [WKDefaultWebImageMediator new];
    imageBrowser.toolViewHandlers = @[WKBrowserToolbar.new];
    WKVideoData *data = [WKVideoData new];
    data.autoPlayCount = 1;
    data.thumbImage = self.coverImgView.image;
    NSString *tempDir= [WKApp shared].config.videoCacheDir;
    
    NSString *videoFile = [tempDir stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_video.mp4",self.model.sid]];
    __weak typeof(self) weakSelf = self;
    
    NSString *taskID = [NSString stringWithFormat:@"moment-%@",weakSelf.model.sid];
    id<WKTaskProto> task = [WKSDK.shared.mediaManager.taskManager get:taskID];
    if(!task) {
        task = [[WKDowloadTask alloc] initWithURL:[[WKApp.shared getFileFullUrl:weakSelf.model.videoURL] absoluteString] storePath:videoFile];
        task.taskId = taskID;
        [[WKSDK shared].mediaManager.taskManager add:task];
        
    }
    data.downloadTask = task;
    

    imageBrowser.dataSourceArray = @[data];
    imageBrowser.currentPage = 0;
    [imageBrowser show];
    
    
//    YBImageBrowser *imageBrowser = [[YBImageBrowser alloc] init];
//    imageBrowser.toolViewHandlers = @[WKBrowserToolbar.new];
//    imageBrowser.webImageMediator = [WKDefaultWebImageMediator new];
//    WKVideoBrowserData *data = [WKVideoBrowserData new];
//    data.coverImage = self.coverImgView.image;
//    __weak typeof(self) weakSelf = self;
//    __weak typeof(data) weakData = data;
//    NSString *tempDir= NSTemporaryDirectory();
//    NSString *videoTmpFile = [tempDir stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_tmp",weakSelf.model.sid]];
//    NSString *videoFile = [tempDir stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_video.mp4",weakSelf.model.sid]];
//    data.download = ^(void (^ _Nonnull downCompleteBlock)(NSString * videoPath, NSError * err)) {
//        if( [WKFileUtil fileIsExistOfPath:videoFile]) {
//            downCompleteBlock(videoFile,nil);
//            return;
//        }
//        if(!self.downloadTask) {
//
//            self.downloadTask = [[WKAPIClient sharedClient] createDownloadTask:[[WKApp.shared getFileFullUrl:weakSelf.model.videoURL] absoluteString] storePath:videoTmpFile progress:^(NSProgress * _Nullable downloadProgress) {
//                if(weakData) {
//                    weakData.progress(downloadProgress.fractionCompleted);
//                }
//           } completeCallback:^(NSError * _Nullable error) {
//               if(error!=nil) {
//                   NSLog(@"下载视频失败！-> %@",error);
//               }else{
//                   [WKFileUtil moveFileFromPath:videoTmpFile toPath:videoFile];
//                   downCompleteBlock(videoFile,nil);
//               }
//               weakSelf.downloadTask = nil;
//           }];
//        }
//        [self.downloadTask resume];
//
//    };
//    imageBrowser.dataSourceArray = @[data];
//    imageBrowser.currentPage = 0;
//    [imageBrowser show];
}

- (NSString *)uuidString{
    
    CFUUIDRef uuid_ref = CFUUIDCreate(NULL);
    CFStringRef uuid_string_ref= CFUUIDCreateString(NULL, uuid_ref);
    NSString *uuid = [NSString stringWithString:(__bridge NSString *)uuid_string_ref];
    CFRelease(uuid_ref);
    CFRelease(uuid_string_ref);
    
    //去除UUID ”-“
    NSString *UUID = [[uuid lowercaseString] stringByReplacingOccurrencesOfString:@"-" withString:@""];

    return UUID;
}

- (UIImageView *)playIconImgView {
    if(!_playIconImgView) {
        _playIconImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 36.0f, 36.0f)];
        _playIconImgView.image = [self imageName:@"Play"];
    }
    return _playIconImgView;
}

- (UIImageView *)avatarImgView {
    if(!_avatarImgView) {
        _avatarImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, avatarSize, avatarSize)];
        _avatarImgView.layer.masksToBounds = YES;
        _avatarImgView.layer.cornerRadius = avatarSize/2.0f;
        
        _avatarImgView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onAvatarTap)];
        [_avatarImgView addGestureRecognizer:tap];
    
    }
    return _avatarImgView;
}
-(void) onAvatarTap {
    [[WKApp shared] invoke:WKPOINT_USER_INFO param:@{@"uid":self.model.uid?:@""}];
}

- (M80AttributedLabel *)contentLbl {
    if(!_contentLbl) {
        _contentLbl = [[M80AttributedLabel alloc] init];
        _contentLbl.numberOfLines = 0;
        _contentLbl.lineBreakMode = NSLineBreakByWordWrapping;
        [_contentLbl setFont:[UIFont systemFontOfSize:contentFontSize]];
    }
    return _contentLbl;
}

- (UILabel *)nameLbl {
    if(!_nameLbl) {
        _nameLbl = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 0.0f, nameHeight)];
        _nameLbl.textColor = nameColor;
        _nameLbl.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onNameTap)];
        [_nameLbl addGestureRecognizer:tap];
    }
    return _nameLbl;
}
-(void) onNameTap {
    [[WKApp shared] invoke:WKPOINT_USER_INFO param:@{@"uid":self.model.uid?:@""}];
}

+(CGSize) getImgSizeWithPath:(NSString*) path {
    if([path containsString:@".png@"]) {
        NSArray* array = [path componentsSeparatedByString:@".png@"];
        NSArray* subArray = [array[1] componentsSeparatedByString:@".png"];
        NSArray* imageSizeArray = [subArray[0] componentsSeparatedByString:@"x"];
        if(imageSizeArray.count == 2) {
            return  [UIImage lim_sizeWithImageOriginSize:CGSizeMake([imageSizeArray[0] floatValue], [imageSizeArray[1] floatValue]) maxLength:contentMaxWidth-60.0f];
        }
    }
    return  CGSizeMake(100.0f, 100.0f);
}


+ (CGSize)getMomentContentLabelSize:(WKMomentContentVideoModel *)model fontSie:(CGFloat)fontSize{
    if(!model.content|| [model.content isEqualToString:@""]) {
        return CGSizeZero;
    }
    NSString *cacheKey = [NSString stringWithFormat:@"%@",model.sid];
    
    return [self getTextLabelSize:model.content key:cacheKey maxWidth:contentMaxWidth fontSize:fontSize];
}

+ (CGSize)getTextLabelSize:(NSString *)content key:(NSString*)cacheKey maxWidth:(CGFloat)maxWidth fontSize:(CGFloat)fontSize{
    static WKMemoryCache *memoryCache;
    static NSLock *memoryLock;
    if(!memoryLock) {
        memoryLock = [[NSLock alloc] init];
    }
    if(!memoryCache) {
        memoryCache = [[WKMemoryCache alloc] init];
        memoryCache.maxCacheNum = 500;
    }
  
    [memoryLock lock];
   NSString *cacheSizeStr =   [memoryCache getCache:cacheKey];
    [memoryLock unlock];
    if(cacheSizeStr) {
        return CGSizeFromString(cacheSizeStr);
    }
    static M80AttributedLabel *textLbl;
    if(!textLbl) {
        textLbl = [[M80AttributedLabel alloc] init];
        [textLbl setFont:[UIFont systemFontOfSize:fontSize]];
    }
    [textLbl lim_setText:content];
    
    CGSize textSize = [textLbl sizeThatFits:CGSizeMake(maxWidth, CGFLOAT_MAX)];
     [memoryLock lock];
    [memoryCache setCache:NSStringFromCGSize(textSize) forKey:cacheKey];
     [memoryLock unlock];
    return textSize;
}

- (UIImage*) imageName:(NSString*)name {
    return [[WKApp shared] loadImage:name moduleID:[WKMomentModule gmoduleId]];
}

@end
