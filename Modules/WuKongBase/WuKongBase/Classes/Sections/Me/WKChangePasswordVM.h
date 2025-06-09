//
//  WKChangePasswordVM.h
//  WuKongBase
//
//  Created by YY1688 on 2025/6/9.
//

#import <WuKongBase/WuKongBase.h>

NS_ASSUME_NONNULL_BEGIN

@interface WKChangePasswordVM : WKBaseVM

/// 修改密码
/// - Parameters:
///   - newPassword: 新密码
///   - oldPassword: 旧密码
- (AnyPromise *)setNewPwd:(NSString *)newPassword oldPassword:(NSString *)oldPassword;

@end

NS_ASSUME_NONNULL_END
