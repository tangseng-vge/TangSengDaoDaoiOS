//
//  WKGroupManagerModule.m
//  WuKongGroupManager
//
//  Created by tt on 2022/6/27.
//

#import "WKGroupManagerModule.h"
#import "WKGroupManagerVC.h"
#import "WKGroupAvatarVC.h"

@WKModule(WKGroupManagerModule)
@implementation WKGroupManagerModule

-(NSString*) moduleId {
    return @"WuKongGroupManager";
}

// 模块初始化
- (void)moduleInit:(WKModuleContext*)context{
    NSLog(@"【WuKongGroupManager】模块初始化！");
    __weak typeof(self) weakSelf = self;
    // 群管理
    [self setMethod:WKPOINT_GROUPMANAGER_SHOW handler:^id _Nullable(id  _Nonnull param) {
        WKGroupManagerVC *vc =  [WKGroupManagerVC new];
        vc.channel = [WKChannel fromMap:param];
        [[WKNavigationManager shared] pushViewController:vc animated:YES];
        return nil;
    }];
    
    [self setMethod:@"channelsetting.groupmanager" handler:^id _Nullable(id  _Nonnull param) {
        WKChannel *channel = param[@"channel"];
        if(channel.channelType != WK_GROUP) {
            return nil;
        }
        BOOL isCreatorOrManager = [param[@"is_creator_or_manager"] boolValue];
        return @{
            @"height":@(0.0f),
            @"items": @[
                @{
                    @"class":WKLabelItemModel.class,
                    @"label":LLangW(@"群管理",weakSelf),
                    @"hidden": @(!isCreatorOrManager),
                    @"showBottomLine":@(NO),
                    @"bottomLeftSpace":isCreatorOrManager?@(0.0f):[NSNull null],
                    @"onClick":^{
                        [[WKApp shared] invoke:WKPOINT_GROUPMANAGER_SHOW param:[channel toMap]];

                    },
                }
            ]
        };
    } category:WKPOINT_CATEGORY_CHANNELSETTING sort:89600];
    
    // 群头像
    [self setMethod:@"channelsetting.groupavatar" handler:^id _Nullable(id  _Nonnull param) {
        WKChannel *channel = param[@"channel"];
        if(channel.channelType != WK_GROUP) {
            return nil;
        }
        return @{
            @"height":@(0.0f),
            @"items": @[
                @{
                    @"class":WKLabelItemModel.class,
                    @"label":LLangW(@"群聊头像",weakSelf),
                    @"showBottomLine":@(NO),
                    @"showTopLine":@(NO),
                    @"onClick":^{
                        WKGroupAvatarVC *vc = [WKGroupAvatarVC new];
                        vc.groupNo = channel.channelId;
                        [[WKNavigationManager shared] pushViewController:vc animated:YES];
                    }
                },
            ],
        };
    } category:WKPOINT_CATEGORY_CHANNELSETTING sort:89900];
    
    // 群备注
    [self setMethod:@"channelsetting.groupremark" handler:^id _Nullable(id  _Nonnull param) {
        WKChannel *channel = param[@"channel"];
        if(channel.channelType != WK_GROUP) {
            return nil;
        }
        WKChannelInfo *channelInfo = param[@"channel_info"];
        return @{
            @"height":@(0.0f),
            @"items": @[
                @{
                    @"class":WKLabelItemModel.class,
                    @"label":LLangW(@"群备注",weakSelf),
                    @"value":channelInfo && channelInfo.remark?channelInfo.remark:@"",
                    @"showBottomLine":@(NO),
                    @"showTopLine":@(NO),
                    @"onClick":^{
                        [weakSelf toSettingGroupRemark:channelInfo channel:channel];
                    }
                },
            ],
        };
    } category:WKPOINT_CATEGORY_CHANNELSETTING sort:89800];
}


-(void) toSettingGroupRemark:(WKChannelInfo*)channelInfo channel:(WKChannel*)channel{
    NSString *groupName = channelInfo?channelInfo.displayName:@"";
    WKInputVC *inputVC = [WKInputVC new];
    inputVC.title = LLang(@"修改群备注");
    inputVC.maxLength = 10;
    inputVC.placeholder = LLang(@"修改群备注");
    inputVC.defaultValue = groupName;
    [inputVC setOnFinish:^(NSString * _Nonnull value) {
        
        [[WKChannelSettingManager shared] channel:channel remark:value].then(^{
            [[WKNavigationManager shared] popViewControllerAnimated:YES];
        }).catch(^(NSError *error){
            [[WKNavigationManager shared].topViewController.view showMsg:error.domain];
        });
       
    }];
    [[WKNavigationManager shared] pushViewController:inputVC animated:YES];
}


@end
