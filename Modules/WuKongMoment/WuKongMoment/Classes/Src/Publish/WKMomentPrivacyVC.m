//
//  WKMomentPrivacyVC.m
//  WuKongMoment
//
//  Created by tt on 2020/11/13.
//

#import "WKMomentPrivacyVC.h"

@interface WKMomentPrivacyVC ()




@end

@implementation WKMomentPrivacyVC

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.viewModel = [WKMomentPrivacyVM new];
    }
    return self;
}

- (void)viewDidLoad {
    
    self.viewModel.momentPrivacySelect = self.momentPrivacySelect;
    
    [super viewDidLoad];

    
    [self.finishBtn addTarget:self action:@selector(finishPressed) forControlEvents:UIControlEventTouchUpInside];
    self.rightView = self.finishBtn;
   
}

- (NSString *)langTitle {
    return LLang(@"谁可以看");
}


-(void) finishPressed {
    WKMomentPrivacySelect *privacySelect = self.viewModel.momentPrivacySelect;
    if([privacySelect.privacyKey isEqualToString:@"internal"] || [privacySelect.privacyKey isEqualToString:@"prohibit"]) {
        if(privacySelect.privacyUIDS.count == 0 && privacySelect.labelIDs.count == 0) {
            [self.view showHUDWithHide:LLang(@"请选择至少一个标签。")];
            return;
        }
    }
    [[WKNavigationManager shared] popViewControllerAnimated:YES];
    if(self.onFinish) {
        self.viewModel.momentPrivacySelect.displayName = [self.viewModel selectItemName];
        self.viewModel.momentPrivacySelect.labelUIDs = [self.viewModel labelUIDs];
        self.onFinish(privacySelect);
    }
}



@end

