//
//  WKMomentContentVideoCell.h
//  WuKongMoment
//
//  Created by tt on 2020/11/24.
//

#import <WuKongBase/WuKongBase.h>

NS_ASSUME_NONNULL_BEGIN

@interface WKMomentContentVideoModel : WKFormItemModel

@property(nonatomic,copy) NSString *sid;
@property(nonatomic,copy) NSString *uid; // 发布者uid
@property(nonatomic,copy) NSString *avatar; // 头像
@property(nonatomic,copy) NSString *name; // 名字
@property(nonatomic,copy) NSString *content;
@property(nonatomic,copy) NSString *videoCoverURL;
@property(nonatomic,copy) NSString *videoURL;

@end

@interface WKMomentContentVideoCell : WKFormItemCell

@end

NS_ASSUME_NONNULL_END
