//
//  WKMomentContentCell.h
//  WuKongMoment
//
//  Created by tt on 2020/11/5.
//

#import <WuKongBase/WuKongBase.h>

NS_ASSUME_NONNULL_BEGIN

@interface WKMomentContentModel : WKFormItemModel

@property(nonatomic,copy) NSString *sid; // 唯一ID
@property(nonatomic,copy) NSString *uid; // 发布者uid
@property(nonatomic,copy) NSString *avatar; // 头像
@property(nonatomic,copy) NSString *name; // 名字
@property(nonatomic,copy) NSString *content; // 正文

@property(nonatomic,strong) NSArray<NSString*> *imgs; // 图片集合

@end

@interface WKMomentContentCell : WKFormItemCell

@end

NS_ASSUME_NONNULL_END
