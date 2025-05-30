//
//  WKMomentPublishImgGroupCell.h
//  WuKongMoment
//
//  Created by tt on 2020/11/12.
//

#import <WuKongBase/WuKongBase.h>
#import "WKMomentFileUploadTask.h"
NS_ASSUME_NONNULL_BEGIN

@interface WKMomentPublishImgGroupModel : WKFormItemModel

@property(nonatomic,strong) NSArray<WKMomentFileUploadTask*> *imgTasks;

@property(nonatomic,copy) void(^onAdd)(void);

@end

@interface WKMomentPublishImgGroupCell : WKFormItemCell

@end

NS_ASSUME_NONNULL_END
