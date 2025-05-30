//
//  WKReactionsListVC.h
//  WuKongAdvanced
//
//  Created by tt on 2022/8/9.
//

#import <WuKongBase/WuKongBase.h>
#import "WKReactionsListVM.h"
NS_ASSUME_NONNULL_BEGIN

@interface WKReactionsListVC : WKBaseTableVC<WKReactionsListVM*>

@property(nonatomic,strong) WKChannel *channel;
@property(nonatomic,strong) NSArray<WKReaction*> *reactions;

@end

NS_ASSUME_NONNULL_END
