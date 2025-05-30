//
//  WKChatBackgroundPreviewVC.m
//  WuKongAdvanced
//
//  Created by tt on 2022/9/13.
//

#import "WKChatBackgroundPreviewVC.h"
#import <WuKongBase/WuKongBase-Swift.h>
#import <WuKongIMSDK/WKUUIDUtil.h>
#import <WuKongBase/WKMD5Util.h>
#import <WuKongBase/Svg.h>
#import <WuKongBase/WKThemeUtil.h>
@class WKConversationVC;
@interface WKChatBackgroundPreviewVC ()

@property(nonatomic,strong) GradientBackgroundNode *backgroundNode;

@property(nonatomic,strong) UIImageView *contentImageView;

@property(nonatomic,strong) WKDowloadTask *downloadTask;

@property(nonatomic,strong) UIView *boxView;

@property(nonatomic,strong) UIView *bottomView;

@property(nonatomic,strong) UIButton *rotateBtn;

@end

@implementation WKChatBackgroundPreviewVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = LLang(@"背景预览");
    
    [self.view addSubview:self.boxView];
    [self.view addSubview:self.bottomView];
    
    [self.view addSubview:self.rotateBtn];
    
    [self.boxView addSubview:self.backgroundNode.view];
    [self.backgroundNode updateLayoutWithSize:self.boxView.lim_size];
    
    if(self.chatBackground.image) {
        [self fileReady:nil];
        return;
    }
    NSString *tmpFile = [self getStorageFile];
    
    if([[NSFileManager defaultManager] fileExistsAtPath:tmpFile]) {
        [self fileReady:tmpFile];
    }else {
        __weak typeof(self) weakSelf = self;
        NSString *taskID = self.chatBackground.url;
        id<WKTaskProto> task = [[WKSDK shared].mediaManager.taskManager  get:taskID];
        if(!task) {
            WKDowloadTask *downTask = [[WKDowloadTask alloc] initWithURL:[WKApp.shared getFileFullUrl:self.chatBackground.url].absoluteString storePath:tmpFile];
            downTask.taskId = taskID;
            task = downTask;
            [[WKSDK shared].mediaManager.taskManager add:downTask];
        }
        self.downloadTask = task;
        
        [task addListener:^{
            if(task.status == WKTaskStatusSuccess) {
                [weakSelf fileReady:tmpFile];
            }
        } target:self];
    }
   
}

-(NSString*) getStorageFile {
    NSString *tempDir= NSTemporaryDirectory();
    NSString *fileName = [NSString stringWithFormat:@"chatbg-%@",[WKMD5Util md5HexDigest:self.chatBackground.url]];
    NSString *tmpFile = [tempDir stringByAppendingPathComponent:fileName];
    return tmpFile;
}

-(void) fileReady:(NSString*)path {
    [self.backgroundNode.view addSubview:self.contentImageView];
    self.contentImageView.frame = self.boxView.bounds;
    
    if(self.chatBackground.image) {
        self.contentImageView.image =  self.chatBackground.image;
        return;
    }
    
    if(!self.chatBackground.isSvg) {
       self.contentImageView.image = [[UIImage alloc] initWithContentsOfFile:path];
    }else {
        CGSize viewSize = self.boxView.lim_size;
        UIImage *patternImage = drawSvgImage([NSData dataWithContentsOfURL:[NSURL fileURLWithPath:path]], CGSizeMake(viewSize.width*2.0f, viewSize.height*2.0f), [UIColor clearColor], [UIColor whiteColor]);
       UIImage *bgImg = [GenerateImageUtils generateImg:viewSize contextGenerator:^(CGSize size, CGContextRef context) {
            CGContextSetBlendMode(context, kCGBlendModeSoftLight);
            CGContextSetAlpha(context, 0.2f);
            CGContextDrawImage(context, CGRectMake(0.0f, 0.0f, viewSize.width, viewSize.height), patternImage.CGImage);
        } opaque:false];
        self.contentImageView.image = bgImg;
        
    }
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (GradientBackgroundNode *)backgroundNode {
    if(!_backgroundNode) {
        _backgroundNode = [[GradientBackgroundNode alloc] initWithColors:[self getColors] useSharedAnimationPhase:false adjustSaturation:false];
        [_backgroundNode.view setBackgroundColor:[UIColor redColor]];
    }
    return _backgroundNode;
}

-(NSArray<UIColor*>*) getColors {
    if(WKApp.shared.config.style == WKSystemStyleDark) {
        return self.chatBackground.darkColors;
    }
    return self.chatBackground.lightColors;
}

- (UIImageView *)contentImageView {
    if(!_contentImageView) {
        _contentImageView = [[UIImageView alloc] init];
        _contentImageView.clipsToBounds = YES;
        _contentImageView.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _contentImageView;
}

- (UIView *)boxView {
    if(!_boxView) {
        CGRect visibleRect = self.visibleRect;
        _boxView = [[UIView alloc] initWithFrame:CGRectMake(visibleRect.origin.x, visibleRect.origin.y, visibleRect.size.width, visibleRect.size.height - self.bottomView.lim_height)];
    }
    return _boxView;
}

- (UIView *)bottomView {
    if(!_bottomView) {
        CGFloat height = 60.0f;
        CGFloat safeBottom = WKApp.shared.config.visibleEdgeInsets.bottom;
        _bottomView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, WKScreenHeight - height - safeBottom, self.view.lim_width, height+safeBottom)];
        [_bottomView setBackgroundColor:WKApp.shared.config.cellBackgroundColor];
        
        UIButton *setBackbgBtn = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, _bottomView.lim_width, height)];
        [setBackbgBtn setTitle:LLang(@"设置背景") forState:UIControlStateNormal];
        [setBackbgBtn setTitleColor:WKApp.shared.config.themeColor forState:UIControlStateNormal];
        [setBackbgBtn addTarget:self action:@selector(setBackbgBtnPressed) forControlEvents:UIControlEventTouchUpInside];
        
        [_bottomView addSubview:setBackbgBtn];
        
    }
    return _bottomView;
}

- (UIButton *)rotateBtn {
    if(!_rotateBtn) {
        CGFloat width = 70.0f;
        CGFloat height = 35.0f;
        _rotateBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.view.lim_width/2.0f - width/2.0f, self.bottomView.lim_top - height - 20.0f, width, height)];
        [_rotateBtn setBackgroundColor:[UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.5f]];
        [_rotateBtn setTitle:LLang(@"旋转") forState:UIControlStateNormal];
        [[_rotateBtn titleLabel] setFont:[WKApp.shared.config appFontOfSize:15.0f]];
        _rotateBtn.layer.masksToBounds = YES;
        _rotateBtn.hidden = YES;
        _rotateBtn.layer.cornerRadius = height/2.0f;
        if(self.chatBackground.isSvg) {
            _rotateBtn.hidden = NO;
        }
        [_rotateBtn lim_addEventHandler:^{
            [self.backgroundNode animateEvent];
        } forControlEvents:UIControlEventTouchUpInside];
    }
    return _rotateBtn;
}

-(void) setBackbgBtnPressed {
    
    if(self.chatBackground.image) {
        NSData *data = UIImageJPEGRepresentation(self.chatBackground.image, 0.9f);
        [self saveImageData:data style:WKSystemStyleLight];
        [self saveImageData:data style:WKSystemStyleDark];
    }else if(self.chatBackground.isSvg) {
        UIImage *wallpaperImage = [self generateBackground:WKSystemStyleDark];
        [self saveImageData:UIImageJPEGRepresentation(wallpaperImage, 0.9f) style:WKSystemStyleDark];
        
        wallpaperImage = [self generateBackground:WKSystemStyleLight];
        [self saveImageData:UIImageJPEGRepresentation(wallpaperImage, 0.9f) style:WKSystemStyleLight];
    }else {
        NSData *data = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:[self getStorageFile]]];
        [self saveImageData:data style:WKSystemStyleLight];
        [self saveImageData:data style:WKSystemStyleDark];
    }
    
    if(self.channel) {
        [WKNavigationManager.shared popToViewControllerClass:WKConversationVC.class animated:YES];
    }else{
        [self.view showHUDWithHide:LLang(@"设置成功！")];
    }
    

//
    
}

-(void) saveImageData:(NSData*)data style:(WKSystemStyle)style{
    if(self.channel) {
        [WKThemeUtil saveChatBackground:self.channel data:data style:style];
    }else{
        [WKThemeUtil saveDefaultBackground:data style:style];
    }
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    if(self.channel) {
        param[@"channel"] = self.channel;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:WKNOTIFY_CHATBACKGROUND_CHANGE object:param];
}

-(UIImage*) generateBackground:(WKSystemStyle)style {
    NSArray<UIColor*> *colors;
    if(style == WKSystemStyleDark) {
        colors = self.chatBackground.darkColors;
    }else{
        colors = self.chatBackground.lightColors;
    }
    CGSize viewSize = CGSizeMake(self.view.lim_size.width, self.view.lim_size.height);
    
    UIImage *patternImage = drawSvgImage([NSData dataWithContentsOfURL:[NSURL fileURLWithPath:[self getStorageFile]]], CGSizeMake(viewSize.width*2.0f, viewSize.height*2.0f), [UIColor clearColor], [UIColor whiteColor]);
    
    patternImage = [GenerateImageUtils generateImg:viewSize contextGenerator:^(CGSize size, CGContextRef context) {
         CGContextSetBlendMode(context, kCGBlendModeSoftLight);
         CGContextSetAlpha(context, 0.2f);
         CGContextDrawImage(context, CGRectMake(0.0f, 0.0f, viewSize.width, viewSize.height), patternImage.CGImage);
     } opaque:false];
    
    UIImage *wallpaperImage = [GenerateImageUtils generateImg:viewSize  contextGenerator:^(CGSize size, CGContextRef context) {
    
        UIImage *gradientImg = [GradientBackgroundNode generatePreviewWithSize:CGSizeMake(60.0f, 60.0f) colors:colors offset:self.backgroundNode.phase];
        CGContextDrawImage(context, CGRectMake(0.0f, 0.0f, viewSize.width, viewSize.height), gradientImg.CGImage);
//        CGContextTranslateCTM(context, viewSize.width/2.0f, viewSize.height/2.0f);
//        CGContextRotateCTM(context, 180 * M_PI / 180.0);
//        CGContextTranslateCTM(context, -viewSize.width/2.0f, -viewSize.height/2.0f);
        
         CGContextSetBlendMode(context, kCGBlendModeSoftLight);
         CGContextDrawImage(context, CGRectMake(0.0f, 0.0f, viewSize.width, viewSize.height), patternImage.CGImage);
        
     } opaque:false];
    return wallpaperImage;
    
}

- (void)dealloc {
    if(self.downloadTask) {
        [self.downloadTask removeListener:self];
    }
}
@end
