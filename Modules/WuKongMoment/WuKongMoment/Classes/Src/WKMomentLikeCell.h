//
//  WKMomentLikeCell.h
//  WuKongMoment
//
//  Created by tt on 2020/11/6.
//

#import <WuKongBase/WuKongBase.h>

NS_ASSUME_NONNULL_BEGIN

@interface WKMomentLikeUser : NSObject

@property(nonatomic,copy) NSString *uid;
@property(nonatomic,copy) NSString *name;

+(instancetype) uid:(NSString*)uid name:(NSString*)name;

@end

@interface WKMomentLikeModel : WKFormItemModel

@property(nonatomic,strong) NSArray<WKMomentLikeUser*> *users; // 点赞用户列表

@property(nonatomic,assign) BOOL hasComment;

@end

@interface WKMomentLikeCell : WKFormItemCell

@end

NS_ASSUME_NONNULL_END
