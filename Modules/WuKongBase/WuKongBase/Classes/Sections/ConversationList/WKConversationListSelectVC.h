//
//  WKConversationSelectVC.h
//  WuKongBase
//
//  Created by tt on 2020/2/2.
//

#import "WuKongBase.h"
#import "WKConversationListSelectVM.h"
NS_ASSUME_NONNULL_BEGIN

@interface WKConversationListSelectVC : WKBaseTableVC<WKConversationListSelectVM*>


/**
 选中
 */
@property(nonatomic,copy) void(^onSelect)(WKChannel*channel);

@property(nonatomic,copy) void(^onMultipleSelect)(NSArray<WKChannel*> *selectedChannels);

@end


NS_ASSUME_NONNULL_END
