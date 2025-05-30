//
//  WKMomentShareUserListVC.h
//  WuKongMoment
//
//  Created by tt on 2022/11/7.
//

#import <WuKongBase/WuKongBase.h>
#import "WKMomentShareUserListVM.h"
NS_ASSUME_NONNULL_BEGIN

@interface WKMomentShareUserListVC : WKBaseTableVC<WKMomentShareUserListVM *>

@property(nonatomic,copy) NSString *privacyType;
@property(nonatomic,strong) NSArray<NSString*> *privacyUids;

@end

NS_ASSUME_NONNULL_END
