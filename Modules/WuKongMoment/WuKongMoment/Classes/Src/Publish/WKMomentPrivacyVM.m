//
//  WKMomentPrivacyVM.m
//  WuKongMoment
//
//  Created by tt on 2020/11/13.
//

#import "WKMomentPrivacyVM.h"
#import "WKMomentPrivacyFirstCell.h"
#import "WKMomentPrivacySecondCell.h"
#import "WKMomentPrivacyTagCell.h"
#import "WKMomentPrivacyVC.h"

@interface WKMomentPrivacyVM ()



@property(nonatomic,strong) NSMutableArray *unfoldArray;

@property(nonatomic,strong) NSArray<NSDictionary*> *labels;




@end

@implementation WKMomentPrivacyVM

- (instancetype)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(labelRefresh) name:WK_NOTIFY_LABELLIST_REFRESH object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:WK_NOTIFY_LABELLIST_REFRESH object:nil];
}

- (WKMomentPrivacySelect *)momentPrivacySelect {
    if(!_momentPrivacySelect) {
        _momentPrivacySelect = [[WKMomentPrivacySelect alloc] init];
        _momentPrivacySelect.privacyKey = @"public";
    }
    return _momentPrivacySelect;
}

- (NSMutableSet<NSString *> *)labelUIDs {
    NSMutableSet *uids = [NSMutableSet set];
    if(self.momentPrivacySelect.labelIDs && self.momentPrivacySelect.labelIDs.count>0) {
        for (NSString *selectedLabelID in self.momentPrivacySelect.labelIDs) {
            if(self.labels && self.labels.count>0) {
                for (NSDictionary *labelDict in self.labels) {
                   
                    NSString *labelID = [labelDict[@"id"] stringValue];
                    if([labelID isEqualToString:selectedLabelID]) {
                        NSArray *members = labelDict[@"members"];
                        if(members && members.count>0) {
                            for (NSDictionary *memberDict in members) {
                                [uids addObject:memberDict[@"uid"]];
                            }
                        }
                    }
                }
            }
        }
    }
    return uids;
}

-(NSString*) selectItemName {
    if(![self.momentPrivacySelect.privacyKey isEqualToString:@"internal"] && ![self.momentPrivacySelect.privacyKey isEqualToString:@"prohibit"]) {
        return self.momentPrivacySelect.privacyName;
    }
    NSMutableArray *names = [NSMutableArray array];
    if(self.momentPrivacySelect.labelIDs && self.momentPrivacySelect.labelIDs.count>0) {
        for (NSString *selectedLabelID in self.momentPrivacySelect.labelIDs) {
            if(self.labels && self.labels.count>0) {
                for (NSDictionary *labelDict in self.labels) {
                    NSString *labelID = [labelDict[@"id"] stringValue];
                    if([labelID isEqualToString:selectedLabelID]) {
                        [names addObject:labelDict[@"name"]];
                    }
                }
            }
        }
    }
    if(self.momentPrivacySelect.contacts && self.momentPrivacySelect.contacts.count>0) {
        for (WKChannelInfo *channelInfo in self.momentPrivacySelect.contacts) {
            [names addObject:channelInfo.displayName];
        }
    }
    return [names componentsJoinedByString:@"、"];
}



- (NSArray<NSDictionary *> *)tableSectionMaps {
    __weak typeof(self)weakSelf = self;
    
    NSString *privacyKey = self.momentPrivacySelect.privacyKey;
    
    NSMutableArray *items = [NSMutableArray array];
    [items addObject:@{
        @"class": WKMomentPrivacyFirstModel.class,
        @"title":[self.momentPrivacySelect privacyName:@"public"],
        @"subtitle":LLang(@"所有朋友可见"),
        @"checked": @([privacyKey isEqualToString:@"public"]),
        @"onClick":^ {
            [weakSelf.momentPrivacySelect.contacts removeAllObjects];
            weakSelf.momentPrivacySelect.privacyKey = @"public";
            [weakSelf reloadData];
        }
    }];
    [items addObject:@{
        @"class": WKMomentPrivacyFirstModel.class,
        @"title":[self.momentPrivacySelect privacyName:@"private"],
        @"checked": @([privacyKey isEqualToString:@"private"]),
        @"subtitle": LLang(@"仅自己可见"),
        @"onClick":^ {
        [weakSelf.momentPrivacySelect.contacts removeAllObjects];
            weakSelf.momentPrivacySelect.privacyKey = @"private";
            [weakSelf reloadData];
        }
    }];
    [items addObject:@{
        @"class": WKMomentPrivacyFirstModel.class,
        @"title": [self.momentPrivacySelect privacyName:@"internal"],
        @"checked": @([privacyKey isEqualToString:@"internal"]),
        @"subtitle": LLang(@"选中的朋友可见"),
        @"canUnfold":@(true),
        @"onClick":^ {
            weakSelf.momentPrivacySelect.privacyKey = @"internal";
            [weakSelf.momentPrivacySelect.contacts removeAllObjects];
            [weakSelf reloadData];
        }
    }];
    if([privacyKey isEqualToString:@"internal"]) {
        [items addObjectsFromArray:[self subItemSeletion]];
    }
    [items addObject:@{
        @"class": WKMomentPrivacyFirstModel.class,
        @"title": [self.momentPrivacySelect privacyName:@"prohibit"],
        @"checked": @([privacyKey isEqualToString:@"prohibit"]),
        @"ticketRed":@(true),
        @"subtitle": LLang(@"选中的朋友不可见"),
        @"canUnfold":@(true),
        @"onClick":^ {
            weakSelf.momentPrivacySelect.privacyKey = @"prohibit";
            [weakSelf.momentPrivacySelect.contacts removeAllObjects];
            [weakSelf reloadData];
        }
    }];
    if([privacyKey isEqualToString:@"prohibit"]) {
        [items addObjectsFromArray:[self subItemSeletion]];
    }
    return @[
        @{
            @"height":@(0.01f),
            @"items":items,
        }
    ];
}

-(NSArray*) subItemSeletion {
    __weak typeof(self) weakSelf = self;
    NSString *subtitle = @"";
    NSMutableArray *selectdUids = [NSMutableArray array];
    if(self.momentPrivacySelect.contacts.count>0) {
        NSMutableArray *names = [NSMutableArray array];
        for (WKChannelInfo *channelInfo in self.momentPrivacySelect.contacts) {
            [names addObject:channelInfo.displayName];
            [selectdUids addObject:channelInfo.channel.channelId];
        }
        subtitle = [names componentsJoinedByString:@"、"];
    }
    
    NSMutableArray *items = [NSMutableArray array];
    [items addObject:@{
        @"class": WKMomentPrivacySecondModel.class,
        @"title":LLang(@"从通讯录选择"),
        @"subtitle": subtitle,
        @"onClick":^{
            [weakSelf.momentPrivacySelect.contacts removeAllObjects];
            [[WKApp shared] invoke:WKPOINT_CONTACTS_SELECT param:@{@"on_finished":^(NSArray<NSString*>*members){
                
                
                void(^addContacts)(void) = ^{
                    if(members && members.count>0) {
                        for (NSString *uid in members) {
                          WKChannelInfo *channelInfo =  [[WKSDK shared].channelManager getChannelInfo:[WKChannel personWithChannelID:uid]];
                            if(channelInfo) {
                                [weakSelf.momentPrivacySelect.contacts addObject:channelInfo];
                            }
                        }
                        [weakSelf reloadData];

                    }
                };
                
                WKEndpoint *endpoint = [WKApp.shared.endpointManager getEndpointWithSid:WKPOINT_LABEL_UI_SAVE];
                if(endpoint) {
                    [WKAlertUtil alert:LLang(@"保存为标签，下次可直接选用") buttonsStatement:@[LLang(@"存为标签"),LLang(@"忽略")] chooseBlock:^(NSInteger buttonIdx) {
                        if(buttonIdx == 0) {
                            [WKApp.shared invoke:WKPOINT_LABEL_UI_SAVE param:@{
                                @"uids": members,
                                @"onFinish":^(NSDictionary *resultDict){
                                [WKNavigationManager.shared popToViewControllerClass:WKMomentPrivacyVC.class animated:YES];
                                    if(resultDict[@"id"]) {
                                        NSString *labelID = [resultDict[@"id"] stringValue];
                                        [weakSelf.momentPrivacySelect.labelIDs addObject:labelID];
                                        
                                        [weakSelf reloadData];
                                    }
                                }
                            }];
                        }else {
                            [[WKNavigationManager shared] popViewControllerAnimated:YES];
                            addContacts();
                        }
                    }];
                }else{
                    [[WKNavigationManager shared] popViewControllerAnimated:YES];
                    addContacts();
                }
                
            },@"selecteds":selectdUids?:@[],@"hidden_systemuser":@(true)}];
        }
    }];

    if(self.labels && self.labels.count>0) {
        for (NSDictionary *labelDict in self.labels) {
            NSString *name = labelDict[@"name"]?:@"";
            NSString *content = @"";
            NSArray *members = labelDict[@"members"];
            NSString *labelID = [labelDict[@"id"] stringValue];
            if(members && members.count>0) {
                NSMutableArray<NSString*> *memberNames = [NSMutableArray array];
                for (NSDictionary *memberDict in members) {
                    NSString *memberUID = memberDict[@"uid"];
                    NSString *memberName = memberDict[@"name"];
                    WKChannelInfo *channelInfo = [WKSDK.shared.channelManager getChannelInfo:[WKChannel personWithChannelID:memberUID]];
                    if(channelInfo) {
                        [memberNames addObject:channelInfo.displayName];
                    }else{
                        [memberNames addObject:memberName];
                    }
                   
                }
                content = [memberNames componentsJoinedByString:@"、"];
            }
            
            [items addObject:@{
                @"class": WKMomentPrivacyTagModel.class,
                @"title": name,
                @"content": content,
                @"checked": @([weakSelf.momentPrivacySelect.labelIDs containsObject:labelID]),
                @"onMore":^{
                    [WKApp.shared invoke:WKPOINT_LABEL_UI_DETAIL param:labelDict];
                },
                @"onCheck":^(BOOL checked){
                    if(checked) {
                        [weakSelf.momentPrivacySelect.labelIDs addObject:labelID];
                    }else{
                        [weakSelf.momentPrivacySelect.labelIDs removeObject:labelID];
                    }
                }
            }];
        }
    }
    
   
    
   
    
    return items;
}

- (void)requestData:(void (^)(NSError * _Nullable))complete {
   WKEndpoint *endpoint = [WKApp.shared getEndpoint:WKPOINT_LABEL_DATA_LIST];
    if(endpoint) {
        __weak typeof(self) weakSelf = self;
        AnyPromise *result = endpoint.handler(@{});
        if(result) {
            result.then(^(NSArray *results){
                weakSelf.labels = results;
                [weakSelf reloadData];
            }).catch(^(NSError *error){
                NSLog(@"获取标签数据失败！->%@",error);
            });
        }
    }
}

-(void) labelRefresh {
    [self reloadRemoteData];
}


- (NSMutableArray *)unfoldArray {
    if(!_unfoldArray) {
        _unfoldArray = [NSMutableArray array];
    }
    return _unfoldArray;
}

@end
