//
//  WKMomentPublishImgGroupCell.m
//  WuKongMoment
//
//  Created by tt on 2020/11/12.
//

#import "WKMomentPublishImgGroupCell.h"
#import <YBImageBrowser/YBImageBrowser.h>
#import "WKMomentModule.h"
@implementation WKMomentPublishImgGroupModel


- (Class)cell {
    return WKMomentPublishImgGroupCell.class;
}

@end

@interface WKMomentPublishImgGroupCell ()

@property(nonatomic,strong) UIView *box;

@property(nonatomic,strong) WKMomentPublishImgGroupModel *model;

@property(nonatomic,strong) UIView *addView;

@end

@interface WKomentImageView : UIImageView



+ (instancetype) task:(WKMomentFileUploadTask*) task;
@end

@interface WKomentImageView ()
@property(nonatomic,strong) WKMomentFileUploadTask *task;
@property(nonatomic,strong) WKLoadProgressView *progressView;
@end

@implementation WKomentImageView

+ (instancetype) task:(WKMomentFileUploadTask*) task {
    WKomentImageView *imgView = [[WKomentImageView alloc] init];
    imgView.task = task;
    [imgView setup];
    return imgView;
}

-(void) setup {
    [self addSubview:self.progressView];
    if(self.task.status != WKMomentTaskStatusSuccess) {
        [self.progressView setProgress:0.0f];
        __weak typeof(self) weakSelf = self;
        [self.task addListener:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf taskUpdate];
            });
           
        } target:self];
    }
    
    
    
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.progressView.lim_size = self.lim_size;
}

-(void) taskUpdate {
    if(self.task.status == WKMomentTaskStatusSuccess) {
        [self.progressView removeFromSuperview];
    }else{
        [self.progressView setProgress:self.task.progress];
    }
    
}

- (WKLoadProgressView *)progressView {
    if(!_progressView) {
        _progressView = [[WKLoadProgressView alloc] init];
        _progressView.maxProgress = 1.0f;
    }
    return _progressView;
}

- (void)dealloc {
    [self.task removeListener:self];
}

@end

#define imgSpace 5.0f
#define eachColNum 3

#define boxLeftSpace 20.0f

@implementation WKMomentPublishImgGroupCell

- (void)prepareForReuse {
    [super prepareForReuse];
    
    if(self.model && self.model.imgTasks) {
        for (WKMomentFileUploadTask *task in self.model.imgTasks) {
            [task removeListener:self];
        }
    }
}

+ (CGSize)sizeForModel:(WKMomentPublishImgGroupModel *)model {
    CGFloat width = WKScreenWidth - boxLeftSpace*2;
    CGFloat colNum = eachColNum;
    
    CGFloat itemSize = (width - (colNum-1)*imgSpace)/colNum;
    CGFloat height = 0.0f;
    
    NSInteger itemNum = model.imgTasks.count;
    if(itemNum<9) {
        itemNum++;
    }
    
    NSInteger rowNum = itemNum/eachColNum;
    if(itemNum%eachColNum !=0) {
        rowNum++;
    }
    
    height = itemSize * rowNum + (rowNum-1)*imgSpace;
    return  CGSizeMake(width,height);
}

- (void)setupUI {
    [super setupUI];
    [self.contentView addSubview:self.box];
}

- (void)refresh:(WKMomentPublishImgGroupModel *)model {
    [super refresh:model];
    self.model = model;
    [[self.box subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    if(model.imgTasks && model.imgTasks.count>0) {
        NSInteger i = 0;
        for (WKMomentFileUploadTask *task in model.imgTasks) {
            [self.box addSubview:[self newImgView:task index:i]];
            i++;
        }
        if(model.imgTasks.count<9) {
            [self.box addSubview:self.addView];
        }
    }
}



-(WKomentImageView*) newImgView:(WKMomentFileUploadTask*)task index:(NSInteger)index{
    WKomentImageView *imgView = [WKomentImageView task:task];
    imgView.contentMode = UIViewContentModeScaleAspectFill;
    imgView.clipsToBounds = YES;
    imgView.image = task.image;
    imgView.tag = index;
    imgView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTap:)];
    [imgView addGestureRecognizer:tap];
    return imgView;
}




-(void) onTap:(UIGestureRecognizer*)gesture {
    UIView *imgView = gesture.view;
    YBImageBrowser *imageBrowser = [[YBImageBrowser alloc] init];
    imageBrowser.toolViewHandlers = @[WKBrowserToolbar.new];
    imageBrowser.webImageMediator = [WKDefaultWebImageMediator new];
    
    NSMutableArray<id<YBIBDataProtocol>> *dataArray = [NSMutableArray array];
    if(self.model.imgTasks && self.model.imgTasks.count>0) {
        NSInteger i = 0;
        for (WKMomentFileUploadTask *task in self.model.imgTasks) {
            YBIBImageData *data = [YBIBImageData new];
            [data setImage:^UIImage * _Nullable{
                return task.image;
            }];
            data.projectiveView = self.box.subviews[i];
            [dataArray addObject:data];
            i++;
        }
    }
    imageBrowser.dataSourceArray = dataArray;
    imageBrowser.currentPage = imgView.tag;
    
    [imageBrowser show];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.box.lim_left = boxLeftSpace;
    self.box.lim_width = WKScreenWidth - self.box.lim_left*2;
    self.box.lim_height = self.lim_height;
    if(self.box.subviews.count>0) {
        
        CGFloat width = self.box.lim_width;
        CGFloat colNum = eachColNum;
        CGFloat itemSize = (width - (colNum-1)*imgSpace)/colNum;
        
        NSInteger row = 0;
        NSInteger col = 0;
        for (NSInteger i=0;i<self.box.subviews.count;i++) {
            if(i%eachColNum == 0) {
                row++;
            }
            col = i%eachColNum+1;
            
            UIView *view = self.box.subviews[i];
            view.lim_top = (row-1) * (itemSize+imgSpace);
            view.lim_left = (col - 1)* (itemSize+imgSpace);
            view.lim_size = CGSizeMake(itemSize, itemSize);
            
            if(view.tag == 99) {
                view.subviews[0].lim_centerX_parent = view;
                view.subviews[0].lim_centerY_parent = view;
            }
        }
    }
}

- (UIView *)addView {
    if(!_addView) {
        _addView = [[UIView alloc] init];
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 32.0f, 32.0f)];
        imgView.image = [self imageName:@"IconAdd"];
        _addView.tag = 99;
        [_addView addSubview:imgView];
        [_addView setBackgroundColor:[UIColor colorWithRed:240.0f/255.0f green:240.0f/255.0f blue:240.0f/255.0f alpha:1.0f]];
        
        _addView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(addPressed)];
        [_addView addGestureRecognizer:tap];
    }
    return _addView;
}

-(void) addPressed {
    if(self.model.onAdd) {
        self.model.onAdd();
    }
}

- (UIView *)box {
    if(!_box) {
        _box = [[UIView alloc] init];
    }
    return _box;
}

- (UIImage*) imageName:(NSString*)name {
    return [[WKApp shared] loadImage:name moduleID:[WKMomentModule gmoduleId]];
}

@end
