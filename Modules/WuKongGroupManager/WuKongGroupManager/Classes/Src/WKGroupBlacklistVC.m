//
//  WKGroupBlacklistVC.m
//  WuKongBase
//
//  Created by tt on 2020/10/19.
//

#import "WKGroupBlacklistVC.h"

@interface WKGroupBlacklistVC ()<WKGroupBlacklistVMDelegate>

@end

@implementation WKGroupBlacklistVC

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.viewModel = [WKGroupBlacklistVM new];
        self.viewModel.delegate = self;
    }
    return self;
}

- (void)viewDidLoad {
    self.viewModel.channel = self.channel;
    [super viewDidLoad];
}

- (NSString *)langTitle {
    return LLang(@"群黑名单");
}

#pragma mark - WKGroupBlacklistVMDelegate

- (void)groupBlacklistVMRemoveBlacklist:(WKGroupBlacklistVM *)vm member:(WKChannelMember*)member{
    __weak typeof(self) weakSelf = self;
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:LLang(@"提示") message:[NSString stringWithFormat:LLang(@"把“%@”拉出群黑名单？"),member.memberName] preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:LLang(@"取消") style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:LLang(@"好的") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf.viewModel addOrRemoveBlacklist:@"remove" uids:@[member.memberUid]];
    }];
    [alertController addAction:cancelAction];
    [alertController addAction:okAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

@end
