//
//  WKMomentFileUploadTask.m
//  WuKongMoment
//
//  Created by tt on 2020/11/19.
//

#import "WKMomentFileUploadTask.h"

@interface WKMomentFileUploadTask ()



@property(nonatomic,copy) NSString *localPath;

@property(nonatomic,strong) NSMutableArray<NSURLSessionDataTask*> *tasks;

@property(nonatomic,strong) NSMutableDictionary<NSString*,WKTaskListener> *listenerDic;

@end

@implementation WKMomentFileUploadTask


+(WKMomentFileUploadTask*) createImageUploadTask:(UIImage*)image {
    WKMomentFileUploadTask *task = [WKMomentFileUploadTask new];
    task.image = image;
    task.taskID = [[[NSUUID UUID] UUIDString] stringByReplacingOccurrencesOfString:@"-" withString:@""];
    task.imageSize = image.size;
    [task initTask];
    [task start];
    return task;
}

+(WKMomentFileUploadTask*) createVideoUploadTask:(UIImage*)coverImage videoPath:(NSString*)videoPath {
    WKMomentFileUploadTask *task = [WKMomentFileUploadTask new];
    task.image = coverImage;
    task.taskID = [[[NSUUID UUID] UUIDString] stringByReplacingOccurrencesOfString:@"-" withString:@""];
    task.isVideo = true;
    task.videoPath = videoPath;
    task.imageSize = coverImage.size;
    [task initTask];
    [task start];
    return task;
}

-(void) initTask {
    NSString *tempDir= NSTemporaryDirectory();
    NSString *tmpFile = [tempDir stringByAppendingPathComponent:self.taskID];
    NSData *imageData = UIImageJPEGRepresentation(self.image, 0.8f);
    [imageData writeToFile:tmpFile atomically:YES];
    
    self.localPath = tmpFile;
}

- (void)start {
    __weak typeof(self) weakSelf = self;
    
    if(self.isVideo) {
        [self  uploadVideoCover:^{
            NSString *uploadPath = [NSString stringWithFormat:@"/dynamic/%@/%@.mp4",[WKApp shared].loginInfo.uid,self.taskID];
            self.remoteURL = uploadPath;
            [self getUploadURL:uploadPath].then(^(NSDictionary *result){
                NSString *uploadUrl = result[@"url"];
                [weakSelf uploadFile:uploadUrl fileURL:[NSString stringWithFormat:@"file://%@",weakSelf.videoPath]];
            });
        }];
    }else{
        NSString *uploadPath = [NSString stringWithFormat:@"/dynamic/%@/%@.png@%0.0fx%0.0f",[WKApp shared].loginInfo.uid,self.taskID,self.imageSize.width,self.imageSize.height];
        [self getUploadURL:uploadPath].then(^(NSDictionary *result){
            NSString *uploadUrl = result[@"url"];
            [weakSelf uploadFile:uploadUrl fileURL:[NSString stringWithFormat:@"file://%@",weakSelf.localPath]];
        });
    }
    
   
}

-(void) uploadVideoCover:(void(^)(void)) successBlock {
    __weak typeof(self) weakSelf = self;
    NSString *uploadPath = [NSString stringWithFormat:@"/dynamic/%@/%@.png@%0.0fx%0.0f",[WKApp shared].loginInfo.uid,self.taskID,self.imageSize.width,self.imageSize.height];
    
    [self getUploadURL:uploadPath].then(^(NSDictionary *result){
        NSString *uploadUrl = result[@"url"];
        
        NSURLSessionDataTask *task = [[WKAPIClient sharedClient] createFileUploadTask:uploadUrl fileURL:[NSString stringWithFormat:@"file://%@",weakSelf.localPath] progress:^(NSProgress * _Nullable uploadProgress) {
           
        } completeCallback:^(id  _Nullable responseObj, NSError * _Nullable error) {
            if(error) {
                weakSelf.status = WKMomentTaskStatusError;
                weakSelf.error = error;
                weakSelf.remoteURL = @"";
                WKLogDebug(@"上传失败！-> %@",error);
                [weakSelf update];
            }else {
                weakSelf.videoCoverURL = responseObj[@"path"];
                if(successBlock) {
                    successBlock();
                }
            }
        }];
        [task resume];
        
    });
}

- (void)stop {
    
}


-(void) uploadFile:(NSString*)uploadURL fileURL:(NSString*)fileURL{
   
    NSURLSessionDataTask *task = [self createAndAddUploadTask:uploadURL sourceFileURL:fileURL];
     if(task) {
         [task resume];
     }
}


// 创建和添加下载上传任务
-(NSURLSessionDataTask*) createAndAddUploadTask:(NSString*)uploadUrl sourceFileURL:(NSString*)fileURL {
    __weak typeof(self) weakSelf = self;
    NSURLSessionDataTask *task = [[WKAPIClient sharedClient] createFileUploadTask:uploadUrl fileURL:fileURL progress:^(NSProgress * _Nullable uploadProgress) {
        weakSelf.progress = uploadProgress.fractionCompleted;
        weakSelf.status = WKMomentTaskStatusProgressing;
        [weakSelf update];
    } completeCallback:^(id  _Nullable responseObj, NSError * _Nullable error) {
        if(error) {
            weakSelf.status = WKMomentTaskStatusError;
            weakSelf.error = error;
            weakSelf.remoteURL = @"";
            WKLogDebug(@"上传失败！-> %@",error);
        }else {
            weakSelf.remoteURL = responseObj[@"path"];
             weakSelf.status = WKMomentTaskStatusSuccess;
            weakSelf.error = nil;
        }
         [weakSelf update];
    }];
    [self.tasks addObject:task];
    return task;
}

// 获取上传地址
-(AnyPromise*) getUploadURL:(NSString*)path {
    return  [[WKAPIClient sharedClient] GET:[NSString stringWithFormat:@"%@file/upload?path=%@&type=moment",[WKApp shared].config.fileBaseUrl,path] parameters:nil];
}

-(NSMutableArray<NSURLSessionDataTask*>*) tasks {
    if(!_tasks) {
        _tasks = [NSMutableArray array];
    }
    return _tasks;
}

-(void) update {
    if(self.listeners) {
        for (WKTaskListener listener in self.listeners) {
            listener();
        }
    }
}


- (NSMutableDictionary *)listenerDic {
    if(!_listenerDic) {
        _listenerDic = [NSMutableDictionary dictionary];
    }
    return _listenerDic;
}

- (NSArray<WKTaskListener> *)listeners {
    return self.listenerDic.allValues;
}

- (void)addListener:(nonnull WKTaskListener)listener target:(id) target {
    self.listenerDic[NSStringFromClass([target class])] = listener;
}

- (void)removeListener:(id)target {
    [self.listenerDic removeObjectForKey:NSStringFromClass([target class])];
}

@end
