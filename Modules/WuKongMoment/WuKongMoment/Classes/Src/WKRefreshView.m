//
//  WKRefreshView.m
//  WuKongMoment
//
//  Created by tt on 2020/11/5.
//

#import "WKRefreshView.h"
#import "WKMomentConst.h"
#import "WKMomentModule.h"

NSString *const ObserveKeyPath = @"contentOffset";
static const CGFloat contentOffetY = -100.f;
NSString *const  AnimationKey =@"animationKey";
NSString *const  PositionKey =@"position";
NSString *const  PositionShowKey =@"positionShow";

static const CGFloat originY = -80.f;

@interface WKRefreshView ()

@property(nonatomic,assign) CGPoint originCenter;

@end

@implementation WKRefreshView
{
    CABasicAnimation *_rotateAnimation;
}
+ (instancetype)refreshHeaderWithCenter:(CGPoint)center
{
    
    WKRefreshView *refreshView = [WKRefreshView new];
    refreshView.originCenter = center;
    refreshView.center = center;
    refreshView.lim_top = originY;
    refreshView.hidden = YES;
    return refreshView;
}
- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setupView];
    }
    return self;
}
- (void)setupView
{
    self.backgroundColor = [UIColor clearColor];
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[self imageName:@"RefreshDynamic"]];
    imageView.lim_size = CGSizeMake(24.0f, 24.0f);
    self.bounds = imageView.bounds;
    [self addSubview:imageView];
    
    _rotateAnimation = [[CABasicAnimation alloc] init];
    _rotateAnimation.keyPath = @"transform.rotation.z";
    _rotateAnimation.fromValue = @0;
    _rotateAnimation.toValue = @(M_PI * 2);
    _rotateAnimation.duration = 0.5;
    _rotateAnimation.repeatCount = MAXFLOAT;
    
}

- (void)setScrollView:(UIScrollView *)scrollView
{
    _scrollView = scrollView;
    
    [scrollView addObserver:self forKeyPath:ObserveKeyPath options:NSKeyValueObservingOptionNew context:nil];
}
- (void)willMoveToSuperview:(UIView *)newSuperview
{
    if (!newSuperview) {
        [self.scrollView removeObserver:self forKeyPath:ObserveKeyPath];
    }
}
- (void)endRefreshing
{
    self.refreshState = LXWXRefreshViewStateNormal;
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
   
    if (keyPath != ObserveKeyPath) return;
    
    [self updateRefreshHeaderWithOffsetY:self.scrollView.contentOffset.y+BIG_BACKGROUP_IMAGE_HEIGHT+[UIApplication sharedApplication].statusBarFrame.size.height];
}
- (void)updateRefreshHeaderWithOffsetY:(CGFloat)y
{
   
    CGFloat rotateValue = y / 47.0 * M_PI;
    if (y < contentOffetY) {
        y = contentOffetY;
        if (self.scrollView.isDragging && self.refreshState != LXWXRefreshViewStateWillRefresh) {
            self.refreshState = LXWXRefreshViewStateWillRefresh;
            NSLog(@"LXWXRefreshViewStateWillRefresh");
            
        } else if (!self.scrollView.isDragging && self.refreshState == LXWXRefreshViewStateWillRefresh) {
            self.refreshState = LXWXRefreshViewStateRefreshing;
            NSLog(@"LXWXRefreshViewStateRefreshing");
        }
    }
    
    if (self.refreshState == LXWXRefreshViewStateRefreshing) return;
    if(!self.scrollView.isDragging && self.refreshState == LXWXRefreshViewStateWillRefresh) {
        NSLog(@"LXWXRefreshViewStateNormal");
        self.hidden = YES;
        self.refreshState = LXWXRefreshViewStateNormal;
        return;
    }
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    transform = CGAffineTransformTranslate(transform, 0, -y);
    transform = CGAffineTransformRotate(transform, rotateValue);

    self.transform = transform;
    
}

- (void)setRefreshState:(LXWXRefreshViewState)refreshState
{
    _refreshState =  refreshState;

    if (refreshState  == LXWXRefreshViewStateWillRefresh) {
        
        self.hidden = NO;
        self.transform = CGAffineTransformIdentity;
        CABasicAnimation *basic =[CABasicAnimation animation];
        basic.keyPath = @"position";
        basic.fromValue =[NSValue valueWithCGPoint:self.center];
        basic.toValue = [NSValue valueWithCGPoint:CGPointMake(self.center.x, 80.0f)];
        basic.duration = 0.25;
        basic.delegate = self;
        basic.removedOnCompletion = NO;
        [basic setValue:PositionShowKey forKey:@"key"];
        basic.fillMode = kCAFillModeForwards;
        [self.layer addAnimation:basic forKey:PositionShowKey];
    }
    if (refreshState == LXWXRefreshViewStateRefreshing) {
        if (self.refreshingBlock) {
            self.refreshingBlock();
        }
        
        [self.layer addAnimation:_rotateAnimation forKey:AnimationKey];
    } else if (refreshState == LXWXRefreshViewStateNormal) {
        
        [self.layer removeAnimationForKey:AnimationKey];
        [self.layer removeAnimationForKey:PositionShowKey];
        self.transform = CGAffineTransformIdentity;
        CABasicAnimation *basic =[CABasicAnimation animation];
        basic.keyPath = @"position";
        basic.fromValue =[NSValue valueWithCGPoint:self.originCenter];
        basic.toValue = [NSValue valueWithCGPoint:CGPointMake(self.center.x, originY)];
        basic.duration = 0.5f;
        basic.delegate = self;
        [basic setValue:PositionKey forKey:@"key"];
        basic.removedOnCompletion = NO;
        basic.fillMode = kCAFillModeForwards;
        [self.layer addAnimation:basic forKey:PositionKey];
    }
}
-(void)animationDidStop:(CABasicAnimation *)anim finished:(BOOL)flag
{
    if ([[anim valueForKey:@"key"] isEqualToString:PositionKey]) {
        [self.layer removeAnimationForKey:PositionKey];
        self.hidden = YES;
    }
}

- (UIImage*) imageName:(NSString*)name {
    return [[WKApp shared] loadImage:name moduleID:[WKMomentModule gmoduleId]];
}
@end
