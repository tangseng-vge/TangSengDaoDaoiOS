//
//  WKMomentCommentItemTextCell.h
//  WuKongMoment
//
//  Created by tt on 2020/11/18.
//

#import <WuKongBase/WuKongBase.h>

NS_ASSUME_NONNULL_BEGIN

@interface WKMomentCommentItemTextModel : WKFormItemModel

@property(nonatomic,copy) NSString *sid;
@property(nonatomic,copy) NSString *uid; // 评论者uid
@property(nonatomic,copy) NSString *name; // 评论者名称
@property(nonatomic,copy) NSString *content; // 评论内容

@property(nonatomic,copy) NSString *toUID; // 回复给
@property(nonatomic,copy) NSString *toName; // 回复给...的名称

@property(nonatomic,assign) BOOL topCorner; // 是否显示顶部圆角
@property(nonatomic,assign) BOOL bottomCorner; // 是否显示底部圆角
@end

@interface WKMomentCommentItemTextCell : WKFormItemCell
@property(nonatomic,strong) WKMomentCommentItemTextModel *model;
@end

NS_ASSUME_NONNULL_END
