//
//  WKMomentPrivacyVC.h
//  WuKongMoment
//
//  Created by tt on 2020/11/13.
//

#import <WuKongBase/WuKongBase.h>
#import "WKMomentPrivacyVM.h"
#import "WKMomentPrivacySelect.h"
NS_ASSUME_NONNULL_BEGIN

@interface WKMomentPrivacyVC : WKBaseTableVC<WKMomentPrivacyVM*>

@property(nonatomic,strong) WKMomentPrivacySelect *momentPrivacySelect;

@property(nonatomic,copy) void(^onFinish)(WKMomentPrivacySelect *select);

@end



NS_ASSUME_NONNULL_END
