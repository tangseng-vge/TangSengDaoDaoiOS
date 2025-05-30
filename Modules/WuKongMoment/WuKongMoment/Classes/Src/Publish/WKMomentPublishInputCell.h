//
//  WKMomentPublishInputCell.h
//  WuKongMoment
//
//  Created by tt on 2020/11/12.
//

#import <WuKongBase/WuKongBase.h>

NS_ASSUME_NONNULL_BEGIN

@interface WKMomentPublishInputModel : WKFormItemModel

@property(nonatomic,copy) NSString *placeholder;
@property(nonatomic,copy) void(^onChange)(NSString*value,UITextField *textfield);

@end

@interface WKMomentPublishInputCell : WKFormItemCell

@end

NS_ASSUME_NONNULL_END
