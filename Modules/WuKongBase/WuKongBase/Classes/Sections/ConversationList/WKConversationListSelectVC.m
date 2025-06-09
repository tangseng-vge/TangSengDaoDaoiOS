//
//  WKConversationSelectVC.m
//  WuKongBase
//
//  Created by tt on 2020/2/2.
//

#import "WKConversationListSelectVC.h"
#import "WKConversationWrapModel.h"
#import <SDWebImage/SDWebImage.h>
#import "WKResource.h"
#import "UIView+WK.h"
#import "WKLabelItemCell.h"
#import "WKIconTitleItemCell.h"
@interface WKConversationListSelectVC ()<WKChannelManagerDelegate,WKConversationListSelectVMDelegate>
@end

@implementation WKConversationListSelectVC


- (instancetype)init
{
    self = [super init];
    if (self) {
        self.viewModel = [WKConversationListSelectVM new];
        self.viewModel.multiple = YES;
        self.viewModel.delegate = self;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addDelegates];
    [self refreshRightItem];
}
-(void) addDelegates {
    // 频道信息监听
    [[[WKSDK shared] channelManager] addDelegate:self];
}

-(void) removeDelegates {
    // 移除频道监听
    [[[WKSDK shared] channelManager] removeDelegate:self];
}
-(void) dealloc {
    [self removeDelegates];
}

-(UIImage*) imageName:(NSString*)name {
    return [WKApp.shared loadImage:name moduleID:@"WuKongBase"];
//    return [[WKResource shared] resourceForImage:name podName:@"WuKongBase_images"];
}

-(void) refreshRightItem {
    if(self.viewModel.multiple == NO) {
        return;
    }
    if ([self.viewModel isKindOfClass:[WKConversationListSelectVM class]]) {
        WKConversationListSelectVM *selectViewModel = (WKConversationListSelectVM *)self.viewModel;
        if ([selectViewModel.selectedChannels count] > 0) {
            NSString *rightTitle =
            [NSString stringWithFormat:@"%@(%i)", LLang(@"完成"),
             (int)[selectViewModel.selectedChannels count]];
            [self setRightBarItem:rightTitle
                   withDisable:false];
        } else {
            [self setRightBarItem:LLang(@"完成") withDisable:true];
        }
    }
    
}

- (void) setRightBarItem:(NSString *)title
          withDisable:(BOOL)disable {
    if(disable) {
        self.rightView =
        [self barButtonItemWithTitle:title
                          titleColor:[[WKApp shared].config.navBarButtonColor colorWithAlphaComponent:0.5f] action:nil];
    }else {
        self.rightView =
        [self barButtonItemWithTitle:title
                          titleColor:[WKApp shared].config.navBarButtonColor
                              action:@selector(nextBtnPress)];
    }
}

//带标题的按钮样式
- (UIButton *)barButtonItemWithTitle:(NSString *)title
                                 titleColor:(UIColor *)titleColor
                                     action:(SEL)selector {
    UIButton *barBtn = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 0.0f, 0.0f)];
    [barBtn addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    [barBtn setTitle:title forState:UIControlStateNormal];
    [barBtn setTitleColor:titleColor forState:UIControlStateNormal];
//    [barBtn setBackgroundColor:[UIColor redColor]];
    [barBtn sizeToFit];
    return barBtn;
}
// 下一步点击
-(void) nextBtnPress  {
    NSArray<WKChannel*> *selectedChannels = ((WKConversationListSelectVM *)self.viewModel).selectedChannels;
    if (self.onMultipleSelect && selectedChannels.count > 0) {
        self.onMultipleSelect(selectedChannels);
    }
}

#pragma mark WKConversationListSelectVMDelegate

- (void)conversationListSelectVM:(WKConversationListSelectVM *)vm didSelected:(NSArray<WKChannel *> *)channels {
    if (self.viewModel.multiple == YES) {
        [self refreshRightItem];
    } else {
        if(self.onSelect) {
            self.onSelect(channels[0]);
        }
    }
}

#pragma mark -- WKChannelManagerDelegate
-(void) channelInfoUpdate:(WKChannelInfo*)channelInfo {
    [self reloadData];
}
@end

