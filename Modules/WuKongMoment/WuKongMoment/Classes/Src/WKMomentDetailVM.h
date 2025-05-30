//
//  WKMomentDetailVM.h
//  WuKongMoment
//
//  Created by tt on 2020/11/17.
//

#import <WuKongBase/WuKongBase.h>
#import "WKMomentVM.h"
NS_ASSUME_NONNULL_BEGIN

@interface WKMomentDetailVM : WKBaseTableVM

@property(nonatomic,strong) WKMomentResp *moment;
@property(nonatomic,copy) NSString *momentNo;


-(AnyPromise*) requestCommentDel:(NSString*)momentNo commentID:(NSString*)commentID;

/// 添加评论
/// @param momentNo <#momentNo description#>
/// @param req <#req description#>
-(AnyPromise*) requestCommentAdd:(NSString*)momentNo req:(WKCommentReq*)req;

@end

NS_ASSUME_NONNULL_END
