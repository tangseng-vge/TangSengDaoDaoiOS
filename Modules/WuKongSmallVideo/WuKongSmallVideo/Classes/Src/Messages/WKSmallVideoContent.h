//
//  WKSmallVideoContent.h
//  WuKongSmallVideo
//
//  Created by tt on 2020/4/29.
//

#import <WuKongIMSDK/WuKongIMSDK.h>

#import <WuKongBase/WuKongBase.h>

NS_ASSUME_NONNULL_BEGIN

@interface WKSmallVideoContent : WKMediaMessageContent


/// 初始化小视频正文
/// @param videoData 小视频数据
/// @param coverData 封面图数据
/// @param second 小视频秒数
+(WKSmallVideoContent*) smallVideoContent:(NSData*)videoData coverData:(NSData*)coverData second:(NSInteger)second;


/// 获取本地封面路径
- (NSString *)coverLocalPath;

// 视频源地址
@property(nonatomic,copy) NSString *url;
// 封面图地址
@property(nonatomic,copy) NSString *cover;
// 视频大小(单位byte)
@property(nonatomic,assign) NSInteger size;
// 视频宽度
@property(nonatomic,assign) NSInteger width;
// 视频高度
@property(nonatomic,assign) NSInteger height;
// 视频长度（单位秒）
@property(nonatomic,assign) NSInteger second;

@end

NS_ASSUME_NONNULL_END
