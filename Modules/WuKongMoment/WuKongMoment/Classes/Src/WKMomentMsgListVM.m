//
//  WKMomentMsgListVM.m
//  WuKongMoment
//
//  Created by tt on 2020/11/16.
//

#import "WKMomentMsgListVM.h"
#import "WKMomentMsgItemCell.h"
#import "WKMomentDetailVC.h"
#import "WKMomentMsgDB.h"

@interface WKMomentMsgListVM ()

@property(nonatomic,strong) NSArray<WKMomentMsgModel*> *messages;

@end

@implementation WKMomentMsgListVM

- (NSArray<NSDictionary *> *)tableSectionMaps {
    if(!self.messages || self.messages.count<=0) {
        return @[];
    }
    NSMutableArray *items = [NSMutableArray array];
    for (WKMomentMsgModel *msgModel in self.messages) {
        NSString *time = [WKTimeTool getTimeStringAutoShort2:[NSDate dateWithTimeIntervalSince1970:msgModel.actionAt] mustIncludeTime:YES];
        NSArray *imgs = msgModel.content[@"imgs"];
        NSString *firstImgURL = @"";
        NSString *content = @"";
        BOOL like = false;
        BOOL isVideo = false;
        if(imgs && ![imgs isKindOfClass:[NSNull class]] && imgs.count>0) {
            firstImgURL = [[WKApp.shared getImageFullUrl:imgs[0]] absoluteString];
        }else if(msgModel.content[@"video_conver_path"] && ![msgModel.content[@"video_conver_path"] isEqualToString:@""]) {
            isVideo =true;
            firstImgURL =  [[WKApp.shared getImageFullUrl:msgModel.content[@"video_conver_path"]] absoluteString];
        } else {
            content = msgModel.content[@"moment_content"];
        }
        NSString *comment = msgModel.comment;
        if([msgModel.action isEqualToString:@"like"]) {
            like = true;
        }else if([msgModel.action isEqualToString:@"comment"]) {
            if(msgModel.isDeleted) {
                comment = @"对方评论已删除";
            }
        }
        
        [items addObject:@{
            @"class":WKMomentMsgItemModel.class,
            @"uid": msgModel.uid?:@"",
            @"name": msgModel.name?:@"",
            @"timeFormat": time?:@"",
            @"firstImgURL":firstImgURL,
            @"isVideo":@(isVideo),
            @"comment": comment?:@"",
            @"like": @(like),
            @"isDeleted":@(msgModel.isDeleted),
            @"content": content?:@"",
            @"onClick":^{
                WKMomentDetailVC *vc = [WKMomentDetailVC new];
                vc.momentNo = msgModel.momentNo;
                vc.replyUID = msgModel.uid;
                vc.replyName = msgModel.name;
                [[WKNavigationManager shared] pushViewController:vc animated:YES];
            },
        }];
    }
   
    return @[
        @{
            @"height": @(0.01f),
            @"items":items,
        }
    ];
}

- (void)requestData:(void (^)(NSError * _Nullable))complete {
    self.messages = [[WKMomentMsgDB shared] queryList];
    complete(nil);
    
}

@end
