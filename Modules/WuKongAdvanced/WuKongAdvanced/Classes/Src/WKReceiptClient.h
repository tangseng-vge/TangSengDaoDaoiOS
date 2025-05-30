//
//  WKReceiptClient.h
//  WuKongBase
//
//  Created by tt on 2021/4/10.
//

#import <Foundation/Foundation.h>
#import "WuKongBase.h"
#import <PromiseKit/PromiseKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface WKReceiptClient : NSObject

+ (WKReceiptClient *)shared;

/**
 获取已读列表
 */
-(AnyPromise*) readedList:(WKChannel*)channel messageID:(uint64_t)messageID;

/**
 获取未读列表
 */
-(AnyPromise*) unreadList:(WKChannel*)channel messageID:(uint64_t)messageID;

@end

@interface WKReadedUserResp : WKModel

@property(nonatomic,copy) NSString *uid;
@property(nonatomic,copy) NSString *name;

@end

@interface WKUnreadUserResp : WKModel

@property(nonatomic,copy) NSString *uid;
@property(nonatomic,copy) NSString *name;

@end

NS_ASSUME_NONNULL_END
