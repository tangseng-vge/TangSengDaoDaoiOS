//
//  WKMomentPublishSettingItemCell.h
//  WuKongMoment
//
//  Created by tt on 2020/11/12.
//

#import <WuKongBase/WuKongBase.h>

@interface WKMomentPublishSettingItemModel : WKFormItemModel


@property(nonatomic,strong) UIImage *icon;
@property(nonatomic,copy) NSString *title;
@property(nonatomic,copy) NSString *value;
@property(nonatomic,strong) UIColor *color;

@end

NS_ASSUME_NONNULL_BEGIN

@interface WKMomentPublishSettingItemCell : WKFormItemCell

@end

NS_ASSUME_NONNULL_END
