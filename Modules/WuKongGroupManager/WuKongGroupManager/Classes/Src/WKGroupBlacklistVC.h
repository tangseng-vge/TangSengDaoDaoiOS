//
//  WKGroupBlacklistVC.h
//  WuKongBase
//
//  Created by tt on 2020/10/19.
//

#import "WKBaseTableVC.h"
#import "WKGroupBlacklistVM.h"

NS_ASSUME_NONNULL_BEGIN

@interface WKGroupBlacklistVC : WKBaseTableVC<WKGroupBlacklistVM*>

@property(nonatomic,strong) WKChannel *channel;

@end

NS_ASSUME_NONNULL_END
