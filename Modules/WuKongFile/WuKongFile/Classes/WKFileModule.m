//
//  WKFileModule.m
//  WuKongFile
//
//  Created by tt on 2020/5/5.
//

#import "WKFileModule.h"
#import "WKFileContent.h"
#import "WKFileCell.h"
#import "WKFileChooseUtil.h"
#import "WKPanelFileFuncItem.h"
@WKModule(WKFileModule)
@implementation WKFileModule

+(NSString*) gmoduleId {
    return @"WuKongFile";
}

-(NSString*) moduleId {
    return [WKFileModule gmoduleId];
}

- (void)moduleInit:(WKModuleContext *)context {
    NSLog(@"【WuKongFile】模块初始化！");
     // 注册消息
    [[WKApp shared] registerCellClass:WKFileCell.class forMessageContntClass:WKFileContent.class];
    
    // file
    [self setMethod:WKPOINT_CATEGORY_PANELFUNCITEM_FILE handler:^id _Nullable(id  _Nonnull param) {
        WKPanelDefaultFuncItem *item = [[WKPanelFileFuncItem alloc] init];
        item.sort = 8000;
        return item;
    } category:WKPOINT_CATEGORY_PANELFUNCITEM];
}


// 数据库加载完成
-(void) moduleDidDatabaseLoad:(WKModuleContext*_Nonnull) context {
    WKLogDebug(@"【WuKongFile】数据库加载完成....");
//    WKChannel *fileHelperChannel = [[WKChannel alloc] initWith:[WKApp shared].loginInfo.uid channelType:WK_PERSON];
//    WKConversation *fileHeplerConversation = [[WKSDK shared].conversationManager getConversation:fileHelperChannel];
//    if(!fileHeplerConversation) {
//        WKConversation *fileHeplerConversation = [WKConversation new];
//        fileHeplerConversation.channel = fileHelperChannel;
//        fileHeplerConversation.version = 1;
//        fileHeplerConversation.lastMsgTimestamp = [[NSDate date] timeIntervalSince1970];
//        [[WKSDK shared].conversationManager addConversation:fileHeplerConversation];
//    }
    
}
-(UIImage*) imageName:(NSString*)name {
    return [[WKApp shared] loadImage:name moduleID:@"WuKongFile"];
}

@end
