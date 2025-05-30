//
//  WKFlameSettingView.m
//  WuKongAdvanced
//
//  Created by tt on 2022/8/19.
//

#import "WKFlameSettingView.h"


@interface WKFlameSettingView ()

@property(nonatomic,strong) UIImageView *flameIconImgView;
@property(nonatomic,strong) UILabel *tipLbl;
@property(nonatomic,strong) UISlider *slider;
@property(nonatomic,strong) UISwitch *flameSwitch;

@end

@implementation WKFlameSettingView

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.frame = CGRectMake(0.0f, 0.0f, WKScreenWidth, 80.0f);
        
        [self addSubview:self.flameIconImgView];
        [self addSubview:self.tipLbl];
        [self addSubview:self.slider];
        [self addSubview:self.flameSwitch];
    }
    return self;
}

- (void)setChannel:(WKChannel *)channel {
    _channel = channel;
    
   WKChannelInfo *channelInfo = [WKSDK.shared.channelManager getChannelInfo:channel];
    if(!channelInfo) {
        return;
    }
    self.tipLbl.text = [self formatTip:channelInfo.flameSecond];
    [self.tipLbl sizeToFit];
    
    self.flameSwitch.on = channelInfo.flame;
    self.slider.value = [self flameSecondToProgress:channelInfo.flameSecond];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat topSpace = 10.0f;
    
    self.flameIconImgView.lim_left = topSpace;
    self.flameIconImgView.lim_top = topSpace;
    
    self.tipLbl.lim_left = self.flameIconImgView.lim_right +  topSpace;
    self.tipLbl.lim_top = topSpace;
    
    self.flameSwitch.lim_left = self.lim_width - self.flameSwitch.lim_width - 10.0f;
    self.flameSwitch.lim_top = 40.0f;
    
    self.slider.lim_left =  topSpace;
    self.slider.lim_width = self.flameSwitch.lim_left - topSpace*2;
    self.slider.lim_top = self.tipLbl.lim_bottom + topSpace;
    
    
}

- (UIImageView *)flameIconImgView {
    if(!_flameIconImgView) {
        _flameIconImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 12.0f, 17.0f)];
        [_flameIconImgView setImage:[self imageName:@"Conversation/Setting/SecretMediaIcon"]];
    }
    return _flameIconImgView;
}

- (UILabel *)tipLbl {
    if(!_tipLbl) {
        _tipLbl = [[UILabel alloc] init];
        [_tipLbl setFont:[WKApp.shared.config appFontOfSize:14.0f]];
        
    }
    return _tipLbl;
}

- (UISlider *)slider {
    if(!_slider) {
        _slider = [[UISlider alloc] init];
        _slider.minimumValue = 0;
        _slider.maximumValue = 6;
//        _slider.lim_height = 8.0f;
        [_slider addTarget:self action:@selector(progressChange:forEvent:) forControlEvents:UIControlEventValueChanged];
    }
    return _slider;
}

- (UISwitch *)flameSwitch {
    if(!_flameSwitch) {
        _flameSwitch = [[UISwitch alloc] init];
        [_flameSwitch setOnTintColor:WKApp.shared.config.themeColor];
        [_flameSwitch addTarget:self action:@selector(flameSwitchPressed:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _flameSwitch;
}

-(void) flameSwitchPressed:(UISwitch*)sw {
    if(self.onSwitch) {
        self.onSwitch(sw.on);
    }
}

-(void) progressChange:(UISlider*)slider forEvent:(UIEvent*)event{
    UITouch *touchEvent = event.allTouches.allObjects[0];
    if(touchEvent.phase!=UITouchPhaseEnded) {
        return;
    }
    NSInteger value = slider.value;
    
    self.tipLbl.text = [self formatTip:[self progressToFlameSecond:value]];
    [self.tipLbl sizeToFit];
    
    [[WKChannelSettingManager shared] channel:self.channel flameSecond:[self progressToFlameSecond:value]];
    
}


-(NSString*) formatTip:(NSInteger)second {
    if(second<=0) {
        return LLang(@"退出聊天后，已读消息自动销毁");
    }
    return [NSString stringWithFormat:LLang(@"消息阅读后%@自动销毁"),[self formatSecond:second]];
}

-(NSString*) formatSecond:(NSInteger)second {
    if(second<60) {
        return  [NSString stringWithFormat:LLang(@"%ld秒"),second];
    }
    return [NSString stringWithFormat:LLang(@"%ld分钟"),second/60];
    
}

-(NSInteger) flameSecondToProgress:(NSInteger)flameSecond {
    if(flameSecond > 0 && flameSecond < 60) {
        return flameSecond/10;
    }
    if(flameSecond == 60) {
        return 4;
    }
    if(flameSecond>60 && flameSecond <= 120) {
        return 5;
    }
    if(flameSecond >120 && flameSecond <= 180) {
        return 6;
    }
    return 0;
}

-(NSInteger) progressToFlameSecond:(NSInteger)progress {
    if(progress>0 && progress <=3) {
        return progress*10;
    }
    if(progress == 4) {
        return 60;
    }
    if(progress == 5) {
        return 120;
    }
    if(progress >= 6) {
        return 180;
    }
    return 0;
}
-(UIImage*) imageName:(NSString*)name {
    return [[WKApp shared] loadImage:name moduleID:@"WuKongAdvanced"];
}

@end
