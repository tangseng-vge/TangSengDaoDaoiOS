//
//  WKMomentFileUploadTask.h
//  WuKongMoment
//
//  Created by tt on 2020/11/19.
//
#import <WuKongBase/WuKongBase.h>
#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    WKMomentTaskStatusWait, // 任务等待执行
    WKMomentTaskStatusSuccess, // 任务执行成功
    WKMomentTaskStatusProgressing, // 任务处理中
    WKMomentTaskStatusError, // 任务执行错误
} WKMomentTaskStatus;


NS_ASSUME_NONNULL_BEGIN

@interface WKMomentFileUploadTask : NSObject

+(WKMomentFileUploadTask*) createImageUploadTask:(UIImage*)image;

+(WKMomentFileUploadTask*) createVideoUploadTask:(UIImage*)coverImage videoPath:(NSString*)videoPath;

@property(nonatomic,copy) NSString *taskID;

@property(nonatomic,assign) BOOL finished; // 任务是否完成

@property(nonatomic,copy) NSString *remoteURL; // 远程地址

@property(nonatomic,assign) CGFloat progress; // 进度

@property(nonatomic,assign) CGSize imageSize;

@property(nonatomic,strong) UIImage *image;

@property(nonatomic,copy) NSString *videoCoverURL; // 视频封面url
@property(nonatomic,copy) NSString *videoPath; // 视频路径

@property(nonatomic,assign) BOOL isVideo; // 是视频


@property(nonatomic,assign) WKMomentTaskStatus status;

@property(nonatomic,strong,nullable) NSError *error;

-(void) start;

-(void) stop;


- (void)addListener:(nonnull WKTaskListener)listener target:(id) target;

- (void)removeListener:(id)target;



@end

NS_ASSUME_NONNULL_END
