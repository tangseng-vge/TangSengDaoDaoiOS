//
//  WKMomentPublishInputCell.m
//  WuKongMoment
//
//  Created by tt on 2020/11/12.
//

#import "WKMomentPublishInputCell.h"
#import <WuKongBase/UITextView+WKPlaceholder.h>
@implementation WKMomentPublishInputModel

- (Class)cell {
    return WKMomentPublishInputCell.class;
}

- (NSString *)placeholder {
    if(!_placeholder) {
        return LLang(@"这一刻的想法...");
    }
    return _placeholder;
}

@end

@interface WKMomentPublishInputCell ()<UITextViewDelegate>

@property(nonatomic,strong) UITextView *contentTextView;
@property(nonatomic,strong) WKMomentPublishInputModel *model;

@end

@implementation WKMomentPublishInputCell

+ (CGSize)sizeForModel:(WKFormItemModel *)model {
    return CGSizeMake(WKScreenWidth, 90.0f);
}

- (void)setupUI {
    [super setupUI];
    
    [self.contentView addSubview:self.contentTextView];
}

- (void)refresh:(WKMomentPublishInputModel *)model {
    [super refresh:model];
    self.model = model;
    self.contentTextView.placeholder = model.placeholder;
    
    self.backgroundColor = [WKApp shared].config.cellBackgroundColor;
    self.contentTextView.backgroundColor = [WKApp shared].config.cellBackgroundColor;
    
    
}

- (void)layoutSubviews {
    [super layoutSubviews];
   
    self.contentTextView.lim_left = 20.0f;
    self.contentTextView.lim_width = self.lim_width - self.contentTextView.lim_left*2.0f;
    self.contentTextView.lim_height = self.lim_height;
}

- (UITextView *)contentTextView {
    if(!_contentTextView) {
        _contentTextView = [[UITextView alloc] init];
        _contentTextView.font = [[WKApp shared].config appFontOfSize:16.0f];
        _contentTextView.placeholderTextView.font = [[WKApp shared].config appFontOfSize:16.0f];
        _contentTextView.delegate = self;
    }
    return _contentTextView;
}


- (void)textViewDidChange:(UITextView *)textView {
    if(self.model.onChange) {
        self.model.onChange(textView.text,textView);
    }
}

@end
