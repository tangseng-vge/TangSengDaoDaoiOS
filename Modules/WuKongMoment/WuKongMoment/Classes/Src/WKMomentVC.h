//
//  WKMomentVC.h
//  WuKongMoment
//
//  Created by tt on 2020/11/5.
//

#import <WuKongBase/WuKongBase.h>
#import "WKMomentVM.h"
NS_ASSUME_NONNULL_BEGIN

@interface WKMomentVC : WKBaseTableVC<WKMomentVM*>

@property(nonatomic,assign) BOOL showMsg; // 显示自己的界面
@property(nonatomic,copy) NSString *uid; // 如果查看别人朋友圈请传入要查看人的uid

@end

NS_ASSUME_NONNULL_END
