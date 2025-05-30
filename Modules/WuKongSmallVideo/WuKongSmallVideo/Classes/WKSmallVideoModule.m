//
//  WKSmallVideoModule.m
//  WuKongSmallVideo
//
//  Created by tt on 2020/4/29.
//

#import "WKSmallVideoModule.h"
#import "WKSmallVideoCell.h"
#import "WKSmallVideoContent.h"
#import "WKPanelCameraFuncItem.h"
#import "WKMergeForwardDetailVideoCell.h"
@WKModule(WKSmallVideoModule)
@implementation WKSmallVideoModule

+(NSString*) gmoduleId {
    return @"WuKongSmallVideo";
}

-(NSString*) moduleId {
    return [WKSmallVideoModule gmoduleId];
}

- (void)moduleInit:(WKModuleContext*)context{
    NSLog(@"【WuKongSmallVideo】模块初始化！");
    // 注册小视频消息
    [[WKApp shared] registerCellClass:WKSmallVideoCell.class forMessageContntClass:WKSmallVideoContent.class];
    
    [[WKApp shared] addMessageAllowForward:WK_SMALLVIDEO];
    
    // camera
    [self setMethod:WKPOINT_CATEGORY_PANELFUNCITEM_CAMERA handler:^id _Nullable(id  _Nonnull param) {
        WKPanelDefaultFuncItem *item = [[WKPanelCameraFuncItem alloc] init];
        item.sort = 4900;
        return item;
    } category:WKPOINT_CATEGORY_PANELFUNCITEM];
    
    // 发送视频消息
    [self setMethod:WKPOINT_SEND_VIDEO handler:^id _Nullable(id  _Nonnull param) {
        id<WKConversationContext> context = param[@"context"];
        NSData *coverData = param[@"cover_data"];
        NSData *videoData = param[@"video_data"];
        NSInteger second = param[@"second"] ?[ param[@"second"] integerValue]:0;
        if(!context || !coverData || !videoData) {
            return nil;
        }
        [context sendMessage: [WKSmallVideoContent smallVideoContent:videoData coverData:coverData second:second]];
        return nil;
    }];
    
    [[WKApp shared].endpointManager registerMergeForwardItem:WK_SMALLVIDEO cls:WKMergeForwardDetailVideoModel.class];
}

-(void) sendVideoMessage:(NSURL*)videoURL context:(id<WKConversationContext>)context {
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:videoURL options:nil];
    if(!asset) {
        return;
    }
    long long second = asset.duration.value/asset.duration.timescale;
    UIImage *coverImg =  [self getVideoPreViewImage:asset];
   
    [context sendMessage: [WKSmallVideoContent smallVideoContent:[NSData dataWithContentsOfURL:videoURL] coverData: UIImageJPEGRepresentation(coverImg, 0.8) second:second]];
}
//full 是否是原图
-(void) sendImageMessage:(UIImage*)image full:(BOOL)full context:(id<WKConversationContext>)context {
    WKImageContent *imageMessageContent = [WKImageContent initWithImage:image];
    [context sendMessage:imageMessageContent];
    
}

-(UIImage*) imageName:(NSString*)name {
    return [[WKApp shared] loadImage:name moduleID:[WKSmallVideoModule gmoduleId]];
}

// 获取视频第一帧
- (UIImage*) getVideoPreViewImage:(AVURLAsset *)asset
{
    AVAssetImageGenerator *assetGen = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    
    assetGen.appliesPreferredTrackTransform = YES;
    CMTime time = CMTimeMakeWithSeconds(0.0, 600);
    NSError *error = nil;
    CMTime actualTime;
    CGImageRef image = [assetGen copyCGImageAtTime:time actualTime:&actualTime error:&error];
    UIImage *videoImage = [[UIImage alloc] initWithCGImage:image];
    CGImageRelease(image);
    return videoImage;
}

@end
