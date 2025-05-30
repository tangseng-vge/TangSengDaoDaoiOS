//
//  WKGroupBlacklistVM.m
//  WuKongBase
//
//  Created by tt on 2020/10/19.
//

#import "WKGroupBlacklistVM.h"
#import "WKManagerCell.h"


@interface WKGroupBlacklistVM ()
/**
 我在群里的信息
 */
@property(nullable,nonatomic,strong) WKChannelMember *memberOfMe;

@end
@implementation WKGroupBlacklistVM

- (NSArray<NSDictionary *> *)tableSectionMaps {
   NSArray<WKChannelMember*> *members = [[WKChannelMemberDB shared] getBlacklistMembersWithChannel:self.channel];
    __weak typeof(self) weakSelf = self;
    NSMutableArray *items = [NSMutableArray array];
    if(members && members.count>0) {
        for (WKChannelMember *member in members) {
            
            BOOL showSub = false;
            if([self isManagerOrCreatorForMe]) {
                showSub =  true;
            }
            [items addObject:@{
                @"class": WKManagerModel.class,
                @"title":member.memberName?:@"",
                @"icon": member.memberAvatar && ![member.memberAvatar isEqualToString:@""] ?[WKAvatarUtil getFullAvatarWIthPath:member.memberAvatar]: [WKAvatarUtil getAvatar:member.memberUid],
                @"onSub": ^{
                    if(weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(groupBlacklistVMRemoveBlacklist:member:)]) {
                        [weakSelf.delegate groupBlacklistVMRemoveBlacklist:weakSelf member:member];
                    }
                },
                @"showSub": @(showSub),
            }];
        }
    }
    if([self isManagerOrCreatorForMe]) {
        [items addObject:@{
            @"class":WKManagerAddModel.class,
            @"title":LLang(@"添加黑名单成员"),
            @"onClick":^{
                [weakSelf toSelectMembers];
            }
        }];
    }
   
    return @[
        @{
            @"height":@(10.0f),
            @"items":items,
        }
    ];
}

// 去选择拉入黑名单的成员
-(void) toSelectMembers {
   NSArray<WKChannelMember*> *members = [[WKChannelMemberDB shared] getMembersWithChannel:self.channel role:WKMemberRoleCommon];
    NSMutableArray<WKContactsSelect*> *contactsSelects = [NSMutableArray array];
    for (WKChannelMember *member in members) {
        [contactsSelects addObject:[WKModelConvert toContactsSelect:member]];
    }
    __weak typeof(self) weakSelf = self;
    [[WKApp shared] invoke:WKPOINT_CONTACTS_SELECT param:@{@"on_finished":^(NSArray<NSString*>*uids){
        [[WKNavigationManager shared] popViewControllerAnimated:YES];
        [weakSelf addOrRemoveBlacklist:@"add" uids:uids];
    },@"data":contactsSelects,@"title":LLang(@"选择成员")}];
}

// 添加或移除黑名单
-(void) addOrRemoveBlacklist:(NSString*)action uids:(NSArray<NSString*>*)uids{
    __weak typeof(self) weakSelf = self;
    [[WKNavigationManager shared].topViewController.view showHUD];
    [[WKAPIClient sharedClient] POST:[NSString stringWithFormat:@"groups/%@/blacklist/%@",self.channel.channelId,action] parameters:@{
        @"uids": uids?:@[],
    }].then(^{
        [[WKNavigationManager shared].topViewController.view hideHud];
        WKMemberStatus memberStatus;
        if(action && [action isEqualToString:@"remove"]) {
            memberStatus = WKMemberStatusNormal;
        }else {
            memberStatus = WKMemberStatusBlacklist;
        }
        [WKChannelMemberDB.shared updateMemberStatus:memberStatus channel:weakSelf.channel uids:uids];
        [weakSelf reloadData]; // 先刷新 让黑名单消失
        [[WKGroupManager shared] syncMemebers:weakSelf.channel.channelId complete:^(NSInteger syncMemberCount, NSError * _Nullable error) {
            if(error) {
                [[WKNavigationManager shared].topViewController.view switchHUDError:error.domain];
                return;
            }
            [weakSelf reloadData];
        }];
    }).catch(^(NSError *error){
        [[WKNavigationManager shared].topViewController.view switchHUDError:error.domain];
    });
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

@end
