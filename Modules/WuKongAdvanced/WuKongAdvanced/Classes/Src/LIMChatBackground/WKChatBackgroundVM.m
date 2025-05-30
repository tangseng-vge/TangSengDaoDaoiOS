//
//  WKChatBackgroundVM.m
//  WuKongAdvanced
//
//  Created by tt on 2022/9/12.
//

#import "WKChatBackgroundVM.h"
#import "WKChatBackgroundItemCell.h"
#import "WKChatBackgroundPreviewVC.h"
#import "WKPhotoBrowser.h"
@interface WKChatBackgroundVM ()

@property(nonatomic,strong) NSMutableArray<WKChatBackground*> *chatBackgrounds;

@end

@implementation WKChatBackgroundVM

- (NSArray<NSDictionary *> *)tableSectionMaps {
    
    NSInteger rowMaxBg = 3;
    __weak typeof(self) weakSelf = self;
    NSMutableArray<NSDictionary*> *bgItems = [NSMutableArray array];
    if(self.chatBackgrounds&&self.chatBackgrounds.count>0) {
        NSInteger row = self.chatBackgrounds.count/rowMaxBg;
        
        for (NSInteger i=0; i<row; i++) {
            [bgItems addObject:@{
                @"class": WKChatBackgroundItemCellModel.class,
                @"maxNum": @(rowMaxBg),
                @"chatBackgrounds": [self.chatBackgrounds subarrayWithRange:NSMakeRange(i*rowMaxBg, rowMaxBg)],
                @"onBackground":^(WKChatBackground*chatBg){
                    [weakSelf chatBackgroundPressed:chatBg];
                }
                
            }];
            
        }
        NSInteger rem = self.chatBackgrounds.count%rowMaxBg;
        if(rem!=0) {
            [bgItems addObject:@{
                @"class": WKChatBackgroundItemCellModel.class,
                @"maxNum": @(rowMaxBg),
                @"chatBackgrounds": [self.chatBackgrounds subarrayWithRange:NSMakeRange(self.chatBackgrounds.count-rem, rem)],
                @"onBackground":^(WKChatBackground*chatBg){
                    [weakSelf chatBackgroundPressed:chatBg];
                }
            }];
        }
    }

    return @[
        @{
            @"height":WKSectionHeight,
            @"items": @[
                @{
                    @"class":WKLabelItemModel.class,
                    @"label":LLang(@"从手机相册选择"),
                    @"onClick":^{
                        [[WKPhotoBrowser shared] showPhotoLibraryWithSender:WKNavigationManager.shared.topViewController selectCompressImageBlock:^(NSArray<NSData *> * _Nonnull images, NSArray<PHAsset *> * _Nonnull assets, BOOL isOriginal) {
                            WKChatBackground *bg = [WKChatBackground new];
                            bg.image = [UIImage imageWithData:images[0]];
                            [weakSelf chatBackgroundPressed:bg];
                        } maxSelectCount:1 allowSelectVideo:NO];
                    }
                },
                @{
                    @"class":WKLabelItemModel.class,
                    @"label":LLang(@"拍一张"),
                    @"onClick":^{
                        [[WKPhotoService shared] getPhotoFromCamera:^(UIImage * _Nonnull image) {
                            WKChatBackground *bg = [WKChatBackground new];
                            bg.image = image;
                            [weakSelf chatBackgroundPressed:bg];
                        }];
                    }
                }
            ],
        },
        @{
            @"height":WKSectionHeight,
            @"items": bgItems,
        }
    ];
}

- (NSMutableArray<WKChatBackground *> *)chatBackgrounds {
    if(!_chatBackgrounds) {
        _chatBackgrounds = [NSMutableArray array];
    }
    return _chatBackgrounds;
}

- (void)requestData:(void (^)(NSError * _Nullable))complete {
    __weak typeof(self) weakSelf = self;
    [WKAPIClient.sharedClient GET:@"common/chatbg" parameters:nil model:WKChatBackground.class].then(^(NSArray<WKChatBackground*>*backgrounds){
        NSMutableArray *bgArray = [NSMutableArray arrayWithArray:backgrounds];
        
        UIImage *defaultBgImg = [WKApp.shared loadImage:@"Conversation/Index/ChatBg" moduleID:@"WuKongBase"];
        if(defaultBgImg) {
            WKChatBackground *defaultBg = [WKChatBackground new];
            defaultBg.image = defaultBgImg;
            
            [bgArray insertObject:defaultBg atIndex:0];
        }
        
        weakSelf.chatBackgrounds = [NSMutableArray arrayWithArray:bgArray];
        [weakSelf reloadData];
    });
}

-(void) chatBackgroundPressed:(WKChatBackground*)chatBg {
    WKChatBackgroundPreviewVC *vc = [WKChatBackgroundPreviewVC new];
    vc.chatBackground = chatBg;
    vc.channel = self.channel;
    [WKNavigationManager.shared pushViewController:vc animated:YES];
}

@end

@implementation WKChatBackground

+ (WKModel *)fromMap:(NSDictionary *)dictory type:(ModelMapType)type {
    WKChatBackground *bg = [WKChatBackground new];
    bg.url = dictory[@"url"];
    bg.cover = dictory[@"cover"];
    bg.isSvg = [dictory[@"is_svg"] boolValue];
    NSArray<NSString*> *darkColors =  dictory[@"dark_colors"];
    NSArray<NSString*> *lightColors = dictory[@"light_colors"];
    if(darkColors && darkColors.count>0) {
        NSMutableArray<UIColor*> *darkColorArray = [NSMutableArray array];
        for (NSString *darkColor in darkColors) {
            [darkColorArray addObject:[UIColor colorWithHexString:darkColor]];
        }
        bg.darkColors = darkColorArray;
    }
    if(lightColors && lightColors.count>0) {
        NSMutableArray<UIColor*> *lightColorArray = [NSMutableArray array];
        for (NSString *lightColor in lightColors) {
            [lightColorArray addObject:[UIColor colorWithHexString:lightColor]];
        }
        bg.lightColors = lightColorArray;
    }
    return bg;
}


@end
