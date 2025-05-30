//
//  WKUserMomentCell.h
//  WuKongMoment
//
//  Created by tt on 2020/11/30.
//

#import <WuKongBase/WuKongBase.h>

NS_ASSUME_NONNULL_BEGIN

@interface WKUserMomentModel : WKViewItemModel

@property(nonatomic,strong) NSArray<NSString*> *imgs;

@end

@interface WKUserMomentCell : WKViewItemCell

@end

NS_ASSUME_NONNULL_END
