//
//  WKGroupManagerVC.h
//  WuKongBase
//
//  Created by tt on 2020/3/1.
//

#import <UIKit/UIKit.h>
#import "WKBaseTableVC.h"
#import "WKGroupManagerVM.h"
#import <WuKongIMSDK/WuKongIMSDK.h>
NS_ASSUME_NONNULL_BEGIN

@interface WKGroupManagerVC : WKBaseTableVC<WKGroupManagerVM*>

@property(nonatomic,strong) WKChannel *channel;

@end

NS_ASSUME_NONNULL_END
