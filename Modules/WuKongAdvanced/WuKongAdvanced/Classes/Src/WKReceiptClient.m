//
//  WKReceiptClient.m
//  WuKongBase
//
//  Created by tt on 2021/4/10.
//

#import "WKReceiptClient.h"

@implementation WKReceiptClient


static WKReceiptClient *_instance;
+ (id)allocWithZone:(NSZone *)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [super allocWithZone:zone];
    });
    return _instance;
}
+ (WKReceiptClient *)shared
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}

-(AnyPromise*) readedList:(WKChannel*)channel messageID:(uint64_t)messageID{
   return [[WKAPIClient sharedClient] GET:[NSString stringWithFormat:@"messages/%llu/receipt",messageID] parameters:@{
        @"readed":@(1),
        @"channel_id": channel.channelId,
        @"channel_type": @(channel.channelType),
        @"page_size":@(1000),
    } model:WKReadedUserResp.class];
}

-(AnyPromise*) unreadList:(WKChannel*)channel messageID:(uint64_t)messageID{
    return [[WKAPIClient sharedClient] GET:[NSString stringWithFormat:@"messages/%llu/receipt",messageID] parameters:@{
         @"readed":@(0),
         @"channel_id": channel.channelId,
         @"channel_type": @(channel.channelType),
         @"page_size":@(1000),
     } model:WKUnreadUserResp.class];
}

@end

@implementation WKReadedUserResp

+ (WKModel *)fromMap:(NSDictionary *)dictory type:(ModelMapType)type {
    WKReadedUserResp *resp = [WKReadedUserResp new];
    resp.uid = dictory[@"uid"];
    resp.name = dictory[@"name"];
    return resp;
}

@end


@implementation WKUnreadUserResp

+ (WKModel *)fromMap:(NSDictionary *)dictory type:(ModelMapType)type {
    WKReadedUserResp *resp = [WKReadedUserResp new];
    resp.uid = dictory[@"uid"];
    resp.name = dictory[@"name"];
    return resp;
}

@end
