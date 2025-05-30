//
//  WKBurnAfterReadingSelectCell.m
//  WuKongAdvanced
//
//  Created by tt on 2022/8/15.
//

#import "WKBurnAfterReadingSelectCell.h"

@implementation WKBurnAfterReadingSelectCellModel

- (Class)cell {
    return WKBurnAfterReadingSelectCell.class;
}

- (CGFloat)cellHeight {
    return 60.0f;
}

@end

@interface WKBurnAfterReadingSelectCell ()

@property(nonatomic,strong) UISlider *slider;
@property(nonatomic,strong) UILabel *titleLbl;
@property(nonatomic,strong) UIImageView *iconImgView;

@property(nonatomic,strong) WKBurnAfterReadingSelectCellModel *cellModel;

@end

@implementation WKBurnAfterReadingSelectCell

- (void)setupUI {
    [super setupUI];
    
    [self.contentView addSubview:self.iconImgView];
    [self.contentView addSubview:self.titleLbl];
    [self.contentView addSubview:self.slider];
}

- (void)refresh:(WKBurnAfterReadingSelectCellModel *)model {
    [super refresh:model];
    self.cellModel = model;
    
    
    self.titleLbl.text = [self formatTip:model.flameSecond];
    [self.titleLbl sizeToFit];
    
    [self.slider setValue:[self flameSecondToProgress:model.flameSecond] animated:YES];

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

-(void) progressChange:(UISlider*)slider forEvent:(UIEvent*)event{
    UITouch *touchEvent = event.allTouches.allObjects[0];
    if(touchEvent.phase!=UITouchPhaseEnded) {
        return;
    }
    NSInteger value = slider.value;
    
    if(self.cellModel.valueChange) {
        self.cellModel.valueChange([self progressToFlameSecond:value]);
    }
}

-(NSString*) formatSecond:(NSInteger)second {
    if(second<60) {
        return  [NSString stringWithFormat:LLang(@"%ld秒"),second];
    }
    return [NSString stringWithFormat:LLang(@"%ld分钟"),second/60];
    
}

-(NSString*) formatTip:(NSInteger)second {
    if(second<=0) {
        return LLang(@"退出聊天后，已读消息自动销毁");
    }
    return [NSString stringWithFormat:LLang(@"消息阅读后%@自动销毁"),[self formatSecond:second]];
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

- (UILabel *)titleLbl {
    if(!_titleLbl) {
        _titleLbl = [[UILabel alloc] init];
        _titleLbl.font = [WKApp.shared.config appFontOfSize:14.0f];
    }
    return _titleLbl;
}

- (UIImageView *)iconImgView {
    if(!_iconImgView) {
        _iconImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 12.0f, 17.0f)];
        UIImage *icon = [self imageName:@"Conversation/Setting/SecretMediaIcon"];
        _iconImgView.image =  [WKGenerateImageUtils generateTintedImgWithImage:icon color:WKApp.shared.config.defaultTextColor backgroundColor:nil];
    }
    return _iconImgView;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.iconImgView.lim_left = 15.0f;
    self.iconImgView.lim_top = 0.0f;
    
    self.titleLbl.lim_left = self.iconImgView.lim_right + 5.0f;
    self.titleLbl.lim_top = self.iconImgView.lim_top;
    
    self.slider.lim_left = 15.0f;
    self.slider.lim_top = self.titleLbl.lim_bottom + 5.0f;
    self.slider.lim_width = self.lim_width - self.slider.lim_left*2.0f;
    
}
-(UIImage*) imageName:(NSString*)name {
    return [[WKApp shared] loadImage:name moduleID:@"WuKongAdvanced"];
}


@end
