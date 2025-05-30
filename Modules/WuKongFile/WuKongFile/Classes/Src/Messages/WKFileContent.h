//
//  WKFileContent.h
//  WuKongFile
//
//  Created by tt on 2020/5/5.
//

#import <WuKongBase/WuKongBase.h>

NS_ASSUME_NONNULL_BEGIN

@interface WKFileContent : WKMediaMessageContent
@property(nonatomic,copy) NSString *url; // 文件下载地址
@property(nonatomic,copy) NSString *name; // 文件名
@property(nonatomic,assign) NSInteger size; // 文件大小


+(WKFileContent*) initWithFileName:(NSString*)fileName fileData:(NSData*)data;
@end

NS_ASSUME_NONNULL_END
