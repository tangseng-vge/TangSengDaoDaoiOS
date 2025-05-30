//
//  WKMomentPrivacyTagCell.h
//  WuKongMoment
//
//  Created by tt on 2022/11/29.
//

#import <WuKongBase/WuKongBase.h>

NS_ASSUME_NONNULL_BEGIN

@interface WKMomentPrivacyTagModel : WKFormItemModel

@property(nonatomic,copy) NSString *title;
@property(nonatomic,copy) NSString *content;
@property(nonatomic,assign) BOOL checked;
@property(nonatomic,copy) void(^onMore)(void);
@property(nonatomic,copy) void(^onCheck)(BOOL checked);

@end

@interface WKMomentPrivacyTagCell : WKFormItemCell

@end

NS_ASSUME_NONNULL_END
