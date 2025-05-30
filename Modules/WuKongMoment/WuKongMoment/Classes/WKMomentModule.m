//
//  WKMomentModule.m
//  WuKongMoment
//
//  Created by tt on 2020/11/5.
//

#import "WKMomentModule.h"
#import "WKMomentVC.h"
#import "WKMomentMsgManager.h"
#import "WKMomentCommon.h"
#import "WKUserMomentCell.h"
@WKModule(WKMomentModule)

@implementation WKMomentModule

+ (NSString *)gmoduleId {
    return @"WuKongMoment";
}

- (NSString *)moduleId {
    return [WKMomentModule gmoduleId];
}

- (NSInteger)moduleSort {
    return 2;
}

- (void)moduleInit:(WKModuleContext *)context {
    NSLog(@"【WuKongMoment】模块初始化！");
    
    [[WKMomentMsgManager shared] setup];
    
    __weak typeof(self) weakSelf = self;
    
    // 联系人tabBarItem的红点
    [self setMethod:@"moment.reddot" handler:^id _Nullable(id  _Nonnull param) {
        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
        
        NSString *msgCountKey = [NSString stringWithFormat:@"%@%@:msgcount",momentMsgDataKeyPrefx,[WKApp.shared loginInfo].uid];
        
        NSInteger unreadCount =  [userDefault integerForKey:msgCountKey];
        if(unreadCount<=0) {
            NSString *uidkey = [NSString stringWithFormat:@"%@%@:uid",momentMsgDataKeyPrefx,[WKApp.shared loginInfo].uid];
            NSString *uid = [userDefault stringForKey:uidkey];
            if(uid && ![uid isEqualToString:@""]) {
                return @(-1);
            }
        }
        return @(unreadCount);
    } category:WK_CONTACTS_CATEGORY_TAB_REDDOT];
    
    // 朋友圈
    [self setMethod:@"contacts.header.moment" handler:^id _Nullable(id  _Nonnull param) {
        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
        NSString *msgCountKey = [NSString stringWithFormat:@"%@%@:msgcount",momentMsgDataKeyPrefx,[WKApp.shared loginInfo].uid];
        NSString *userUIDKey = [NSString stringWithFormat:@"%@%@:uid",momentMsgDataKeyPrefx,[WKApp.shared loginInfo].uid];
       NSInteger unreadCount =  [userDefault integerForKey:msgCountKey];
        
        WKContactsHeaderItem *item = [WKContactsHeaderItem initWithSid:@"moment" title:LLangW(@"朋友圈",weakSelf) icon:@"IconMoment" moduleID:[weakSelf moduleId] onClick:^{
            [userDefault setObject:@"" forKey:userUIDKey];
            [userDefault synchronize];
            // 更新header
            [[NSNotificationCenter defaultCenter] postNotificationName:WK_NOTIFY_CONTACTS_HEADER_UPDATE object:nil];
            // 更新联系人tabbar红点
            [[NSNotificationCenter defaultCenter] postNotificationName:WK_NOTIFY_CONTACTS_TAB_REDDOT_UPDATE object:nil];
            [[WKNavigationManager shared] pushViewController:[WKMomentVC new] animated:YES];
        }];
        if(unreadCount>0) {
            item.badgeValue = [NSString stringWithFormat:@"%ld",(long)unreadCount];
        }
       
        NSString *uid = [userDefault stringForKey:userUIDKey];
        if(uid && ![uid isEqualToString:@""]) {
            item.avatarURL = [WKAvatarUtil getAvatar:uid];
        }
        return item;
    } category:WKPOINT_CATEGORY_CONTACTSITEM sort:11000];
    
    // 注入朋友圈到用户个人资料列表
    [self setMethod:@"user.info.moments" handler:^id _Nullable(id  _Nonnull param) {
        void(^reload)(void)  =  param[@"reload"];
        NSString *uid = param[@"uid"];
        NSMutableDictionary *contextDic = param[@"context"];
        if(contextDic && !contextDic[@"moments"]) {
             [[WKAPIClient sharedClient] GET:@"moments" parameters:@{
                @"page_index": @(1),
                @"page_size": @(10),
                @"uid": uid?:@"",
            } model:WKMomentResp.class].then(^(NSArray *result){
                 contextDic[@"moments"] = result;
                 reload();
             }).catch(^(NSError *err){
                 NSLog(@"请求朋友圈失败！->%@",err);
             });
            return nil;
        }
        NSArray<WKMomentResp*> *moments = contextDic[@"moments"];
        NSMutableArray *imgs = [NSMutableArray array];
        if(moments && moments.count>0) {
            for (WKMomentResp *resp in moments) {
                if(resp.imgs && resp.imgs.count>0) {
                    [imgs addObjectsFromArray:resp.imgs];
                }else if(resp.videoCoverPath && ![resp.videoCoverPath isEqualToString:@""]) {
                    [imgs addObject:resp.videoCoverPath];
                }
                
                
            }
        }
        return  @{
            @"height":@(10.0f),
            @"items":@[
                    @{
                        @"class":WKUserMomentModel.class,
                        @"label":LLangW(@"朋友圈",weakSelf),
                        @"imgs": imgs?:@[],
                        @"onClick":^{
                            WKMomentVC *vc = [WKMomentVC new];
                            vc.uid = uid;
                            vc.showMsg = true;
                            [[WKNavigationManager shared] pushViewController:vc animated:YES];
                        }
                    },
            ],
        };
    } category:WKPOINT_CATEGORY_USER_INFO_ITEM sort:3900];
    
}

- (void)moduleDidDatabaseLoad:(WKModuleContext *)context {
    // 初始化db
    [[WKDBMigration shared] migrateDatabase:[self resourceBundle]];
}

- (UIImage*) imageName:(NSString*)name {
    return [[WKApp shared] loadImage:name moduleID:[WKMomentModule gmoduleId]];
}

@end
