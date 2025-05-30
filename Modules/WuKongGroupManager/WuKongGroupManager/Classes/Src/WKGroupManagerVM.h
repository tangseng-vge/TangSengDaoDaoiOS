//
//  WKGroupManagerVM.h
//  WuKongBase
//
//  Created by tt on 2020/3/1.
//

#import "WKBaseTableVM.h"
#import "WKFormSection.h"
#import <WuKongIMSDK/WuKongIMSDK.h>
#import <PromiseKit/PromiseKit.h>
NS_ASSUME_NONNULL_BEGIN
@class WKGroupManagerVM;
@protocol WKGroupManagerVMDelegate <NSObject>


/// 删除管理者
/// @param vm <#vm description#>
/// @param manager <#manager description#>
-(void) didDeleteManager:(WKGroupManagerVM*)vm manager:(WKChannelMember*)manager;


/// 群转让
/// @param vm <#vm description#>
-(void) didTransferGrouper:(WKGroupManagerVM*)vm;

@end

@interface WKGroupManagerVM : WKBaseTableVM

@property(nonatomic,weak) id<WKGroupManagerVMDelegate> delegate;

@property(nonatomic,strong) WKChannel *channel;


-(NSArray<WKFormSection*>*) getSections;


@property(nonatomic,strong) NSArray<WKChannelMember*> *members; // 成员


/// 请求转让群主
/// @param toUID <#toUID description#>
-(AnyPromise*) requestTransferGrouper:(NSString*)toUID;

/// 重新加载管理者
-(void) reloadManagerAndCreators;


/// 重新加载频道数据
-(void) reloadChannelInfo;
@end

NS_ASSUME_NONNULL_END
