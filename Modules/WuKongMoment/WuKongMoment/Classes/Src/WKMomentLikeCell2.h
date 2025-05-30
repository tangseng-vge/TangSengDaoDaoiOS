//
//  WKMomentLikeCell2.h
//  WuKongMoment
//
//  Created by tt on 2020/11/17.
//

#import <WuKongBase/WuKongBase.h>
#import "WKMomentLikeCell.h"
NS_ASSUME_NONNULL_BEGIN

@interface WKMomentLikeModel2 : WKFormItemModel

@property(nonatomic,copy) NSString *sid;
@property(nonatomic,strong) NSArray<WKMomentLikeUser*> *users; // 点赞用户列表

@property(nonatomic,assign) BOOL hasComment;

@end

@interface WKMomentLikeCell2 : WKFormItemCell

@end

NS_ASSUME_NONNULL_END
