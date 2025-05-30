//
//  WKFlameSettingView.h
//  WuKongAdvanced
//
//  Created by tt on 2022/8/19.
//

#import <UIKit/UIKit.h>
#import <WuKongBase/WuKongBase.h>

NS_ASSUME_NONNULL_BEGIN



@interface WKFlameSettingView : UIView

@property(nonatomic,strong) WKChannel *channel;

@property(nonatomic,copy) void(^onSwitch)(BOOL sw);

@end

NS_ASSUME_NONNULL_END
