//
//  WKConversationNotifySettingVC.m
//  WuKongBase
//
//  Created by tt on 2020/10/16.
//

#import "WKConversationNotifySettingVC.h"

@interface WKConversationNotifySettingVC ()

@end

@implementation WKConversationNotifySettingVC

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.viewModel = [WKConversationNotifySettingVM new];
    }
    return self;
}

- (void)viewDidLoad {
    self.viewModel.channel = self.channel;
    
    [super viewDidLoad];

}

- (NSString *)langTitle {
    return LLang(@"消息通知设置");
}

@end
