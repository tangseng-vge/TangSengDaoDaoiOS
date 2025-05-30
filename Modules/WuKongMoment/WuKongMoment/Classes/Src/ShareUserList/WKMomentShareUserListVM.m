//
//  WKMomentShareUserListVM.m
//  WuKongMoment
//
//  Created by tt on 2022/11/7.
//

#import "WKMomentShareUserListVM.h"
#import "WKAvatarTitleCell.h"

@interface WKMomentShareUserListVM ()<WKChannelManagerDelegate>



@end

@implementation WKMomentShareUserListVM

- (instancetype)init
{
    self = [super init];
    if (self) {
        [WKSDK.shared.channelManager addDelegate:self];
    }
    return self;
}

- (NSArray<NSDictionary *> *)tableSectionMaps {
    if(!self.privacyUids||self.privacyUids.count == 0) {
        return nil;
    }
    
    NSMutableArray *items = [NSMutableArray array];
    
    for (NSString *uid in self.privacyUids) {
        WKChannelInfo *channelInfo = [WKSDK.shared.channelManager getChannelInfo:[WKChannel personWithChannelID:uid]];
        NSString *name = @"";
        if(channelInfo) {
            name = channelInfo.displayName;
        }
        [items addObject:@{
            @"class": WKAvatarTitleModel.class,
            @"avatar": [WKAvatarUtil getAvatar:uid],
            @"name": name,
            @"showArrow":@(false),
            @"onClick":^{
                [WKApp.shared.endpointManager pushUserInfoVC:uid];
            }
        }];
    }
    
    return @[@{
        @"height": @(0),
        @"items": items,
    }];
    
}

- (void)dealloc {
    [WKSDK.shared.channelManager  removeDelegate:self];
}

#pragma mark -- WKChannelManagerDelegate

- (void)channelInfoUpdate:(WKChannelInfo *)channelInfo {
    [self reloadData];
}

@end
