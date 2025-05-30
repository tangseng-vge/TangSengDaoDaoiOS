//
//  WKMomentPublishVC.m
//  WuKongMoment
//
//  Created by tt on 2020/11/12.
//

#import "WKMomentPublishVC.h"
#import "WKMomentPublishImgGroupCell.h"
#import "WKMomentCommon.h"

#define imgMaxLimit 9

@interface WKMomentPublishVC ()<WKMomentPublishVMDelegate>

@property(nonatomic,strong) WKMediaFetcher *mediaFetcher;
@end

@implementation WKMomentPublishVC

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.viewModel = [WKMomentPublishVM new];
        self.viewModel.delegate = self;
    }
    return self;
}

-(WKMediaFetcher*) mediaFetcher {
    if(!_mediaFetcher) {
        _mediaFetcher = [[WKMediaFetcher alloc] init];
    }
    return _mediaFetcher;
}

- (void)viewDidLoad {
    
    self.viewModel.imgTasks = self.imgTasks;
    self.viewModel.isVideo = self.isVideo;
    if(self.isVideo) {
        self.viewModel.videoTask = [WKMomentFileUploadTask createVideoUploadTask:self.coverImg videoPath:self.videoPath];
    }
    
    [super viewDidLoad];
//    [self.navigationBar setBackgroundColor:[UIColor whiteColor]];
//    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    if([self.viewModel onlyPublishText]) {
        self.finishBtn.alpha = 0.5f;
        self.finishBtn.enabled = NO;
    }
    [self.finishBtn setTitle:LLang(@"发表") forState:UIControlStateNormal];
    [self.finishBtn addTarget:self action:@selector(onFinish) forControlEvents:UIControlEventTouchUpInside];
    self.rightView = self.finishBtn;
   
}

-(void) onFinish {
    __weak typeof(self) weakSelf = self;
    if(self.viewModel.isVideo) {
        if(self.viewModel.videoTask.status != WKMomentTaskStatusSuccess) {
            [[WKNavigationManager shared].topViewController.view showHUDWithHide:LLang(@"还有未上传完成不能发布！")];
            return;
        }
    }
    if(self.viewModel.imgTasks && self.viewModel.imgTasks.count>0){
        for (WKMomentFileUploadTask *task in self.viewModel.imgTasks) {
            if(task.status != WKMomentTaskStatusSuccess) {
                [[WKNavigationManager shared].topViewController.view showHUDWithHide:LLang(@"还有未上传完成不能发布！")];
                return;
            }
        }
    }
        
    [self.view showHUD];
    [self.viewModel publish].then(^{
        [weakSelf.view hideHud];
        [[WKNavigationManager shared] popViewControllerAnimated:YES];
        [[NSNotificationCenter defaultCenter] postNotificationName:WK_MOMENTPUBLISH_NOTIFY object:nil];
    }).catch(^(NSError *error){
        [weakSelf.view switchHUDError:error.domain];
    });
}


-(void) reloadImgGroup {
    NSIndexPath *imgGroupIndexPath = [NSIndexPath indexPathForRow:0 inSection:1];
   WKFormItemCell *cell =  (WKFormItemCell*)[self.tableView cellForRowAtIndexPath:imgGroupIndexPath];
    if(cell) {
        WKMomentPublishImgGroupModel *model = (WKMomentPublishImgGroupModel*)self.items[imgGroupIndexPath.section].items[imgGroupIndexPath.row];
        model.imgTasks = self.imgTasks;
        [cell refresh:model];
        [self.tableView reloadRowsAtIndexPaths:@[imgGroupIndexPath] withRowAnimation:UITableViewRowAnimationNone];
    }
}

#pragma mark - WKMomentPublishVMDelegate

- (void)momentPublishVMContentChange:(WKMomentPublishVM *)vm textfiled:(UITextField *)textfield {
    if(![self.viewModel onlyPublishText]) {
        return;
    }
    NSString *text = [textfield.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if(text.length>0) {
        self.finishBtn.alpha = 1.0f;
        self.finishBtn.enabled = YES;
    }else {
        self.finishBtn.alpha = 0.5f;
        self.finishBtn.enabled = NO;
    }
}

- (void)momentPublishVMAddImg:(WKMomentPublishVM *)vm {
    if(imgMaxLimit - self.imgTasks.count>0) {
        self.mediaFetcher.mediaTypes = @[(NSString*)kUTTypeImage];
        self.mediaFetcher.limit = imgMaxLimit - self.imgTasks.count;
        __weak typeof(self) weakSelf = self;
        NSMutableArray *newTasks = [NSMutableArray arrayWithArray:weakSelf.imgTasks];
        
        [self.mediaFetcher fetchPhotoFromLibraryOfCompress:^(NSData *imageData, NSString *path, bool isSelectOriginalPhoto, PHAssetMediaType type, NSInteger left) {
            switch (type) {
                case PHAssetMediaTypeImage:{
                    [newTasks addObject:[WKMomentFileUploadTask createImageUploadTask:[[UIImage alloc] initWithData:imageData]]];
                    if(left == 0) {
                        weakSelf.imgTasks = newTasks;
                        weakSelf.viewModel.imgTasks = newTasks;
                        [weakSelf reloadImgGroup];
                    }
                    break;
                }
                case PHAssetMediaTypeUnknown: {
                    
                    break;
                }
                case PHAssetMediaTypeVideo: {
                    
                    break;
                }
                case PHAssetMediaTypeAudio: {
                    
                    break;
                }
            }
        } cancel:^{
            weakSelf.mediaFetcher = nil;
        }];
    }
}

@end
