//
//  WKMomentNewMsgCell.h
//  WuKongMoment
//
//  Created by tt on 2020/11/6.
//

#import <WuKongBase/WuKongBase.h>

NS_ASSUME_NONNULL_BEGIN

@interface WKMomentNewMsgModel : WKFormItemModel

@property(nonatomic,assign) BOOL hasNewMsg; // 是否有新消息
@property(nonatomic,strong) NSNumber *msgCount; // 消息数量
@property(nonatomic,copy) NSString *lastMsgAvatar; // 最后一个人的头像
@end

@interface WKMomentNewMsgCell : WKFormItemCell

@end

NS_ASSUME_NONNULL_END
