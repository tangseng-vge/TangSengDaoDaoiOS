//
//  WKCircleProgressView.h
//  WuKongFile
//
//  Created by tt on 2020/7/16.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface WKCircleProgressView : UIView

@property (nonatomic, assign) CGFloat progress;

//进度条颜色
@property(nonatomic,strong) UIColor *progerssColor;
//进度条背景颜色
@property(nonatomic,strong) UIColor *progerssBackgroundColor;
//进度条的宽度
@property(nonatomic,assign) CGFloat progerWidth;
//进度数据字体大小
@property(nonatomic,assign)CGFloat percentageFontSize;
//进度数字颜色
@property(nonatomic,strong) UIColor *percentFontColor;

// 隐藏进度条数字
@property(nonatomic,assign) BOOL hiddenPercentage;


@end

NS_ASSUME_NONNULL_END
