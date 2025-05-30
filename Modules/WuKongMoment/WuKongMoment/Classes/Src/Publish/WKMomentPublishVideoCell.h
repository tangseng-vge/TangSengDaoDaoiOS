//
//  WKMomentPublishVideoCell.h
//  WuKongMoment
//
//  Created by tt on 2020/11/12.
//

#import <WuKongBase/WuKongBase.h>
#import "WKMomentFileUploadTask.h"
NS_ASSUME_NONNULL_BEGIN

@interface WKMomentPublishVideoModel : WKFormItemModel


@property(nonatomic,strong) WKMomentFileUploadTask *videoTask;

@end

@interface WKMomentPublishVideoCell : WKFormItemCell

@end

NS_ASSUME_NONNULL_END
