//
//  WKChangePasswordVM.m
//  WuKongBase
//
//  Created by YY1688 on 2025/6/9.
//

#import "WKChangePasswordVM.h"

@implementation WKChangePasswordVM

- (AnyPromise *)setNewPwd:(NSString *)newPassword oldPassword:(NSString *)oldPassword {
    return [[WKAPIClient sharedClient] PUT:@"user/updatepassword" parameters:@{@"password":oldPassword,@"new_password":newPassword}];
}

@end
