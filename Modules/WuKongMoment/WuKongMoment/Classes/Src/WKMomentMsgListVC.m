//
//  WKMomentMsgListVC.m
//  WuKongMoment
//
//  Created by tt on 2020/11/16.
//

#import "WKMomentMsgListVC.h"

@interface WKMomentMsgListVC ()

@end

@implementation WKMomentMsgListVC

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.viewModel = [WKMomentMsgListVM new];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (NSString *)langTitle {
    return LLang(@"消息");
}

@end
