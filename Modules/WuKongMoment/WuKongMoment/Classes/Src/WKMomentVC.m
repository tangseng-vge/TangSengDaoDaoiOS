//
//  WKMomentVC.m
//  WuKongMoment
//
//  Created by tt on 2020/11/5.
//

#import "WKMomentVC.h"
#import "UIScrollView+PullScaleMoment.h"
#import "WKMomentModule.h"
#import "WKRefreshView.h"
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/ALAsset.h>
#import <AssetsLibrary/ALAssetsLibrary.h>
#import <AssetsLibrary/ALAssetRepresentation.h>
#import "WKMomentConst.h"
#import "WKMomentPublishVC.h"
#import "WKMomentCommentItemTextCell.h"
#import "WKMomentFileUploadTask.h"
#import "WKMomentCommon.h"
#import "WKMomentMsgManager.h"
#import <MJRefresh/MJRefresh.h>
#import "WKMomentMsgListVC.h"


@interface WKMomentVC ()<WKSimpleInputDelegate,WKMomentVMDelegate,WKMomentMsgManagerDelegate>

@property(nonatomic,strong) UIButton *iconCameraBtn;
@property(nonatomic,strong) UIButton *msgBtn;

@property(nonatomic,strong) WKRefreshView *refreshView;

@property(nonatomic,strong) WKUserAvatar *avatarImgView; // 头像
@property(nonatomic,strong) UILabel *nameLbl;
@property(nonatomic,strong) WKMediaFetcher *mediaFetcher;

@property(nonatomic,strong) WKSimpleInput *input;

@property(nonatomic,strong) WKMomentResp *selectedMoment; // 被选中的朋友圈编号
@property(nonatomic,strong) WKCommentResp *selectedComment; // 被选中的评论


@end

@implementation WKMomentVC

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.viewModel = [WKMomentVM new];
        self.viewModel.delegate = self;
    }
    return self;
}

-(WKMediaFetcher*) mediaFetcher {
    if(!_mediaFetcher) {
        _mediaFetcher = [[WKMediaFetcher alloc] init];
        _mediaFetcher.mediaTypes =  @[(NSString *)kUTTypeImage];
        
    }
    return _mediaFetcher;
}


- (void)viewDidLoad {
   
    self.viewModel.uid = self.uid;
    
    [super viewDidLoad];
    
    [self.navigationBar setStyle:WKNavigationBarStyleWhite];
    [self.navigationBar setBackgroundColor:[UIColor clearColor]];
    
    [self.view addSubview:self.avatarImgView];
    [self.view addSubview:self.nameLbl];
    
    [self.view bringSubviewToFront:self.navigationBar];
    
    [self.tableView addPullScaleFuncInVC:self
                          originalHeight:BIG_BACKGROUP_IMAGE_HEIGHT
                               hasNavBar:NO];
    self.tableView.imageV.image = [self imageName:@"DynamicDefaultBackground"];
    
    if([self.viewModel isSelf]) {
        self.tableView.imageV.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onPullImagePressed)];
        [self.tableView.imageV addGestureRecognizer:tap];
    }
   
    
    [self.tableView.imageV lim_setImageWithURL:[NSURL URLWithString:[self coverURL]] placeholderImage:[self imageName:@"DynamicDefaultBackground"]];
    
    if([self.viewModel isSelf]) {
        if(self.showMsg) {
            self.rightView = self.msgBtn;
        }else{
            self.rightView = self.iconCameraBtn;
            UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(cameraLongPressed:)];
            longPress.minimumPressDuration = 0.5;
            [self.iconCameraBtn addGestureRecognizer:longPress];
        }
       
    }
    
    
    [self.view addSubview:self.input];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadMoments) name:WK_MOMENTPUBLISH_NOTIFY object:nil];
    
    
    [self.viewModel requestMoments];
    
    __weak typeof(self) weakSelf = self;
    MJRefreshAutoNormalFooter *footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        [weakSelf pullup];
    }];
    footer.refreshingTitleHidden = YES;
    footer.stateLabel.hidden  = YES;
    self.tableView.mj_footer = footer;
    
    [[WKMomentMsgManager shared] addDelegate:self];
   
}

- (NSString *)langTitle {
    return LLang(@"朋友圈");
}

-(void) cameraLongPressed:(UILongPressGestureRecognizer*)gestureRecognizer {
    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan) {
        if (@available(iOS 10.0, *)) {
            static UIImpactFeedbackGenerator *feedbackSelection;
            if(!feedbackSelection) {
                feedbackSelection = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleLight];
            }
            [feedbackSelection prepare];
            [feedbackSelection impactOccurred];
        }
        WKMomentPublishVC *vc = [WKMomentPublishVC new];
        [[WKNavigationManager shared] pushViewController:vc animated:YES];
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle{

    return UIStatusBarStyleDefault;
}

-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIBarStyleBlack];
    [self.navigationController.navigationBar setBarStyle:UIBarStyleBlack];
    
    // UIStatusBarStyleDefault
}

-(void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController.navigationBar setBarStyle:UIBarStyleDefault];
    [[UIApplication sharedApplication] setStatusBarStyle:UIBarStyleDefault];
    
    if(WKApp.shared.config.style == WKSystemStyleDark) {
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    }else{
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDarkContent;
    }
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if(!self.refreshView.superview) {
        [self.tableView.superview addSubview:self.refreshView];
    }else{
        [self.tableView.superview bringSubviewToFront:self.refreshView];
    }
}


- (void)dealloc {
    [[WKMomentMsgManager shared] removeDelegate:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:WK_MOMENTPUBLISH_NOTIFY object:nil];
}

-(void) onPullImagePressed {
    __weak typeof(self) weakSelf = self;
    WKActionSheetView2 *action = [WKActionSheetView2 initWithTip:nil];
    [action addItem:[WKActionSheetButtonItem2 initWithTitle:LLang(@"拍照") onClick:^{
        [weakSelf.mediaFetcher fetchMediaFromCamera:^(NSString *path, UIImage *image) {
            [weakSelf uploadCover:image];
        }];
    }]];
    [action addItem:[WKActionSheetButtonItem2 initWithTitle:LLang(@"从相册选") onClick:^{
        self.mediaFetcher.limit = 1;
        [weakSelf.mediaFetcher fetchPhotoFromLibraryOfCompress:^(NSData *imageData, NSString *path, bool isSelectOriginalPhoto, PHAssetMediaType type, NSInteger left) {
            switch (type) {
                case PHAssetMediaTypeImage:{
                    [weakSelf uploadCover:[[UIImage alloc] initWithData:imageData]];
                }
                    break;
                default:
                    break;
            }
        } cancel:^{
            weakSelf.mediaFetcher = nil;
        }];
    }]];
    [action show];
}

// 封面地址
-(NSString*) coverURL {
   
    return [NSString stringWithFormat:@"%@moment/cover?uid=%@",[WKApp shared].config.apiBaseUrl,[self.viewModel getRealUID]];
}

// 上传封面
-(void) uploadCover:(UIImage*)img {
    __weak typeof(self) weakSelf = self;
    [self.viewModel uploadCover:img].then(^{
        [[SDImageCache sharedImageCache] storeImage:img forKey:[weakSelf coverURL] completion:^{
            [weakSelf.tableView.imageV lim_setImageWithURL:[NSURL URLWithString:[weakSelf coverURL]] placeholderImage:[self imageName:@"DynamicDefaultBackground"]];
        }];
    });
}

-(void) pullup {
    self.viewModel.pageIndex++;
    __weak typeof(self) weakSelf = self;
    [self.viewModel requestMoments].then(^{
        if(weakSelf.viewModel.completed) {
            [weakSelf.tableView.mj_footer endRefreshingWithNoMoreData];
        }else{
            [weakSelf.tableView.mj_footer endRefreshing];
        }
        
    });
}


-(void) reloadMoments {
    [self.viewModel requestMoments];
}

- (WKRefreshView *)refreshView {
    if(!_refreshView) {
        _refreshView = [WKRefreshView refreshHeaderWithCenter:CGPointMake(40, 45)];
        _refreshView.scrollView = self.tableView;
        __weak typeof(_refreshView) weakHeader = _refreshView;
        __weak typeof(self) weakSelf = self;
        [_refreshView setRefreshingBlock:^{
            weakSelf.viewModel.completed = false;
            weakSelf.viewModel.pageIndex = 1;
            [weakSelf.tableView.mj_footer resetNoMoreData];
            [weakSelf.viewModel requestMoments].then(^{
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [weakHeader endRefreshing];
                    });
                    
                });
                
            });
        }];
    }
    return _refreshView;
}

- (WKSimpleInput *)input {
    if(!_input) {
        _input = [WKSimpleInput new];
        _input.delegate = self;
        _input.hidden = YES;
    }
    return _input;
}

// 右上角更多按钮
-(UIButton*) iconCameraBtn {
    if(!_iconCameraBtn) {
        _iconCameraBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_iconCameraBtn addTarget:self action:@selector(cameraPressed) forControlEvents:UIControlEventTouchUpInside];
        _iconCameraBtn.frame = CGRectMake(0 , 0, 44, 44);
        [_iconCameraBtn setImage:[self imageName:@"IconCamera"] forState:UIControlStateNormal];
//       _moreButtonItem =[[UIBarButtonItem alloc] initWithCustomView:button];
    }
    return _iconCameraBtn;
}

- (UIButton *)msgBtn {
    if(!_msgBtn) {
        _msgBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_msgBtn addTarget:self action:@selector(msgPressed) forControlEvents:UIControlEventTouchUpInside];
        _msgBtn.frame = CGRectMake(0.0f, 0.0f, 24.0f, 24.0f);
        UIImage *img = [[self imageName:@"IconMsg"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [_msgBtn setImage:img forState:UIControlStateNormal];
    }
    return _msgBtn;
}

- (WKUserAvatar *)avatarImgView {
    if(!_avatarImgView) {
        CGFloat size = 70.0f;
        _avatarImgView = [[WKUserAvatar alloc] initWithFrame:CGRectMake(WKScreenWidth - size -15.0f ,BIG_BACKGROUP_IMAGE_HEIGHT+20.0f, size, size)];
        [_avatarImgView setUrl:[WKAvatarUtil getAvatar:[self.viewModel getRealUID]]];
        _avatarImgView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onAvatarTap)];
        [_avatarImgView addGestureRecognizer:tap];
//        [_avatarImgView setBackgroundColor:[UIColor redColor]];
    }
    return _avatarImgView;
}

-(void) onAvatarTap {
    [[WKApp shared] invoke:WKPOINT_USER_INFO param:@{@"uid":[self.viewModel getRealUID]}];
}

- (UILabel *)nameLbl {
    if(!_nameLbl) {
        _nameLbl = [[UILabel alloc] init];
        _nameLbl.font = [[WKApp shared].config appFontOfSize:16.0f];
        _nameLbl.textColor = [UIColor whiteColor];
        _nameLbl.shadowColor = [UIColor blackColor];
        _nameLbl.shadowOffset = CGSizeMake(0, -1.0);
        _nameLbl.text = [self.viewModel getRealName];
        [_nameLbl setTextAlignment:NSTextAlignmentRight];
        [_nameLbl sizeToFit];
        _nameLbl.lim_left = self.avatarImgView.lim_left - _nameLbl.lim_width - 15.0f;
        _nameLbl.lim_top = self.avatarImgView.lim_top + 20.0f;
    }
    return _nameLbl;
}

-(void) cameraPressed {
    
    __weak typeof(self) weakSelf = self;
    WKActionSheetView2 *sheet = [WKActionSheetView2 initWithTip:nil];
    
    [sheet addItem:[WKActionSheetButtonSubtitleItem2 initWithTitle:LLang(@"拍摄") subtitle:LLang(@"照片或视频")  onClick:^{
        [WKVideoRecordUtil videoRecord:^(NSString * _Nonnull coverPath, NSString * _Nonnull videoPath) {
            WKMomentPublishVC *vc = [WKMomentPublishVC new];
            vc.isVideo = true;
            vc.coverImg = [UIImage imageWithContentsOfFile:coverPath];
            vc.videoPath = videoPath;
            [[WKNavigationManager shared] pushViewController:vc animated:YES];
        } imgCallback:^(UIImage * _Nonnull img) {
            WKMomentPublishVC *vc = [WKMomentPublishVC new];
            vc.imgTasks = @[[WKMomentFileUploadTask createImageUploadTask:img]];
            
            [[WKNavigationManager shared] pushViewController:vc animated:YES];
        }];
    }]];
    [sheet addItem:[WKActionSheetButtonItem2 initWithTitle:LLang(@"从手机相册选择")   onClick:^{
        [weakSelf selectPhoto];
    }]];
    
    [sheet show];
}

-(void) msgPressed {
    [[WKNavigationManager shared] pushViewController:[WKMomentMsgListVC new] animated:YES];
}

-(void) selectPhoto {
    __weak typeof(self) weakSelf = self;
    self.mediaFetcher.limit = 9;
    NSMutableArray<UIImage*> *imageList = [NSMutableArray array];
    
    [self.mediaFetcher fetchPhotoFromLibraryOfCompress:^(NSData *imageData, NSString *path, bool isSelectOriginalPhoto, PHAssetMediaType type, NSInteger left) {
        switch (type) {
            case PHAssetMediaTypeImage:{
                [imageList addObject:[[UIImage alloc] initWithData:imageData]];
                if(left == 0) {
                    WKMomentPublishVC *vc = [WKMomentPublishVC new];
                    NSMutableArray *tasks = [NSMutableArray array];
                    for (UIImage *img  in imageList) {
                        [tasks addObject:[WKMomentFileUploadTask createImageUploadTask:img]];
                    }
                    vc.imgTasks = tasks;
                    [[WKNavigationManager shared] pushViewController:vc animated:YES];
                }
                
                break;
            }
            case PHAssetMediaTypeVideo:{
                WKMomentPublishVC *vc = [WKMomentPublishVC new];
                vc.isVideo = true;
                vc.coverImg = [weakSelf getVideoPreViewImage:[NSURL fileURLWithPath:path]];
                vc.videoPath = path;
                [[WKNavigationManager shared] pushViewController:vc animated:YES];
               
                break;
            }
            case PHAssetMediaTypeAudio: {
                
                break;
            }
            case PHAssetMediaTypeUnknown: {
                
                break;
            }
        }
    } cancel:nil];
}

// 获取视频第一帧
- (UIImage*) getVideoPreViewImage:(NSURL *)path
{
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:path options:nil];
    AVAssetImageGenerator *assetGen = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    
    assetGen.appliesPreferredTrackTransform = YES;
    CMTime time = CMTimeMakeWithSeconds(0.0, 600);
    NSError *error = nil;
    CMTime actualTime;
    CGImageRef image = [assetGen copyCGImageAtTime:time actualTime:&actualTime error:&error];
    UIImage *videoImage = [[UIImage alloc] initWithCGImage:image];
    CGImageRelease(image);
    return videoImage;
}


-(CGRect) tableViewFrame {
    return CGRectMake(0.0f, 0.0f, self.view.lim_width, self.view.lim_height);
}


#define SCROLL_OFFSET 60.0f
- (void)scrollViewDidScroll:(UIScrollView*)scrollView {
    if (![scrollView isKindOfClass:[UITableView class]]) {
        return;
    }
    CGFloat y = scrollView.contentOffset.y;
    

   
    [self updateAvatarY:y];
    
    CGFloat contentY = y+self.navigationBar.lim_bottom;
    if(contentY>-20.0f && contentY<=20) { // Alpha 变化
        [self showNavStyle:WKNavigationBarStyleDefault];
        if([WKApp shared].config.style == WKSystemStyleDark) {
            [self.navigationBar setBackgroundColor:[UIColor colorWithRed:16.0f/255.0f green:16.0f/255.0f blue:16.0f/255.0f alpha:(20.0f+contentY)/40.0f]];
        }else{
            [self.navigationBar setBackgroundColor:[[WKApp shared].config navBackgroudColorWithAlpha:(20.0f+contentY)/40.0f]];
        }
        
    }
    
    
    if(contentY<-20) {
        [self showNavStyle:WKNavigationBarStyleWhite];

    }
    if(contentY>20) {
        if([WKApp shared].config.style == WKSystemStyleDark) {
            [self showNavStyle:WKNavigationBarStyleDark];
        }else {
            [self showNavStyle:WKNavigationBarStyleDefault];
        }
        
    }

}

-(void) updateAvatarY:(CGFloat)y {
    self.avatarImgView.lim_top = -y - self.avatarImgView.lim_height + 20.0f;
    self.nameLbl.lim_top = self.avatarImgView.lim_top + 20.0f;
}


-(void) showNavStyle:(WKNavigationBarStyle) style {
    if(style == WKNavigationBarStyleDefault || style == WKNavigationBarStyleDark) {
        self.title = LLang(@"朋友圈");
        [[UIApplication sharedApplication] setStatusBarStyle:UIBarStyleDefault];
        [self.navigationController.navigationBar setBarStyle:UIBarStyleDefault];
        [self.navigationBar setStyle:style];
        [self.navigationBar setBackgroundColor:[WKApp shared].config.navBackgroudColor];
        if([WKApp shared].config.style == WKSystemStyleDark) {
            [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
            [self.iconCameraBtn setImage:[self imageName:@"IconCamera"] forState:UIControlStateNormal];
            [self.navigationBar.backButton setTintColor:[UIColor whiteColor]];
            [[UIApplication sharedApplication] setStatusBarStyle:UIBarStyleBlack];
            [self.msgBtn setTintColor:[UIColor whiteColor]];
        }else{
            [UIApplication sharedApplication].statusBarStyle =  UIStatusBarStyleDarkContent;
            [self.iconCameraBtn setImage:[self imageName:@"NavIconCamera"] forState:UIControlStateNormal];
            [self.navigationBar.backButton setTintColor:[UIColor blackColor]];
            [self.msgBtn setTintColor:[UIColor blackColor]];
        }
        
    }else{
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
        self.title = @"";
        [self.navigationController.navigationBar setBarStyle:UIBarStyleBlack];
        [[UIApplication sharedApplication] setStatusBarStyle:UIBarStyleBlack];
        [self.navigationBar setBackgroundColor:[UIColor clearColor]];
        [self.navigationBar setStyle:WKNavigationBarStyleWhite];
        [self.iconCameraBtn setImage:[self imageName:@"IconCamera"] forState:UIControlStateNormal];
        [self.msgBtn setTintColor:[UIColor whiteColor]];
        [self.navigationBar.backButton setTintColor:[UIColor whiteColor]];
        
    }
    
}


- (UIImage*) imageName:(NSString*)name {
    return [[WKApp shared] loadImage:name moduleID:[WKMomentModule gmoduleId]];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    UITableViewCell* cell = [self.tableView cellForRowAtIndexPath:indexPath];
    if([cell isKindOfClass:[WKMomentCommentItemTextCell class]]) {
        self.selectedMoment = self.viewModel.moments[indexPath.section-1];
        
        WKMomentCommentItemTextCell *commentCell = (WKMomentCommentItemTextCell*)cell;
        NSInteger commentIndex= [self commentInMomentIndex:self.selectedMoment commentSID:commentCell.model.sid];
    
        self.selectedComment = self.selectedMoment.comments[commentIndex];
        if([self.selectedComment.uid isEqualToString:[WKApp shared].loginInfo.uid]) {
            WKActionSheetView2 *sheet = [WKActionSheetView2 initWithTip:LLang(@"删除这条评论？")];
            __weak typeof(self) weakSelf  = self;
            [sheet addItem:[WKActionSheetButtonItem2 initWithAlertTitle:LLang(@"删除") onClick:^{
                [weakSelf.tableView beginUpdates];
                NSMutableArray *newComments = [NSMutableArray arrayWithArray:weakSelf.selectedMoment.comments];
                [newComments removeObjectAtIndex:commentIndex];
                weakSelf.selectedMoment.comments = newComments;
                NSMutableArray *newItems =  [NSMutableArray arrayWithArray:weakSelf.items[indexPath.section].items];
                [newItems removeObjectAtIndex:indexPath.row];
                weakSelf.items[indexPath.section].items = newItems;
                [weakSelf.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                [weakSelf.tableView endUpdates];
                
                [weakSelf.viewModel requestCommentDel:weakSelf.selectedMoment.momentNo commentID:weakSelf.selectedComment.sid].catch(^(NSError *error){
                    [[WKNavigationManager shared].topViewController.view showHUDWithHide:error.domain];
                });
            }]];
            [sheet show];
        }else{
            [self showInputInCell:cell];
        }
       
    }
}

-(NSInteger) commentInMomentIndex:(WKMomentResp*)moment commentSID:(NSString*)sid{
    if(moment.comments) {
        for (NSInteger i=0;i<moment.comments.count; i++) {
            WKCommentResp *comment = moment.comments[i];
            if([sid isEqualToString:comment.sid]) {
                return i;
            }
        }
    }
    return -1;
}

-(void) showInputInCell:(UITableViewCell*)cell {
    self.input.hidden = NO;
    self.input.placeholder = LLang(@"评论");
    if(self.selectedComment) {
        self.input.placeholder = [NSString stringWithFormat:LLang(@"回复%@"),self.selectedComment.name];
    }
    [self.input becomeFirstResponder];
    __weak typeof(self) weakSelf = self;
    [UIView
        animateWithDuration:.25f
                 animations:^{
                     [weakSelf.tableView
                         setContentOffset:CGPointMake(0, cell.lim_bottom - WKScreenHeight + weakSelf.input.inputTotalHeight)
                                 animated:NO];
                 }];
}

- (void)tableView:(UITableView *)tableView touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.input endEditing:YES];
    self.input.hidden = YES;
    [self adjustTableWithOffset:0.0f];
}

// 校准table的位置
-(void) adjustTable{
    
    CGFloat changeHeight = self.input.inputTotalHeight;
    
    [self adjustTableWithOffset:changeHeight];
    
}

-(void) layoutTable{
    self.tableView.lim_width = self.view.lim_width;
    self.tableView.lim_height = self.view.lim_height;
}

-(void) adjustTableWithOffset:(CGFloat)offset {
    self.tableView.lim_top = -offset;
    
    self.tableView.contentInset = UIEdgeInsetsMake(offset+BIG_BACKGROUP_IMAGE_HEIGHT, 0, 0, 0);
//    UIEdgeInsets contentInset = self.tableView.contentInset;
//    self.tableView.scrollIndicatorInsets = contentInset;
}

#pragma mark - WKSimpleInputDelegate

- (void)simpleInput:(WKSimpleInput *)input heightChange:(CGFloat)height {
    
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.12f delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [weakSelf adjustTableWithOffset:height-weakSelf.input.inputTextViewMinHeight];
    } completion:nil];
}

- (void)simpleInput:(WKSimpleInput *)input sendText:(NSString *)text {
    if(!self.selectedMoment) {
        return;
    }
    
    
    WKCommentResp *commentResp = [WKCommentResp new];
    commentResp.uid = [WKApp shared].loginInfo.uid;
    commentResp.name = [WKApp shared].loginInfo.extra[@"name"];
    commentResp.content = text;
    if(self.selectedComment) {
        commentResp.replyUID = self.selectedComment.uid;
        commentResp.replyName = self.selectedComment.name;
    }
    
    NSMutableArray *newComments =  [NSMutableArray arrayWithArray:self.selectedMoment.comments];
    [newComments addObject:commentResp];
    
    self.selectedMoment.comments = newComments;
    [self reloadData];
    self.input.hidden = YES;
    [self.input endEditing:YES];
    
    WKCommentReq *req = [WKCommentReq new];
    req.content = text;
    if(self.selectedComment) {
        req.replyUID = self.selectedComment.uid;
        req.replyName = self.selectedComment.name;
        req.replyCommentID = self.selectedComment.sid;
    }
    __weak typeof(self) weakSelf = self;
    [self.viewModel requestCommentAdd:self.selectedMoment.momentNo req:req].then(^(NSDictionary *result){
        commentResp.sid = result[@"id"];
        [weakSelf reloadData];
    }).catch(^(NSError*error){
        [[WKNavigationManager shared].topViewController.view showHUDWithHide:error.domain];
    });

}

#pragma mark - WKMomentVMDelegate

// 点击评论按钮
-(void) momentVMCommentClick:(WKMomentVM*)vm cell:(WKMomentOperateCell*)cell model:(WKMomentResp*)model {
    self.selectedMoment = model;
    self.selectedComment = nil;
    [self showInputInCell:cell];
}

// 删除朋友圈
-(void) momentVMDelete:(WKMomentVM*)vm model:(WKMomentResp*)model {
    WKActionSheetView2 *sheet = [WKActionSheetView2 initWithTip:LLang(@"删除这条朋友圈？")];
    __weak typeof(self) weakSelf  = self;
    [sheet addItem:[WKActionSheetButtonItem2 initWithAlertTitle:LLang(@"删除") onClick:^{
        [weakSelf.viewModel removeMoment:model.momentNo];
        [weakSelf reloadData];
        
        [weakSelf.viewModel requestDeleteMoment:model.momentNo].catch(^(NSError *error){
            NSLog(@"删除朋友圈失败！-> %@",error);
            [[WKNavigationManager shared].topViewController.view showHUDWithHide:LLang(@"删除朋友圈失败！")];
        });
    }]];
    [sheet show];
}


// 点赞
- (void)momentVMDLikeClick:(WKMomentVM *)vm model:(WKMomentResp *)model like:(BOOL)like{
    if(like) {
        [self.viewModel requestLike:model.momentNo].catch(^(NSError *error){
            [[WKNavigationManager shared].topViewController.view showHUDWithHide:error.domain];
        });
    }else {
        [self.viewModel requestUnlike:model.momentNo].catch(^(NSError *error){
            [[WKNavigationManager shared].topViewController.view showHUDWithHide:error.domain];
        });
    }
}


#pragma mark - WKMomentMsgManagerDelegate

- (void)recvMomentCMDMsg:(WKCMDModel *)cmd {
    [self reloadData];
}

@end
