//
//  WKBurnAfterReadingSelectCell.h
//  WuKongAdvanced
//
//  Created by tt on 2022/8/15.
//

#import <WuKongBase/WuKongBase.h>

NS_ASSUME_NONNULL_BEGIN

@interface WKBurnAfterReadingSelectCellModel : WKFormItemModel

@property(nonatomic,copy) void(^valueChange)(NSInteger value);

@property(nonatomic,assign) NSInteger flameSecond;

@end

@interface WKBurnAfterReadingSelectCell : WKFormItemCell

@end

NS_ASSUME_NONNULL_END
