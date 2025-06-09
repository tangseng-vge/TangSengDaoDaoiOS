//
//  WKChangePasswordVC.m
//  WuKongBase
//
//  Created by YY1688 on 2025/6/9.
//

#import "WKChangePasswordVC.h"
#import "WKChangePasswordVM.h"

@interface WKChangePasswordVC () <UITextFieldDelegate>


@property(nonatomic,strong) UIImageView *bgImgView; // 背景图

// ----------  旧密码相关 ----------
@property(nonatomic,strong) UIView *oldPasswordView; // 旧密码的box view
@property(nonatomic,strong) UIView *oldPasswordSpliteLineView; // 分割线
@property(nonatomic,strong) UITextField *oldPasswordTextField; // 旧密码
@property(nonatomic,strong) UIView *oldPasswordBottomLineView; // 旧密码底部输入线

// ---------- 密码输入相关 ----------
@property(nonatomic,strong) UIView *passwordBoxView; // 密码输入的box view
@property(nonatomic,strong) UIView *passwordBottomLineView; // 密码底部输入线
@property(nonatomic,strong) UITextField *passwordTextField; // 密码输入
@property(nonatomic,strong) UIButton *eyeBtn; // 眼睛关闭

// ---------- 确认密码输入相关 ----------
@property(nonatomic,strong) UIView *confirmPasswordBoxView; // 密码输入的box view
@property(nonatomic,strong) UIView *confirmPasswordBottomLineView; // 密码底部输入线
@property(nonatomic,strong) UITextField *confirmPasswordTextField; // 密码输入
@property(nonatomic,strong) UIButton *comfirEyeBtn; // 眼睛关闭


// ---------- 底部相关 ----------
@property(nonatomic,strong) UIButton *confirmBtn; // 注册按钮


@end

@implementation WKChangePasswordVC

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.viewModel = [WKChangePasswordVM new];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = LLang(@"修改密码");
    [self.view addSubview:self.bgImgView];
//    [self.view addSubview:self.titleLbl];
    
    [self.view addSubview:self.oldPasswordView];
    [self.oldPasswordView addSubview:self.oldPasswordSpliteLineView];
    [self.oldPasswordView addSubview:self.oldPasswordTextField];
    [self.oldPasswordView addSubview:self.oldPasswordBottomLineView];
    
    [self.view addSubview:self.passwordBoxView];
    [self.passwordBoxView addSubview:self.passwordBottomLineView];
    [self.passwordBoxView addSubview:self.passwordTextField];
    [self.passwordBoxView addSubview:self.eyeBtn];
    
    [self.view addSubview:self.confirmPasswordBoxView];
    [self.confirmPasswordBoxView addSubview:self.confirmPasswordBottomLineView];
    [self.confirmPasswordBoxView addSubview:self.confirmPasswordTextField];
    [self.confirmPasswordBoxView addSubview:self.comfirEyeBtn];
    
    [self.view addSubview:self.confirmBtn];
        
}

- (NSString *)langTitle {
    return LLang(@"修改密码");
}

- (WKBaseVM *)viewModel {
    return [WKChangePasswordVM new];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}


#pragma mark -- 视图初始化

// ---------- 背景图片 ----------
- (UIImageView *)bgImgView {
    if(!_bgImgView) {
        _bgImgView = [[UIImageView alloc] initWithImage:[[WKApp shared] loadImage:@"Background" moduleID:@"WuKongLogin"]];
        _bgImgView.frame = [self visibleRect];
    }
    return _bgImgView;
}

// ---------- 旧密码 ----------

- (UIView *)oldPasswordView {
    if(!_oldPasswordView) {
        _oldPasswordView = [[UIView alloc] initWithFrame:CGRectMake(0, 190.0f, WKScreenWidth, 40.0f)];
    }
    return _oldPasswordView;
}

- (UIView *)oldPasswordSpliteLineView {
    if(!_oldPasswordSpliteLineView) {
        _oldPasswordSpliteLineView = [[UIView alloc] initWithFrame:CGRectMake(20.0f,self.oldPasswordView.lim_height/2.0f - 5.0f,1,10)];
        _oldPasswordSpliteLineView.layer.backgroundColor = [WKApp shared].config.lineColor.CGColor;
       
    }
    return _oldPasswordSpliteLineView;
}

-(UITextField*) oldPasswordTextField {
    if(!_oldPasswordTextField) {
//        CGFloat left =self.countrySpliteLineView.lim_right+20.0f;
        CGFloat left = 20.0f;
        _oldPasswordTextField = [[UITextField alloc] initWithFrame:CGRectMake(left, self.oldPasswordView.lim_height/2.0f - 20.0f, WKScreenWidth - left - 20.0f, 40.0f)];
//        _mobileTextField.placeholder = LLang(@"请输入手机号");
        _oldPasswordTextField.placeholder = LLang(@"请输入密码");
        _passwordTextField.returnKeyType = UIReturnKeyDone;
        _passwordTextField.secureTextEntry = YES;
        _passwordTextField.delegate = self;
        _oldPasswordTextField.delegate = self;
    }
    return _oldPasswordTextField;
}

- (UIView *)oldPasswordBottomLineView {
    if(!_oldPasswordBottomLineView) {
        _oldPasswordBottomLineView = [[UIView alloc] initWithFrame:CGRectMake(20.0f, self.oldPasswordView.lim_height, WKScreenWidth-40.0f, 1)];
        _oldPasswordBottomLineView.layer.backgroundColor = [WKApp shared].config.lineColor.CGColor;
    }
    return _oldPasswordBottomLineView;
}

// ---------- 密码输入 ----------

- (UIView *)passwordBoxView {
    if(!_passwordBoxView) {
        _passwordBoxView = [[UIView alloc] initWithFrame:CGRectMake(0, self.oldPasswordView.lim_bottom+20.0f, WKScreenWidth, self.oldPasswordView.lim_height)];
//        [_passwordBoxView setBackgroundColor:[UIColor greenColor]];
    }
    return _passwordBoxView;
}
- (UIView *)passwordBottomLineView {
    if(!_passwordBottomLineView) {
        _passwordBottomLineView = [[UIView alloc] initWithFrame:CGRectMake(20.0f, self.passwordBoxView.lim_height, WKScreenWidth-40.0f, 1)];
        _passwordBottomLineView.layer.backgroundColor = [WKApp shared].config.lineColor.CGColor;
    }
    return _passwordBottomLineView;
}

- (UITextField *)passwordTextField {
    if(!_passwordTextField) {
        _passwordTextField = [[UITextField alloc] initWithFrame:CGRectMake(20.0f, self.oldPasswordView.lim_height/2.0f - 20.0f, WKScreenWidth-20*2 - 32.0f, 40.0f)];
        [_passwordTextField setPlaceholder:LLang(@"请输入新密码")];
        _passwordTextField.returnKeyType = UIReturnKeyDone;
        _passwordTextField.secureTextEntry = YES;
        _passwordTextField.delegate = self;
        
    }
    return _passwordTextField;
}
- (UIButton *)eyeBtn {
    if(!_eyeBtn) {
        CGFloat width = 32.0f;
        CGFloat height = 32.0f;
        _eyeBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.view.lim_width - 20.0f - width, self.passwordBoxView.lim_height/2.0f - (height)/2.0f, width, height)];
        [_eyeBtn setImage:[[WKApp shared] loadImage:@"BtnEyeOff" moduleID:@"WuKongLogin"] forState:UIControlStateNormal];
        [_eyeBtn setImage:[[WKApp shared] loadImage:@"BtnEyeOn" moduleID:@"WuKongLogin"] forState:UIControlStateSelected];
        _eyeBtn.imageView.contentMode = UIViewContentModeScaleAspectFit;
        [_eyeBtn setImageEdgeInsets:UIEdgeInsetsMake(height/4.0f, width, height/4.0f,  width)];
        [_eyeBtn addTarget:self action:@selector(passwordLookPressed:) forControlEvents:UIControlEventTouchUpInside];
       // [_eyeBtn setBackgroundColor:[UIColor redColor]];
        _eyeBtn.hidden = YES;
    }
    return _eyeBtn;
}

// ---------- 确认密码输入 ----------

- (UIView *)confirmPasswordBoxView {
    if(!_confirmPasswordBoxView) {
        _confirmPasswordBoxView = [[UIView alloc] initWithFrame:CGRectMake(0, self.passwordBoxView.lim_bottom+20.0f, WKScreenWidth, self.passwordBoxView.lim_height)];
//        [_confirmPasswordBoxView setBackgroundColor:[UIColor grayColor]];
    }
    return _confirmPasswordBoxView;
}
- (UIView *)confirmPasswordBottomLineView {
    if(!_confirmPasswordBottomLineView) {
        _confirmPasswordBottomLineView = [[UIView alloc] initWithFrame:CGRectMake(20.0f, self.confirmPasswordBoxView.lim_height, WKScreenWidth-40.0f, 1)];
        _confirmPasswordBottomLineView.layer.backgroundColor = [WKApp shared].config.lineColor.CGColor;
    }
    return _confirmPasswordBottomLineView;
}

- (UITextField *)confirmPasswordTextField {
    if(!_confirmPasswordTextField) {
        _confirmPasswordTextField = [[UITextField alloc] initWithFrame:CGRectMake(20.0f, self.passwordBoxView.lim_height/2.0f - 20.0f, WKScreenWidth-20*2 - 32.0f, 40.0f)];
        [_confirmPasswordTextField setPlaceholder:LLang(@"请确认新密码")];
        _confirmPasswordTextField.returnKeyType = UIReturnKeyDone;
        _confirmPasswordTextField.secureTextEntry = YES;
        _confirmPasswordTextField.delegate = self;
        
    }
    return _confirmPasswordTextField;
}
- (UIButton *)comfirEyeBtn {
    if(!_comfirEyeBtn) {
        CGFloat width = 32.0f;
        CGFloat height = 32.0f;
        _comfirEyeBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.view.lim_width - 20.0f - width, self.confirmPasswordBoxView.lim_height/2.0f - (height)/2.0f, width, height)];
        [_comfirEyeBtn setImage:[[WKApp shared] loadImage:@"BtnEyeOff" moduleID:@"WuKongLogin"] forState:UIControlStateNormal];
        [_comfirEyeBtn setImage:[[WKApp shared] loadImage:@"BtnEyeOn" moduleID:@"WuKongLogin"] forState:UIControlStateSelected];
        _comfirEyeBtn.imageView.contentMode = UIViewContentModeScaleAspectFit;
        [_comfirEyeBtn setImageEdgeInsets:UIEdgeInsetsMake(height/4.0f, width, height/4.0f,  width)];
        [_comfirEyeBtn addTarget:self action:@selector(passwordLookPressed:) forControlEvents:UIControlEventTouchUpInside];
       // [_comfirEyeBtn setBackgroundColor:[UIColor redColor]];
        _comfirEyeBtn.hidden = YES;
    }
    return _comfirEyeBtn;
}

// ---------- 底部相关 ----------


// 确认
- (UIButton *)confirmBtn {
    if(!_confirmBtn) {
        CGFloat top = self.confirmPasswordBoxView.lim_bottom;
        
        _confirmBtn = [[UIButton alloc] initWithFrame:CGRectMake(30.0f,top+82.0f, WKScreenWidth - 60.0f, 40.0f)];
        [_confirmBtn setBackgroundColor:[WKApp shared].config.themeColor];
        [_confirmBtn setTitle:LLang(@"确认") forState:UIControlStateNormal];
        [_confirmBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _confirmBtn.layer.masksToBounds = YES;
        _confirmBtn.layer.cornerRadius = 4.0f;
        [_confirmBtn addTarget:self action:@selector(registerBtnPressed) forControlEvents:UIControlEventTouchUpInside];
        
        [WKApp.shared.config setThemeStyleButton:_confirmBtn];
        
    }
    return _confirmBtn;
}

#pragma mark - 事件
// 跳到注册页面
-(void) toLoginPressed{
    [[WKNavigationManager shared] popViewControllerAnimated:YES];
}

// 密码那个小眼睛点击
-(void) passwordLookPressed:(UIButton*)btn {
    btn.selected = !btn.selected;
    _passwordTextField.secureTextEntry = !btn.selected;
}

-(void) registerBtnPressed {
    
    NSString *oldPassword = self.oldPasswordTextField.text;
    NSString *newPassword = self.passwordTextField.text;
    NSString *confirmPassword = self.confirmPasswordTextField.text;
    
    if (![newPassword isEqualToString:confirmPassword]) {
        [self.view showHUDWithHide:LLang(@"两次密码输入不一致！")];
        return;
    }

    [self.view showHUD:LLang(@"修改中")];
    __weak typeof(self) weakSelf = self;
        
    [self.viewModel setNewPwd:confirmPassword oldPassword:oldPassword].then(^{
        [weakSelf.view hideHud];
        [weakSelf.view switchHUDSuccess:@"密码修改成功"];
//        weakSelf.oldPasswordTextField.text = @"";
//        weakSelf.passwordTextField.text = @"";
//        weakSelf.confirmPasswordTextField.text = @"";
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [[WKNavigationManager shared] popViewControllerAnimated:YES];
        });
    }).catch(^(NSError *error){
        [weakSelf.view switchHUDError:error.domain];
    });
}

#pragma mark -- 委托
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    return true;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if(_passwordTextField == textField) {
       
    }
    return YES;
}
- (void)dealloc {
    
}



@end
