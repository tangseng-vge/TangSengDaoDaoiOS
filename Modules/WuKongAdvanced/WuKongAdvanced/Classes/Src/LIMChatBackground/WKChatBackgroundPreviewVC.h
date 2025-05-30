//
//  WKChatBackgroundPreviewVC.h
//  WuKongAdvanced
//
//  Created by tt on 2022/9/13.
//

#import <WuKongBase/WuKongBase.h>
#import "WKChatBackgroundVM.h"
NS_ASSUME_NONNULL_BEGIN

@interface WKChatBackgroundPreviewVC : WKBaseVC

@property(nonatomic,strong) WKChatBackground *chatBackground;
@property(nonatomic,strong) WKChannel *channel;

@end

NS_ASSUME_NONNULL_END
