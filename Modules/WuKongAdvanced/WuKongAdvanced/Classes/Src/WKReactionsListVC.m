//
//  WKReactionsListVC.m
//  WuKongAdvanced
//
//  Created by tt on 2022/8/9.
//

#import "WKReactionsListVC.h"
#import "WKReactionsListVM.h"
@interface WKReactionsListVC ()<WKChannelManagerDelegate>

@end

@implementation WKReactionsListVC


- (instancetype)init
{
    self = [super init];
    if (self) {
        self.viewModel = [WKReactionsListVM new];
    }
    return self;
}

- (void)viewDidLoad {
    
    self.viewModel.reactions = self.reactions;
    
    [super viewDidLoad];
    
    self.title = [NSString stringWithFormat:LLang(@"%ld 人回应"),self.reactions.count];
    
    [WKSDK.shared.channelManager addDelegate:self];
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
   WKReaction *reaction =   self.reactions[indexPath.row];
    
    WKChannelMember *member = [[WKChannelMemberDB shared] get:self.channel memberUID:reaction.uid];
    NSString *vercode = @"";
    if(member && member.extra && member.extra[@"vercode"]) {
        vercode = member.extra[@"vercode"];
    }
    
    [[WKApp shared] invoke:WKPOINT_USER_INFO param:@{
        @"channel": self.channel,
        @"vercode": vercode,
        @"uid": reaction.uid,
    }];
}

- (void)dealloc {
    [WKSDK.shared.channelManager removeDelegate:self];
}



#pragma mark -- WKChannelManagerDelegate

- (void)channelInfoUpdate:(WKChannelInfo *)channelInfo {
    [self reloadData];
}

@end
