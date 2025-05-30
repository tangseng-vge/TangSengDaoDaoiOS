//
//  WKMomentMsgDB.h
//  WuKongMoment
//
//  Created by tt on 2020/11/26.
//

#import <Foundation/Foundation.h>
#import <WuKongBase/WuKongBase.h>
@class WKMomentMsgModel;
NS_ASSUME_NONNULL_BEGIN

@interface WKMomentMsgDB : NSObject

+ (WKMomentMsgDB *)shared;

-(void) insert:(WKMomentMsgModel*)model;

// 删除评论
-(void) deleteComment:(NSString*)commentID;

-(NSArray<WKMomentMsgModel*>*) queryList;

@end

@interface WKMomentMsgModel : NSObject

@property(nonatomic,assign) NSInteger _id;
@property(nonatomic,copy) NSString *action;
@property(nonatomic,assign) NSInteger actionAt;
@property(nonatomic,copy) NSString *momentNo;
@property(nonatomic,copy) NSString *commentID;
@property(nonatomic,copy) NSDictionary *content;
@property(nonatomic,copy) NSString *uid;
@property(nonatomic,copy) NSString *name;
@property(nonatomic,copy) NSString *comment;
@property(nonatomic,assign) NSInteger version;
@property(nonatomic,assign) BOOL isDeleted;
@end

NS_ASSUME_NONNULL_END
