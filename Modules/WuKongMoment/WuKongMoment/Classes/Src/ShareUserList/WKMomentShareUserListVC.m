//
//  WKMomentShareUserListVC.m
//  WuKongMoment
//
//  Created by tt on 2022/11/7.
//

#import "WKMomentShareUserListVC.h"

@interface WKMomentShareUserListVC ()

@end

@implementation WKMomentShareUserListVC


- (instancetype)init
{
    self = [super init];
    if (self) {
        self.viewModel = [WKMomentShareUserListVM new];
    }
    return self;
}

- (void)viewDidLoad {
    self.viewModel.privacyUids = self.privacyUids;
    [super viewDidLoad];
    
    if(self.privacyType) {
        if([self.privacyType isEqualToString:@"internal"]) {
            self.title = LLang(@"可见的朋友");
        }else if([self.privacyType isEqualToString:@"prohibit"]) {
            self.title = LLang(@"不可见的朋友");
        }
    }
    
    
    
}




@end
