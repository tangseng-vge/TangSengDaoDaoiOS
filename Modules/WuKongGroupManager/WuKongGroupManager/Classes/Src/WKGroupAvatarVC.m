//
//  WKGroupAvatarVC.m
//  WuKongBase
//
//  Created by tt on 2022/4/12.
//

#import "WKGroupAvatarVC.h"
#import "WKActionSheetView2.h"
#import "WKMediaPickerController.h"
#import "TOCropViewController.h"
@interface WKGroupAvatarVC ()<TOCropViewControllerDelegate>

@property(nonatomic,strong) UIImageView *avatarImgView;

@property(nonatomic,strong) UIButton *moreButtonItem;


@end

@implementation WKGroupAvatarVC

- (void)viewDidLoad {
    [super viewDidLoad];
   
    
    self.navigationBar.rightView = self.moreButtonItem;
    
   
    [self.view addSubview:self.avatarImgView];
    [self.avatarImgView lim_setImageWithURL:[NSURL URLWithString:[WKAvatarUtil getGroupAvatar:self.groupNo]] placeholderImage:[WKApp shared].config.defaultAvatar];
}

- (NSString *)langTitle {
    return LLang(@"群聊头像");
}

- (UIImageView *)avatarImgView {
    if(!_avatarImgView) {
        _avatarImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, [self visibleRect].origin.y + 100.0f, WKScreenWidth/2.0f, WKScreenWidth/2.0f)];
        _avatarImgView.lim_centerX_parent = self.view;
        _avatarImgView.lim_centerY_parent = self.view;
    }
    return _avatarImgView;
}

// 右上角更多按钮
-(UIButton*) moreButtonItem {
    if(!_moreButtonItem) {
        _moreButtonItem = [UIButton buttonWithType:UIButtonTypeCustom];
        [_moreButtonItem addTarget:self action:@selector(moreBtnPress) forControlEvents:UIControlEventTouchUpInside];
        _moreButtonItem.frame = CGRectMake(0 , 0, 44, 44);
//       _moreButtonItem =[[UIBarButtonItem alloc] initWithCustomView:button];
        
        UIImage *img = [[self imageName:@"More"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [_moreButtonItem setImage:img forState:UIControlStateNormal];
        [_moreButtonItem setImage:img forState:UIControlStateHighlighted];
        [_moreButtonItem setTintColor:WKApp.shared.config.navBarButtonColor];
    }
    return _moreButtonItem;
}

-(UIImage*) imageName:(NSString*)name {
    return [[WKApp shared] loadImage:name moduleID:@"WuKongGroupManager"];
}


#pragma mark -- 事件

// 更多点击
-(void) moreBtnPress {
    
    WKChannelMember *member = [[WKSDK shared].channelManager getMember:[WKChannel groupWithChannelID:self.groupNo] uid:[WKApp shared].loginInfo.uid];
    
    __weak typeof(self) weakSelf = self;
    WKActionSheetView2 *actionSheet = [WKActionSheetView2 initWithTip:nil];
    
    if(member && ( member.role == WKMemberRoleCreator || member.role == WKMemberRoleManager)) {
        [actionSheet addItem:[WKActionSheetButtonItem2 initWithTitle:LLang(@"拍照") onClick:^{
            [weakSelf cameraPressed];
        }]];
        [actionSheet addItem:[WKActionSheetButtonItem2 initWithTitle:LLang(@"从手机相册选择") onClick:^{
            [[WKPhotoService shared] getPhotoOneFromLibrary:^(UIImage * _Nonnull image) {
                [weakSelf cropAvatar:image];
            }];
        }]];
    }
    
    [actionSheet addItem:[WKActionSheetButtonItem2 initWithTitle:LLang(@"保存图片") onClick:^{
        UIImageWriteToSavedPhotosAlbum(self.avatarImgView.image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
    }]];
    [actionSheet show];
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{
    // 保存完毕
       if (error) {
           [self.view showHUDWithHide:LLang(@"保存失败！")];
       }else{
          [self.view showHUDWithHide:LLang(@"保存成功！")];
       }
}

-(void) cameraPressed {
    __weak typeof(self) weakSelf = self;
    [[WKPhotoService shared] getPhotoFromCamera:^(UIImage * _Nonnull image) {
        [weakSelf cropAvatar:image];
    }];
}

-(void) cropAvatar:(UIImage*)avatarImg {
    TOCropViewController *cropController = [[TOCropViewController alloc] initWithCroppingStyle:TOCropViewCroppingStyleDefault image:avatarImg];
    cropController.delegate = self;
    cropController.aspectRatioPreset = TOCropViewControllerAspectRatioPresetSquare;
    cropController.aspectRatioPickerButtonHidden = YES;
    [self presentViewController:cropController animated:YES completion:nil];
}

#pragma mark - TOCropViewControllerDelegate

- (void)cropViewController:(nonnull TOCropViewController *)cropViewController
didCropToImage:(nonnull UIImage *)image withRect:(CGRect)cropRect
                     angle:(NSInteger)angle {
    [self dismissViewControllerAnimated:YES completion:nil];
   
    
    NSData *data = [[WKPhotoService shared] compressImageSize:image toByte:1024*50]; // 压缩到50k
    
    
    __weak typeof(self) weakSelf = self;
    [self.view showHUD:LLang(@"上传中")];
    [[WKAPIClient sharedClient] fileUpload:[NSString stringWithFormat:@"groups/%@/avatar",self.groupNo] data:data progress:^(NSProgress * _Nonnull progress) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.view switchHUDProgress:progress.fractionCompleted];
        });
    } completeCallback:^(id  _Nullable resposeObject, NSError * _Nullable error) {
        if(error) {
            [weakSelf.view switchHUDSuccess:LLangW(@"上传失败", weakSelf)];
            WKLogError(@"上传失败！-> %@",error);
        }else {
            weakSelf.avatarImgView.image = image;
            [weakSelf.view switchHUDSuccess:LLangW(@"上传成功", weakSelf)];
            [[SDImageCache sharedImageCache] removeImageForKey:[WKAvatarUtil getGroupAvatar:[WKApp shared].loginInfo.uid] withCompletion:nil];
        }
        
    }];
}


@end
