//
//  WKMainTabController.m
//  TangSengDaoDao
//
//  Created by tt on 2019/12/7.
//  Copyright © 2019 xinbida. All rights reserved.
//

#import "WKMainTabController.h"
#import <WuKongBase/WuKongBase.h>
#import <Lottie/Lottie.h>
#import "WKConversationListVC.h"
#import "WKContactsVC.h"
#import "WKMeVC.h"
#import "UIColor+WK.h"
@interface WKMainTabController ()<UITabBarControllerDelegate>

@property(nonatomic,strong) LOTAnimationView *currentLOTAnimationView;

@end

@implementation WKMainTabController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.delegate = self;
    // Do any additional setup after loading the view.
    [self.tabBar setBarTintColor:[UIColor whiteColor]];
    
    [[UITabBar appearance] setShadowImage:[[UIImage alloc]init]];
    [[UITabBar appearance] setBackgroundImage:[[UIImage alloc]init]];
    if (@available(iOS 13.0, *)) {
        [self.tabBar setBarTintColor:[UIColor systemBackgroundColor]];
        [self.tabBar setBackgroundColor:[UIColor systemBackgroundColor]];
    } else {
        [self.tabBar setBarTintColor:[UIColor whiteColor]];
        [self.tabBar setBackgroundColor:[UIColor whiteColor]];
    }
   
    [self setupChildVC:WKConversationListVC.class title:NSLocalizedString(@"聊天", nil) andImage:@"HomeTab" andSelectImage:@"HomeTabSelected"];
    [self setupChildVC:WKContactsVC.class title:NSLocalizedString(@"联系人", nil) andImage:@"ContactsTab" andSelectImage:@"ContactsTabSelected"];
    [self setupChildVC:WKMeVC.class title:NSLocalizedString(@"我的", nil) andImage:@"MeTab" andSelectImage:@"MeTabSelected"];

}

- (void)setupChildVC:(Class)vc title:(NSString *)title andImage:(NSString * )image andSelectImage:(NSString *)selectImage{
    
    UIViewController * vcInstall = [[vc alloc] init];
    //VC.view.backgroundColor = UIColor.whiteColor;
    [vcInstall.tabBarItem setTitleTextAttributes:@{
        NSForegroundColorAttributeName: [UIColor colorWithRed:223/255.0 green:107/255.0 blue:78/255.0 alpha:0.5],
        NSFontAttributeName: [UIFont systemFontOfSize:12.0]
    } forState:UIControlStateNormal];

    [vcInstall.tabBarItem setTitleTextAttributes:@{
        NSForegroundColorAttributeName: [UIColor colorWithRed:223/255.0 green:107/255.0 blue:78/255.0 alpha:1.0],
        NSFontAttributeName: [UIFont boldSystemFontOfSize:12.0]
    } forState:UIControlStateSelected];
    
    vcInstall.tabBarItem.title = title;
    vcInstall.tabBarItem.image = [[UIImage imageNamed:image]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    vcInstall.tabBarItem.selectedImage = [[UIImage imageNamed:selectImage]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    vcInstall.tabBarItem.imageInsets = UIEdgeInsetsMake(6, 0, 0, 0);
    [self addChildViewController:vcInstall];
}

-(void) dealloc {
    WKLogDebug(@"WKMainTabController dealloc");
}

#pragma mark - UITabBarControllerDelegate

static UIImpactFeedbackGenerator *impactFeedBack;
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
    
    if(!impactFeedBack) {
        impactFeedBack = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleLight];
    }
    [impactFeedBack prepare];
    [impactFeedBack impactOccurred];
}

@end
