//
//  WKGroupManagerVM.m
//  WuKongBase
//
//  Created by tt on 2020/3/1.
//

#import "WKGroupManagerVM.h"
#import "WKTableSectionUtil.h"
#import "WKLabelItemCell.h"
#import "WKSwitchItemCell.h"
#import "WKManagerCell.h"
#import "WKAvatarUtil.h"
#import "WKModelConvert.h"
#import "WKGroupBlacklistVC.h"
@interface WKGroupManagerVM ()

@property(nonatomic,strong) NSArray<WKChannelMember*> *managerAndCreators; // 群里的管理员和创建者


// 频道信息
@property(nonatomic,strong) WKChannelInfo *channelInfo;

/**
 我在群里的信息
 */
@property(nullable,nonatomic,strong) WKChannelMember *memberOfMe;

@end

@implementation WKGroupManagerVM


- (NSArray<WKFormSection *> *)tableSections {
    NSMutableArray *sections = [NSMutableArray array];
    [sections addObjectsFromArray:self.getSectionMap];
    if(self.memberOfMe.role != WKMemberRoleCreator) {
        return [WKTableSectionUtil toSections:sections];
    }
    NSMutableArray *members = [NSMutableArray array];
    
    __weak typeof(self) weakSelf = self;
    if(self.managerAndCreators) {
        int index = 0;
        for (WKChannelMember *member in self.managerAndCreators) {
            [members addObject:@{
                        @"class":WKManagerModel.class,
                        @"showBottomLine":@(NO),
                        @"showTopLine":@(NO),
                        @"showSub": member.role == WKMemberRoleCreator?@(NO):@(YES),
                        @"title":member.memberName?:@"",
                        @"onSub": ^{
                             [weakSelf deleteManager:member];
                        },
                        @"icon": member.memberAvatar && ![member.memberAvatar isEqualToString:@""] ?[WKAvatarUtil getFullAvatarWIthPath:member.memberAvatar]: [WKAvatarUtil getAvatar:member.memberUid],
                   }];
            index++;
        }
    }
    [members addObject:@{
                           @"class":WKManagerAddModel.class,
                           @"title":LLang(@"添加管理员"),
                           @"showBottomLine":@(NO),
                            @"bottomLeftSpace":@(0.0f),
                           @"showArrow":@(NO),
                           @"onClick":^{
                                [weakSelf toSelectManager];
                           }
                      }];
    [sections addObject:@{
         @"height":@(10.0f),
         @"title":LLang(@"群主、管理员"),
         @"items": members,
    }];
    
    [sections addObject: @{
        @"height":@(20.0f),
        @"items":@[
            @{
                @"class":WKButtonItemModel.class,
                @"title":LLang(@"解散该群聊"),
                @"hidden": @(![self isCreatorForMe]),
                @"showBottomLine":@(NO),
                @"bottomLeftSpace":@(0.0f),
                @"showTopLine":@(NO),
                @"onClick":^{
                    __weak typeof(self) weakSelf = self;
                    WKActionSheetView2 *actionSheetView = [WKActionSheetView2 initWithTip:LLang(@"解散群聊后，群成员和群主都将被移出群聊。")];
                      [actionSheetView addItem:[WKActionSheetButtonItem2 initWithAlertTitle:LLang(@"确定") onClick:^{
                          [[WKGroupManager shared] didGroupDisband:weakSelf.channel.channelId complete:^(NSError * _Nonnull error) {
                              [[WKNavigationManager shared] popToRootViewControllerAnimated:YES];
                          }];
                      }]];
                      [actionSheetView show];
                }
            },
           ]
    }];
    
    
    return [WKTableSectionUtil toSections:sections];
}


-(void) deleteManager:(WKChannelMember*)member {
    if(_delegate && [_delegate respondsToSelector:@selector(didDeleteManager:manager:)]) {
        [_delegate didDeleteManager:self manager:member];
    }
}

// 去选择管理员
-(void) toSelectManager {
    NSMutableArray<WKContactsSelect*> *contactsSelects = [NSMutableArray array];
    for (WKChannelMember *member in self.members) {
        BOOL isManager = false;
        for (WKChannelMember *manager in self.managerAndCreators) {
            if([member.memberUid isEqualToString:manager.memberUid]) {
                isManager = true;
                continue;
            }
        }
        if(!isManager) {
            [contactsSelects addObject:[WKModelConvert toContactsSelect:member]];
        }
    }
    [[WKApp shared] invoke:WKPOINT_CONTACTS_SELECT param:@{@"on_finished":^(NSArray<NSString*>*uids){
        [[WKGroupManager shared] groupNo:self.channel.channelId membersToManager:uids complete:^(NSError * _Nonnull error) {
            if(error) {
                [[WKNavigationManager shared].topViewController.view showMsg:error.domain];
                return;
            }
            [[WKNavigationManager shared] popViewControllerAnimated:YES];
        }];
    },@"data":contactsSelects,@"title":LLang(@"选择管理员")}];
}

// 获取管理员数据
- (NSArray<WKChannelMember *> *)managerAndCreators {
    if(!_managerAndCreators) {
        _managerAndCreators = [[WKChannelMemberDB shared] getManagerAndCreator:self.channel];
    }
    return _managerAndCreators;
}

// 重新加载管理员数据
-(void) reloadManagerAndCreators {
    _managerAndCreators = [[WKChannelMemberDB shared] getManagerAndCreator:self.channel];
}

// 当前频道成员
-(NSArray<WKChannelMember*>*) members {
    if(!_members) {
        _members = [[WKChannelMemberDB shared] getMembersWithChannel:self.channel];
    }
    return _members;
}

- (WKChannelMember *)memberOfMe {
    if(!_memberOfMe) {
        _memberOfMe = [[WKSDK shared].channelManager getMember:self.channel uid:[WKApp shared].loginInfo.uid];
    }
    return _memberOfMe;
}
-(BOOL) isManagerForMe {
    return self.memberOfMe && self.memberOfMe.role == WKMemberRoleManager;
}

-(BOOL) isCreatorForMe {
    return self.memberOfMe && self.memberOfMe.role == WKMemberRoleCreator;
}

-(BOOL) isManagerOrCreatorForMe {
    return [self isManagerForMe] || [self isCreatorForMe];
}

// 当前频道信息
- (WKChannelInfo *)channelInfo {
    if(!_channelInfo) {
        _channelInfo = [[WKSDK shared].channelManager getChannelInfo:self.channel];
    }
    return _channelInfo;
}

-(void) reloadChannelInfo {
     _channelInfo = [[WKSDK shared].channelManager getChannelInfo:self.channel];
}

-(AnyPromise*) requestTransferGrouper:(NSString*)toUID {
   return [[WKAPIClient sharedClient] POST:[NSString stringWithFormat:@"groups/%@/transfer/%@",self.channel.channelId,toUID] parameters:nil];
}


-(NSArray<NSDictionary*>*) getSectionMap {
    __weak typeof(self) weakSelf = self;
    return @[
        @{
             @"height":@(0.1f),
             @"remark":LLang( @"启用后，群成员需要群主或管理员确认才能邀请朋友进群。扫描二维码进群将同时停用。"),
             @"items":@[
                     @{
                          @"class":WKSwitchItemModel.class,
                          @"label":LLang(@"群聊邀请确认"),
                          @"on":@(self.channelInfo.invite),
                          @"bottomLeftSpace":@(0.0f),
                          @"showBottomLine":@(NO),
                          @"showTopLine":@(NO),
                          @"onSwitch":^(BOOL on){
                              [[WKGroupManager shared] groupSetting:weakSelf.channel.channelId settingKey:WKGroupSettingKeyInvite on:on];
                          }
                         
                     }
             ],
        },
        @{
             @"height":@(10.0f),
             @"items":@[
                     @{
                          @"class":WKLabelItemModel.class,
                          @"label":LLang(@"群主管理权转让"),
                          @"hidden": @(![self isCreatorForMe]),
                          @"showBottomLine":@(NO),
                          @"bottomLeftSpace":@(0.0f),
                          @"showTopLine":@(NO),
                          @"onClick":^{
                              [weakSelf transferGrouper];
                          }
                         
                     },
             ],
        },
        @{
                    @"height":@(10.0f),
                    @"title":LLang(@"成员设置"),
                    @"remark": LLang(@"全员禁言启用后，只允许群主和管理员发言。"),
                    @"items":@[
                            @{
                                 @"class":WKSwitchItemModel.class,
                                 @"label":LLang(@"全员禁言"),
                                  @"showTopLine":@(NO),
                                 @"showBottomLine":@(NO),
                                  @"on":@(self.channelInfo.forbidden),
                                 @"bottomLeftSpace":@(0.0f),
                                 @"onSwitch":^(BOOL on){
                                     [[WKGroupManager shared] groupSetting:self.channel.channelId settingKey:WKGroupSettingKeyForbidden on:on];
                                 }
                                
                            },
                    ],
            },
            @{
                    @"height":@(10.0f),
                    @"remark": LLang(@"开启后，群成员无法通过该群添加好友。"),
                    @"items":@[
                            @{
                                 @"class":WKSwitchItemModel.class,
                                 @"label":LLang(@"禁止群成员互加好友"),
                                  @"showTopLine":@(NO),
                                 @"showBottomLine":@(NO),
                                 @"on":self.channelInfo.extra[WKChannelExtraKeyForbiddenAddFriend]?:@(false),
                                 @"bottomLeftSpace":@(0.0f),
                                 @"onSwitch":^(BOOL on){
                                     [[WKGroupManager shared] groupSetting:self.channel.channelId settingKey:WKGroupSettingKeyForbiddenAddFriend on:on];
                                 }
                                
                            },
                    ],
            },
            @{
                @"height":@(10.0f),
                @"remark": LLang(@"开启后，新加入聊天的成员能看见以前的聊天记录。"),
                @"items":@[
                        @{
                             @"class":WKSwitchItemModel.class,
                             @"label":LLang(@"允许新成员查看历史消息"),
                              @"showTopLine":@(NO),
                             @"showBottomLine":@(NO),
                             @"on":self.channelInfo.extra[WKChannelExtraKeyAllowViewHistoryMsg]?:@(false),
                             @"bottomLeftSpace":@(0.0f),
                             @"onSwitch":^(BOOL on){
                                 [[WKGroupManager shared] groupSetting:self.channel.channelId settingKey:WKGroupSettingKeyAllowViewHistoryMsg on:on];
                             }
                            
                        },
                ],
            },
            @{
                    @"height":@(20.0f),
                    @"items":@[
                            @{
                                 @"class":WKLabelItemModel.class,
                                 @"label":LLang(@"群黑名单"),
                                 @"onClick":^{
                                     WKGroupBlacklistVC *vc = [WKGroupBlacklistVC new];
                                     vc.channel = weakSelf.channel;
                                     [[WKNavigationManager shared] pushViewController:vc animated:YES];
                                 }
                                
                            },
                    ],
            },
    ];
}


/// 转让群主
-(void) transferGrouper {
   if(_delegate && [_delegate respondsToSelector:@selector(didTransferGrouper:)]) {
         [_delegate didTransferGrouper:self];
     }
}
@end
