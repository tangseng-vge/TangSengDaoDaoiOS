//
//  WKReceiptListVC.h
//  WuKongBase
//
//  Created by tt on 2021/4/10.
//

#import "WuKongBase.h"

NS_ASSUME_NONNULL_BEGIN

@interface WKReceiptListVC : WKBaseVC

@property(nonatomic,strong) WKChannel *channel;
@property(nonatomic,assign) uint64_t messageID;

@property(nonatomic,assign) NSInteger unreadCount; // 未读数量
@property(nonatomic,assign) NSInteger readedCount; // 已读数量

@end

NS_ASSUME_NONNULL_END
