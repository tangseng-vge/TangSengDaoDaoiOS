//
//  WKReactionsCell.h
//  WuKongAdvanced
//
//  Created by tt on 2022/8/9.
//

#import <WuKongBase/WuKongBase.h>

NS_ASSUME_NONNULL_BEGIN

@interface WKReactionsCell : WKFormItemCell

@end

@interface WKReactionsCellModel : WKFormItemModel

@property(nonatomic,strong) WKReaction *reaction;

@end

NS_ASSUME_NONNULL_END
