//
//  WKSmallVideoContent.m
//  WuKongSmallVideo
//
//  Created by tt on 2020/4/29.
//

#import "WKSmallVideoContent.h"
#import <WuKongIMSDK/WKMediaUtil.h>
@interface WKSmallVideoContent ()
@property(nonatomic,strong) NSData *videoData;
@property(nonatomic,strong) NSData *coverData;
@end

@implementation WKSmallVideoContent

+(WKSmallVideoContent*) smallVideoContent:(NSData*)videoData coverData:(NSData*)coverData second:(NSInteger)second {
    WKSmallVideoContent *smallVideoContent = [WKSmallVideoContent new];
    smallVideoContent.size = [videoData length];
    smallVideoContent.videoData = videoData;
    smallVideoContent.coverData = coverData;
    smallVideoContent.second = second;
    UIImage *coverImage =  [UIImage imageWithData:coverData];
    if(coverImage) {
        smallVideoContent.width = coverImage.size.width;
        smallVideoContent.height = coverImage.size.height;
    }
    return smallVideoContent;
}

- (void)decodeWithJSON:(NSDictionary *)contentDic {
    self.remoteUrl = contentDic[@"url"];
    self.url = contentDic[@"url"];
    self.cover = contentDic[@"cover"];
    self.size = contentDic[@"size"]?[contentDic[@"size"] integerValue]:0;
    self.second = contentDic[@"second"]?[contentDic[@"second"] integerValue]:0;
    self.width = contentDic[@"width"]?[contentDic[@"width"] integerValue]:0;
    self.height = contentDic[@"height"]?[contentDic[@"height"] integerValue]:0;
}

- (NSDictionary *)encodeWithJSON {
   NSMutableDictionary *dataDict = [NSMutableDictionary dictionary];
    [dataDict setObject:self.remoteUrl?:@"" forKey:@"url"];
    [dataDict setObject:@(self.width) forKey:@"width"];
    [dataDict setObject:@(self.height) forKey:@"height"];
    if(self.cover && ![self.cover isEqualToString:@""]) { // 如果属性里有封面属性直接取封面
        [dataDict setObject:self.cover?:@"" forKey:@"cover"];
    }else  { // 如果属性里cover没值 就取扩展里的
        NSString *videoCover = [self getExtra:@"video_cover"]; //
        if(videoCover && ![videoCover isEqualToString:@""]) {
            [dataDict setObject:videoCover forKey:@"cover"];
        }
    }
    
    [dataDict setObject:@(self.size) forKey:@"size"];
    [dataDict setObject:@(self.second) forKey:@"second"];
    return dataDict;
}

- (void)writeDataToLocalPath {
    [super writeDataToLocalPath];
    if(self.videoData) {
        [self.videoData writeToFile:self.localPath atomically:YES];
    }
    if(self.coverData) {
        [self.coverData writeToFile:[self coverLocalPath] atomically:YES];
    }
}
// 封面本地路径
- (NSString *)coverLocalPath {
     WKChannel *channel =  self.message.channel;
    NSString *uid = [WKSDK shared].options.connectInfo.uid;
       return   [NSString stringWithFormat:@"%@/%@/%@",[WKSDK shared].options.messageFileRootDir,uid, [NSString stringWithFormat:@"%@/%@%@",[WKMediaUtil getChannelDir:channel],self.message.clientMsgNo,@".jpg"]];
}

- (id)getExtra:(NSString *)key {
    if([key isEqualToString:@"video_cover_file"]) { // 如果是取视频的封面图 直接返回本地封面图
        return [self coverLocalPath];
    }
    return [super getExtra:key];
}


+(NSNumber*) contentType {
    return @(WK_SMALLVIDEO);
}

- (NSString *)extension {
    return @".mp4";
}

- (NSString *)conversationDigest {
    return LLang(@"[小视频]");
}

- (NSString *)searchableWord {
    return @"[小视频]";
}
@end
