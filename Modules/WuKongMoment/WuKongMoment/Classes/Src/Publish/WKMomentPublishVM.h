//
//  WKMomentPublishVM.h
//  WuKongMoment
//
//  Created by tt on 2020/11/12.
//

#import <WuKongBase/WuKongBase.h>
#import "WKMomentFileUploadTask.h"
@class WKMomentPublishVM;
NS_ASSUME_NONNULL_BEGIN

@protocol WKMomentPublishVMDelegate <NSObject>

@optional

// 添加图片
-(void) momentPublishVMAddImg:(WKMomentPublishVM*)vm;

-(void) momentPublishVMContentChange:(WKMomentPublishVM*)vm textfiled:(UITextField*)textfield;

@end

@interface WKMomentPublishVM : WKBaseTableVM

@property(nonatomic,weak) id<WKMomentPublishVMDelegate> delegate;
@property(nonatomic,assign) BOOL isVideo; // 是否是视频
@property(nonatomic,copy) NSString *content; // 发布内容
-(BOOL) onlyPublishText; // 仅仅只发布文本内容
@property(nonatomic,strong) WKMomentFileUploadTask *videoTask;
@property(nonatomic,strong) NSArray<WKMomentFileUploadTask*> *imgTasks;

-(AnyPromise*) publish;

@end

NS_ASSUME_NONNULL_END
