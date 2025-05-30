//
//  WKFileCommon.h
//  WuKongFile
//
//  Created by tt on 2020/5/5.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    WKFileTypeUnknown,
    WKFileTypeWord,
    WKFileTypeImage,
    WKFileTypeExcel,
    WKFileTypePPT,
    WKFileTypePDF,
    WKFileTypeZIP,
    WKFileTypeRAR,
    WKFileTypeText,
    WKFileTypePages,
} WKFileType;

NS_ASSUME_NONNULL_BEGIN

@interface WKFileInfoModel : NSObject

@property(nonatomic,copy) NSString *extendIcon;
@property(nonatomic,strong) UIColor *fileColor;

@end

@interface WKFileCommon : NSObject

+ (WKFileCommon *)shared;

-(WKFileInfoModel*) fileInfoWithName:(NSString*)name;

-(NSString*) sizeFormat:(NSInteger)size;


/// 是否支持的格式
/// @param filename <#filename description#>
-(BOOL) support:(NSString*)filename;

@end

NS_ASSUME_NONNULL_END
