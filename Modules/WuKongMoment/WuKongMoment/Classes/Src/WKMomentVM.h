//
//  WKMomentVM.h
//  WuKongMoment
//
//  Created by tt on 2020/11/5.
//

#import <WuKongBase/WuKongBase.h>
#import "WKMomentOperateCell.h"
@class WKMomentResp;
@class WKMomentVM;
@class WKCommentReq;
NS_ASSUME_NONNULL_BEGIN

@protocol WKMomentVMDelegate <NSObject>

@optional

// 评论点击
-(void) momentVMCommentClick:(WKMomentVM*)vm cell:(WKMomentOperateCell*)cell model:(WKMomentResp*)model;

// 点赞
-(void) momentVMDLikeClick:(WKMomentVM*)vm model:(WKMomentResp*)model like:(BOOL)like;

// 删除朋友圈
-(void) momentVMDelete:(WKMomentVM*)vm model:(WKMomentResp*)model;
@end

@interface WKMomentVM : WKBaseTableVM

@property(nonatomic,weak) id<WKMomentVMDelegate> delegate;

@property(nonatomic,strong) NSMutableArray<WKMomentResp*> *moments;

@property(nonatomic,assign) NSInteger pageIndex; // 当前页码
@property(nonatomic,assign) BOOL completed; // 数据加载完毕

@property(nonatomic,copy) NSString *uid; // 如果查看别人朋友圈请传入要查看人的uid

// 请求朋友圈
-(AnyPromise*) requestMoments;
// 删除朋友圈
-(AnyPromise*) requestDeleteMoment:(NSString*)momentNo;
// 请求点赞
-(AnyPromise*) requestLike:(NSString*)momentNo;
// 请求取消点赞
-(AnyPromise*) requestUnlike:(NSString*)momentNo;

-(void) removeMoment:(NSString*)momentNo;

/// 添加评论
/// @param momentNo <#momentNo description#>
/// @param req <#req description#>
-(AnyPromise*) requestCommentAdd:(NSString*)momentNo req:(WKCommentReq*)req;


/// 删除评论
/// @param momentNo <#momentNo description#>
/// @param commentID <#commentID description#>
-(AnyPromise*) requestCommentDel:(NSString*)momentNo commentID:(NSString*)commentID;


/// 上传封面图
-(AnyPromise*) uploadCover:(UIImage*)img;

-(NSString *) getRealUID;

-(NSString*) getRealName;

-(BOOL) isSelf;

@end

@interface WKCommentReq : WKModel

@property(nonatomic,copy) NSString *content; // 评论内容

@property(nonatomic,copy) NSString *replyCommentID; // 回复评论的ID
@property(nonatomic,copy) NSString *replyUID; // 回复uid
@property(nonatomic,copy) NSString *replyName; // 回复to的名字

@end

// 点赞
@interface WKLikeResp : WKModel

@property(nonatomic,copy) NSString *uid;
@property(nonatomic,copy) NSString *name;

@end

// 评论
@interface WKCommentResp : WKModel

@property(nonatomic,copy) NSString *sid;
@property(nonatomic,copy) NSString *uid;
@property(nonatomic,copy) NSString *name;
@property(nonatomic,copy) NSString *content;
@property(nonatomic,copy) NSString *commentAt;
@property(nonatomic,copy) NSString *replyUID;
@property(nonatomic,copy) NSString *replyName;

@end

// 朋友圈
@interface WKMomentResp : WKModel

@property(nonatomic,copy) NSString *momentNo;
@property(nonatomic,copy) NSString *publisher;
@property(nonatomic,copy) NSString *publisherName;
@property(nonatomic,copy) NSString *videoPath;
@property(nonatomic,copy) NSString *videoCoverPath;
@property(nonatomic,copy) NSString *text;
@property(nonatomic,copy) NSString *createdAt;
@property(nonatomic,copy) NSString *privacyType;
@property(nonatomic,copy) NSArray<NSString*> *privacyUids;
@property(nonatomic,strong) NSArray<NSString*> *imgs;
// 评论
@property(nonatomic,strong) NSArray<WKCommentResp*> *comments;
// 点赞
@property(nonatomic,strong) NSArray<WKLikeResp*> *likes;

-(BOOL) isVideo;

@end

NS_ASSUME_NONNULL_END
