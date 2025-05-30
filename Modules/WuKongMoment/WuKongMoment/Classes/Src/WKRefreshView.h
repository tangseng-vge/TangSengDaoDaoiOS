//
//  WKRefreshView.h
//  WuKongMoment
//
//  Created by tt on 2020/11/5.
//

#import <UIKit/UIKit.h>

typedef enum {
    LXWXRefreshViewStateNormal,
    LXWXRefreshViewStateWillRefresh,
    LXWXRefreshViewStateRefreshing,
} LXWXRefreshViewState;

NS_ASSUME_NONNULL_BEGIN

@interface WKRefreshView : UIView<CAAnimationDelegate>



+ (instancetype)refreshHeaderWithCenter:(CGPoint)center;

@property(nonatomic,strong)UIScrollView *scrollView;

@property (nonatomic, copy) void(^refreshingBlock)(void);

@property (nonatomic, assign) LXWXRefreshViewState refreshState;
- (void)endRefreshing;

@end

NS_ASSUME_NONNULL_END
