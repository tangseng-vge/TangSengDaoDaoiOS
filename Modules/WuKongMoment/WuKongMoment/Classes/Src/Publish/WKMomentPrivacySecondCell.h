//
//  WKMomentPrivacySecondCell.h
//  WuKongMoment
//
//  Created by tt on 2020/11/19.
//

#import <WuKongBase/WuKongBase.h>

NS_ASSUME_NONNULL_BEGIN

@interface WKMomentPrivacySecondModel : WKFormItemModel

@property(nonatomic,copy) NSString *title;
@property(nonatomic,copy) NSString *subtitle;

@end

@interface WKMomentPrivacySecondCell : WKFormItemCell

@end

NS_ASSUME_NONNULL_END
