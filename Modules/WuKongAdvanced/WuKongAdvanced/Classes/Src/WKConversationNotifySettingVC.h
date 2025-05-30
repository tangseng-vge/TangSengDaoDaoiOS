//
//  WKConversationNotifySettingVC.h
//  WuKongBase
//
//  Created by tt on 2020/10/16.
//

#import "WKConversationNotifySettingVM.h"
#import <WuKongBase/WuKongBase.h>
NS_ASSUME_NONNULL_BEGIN

@interface WKConversationNotifySettingVC : WKBaseTableVC<WKConversationNotifySettingVM*>

@property(nonatomic,strong) WKChannel *channel;

@end

NS_ASSUME_NONNULL_END
