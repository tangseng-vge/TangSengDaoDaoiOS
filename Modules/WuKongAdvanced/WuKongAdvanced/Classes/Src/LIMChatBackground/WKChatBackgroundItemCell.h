//
//  WKChatBackgroundItemCell.h
//  WuKongAdvanced
//
//  Created by tt on 2022/9/12.
//

#import <WuKongBase/WuKongBase.h>
#import "WKChatBackgroundVM.h"
NS_ASSUME_NONNULL_BEGIN

@interface WKChatBackgroundItemCellModel : WKFormItemModel

@property(nonatomic,assign) NSInteger maxNum;

@property(nonatomic,strong) NSArray<WKChatBackground*> *chatBackgrounds;

@property(nonatomic,copy) void(^onBackground)(WKChatBackground*chatBackground);

@end

@interface WKChatBackgroundItemCell : WKFormItemCell

@end

NS_ASSUME_NONNULL_END
