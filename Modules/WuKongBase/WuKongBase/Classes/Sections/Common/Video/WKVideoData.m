//
//  YBIBVideoData.m
//  YBImageBrowserDemo
//
//  Created by 波儿菜 on 2019/7/10.
//  Copyright © 2019 杨波. All rights reserved.
//

#import "WKVideoData.h"
#import "WKVideoCell.h"
#import "WKVideoData+Internal.h"
#import <YBImageBrowser/YBIBUtilities.h>
#import <YBImageBrowser/YBIBCopywriter.h>
#import <YBImageBrowser/YBIBPhotoAlbumManager.h>


extern CGImageRef YYCGImageCreateDecodedCopy(CGImageRef imageRef, BOOL decodeForDisplay);

@interface WKVideoData ()
@end

@implementation WKVideoData

#pragma mark - life cycle

- (instancetype)init {
    self = [super init];
    if (self) {
        [self initValue];
    }
    return self;
}

- (void)initValue {
    _loadingFirstFrame = NO;
    _loadingAVAssetFromPHAsset = NO;
    _downloading = NO;
    _interactionProfile = [YBIBInteractionProfile new];
    _repeatPlayCount = 0;
    _autoPlayCount = 0;
    _shouldHideForkButton = NO;
    _allowSaveToPhotoAlbum = YES;
}

#pragma mark - load data

- (void)loadData {
    // Always load 'thumbImage'.
    [self loadThumbImage];
    
    if (self.videoAVAsset) {
        [self.delegate yb_videoData:self readyForAVAsset:self.videoAVAsset];
    } else if (self.videoPHAsset) {
        [self loadAVAssetFromPHAsset];
    } else if(!self.downloadTask){
        [self.delegate yb_videoIsInvalidForData:self];
    }
}



- (void)loadAVAssetFromPHAsset {
    if (!self.videoPHAsset) return;
    if (self.isLoadingAVAssetFromPHAsset) {
        self.loadingAVAssetFromPHAsset = YES;
        return;
    }
    
    self.loadingAVAssetFromPHAsset = YES;
    [YBIBPhotoAlbumManager getAVAssetWithPHAsset:self.videoPHAsset completion:^(AVAsset * _Nullable asset) {
        YBIB_DISPATCH_ASYNC_MAIN(^{
            self.loadingAVAssetFromPHAsset = NO;
            
            self.videoAVAsset = asset;
            [self.delegate yb_videoData:self readyForAVAsset:self.videoAVAsset];
            [self loadThumbImage];
        })
    }];
}

- (void)loadThumbImage {
    if (self.thumbImage) {
        [self.delegate yb_videoData:self readyForThumbImage:self.thumbImage];
    } else if (self.projectiveView && [self.projectiveView isKindOfClass:UIImageView.self] && ((UIImageView *)self.projectiveView).image) {
        self.thumbImage = ((UIImageView *)self.projectiveView).image;
        [self.delegate yb_videoData:self readyForThumbImage:self.thumbImage];
    } else {
        [self loadThumbImage_firstFrame];
    }
}
- (void)loadThumbImage_firstFrame {
    if (!self.videoAVAsset) return;
    if (self.isLoadingFirstFrame) {
        self.loadingFirstFrame = YES;
        return;
    }
    
    self.loadingFirstFrame = YES;
    CGSize containerSize = self.yb_containerSize(self.yb_currentOrientation());
    CGSize maximumSize = containerSize;
    
    __weak typeof(self) wSelf = self;
    YBIB_DISPATCH_ASYNC(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        AVAssetImageGenerator *generator = [AVAssetImageGenerator assetImageGeneratorWithAsset:self.videoAVAsset];
        generator.appliesPreferredTrackTransform = YES;
        generator.maximumSize = maximumSize;
        NSError *error = nil;
        CGImageRef cgImage = [generator copyCGImageAtTime:CMTimeMake(0, 1) actualTime:NULL error:&error];
        CGImageRef decodedImage = YYCGImageCreateDecodedCopy(cgImage, YES);
        UIImage *resultImage = [UIImage imageWithCGImage:decodedImage];
        if (cgImage) CGImageRelease(cgImage);
        if (decodedImage) CGImageRelease(decodedImage);
        
        YBIB_DISPATCH_ASYNC_MAIN(^{
            __strong typeof(wSelf) self = wSelf;
            if (!self) return;
            self.loadingFirstFrame = NO;
            if (!error && resultImage) {
                self.thumbImage = resultImage;
                [self.delegate yb_videoData:self readyForThumbImage:self.thumbImage];
            }
        })
    })
}

#pragma mark - <YBIBDataProtocol>

@synthesize yb_currentOrientation = _yb_currentOrientation;
@synthesize yb_containerView = _yb_containerView;
@synthesize yb_containerSize = _yb_containerSize;
@synthesize yb_isHideTransitioning = _yb_isHideTransitioning;
@synthesize yb_auxiliaryViewHandler = _yb_auxiliaryViewHandler;

- (nonnull Class)yb_classOfCell {
    return WKVideoCell.self;
}

//- (UIView *)yb_projectiveView {
//    return self.projectiveView;
//}

- (CGRect)yb_imageViewFrameWithContainerSize:(CGSize)containerSize imageSize:(CGSize)imageSize orientation:(UIDeviceOrientation)orientation {
    if (containerSize.width <= 0 || containerSize.height <= 0 || imageSize.width <= 0 || imageSize.height <= 0) return CGRectZero;
    CGFloat x = 0, y = 0, width = 0, height = 0;
    if (imageSize.width / imageSize.height >= containerSize.width / containerSize.height) {
        width = containerSize.width;
        height = containerSize.width * (imageSize.height / imageSize.width);
        x = 0;
        y = (containerSize.height - height) / 2.0;
    } else {
        height = containerSize.height;
        width = containerSize.height * (imageSize.width / imageSize.height);
        x = (containerSize.width - width) / 2.0;
        y = 0;
    }
    return CGRectMake(x, y, width, height);
}

- (void)yb_preload {
    if (!self.delegate) {
        [self loadData];
    }
}

- (BOOL)yb_allowSaveToPhotoAlbum {
    return self.allowSaveToPhotoAlbum;
}

-(NSString*) getTaskStorePath:(WKBaseTask*)task {
    if([task isKindOfClass:[WKDowloadTask class]]) {
        WKDowloadTask *realTask = (WKDowloadTask*)task;
        return realTask.storePath;
    }else if([task isKindOfClass:[WKMessageFileDownloadTask class]]) {
        WKMessageFileDownloadTask *realTask = (WKMessageFileDownloadTask*)task;
        if(realTask.message && realTask.message.content) {
            WKMediaMessageContent *mediaContent = (WKMediaMessageContent*)realTask.message.content;
            return mediaContent.localPath;
        }
    }
    return nil;
}

- (void)yb_saveToPhotoAlbum {
    void(^unableToSave)(void) = ^(){
        [self.yb_auxiliaryViewHandler() yb_showIncorrectToastWithContainer:self.yb_containerView text:[YBIBCopywriter sharedCopywriter].unableToSave];
    };
    
    if(!self.downloadTask) {
        unableToSave();
        return;
    }
    
    NSString *storePath = [self getTaskStorePath:self.downloadTask];
    if(!storePath) {
        unableToSave();
        return;
    }
    if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(storePath)) {
        UISaveVideoAtPathToSavedPhotosAlbum(storePath, self, @selector(UISaveVideoAtPathToSavedPhotosAlbum_videoPath:didFinishSavingWithError:contextInfo:), nil);
    } else {
        unableToSave();
    }
}

#pragma mark - private

- (void)UISaveVideoAtPathToSavedPhotosAlbum_videoPath:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{
    if (error) {
        [self.yb_auxiliaryViewHandler() yb_showIncorrectToastWithContainer:self.yb_containerView text:[YBIBCopywriter sharedCopywriter].saveToPhotoAlbumFailed];
    } else {
        [self.yb_auxiliaryViewHandler() yb_showCorrectToastWithContainer:self.yb_containerView text:[YBIBCopywriter sharedCopywriter].saveToPhotoAlbumSuccess];
    }
}



#pragma mark - getters & setters

- (void)setVideoURL:(NSURL *)videoURL{
    _videoURL = [videoURL isKindOfClass:NSString.class] ? [NSURL URLWithString:(NSString *)videoURL] : videoURL;
    self.videoAVAsset = [AVURLAsset URLAssetWithURL:_videoURL options:nil];
}

- (void)setDownloading:(BOOL)downloading {
    _downloading = downloading;
    if (downloading) {
        [self.delegate yb_videoData:self downloadingWithProgress:0];
    } else {
        [self.delegate yb_finishDownloadingForData:self];
    }
}

- (void)setLoadingAVAssetFromPHAsset:(BOOL)loadingAVAssetFromPHAsset {
    _loadingAVAssetFromPHAsset = loadingAVAssetFromPHAsset;
    if (loadingAVAssetFromPHAsset) {
        [self.delegate yb_startLoadingAVAssetFromPHAssetForData:self];
    } else {
        [self.delegate yb_finishLoadingAVAssetFromPHAssetForData:self];
    }
}

- (void)setLoadingFirstFrame:(BOOL)loadingFirstFrame {
    _loadingFirstFrame = loadingFirstFrame;
    if (loadingFirstFrame) {
        [self.delegate yb_startLoadingFirstFrameForData:self];
    } else {
        [self.delegate yb_finishLoadingFirstFrameForData:self];
    }
}

@synthesize delegate = _delegate;
- (void)setDelegate:(id<WKVideoDataDelegate>)delegate {
    _delegate = delegate;
    if (delegate) {
        [self loadData];
    }
}
- (id<WKVideoDataDelegate>)delegate {
    // Stop sending data to the '_delegate' if it is transiting.
    return self.yb_isHideTransitioning() ? nil : _delegate;
}

@end
