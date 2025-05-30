//
//  WKMomentDetailVC.h
//  WuKongMoment
//
//  Created by tt on 2020/11/17.
//

#import <WuKongBase/WuKongBase.h>
#import "WKMomentDetailVM.h"
NS_ASSUME_NONNULL_BEGIN

@interface WKMomentDetailVC : WKBaseTableVC<WKMomentDetailVM*>

@property(nonatomic,copy) NSString *momentNo;

@property(nonatomic,copy) NSString *replyUID;
@property(nonatomic,copy) NSString *replyName;

@end

NS_ASSUME_NONNULL_END
