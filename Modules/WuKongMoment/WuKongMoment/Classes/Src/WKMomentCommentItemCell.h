//
//  WKMomentCommentItemCell.h
//  WuKongMoment
//
//  Created by tt on 2020/11/17.
//

#import <WuKongBase/WuKongBase.h>

NS_ASSUME_NONNULL_BEGIN

@interface WKMomentCommentItemModel : WKFormItemModel

@property(nonatomic,assign) BOOL first; // 是否是第一条评论
@property(nonatomic,copy) NSString *sid;
@property(nonatomic,copy) NSString *uid; // 评论者uid
@property(nonatomic,copy) NSString *name; // 评论者名称
@property(nonatomic,copy) NSString *content; // 评论内容

@property(nonatomic,copy) NSString *timeFormat; // 评论时间

@property(nonatomic,copy) NSString *toUID; // 回复给
@property(nonatomic,copy) NSString *toName; // 回复给...的名称




@end

@interface WKMomentCommentItemCell : WKFormItemCell

@property(nonatomic,strong) WKMomentCommentItemModel *model;

@end

NS_ASSUME_NONNULL_END
