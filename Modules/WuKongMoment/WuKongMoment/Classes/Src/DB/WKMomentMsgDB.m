//
//  WKMomentMsgDB.m
//  WuKongMoment
//
//  Created by tt on 2020/11/26.
//

#import "WKMomentMsgDB.h"

#define SQL_INSERT @"insert into moment_msg(action,action_at,moment_no,comment_id,content,uid,name,comment,version) values(?,?,?,?,?,?,?,?,?)"

#define SQL_QUERY @"select * from moment_msg order by action_at desc limit 1000"

#define SQL_COMMENT_DELETE @"update moment_msg set is_deleted=1,content='' where comment_id=?"

@implementation WKMomentMsgDB


static WKMomentMsgDB *_instance;
+ (id)allocWithZone:(NSZone *)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [super allocWithZone:zone];
    });
    return _instance;
}
+ (WKMomentMsgDB *)shared
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}

-(void) insert:(WKMomentMsgModel*)model {
    [[WKKitDB shared].dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
        
        [db executeUpdate:SQL_INSERT,model.action?:@"",@(model.actionAt),model.momentNo?:@"",model.commentID?:@"",[self dictToStr:model.content]?:@"",model.uid?:@"",model.name?:@"",model.comment?:@"",@(model.version)];
    }];
}


-(void) deleteComment:(NSString*)commentID {
    [[WKKitDB shared].dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
        [db executeUpdate:SQL_COMMENT_DELETE,commentID];
    }];
}
-(NSString*) dictToStr:(NSDictionary*)extra {
    NSString *extraStr = @"";
    if(extra) {
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:extra options:kNilOptions error:nil];
        extraStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    return extraStr;
}

-(NSArray<WKMomentMsgModel*>*) queryList {
   __block NSMutableArray<WKMomentMsgModel*> *items = [NSMutableArray array];
    [[WKKitDB shared].dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
        FMResultSet *resultSet = [db executeQuery:SQL_QUERY];
        while (resultSet.next) {
            [items addObject:[self toModel:resultSet]];
        }
        [resultSet close];
    }];
    
    return items;
}

-(WKMomentMsgModel*) toModel:(FMResultSet*)resultSet {
    WKMomentMsgModel *model = [WKMomentMsgModel new];
    model._id = [resultSet intForColumn:@"id"];
    model.action = [resultSet stringForColumn:@"action"];
    model.actionAt = [resultSet intForColumn:@"action_at"];
    model.momentNo = [resultSet stringForColumn:@"moment_no"];
    model.uid = [resultSet stringForColumn:@"uid"];
    model.name = [resultSet stringForColumn:@"name"];
    model.comment = [resultSet stringForColumn:@"comment"];
    model.commentID =  [resultSet stringForColumn:@"comment_id"];
    model.isDeleted = [resultSet boolForColumn:@"is_deleted"];
    NSString *content = [resultSet stringForColumn:@"content"];
    
    if(content && ![content isEqualToString:@""]) {
        NSError *error;
       NSDictionary *resultDict = [NSJSONSerialization JSONObjectWithData:[content dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:&error];
        if(resultDict) {
            model.content = resultDict;
        }else{
            model.content = [NSDictionary dictionary];
        }
    }
    return model;
}


@end


@implementation WKMomentMsgModel


@end
