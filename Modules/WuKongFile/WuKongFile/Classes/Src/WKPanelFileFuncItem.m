//
//  WKPanelFileFuncItem.m
//  WuKongFile
//
//  Created by tt on 2022/5/4.
//

#import "WKPanelFileFuncItem.h"
#import "WKFileChooseUtil.h"
#import "WKFileContent.h"
@implementation WKPanelFileFuncItem

- (NSString *)sid {
    return @"apm.wukong.file";
}


- (UIImage *)itemIcon {
    return [self imageName:@"Conversation/Toolbar/FileNormal"];
}

- (void)onPressed:(UIButton *)btn {
    id<WKConversationContext> context = self.inputPanel.conversationContext;
    __weak typeof(context) weakContext = context;
    [[WKFileChooseUtil shared] chooseFile:^(NSString * _Nonnull fileName, NSData * _Nonnull fileData) {
        btn.selected = false;
        [weakContext sendMessage:[WKFileContent initWithFileName:fileName fileData:fileData]];
    } onCancel:^{
        btn.selected = false;
    }];
}
- (NSString *)title {
    return LLang(@"文件");
}

-(UIImage*) imageName:(NSString*)name {
    return [[WKApp shared] loadImage:name moduleID:@"WuKongFile"];
}



@end
