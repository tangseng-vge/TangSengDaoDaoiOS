//
//  WKAdvancedModule.m
//  WuKongAdvanced
//
//  Created by tt on 2022/6/27.
//

#import "WKAdvancedModule.h"
#import <WuKongAdvanced/WuKongAdvanced-Swift.h>
@import WuKongBase.Swift;
#import "WKReactionView.h"
#import "WKConversationNotifySettingVC.h"
#import "WKReceiptListVC.h"
#import "WKReactionsListVC.h"
#import "WKBurnAfterReadingSelectCell.h"
#import "WKFlameSettingView.h"
#import "WKChatBackgroundVC.h"
@WKModule(WKAdvancedModule)

@implementation WKAdvancedModule



-(NSString*) moduleId {
    return @"WuKongAdvanced";
}

// 模块初始化
- (void)moduleInit:(WKModuleContext*)context{
    NSLog(@"【WuKongAdvanced】模块初始化！");
    
    WKApp.shared.config.takeScreenshotOn = YES; // 旗舰模块才开启截屏通知
    
    
    
    // 长按消息菜单
    [self setLongMessageMenus];
    
    // 频道设置
    [self setChannelSettings];
    // 阅后即焚
//    [self setFlame];
    
    // 回应服务端数据提供者
    [self setReactionProvider];
    // 已读未读数据提供者
    [self setMessageReadedProvider];
    // 消息编辑提供者
    [self setMessageEditProvider];
    
    // 通用设置
    [self setCommonSettings];
}

-(void) setLongMessageMenus {
    NSArray<ReactionContextItem*> *reactionItems = [WKReactionProvider.shared reactions];
    __weak typeof(self) weakSelf = self;
    
    // 长按菜单-已读未读
    [self setMethod:WKPOINT_LONGMENUS_READED handler:^id _Nullable(id  _Nonnull param) {
        WKMessageModel *message = param[@"message"];
        
        if(![message isSend]) { // 只有自己发的消息才有已读未读
            return nil;
        }
        if(message.status != WK_MESSAGE_SUCCESS) {
            return nil;
        }
        
        NSInteger readedCount = message.message.remoteExtra.readedCount;
        NSInteger unreadCount = message.message.remoteExtra.unreadCount;
        
        if(readedCount<=0) {
            return nil;
        }
        
        UIImage *icon = [GenerateImageUtils generateTintedImgWithImage:[weakSelf imageName:@"Conversation/ContextMenu/Readed"] color:[WKApp shared].config.contextMenu.primaryColor backgroundColor:nil];
       
        return [WKMessageLongMenusItem initWithTitle:[NSString stringWithFormat:LLangW(@"%ld 人已读", weakSelf),readedCount] icon:icon onTap:^(id<WKConversationContext> context){
            WKReceiptListVC *vc = [WKReceiptListVC new];
            vc.channel = message.channel;
            vc.messageID = message.messageId;
            vc.unreadCount = unreadCount;
            vc.readedCount = readedCount;
            
            [[WKNavigationManager shared] pushViewController:vc animated:YES];
        }];
    } category:WKPOINT_CATEGORY_MESSAGE_LONGMENUS sort:9999];
    
    // 长按菜单-消息回应
    [self setMethod:WKPOINT_LONGMENUS_REACTIONS handler:^id _Nullable(id  _Nonnull param) {
        WKMessageModel *message = param[@"message"];
        
        if(message.status != WK_MESSAGE_SUCCESS) {
            return nil;
        }
        
        NSInteger reactionCount = message.reactions?message.reactions.count:0;
       
        
        if(reactionCount<=0) {
            return nil;
        }
        
        UIImage *icon = [GenerateImageUtils generateTintedImgWithImage:[weakSelf imageName:@"Conversation/ContextMenu/Readed"] color:[WKApp shared].config.contextMenu.primaryColor backgroundColor:nil];
       
        return [WKMessageLongMenusItem initWithTitle:[NSString stringWithFormat:LLangW(@"%ld 人回应", weakSelf),reactionCount] icon:icon onTap:^(id<WKConversationContext> context){
            WKReactionsListVC *vc = [WKReactionsListVC new];
            vc.channel = message.channel;
            vc.reactions = message.reactions;
            [[WKNavigationManager shared] pushViewController:vc animated:YES];
        }];
    } category:WKPOINT_CATEGORY_MESSAGE_LONGMENUS sort:9999];
    
    
    // 长按菜单-消息编辑
    [self setMethod:WKPOINT_LONGMENUS_EDITOR handler:^id _Nullable(id  _Nonnull param) {
        WKMessageModel *message = param[@"message"];
        
        if(![message isSend]) { // 只有自己发的消息才能编辑
            return nil;
        }
        if(message.status != WK_MESSAGE_SUCCESS) {
            return nil;
        }
        if(message.contentType != WK_TEXT) {
            return nil;
        }
        UIImage *icon = [GenerateImageUtils generateTintedImgWithImage:[weakSelf imageName:@"Conversation/ContextMenu/Edit"] color:[WKApp shared].config.contextMenu.primaryColor backgroundColor:nil];
       
        return [WKMessageLongMenusItem initWithTitle:LLangW(@"编辑", weakSelf) icon:icon onTap:^(id<WKConversationContext> context){
            [context editTo:message.message];
        }];
    } category:WKPOINT_CATEGORY_MESSAGE_LONGMENUS sort:2800];
    
   
    
    // 长按菜单 - 长按显示的reaction
    [self setMethod:WKPOINT_LONGMENUS_REACTIONS handler:^id _Nullable(id  _Nonnull param) {
        WKMessageModel *message = param[@"message"];
        if(message.messageId == 0) {
            return nil;
        }
        return reactionItems;
    }];
    
    // 消息点赞的view
    [self setMethod:WKPOINT_MESSAGEEXTEND_REACTIONVIEW handler:^id _Nullable(id  _Nonnull param) {
       
        return [[WKReactionView alloc] init];
    }];
    
}

-(void) setFlame {
    __weak typeof(self) weakSelf = self;
    // 阅后即焚
    [self setMethod:@"channelsetting.burnAfterReading" handler:^id _Nullable(id  _Nonnull param) {
        WKChannel *channel = param[@"channel"];
        WKChannelInfo *channelInfo = param[@"channel_info"];
        
        BOOL flame = channelInfo && channelInfo.flame;
        return  @{
            @"height":@(0.0f),
            @"remark": LLangW(@"对方阅读消息后，根据设置的时间自动销毁",weakSelf),
            @"items":@[
                    @{
                        @"class":WKSwitchItemModel.class,
                        @"label":LLangW(@"阅后即焚",weakSelf),
                        @"on":@(flame),
                        @"showBottomLine":@(NO),
                        @"showTopLine":@(NO),
                        @"onSwitch":^(BOOL on){
                            [[WKChannelSettingManager shared] channel:channel flame:on];
                        }
                    },
                    @{
                        @"class":WKBurnAfterReadingSelectCellModel.class,
                        @"hidden":@(!flame),
                        @"flameSecond": @(channelInfo.flameSecond),
                        @"valueChange":^(NSInteger value){
                            channelInfo.flameSecond = value;
                            [[WKChannelSettingManager shared] channel:channel flameSecond:value];
                        }
                    },
               ]
        };
    } category:WKPOINT_CATEGORY_CHANNELSETTING sort:89180];
    
    // 阅后即焚-输入框右边视图
    [self setMethod:@"conversationinput.textview.rightview.flame" handler:^id _Nullable(id  _Nonnull param) {
        
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 28.0f, 28.0f)];
        UIImage *secretMediaIcon = [weakSelf imageName:@"Conversation/Setting/SecretMediaIcon"];
        CGFloat factor = 0.7f;
        secretMediaIcon = [GenerateImageUtils generateImg:CGSizeMake(secretMediaIcon.size.width*factor, secretMediaIcon.size.height*factor) contextGenerator:^(CGSize size, CGContextRef contextRef) {
            CGContextClearRect(contextRef, CGRectMake(0.0f, 0.0f, size.width, size.height));
            CGContextDrawImage(contextRef, CGRectMake(0.0f, 0.0f, size.width, size.height), secretMediaIcon.CGImage);
        } opaque:NO];
        
        id<WKConversationContext> context = param[@"context"];
        WKChannelInfo *channelInfo = [context getChannelInfo];
        if(!channelInfo.flame) {
            return nil;
        }
        
        secretMediaIcon = [WKGenerateImageUtils generateTintedImgWithImage:secretMediaIcon color:[UIColor redColor] backgroundColor:nil];
        [btn setImage:secretMediaIcon forState:UIControlStateNormal];
        
        WKFlameSettingView *flameSettingView = [[WKFlameSettingView alloc] init];
        flameSettingView.channel = context.channel;
        
        
        flameSettingView.onSwitch = ^(BOOL sw) {
            [[WKChannelSettingManager shared] channel:context.channel flame:sw];
            if(!sw) {
                [context setInputTopView:nil];
            }
        };
        [btn lim_addEventHandler:^{
            if(context.inputTopView) {
                if(![context.inputTopView isKindOfClass:[WKFlameSettingView class]]) {
                    [context setInputTopView:nil];
                    [context setInputTopView:flameSettingView];
                }else{
                    UIView *backTopView;
                    if(context.hasReply) {
                        backTopView = [context replyView:[context replyingMessage]];
                    }else if(context.hasEdit) {
                        backTopView = [context editView:[context editingMessage]];
                    }
                    [context setInputTopView:backTopView];
                }
            }else{
                [context setInputTopView:flameSettingView];
            }
        } forControlEvents:UIControlEventTouchUpInside];
        return btn;
    } category:WKPOINT_CATEGORY_TEXTVIEW_RIGHTVIEW];
}

-(void) setChannelSettings {
    __weak typeof(self) weakSelf = self;
    
    // 消息回执
    [self setMethod:@"channelsetting.receipt" handler:^id _Nullable(id  _Nonnull param) {
        WKChannel *channel = param[@"channel"];
        WKChannelInfo *channelInfo = param[@"channel_info"];
        BOOL receiptOn = channelInfo && channelInfo.receipt;
        return  @{
            @"height":@(0.0f),
            @"remark": LLangW(@"开启后，发送的聊天信息会提示已读未读情况",weakSelf),
            @"items":@[
                    @{
                        @"class":WKSwitchItemModel.class,
                        @"label":LLangW(@"消息回执",weakSelf),
                        @"on":@(receiptOn),
                        @"showBottomLine":@(NO),
                        @"showTopLine":@(NO),
                        @"onSwitch":^(BOOL on){
                            [[WKChannelSettingManager shared] channel:channel receipt:on];
                        }},
               ]

        };
    } category:WKPOINT_CATEGORY_CHANNELSETTING sort:89190];
    
    // 设置当前聊天背景
    [self setMethod:@"channelsetting.chatbackground" handler:^id _Nullable(id  _Nonnull param) {
        WKChannel *channel = param[@"channel"];
        return  @{
            @"height":WKSectionHeight,
            @"items":@[
                @{
                    @"class":WKLabelItemModel.class,
                    @"label":LLangW(@"设置当前聊天背景",weakSelf),
                    @"value":@"",
                    @"showBottomLine":@(NO),
                    @"bottomLeftSpace":@(0.0f),
                    @"showTopLine":@(NO),
                    @"onClick":^{
                        WKChatBackgroundVC *vc = [WKChatBackgroundVC new];
                        vc.channel = channel;
                        [[WKNavigationManager shared] pushViewController:vc animated:YES];
                    }
                },
               ]
        };
    } category:WKPOINT_CATEGORY_CHANNELSETTING sort:89100];
    
    // 消息通知设置
    [self setMethod:@"channelsetting.notify" handler:^id _Nullable(id  _Nonnull param) {
        WKChannel *channel = param[@"channel"];
        return  @{
            @"height":WKSectionHeight,
            @"items":@[
                @{
                    @"class":WKLabelItemModel.class,
                    @"label":LLangW(@"消息通知设置",weakSelf),
                    @"value":@"",
                    @"showBottomLine":@(NO),
                    @"bottomLeftSpace":@(0.0f),
                    @"showTopLine":@(NO),
                    @"onClick":^{
                        WKConversationNotifySettingVC *vc = [WKConversationNotifySettingVC new];
                        vc.channel = channel;
                        [[WKNavigationManager shared] pushViewController:vc animated:YES];
                    }
                },
               ]
        };
    } category:WKPOINT_CATEGORY_CHANNELSETTING sort:89000];
}

-(void) setCommonSettings {
    __weak typeof(self) weakSelf = self;
    // 聊天背景
    [self setMethod:@"commonsetting.chatbg" handler:^id _Nullable(id  _Nonnull param) {
       
        return  @{
            @"height":@(0),
            @"items":@[
                    @{
                        @"class":WKLabelItemModel.class,
                        @"label":LLangW(@"聊天背景",weakSelf),
                        @"onClick":^{
                            WKChatBackgroundVC *vc = [WKChatBackgroundVC new];
                            [WKNavigationManager.shared pushViewController:vc animated:YES];
                        }
                    },
            ],
        };
    } category:WKPOINT_CATEGORY_COMMONSETTING sort:69000];
}


-(void) setReactionProvider {
    
    // 同步点赞
    [[WKSDK shared].reactionManager setSyncReactionsProvider:^(WKChannel * _Nonnull channel, uint64_t maxVersion, WKSyncReactionsCallback  _Nonnull callback) {
        [[WKAPIClient sharedClient] POST:@"reaction/sync" parameters:@{
            @"channel_id":channel.channelId,
            @"channel_type":@(channel.channelType),
            @"seq": @(maxVersion),
        }].then(^(NSArray<NSDictionary*> *results){
            if(!results || results.count==0) {
                callback(nil,nil);
                return;
            }
            NSMutableArray<WKReaction*> *reactions = [NSMutableArray array];
            for (NSDictionary *result in results) {
                [reactions addObject:[WKMessageUtil toReaction:result]];
            }
            callback(reactions,nil);
            
        }).catch(^(NSError *error){
            callback(nil,error);
        });
    }];
    
    // 添加或取消点赞
    [[WKSDK shared].reactionManager setAddOrCancelReactionProvider:^(WKChannel * _Nonnull channel, uint64_t messageID,  NSString *reactionName,WKAddOrCancelReactionsCallback  _Nonnull callback) {
         [[WKAPIClient sharedClient] POST:@"reactions" parameters:@{
            @"message_id":[NSString stringWithFormat:@"%llu",messageID],
            @"channel_id": channel.channelId,
            @"channel_type": @(channel.channelType),
            @"emoji": reactionName,
         }].then(^{
             callback(nil);
         }).catch(^(NSError *error){
             callback(error);
         });
    }];
}


-(void) setMessageReadedProvider {
    [[[WKSDK shared] receiptManager] setMessageReadedProvider:^(WKChannel *channel,NSArray<WKMessage *> * _Nonnull messages, WKMessageReadedCallback  _Nonnull callback) {
        NSMutableArray<NSString*> *messageIDS = [NSMutableArray array];
        if(messages.count>0) {
            for (WKMessage *message in messages) {
                [messageIDS addObject:[NSString stringWithFormat:@"%llu",message.messageId]];
            }
        }
        [[WKAPIClient sharedClient] POST:@"message/readed" parameters:@{
            @"channel_id": channel.channelId,
            @"channel_type":@(channel.channelType),
            @"message_ids": messageIDS,
        }].then(^{
            if(callback) {
                callback(nil);
            }
        }).catch(^(NSError *err){
            if(callback) {
                callback(err);
            }
        });
    }];
}


-(void) setMessageEditProvider{
    [[[WKSDK shared] chatManager] setMessageEditProvider:^(WKMessageExtra * _Nonnull extra, WKMessageEditCallback  _Nonnull callback) {
        
        [[WKAPIClient sharedClient] POST:@"message/edit" parameters:@{
            @"message_id":  [NSString stringWithFormat:@"%llu",extra.messageID],
            @"channel_id": extra.channelID,
            @"channel_type":@(extra.channelType),
            @"message_seq": @(extra.messageSeq),
            @"content_edit": [[NSString alloc] initWithData:extra.contentEditData encoding:NSUTF8StringEncoding],
            
        }].then(^{
            if(callback) {
                callback(nil);
            }
            
        }).catch(^(NSError *error){
            if(callback) {
                callback(error);
            }
        });
    }];
}

- (BOOL)moduleDidFinishLaunching:(WKModuleContext *)context {
    NSArray<WKMessage*> *messages = [WKFlameManager.shared getMessagesOfNeedFlame];
    if(messages && messages.count>0) {
        NSMutableArray<WKMessageModel*> *messageModels = [NSMutableArray array];
        for (WKMessage *message in messages) {
            [messageModels addObject:[[WKMessageModel alloc] initWithMessage:message]];
        }
        [WKMessageManager.shared deleteMessages:messageModels];
    }
    
    return true;
}

-(UIImage*) imageName:(NSString*)name {
    return [[WKApp shared] loadImage:name moduleID:@"WuKongAdvanced"];
}

@end
