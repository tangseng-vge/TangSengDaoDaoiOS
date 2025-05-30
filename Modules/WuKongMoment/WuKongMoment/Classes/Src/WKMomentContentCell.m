//
//  WKMomentContentCell.m
//  WuKongMoment
//
//  Created by tt on 2020/11/5.
//

#import "WKMomentContentCell.h"
#import <M80AttributedLabel/M80AttributedLabel.h>
#import "M80AttributedLabel+WK.h"
#import "WKMomentConst.h"
@implementation WKMomentContentModel

- (Class)cell {
    return WKMomentContentCell.class;
}

@end

@interface WKMomentContentCell ()

@property(nonatomic,strong) WKMomentContentModel *model;

@property(nonatomic,strong) UIImageView *avatarImgView; // 头像
@property(nonatomic,strong) UILabel *nameLbl; // 名字

@property(nonatomic,strong) M80AttributedLabel *contentLbl; // 朋友圈文字内容

@property(nonatomic,strong) UIView *imgsBox;

@end





@implementation WKMomentContentCell

+ (CGSize)sizeForModel:(WKMomentContentModel *)model {
    CGFloat contentHeight = 0.0f;
    if(model.content) {
        contentHeight = [self getMomentContentLabelSize:model fontSie:contentFontSize].height;
    }
    CGFloat imgBoxHeight = 0.0f;
    if(model.imgs && model.imgs.count>0) {
        if(model.imgs.count == 1) {
            imgBoxHeight = [self getImgSizeWithPath:model.imgs[0]].height;
        }else {
            NSInteger eachRowNum = 3;
            CGFloat imgWidth = (contentMaxWidth-(2*imgSpace))/eachRowNum;
            if(model.imgs.count == 4) {
                imgBoxHeight = 2*imgWidth + imgSpace;
            }else{
                NSInteger row = model.imgs.count/eachRowNum;
                if(model.imgs.count%eachRowNum !=0) {
                    row ++;
                }
                imgBoxHeight = row*imgWidth + (row-1)*imgSpace;
            }
           
        }
    }
    return CGSizeMake(WKScreenWidth, contentHeight + nameTopSpace + nameHeight + (contentHeight>0? contentTopSpace:0.0f)+cellTopSpace +( imgBoxHeight>0?(imgBoxHeight + imgBoxTopSpace):0.0f));
}

+(CGSize) getImgSizeWithPath:(NSString*) path {
    if([path containsString:@".png@"]) {
        NSArray* array = [path componentsSeparatedByString:@".png@"];
        NSArray* subArray = [array[1] componentsSeparatedByString:@".png"];
        NSArray* imageSizeArray = [subArray[0] componentsSeparatedByString:@"x"];
        if(imageSizeArray.count == 2) {
            return  [UIImage lim_sizeWithImageOriginSize:CGSizeMake([imageSizeArray[0] floatValue], [imageSizeArray[1] floatValue]) maxLength:contentMaxWidth - 60.0f];
        }
        
    }
    return  CGSizeMake(100.0f, 100.0f);
}

- (void)setupUI {
    [super setupUI];
    
    [self.contentView addSubview:self.avatarImgView];
    [self.contentView addSubview:self.nameLbl];
    
    [self.contentView addSubview:self.contentLbl];
    
    [self.contentView addSubview:self.imgsBox];
    
}

- (void)refresh:(WKMomentContentModel *)model {
    [super refresh:model];
    self.model = model;
    
    self.contentLbl.backgroundColor = [UIColor clearColor];
    self.contentLbl.textColor = [WKApp shared].config.defaultTextColor;
    
    [self.contentLbl lim_setText:model.content];
    [self.avatarImgView lim_setImageWithURL:[NSURL URLWithString:model.avatar] placeholderImage:[WKApp shared].config.defaultAvatar];
    WKChannelInfo *channelInfo = [[WKSDK shared].channelManager getChannelInfo:[WKChannel personWithChannelID:model.uid]];
    self.nameLbl.text = model.name;
    if(channelInfo) {
        self.nameLbl.text = channelInfo.displayName;
    }
    
    [[self.imgsBox subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    if(model.imgs && model.imgs.count>0) {
        NSInteger i = 0;
        for (NSString *imgURL  in model.imgs) {
            UIImageView *imgView = [self newImgView:i];
            [imgView lim_setImageWithURL:[[WKApp shared] getImageFullUrl:imgURL] placeholderImage:[WKApp shared].config.defaultPlaceholder];
            [self.imgsBox addSubview:imgView];
            i++;
        }
        self.imgsBox.hidden = NO;
    }else{
        self.imgsBox.hidden = YES;
    }
}



- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.avatarImgView.lim_left = avatarLeftSpace;
    self.avatarImgView.lim_top = cellTopSpace;
    
    self.nameLbl.lim_left = self.avatarImgView.lim_right + nameLeftSpace;
    self.nameLbl.lim_top =  nameTopSpace + cellTopSpace;
    
    CGFloat contentWidth = contentMaxWidth;
    self.nameLbl.lim_width = contentWidth;
    
    if(!self.model.content||[self.model.content isEqualToString:@""]) {
        self.contentLbl.lim_top = self.nameLbl.lim_bottom;
        self.contentLbl.lim_left = self.nameLbl.lim_left;
    }else{
        self.contentLbl.lim_width = contentWidth;
        self.contentLbl.lim_left = self.nameLbl.lim_left;
        self.contentLbl.lim_top = self.nameLbl.lim_bottom + contentTopSpace;
    }
   
    
    CGFloat contentHeight  = [[self class] getMomentContentLabelSize:self.model fontSie:contentFontSize].height;
    self.contentLbl.lim_height = contentHeight;
    
    NSInteger imgsBoxSubCount = self.imgsBox.subviews.count;
    
    self.imgsBox.lim_top = self.contentLbl.lim_bottom + (imgsBoxSubCount>0?imgBoxTopSpace:0.0f);
    self.imgsBox.lim_left = self.contentLbl.lim_left;
    if(imgsBoxSubCount>0) {
        if(imgsBoxSubCount == 1) {
            CGSize firstSize = [[self class] getImgSizeWithPath:self.model.imgs[0]];
            self.imgsBox.lim_size = firstSize;
            UIView *firstView = self.imgsBox.subviews[0];
            firstView.lim_top = 0.0f;
            firstView.lim_size = self.imgsBox.lim_size;
        }else {
            NSInteger index = 0;
            NSInteger row = 0;
            NSInteger col = 0;
            NSInteger eachRowNum = 3;
            CGFloat imgWidth = (contentWidth-(2*imgSpace))/eachRowNum;
            
            if(imgsBoxSubCount == 4) {
                eachRowNum = 2;
            }
            
            for (UIView *imgView in self.imgsBox.subviews) {
                if(index%eachRowNum == 0 ) {
                    row++;
                }
                col = index%eachRowNum + 1;
                imgView.lim_left = (col-1)*(imgWidth + imgSpace);
                imgView.lim_top = (row-1) * (imgWidth + imgSpace);
                imgView.lim_size = CGSizeMake(imgWidth, imgWidth);
                index++;
            }
            self.imgsBox.lim_size = CGSizeMake(contentWidth, row*imgWidth + (row-1)*imgSpace);
        }
    }
    
    
}


-(UIImageView*) newImgView:(NSInteger)tag {
    UIImageView *imgView = [[UIImageView alloc] init];
    imgView.contentMode = UIViewContentModeScaleAspectFill;
    imgView.clipsToBounds = YES;
    imgView.tag = tag;
    
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
    if(self.model.imgs && self.model.imgs.count>0) {
        NSInteger i = 0;
        for (UIImageView *imgV in self.imgsBox.subviews) {
            YBIBImageData *data = [YBIBImageData new];
            [data setImage:^UIImage * _Nullable{
                return imgV.image;
            }];
            data.projectiveView = imgV;
            [dataArray addObject:data];
            i++;
        }
    }
    imageBrowser.dataSourceArray = dataArray;
    imageBrowser.currentPage = imgView.tag;
    
    [imageBrowser show];
}

- (UIImageView *)avatarImgView {
    if(!_avatarImgView) {
        _avatarImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, avatarSize, avatarSize)];
        _avatarImgView.layer.masksToBounds = YES;
        _avatarImgView.layer.cornerRadius = avatarSize/2.0f;
        
        _avatarImgView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onAvatarTap)];
        [_avatarImgView addGestureRecognizer:tap];
    
    }
    return _avatarImgView;
}
-(void) onAvatarTap {
    [[WKApp shared] invoke:WKPOINT_USER_INFO param:@{@"uid":self.model.uid?:@""}];
}

- (UILabel *)nameLbl {
    if(!_nameLbl) {
        _nameLbl = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 0.0f, nameHeight)];
        _nameLbl.textColor = nameColor;
        _nameLbl.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onNameTap)];
        [_nameLbl addGestureRecognizer:tap];
    }
    return _nameLbl;
}

-(void) onNameTap {
    [[WKApp shared] invoke:WKPOINT_USER_INFO param:@{@"uid":self.model.uid?:@""}];
}

- (M80AttributedLabel *)contentLbl {
    if(!_contentLbl) {
        _contentLbl = [[M80AttributedLabel alloc] init];
        _contentLbl.numberOfLines = 0;
        _contentLbl.lineBreakMode = NSLineBreakByWordWrapping;
        [_contentLbl setFont:[UIFont systemFontOfSize:contentFontSize]];
    }
    return _contentLbl;
}

- (UIView *)imgsBox {
    if(!_imgsBox) {
        _imgsBox = [[UIView alloc] init];
    }
    return _imgsBox;
}


+ (CGSize)getMomentContentLabelSize:(WKMomentContentModel *)model fontSie:(CGFloat)fontSize{
    if(!model.content|| [model.content isEqualToString:@""]) {
        return CGSizeZero;
    }
    NSString *cacheKey = [NSString stringWithFormat:@"%@",model.sid];
    
    return [self getTextLabelSize:model.content key:cacheKey maxWidth:contentMaxWidth fontSize:fontSize];
}

+ (CGSize)getTextLabelSize:(NSString *)content key:(NSString*)cacheKey maxWidth:(CGFloat)maxWidth fontSize:(CGFloat)fontSize{
    static WKMemoryCache *memoryCache;
    static NSLock *memoryLock;
    if(!memoryLock) {
        memoryLock = [[NSLock alloc] init];
    }
    if(!memoryCache) {
        memoryCache = [[WKMemoryCache alloc] init];
        memoryCache.maxCacheNum = 500;
    }
  
    [memoryLock lock];
   NSString *cacheSizeStr =   [memoryCache getCache:cacheKey];
    [memoryLock unlock];
    if(cacheSizeStr) {
        return CGSizeFromString(cacheSizeStr);
    }
    static M80AttributedLabel *textLbl;
    if(!textLbl) {
        textLbl = [[M80AttributedLabel alloc] init];
        [textLbl setFont:[UIFont systemFontOfSize:fontSize]];
    }
    [textLbl lim_setText:content];
    
    CGSize textSize = [textLbl sizeThatFits:CGSizeMake(maxWidth, CGFLOAT_MAX)];
     [memoryLock lock];
    [memoryCache setCache:NSStringFromCGSize(textSize) forKey:cacheKey];
     [memoryLock unlock];
    return textSize;
}
@end
