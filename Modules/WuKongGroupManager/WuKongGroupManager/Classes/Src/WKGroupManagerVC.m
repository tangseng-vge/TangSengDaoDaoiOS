//
//  WKGroupManagerVC.m
//  WuKongBase
//
//  Created by tt on 2020/3/1.
//

#import "WKGroupManagerVC.h"
#import "WKGroupManagerVM.h"
#import "WKGroupManager.h"
#import "WKModelConvert.h"
#import "WKConversationGroupSettingVC.h"
@interface WKGroupManagerVC ()<WKGroupManagerVMDelegate,WKChannelManagerDelegate>


@end

@implementation WKGroupManagerVC

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.viewModel =  [[WKGroupManagerVM alloc] init];
    }
    return self;
}

- (void)viewDidLoad {
    self.viewModel.channel = self.channel;
    self.viewModel.delegate = self;
    [super viewDidLoad];
    
    // 监听群成员更新通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(memberUpdate) name:WKNOTIFY_GROUP_MEMBERUPDATE object:nil];
    // 监听频道数据变化
    [[WKSDK shared].channelManager addDelegate:self];
}

- (NSString *)langTitle {
    return LLang(@"群管理");
}


// 群成员更新
-(void) memberUpdate {
    [self reloadManagerAndCreators];
}

-(void) reloadManagerAndCreators {
    [self.viewModel reloadManagerAndCreators];
    [self reloadData];
    [self.tableView reloadData];
}

-(void) reloadChannelInfo {
    [self.viewModel reloadChannelInfo];
    [self reloadData];
    [self.tableView reloadData];
}

- (void)dealloc {
    // 销毁监听群成员更新通知
    [[NSNotificationCenter defaultCenter] removeObserver:self name:WKNOTIFY_GROUP_MEMBERUPDATE object:nil];
      [[WKSDK shared].channelManager removeDelegate:self];
}

#pragma mark -  WKGroupManagerVMDelegate

-(void) didDeleteManager:(WKGroupManagerVM*)vm manager:(WKChannelMember*)manager {
    __weak typeof(self) weakSelf = self;
       UIAlertController *alertController = [UIAlertController alertControllerWithTitle:LLang(@"提示") message:[NSString stringWithFormat:LLang(@"取消“%@”的管理员身份？"),manager.memberName] preferredStyle:UIAlertControllerStyleAlert];
       
       UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:LLang(@"取消") style:UIAlertActionStyleCancel handler:nil];
       UIAlertAction *okAction = [UIAlertAction actionWithTitle:LLang(@"好的") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [[WKGroupManager shared] groupNo:weakSelf.channel.channelId managersToMember:@[manager.memberUid] complete:^(NSError * _Nonnull error) {
                if(error) {
                    [weakSelf.view showMsg:error.domain];
                    return;
                }
                [weakSelf reloadManagerAndCreators];
           }];
       }];
       [alertController addAction:cancelAction];
       [alertController addAction:okAction];
       
       [self presentViewController:alertController animated:YES completion:nil];
}

- (void)didTransferGrouper:(WKGroupManagerVM *)vm {
    NSMutableArray<WKContactsSelect*> *contactsSelects = [NSMutableArray array];
    NSArray *members =  self.viewModel.members;
       for (WKChannelMember *member in members) {
           if([member.memberUid isEqualToString:[WKApp shared].loginInfo.uid]) { // 排除自己
                  continue;
           }
           if([member.memberUid isEqualToString:[WKApp shared].config.fileHelperUID]) { // 排除文件助手
                  continue;
           }
           if([member.memberUid isEqualToString:[WKApp shared].config.systemUID]) { // 系统
                  continue;
           }
           [contactsSelects addObject:[WKModelConvert toContactsSelect:member]];
       }
       __weak typeof(self) weakSelf = self;
       [[WKApp shared] invoke:WKPOINT_CONTACTS_SELECT param:@{@"on_finished":^(NSArray<NSString*>*uids){
           [WKAlertUtil alert:LLang(@"你将自动放弃群主身份。") buttonsStatement:@[LLang(@"取消"),LLang(@"好的")] chooseBlock:^(NSInteger buttonIdx) {
               if(buttonIdx == 1) {
                   [weakSelf.viewModel requestTransferGrouper:uids[0]].then(^{
                       [[WKNavigationManager shared] popToViewControllerClass:WKConversationGroupSettingVC.class animated:YES];
                   }).catch(^(NSError *error){
                       [[WKNavigationManager shared].topViewController.view showMsg:error.domain];
                   });
               }
           }];
          },@"data":contactsSelects,@"mode":@"single",@"title":LLang(@"选择新的群主")}];
}

#pragma mark -- WKChannelManagerDelegate

- (void)channelInfoUpdate:(WKChannelInfo *)channelInfo {
    if(![self.channel isEqual:channelInfo.channel]) {
           return;
    }
    [self reloadChannelInfo];
}

@end
