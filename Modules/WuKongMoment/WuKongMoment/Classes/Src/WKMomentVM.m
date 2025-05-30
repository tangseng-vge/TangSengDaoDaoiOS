//
//  WKMomentVM.m
//  WuKongMoment
//
//  Created by tt on 2020/11/5.
//

#import "WKMomentVM.h"
#import "WKMomentContentCell.h"
#import "WKMomentOperateCell.h"
#import "WKMomentNewMsgCell.h"
#import "WKMomentLikeCell.h"
#import "WKMomentMsgListVC.h"
#import "WKMomentCommentItemTextCell.h"
#import "WKMomentContentVideoCell.h"
#import "WKMomentCommon.h"
#import "WKMomentShareUserListVC.h"

@interface WKMomentVM ()



@end

@implementation WKMomentVM

- (NSArray<NSDictionary *> *)tableSectionMaps {
    if(self.moments.count<=0) {
        return @[];
    }
    __weak typeof(self) weakSelf = self;
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSMutableArray *items = [NSMutableArray array];
    NSInteger i = 0;
    NSString *msgCountKey = [NSString stringWithFormat:@"%@%@:msgcount",momentMsgDataKeyPrefx,[WKApp.shared loginInfo].uid];
    NSString *commentUserUIDKey = [NSString stringWithFormat:@"%@%@:commenter",momentMsgDataKeyPrefx,[WKApp.shared loginInfo].uid];
    NSInteger unreadCount =  [userDefault integerForKey:msgCountKey];
    NSString *lastCommentUID =  [userDefault stringForKey:commentUserUIDKey];
    BOOL hasNewMsg =  [self isSelf] && unreadCount>0;
    
    [items addObject:@{
        @"height":@(0.01f),
        @"items": @[
                @{
                    @"class": WKMomentNewMsgModel.class,
                    @"hasNewMsg":@(hasNewMsg),
                    @"msgCount":@(unreadCount),
                    @"lastMsgAvatar": [WKAvatarUtil getAvatar:lastCommentUID],
                    @"onClick":^{
                        [userDefault setInteger:0 forKey:msgCountKey];
                        [userDefault setObject:@"" forKey:commentUserUIDKey];
                        [userDefault synchronize];
                        [weakSelf reloadData];
                        // 更新header
                        [[NSNotificationCenter defaultCenter] postNotificationName:WK_NOTIFY_CONTACTS_HEADER_UPDATE object:nil];
                        // 更新联系人tabbar红点
                        [[NSNotificationCenter defaultCenter] postNotificationName:WK_NOTIFY_CONTACTS_TAB_REDDOT_UPDATE object:nil];
                        [[WKNavigationManager shared] pushViewController:[WKMomentMsgListVC new] animated:YES];
                    }
                }
        ],
    }];
    
    for (WKMomentResp *moment in self.moments) {
        
        // ---------- 点赞 ----------
        NSDictionary *likeItemDict;
        BOOL myLike = false; // 我是否已d
        BOOL showPrivate = false;
        BOOL selfVisiable = false;
        
        if([moment.privacyType isEqualToString:@"internal"] || [moment.privacyType isEqualToString:@"prohibit"]) {
            showPrivate = [WKApp.shared.loginInfo.uid isEqualToString:moment.publisher];
        }else if([moment.privacyType isEqualToString:@"private"]) {
            selfVisiable = [WKApp.shared.loginInfo.uid isEqualToString:moment.publisher];
        }
        if(moment.likes && moment.likes.count>0) {
            NSMutableArray *likeUsers = [NSMutableArray array];
            for (WKLikeResp *likeResp in moment.likes) {
                if([likeResp.uid isEqualToString:[WKApp shared].loginInfo.uid]) {
                    myLike = true;
                }
                [likeUsers addObject: [WKMomentLikeUser uid:likeResp.uid name:likeResp.name]];
            }
            likeItemDict = @{
                @"class": WKMomentLikeModel.class,
                @"hasComment":@(moment.comments.count>0),
                @"users":likeUsers,
            };
        }
        
        // ---------- 评论 ----------
        NSMutableArray *commentItems = [NSMutableArray array];
        if(moment.comments && moment.comments.count>0) {
            NSInteger i=0;
            for (WKCommentResp *commentResp in moment.comments) {
                [commentItems addObject:@{
                    @"class": WKMomentCommentItemTextModel.class,
                    @"sid": commentResp.sid?:@"",
                    @"uid":commentResp.uid,
                    @"name":commentResp.name?:@"",
                    @"toUID": commentResp.replyUID?:@"",
                    @"toName": commentResp.replyName?:@"",
                    @"content":commentResp.content?:@"",
                    @"bottomCorner":@(i==moment.comments.count-1),
                }];
                i++;
            }
        }
        
        NSMutableArray *momentItems = [NSMutableArray array];
        if(moment.isVideo) {
            [momentItems addObject: @{
                @"class":WKMomentContentVideoModel.class,
                @"sid": moment.momentNo,
                @"uid": moment.publisher?:@"",
                @"name": moment.publisherName?:@"",
                @"avatar": [WKAvatarUtil getAvatar:moment.publisher],
                @"videoCoverURL": moment.videoCoverPath?:@"",
                @"videoURL": moment.videoPath?:@"",
                @"content": moment.text?:@"",
            }];
        }else{
            [momentItems addObject: @{
                @"class":WKMomentContentModel.class,
                @"sid": moment.momentNo?:@"",
                @"uid": moment.publisher?:@"",
                @"name": moment.publisherName?:@"",
                @"imgs": moment.imgs?:@[],
                @"avatar": [WKAvatarUtil getAvatar:moment.publisher],
                @"content":moment.text?:@"",
            }];
        }
       
    
        NSString *timeFormat = [WKTimeTool getTimeStringAutoShort2:[WKTimeTool dateFromString:moment.createdAt format:@"yyyy-MM-dd HH:mm:ss"] mustIncludeTime:YES];
        
        [momentItems addObject: @{
            @"class": WKMomentOperateModel.class,
            @"sid": moment.momentNo?:@"",
            @"timeFormat":timeFormat,
            @"liked": @(myLike),
            @"showPrivate":@(showPrivate),
            @"selfVisiable":@(selfVisiable),
            @"showDelete":@([[WKApp shared].loginInfo.uid isEqualToString:moment.publisher]),
            @"onComment":^(WKMomentOperateCell *cell,WKMomentOperateModel *model) {
                if(weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(momentVMCommentClick:cell:model:)]) {
                    [weakSelf.delegate momentVMCommentClick:weakSelf cell:cell model:moment];
                }
            },
            @"onLike":^(WKMomentOperateCell *cell,WKMomentOperateModel *model) {
                NSMutableArray *newLikes = [NSMutableArray arrayWithArray:moment.likes];
                if(model.liked) {
                    if(moment.likes && moment.likes.count>0) {
                        for (NSInteger i=0;i<moment.likes.count;i++) {
                            WKLikeResp *resp = moment.likes[i];
                            if([resp.uid isEqualToString:[WKApp shared].loginInfo.uid]) {
                                [newLikes removeObjectAtIndex:i];
                                break;
                            }
                        }
                    }
                }else{
                    WKLikeResp *likeResp = [WKLikeResp new];
                    if(!model.liked) {
                        likeResp.uid = [WKApp shared].loginInfo.uid;
                        likeResp.name = [WKApp shared].loginInfo.extra[@"name"]?:@"";
                    }
                    [newLikes addObject:likeResp];
                }
                moment.likes = newLikes;
                [weakSelf reloadData];
                if(weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(momentVMDLikeClick:model:like:)]) {
                        [weakSelf.delegate momentVMDLikeClick:weakSelf model:moment like:!model.liked];
                    }
                   
                },
            @"onDelete":^{ // 删除
                if(weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(momentVMDelete:model:)]) {
                    [weakSelf.delegate momentVMDelete:weakSelf model:moment];
                }
            },
            @"onPrivate":^{
                if(moment.privacyUids && moment.privacyUids.count>0) {
                    WKMomentShareUserListVC *vc = [WKMomentShareUserListVC new];
                    vc.privacyType = moment.privacyType;
                    vc.privacyUids = moment.privacyUids;
                    [WKNavigationManager.shared pushViewController:vc animated:YES];
                }
            },
        }];
        if(likeItemDict) {
            [momentItems addObject:likeItemDict];
        }
        if(commentItems && commentItems.count>0) {
            [momentItems addObjectsFromArray:commentItems];
        }
        
        [items addObject:@{
            @"height":@(0.01f),
            @"items": momentItems,
        }];
        
        i++;
    }
   
    return items;
}


-(NSString *) getRealUID {
    NSString *uid = @"";
    if(self.uid && ![self.uid isEqualToString:@""]) {
        uid = self.uid;
    }else{
        uid = [WKApp shared].loginInfo.uid;
    }
    return uid;
}

-(NSString*) getRealName {
    if([self isSelf]) {
        return [WKApp shared].loginInfo.extra[@"name"];
    }
  WKChannelInfo *channelInfo =   [[WKSDK shared].channelManager getChannelInfo:[WKChannel personWithChannelID:[self getRealUID]]];
    if(channelInfo) {
        return channelInfo.displayName?:@"";
    }
    return @"";
}
-(BOOL) isSelf {
    NSString *uid = [self getRealUID];
    if([uid isEqualToString:[WKApp.shared loginInfo].uid]) {
        return true;
    }
    return false;
}

-(void) removeMoment:(NSString*)momentNo {
    if(!momentNo) {
        return;
    }
    NSInteger j = -1;
    for (NSInteger i=0; i<self.moments.count; i++) {
        WKMomentResp *moment = self.moments[i];
        if([momentNo isEqualToString:moment.momentNo]) {
            j = i;
            break;
        }
    }
    if(j!=-1) {
        [self.moments removeObjectAtIndex:j];
    }
}

- (NSMutableArray<WKMomentResp *> *)moments {
    if(!_moments) {
        _moments = [NSMutableArray array];
    }
    return _moments;
}

-(AnyPromise*) requestMoments {
    __weak typeof(self) weakSelf = self;
    return [[WKAPIClient sharedClient] GET:@"moments" parameters:@{
        @"page_index": @(weakSelf.pageIndex),
        @"page_size": @(15),
        @"uid": weakSelf.uid?:@"",
    } model:WKMomentResp.class].then(^(NSArray *result){
        if(weakSelf.pageIndex == 1) {
            weakSelf.moments = [NSMutableArray arrayWithArray:result];
        }else{
            [weakSelf.moments addObjectsFromArray:result];
        }
        if(result.count<=0) {
            weakSelf.completed = true;
        }
       
        [weakSelf reloadData];
    });
}

- (NSInteger)pageIndex {
    if(_pageIndex<=0) {
        return 1;
    }
    return _pageIndex;
}

-(AnyPromise*) requestDeleteMoment:(NSString*)momentNo {
    return [[WKAPIClient sharedClient] DELETE:[NSString stringWithFormat:@"moments/%@",momentNo] parameters:nil];
}

- (AnyPromise *)requestLike:(NSString *)momentNo {
    return [[WKAPIClient sharedClient] PUT:[NSString stringWithFormat:@"moments/%@/like",momentNo] parameters:nil];
}

- (AnyPromise *)requestUnlike:(NSString *)momentNo {
    return [[WKAPIClient sharedClient] PUT:[NSString stringWithFormat:@"moments/%@/unlike",momentNo] parameters:nil];
}

-(AnyPromise*) requestCommentAdd:(NSString*)momentNo req:(WKCommentReq*)req {
    return [[WKAPIClient sharedClient] POST:[NSString stringWithFormat:@"moments/%@/comments",momentNo] parameters:[req toMap:ModelMapTypeAPI]];
}

-(AnyPromise*) requestCommentDel:(NSString*)momentNo commentID:(NSString*)commentID {
    return  [[WKAPIClient sharedClient] DELETE:[NSString stringWithFormat:@"moments/%@/comments/%@",momentNo,commentID] parameters:nil];
}

-(AnyPromise*) uploadCover:(UIImage*)img {
    NSData *data = UIImageJPEGRepresentation(img, 0.8);
    return   [AnyPromise promiseWithResolverBlock:^(PMKResolver resolver) {
        [[WKAPIClient sharedClient] GET:@"file/upload" parameters:@{@"type":@"momentcover"}].then(^(NSDictionary *dict){
          NSString *uploadURL = dict[@"url"];
            [[WKAPIClient sharedClient] fileUpload:uploadURL data:data  progress:nil completeCallback:^(id  _Nullable resposeObject, NSError * _Nullable error) {
              if(error) {
                  resolver(error);
                  return;
              }
              resolver(PMKManifold(resposeObject));
          }];
        }).catch(^(NSError *err){
            resolver(err);
        });
    }];
    
}

@end

@implementation WKLikeResp

+ (WKModel *)fromMap:(NSDictionary *)dictory type:(ModelMapType)type {
    WKLikeResp *resp = [WKLikeResp new];
    resp.uid = dictory[@"uid"]?:@"";
    resp.name = dictory[@"name"]?:@"";
    return resp;
}

@end

@implementation WKCommentReq

- (NSDictionary *)toMap:(ModelMapType)type {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[@"content"] = self.content?:@"";
    if(self.replyUID && ![self.replyUID isEqualToString:@""]) {
        dict[@"reply_uid"] = self.replyUID?:@"";
        dict[@"reply_name"] = self.replyName?:@"";
        dict[@"reply_comment_id"] = self.replyCommentID?:@"";
    }
    return dict;
}

@end

@implementation WKCommentResp

+ (WKModel *)fromMap:(NSDictionary *)dictory type:(ModelMapType)type {
    WKCommentResp *resp = [WKCommentResp new];
    resp.sid = dictory[@"sid"]?:@"";
    resp.uid = dictory[@"uid"]?:@"";
    resp.name = dictory[@"name"]?:@"";
    resp.content = dictory[@"content"]?:@"";
    resp.commentAt = dictory[@"comment_at"]?:@"";
    resp.replyUID = dictory[@"reply_uid"]?:@"";
    resp.replyName = dictory[@"reply_name"]?:@"";
    return resp;
}

@end

@implementation WKMomentResp

+ (WKModel *)fromMap:(NSDictionary *)dictory type:(ModelMapType)type {
    WKMomentResp *resp = [WKMomentResp new];
    resp.momentNo = dictory[@"moment_no"]?:@"";
    resp.publisher = dictory[@"publisher"]?:@"";
    resp.publisherName = dictory[@"publisher_name"]?:@"";
    resp.text = dictory[@"text"]?:@"";
    resp.videoPath = dictory[@"video_path"]?:@"";
    resp.videoCoverPath = dictory[@"video_cover_path"]?:@"";
    resp.createdAt = dictory[@"created_at"]?:@"";
    resp.imgs = dictory[@"imgs"]?:@[];
    resp.privacyType = dictory[@"privacy_type"]?:@"";
    resp.privacyUids = dictory[@"privacy_uids"]?:@[];
    
    NSArray<NSDictionary*> *commentDicts = dictory[@"comments"];
    if(commentDicts && ![commentDicts isKindOfClass:[NSNull class]] && commentDicts.count>0) {
        NSMutableArray *comments = [NSMutableArray array];
        for (NSDictionary *commentDict in commentDicts) {
            [comments addObject:[WKCommentResp fromMap:commentDict type:ModelMapTypeAPI]];
        }
        resp.comments = comments;
    }
    
    NSArray<NSDictionary*> *likeDicts = dictory[@"likes"];
    if(likeDicts && ![likeDicts isKindOfClass:[NSNull class]] && likeDicts.count>0) {
        NSMutableArray *likes = [NSMutableArray array];
        for (NSDictionary *likeDict in likeDicts) {
            [likes addObject:[WKLikeResp fromMap:likeDict type:ModelMapTypeAPI]];
        }
        resp.likes = likes;
    }
    
    return resp;
}

- (BOOL)isVideo {
    if(self.videoPath && ![self.videoPath isEqualToString:@""]) {
        return true;
    }
    return false;
}

@end
