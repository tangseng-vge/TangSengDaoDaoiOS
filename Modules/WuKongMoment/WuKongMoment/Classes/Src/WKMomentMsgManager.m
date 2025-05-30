//
//  WKMomentMsgManager.m
//  WuKongMoment
//
//  Created by tt on 2020/11/25.
//

#import "WKMomentMsgManager.h"
#import "WKMomentCommon.h"
#import "WKMomentMsgDB.h"
@interface WKMomentMsgManager ()<WKCMDManagerDelegate>

/**
 *  用来存储所有添加j过的delegate
 *  NSHashTable 与 NSMutableSet相似，但NSHashTable可以持有元素的弱引用，而且在对象被销毁后能正确地将其移除。
 */
@property (strong, nonatomic) NSHashTable  *delegates;
/**
 *  delegateLock 用于给delegate的操作加锁，防止多线程同时调用
 */
@property (strong, nonatomic) NSLock  *delegateLock;

@end

@implementation WKMomentMsgManager


static WKMomentMsgManager *_instance = nil;

+(instancetype)allocWithZone:(struct _NSZone *)zone{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [super allocWithZone:zone ];
    });
    return _instance;
}

+(instancetype) shared{
    if (_instance == nil) {
        _instance = [[super alloc]init];
    }
    return _instance;
}

-(void) setup {
    [[WKSDK shared].cmdManager addDelegate:self];
}

- (void)dealloc {
    [[WKSDK shared].cmdManager removeDelegate:self];
}
- (NSLock *)delegateLock {
    if (_delegateLock == nil) {
        _delegateLock = [[NSLock alloc] init];
    }
    return _delegateLock;
}

-(NSHashTable*) delegates {
    if (_delegates == nil) {
        _delegates = [NSHashTable hashTableWithOptions:NSPointerFunctionsWeakMemory];
    }
    return _delegates;
}

-(void) addDelegate:(id<WKMomentMsgManagerDelegate>) delegate{
    [self.delegateLock lock];//防止多线程同时调用
    [self.delegates addObject:delegate];
    [self.delegateLock unlock];
}
- (void)removeDelegate:(id<WKMomentMsgManagerDelegate>) delegate {
    [self.delegateLock lock];//防止多线程同时调用
    [self.delegates removeObject:delegate];
    [self.delegateLock unlock];
}


-(void) callOnCMDDelegate:(WKCMDModel*)model {
    [self.delegateLock lock];
    NSHashTable *copyDelegates =  [self.delegates copy];
    [self.delegateLock unlock];
    for (id delegate in copyDelegates) {//遍历delegates ，call delegate
        if(!delegate) {
            continue;
        }
        if ([delegate respondsToSelector:@selector(recvMomentCMDMsg:)]) {
            if (![NSThread isMainThread]) {
                dispatch_sync(dispatch_get_main_queue(), ^{
                    [delegate recvMomentCMDMsg:model];
                });
            }else {
                [delegate recvMomentCMDMsg:model];
            }
        }
    }
}

#pragma mark -- WKCMDManagerDelegate

-(void) cmdManager:(WKCMDManager*)manager onCMD:(WKCMDModel*)model {
    if([model.cmd isEqualToString:@"momentMsg"]) {
        
        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
        if(!model.param) {
            return;
        }
        NSString *action = model.param[@"action"];
        if(!action) {
            return;
        }
        if([action isEqualToString:@"comment"] || [action isEqualToString:@"like"]) {
            WKMomentMsgModel *msgModel = [WKMomentMsgModel new];
            msgModel.action = action;
            msgModel.actionAt = [model.param[@"action_at"] integerValue];
            msgModel.comment = model.param[@"comment"];
            msgModel.content = model.param[@"content"];
            msgModel.momentNo = model.param[@"moment_no"];
            msgModel.commentID = [NSString stringWithFormat:@"%@",model.param[@"comment_id"]];
            msgModel.uid = model.param[@"uid"];
            msgModel.name = model.param[@"name"];
            [[WKMomentMsgDB shared] insert:msgModel];
        }else if([action isEqualToString:@"delete_comment"]){
            NSString *commentID = [NSString stringWithFormat:@"%@",model.param[@"comment_id"]];
            [WKMomentMsgDB.shared deleteComment:commentID];
        }
       
        NSString *msgCountKey = [NSString stringWithFormat:@"%@%@:msgcount",momentMsgDataKeyPrefx,[WKApp.shared loginInfo].uid];
        NSString *userUIDKey = [NSString stringWithFormat:@"%@%@:uid",momentMsgDataKeyPrefx,[WKApp.shared loginInfo].uid];
        NSString *commentUserUIDKey = [NSString stringWithFormat:@"%@%@:commenter",momentMsgDataKeyPrefx,[WKApp.shared loginInfo].uid];
        NSInteger msgCount = [userDefault integerForKey:msgCountKey];
        if([action isEqualToString:@"like"]) {
            msgCount++;
            [userDefault setObject:model.param[@"uid"]?:@"" forKey:commentUserUIDKey];
        }else if([action isEqualToString:@"comment"]){
            msgCount++;
            [userDefault setObject:model.param[@"uid"]?:@"" forKey:commentUserUIDKey];
        }else if([action isEqualToString:@"publish"]){
            [userDefault setObject:model.param[@"uid"]?:@"" forKey:userUIDKey];
        }
        [userDefault setInteger:msgCount forKey:msgCountKey];
       
        [userDefault synchronize];
        
        // 更新header
        [[NSNotificationCenter defaultCenter] postNotificationName:WK_NOTIFY_CONTACTS_HEADER_UPDATE object:nil];
        // 更新联系人tabbar红点
        [[NSNotificationCenter defaultCenter] postNotificationName:WK_NOTIFY_CONTACTS_TAB_REDDOT_UPDATE object:nil];
        
        [self callOnCMDDelegate:model];
    }
}

@end
