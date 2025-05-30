//
//  WKChatBackgroundVC.h
//  WuKongAdvanced
//
//  Created by tt on 2022/9/12.
//

#import <WuKongBase/WuKongBase.h>
#import "WKChatBackgroundVM.h"
NS_ASSUME_NONNULL_BEGIN

@interface WKChatBackgroundVC : WKBaseTableVC<WKChatBackgroundVM*>

@property(nonatomic,strong) WKChannel *channel;

@end

NS_ASSUME_NONNULL_END
