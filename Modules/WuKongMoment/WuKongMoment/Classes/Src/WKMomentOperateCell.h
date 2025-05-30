//
//  WKMomentOperateCell.h
//  WuKongMoment
//
//  Created by tt on 2020/11/5.
//

#import <WuKongBase/WuKongBase.h>
@class WKMomentOperateCell;
NS_ASSUME_NONNULL_BEGIN

@interface WKMomentOperateModel : WKFormItemModel

@property(nonatomic,copy) NSString *sid;
@property(nonatomic,copy) NSString *timeFormat;

@property(nonatomic,assign) BOOL showDelete; // 是否显示删除
@property(nonatomic,assign) BOOL liked; // 是否已经点赞
@property(nonatomic,assign) BOOL showPrivate; // 是否显示私有图标
@property(nonatomic,assign) BOOL selfVisiable; // 仅自己可见

@property(nonatomic,copy) void(^onDelete)(void); // 删除
@property(nonatomic,copy) void(^onComment)(WKMomentOperateCell *cell,WKMomentOperateModel *model);
@property(nonatomic,copy) void(^onLike)(WKMomentOperateCell *cell,WKMomentOperateModel *model);
@property(nonatomic,copy) void(^onPrivate)(void); // 私有按钮点击

@end

@interface WKMomentOperateCell : WKFormItemCell

@end

NS_ASSUME_NONNULL_END
