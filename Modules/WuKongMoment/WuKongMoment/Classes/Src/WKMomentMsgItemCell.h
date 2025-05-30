//
//  WKMomentMsgItemCell.h
//  WuKongMoment
//
//  Created by tt on 2020/11/16.
//

#import <WuKongBase/WuKongBase.h>
#import "WKMomentCommentItemTextCell.h"
NS_ASSUME_NONNULL_BEGIN

@interface WKMomentMsgItemModel : WKFormItemModel

@property(nonatomic,copy) NSString *uid;
@property(nonatomic,copy) NSString *name;
@property(nonatomic,assign) BOOL like;
@property(nonatomic,assign) BOOL isVideo;
@property(nonatomic,copy) NSString *comment;
@property(nonatomic,copy) NSString *timeFormat;

@property(nonatomic,copy) NSString *firstImgURL;
@property(nonatomic,copy) NSString *content;
@property(nonatomic,assign) BOOL isDeleted;
@end

@interface WKMomentMsgItemCell : WKFormItemCell

@end

NS_ASSUME_NONNULL_END
