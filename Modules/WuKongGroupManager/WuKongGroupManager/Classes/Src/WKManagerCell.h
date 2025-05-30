//
//  WKManagerCell.h
//  WuKongBase
//
//  Created by tt on 2020/4/1.
//

#import "WKViewItemCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface WKManagerModel : WKViewItemModel


/// 管理员头像
@property(nonatomic,copy) NSString *icon;


/// 管理员名称
@property(nonatomic,copy) NSString *title;


/// 是否显示减号
@property(nonatomic,assign) BOOL showSub;


/// 删除点击
@property(nonatomic,strong) void(^onSub)(void);

@end

@interface WKManagerCell : WKViewItemCell


@end

@interface WKManagerAddModel : WKViewItemModel

/// 管理员名称
@property(nonatomic,copy) NSString *title;

@end

@interface WKManagerAddCell : WKViewItemCell


@end

NS_ASSUME_NONNULL_END
