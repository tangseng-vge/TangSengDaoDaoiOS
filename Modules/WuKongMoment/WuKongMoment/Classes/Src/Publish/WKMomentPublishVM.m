//
//  WKMomentPublishVM.m
//  WuKongMoment
//
//  Created by tt on 2020/11/12.
//

#import "WKMomentPublishVM.h"
#import "WKMomentPublishInputCell.h"
#import "WKMomentPublishImgGroupCell.h"
#import "WKMomentPublishSettingItemCell.h"
#import "WKMomentModule.h"
#import "WKMomentPublishVideoCell.h"
#import "WKMomentPrivacyVC.h"

@interface WKMomentPublishVM ()


@property(nonatomic,strong) WKMomentPrivacySelect *momentPrivacySelect;

@end

@implementation WKMomentPublishVM

- (WKMomentPrivacySelect *)momentPrivacySelect {
    if(!_momentPrivacySelect) {
        _momentPrivacySelect = [[WKMomentPrivacySelect alloc] init];
        _momentPrivacySelect.privacyKey = @"public";
    }
    return _momentPrivacySelect;
}

-(BOOL) onlyPublishText {
    BOOL onlyText = false;
    if((!self.imgTasks||self.imgTasks.count<=0) && !self.videoTask) {
        onlyText = true;
    }
    return onlyText;
}

- (NSArray<NSDictionary *> *)tableSectionMaps {
    NSMutableArray *items = [NSMutableArray array];
    __weak typeof(self) weakSelf = self;
    
    UIColor *shareToColor = WKApp.shared.config.defaultTextColor;
    NSString *shareToTitle = LLang(@"谁可以看");
    if([self.momentPrivacySelect.privacyKey isEqualToString:@"internal"]) {
        shareToColor = WKApp.shared.config.themeColor;
    }else if([self.momentPrivacySelect.privacyKey isEqualToString:@"prohibit"]) {
        shareToColor = [UIColor redColor];
        shareToTitle = LLang(@"不给谁看");
    }
    
    [items addObject: @{
        @"height":@(0.01f),
        @"items": @[
                @{
                    @"class":  WKMomentPublishInputModel.class,
                    @"onChange":^(NSString*value,UITextField *textfield){
                        weakSelf.content = value;
                        if(weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(momentPublishVMContentChange:textfiled:)]) {
                            [weakSelf.delegate momentPublishVMContentChange:self textfiled:textfield];
                        }
                    }
                },
        ]
    }];

    if(![self onlyPublishText]) {
        if(self.isVideo) {
            [items addObject: @{
                @"height":@(0.01f),
                @"items": @[
                        @{
                            @"class":  WKMomentPublishVideoModel.class,
                            @"videoTask": self.videoTask,
                        }
                ]
            }];
        }else{
            [items addObject: @{
                @"height":@(0.01f),
                @"items": @[
                        @{
                            @"class":  WKMomentPublishImgGroupModel.class,
                            @"imgTasks":self.imgTasks?:@[],
                            @"onAdd":^{
                                if(weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(momentPublishVMAddImg:)]) {
                                    [weakSelf.delegate momentPublishVMAddImg:weakSelf];
                                }
                            },
                        }
                ]
            }];
        }
    }
   
    
    [items addObject: @{
        @"height":@(20.0f),
        @"items": @[
                @{
                    @"class":  WKMomentPublishSettingItemModel.class,
                    @"icon": [self imageName:@"IconPerson"],
                    @"showArrow":@(true),
                    @"title": shareToTitle,
                    @"color": shareToColor,
                    @"value": weakSelf.momentPrivacySelect.displayName?:LLang(@"公开"),
                    @"onClick":^ {
                        WKMomentPrivacyVC *vc = [WKMomentPrivacyVC new];
                        vc.momentPrivacySelect = [self.momentPrivacySelect copy];
                        [vc setOnFinish:^(WKMomentPrivacySelect * _Nonnull select) {
    
                            weakSelf.momentPrivacySelect = [select copy];
                            
                            [weakSelf reloadData];
                        }];
                        [[WKNavigationManager shared] pushViewController:vc animated:YES];
                    }
                }
        ]
    }];
    
    return items;
}


-(AnyPromise*) publish {
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    param[@"text"] = self.content?:@"";
    param[@"privacy_type"] = self.momentPrivacySelect.privacyKey;
    if(self.momentPrivacySelect.privacyUIDS && self.momentPrivacySelect.privacyUIDS.count>0) {
        param[@"privacy_uids"] = self.momentPrivacySelect.privacyUIDS;
    }
    
    if(self.isVideo) {
        param[@"video_path"] = self.videoTask.remoteURL?:@"";
        param[@"video_cover_path"] = self.videoTask.videoCoverURL?:@"";
    }else{
        if(self.imgTasks) {
            NSMutableArray *imgs = [NSMutableArray array];
            for (WKMomentFileUploadTask *task in self.imgTasks) {
                [imgs addObject:task.remoteURL?:@""];
            }
            param[@"imgs"] = imgs;
        }
    }
   
    return [[WKAPIClient sharedClient] POST:@"moments" parameters:param];
}

- (UIImage*) imageName:(NSString*)name {
    return [[WKApp shared] loadImage:name moduleID:[WKMomentModule gmoduleId]];
}

@end
