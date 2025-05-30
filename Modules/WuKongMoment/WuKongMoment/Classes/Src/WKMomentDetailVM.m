//
//  WKMomentDetailVM.m
//  WuKongMoment
//
//  Created by tt on 2020/11/17.
//

#import "WKMomentDetailVM.h"
#import "WKMomentContentCell.h"
#import "WKMomentOperateCell.h"
#import "WKMomentLikeCell2.h"
#import "WKMomentCommentItemCell.h"
#import "WKMomentVM.h"
#import "WKMomentContentVideoCell.h"

@interface WKMomentDetailVM ()



@end

@implementation WKMomentDetailVM

- (NSArray<NSDictionary *> *)tableSectionMaps {
    if(!self.moment) {
        return nil;
    }
    NSString *timeFormat = [WKTimeTool getTimeStringAutoShort2:[WKTimeTool dateFromString:self.moment.createdAt format:@"yyyy-MM-dd HH:mm"] mustIncludeTime:YES];
    // ---------- 点赞 ----------
    NSDictionary *likeItemDict;
    BOOL myLike = false; // 我是否已d
    if(self.moment.likes && self.moment.likes.count>0) {
        NSMutableArray *likeUsers = [NSMutableArray array];
        for (WKLikeResp *likeResp in self.moment.likes) {
            if([likeResp.uid isEqualToString:[WKApp shared].loginInfo.uid]) {
                myLike = true;
            }
            [likeUsers addObject: [WKMomentLikeUser uid:likeResp.uid name:likeResp.name]];
        }
        likeItemDict = @{
            @"class": WKMomentLikeModel2.class,
            @"hasComment":@(self.moment.comments.count>0),
            @"users":likeUsers,
        };
    }
    NSMutableArray *items = [NSMutableArray array];
    
    if(self.moment.isVideo) {
        [items addObject: @{
            @"class":WKMomentContentVideoModel.class,
            @"sid": self.moment.momentNo,
            @"uid": self.moment.publisher?:@"",
            @"name": self.moment.publisherName?:@"",
            @"avatar": [WKAvatarUtil getAvatar:self.moment.publisher],
            @"videoCoverURL": self.moment.videoCoverPath?:@"",
            @"videoURL": self.moment.videoPath?:@"",
            @"content": self.moment.text?:@"",
        }];
    }else{
        [items addObject: @{
            @"class":WKMomentContentModel.class,
            @"sid": self.moment.momentNo?:@"",
            @"uid": self.moment.publisher?:@"",
            @"name": self.moment.publisherName?:@"",
            @"imgs": self.moment.imgs?:@[],
            @"avatar": [WKAvatarUtil getAvatar:self.moment.publisher],
            @"content":self.moment.text?:@"",
        }];
    }

    
    // like
    [items addObject:@{
        @"class": WKMomentOperateModel.class,
        @"timeFormat":timeFormat?:@"",
    }];
    if(likeItemDict) {
        [items addObject:likeItemDict];
    }
    
    // comment
    if(self.moment.comments && self.moment.comments.count>0) {
        NSInteger i=0;
        for (WKCommentResp *commentResp in self.moment.comments) {
            NSString *timeFormat = [WKTimeTool getTimeStringAutoShort2:[WKTimeTool dateFromString:commentResp.commentAt format:@"yyyy-MM-dd HH:mm"] mustIncludeTime:YES];
            [items addObject:@{
                @"class": WKMomentCommentItemModel.class,
                @"sid": commentResp.sid?:@"",
                @"uid":commentResp.uid,
                @"first":@(i==0),
                @"name":commentResp.name?:@"",
                @"toUID": commentResp.replyUID?:@"",
                @"toName": commentResp.replyName?:@"",
                @"timeFormat": timeFormat,
                @"content":commentResp.content?:@"",
            }];
            i++;
        }
    }
    
    return @[
        @{
            @"height":@(0.01f),
            @"items":items,
        },
    ];
}

- (void)requestData:(void (^)(NSError * _Nullable))complete {
    __weak typeof(self) weakSelf = self;
    [[WKAPIClient sharedClient] GET:[NSString stringWithFormat:@"moments/%@",self.momentNo] parameters:nil model:WKMomentResp.class].then(^(WKMomentResp *resp){
        weakSelf.moment = resp;
        complete(nil);
    }).catch(^(NSError *error){
        complete(error);
    });
}

-(AnyPromise*) requestCommentDel:(NSString*)momentNo commentID:(NSString*)commentID {
    return  [[WKAPIClient sharedClient] DELETE:[NSString stringWithFormat:@"moments/%@/comments/%@",momentNo,commentID] parameters:nil];
}

-(AnyPromise*) requestCommentAdd:(NSString*)momentNo req:(WKCommentReq*)req {
    return [[WKAPIClient sharedClient] POST:[NSString stringWithFormat:@"moments/%@/comments",momentNo] parameters:[req toMap:ModelMapTypeAPI]];
}

@end
