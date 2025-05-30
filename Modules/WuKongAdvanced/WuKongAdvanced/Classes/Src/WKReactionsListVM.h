//
//  WKReactionsListVM.h
//  WuKongAdvanced
//
//  Created by tt on 2022/8/9.
//

#import <WuKongBase/WuKongBase.h>

NS_ASSUME_NONNULL_BEGIN

@interface WKReactionsListVM : WKBaseTableVM

@property(nonatomic,strong) NSArray<WKReaction*> *reactions;

@end

NS_ASSUME_NONNULL_END
