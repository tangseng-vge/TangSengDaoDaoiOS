//
//  WKChatBackgroundVM.h
//  WuKongAdvanced
//
//  Created by tt on 2022/9/12.
//

#import <WuKongBase/WuKongBase.h>

NS_ASSUME_NONNULL_BEGIN

@interface WKChatBackgroundVM : WKBaseTableVM

@property(nonatomic,strong) WKChannel *channel;

@end

@interface WKChatBackground : WKModel

@property(nonatomic,copy) NSString *url;
@property(nonatomic,assign) BOOL isSvg;
@property(nonatomic,copy) NSString *cover;
@property(nonatomic,strong) NSArray<UIColor*> *darkColors;
@property(nonatomic,strong) NSArray<UIColor*> *lightColors;

@property(nonatomic,strong) UIImage *image; // 本地选择的图片
@end

NS_ASSUME_NONNULL_END
