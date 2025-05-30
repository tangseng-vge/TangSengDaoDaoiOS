//
//  WKMomentPrivacyFirstCell.h
//  WuKongMoment
//
//  Created by tt on 2020/11/13.
//

#import <WuKongBase/WuKongBase.h>

NS_ASSUME_NONNULL_BEGIN

@interface WKMomentPrivacyFirstModel : WKFormItemModel

@property(nonatomic,assign) BOOL checked; // 是否选中
@property(nonatomic,assign) BOOL ticketRed; // 是否显示红色的对勾
@property(nonatomic,copy) NSString *title;
@property(nonatomic,copy) NSString *subtitle;
@property(nonatomic,assign) BOOL canUnfold; // 是否可以展开

@end

@interface WKMomentPrivacyFirstCell : WKFormItemCell

@end

NS_ASSUME_NONNULL_END
