//
//  AppDelegate.m
//  TangSengDaoDao
//
//  Created by tt on 2019/11/30.
//  Copyright © 2019 xinbida. All rights reserved.
//

#import "AppDelegate.h"
#import <WuKongBase/WuKongBase.h>
#import "WKMainTabController.h"
@import WuKongContacts;
#import <WuKongBase/WKSyncService.h>
#import "WKMeVC.h"

#import "SELUpdateAlert.h"

#import "TangSengDaoDao-Bridging-Header.h"
#import "TangSengDaoDao-Swift.h"
#import "LLDynamicLaunchScreen.h"

#define SERVER_IP @"api.newhxchat.top/api" //@"api.botgate.cn" // xxx.xxx.xx.xx:8090
#define HTTPS_ON false // https开关


#define BASE_URL [NSString stringWithFormat:@"%@://%@/v1/",HTTPS_ON?@"https":@"http",SERVER_IP]
#define WEB_URL [NSString stringWithFormat:@"%@://%@/web/",HTTPS_ON?@"https":@"http",SERVER_IP]
// api基地址
#define API_BASE_URL  BASE_URL
// 文件基地址
#define FILE_BASE_URL BASE_URL
// 文件预览地址
#define FILE_BROWSE_URL BASE_URL
// 图片预览地址
#define IMAGE_BROWSE_URL BASE_URL

// 举报地址
#define REPORT_URL  [NSString stringWithFormat:@"%@://%@/web/report.html",HTTPS_ON?@"https":@"http",SERVER_IP]




@interface AppDelegate ()<UITabBarControllerDelegate>

@property(nonatomic,strong) WKConversationListVC *conversationList;
//@property(nonatomic,strong)  WKContactsVC *contactVC;
@property(nonatomic,strong) WKMeVC *meVC;


@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor grayColor];
    UIStoryboard *launchSB = [UIStoryboard storyboardWithName:@"LaunchScreen" bundle:nil];
        UIViewController *splashVC = [launchSB instantiateInitialViewController];
    self.window.rootViewController = splashVC;
    [self.window makeKeyAndVisible];
    
    // 获取客户端真实ip
    [WKIPCheckManager.shared getAPIAddressWithCompletion:^(NSString * _Nullable apiAddress, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            // 4. 实例化真正的首页控制器（例：从 Main.storyboard）
            UIStoryboard *mainSB = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            UIViewController *mainVC = [mainSB instantiateInitialViewController];
            // 5. 做一个淡入淡出过渡动画
            [UIView transitionWithView:self.window
                              duration:0.4
                               options:UIViewAnimationOptionTransitionCrossDissolve
                            animations:^{
                if (error) {
                    [self initializeAppWithBaseUrl:nil];
                    return;
                }
                NSLog(@"apiAddress: %@", apiAddress);
                [self initializeAppWithBaseUrl:apiAddress];
                            }
                            completion:nil];
        });
        
    }];

    return YES;
}


- (void)initializeAppWithBaseUrl:(NSString *)baseUrl {
    // 加载登录信息
    [[WKApp shared].loginInfo load];
        
    NSString *apiBaseUrl = baseUrl ? [WKIPCheckManager wk_baseUrlWithUrl:baseUrl] : API_BASE_URL;
    NSString *fileBaseUrl = baseUrl ? [WKIPCheckManager wk_baseUrlWithUrl:baseUrl] : FILE_BASE_URL;
    NSString *fileBrowseUrl = baseUrl ? [WKIPCheckManager wk_baseUrlWithUrl:baseUrl] : FILE_BROWSE_URL;
    NSString *imageBrowseUrl = baseUrl ? [WKIPCheckManager wk_baseUrlWithUrl:baseUrl] : IMAGE_BROWSE_URL;
    NSString *webUrl = baseUrl ? [WKIPCheckManager wk_webUrlWithUrl:baseUrl] : WEB_URL;
    
    // app配置
    WKAppConfig *config = [WKAppConfig new];
    config.apiBaseUrl = apiBaseUrl; // api地址
    config.fileBaseUrl = fileBaseUrl; // 文件上传地址
    config.fileBrowseUrl = fileBrowseUrl; // 文件预览地址
    config.imageBrowseUrl = imageBrowseUrl; // 图片预览地址
    config.reportUrl = [NSString stringWithFormat:@"%@report/html",apiBaseUrl]; //举报地址
    config.privacyAgreementUrl = [NSString stringWithFormat:@"%@privacy_policy.html",webUrl]; //隐私协议
    config.userAgreementUrl = [NSString stringWithFormat:@"%@user_agreement.html",webUrl]; //用户协议
    [WKApp shared].config = config;
    
    // app首页设置
    [WKApp shared].getHomeViewController = ^UIViewController * _Nonnull{
        WKMainTabController *homeViewController =  [WKMainTabController new];
        return homeViewController;
    };
    
    
    // app初始化
    [[WKApp shared] appInit];
    
    if (@available(iOS 13.0, *)) {
        if([WKApp shared].config.style == WKSystemStyleDark) {
            self.window.overrideUserInterfaceStyle = UIUserInterfaceStyleDark;
        }else{
            self.window.overrideUserInterfaceStyle = UIUserInterfaceStyleLight;
        }
    }
}

-(void) applicationWillEnterForeground:(UIApplication *)application {
    NSInteger lastCheckUpdateTime = [[NSUserDefaults standardUserDefaults] integerForKey:@"lastCheckUpdateTime"];
    if(lastCheckUpdateTime == 0) {
        [self checkAppVersionOrUpdate];
    }else if ([[NSDate date] timeIntervalSince1970] - lastCheckUpdateTime > 60.0f * 30.0f){
        [self checkAppVersionOrUpdate];
    }
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    NSLog(@"内存警告");
}

-(void) checkAppVersionOrUpdate {
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *appVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    [[WKAPIClient sharedClient] GET:[NSString stringWithFormat:@"common/appversion/iOS/%@",appVersion] parameters:nil].then(^(NSDictionary *resultDict){
        [[NSUserDefaults standardUserDefaults] setInteger:[[NSDate date] timeIntervalSince1970] forKey:@"lastCheckUpdateTime"];
        NSString *version = resultDict[@"app_version"];
        if(!version||[version isEqualToString:@""]) {
            [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"lastAlertUpdateTime"];
            return;
        }
        
        if([self versionStrToInt:version]>[self versionStrToInt:appVersion]) {
            NSString  *updateDesc = resultDict[@"update_desc"];
            BOOL isForce = resultDict[@"is_force"]?[resultDict[@"is_force"] boolValue]:false;
            NSString *downloadURL = resultDict[@"download_url"];
            
            [SELUpdateAlert showUpdateAlertWithVersion:resultDict[@"app_version"] Description:updateDesc downloadURL:downloadURL forceUpdate:isForce];
        }
      
    });
}

-(NSInteger) versionStrToInt:(NSString*)versionStr {
    return [[versionStr stringByReplacingOccurrencesOfString:@"." withString:@""] integerValue];;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    if (!deviceToken || ![deviceToken isKindOfClass:[NSData class]] || deviceToken.length==0) {
        return;
    }
    NSString *(^getDeviceToken)(void) = ^() {
            if (@available(iOS 13.0, *)) {
                const unsigned char *dataBuffer = (const unsigned char *)deviceToken.bytes;
                NSMutableString *myToken  = [NSMutableString stringWithCapacity:(deviceToken.length * 2)];
                for (int i = 0; i < deviceToken.length; i++) {
                    [myToken appendFormat:@"%02x", dataBuffer[i]];
                }
                return (NSString *)[myToken copy];
            } else {
                NSCharacterSet *characterSet = [NSCharacterSet characterSetWithCharactersInString:@"<>"];
                NSString *myToken = [[deviceToken description] stringByTrimmingCharactersInSet:characterSet];
                return [myToken stringByReplacingOccurrencesOfString:@" " withString:@""];
            }
        };
    NSString *myToken = getDeviceToken();
    NSLog(@"myToken----------->%@",myToken);
    [WKApp shared].loginInfo.deviceToken = myToken;
    [[WKApp shared].loginInfo save];
   NSString *bundleID = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
    [[WKAPIClient sharedClient] POST:@"user/device_token" parameters:@{@"device_token":myToken,@"device_type":@"IOS",@"bundle_id":bundleID}].catch(^(NSError *error){
        WKLogError(@"上传设备token失败！-> %@",error);
    });
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    NSLog(@"didReceiveRemoteNotification------>");
    [WKApp.shared application:application didReceiveRemoteNotification:userInfo fetchCompletionHandler:completionHandler];
}


- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    WKLogError(@"注册远程通知失败->%@",error);
}
- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
    
    return [[WKApp shared] appOpenURL:url options:options];
}

- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray<id<UIUserActivityRestoring>> * _Nullable))restorationHandler {
    
    return [[WKApp shared] appContinueUserActivity:userActivity restorationHandler:restorationHandler];
}

@end



