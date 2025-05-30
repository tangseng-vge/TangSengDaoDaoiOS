//
//  WKChatBackgroundVC.m
//  WuKongAdvanced
//
//  Created by tt on 2022/9/12.
//

#import "WKChatBackgroundVC.h"

@interface WKChatBackgroundVC ()

@end

@implementation WKChatBackgroundVC

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.viewModel = [WKChatBackgroundVM new];
    }
    return self;
}

- (void)viewDidLoad {
    self.viewModel.channel = self.channel;
    
    [super viewDidLoad];
    
    self.title = LLang(@"聊天背景");
}

@end
