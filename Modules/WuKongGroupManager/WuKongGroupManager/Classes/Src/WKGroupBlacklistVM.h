//
//  WKGroupBlacklistVM.h
//  WuKongBase
//
//  Created by tt on 2020/10/19.
//

#import "WKBaseTableVM.h"
@class WKGroupBlacklistVM;
NS_ASSUME_NONNULL_BEGIN

@protocol WKGroupBlacklistVMDelegate <NSObject>

@optional


/// 移除黑名单
/// @param vm <#vm description#>
-(void) groupBlacklistVMRemoveBlacklist:(WKGroupBlacklistVM*)vm member:(WKChannelMember*)member;

@end

@interface WKGroupBlacklistVM : WKBaseTableVM

@property(nonatomic,weak) id<WKGroupBlacklistVMDelegate> delegate;

@property(nonatomic,strong) WKChannel *channel;

// 添加或移除黑名单
-(void) addOrRemoveBlacklist:(NSString*)action uids:(NSArray<NSString*>*)uids;

@end

NS_ASSUME_NONNULL_END
