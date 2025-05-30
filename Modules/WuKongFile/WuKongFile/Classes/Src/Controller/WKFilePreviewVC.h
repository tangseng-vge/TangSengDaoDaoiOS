//
//  WKFilePreviewVC.h
//  WuKongFile
//
//  Created by tt on 2020/7/16.
//

#import <WuKongBase/WuKongBase.h>
#import <QuickLook/QuickLook.h>
NS_ASSUME_NONNULL_BEGIN
@interface WKPreviewFileItem : NSObject <QLPreviewItem>

@property(nonatomic, copy) NSString *title;

@property(nonatomic, strong) NSURL *url;

@end

@interface WKFilePreviewVC : QLPreviewController
@property(nonatomic, copy) NSString *fileName;

@property(nonatomic, strong) NSURL *url;
@end

NS_ASSUME_NONNULL_END
