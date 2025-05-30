//
//  WKMomentPublishVC.h
//  WuKongMoment
//
//  Created by tt on 2020/11/12.
//

#import <WuKongBase/WuKongBase.h>
#import "WKMomentPublishVM.h"
#import "WKMomentFileUploadTask.h"
NS_ASSUME_NONNULL_BEGIN

@interface WKMomentPublishVC : WKBaseTableVC<WKMomentPublishVM*>

@property(nonatomic,assign) BOOL isVideo;
@property(nonatomic,strong) UIImage *coverImg;
@property(nonatomic,copy) NSString *videoPath;

@property(nonatomic,strong) NSArray<WKMomentFileUploadTask*> *imgTasks;




@end

NS_ASSUME_NONNULL_END
