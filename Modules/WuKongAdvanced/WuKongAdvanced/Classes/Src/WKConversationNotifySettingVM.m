//
//  WKConversationNotifySettingVM.m
//  WuKongBase
//
//  Created by tt on 2020/10/16.
//

#import "WKConversationNotifySettingVM.h"
#import "WKGroupManager.h"
@interface WKConversationNotifySettingVM ()

@property(nonatomic,strong) WKChannelInfo *channelInfo;

@end

@implementation WKConversationNotifySettingVM

- (NSArray<NSDictionary *> *)tableSectionMaps {
    
    WKChannelInfo *channelInfo = self.channelInfo;
    if(!channelInfo) {
        return nil;
    }
    BOOL screenshot = false;
    if( [channelInfo extraValueForKey:WKChannelExtraKeyScreenshot]) {
        screenshot = [[channelInfo extraValueForKey:WKChannelExtraKeyScreenshot] boolValue];
    };
    BOOL revokeRemind = false;
    if([channelInfo extraValueForKey:WKChannelExtraKeyRevokeRemind]) {
        revokeRemind = [[channelInfo extraValueForKey:WKChannelExtraKeyRevokeRemind] boolValue];
    }
    BOOL joinGroupRemind = true;
    if([channelInfo extraValueForKey:WKChannelExtraKeyJoinGroupRemind]) {
        joinGroupRemind =  [[channelInfo extraValueForKey:WKChannelExtraKeyJoinGroupRemind] boolValue];
    }
    
    __weak typeof(self) weakSelf = self;
    NSMutableArray *items = [NSMutableArray array];
    
    [items addObject:@{
        @"height":WKSectionHeight,
        @"remark": LLang(@"在对话中的截屏，各方均会收到通知"),
        @"items":@[
                @{
                    @"class":WKSwitchItemModel.class,
                    @"label":LLang(@"截屏通知"),
                    @"on":@(screenshot),
                    @"showBottomLine":@(NO),
                    @"showTopLine":@(NO),
                    @"onSwitch":^(BOOL on){
                        [[WKChannelSettingManager shared] channel:weakSelf.channel screenshot:on];
                    }}
                ]
        
        }];
    [items addObject:@{
        @"height":WKSectionHeight,
        @"remark": LLang(@"在对话中的消息撤回，各方均会收到通知"),
        @"items":@[
                @{
                    @"class":WKSwitchItemModel.class,
                    @"label":LLang(@"撤回通知"),
                    @"on":@(revokeRemind),
                    @"showBottomLine":@(NO),
                    @"showTopLine":@(NO),
                    @"onSwitch":^(BOOL on){
                        [[WKChannelSettingManager shared] channel:weakSelf.channel revokeRemind:on];
                    }
                }
        ]
    }];
    if(self.channel.channelType != WK_PERSON) {
//        [items addObject:@{
//            @"height":WKSectionHeight,
//            @"remark": LLang(@"关闭后，成员进群将不会响铃/震动"),
//            @"items":@[
//                    @{
//                        @"class":WKSwitchItemModel.class,
//                        @"label":LLang(@"成员进群提醒"),
//                        @"on":@(joinGroupRemind),
//                        @"showBottomLine":@(NO),
//                        @"showTopLine":@(NO),
//                        @"onSwitch":^(BOOL on){
//                            [[WKGroupManager shared] groupSetting:weakSelf.channel.channelId settingKey:WKGroupSettingKeyJoinGroupRemind on:on];
//                        }}
//                    ]
//            }];
    }
    return items;
}

- (WKChannelInfo *)channelInfo {
    if(!_channelInfo) {
        _channelInfo = [[WKSDK shared].channelManager getChannelInfo:self.channel];
    }
    return _channelInfo;
}

@end
